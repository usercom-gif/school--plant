package com.schoolplant.service;

import com.schoolplant.dto.PlantImageAnalysisResult;

import java.io.File;

public interface PlantImageAnalysisService {
    PlantImageAnalysisResult analyze(File imageFile);

    default PlantImageAnalysisResult analyze(File imageFile, String userDescription) {
        return analyze(imageFile);
    }
}
