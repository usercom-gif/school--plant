package com.schoolplant.job;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.schoolplant.entity.AdoptionRecord;
import com.schoolplant.entity.Plant;
import com.schoolplant.mapper.AdoptionRecordMapper;
import com.schoolplant.mapper.PlantMapper;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;

@Component
public class AdoptionFinishJob extends QuartzJobBean {

    @Autowired
    private AdoptionRecordMapper adoptionRecordMapper;

    @Autowired
    private PlantMapper plantMapper;

    @Override
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
        LocalDate today = LocalDate.now();

        List<AdoptionRecord> expired = adoptionRecordMapper.selectList(new LambdaQueryWrapper<AdoptionRecord>()
                .eq(AdoptionRecord::getStatus, "ACTIVE")
                .isNotNull(AdoptionRecord::getEndDate)
                .lt(AdoptionRecord::getEndDate, today)
        );

        for (AdoptionRecord record : expired) {
            record.setStatus("FINISHED");
            adoptionRecordMapper.updateById(record);

            Plant plant = plantMapper.selectById(record.getPlantId());
            if (plant != null && "ADOPTED".equals(plant.getStatus())) {
                plant.setStatus("AVAILABLE");
                plantMapper.updateById(plant);
            }
        }
    }
}

