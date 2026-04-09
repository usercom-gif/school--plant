package com.schoolplant.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.schoolplant.entity.Achievement;

import java.util.Map;

public interface AchievementService extends IService<Achievement> {
    void generateCycleReport(String adoptionCycle);
    Achievement getMyAchievement(String adoptionCycle, Long userId);
    Map<String, Object> getStats(String adoptionCycle);
    byte[] generateCertificate(Long userId, String adoptionCycle);
    void updateUserAchievement(Long userId, Long plantId);
    void auditAchievement(Long id, boolean isPass);
}
