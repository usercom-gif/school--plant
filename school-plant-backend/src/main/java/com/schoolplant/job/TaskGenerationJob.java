package com.schoolplant.job;

import com.schoolplant.service.CareTaskService;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;

@Component
public class TaskGenerationJob extends QuartzJobBean {

    @Autowired
    private CareTaskService careTaskService;

    @Override
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
        System.out.println("【定时任务】开始生成每日养护任务");
        careTaskService.generateDailyTasks();
        System.out.println("【定时任务】养护任务生成完成");
    }
}