package com.schoolplant.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.entity.Achievement;
import com.schoolplant.entity.AdoptionRecord;
import com.schoolplant.entity.CareTask;
import com.schoolplant.entity.PlantAbnormality;
import com.schoolplant.entity.User;
import com.schoolplant.mapper.AchievementMapper;
import com.schoolplant.mapper.AdoptionRecordMapper;
import com.schoolplant.mapper.CareTaskMapper;
import com.schoolplant.mapper.PlantAbnormalityMapper;
import com.schoolplant.mapper.UserMapper;
import com.schoolplant.service.AchievementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AchievementServiceImpl extends ServiceImpl<AchievementMapper, Achievement> implements AchievementService {

    @Autowired
    private UserMapper userMapper;
    
    @Autowired
    private CareTaskMapper taskMapper;

    @Autowired
    private AdoptionRecordMapper adoptionRecordMapper;

    @Autowired
    private PlantAbnormalityMapper abnormalityMapper;

    @Autowired
    private com.schoolplant.service.SystemParameterService parameterService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateUserAchievement(Long userId, Long plantId) {
        // 1. Find active or recently finished adoption record to determine context
        AdoptionRecord record = adoptionRecordMapper.selectOne(new LambdaQueryWrapper<AdoptionRecord>()
                .eq(AdoptionRecord::getUserId, userId)
                .eq(AdoptionRecord::getPlantId, plantId)
                .and(w -> w.eq(AdoptionRecord::getStatus, "ACTIVE").or().eq(AdoptionRecord::getStatus, "FINISHED"))
                .orderByDesc(AdoptionRecord::getCreatedAt)
                .last("LIMIT 1")
        );

        if (record == null) return;

        // 2. Calculate Stats
        // Count total tasks (COMPLETED + OVERDUE) for this plant and user
        Long total = taskMapper.selectCount(new LambdaQueryWrapper<CareTask>()
                .eq(CareTask::getUserId, userId)
                .eq(CareTask::getPlantId, plantId)
                .in(CareTask::getStatus, "COMPLETED", "OVERDUE")
        );
        
        // Count completed tasks
        Long completed = taskMapper.selectCount(new LambdaQueryWrapper<CareTask>()
                .eq(CareTask::getUserId, userId)
                .eq(CareTask::getPlantId, plantId)
                .eq(CareTask::getStatus, "COMPLETED")
        );
        
        BigDecimal taskRate = BigDecimal.ZERO;
        if (total > 0) {
            taskRate = new BigDecimal(completed)
                    .divide(new BigDecimal(total), 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal(100));
        }

        // 3. Calculate health score (30%)
        BigDecimal healthScore = new BigDecimal("100.00");
        Long abnormalityCount = abnormalityMapper.selectCount(new LambdaQueryWrapper<PlantAbnormality>()
                .eq(PlantAbnormality::getPlantId, plantId)
                .eq(PlantAbnormality::getStatus, "PENDING") // Currently sick
        );
        if (abnormalityCount > 0) {
            healthScore = healthScore.subtract(new BigDecimal(abnormalityCount).multiply(new BigDecimal("10")));
            if (healthScore.compareTo(BigDecimal.ZERO) < 0) healthScore = BigDecimal.ZERO;
        }

        // 4. Composite Score
        BigDecimal compositeScore = taskRate.add(healthScore)
                .divide(new BigDecimal("2"), 2, RoundingMode.HALF_UP);

        // 5. Update Achievement
        String currentCycle = parameterService.getValue("CURRENT_CYCLE", "2024-Cycle1");
        
        Achievement achievement = this.getOne(new LambdaQueryWrapper<Achievement>()
                .eq(Achievement::getUserId, userId)
                .eq(Achievement::getPlantId, plantId)
                .eq(Achievement::getAdoptionCycle, currentCycle));
        
        if (achievement == null) {
            achievement = new Achievement();
            achievement.setUserId(userId);
            achievement.setPlantId(plantId);
            achievement.setAdoptionCycle(currentCycle);
            achievement.setAdoptionStartDate(record.getStartDate());
        }

        achievement.setTotalTasks(total.intValue());
        achievement.setCompletedTasks(completed.intValue());
        achievement.setTaskCompletionRate(taskRate);
        achievement.setPlantHealthScore(healthScore);
        achievement.setCompositeScore(compositeScore);
        
        // Check outstanding
        int thresholdVal = parameterService.getInt("ACHIEVEMENT_SCORE_THRESHOLD", 90);
        if (compositeScore.compareTo(new BigDecimal(thresholdVal)) >= 0) {
            achievement.setIsOutstanding(2); // 2: 待人工审核 (Pending Manual Audit)
            achievement.setCertificateUrl(null); // 审核通过前不生成证书
        } else {
            achievement.setIsOutstanding(0);
            achievement.setCertificateUrl(null);
        }
        
        User user = userMapper.selectById(userId);
        if (user != null) {
            achievement.setUserRealName(user.getRealName());
            achievement.setStudentId(user.getStudentId());
        }

        this.saveOrUpdate(achievement);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void generateCycleReport(String adoptionCycle) {
        // 1. Get all users
        List<User> users = userMapper.selectList(null);
        
        for (User user : users) {
            // 2. Count total tasks (COMPLETED + OVERDUE)
            Long total = taskMapper.selectCount(new LambdaQueryWrapper<CareTask>()
                    .eq(CareTask::getUserId, user.getId())
                    .in(CareTask::getStatus, "COMPLETED", "OVERDUE")
            );
            
            // 3. Count completed tasks
            Long completed = taskMapper.selectCount(new LambdaQueryWrapper<CareTask>()
                    .eq(CareTask::getUserId, user.getId())
                    .eq(CareTask::getStatus, "COMPLETED")
            );
            
            // 4. Calculate rate
            BigDecimal taskRate = BigDecimal.ZERO;
            if (total > 0) {
                taskRate = new BigDecimal(completed)
                        .divide(new BigDecimal(total), 4, RoundingMode.HALF_UP)
                        .multiply(new BigDecimal(100));
            }

            // 5. Calculate adoption duration
            List<AdoptionRecord> records = adoptionRecordMapper.selectList(new LambdaQueryWrapper<AdoptionRecord>()
                    .eq(AdoptionRecord::getUserId, user.getId()));
            
            long durationDays = 0;
            for (AdoptionRecord record : records) {
                if (record.getStartDate() != null && record.getEndDate() != null) {
                    durationDays += ChronoUnit.DAYS.between(record.getStartDate(), record.getEndDate());
                }
            }

            // 6. Calculate health score (30%)
            // Basic logic: Start with 100, deduct for abnormalities
            BigDecimal healthScore = new BigDecimal("100.00");
            Long abnormalityCount = abnormalityMapper.selectCount(new LambdaQueryWrapper<PlantAbnormality>()
                    .inSql(PlantAbnormality::getPlantId, "SELECT plant_id FROM adoption_records WHERE user_id = " + user.getId())
                    .eq(PlantAbnormality::getStatus, "PENDING") // Currently sick
            );
            if (abnormalityCount > 0) {
                healthScore = healthScore.subtract(new BigDecimal(abnormalityCount).multiply(new BigDecimal("10")));
                if (healthScore.compareTo(BigDecimal.ZERO) < 0) healthScore = BigDecimal.ZERO;
            }

            // 7. Composite Score = (Task Completion Rate + Health Score) / 2
            // 综合评分 = (任务完成率 + 植物健康分) / 2
            BigDecimal compositeScore = taskRate.add(healthScore)
                    .divide(new BigDecimal("2"), 2, RoundingMode.HALF_UP);

            // 8. Check existence
            Achievement achievement = this.getOne(new LambdaQueryWrapper<Achievement>()
                    .eq(Achievement::getUserId, user.getId())
                    .eq(Achievement::getAdoptionCycle, adoptionCycle));
            
            if (achievement == null) {
                achievement = new Achievement();
                achievement.setUserId(user.getId());
                achievement.setAdoptionCycle(adoptionCycle);
            }

            // Try to find plant ID from records
            if (!records.isEmpty()) {
                achievement.setPlantId(records.get(0).getPlantId());
                achievement.setAdoptionStartDate(records.get(0).getStartDate());
            } else {
                continue;
            }
            
            achievement.setTotalTasks(total.intValue());
            achievement.setCompletedTasks(completed.intValue());
            achievement.setTaskCompletionRate(taskRate);
            achievement.setAdoptionDurationDays((int)durationDays);
            achievement.setPlantHealthScore(healthScore);
            achievement.setCompositeScore(compositeScore);
            
            // Outstanding Candidates: Composite Score >= 90
            // 优秀养护人：综合评分 >= 90
            int thresholdVal = parameterService.getInt("ACHIEVEMENT_SCORE_THRESHOLD", 90);
            BigDecimal threshold = new BigDecimal(thresholdVal);
            
            if (compositeScore.compareTo(threshold) >= 0) {
                achievement.setIsOutstanding(2); // 2: 待人工审核
                achievement.setCertificateUrl(null);
            } else {
                achievement.setIsOutstanding(0);
                achievement.setCertificateUrl(null);
            }
            
            // Set user name and student ID for display
            achievement.setUserRealName(user.getRealName());
            achievement.setStudentId(user.getStudentId());

            this.saveOrUpdate(achievement);
        }

        // Finalize Outstanding: If multiple 100% candidates, they are already marked. 
        // Requirements say "sort by duration to select outstanding". 
        // We could limit the number of outstanding users here.
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void auditAchievement(Long id, boolean isPass) {
        Achievement achievement = this.getById(id);
        if (achievement == null) {
            throw new RuntimeException("成果记录不存在");
        }
        
        // 只有在待人工审核状态下才能审核
        if (achievement.getIsOutstanding() != null && achievement.getIsOutstanding() == 2) {
            if (isPass) {
                achievement.setIsOutstanding(1); // 1: 优秀
                achievement.setCertificateUrl("/api/achievement/certificate/" + achievement.getUserId() + "/" + achievement.getAdoptionCycle());
            } else {
                achievement.setIsOutstanding(0); // 0: 不符合
            }
            this.updateById(achievement);
        }
    }
    @Override
    public Achievement getMyAchievement(String adoptionCycle, Long userId) {
        return this.getOne(new LambdaQueryWrapper<Achievement>()
                .eq(Achievement::getUserId, userId)
                .eq(Achievement::getAdoptionCycle, adoptionCycle));
    }

    @Override
    public Map<String, Object> getStats(String adoptionCycle) {
        List<Achievement> list = this.list(new LambdaQueryWrapper<Achievement>().eq(Achievement::getAdoptionCycle, adoptionCycle));
        
        int excellent = 0; // 90-100
        int good = 0;      // 80-89
        int pass = 0;      // 60-79
        int fail = 0;      // 0-59
        
        BigDecimal totalScore = BigDecimal.ZERO;
        
        for (Achievement a : list) {
            BigDecimal score = a.getCompositeScore();
            if (score != null) {
                totalScore = totalScore.add(score);
                double val = score.doubleValue();
                if (val >= 90) excellent++;
                else if (val >= 80) good++;
                else if (val >= 60) pass++;
                else fail++;
            }
            
            // Populate user name and student ID
            User u = userMapper.selectById(a.getUserId());
            if (u != null) {
                a.setUserRealName(u.getRealName()); // 使用真实姓名
                a.setStudentId(u.getStudentId()); // 填充学号
            }
        }
        
        Map<String, Object> map = new java.util.HashMap<>();
        map.put("totalUsers", list.size());
        map.put("averageScore", list.isEmpty() ? 0 : totalScore.divide(new BigDecimal(list.size()), 2, RoundingMode.HALF_UP));
        
        Map<String, Integer> distribution = new java.util.LinkedHashMap<>();
        distribution.put("优秀 (90-100)", excellent);
        distribution.put("良好 (80-89)", good);
        distribution.put("及格 (60-79)", pass);
        distribution.put("不及格 (<60)", fail);
        map.put("scoreDistribution", distribution);
        
        // Top 5
        List<Achievement> top5 = list.stream()
            .sorted((a, b) -> {
                BigDecimal s1 = a.getCompositeScore() == null ? BigDecimal.ZERO : a.getCompositeScore();
                BigDecimal s2 = b.getCompositeScore() == null ? BigDecimal.ZERO : b.getCompositeScore();
                return s2.compareTo(s1);
            })
            .limit(5)
            .collect(Collectors.toList());
        map.put("top5", top5);
        
        return map;
    }

    @Override
    public byte[] generateCertificate(Long userId, String adoptionCycle) {
        Achievement achievement = this.getOne(new LambdaQueryWrapper<Achievement>()
                .eq(Achievement::getUserId, userId)
                .eq(Achievement::getAdoptionCycle, adoptionCycle));
                
        if (achievement == null || achievement.getIsOutstanding() != 1) {
            throw new RuntimeException("该用户不符合荣誉证书领取资格");
        }
        
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        try {
            int width = 1200;
            int height = 850;
            java.awt.image.BufferedImage image = new java.awt.image.BufferedImage(width, height, java.awt.image.BufferedImage.TYPE_INT_RGB);
            java.awt.Graphics2D g2d = image.createGraphics();
            g2d.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON);
            g2d.setRenderingHint(java.awt.RenderingHints.KEY_TEXT_ANTIALIASING, java.awt.RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
            g2d.setRenderingHint(java.awt.RenderingHints.KEY_RENDERING, java.awt.RenderingHints.VALUE_RENDER_QUALITY);

            java.awt.GradientPaint bg = new java.awt.GradientPaint(
                    0, 0, new java.awt.Color(253, 251, 244),
                    0, height, new java.awt.Color(244, 249, 255)
            );
            g2d.setPaint(bg);
            g2d.fillRect(0, 0, width, height);

            g2d.setColor(new java.awt.Color(212, 175, 55));
            g2d.setStroke(new java.awt.BasicStroke(12));
            g2d.drawRoundRect(40, 40, width - 80, height - 80, 28, 28);
            g2d.setColor(new java.awt.Color(240, 215, 130));
            g2d.setStroke(new java.awt.BasicStroke(2));
            g2d.drawRoundRect(65, 65, width - 130, height - 130, 22, 22);

            g2d.setColor(new java.awt.Color(0, 0, 0, 25));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 72));
            String watermark = "SCHOOL PLANT";
            java.awt.FontMetrics wmFm = g2d.getFontMetrics();
            int wmX = (width - wmFm.stringWidth(watermark)) / 2;
            java.awt.geom.AffineTransform old = g2d.getTransform();
            java.awt.geom.AffineTransform at = new java.awt.geom.AffineTransform();
            at.rotate(Math.toRadians(-18), width / 2.0, height / 2.0);
            g2d.setTransform(at);
            g2d.drawString(watermark, wmX, height / 2);
            g2d.setTransform(old);

            String realName = user.getRealName();
            if (realName == null || realName.trim().isEmpty()) {
                realName = user.getUsername();
            }
            String certificateNo = "SP-" + adoptionCycle.replaceAll("[^A-Za-z0-9]", "") + "-" + userId;
            String issueDate = LocalDate.now().toString();
            String scoreText = achievement.getCompositeScore() == null
                    ? "综合评分：-"
                    : "综合评分：" + achievement.getCompositeScore().setScale(0, RoundingMode.HALF_UP) + " 分";

            g2d.setColor(new java.awt.Color(60, 60, 60));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 20));
            g2d.drawString("证书编号：" + certificateNo, 90, 120);
            g2d.drawString("认养周期：" + adoptionCycle, 90, 150);

            g2d.setColor(new java.awt.Color(33, 53, 82));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 64));
            String title = "荣誉证书";
            java.awt.FontMetrics titleFm = g2d.getFontMetrics();
            int titleX = (width - titleFm.stringWidth(title)) / 2;
            g2d.drawString(title, titleX, 220);

            g2d.setColor(new java.awt.Color(212, 175, 55));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 34));
            String subtitle = "优秀养护人";
            java.awt.FontMetrics subFm = g2d.getFontMetrics();
            int subX = (width - subFm.stringWidth(subtitle)) / 2;
            g2d.drawString(subtitle, subX, 280);

            g2d.setColor(new java.awt.Color(70, 70, 70));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 28));
            String line1 = "兹授予";
            java.awt.FontMetrics line1Fm = g2d.getFontMetrics();
            int line1X = (width - line1Fm.stringWidth(line1)) / 2;
            g2d.drawString(line1, line1X, 380);

            g2d.setColor(new java.awt.Color(20, 20, 20));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 56));
            java.awt.FontMetrics nameFm = g2d.getFontMetrics();
            int nameX = (width - nameFm.stringWidth(realName)) / 2;
            g2d.drawString(realName, nameX, 455);

            g2d.setColor(new java.awt.Color(70, 70, 70));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 26));
            String line2 = "在校园植物认养项目中表现优异，特颁发此证。";
            java.awt.FontMetrics line2Fm = g2d.getFontMetrics();
            int line2X = (width - line2Fm.stringWidth(line2)) / 2;
            g2d.drawString(line2, line2X, 535);

            g2d.setColor(new java.awt.Color(60, 60, 60));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 24));
            java.awt.FontMetrics scoreFm = g2d.getFontMetrics();
            int scoreX = (width - scoreFm.stringWidth(scoreText)) / 2;
            g2d.drawString(scoreText, scoreX, 585);

            int sealCx = width - 230;
            int sealCy = height - 210;
            g2d.setColor(new java.awt.Color(200, 40, 40, 200));
            g2d.setStroke(new java.awt.BasicStroke(6));
            g2d.drawOval(sealCx - 90, sealCy - 90, 180, 180);
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 26));
            String sealText = "认证";
            java.awt.FontMetrics sealFm = g2d.getFontMetrics();
            g2d.drawString(sealText, sealCx - sealFm.stringWidth(sealText) / 2, sealCy + 10);

            g2d.setColor(new java.awt.Color(60, 60, 60));
            g2d.setFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 22));
            String org = "校园植物认养系统";
            java.awt.FontMetrics orgFm = g2d.getFontMetrics();
            int orgX = width - 90 - orgFm.stringWidth(org);
            g2d.drawString(org, orgX, height - 170);
            String date = "颁发日期：" + issueDate;
            java.awt.FontMetrics dateFm = g2d.getFontMetrics();
            int dateX = width - 90 - dateFm.stringWidth(date);
            g2d.drawString(date, dateX, height - 135);

            g2d.dispose();
            
            java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
            javax.imageio.ImageIO.write(image, "png", baos);
            return baos.toByteArray();
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("荣誉证书生成失败");
        }
    }
}
