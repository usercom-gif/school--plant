package com.schoolplant.service.impl;

import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.entity.AbnormalityProcessLog;
import com.schoolplant.entity.PlantAbnormality;
import com.schoolplant.mapper.AbnormalityProcessLogMapper;
import com.schoolplant.mapper.PlantAbnormalityMapper;
import com.schoolplant.service.DifyService;
import com.schoolplant.service.CosStorageService;
import com.schoolplant.service.PlantAbnormalityService;
import com.schoolplant.service.PlantImageAnalysisService;
import com.schoolplant.service.SystemParameterService;
import com.schoolplant.websocket.AbnormalityWebSocket;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.schoolplant.service.PlantService;
import com.schoolplant.service.CareTaskService;
import com.schoolplant.entity.CareTask;
import com.schoolplant.service.UserService;
import com.schoolplant.entity.User;
import com.schoolplant.entity.Plant;
import com.schoolplant.util.PlantAiTextTemplate;

@Service
public class PlantAbnormalityServiceImpl extends ServiceImpl<PlantAbnormalityMapper, PlantAbnormality> implements PlantAbnormalityService {

    @Autowired
    private PlantService plantService;

    @Autowired
    private CareTaskService careTaskService;

    @Autowired
    private UserService userService;

    @Autowired
    private DifyService difyService;

    @Autowired
    private PlantImageAnalysisService plantImageAnalysisService;

    @Autowired
    private AbnormalityProcessLogMapper processLogMapper;
    
    @Autowired
    private SystemParameterService parameterService;

    @Value("${file.upload-path:./uploads}")
    private String uploadPath;

    @Value("${school-plant.storage:local}")
    private String storage;

    @Autowired(required = false)
    private CosStorageService cosStorageService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String reportAbnormality(Long plantId, Long reporterId, String type, String desc, String reporterName, String reporterContact, String location, MultipartFile[] images) {
        List<String> imageUrls = new ArrayList<>();
        File firstImageFile = null;

        try {
            for (int i = 0; i < images.length; i++) {
                MultipartFile img = images[i];
                if (img == null || img.isEmpty()) continue;

                String originalFilename = img.getOriginalFilename();
                String safeName = originalFilename == null ? "image" : originalFilename.replaceAll("\\s+", "_");
                String key = "abnormality/report/" + plantId + "/" + UUID.randomUUID() + "_" + safeName;

                if ("cos".equalsIgnoreCase(storage)) {
                    if (cosStorageService == null) {
                        throw new RuntimeException("COS 未启用或未配置密钥：请设置 tencent.cos.enabled=true，并配置环境变量 TENCENT_COS_SECRET_ID 与 TENCENT_COS_SECRET_KEY");
                    }
                    String url = cosStorageService.upload(img, key);
                    imageUrls.add(url);
                } else {
                    String absoluteUploadPath;
                    if (uploadPath.startsWith("./") || uploadPath.startsWith("../")) {
                        absoluteUploadPath = new File(System.getProperty("user.dir"), uploadPath).getAbsolutePath();
                    } else {
                        absoluteUploadPath = uploadPath;
                    }

                    File uploadDir = new File(absoluteUploadPath);
                    if (!uploadDir.exists()) {
                        boolean created = uploadDir.mkdirs();
                        if (!created && !uploadDir.exists()) {
                            throw new RuntimeException("无法创建目录：" + uploadDir.getAbsolutePath());
                        }
                    }

                    String fileName = UUID.randomUUID() + "_" + safeName;
                    File dest = new File(absoluteUploadPath, fileName);
                    img.transferTo(dest.getAbsoluteFile());
                    imageUrls.add("/uploads/" + fileName);
                }

                if (i == 0) {
                    Path temp = Files.createTempFile("abnormality-first-", ".tmp");
                    img.transferTo(temp.toFile());
                    firstImageFile = temp.toFile();
                }
            }
        } catch (IOException e) {
            throw new RuntimeException("图片上传失败：" + e.getMessage(), e);
        }

        Plant plant = plantId != null ? plantService.getById(plantId) : null;
        if (plantId != null && plant == null) {
             throw new RuntimeException("植物不存在");
        }

        // 2. Call AI Analysis
        String aiSuggestion = "暂无AI建议";
        if (firstImageFile != null) {
            var analysis = plantImageAnalysisService.analyze(firstImageFile, desc);

            String templateText = PlantAiTextTemplate.buildAbnormalityDecisionText(
                    plant != null ? plant.getSpecies() : "任意植物",
                    type,
                    desc != null ? desc : "未提供描述",
                    analysis
            );

            aiSuggestion = templateText;

            String difySuggestion = difyService.analyzeImage(null, firstImageFile, desc);
            if (difySuggestion != null) {
                String trimmed = difySuggestion.trim();
                if (!trimmed.isEmpty()
                        && !trimmed.contains("暂时不可用")
                        && !trimmed.startsWith("AI分析失败")
                        && trimmed.contains("判定结果如下")
                        && trimmed.contains("判定依据说明")) {
                    aiSuggestion = trimmed;
                }
            }
        }

        // 3. Save DB
        PlantAbnormality record = new PlantAbnormality();
        record.setPlantId(plantId);
        if (plant != null) {
            record.setPlantName(plant.getName());
            
            // 只有未填写位置信息（说明是上报的自己认养的植物）时，才更新该植物为生病状态
            // 若填写了位置信息（说明是上报的校园任意植物），则不改变植物全局的健康状态，交由养护员处理时评估
            if (!StringUtils.hasText(location)) {
                plant.setHealthStatus("SICK");
                plantService.updateById(plant);
            }
        }
        
        record.setLocation(location);
        record.setReporterId(reporterId);
        record.setAbnormalityType(type);
        record.setDescription(desc);
        record.setReporterName(reporterName);
        record.setReporterContact(reporterContact);
        record.setImageUrls(JSON.toJSONString(imageUrls));
        record.setSuggestedSolution(aiSuggestion);
        record.setStatus("PENDING"); // 待分派
        record.setCreatedAt(LocalDateTime.now());
        save(record);

        // 4. Log
        logProcess(record.getId(), reporterId, "USER", "REPORT", "用户上报异常");

        // Notify Admins
        List<User> admins = userService.getUsersByRole("ADMIN");
        for (User admin : admins) {
            AbnormalityWebSocket.sendMessage(admin.getId(), "NEW_ABNORMALITY:" + record.getId());
        }

        return aiSuggestion;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String reportAbnormalityFromTask(Long taskId, Long reporterId, String type, String desc, String reporterName, String reporterContact, MultipartFile[] images) {
        CareTask task = careTaskService.getById(taskId);
        if (task == null) {
            throw new RuntimeException("任务不存在");
        }
        
        String aiDiagnosis = reportAbnormality(task.getPlantId(), reporterId, type, desc, reporterName, reporterContact, null, images);
        
        // Link the latest abnormality to the task (assuming it's the one just created)
        PlantAbnormality latestAbnormality = this.getOne(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<PlantAbnormality>()
                .eq(PlantAbnormality::getReporterId, reporterId)
                .eq(PlantAbnormality::getPlantId, task.getPlantId())
                .orderByDesc(PlantAbnormality::getCreatedAt)
                .last("LIMIT 1"));
                
        if (latestAbnormality != null) {
            latestAbnormality.setCareTaskId(taskId);
            this.updateById(latestAbnormality);
            
            task.setAbnormalityId(latestAbnormality.getId());
            careTaskService.updateById(task);
        }
        
        return aiDiagnosis;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void assignMaintainer(Long abnormalityId, Long maintainerId, Long operatorId) {
        PlantAbnormality record = getById(abnormalityId);
        if (record == null) throw new RuntimeException("工单不存在");

        record.setMaintainerId(maintainerId);
        record.setStatus("ASSIGNED"); // 已分派
        record.setAssignedAt(LocalDateTime.now());
        record.setUpdatedAt(LocalDateTime.now());
        updateById(record);

        // Log
        logProcess(abnormalityId, operatorId, "ADMIN", "ASSIGN", "分派给养护员ID: " + maintainerId);

        // WebSocket Push to Maintainer
        AbnormalityWebSocket.sendMessage(maintainerId, "您有新的异常工单待处理，ID: " + abnormalityId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void resolveAbnormality(Long abnormalityId, String resolution, String materials, String evaluation, MultipartFile[] images) {
        PlantAbnormality record = getById(abnormalityId);
        if (record == null) throw new RuntimeException("工单不存在");

        // Save Result Images
        List<String> resultUrls = new ArrayList<>();
        if (images != null) {
            try {
                for (MultipartFile img : images) {
                    if (img == null || img.isEmpty()) continue;

                    String originalFilename = img.getOriginalFilename();
                    String safeName = originalFilename == null ? "image" : originalFilename.replaceAll("\\s+", "_");
                    String key = "abnormality/resolve/" + abnormalityId + "/" + UUID.randomUUID() + "_" + safeName;

                    if ("cos".equalsIgnoreCase(storage)) {
                        if (cosStorageService == null) {
                            throw new RuntimeException("COS 未启用或未配置密钥：请设置 tencent.cos.enabled=true，并配置环境变量 TENCENT_COS_SECRET_ID 与 TENCENT_COS_SECRET_KEY");
                        }
                        String url = cosStorageService.upload(img, key);
                        resultUrls.add(url);
                    } else {
                        String fileName = UUID.randomUUID() + "_res_" + safeName;
                        File dest = new File(uploadPath, fileName);
                        img.transferTo(dest);
                        resultUrls.add("/uploads/" + fileName);
                    }
                }
            } catch (IOException e) {
                throw new RuntimeException("图片上传失败", e);
            }
        }

        record.setResolutionDescription(resolution);
        record.setMaterialsUsed(materials);
        record.setEffectEvaluation(evaluation);
        record.setResolutionImageUrls(JSON.toJSONString(resultUrls));
        record.setStatus("RESOLVED"); // 已处理
        record.setResolvedAt(LocalDateTime.now());
        record.setUpdatedAt(LocalDateTime.now());
        updateById(record);

        // 更新植物健康状态为健康
        Plant plant = plantService.getById(record.getPlantId());
        if (plant != null) {
            plant.setHealthStatus("HEALTHY");
            plantService.updateById(plant);
        }

        // Log
        logProcess(abnormalityId, record.getMaintainerId(), "MAINTAINER", "RESOLVE", "养护员完成处理");
        
        // WebSocket Push to Reporter
        AbnormalityWebSocket.sendMessage(record.getReporterId(), "您上报的异常工单已处理，ID: " + abnormalityId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markUnresolved(Long abnormalityId, String reason, String materials, String evaluation, MultipartFile[] images) {
        PlantAbnormality record = getById(abnormalityId);
        if (record == null) throw new RuntimeException("工单不存在");

        List<String> resultUrls = new ArrayList<>();
        if (images != null) {
            try {
                for (MultipartFile img : images) {
                    if (img == null || img.isEmpty()) continue;

                    String originalFilename = img.getOriginalFilename();
                    String safeName = originalFilename == null ? "image" : originalFilename.replaceAll("\\s+", "_");
                    String key = "abnormality/unresolved/" + abnormalityId + "/" + UUID.randomUUID() + "_" + safeName;

                    if ("cos".equalsIgnoreCase(storage)) {
                        if (cosStorageService == null) {
                            throw new RuntimeException("COS 未启用或未配置密钥：请设置 tencent.cos.enabled=true，并配置环境变量 TENCENT_COS_SECRET_ID 与 TENCENT_COS_SECRET_KEY");
                        }
                        String url = cosStorageService.upload(img, key);
                        resultUrls.add(url);
                    } else {
                        String fileName = UUID.randomUUID() + "_unresolved_" + safeName;
                        File dest = new File(uploadPath, fileName);
                        img.transferTo(dest);
                        resultUrls.add("/uploads/" + fileName);
                    }
                }
            } catch (IOException e) {
                throw new RuntimeException("图片上传失败", e);
            }
        }

        record.setResolutionDescription(reason);
        record.setMaterialsUsed(materials);
        record.setEffectEvaluation(evaluation);
        record.setResolutionImageUrls(JSON.toJSONString(resultUrls));
        record.setStatus("UNRESOLVED");
        record.setResolvedAt(LocalDateTime.now());
        record.setUpdatedAt(LocalDateTime.now());
        record.setOvertimeAlertSent(1);
        updateById(record);

        logProcess(abnormalityId, record.getMaintainerId(), "MAINTAINER", "UNRESOLVED", "养护员标记处理失败");
        AbnormalityWebSocket.sendMessage(record.getReporterId(), "您上报的异常工单处理失败，已标记为未解决，ID: " + abnormalityId);

        // Notify Admins
        List<User> admins = userService.getUsersByRole("ADMIN");
        for (User admin : admins) {
            AbnormalityWebSocket.sendMessage(admin.getId(), "ABNORMALITY_FAILED_ESCALATION:" + abnormalityId);
        }
    }

    @Override
    public int countResolvedByMaintainer(Long maintainerId) {
        return (int) this.count(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<PlantAbnormality>()
                .eq(PlantAbnormality::getMaintainerId, maintainerId)
                .eq(PlantAbnormality::getStatus, "RESOLVED"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void checkOverdueAbnormalities() {
        int timeoutHours = parameterService.getInt("ABNORMALITY_TIMEOUT_HOURS", 48);
        LocalDateTime deadline = LocalDateTime.now().minusHours(timeoutHours);
        
        List<PlantAbnormality> overdueList = this.list(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<PlantAbnormality>()
                .eq(PlantAbnormality::getStatus, "ASSIGNED")
                .le(PlantAbnormality::getAssignedAt, deadline)
                .eq(PlantAbnormality::getOvertimeAlertSent, 0));

        for (PlantAbnormality record : overdueList) {
            // Trigger Admin Alert (Log or WebSocket to specific admin channel if exists)
            // Here we simply log and maybe notify the maintainer again
            System.err.println("【逾期提醒】异常工单ID: " + record.getId() + " 已超过" + timeoutHours + "小时未处理！养护员ID: " + record.getMaintainerId());
            
            // Notify Maintainer again
            AbnormalityWebSocket.sendMessage(record.getMaintainerId(), "【紧急】您的工单ID: " + record.getId() + " 已逾期" + timeoutHours + "小时，请尽快处理！");

            // Mark as alerted
            record.setOvertimeAlertSent(1);
            updateById(record);
        }
    }

    private void logProcess(Long abnormalityId, Long operatorId, String operatorName, String action, String comment) {
        AbnormalityProcessLog log = new AbnormalityProcessLog();
        log.setAbnormalityId(abnormalityId);
        log.setOperatorId(operatorId);
        log.setOperatorName(operatorName); // Should fetch real name
        log.setAction(action);
        log.setComment(comment);
        log.setCreatedAt(LocalDateTime.now());
        processLogMapper.insert(log);
    }
}
