package com.schoolplant.dto;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class PlantImageAnalysisResult {
    private String status;
    private Double confidence;
    private String summary;
    private String userDescription;
    private List<String> suggestions = new ArrayList<>();

    public String toSuggestionText() {
        StringBuilder sb = new StringBuilder();
        if (summary != null && !summary.isBlank()) {
            sb.append("识别结果：").append(summary);
        } else if (status != null && !status.isBlank()) {
            sb.append("识别结果：").append(status);
        } else {
            sb.append("识别结果：无法判断");
        }
        if (confidence != null) {
            sb.append("（置信度：").append(String.format("%.2f", confidence)).append("）");
        }
        sb.append("\n");

        if (userDescription != null && !userDescription.isBlank()) {
            sb.append("用户描述：").append(userDescription.trim()).append("\n");
        }

        if (suggestions != null && !suggestions.isEmpty()) {
            sb.append("处理建议：\n");
            for (int i = 0; i < suggestions.size(); i++) {
                sb.append(i + 1).append("）").append(suggestions.get(i)).append("\n");
            }
        } else {
            sb.append("处理建议：暂无\n");
        }
        sb.append("提示：建议补充清晰近景与叶背照片以提高准确性。\n");
        sb.append("说明：以上为基于图片与描述的初步建议，可作为养护人员处理参考。 ");
        return sb.toString();
    }
}
