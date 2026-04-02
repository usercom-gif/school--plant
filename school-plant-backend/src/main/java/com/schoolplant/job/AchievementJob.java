package com.schoolplant.job;

import com.schoolplant.service.AchievementService;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class AchievementJob implements Job {

    @Autowired
    private AchievementService achievementService;

    @Autowired
    private com.schoolplant.service.SystemParameterService parameterService;

    @Override
    public void execute(JobExecutionContext context) {
        // Use system parameter for current cycle
        String adoptionCycle = parameterService.getValue("CURRENT_CYCLE", "2024-Cycle1");
        
        System.out.println("【定时任务】开始生成认养周期成果报告: " + adoptionCycle);
        achievementService.generateCycleReport(adoptionCycle);
        System.out.println("【定时任务】成果报告生成完成");
    }
}
