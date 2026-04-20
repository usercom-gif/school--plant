package com.schoolplant.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.entity.*;
import com.schoolplant.mapper.*;
import com.schoolplant.service.CareTaskService;
import com.schoolplant.service.UserTaskSettingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
public class CareTaskServiceImpl extends ServiceImpl<CareTaskMapper, CareTask> implements CareTaskService {

    @Autowired
    private CareTaskMapper careTaskMapper;

    @Autowired
    private AdoptionRecordMapper recordMapper;

    @Autowired
    private TaskTemplateMapper templateMapper;
    
    @Autowired
    private PlantMapper plantMapper;

    @Autowired
    private UserTaskSettingService userTaskSettingService;

    @Autowired
    private com.schoolplant.service.SystemParameterService parameterService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void generateDailyTasks() {
        // 1. Get all active adoptions (ACTIVE) from AdoptionRecord
        LocalDate targetDate = LocalDate.now().plusDays(1);
        List<AdoptionRecord> activeAdoptions = recordMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AdoptionRecord>()
                .eq(AdoptionRecord::getStatus, "ACTIVE")
                .and(w -> w.isNull(AdoptionRecord::getEndDate).or().ge(AdoptionRecord::getEndDate, targetDate))
        );

        // 2. For each adoption, check settings and generate tasks
        for (AdoptionRecord adoption : activeAdoptions) {
            Long userId = adoption.getUserId();
            Long plantId = adoption.getPlantId();

            // Check if user has custom settings
            List<UserTaskSetting> userSettings = userTaskSettingService.getSettings(userId, plantId);

            if (!userSettings.isEmpty()) {
                // Use User Settings
                for (UserTaskSetting setting : userSettings) {
                    if (targetDate.toEpochDay() % setting.getFrequencyDays() == 0) {
                        // Requirement: Time set to 13:00
                        LocalDateTime scheduledTime = LocalDateTime.of(targetDate, LocalTime.of(13, 0));
                        createTask(userId, plantId, setting.getTaskType(), "用户自定义任务", 
                                   scheduledTime, true);
                    }
                }
            } else {
                // Use System Templates
                Plant plant = plantMapper.selectById(plantId);
                if (plant != null) {
                    List<TaskTemplate> templates = templateMapper.selectList(
                        new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<TaskTemplate>()
                            .eq(TaskTemplate::getPlantSpecies, plant.getSpecies())
                    );
                    
                    for (TaskTemplate template : templates) {
                        if (targetDate.toEpochDay() % template.getFrequencyDays() == 0) {
                            // Requirement: Time set to 13:00
                            LocalDateTime scheduledTime = LocalDateTime.of(targetDate, LocalTime.of(13, 0));
                            createTask(userId, plantId, template.getTaskType(), template.getTaskDescription(), 
                                       scheduledTime, false);
                        }
                    }
                }
            }
        }
    }
    
    private void createTask(Long userId, Long plantId, String type, String desc, LocalDateTime scheduledTime, boolean isUserDefined) {
        CareTask task = new CareTask();
        task.setPlantId(plantId);
        task.setUserId(userId);
        task.setTaskType(type);
        task.setTaskDescription(desc);
        task.setDueDate(scheduledTime.toLocalDate());
        task.setScheduledTime(scheduledTime);
        task.setIsUserDefined(isUserDefined ? 1 : 0);
        task.setStatus("PENDING");
        this.save(task);
    }

    @Autowired
    private com.schoolplant.service.AchievementService achievementService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void completeTask(Long taskId, String imageUrl) {
        CareTask task = this.getById(taskId);
        if (task == null) {
            throw new RuntimeException("任务不存在");
        }
        
        // 1. Get clock-in time window from system params (Default: 00:00:00 - 23:59:59)
        String startTimeStr = parameterService.getValue("CLOCK_IN_START_TIME", "00:00");
        String endTimeStr = parameterService.getValue("CLOCK_IN_END_TIME", "23:59");
        
        LocalTime nowTime = LocalTime.now();
        LocalTime start = LocalTime.parse(startTimeStr);
        LocalTime end = LocalTime.parse(endTimeStr);
        
        // 当配置为全天时，不进行严格的拦截，或者进行包容性判断
        // 注意：23:59:59 可能会被 parse 为 23:59，这里直接用 23:59 作为基准，
        // 实际上如果是 00:00 到 23:59，任何时间都是符合的，只有用户配了非全天才会拦截
        if (nowTime.isBefore(start) || (nowTime.isAfter(end) && !endTimeStr.equals("23:59"))) {
             throw new RuntimeException("打卡失败：只能在 " + startTimeStr + " - " + endTimeStr + " 之间进行打卡");
        }
        
        // 2. Update status
        task.setStatus("COMPLETED");
        task.setImageUrl(imageUrl);
        task.setCompletedDate(LocalDate.now());
        this.updateById(task);
        
        // 3. Update Achievements
        achievementService.updateUserAchievement(task.getUserId(), task.getPlantId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void checkOverdueTasks() {
        // 当打卡时间修改为全天（00:00-23:59）后，逾期检查应该只针对“昨天及以前”的任务
        // 所以我们查找所有 dueDate < today 的 pending 任务，将它们标记为逾期
        
        List<CareTask> overdueTasks = careTaskMapper.selectList(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<CareTask>()
            .eq(CareTask::getStatus, "PENDING")
            .lt(CareTask::getDueDate, LocalDate.now()) // 严格小于今天
        );
        
        for (CareTask task : overdueTasks) {
            task.setStatus("OVERDUE");
            this.updateById(task);
            // Optional: Penalty logic or notification
        }
    }
}
