package com.schoolplant.dto;

import lombok.Data;

@Data
public class AdoptionStatusResponse {
    private boolean canAdopt;
    private String message;
    
    // New fields
    private boolean hasActiveAdoption;
    private Long plantId;
    private String plantName;
    private boolean hasPendingApplication;
}
