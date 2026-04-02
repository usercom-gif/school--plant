package com.schoolplant.dto;

import lombok.Data;
import java.time.LocalTime;

@Data
public class UserTaskSettingRequest {
    private String taskType;
    private Integer frequencyDays;
    private LocalTime scheduledTime;
}
