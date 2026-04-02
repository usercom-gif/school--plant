package com.schoolplant.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.common.R;
import com.schoolplant.dto.UserTaskSettingRequest;
import com.schoolplant.entity.Plant;
import com.schoolplant.entity.TaskTemplate;
import com.schoolplant.entity.UserTaskSetting;
import com.schoolplant.mapper.PlantMapper;
import com.schoolplant.mapper.TaskTemplateMapper;
import com.schoolplant.mapper.UserTaskSettingMapper;
import com.schoolplant.service.UserTaskSettingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class UserTaskSettingServiceImpl extends ServiceImpl<UserTaskSettingMapper, UserTaskSetting> implements UserTaskSettingService {

    @Autowired
    private TaskTemplateMapper templateMapper;

    @Autowired
    private PlantMapper plantMapper;

    @Override
    public List<UserTaskSetting> getSettings(Long userId, Long plantId) {
        return this.list(new LambdaQueryWrapper<UserTaskSetting>()
                .eq(UserTaskSetting::getUserId, userId)
                .eq(UserTaskSetting::getPlantId, plantId));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveSettings(Long userId, Long plantId, List<UserTaskSettingRequest> requests) {
        // 1. Get Plant Species
        Plant plant = plantMapper.selectById(plantId);
        if (plant == null) {
            throw new RuntimeException("植物不存在");
        }

        // 2. Get System Templates for this species
        List<TaskTemplate> templates = templateMapper.selectList(new LambdaQueryWrapper<TaskTemplate>()
                .eq(TaskTemplate::getPlantSpecies, plant.getSpecies()));

        // 3. Validate: User settings must meet minimum frequency requirements
        // Map templates by task type for easy lookup
        Map<String, Integer> systemFrequencyMap = templates.stream()
                .collect(Collectors.toMap(TaskTemplate::getTaskType, TaskTemplate::getFrequencyDays, (v1, v2) -> Math.min(v1, v2)));

        // Check if user settings cover all required task types and frequency is sufficient
        // Note: FrequencyDays: smaller is more frequent. UserFreq <= SystemFreq means UserCount >= SystemCount.
        
        for (UserTaskSettingRequest request : requests) {
            Integer systemFreq = systemFrequencyMap.get(request.getTaskType());
            if (systemFreq != null) {
                if (request.getFrequencyDays() > systemFreq) {
                    throw new RuntimeException("任务类型 " + request.getTaskType() + 
                        " 的频率必须至少每 " + systemFreq + " 天一次 (当前: " + request.getFrequencyDays() + ")");
                }
            }
        }
        
        // Also check if user missed any required task types? 
        // Requirement: "User defined tasks count not less than system default".
        // This implies total count. But usually means covering all bases.
        // Let's assume user must cover all types defined in system templates.
        for (String type : systemFrequencyMap.keySet()) {
            boolean covered = requests.stream().anyMatch(r -> r.getTaskType().equals(type));
            if (!covered) {
                throw new RuntimeException("缺失必需的任务类型: " + type);
            }
        }

        // 4. Delete existing settings and save new ones
        this.remove(new LambdaQueryWrapper<UserTaskSetting>()
                .eq(UserTaskSetting::getUserId, userId)
                .eq(UserTaskSetting::getPlantId, plantId));

        List<UserTaskSetting> settings = requests.stream().map(req -> {
            UserTaskSetting setting = new UserTaskSetting();
            setting.setUserId(userId);
            setting.setPlantId(plantId);
            setting.setTaskType(req.getTaskType());
            setting.setFrequencyDays(req.getFrequencyDays());
            setting.setScheduledTime(req.getScheduledTime());
            return setting;
        }).collect(Collectors.toList());

        this.saveBatch(settings);
    }
}
