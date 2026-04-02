package com.schoolplant.util;

import com.schoolplant.dto.PlantImageAnalysisResult;

import java.util.ArrayList;
import java.util.List;

public class PlantAiTextTemplate {

    private PlantAiTextTemplate() {
    }

    public static String buildAbnormalityDecisionText(
            String plantSpecies,
            String userSelectedType,
            String userDescription,
            PlantImageAnalysisResult analysis
    ) {
        String speciesText = (plantSpecies == null || plantSpecies.isBlank()) ? "未明确" : plantSpecies.trim();

        String abnormalType = inferAbnormalityType(userSelectedType, analysis);
        String conclusion = buildConclusion(abnormalType, userDescription, analysis);

        String symptom = buildSymptomText(userDescription, analysis);
        String envCause = buildEnvironmentCauseText(abnormalType);
        String standardTerm = buildStandardTerm(abnormalType);
        String solution = buildSolutionText(abnormalType, analysis);

        StringBuilder sb = new StringBuilder();
        sb.append("判定结果如下：\n\n");
        sb.append("植物品种").append(speciesText).append("+异常类型：[").append(conclusion).append("]\n\n");
        sb.append("判定依据说明：\n\n");
        sb.append("症状特征：").append(symptom).append("\n");
        sb.append("环境诱因：").append(envCause).append("\n");
        sb.append("标准术语：").append(standardTerm).append("\n");
        sb.append("解决建议：").append(solution).append("\n");
        sb.append("如需更具体判定，请补充植物品种及环境描述。\n");
        return sb.toString();
    }

    private static String inferAbnormalityType(String userSelectedType, PlantImageAnalysisResult analysis) {
        String byImage = null;
        if (analysis != null && analysis.getStatus() != null) {
            switch (analysis.getStatus()) {
                case "SPOTTED_OR_DISEASE" -> byImage = "叶斑病类/病虫害";
                case "YELLOWING" -> byImage = "黄化/缺素或浇水不当";
                case "DRY_OR_BROWN" -> byImage = "干枯/灼伤或根系问题";
                case "HEALTHY" -> byImage = "未见明显异常（需复核）";
                default -> byImage = null;
            }
        }

        if (byImage != null) {
            if (userSelectedType != null && !userSelectedType.isBlank()) {
                return byImage + "（用户选择：" + userSelectedType.trim() + "）";
            }
            return byImage;
        }

        if (userSelectedType != null && !userSelectedType.isBlank()) {
            return userSelectedType.trim();
        }
        return "未明确";
    }

    private static String buildConclusion(String abnormalType, String userDescription, PlantImageAnalysisResult analysis) {
        String symptomOverview = buildSymptomOverview(userDescription, analysis);
        String possibleCause = buildPossibleCauseText(abnormalType);
        String solution = buildSolutionText(abnormalType, analysis);
        StringBuilder sb = new StringBuilder();
        sb.append(symptomOverview).append("；");
        sb.append("可能诱因：").append(possibleCause).append("；");
        sb.append("初步解决方案：").append(solution).append("。");
        if (analysis != null && analysis.getConfidence() != null) {
            sb.append("（置信度：").append(String.format("%.2f", analysis.getConfidence())).append("）");
        }
        return sb.toString();
    }

    private static String buildSymptomOverview(String userDescription, PlantImageAnalysisResult analysis) {
        String desc = userDescription == null ? "" : userDescription.trim();
        if (!desc.isEmpty()) {
            String d = shorten(desc, 70);
            return "症状概述：" + d;
        }

        if (analysis != null && analysis.getSummary() != null && !analysis.getSummary().isBlank()) {
            return "症状概述：" + analysis.getSummary().trim();
        }

        return "症状概述：图片特征不明显，无法可靠判断植物状态";
    }

    private static String buildPossibleCauseText(String abnormalType) {
        if (abnormalType.contains("叶斑") || abnormalType.contains("病虫害")) {
            return "真菌性叶斑病（如炭疽病、褐斑病）或虫害影响，常伴随高湿环境、通风不良、叶面长时间潮湿";
        }
        if (abnormalType.contains("黄化") || abnormalType.contains("缺素")) {
            return "缺素（如缺铁/缺氮）、浇水不当或光照不适，导致叶色发黄";
        }
        if (abnormalType.contains("干枯") || abnormalType.contains("灼伤")) {
            return "缺水、强光日灼、空气过干或根系吸收受限（积水/烂根）";
        }
        return "信息不足，需结合环境与管理方式进一步确认";
    }

    private static String buildSymptomText(String userDescription, PlantImageAnalysisResult analysis) {
        String desc = userDescription == null ? "" : userDescription.trim();
        StringBuilder sb = new StringBuilder();

        if (!desc.isEmpty()) {
            sb.append("根据用户描述（").append(shorten(desc, 60)).append("）");
        } else {
            sb.append("用户未提供详细症状描述");
        }

        if (analysis != null && analysis.getSummary() != null && !analysis.getSummary().isBlank()) {
            sb.append("，结合图片分析显示：").append(analysis.getSummary().trim());
        }

        sb.append("，建议记录并补充环境信息（浇水频率、光照强度、通风情况、近期施肥/换盆、异常出现时间）。");
        return sb.toString();
    }

    private static String buildEnvironmentCauseText(String abnormalType) {
        if (abnormalType.contains("叶斑") || abnormalType.contains("病虫害")) {
            return "常见于高湿、通风差、叶面长时间潮湿或密植环境，有助于真菌/虫害发生。";
        }
        if (abnormalType.contains("黄化") || abnormalType.contains("缺素")) {
            return "可能与光照变化、浇水不当、土壤养分不足或根系吸收受限有关。";
        }
        if (abnormalType.contains("干枯") || abnormalType.contains("灼伤")) {
            return "可能与缺水、强光暴晒、空气过于干燥或盆土长期积水导致根系问题有关。";
        }
        return "目前信息不足，需结合光照、浇水、通风与近期管理措施进一步判断。";
    }

    private static String buildStandardTerm(String abnormalType) {
        if (abnormalType.contains("叶斑")) return "统一表述为“叶斑病类异常”。";
        if (abnormalType.contains("病虫害")) return "统一表述为“病虫害类异常”。";
        if (abnormalType.contains("黄化")) return "统一表述为“黄化/缺素类异常”。";
        if (abnormalType.contains("干枯")) return "统一表述为“干枯/日灼/根系问题类异常”。";
        return "统一表述为“植物异常（待进一步确认）”。";
    }

    private static String buildSolutionText(String abnormalType, PlantImageAnalysisResult analysis) {
        List<String> candidates = new ArrayList<>();
        if (analysis != null && analysis.getSuggestions() != null && !analysis.getSuggestions().isEmpty()) {
            candidates.addAll(analysis.getSuggestions());
        }

        if (candidates.isEmpty()) {
            if (abnormalType.contains("叶斑") || abnormalType.contains("病虫害")) {
                candidates.add("及时剪除明显病叶并清理落叶");
                candidates.add("改善通风，避免叶面长期潮湿，浇水尽量避开叶面");
                candidates.add("必要时按说明稀释使用广谱杀菌剂/杀虫剂并观察 3-5 天变化");
            } else if (abnormalType.contains("黄化") || abnormalType.contains("缺素")) {
                candidates.add("检查盆土干湿与排水，偏湿则延长浇水间隔，偏干则分次浇透");
                candidates.add("逐步调整至合适散射光，避免突然强光直射");
                candidates.add("可按说明少量补充复合肥或含铁营养液，避免一次用量过大");
            } else if (abnormalType.contains("干枯") || abnormalType.contains("灼伤")) {
                candidates.add("检查土壤：偏干则尽快浇透，偏湿且有异味则减少浇水并排查烂根");
                candidates.add("避免中午强光直晒，必要时遮阴并提高环境湿度");
                candidates.add("剪除干枯叶片，减少无效消耗并观察新叶生长情况");
            } else {
                candidates.add("补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）");
                candidates.add("描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议");
            }
        }

        candidates = candidates.stream()
                .map(s -> s == null ? "" : s.replaceAll("[\r\n]+", " ").trim())
                .filter(s -> !s.isEmpty())
                .toList();

        int max = Math.min(3, candidates.size());
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < max; i++) {
            if (i > 0) sb.append("，");
            sb.append(candidates.get(i));
        }
        return sb.toString();
    }

    private static String shorten(String text, int maxLen) {
        if (text == null) return "";
        String t = text.replaceAll("[\r\n]+", " ").trim();
        if (t.length() <= maxLen) return t;
        return t.substring(0, maxLen) + "…";
    }
}
