package com.schoolplant.service;

import com.schoolplant.dto.PlantImageAnalysisResult;
import com.schoolplant.service.impl.PlantImageAnalysisServiceImpl;
import com.schoolplant.util.PlantAiTextTemplate;
import org.junit.jupiter.api.Test;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.nio.file.Files;

import static org.junit.jupiter.api.Assertions.*;

public class PlantImageAnalysisServiceImplTest {

    @Test
    void analyze_shouldUseUserDescriptionWhenImageIsUnclear() throws Exception {
        BufferedImage image = new BufferedImage(200, 200, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, 200, 200);
        g.dispose();

        File tmp = Files.createTempFile("plant-analysis-", ".png").toFile();
        ImageIO.write(image, "png", tmp);

        PlantImageAnalysisServiceImpl service = new PlantImageAnalysisServiceImpl();
        PlantImageAnalysisResult result = service.analyze(tmp, "叶子发黄，有斑点，怀疑虫害");

        assertNotNull(result);
        assertNotNull(result.getConfidence());
        assertTrue(result.getConfidence() >= 0.35);
        assertNotNull(result.getSummary());
        assertNotNull(result.getUserDescription());

        String text = PlantAiTextTemplate.buildAbnormalityDecisionText(
                "未明确",
                "病害",
                "叶子发黄，有斑点，怀疑虫害",
                result
        );
        assertTrue(text.contains("判定结果如下"));
        assertTrue(text.contains("判定依据说明"));
        assertTrue(text.contains("解决建议"));
        assertFalse(text.contains("补充上传"));
        assertFalse(text.contains("描述症状"));
    }
}
