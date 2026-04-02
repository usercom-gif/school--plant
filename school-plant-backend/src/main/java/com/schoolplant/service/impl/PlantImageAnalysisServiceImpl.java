package com.schoolplant.service.impl;

import com.schoolplant.dto.PlantImageAnalysisResult;
import com.schoolplant.service.PlantImageAnalysisService;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;

@Service
public class PlantImageAnalysisServiceImpl implements PlantImageAnalysisService {

    @Override
    public PlantImageAnalysisResult analyze(File imageFile) {
        return analyze(imageFile, null);
    }

    @Override
    public PlantImageAnalysisResult analyze(File imageFile, String userDescription) {
        PlantImageAnalysisResult result = new PlantImageAnalysisResult();
        if (userDescription != null && !userDescription.isBlank()) {
            result.setUserDescription(userDescription.trim());
        }
        if (imageFile == null || !imageFile.exists()) {
            result.setStatus("UNKNOWN");
            result.setConfidence(0.0);
            result.setSummary("未检测到有效图片");
            result.getSuggestions().add("请重新拍摄并上传清晰图片（叶片与整体各一张）");
            return result;
        }

        BufferedImage image;
        try {
            image = ImageIO.read(imageFile);
        } catch (Exception e) {
            result.setStatus("UNKNOWN");
            result.setConfidence(0.0);
            result.setSummary("图片解析失败");
            result.getSuggestions().add("请更换图片格式（建议 JPG/PNG）后重试");
            return result;
        }

        if (image == null) {
            result.setStatus("UNKNOWN");
            result.setConfidence(0.0);
            result.setSummary("图片内容无法读取");
            result.getSuggestions().add("请更换图片格式（建议 JPG/PNG）后重试");
            return result;
        }

        int width = image.getWidth();
        int height = image.getHeight();
        if (width <= 10 || height <= 10) {
            result.setStatus("UNKNOWN");
            result.setConfidence(0.0);
            result.setSummary("图片分辨率过低");
            result.getSuggestions().add("请上传更清晰的照片（建议至少 640×480）");
            return result;
        }

        int step = Math.max(1, Math.min(width, height) / 200);
        long total = 0;

        long green = 0;
        long yellow = 0;
        long brown = 0;
        long dark = 0;

        double vSum = 0.0;
        double sSum = 0.0;

        for (int y = 0; y < height; y += step) {
            for (int x = 0; x < width; x += step) {
                int rgb = image.getRGB(x, y);
                int r = (rgb >> 16) & 0xFF;
                int g = (rgb >> 8) & 0xFF;
                int b = rgb & 0xFF;

                double[] hsv = rgbToHsv(r, g, b);
                double h = hsv[0];
                double s = hsv[1];
                double v = hsv[2];

                total++;
                vSum += v;
                sSum += s;

                if (v < 0.18 && s > 0.20) dark++;

                if (s < 0.12 || v < 0.12) continue;

                if (h >= 70 && h <= 170) {
                    green++;
                } else if (h >= 35 && h < 70) {
                    yellow++;
                } else if (h >= 10 && h < 35 && v < 0.75) {
                    brown++;
                }
            }
        }

        double greenRatio = total == 0 ? 0 : green * 1.0 / total;
        double yellowRatio = total == 0 ? 0 : yellow * 1.0 / total;
        double brownRatio = total == 0 ? 0 : brown * 1.0 / total;
        double darkRatio = total == 0 ? 0 : dark * 1.0 / total;
        double vAvg = total == 0 ? 0 : vSum / total;
        double sAvg = total == 0 ? 0 : sSum / total;

        if (greenRatio > 0.45 && yellowRatio < 0.18 && brownRatio < 0.10 && darkRatio < 0.12) {
            result.setStatus("HEALTHY");
            result.setConfidence(clamp(0.65 + greenRatio * 0.35));
            result.setSummary("整体偏健康，叶色以绿色为主");
            result.getSuggestions().add("保持当前浇水频率，浇水前先触摸土表确认干湿");
            result.getSuggestions().add("保证通风与合适光照，避免长期暴晒或长期阴暗");
            result.getSuggestions().add("每周观察叶背是否有虫卵/蚜虫，早发现早处理");
            return result;
        }

        if (yellowRatio > 0.25 && greenRatio < 0.45) {
            result.setStatus("YELLOWING");
            result.setConfidence(clamp(0.50 + Math.min(0.40, yellowRatio)));
            result.setSummary("叶片偏黄，可能存在缺素、浇水不当或光照问题");
            result.getSuggestions().add("检查盆土是否长期潮湿；若偏湿，延长浇水间隔并改善排水");
            result.getSuggestions().add("在不烧根前提下少量追施复合肥或含铁营养液（按说明稀释）");
            result.getSuggestions().add("调整光照：避免突然强光直射，可逐步增加散射光");
            return result;
        }

        if (brownRatio > 0.18 || (greenRatio < 0.20 && vAvg < 0.35)) {
            result.setStatus("DRY_OR_BROWN");
            double base = 0.45 + Math.min(0.45, Math.max(brownRatio, 0.20));
            result.setConfidence(clamp(base));
            result.setSummary("叶缘/叶片偏褐或发暗，可能缺水、灼伤或根系问题");
            result.getSuggestions().add("检查土壤：若偏干，分次浇透；若偏湿且有异味，考虑烂根并减少浇水");
            result.getSuggestions().add("剪除干枯叶片，避免继续消耗养分");
            result.getSuggestions().add("避免中午强光直晒，必要时增加遮阴与空气湿度");
            return result;
        }

        if (darkRatio > 0.15 && sAvg > 0.18) {
            result.setStatus("SPOTTED_OR_DISEASE");
            result.setConfidence(clamp(0.45 + Math.min(0.45, darkRatio)));
            result.setSummary("存在较多暗色区域，可能为叶斑/霉菌或虫害导致的斑点");
            result.getSuggestions().add("隔离患株，减少交叉感染；剪除明显病叶并及时清理落叶");
            result.getSuggestions().add("保持通风，避免叶面长期潮湿；浇水尽量避开叶面");
            result.getSuggestions().add("必要时使用广谱杀菌剂/杀虫剂（按说明稀释），并观察 3-5 天变化");
            return result;
        }

        result.setStatus("UNKNOWN");
        result.setConfidence(0.35);
        result.setSummary("图片特征不明显，无法可靠判断植物状态");
        result.getSuggestions().add("先隔离异常植株（或与健康植株保持距离），避免交叉感染");
        result.getSuggestions().add("检查浇水与排水：盆土长期偏湿则减少浇水并增强通风，偏干则分次浇透");
        result.getSuggestions().add("检查叶背与茎部是否有虫体/虫卵；轻度可清水冲洗或棉签清理，必要时按说明用药");
        result.getSuggestions().add("剪除明显病叶/枯叶并清理落叶，避免叶面长期潮湿，必要时使用广谱杀菌剂观察 3-5 天");
        result.getSuggestions().add("可初步检测土壤pH与肥力，偏碱可少量补充硫酸亚铁并增加有机肥（按说明稀释）");

        applyDescriptionHeuristics(result, userDescription);
        return result;
    }

    private void applyDescriptionHeuristics(PlantImageAnalysisResult result, String userDescription) {
        if (result == null) return;
        if (userDescription == null || userDescription.isBlank()) return;

        String d = userDescription.trim();
        String lower = d.toLowerCase();

        boolean hasYellow = containsAny(d, "黄叶", "发黄", "变黄", "黄化");
        boolean hasSpot = containsAny(d, "斑点", "叶斑", "黑点", "褐斑", "霉", "白粉");
        boolean hasCurl = containsAny(d, "卷曲", "卷叶", "发皱", "畸形", "皱");
        boolean hasInsect = containsAny(d, "虫", "蚜虫", "介壳", "红蜘蛛", "虫卵", "小飞虫");
        boolean hasWilt = containsAny(d, "萎蔫", "下垂", "没精神", "软趴");
        boolean hasRot = containsAny(d, "腐烂", "烂根", "发臭", "霉烂");
        boolean tooShort = d.length() < 8;

        if (result.getConfidence() != null && result.getConfidence() > 0.45) return;

        if (hasInsect) {
            result.setStatus("SPOTTED_OR_DISEASE");
            result.setConfidence(Math.max(0.48, result.getConfidence() == null ? 0.0 : result.getConfidence()));
            result.setSummary("图片特征不明显，但结合描述疑似虫害/虫咬导致异常");
            result.getSuggestions().add(0, "重点检查叶背与枝条是否有虫体/虫卵；可先用清水冲洗或棉签擦拭");
            result.getSuggestions().add(1, "如发现蚜虫/红蜘蛛等，可使用对应杀虫剂或肥皂水（低浓度）处理并观察 3-5 天");
        } else if (hasSpot) {
            result.setStatus("SPOTTED_OR_DISEASE");
            result.setConfidence(Math.max(0.46, result.getConfidence() == null ? 0.0 : result.getConfidence()));
            result.setSummary("图片特征不明显，但结合描述疑似叶斑/霉菌类问题");
            result.getSuggestions().add(0, "剪除明显病叶并清理落叶，保持通风，避免叶面长期潮湿");
            result.getSuggestions().add(1, "必要时使用广谱杀菌剂（按说明稀释），连续观察 3-5 天变化");
        } else if (hasYellow) {
            result.setStatus("YELLOWING");
            result.setConfidence(Math.max(0.47, result.getConfidence() == null ? 0.0 : result.getConfidence()));
            result.setSummary("图片特征不明显，但结合描述存在黄叶表现，可能与浇水/光照/缺素有关");
            result.getSuggestions().add(0, "检查盆土干湿与排水：偏湿则延长浇水间隔并改善排水，偏干则分次浇透");
            result.getSuggestions().add(1, "可少量补充复合肥或含铁营养液（按说明稀释），避免一次用量过大");
        } else if (hasRot) {
            result.setStatus("DRY_OR_BROWN");
            result.setConfidence(Math.max(0.46, result.getConfidence() == null ? 0.0 : result.getConfidence()));
            result.setSummary("图片特征不明显，但结合描述疑似根系/腐烂问题");
            result.getSuggestions().add(0, "检查是否积水或盆土发臭：如偏湿，暂停浇水并改善通风排水");
            result.getSuggestions().add(1, "必要时脱盆检查根系，剪除腐烂根并更换疏松基质");
        } else if (hasWilt) {
            result.setStatus("DRY_OR_BROWN");
            result.setConfidence(Math.max(0.45, result.getConfidence() == null ? 0.0 : result.getConfidence()));
            result.setSummary("图片特征不明显，但结合描述存在萎蔫现象，可能与缺水/闷根有关");
            result.getSuggestions().add(0, "检查土壤：偏干则尽快浇透，偏湿则减少浇水并改善通风");
        } else if (hasCurl) {
            result.setStatus("UNKNOWN");
            result.setConfidence(Math.max(0.40, result.getConfidence() == null ? 0.0 : result.getConfidence()));
            result.setSummary("图片特征不明显，但结合描述存在卷叶现象，需进一步确认虫害/药害/环境胁迫");
            result.getSuggestions().add(0, "补充叶背近景与卷曲部位特写，并说明近期是否施肥/喷药/暴晒或受冻");
        }

        if (tooShort || lower.contains("不知道") || lower.contains("不清楚")) {
            result.setConfidence(Math.min(0.45, result.getConfidence() == null ? 0.45 : result.getConfidence()));
        }
    }

    private boolean containsAny(String text, String... keywords) {
        if (text == null) return false;
        for (String k : keywords) {
            if (k != null && !k.isBlank() && text.contains(k)) return true;
        }
        return false;
    }

    private static double[] rgbToHsv(int r, int g, int b) {
        double rd = r / 255.0;
        double gd = g / 255.0;
        double bd = b / 255.0;

        double max = Math.max(rd, Math.max(gd, bd));
        double min = Math.min(rd, Math.min(gd, bd));
        double delta = max - min;

        double h;
        if (delta == 0) {
            h = 0;
        } else if (max == rd) {
            h = 60 * (((gd - bd) / delta) % 6);
        } else if (max == gd) {
            h = 60 * (((bd - rd) / delta) + 2);
        } else {
            h = 60 * (((rd - gd) / delta) + 4);
        }
        if (h < 0) h += 360;

        double s = max == 0 ? 0 : delta / max;
        double v = max;
        return new double[]{h, s, v};
    }

    private static double clamp(double v) {
        if (v < 0) return 0;
        if (v > 1) return 1;
        return v;
    }
}
