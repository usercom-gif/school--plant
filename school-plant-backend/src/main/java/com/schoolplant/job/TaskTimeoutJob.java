package com.schoolplant.job;

import com.schoolplant.service.CareTaskService;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;

@Component
public class TaskTimeoutJob extends QuartzJobBean {

    @Autowired
    private CareTaskService careTaskService;

    @Override
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
        System.out.println("【定时任务】开始检查逾期任务");
        careTaskService.checkOverdueTasks();
        System.out.println("【定时任务】逾期任务检查完成");
    }
}