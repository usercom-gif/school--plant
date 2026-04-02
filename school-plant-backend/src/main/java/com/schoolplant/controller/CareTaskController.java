package com.schoolplant.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.schoolplant.common.R;
import com.schoolplant.dto.UserTaskSettingRequest;
import com.schoolplant.entity.CareTask;
import com.schoolplant.entity.Plant;
import com.schoolplant.entity.User;
import com.schoolplant.entity.UserTaskSetting;
import com.schoolplant.service.CareTaskService;
import com.schoolplant.service.PlantService;
import com.schoolplant.service.UserService;
import com.schoolplant.service.UserTaskSettingService;
import com.schoolplant.vo.CareTaskVO;
import cn.dev33.satoken.annotation.SaCheckLogin;
import cn.dev33.satoken.annotation.SaCheckRole;
import cn.dev33.satoken.annotation.SaMode;
import cn.dev33.satoken.stp.StpUtil;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/task")
public class CareTaskController {

    @Autowired
    private CareTaskService careTaskService;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private PlantService plantService;
    
    @Autowired
    private UserTaskSettingService userTaskSettingService;

    @Autowired
    private com.schoolplant.service.PlantAbnormalityService plantAbnormalityService;

    // 获取我的养护任务设置
    @SaCheckLogin
    @GetMapping("/settings")
    public R<List<UserTaskSetting>> getSettings(@RequestParam Long plantId) {
        Long userId = StpUtil.getLoginIdAsLong();
        return R.ok(userTaskSettingService.getSettings(userId, plantId));
    }

    // 保存我的养护任务设置
    @SaCheckLogin
    @PostMapping("/settings")
    public R<Void> saveSettings(@RequestParam Long plantId, @RequestBody List<UserTaskSettingRequest> requests) {
        Long userId = StpUtil.getLoginIdAsLong();
        try {
            userTaskSettingService.saveSettings(userId, plantId, requests);
            return R.ok();
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    // 我的今日任务 (User)
    @SaCheckLogin
    @GetMapping("/my-tasks")
    public R<Page<CareTaskVO>> myTasks(@RequestParam(defaultValue = "1") int page,
                                     @RequestParam(defaultValue = "10") int size,
                                     @RequestParam(required = false) String status) {
        Long userId = StpUtil.getLoginIdAsLong();
        Page<CareTask> pageParam = new Page<>(page, size);
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<CareTask> wrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        wrapper.eq("adopter_id", userId);
        if (status != null && !status.isEmpty()) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("due_date");
        
        Page<CareTask> result = careTaskService.page(pageParam, wrapper);
                
        return R.ok(convertToVO(result));
    }

    // 任务列表 (Admin)
    @SaCheckRole(value = {"ADMIN", "MAINTAINER"}, mode = SaMode.OR)
    @GetMapping("/list")
    public R<Page<CareTaskVO>> list(@RequestParam(defaultValue = "1") int page,
                                  @RequestParam(defaultValue = "10") int size,
                                  @RequestParam(required = false) Long userId,
                                  @RequestParam(required = false) String status) {
        Page<CareTask> pageParam = new Page<>(page, size);
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<CareTask> wrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        if (userId != null) wrapper.eq("adopter_id", userId);
        if (status != null && !status.isEmpty()) wrapper.eq("status", status);
        wrapper.orderByDesc("created_at");
        
        return R.ok(convertToVO(careTaskService.page(pageParam, wrapper)));
    }

    // 创建任务 (Admin)
    @SaCheckRole("ADMIN")
    @PostMapping("/create")
    public R<Boolean> create(@RequestBody CareTask task) {
        task.setStatus("PENDING");
        return R.ok(careTaskService.save(task));
    }

    // 更新任务 (Admin)
    @SaCheckRole("ADMIN")
    @PutMapping("/update")
    public R<Boolean> update(@RequestBody CareTask task) {
        return R.ok(careTaskService.updateById(task));
    }

    // 删除任务 (Admin)
    @SaCheckRole("ADMIN")
    @DeleteMapping("/{ids}")
    public R<Boolean> delete(@PathVariable List<Long> ids) {
        return R.ok(careTaskService.removeByIds(ids));
    }

    // 完成任务打卡 (User)
    @SaCheckLogin
    @PostMapping("/complete")
    public R<Boolean> complete(@RequestBody CareTask task) {
        if (task.getId() == null) return R.fail("任务ID不能为空");
        CareTask existing = careTaskService.getById(task.getId());
        if (existing == null) return R.fail("任务不存在");
        
        // 校验权限
        if (!existing.getUserId().equals(StpUtil.getLoginIdAsLong())) {
            return R.fail("无权操作他人任务");
        }

        List<String> imageUrls = new ArrayList<>();
        if (task.getImageUrls() != null && !task.getImageUrls().isEmpty()) {
            imageUrls.addAll(task.getImageUrls().stream().filter(s -> s != null && !s.trim().isEmpty()).collect(Collectors.toList()));
        } else if (task.getImageUrl() != null && !task.getImageUrl().trim().isEmpty()) {
            imageUrls.add(task.getImageUrl().trim());
        }

        if (imageUrls.isEmpty()) {
            return R.fail("请上传照片凭证");
        }
        if (imageUrls.size() > 5) {
            return R.fail("最多上传5张照片");
        }

        String stored;
        if (imageUrls.size() == 1) {
            stored = imageUrls.get(0);
        } else {
            stored = com.alibaba.fastjson2.JSON.toJSONString(imageUrls);
        }

        try {
            careTaskService.completeTask(task.getId(), stored);
            return R.ok(true);
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }
    
    // 这个接口和上方的 complete 重名且功能重复，保留一个即可，但由于我之前添加了，为了编译通过先删除或者修改参数
    // 我们保留原有基于 RequestBody 的 complete 接口即可，因为前端实际调用的是它
    
    @io.swagger.v3.oas.annotations.Operation(summary = "从任务中上报异常")
    @SaCheckLogin
    @PostMapping("/{id}/report-abnormality")
    public R<String> reportAbnormalityFromTask(
            @PathVariable Long id,
            @RequestParam String type,
            @RequestParam String desc,
            @RequestParam String reporterName,
            @RequestParam String reporterContact,
            @RequestParam(value = "images", required = false) org.springframework.web.multipart.MultipartFile[] images) {
        Long userId = StpUtil.getLoginIdAsLong();
        String aiDiagnosis = plantAbnormalityService.reportAbnormalityFromTask(id, userId, type, desc, reporterName, reporterContact, images);
        return R.ok(aiDiagnosis);
    }

    private Page<CareTaskVO> convertToVO(Page<CareTask> page) {
        Page<CareTaskVO> voPage = new Page<>();
        BeanUtils.copyProperties(page, voPage, "records");
        
        List<CareTaskVO> voList = page.getRecords().stream().map(task -> {
            CareTaskVO vo = new CareTaskVO();
            BeanUtils.copyProperties(task, vo);
            
            User user = userService.getById(task.getUserId());
            if (user != null) vo.setUserName(user.getRealName());
            
            Plant plant = plantService.getById(task.getPlantId());
            if (plant != null) vo.setPlantName(plant.getName());
            
            return vo;
        }).collect(Collectors.toList());
        
        voPage.setRecords(voList);
        return voPage;
    }
}
