package com.schoolplant.controller;

import cn.dev33.satoken.annotation.SaCheckLogin;
import cn.dev33.satoken.annotation.SaCheckRole;
import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.schoolplant.annotation.Log;
import com.schoolplant.common.R;
import com.schoolplant.entity.Achievement;
import com.schoolplant.service.AchievementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/achievement")
public class AchievementController {

    @Autowired
    private AchievementService achievementService;

    // 我的成果
    @SaCheckLogin
    @GetMapping("/my")
    public R<Achievement> my(@RequestParam String adoptionCycle) {
        Long userId = StpUtil.getLoginIdAsLong();
        Achievement achievement = achievementService.getMyAchievement(adoptionCycle, userId);
        if (achievement != null && achievement.getIsOutstanding() != null && achievement.getIsOutstanding() == 1) {
            if (achievement.getCertificateUrl() == null || achievement.getCertificateUrl().trim().isEmpty()) {
                achievement.setCertificateUrl("/api/achievement/certificate/" + userId + "/" + adoptionCycle);
            }
        }
        return R.ok(achievement);
    }
    
    // 优秀榜单 (公开) / 待审核榜单 (管理员)
    @GetMapping("/outstanding")
    public R<Page<Achievement>> outstanding(@RequestParam(defaultValue = "1") int page,
                                            @RequestParam(defaultValue = "10") int size,
                                            @RequestParam String adoptionCycle,
                                            @RequestParam(defaultValue = "1") Integer isOutstanding) {
        Page<Achievement> pageParam = new Page<>(page, size);
        return R.ok(achievementService.page(pageParam, 
            new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Achievement>()
                .eq("adoption_cycle", adoptionCycle)
                .eq("is_outstanding", isOutstanding)
                .orderByDesc("task_completion_rate")));
    }
    
    // 统计数据 (管理员)
    @SaCheckRole("ADMIN")
    @GetMapping("/stats")
    public R<Map<String, Object>> stats(@RequestParam String adoptionCycle) {
        return R.ok(achievementService.getStats(adoptionCycle));
    }
    
    // 证书下载
    @GetMapping("/certificate/{userId}/{adoptionCycle}")
    public org.springframework.http.ResponseEntity<?> certificate(@PathVariable Long userId, @PathVariable String adoptionCycle) {
        try {
            byte[] bytes = achievementService.generateCertificate(userId, adoptionCycle);
            String fileName = "certificate-" + userId + "-" + adoptionCycle.replaceAll("[^A-Za-z0-9]", "") + ".png";
            return org.springframework.http.ResponseEntity.ok()
                    .header("Content-Type", "image/png")
                    .header("Content-Disposition", "attachment; filename=\"" + fileName + "\"")
                    .body(bytes);
        } catch (Exception e) {
            return org.springframework.http.ResponseEntity.status(400)
                    .header("Content-Type", "application/json;charset=UTF-8")
                    .body("{\"code\":400, \"msg\":\"" + e.getMessage() + "\"}");
        }
    }
    
    // 手动触发生成 (管理员)
    @SaCheckRole("ADMIN")
    @Log(module = "ACHIEVEMENT", desc = "生成周期报告", type = "UPDATE", key = "#adoptionCycle")
    @PostMapping("/generate")
    public R<Void> generate(@RequestParam String adoptionCycle) {
        achievementService.generateCycleReport(adoptionCycle);
        return R.ok();
    }

    // 审核人工复核 (管理员)
    @SaCheckRole("ADMIN")
    @Log(module = "ACHIEVEMENT", desc = "人工复核评比", type = "UPDATE", key = "#id")
    @PostMapping("/audit")
    public R<Void> audit(@RequestParam Long id, @RequestParam boolean isPass) {
        achievementService.auditAchievement(id, isPass);
        return R.ok();
    }
}
