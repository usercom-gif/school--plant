package com.schoolplant.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class OperationLogQueryRequest {
    private Integer page = 1;
    private Integer size = 10;

    private Long operatorId;
    
    private String operatorName;
    private String module;
    private String operationType;
    private String startTime;
    private String endTime;
}
