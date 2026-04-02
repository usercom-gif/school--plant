package com.schoolplant.service.impl;

import com.schoolplant.dto.PlantImageAnalysisResult;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;

public class PlantImageAnalysisServiceImplTest {

    @Test
    public void analyze_shouldDetectHealthy() throws Exception {
        File img = createSolidImage(800, 600, new Color(40, 160, 60));
        PlantImageAnalysisServiceImpl service = new PlantImageAnalysisServiceImpl();
        PlantImageAnalysisResult r = service.analyze(img);
        Assertions.assertEquals("HEALTHY", r.getStatus());
        Assertions.assertNotNull(r.getConfidence());
        Assertions.assertTrue(r.getConfidence() >= 0.5);
    }

    @Test
    public void analyze_shouldDetectYellowing() throws Exception {
        File img = createSolidImage(800, 600, new Color(200, 200, 40));
        PlantImageAnalysisServiceImpl service = new PlantImageAnalysisServiceImpl();
        PlantImageAnalysisResult r = service.analyze(img);
        Assertions.assertEquals("YELLOWING", r.getStatus());
    }

    private static File createSolidImage(int w, int h, Color color) throws Exception {
        BufferedImage image = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setColor(color);
        g.fillRect(0, 0, w, h);
        g.dispose();

        File tmp = File.createTempFile("plant-test-", ".png");
        tmp.deleteOnExit();
        ImageIO.write(image, "png", tmp);
        return tmp;
    }
}

