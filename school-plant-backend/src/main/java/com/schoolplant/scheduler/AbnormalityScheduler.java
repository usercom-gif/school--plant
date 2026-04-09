package com.schoolplant.scheduler;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.schoolplant.entity.PlantAbnormality;
import com.schoolplant.service.PlantAbnormalityService;
import com.schoolplant.service.AchievementService;
import com.schoolplant.websocket.AbnormalityWebSocket;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
public class AbnormalityScheduler {

    @Autowired
    private PlantAbnormalityService abnormalityService;

    @Autowired
    private AchievementService achievementService;

    // Check every 5 minutes
    @Scheduled(fixedRate = 300000)
    public void checkOvertime() {
        log.info("Checking for overtime abnormalities and audits...");
        
        // 1. Check overtime abnormalities
        abnormalityService.checkOverdueAbnormalities();
        
        // 2. Check overdue audits
        achievementService.checkOverdueAudits();
    }
}
