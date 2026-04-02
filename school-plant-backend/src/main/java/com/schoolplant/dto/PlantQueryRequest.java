package com.schoolplant.dto;

import lombok.Data;
import java.time.Year;

@Data
public class PlantQueryRequest {
    private Integer page = 1;
    private Integer size = 10;
    
    private String keyword; // General search (name, species, location)
    private String name;    // Specific name search
    private String species;
    private String region;
    private Integer careDifficulty;
    private String status;
}
