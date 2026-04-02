package com.schoolplant.dto;

import lombok.Data;

@Data
public class ContentReportQueryRequest {
    private Integer page = 1;
    private Integer size = 10;
    private String status;
}
