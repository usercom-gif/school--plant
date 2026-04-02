package com.schoolplant.controller;

import cn.dev33.satoken.annotation.SaCheckLogin;
import cn.dev33.satoken.annotation.SaCheckRole;
import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.schoolplant.annotation.Log;
import com.schoolplant.common.R;
import com.schoolplant.entity.PlantAbnormality;
import com.schoolplant.service.PlantAbnormalityService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.schoolplant.service.PlantService;
import com.schoolplant.entity.Plant;
import java.util.List;

@Tag(name = "植物异常管理", description = "植物异常管理")
@RestController
@RequestMapping("/abnormality")
public class AbnormalityController {

    @Autowired
    private PlantAbnormalityService abnormalityService;
    
    @Autowired
    private PlantService plantService;

    @Operation(summary = "上报异常并获取AI建议")
    @SaCheckLogin
    @Log(module = "ABNORMALITY", desc = "上报异常", type = "INSERT")
    @PostMapping("/report")
    public R<String> report(
            @RequestParam(required = false) Long plantId,
            @RequestParam String type,
            @RequestParam(required = false) String desc,
            @RequestParam(required = false) String location,
            @RequestParam String reporterName,
            @RequestParam String reporterContact,
            @RequestPart(required = false) MultipartFile[] images
    ) {
        Long reporterId = StpUtil.getLoginIdAsLong();
        if (StringUtils.hasText(location) && (images == null || images.length == 0)) {
            return R.fail("上报非认养植物异常时必须上传至少一张图片");
        }
        if (images != null && images.length > 5) {
            return R.fail("最多上传5张图片");
        }
        MultipartFile[] safeImages = images == null ? new MultipartFile[0] : images;
        String suggestion = abnormalityService.reportAbnormality(
                plantId, reporterId, type, desc, reporterName, reporterContact, location, safeImages
        );
        return R.ok(suggestion);
    }

    @Operation(summary = "分派异常工单")
    @SaCheckRole("ADMIN")
    @Log(module = "ABNORMALITY", desc = "分派工单", type = "UPDATE")
    @PostMapping("/assign")
    public R<Void> assign(@RequestParam Long id, @RequestParam Long maintainerId) {
        Long operatorId = StpUtil.getLoginIdAsLong();
        abnormalityService.assignMaintainer(id, maintainerId, operatorId);
        return R.ok();
    }

    @Operation(summary = "处理异常工单")
    @SaCheckLogin
    @Log(module = "ABNORMALITY", desc = "处理工单", type = "UPDATE")
    @PostMapping("/resolve")
    public R<Void> resolve(
            @RequestParam Long id,
            @RequestParam String resolution,
            @RequestParam String materials,
            @RequestParam String evaluation,
            @RequestPart(required = false) MultipartFile[] images
    ) {
        if (!StpUtil.hasRole("MAINTAINER") && !StpUtil.hasRole("ADMIN")) {
            return R.fail("无权限操作");
        }
        if (images != null && images.length > 1) {
            return R.fail("最多上传1张图片");
        }
        MultipartFile[] safeImages = images == null ? new MultipartFile[0] : images;
        abnormalityService.resolveAbnormality(id, resolution, materials, evaluation, safeImages);
        return R.ok();
    }

    @Operation(summary = "标记异常处理失败")
    @SaCheckLogin
    @Log(module = "ABNORMALITY", desc = "标记处理失败", type = "UPDATE")
    @PostMapping("/unresolved")
    public R<Void> markUnresolved(
            @RequestParam Long id,
            @RequestParam String reason,
            @RequestParam String materials,
            @RequestParam String evaluation,
            @RequestPart(required = false) MultipartFile[] images
    ) {
        if (!StpUtil.hasRole("MAINTAINER") && !StpUtil.hasRole("ADMIN")) {
            return R.fail("无权限操作");
        }
        if (images != null && images.length > 1) {
            return R.fail("最多上传1张图片");
        }
        MultipartFile[] safeImages = images == null ? new MultipartFile[0] : images;
        abnormalityService.markUnresolved(id, reason, materials, evaluation, safeImages);
        return R.ok();
    }

    @Operation(summary = "查询我的异常上报")
    @SaCheckLogin
    @GetMapping("/my")
    public R<Page<PlantAbnormality>> myReports(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size
    ) {
        Page<PlantAbnormality> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<PlantAbnormality> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlantAbnormality::getReporterId, StpUtil.getLoginIdAsLong());
        wrapper.orderByDesc(PlantAbnormality::getCreatedAt);
        
        Page<PlantAbnormality> resultPage = abnormalityService.page(pageParam, wrapper);
        populatePlantNames(resultPage.getRecords());
        return R.ok(resultPage);
    }
    
    @Operation(summary = "查询异常列表")
    @SaCheckLogin
    @GetMapping("/list")
    public R<Page<PlantAbnormality>> list(
            // ... params
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) Long maintainerId,
            @RequestParam(required = false) Long reporterId
    ) {
        Page<PlantAbnormality> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<PlantAbnormality> wrapper = new LambdaQueryWrapper<>();
        
        if (StringUtils.hasText(status)) {
            wrapper.eq(PlantAbnormality::getStatus, status);
        }
        if (StringUtils.hasText(type)) {
            wrapper.like(PlantAbnormality::getAbnormalityType, type);
        }
        if (StringUtils.hasText(description)) {
            wrapper.like(PlantAbnormality::getDescription, description);
        }
        if (maintainerId != null) {
            wrapper.eq(PlantAbnormality::getMaintainerId, maintainerId);
        }
        if (reporterId != null) {
            wrapper.eq(PlantAbnormality::getReporterId, reporterId);
        }
        
        // RBAC Filter
        if (StpUtil.hasRole("USER")) {
            wrapper.eq(PlantAbnormality::getReporterId, StpUtil.getLoginIdAsLong());
        } else if (StpUtil.hasRole("MAINTAINER")) {
            wrapper.eq(PlantAbnormality::getMaintainerId, StpUtil.getLoginIdAsLong());
        }

        wrapper.orderByDesc(PlantAbnormality::getCreatedAt);
        Page<PlantAbnormality> resultPage = abnormalityService.page(pageParam, wrapper);
        populatePlantNames(resultPage.getRecords());
        return R.ok(resultPage);
    }
    
    private void populatePlantNames(List<PlantAbnormality> list) {
        if (list == null || list.isEmpty()) return;
        for (PlantAbnormality item : list) {
            if (item.getPlantId() != null) {
                Plant plant = plantService.getById(item.getPlantId());
                if (plant != null) {
                    item.setPlantName(plant.getName());
                }
            }
        }
    }
    
    @Operation(summary = "获取异常详情")
    @SaCheckLogin
    @GetMapping("/{id}")
    public R<PlantAbnormality> getDetail(@PathVariable Long id) {
        return R.ok(abnormalityService.getById(id));
    }
}
