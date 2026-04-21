package com.schoolplant.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.dto.AdoptionApplyRequest;
import com.schoolplant.dto.AdoptionQueryRequest;
import com.schoolplant.dto.AdoptionStatusResponse;
import com.schoolplant.dto.AuditApplicationRequest;
import com.schoolplant.entity.AdoptionApplication;
import com.schoolplant.entity.AdoptionAuditLog;
import com.schoolplant.entity.AdoptionRecord;
import com.schoolplant.entity.Plant;
import com.schoolplant.entity.User;
import com.schoolplant.mapper.AdoptionApplicationMapper;
import com.schoolplant.mapper.AdoptionAuditLogMapper;
import com.schoolplant.mapper.AdoptionRecordMapper;
import com.schoolplant.mapper.PlantMapper;
import com.schoolplant.mapper.UserMapper;
import com.schoolplant.service.AchievementService;
import com.schoolplant.service.AdoptionService;
import com.schoolplant.service.SystemNotificationService;
import com.schoolplant.service.SystemParameterService;
import com.schoolplant.vo.AdoptionApplicationVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;
import com.schoolplant.mapper.RoleMapper;
import com.schoolplant.mapper.UserRoleMapper;

@Service
public class AdoptionServiceImpl extends ServiceImpl<AdoptionRecordMapper, AdoptionRecord> implements AdoptionService {

    @Autowired
    private AdoptionApplicationMapper applicationMapper;
    
    @Autowired
    private AdoptionRecordMapper recordMapper; 
    
    @Autowired
    private UserRoleMapper userRoleMapper; 
    
    @Autowired
    private RoleMapper roleMapper; 

    @Autowired
    private PlantMapper plantMapper;
    
    @Autowired
    private UserMapper userMapper;

    @Autowired
    private AdoptionAuditLogMapper auditLogMapper;
    
    @Autowired
    private SystemParameterService parameterService;

    @Autowired
    private SystemNotificationService notificationService;

    @Autowired
    @Lazy
    private AchievementService achievementService;

    @Override
    public AdoptionStatusResponse checkStatus(Long userId) {
        AdoptionStatusResponse response = new AdoptionStatusResponse();
        
        // Check active adoption record
        LocalDate today = LocalDate.now();
        Long activeCount = recordMapper.selectCount(new LambdaQueryWrapper<AdoptionRecord>()
                .eq(AdoptionRecord::getUserId, userId)
                .eq(AdoptionRecord::getStatus, "ACTIVE")
                .and(w -> w.isNull(AdoptionRecord::getEndDate).or().ge(AdoptionRecord::getEndDate, today))
        );
        
        response.setHasActiveAdoption(activeCount > 0);
        
        if (activeCount > 0) {
            AdoptionRecord record = recordMapper.selectOne(new LambdaQueryWrapper<AdoptionRecord>()
                    .eq(AdoptionRecord::getUserId, userId)
                    .eq(AdoptionRecord::getStatus, "ACTIVE")
                    .and(w -> w.isNull(AdoptionRecord::getEndDate).or().ge(AdoptionRecord::getEndDate, today))
                    .last("LIMIT 1"));
            response.setPlantId(record.getPlantId());
            Plant plant = plantMapper.selectById(record.getPlantId());
            response.setPlantName(plant.getName());
        }
        
        // Check pending application
        Long pendingCount = applicationMapper.selectCount(new LambdaQueryWrapper<AdoptionApplication>()
                .eq(AdoptionApplication::getUserId, userId)
                .in(AdoptionApplication::getStatus, "PENDING", "INITIAL_AUDIT"));
        
        response.setHasPendingApplication(pendingCount > 0);
        
        return response;
    }

    @Override
    public Page<AdoptionApplicationVO> listInitialAudits(Long userId, AdoptionQueryRequest request) {
        Page<AdoptionApplication> pageParam = new Page<>(request.getPage(), request.getSize());
        
        // Custom SQL or Logic needed here. 
        // Find applications where plant.created_by = userId AND status = 'INITIAL_AUDIT'
        // Using wrapper with subquery or join is better. 
        // Since we use MP, maybe use apply with subquery.
        LambdaQueryWrapper<AdoptionApplication> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AdoptionApplication::getStatus, "INITIAL_AUDIT");
        wrapper.inSql(AdoptionApplication::getPlantId, "SELECT id FROM plants WHERE created_by = " + userId);
        wrapper.orderByDesc(AdoptionApplication::getCreatedAt);
        
        Page<AdoptionApplication> resultPage = applicationMapper.selectPage(pageParam, wrapper);
        
        // Convert to VO (Duplicate logic, extract later)
        List<AdoptionApplicationVO> vos = resultPage.getRecords().stream().map(app -> {
            AdoptionApplicationVO vo = new AdoptionApplicationVO();
            BeanUtils.copyProperties(app, vo);
            User user = userMapper.selectById(app.getUserId());
            if (user != null) vo.setUserName(user.getUsername());
            Plant plant = plantMapper.selectById(app.getPlantId());
            if (plant != null) vo.setPlantName(plant.getName());
            return vo;
        }).collect(Collectors.toList());
        
        Page<AdoptionApplicationVO> voPage = new Page<>();
        BeanUtils.copyProperties(resultPage, voPage);
        voPage.setRecords(vos);
        
        return voPage;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long submitApplication(Long userId, AdoptionApplyRequest request) {
        // 1. Check if user already has active adoption
        int limit = parameterService.getInt("ADOPTION_LIMIT", 1);

        LocalDate today = LocalDate.now();
        Long activeCount = recordMapper.selectCount(new LambdaQueryWrapper<AdoptionRecord>()
                .eq(AdoptionRecord::getUserId, userId)
                .eq(AdoptionRecord::getStatus, "ACTIVE")
                .and(w -> w.isNull(AdoptionRecord::getEndDate).or().ge(AdoptionRecord::getEndDate, today))
        );
        
        if (activeCount >= limit) {
            throw new RuntimeException("您已达到认养上限 (" + limit + " 株)");
        }
        
        // 2. Check if user has pending application
        Long pendingCount = applicationMapper.selectCount(new LambdaQueryWrapper<AdoptionApplication>()
                .eq(AdoptionApplication::getUserId, userId)
                .in(AdoptionApplication::getStatus, "PENDING", "INITIAL_AUDIT"));
        
        if (pendingCount > 0) {
            throw new RuntimeException("您有待审核的申请，请勿重复提交");
        }
        
        // 3. Check plant status
        Plant plant = plantMapper.selectById(request.getPlantId());
        if (plant == null || !"AVAILABLE".equals(plant.getStatus())) {
            throw new RuntimeException("该植物当前不可认养");
        }
        
        // 4. Create Application
        AdoptionApplication app = new AdoptionApplication();
        app.setUserId(userId);
        app.setPlantId(request.getPlantId());
        app.setAdoptionPeriodMonths(request.getAdoptionPeriodMonths());
        app.setReason(request.getReason() != null ? request.getReason() : "用户认养申请"); 
        app.setCareExperience(request.getCareExperience());
        app.setPlan(request.getPlan());
        app.setContactPhone(request.getContactPhone());
        
        // 5. Check if plant is published by Admin
        User publisher = userMapper.selectById(plant.getCreatedBy());
        if (publisher != null && "ADMIN".equals(roleMapper.selectById(userRoleMapper.selectOne(new LambdaQueryWrapper<com.schoolplant.entity.UserRole>().eq(com.schoolplant.entity.UserRole::getUserId, publisher.getId())).getRoleId()).getRoleKey())) {
             app.setStatus("PENDING"); // Admin published, go to Admin Audit directly
        } else if (publisher != null) {
             app.setStatus("INITIAL_AUDIT"); // Non-admin published, go to Publisher Audit first
        } else {
             app.setStatus("PENDING"); // Fallback
        }
        
        LocalDateTime now = LocalDateTime.now();
        app.setCreatedAt(now);
        app.setUpdatedAt(now);
        
        applicationMapper.insert(app);
        
        return app.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long applyAdoption(Long userId, Long plantId) {
        AdoptionApplyRequest request = new AdoptionApplyRequest();
        request.setPlantId(plantId);
        request.setReason("快速申请");
        int defaultMonths = parameterService.getInt("ADOPTION_PERIOD_MONTHS", 6);
        request.setAdoptionPeriodMonths(defaultMonths);
        User user = userMapper.selectById(userId);
        request.setContactPhone(user != null ? user.getPhone() : "13800000000");
        request.setCareExperience("快速申请：本人承诺按要求完成养护任务并遵守相关管理规范。");
        return submitApplication(userId, request);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateApplication(Long userId, AdoptionApplyRequest request) {
        if (request.getId() == null) {
            throw new RuntimeException("申请ID不能为空");
        }
        
        AdoptionApplication app = applicationMapper.selectById(request.getId());
        if (app == null) {
            throw new RuntimeException("申请不存在");
        }
        if (!app.getUserId().equals(userId)) {
            throw new RuntimeException("无权操作");
        }
        // Allow update in both INITIAL_AUDIT and PENDING
        if (!"PENDING".equals(app.getStatus()) && !"INITIAL_AUDIT".equals(app.getStatus())) {
            throw new RuntimeException("只能修改待审核的申请");
        }
        
        // Update fields
        app.setAdoptionPeriodMonths(request.getAdoptionPeriodMonths());
        app.setCareExperience(request.getCareExperience());
        app.setContactPhone(request.getContactPhone());
        // Reason is usually fixed or same as careExperience in simplified model, but update if provided
        if (request.getReason() != null) {
            app.setReason(request.getReason());
        }
        app.setUpdatedAt(LocalDateTime.now());
        
        applicationMapper.updateById(app);
    }

    @Override
    public long countPendingAudits() {
        return applicationMapper.selectCount(new LambdaQueryWrapper<AdoptionApplication>()
                .eq(AdoptionApplication::getStatus, "PENDING"));
    }

    @Override
    public Page<AdoptionApplication> listApplications(AdoptionQueryRequest request) {
        Page<AdoptionApplication> pageParam = new Page<>(request.getPage(), request.getSize());
        LambdaQueryWrapper<AdoptionApplication> wrapper = new LambdaQueryWrapper<>();
        
        if (request.getUserId() != null) {
            wrapper.eq(AdoptionApplication::getUserId, request.getUserId());
        }
        if (request.getStatus() != null) {
            wrapper.eq(AdoptionApplication::getStatus, request.getStatus());
        }
        
        wrapper.orderByDesc(AdoptionApplication::getCreatedAt);
        
        return applicationMapper.selectPage(pageParam, wrapper);
    }

    @Override
    public Page<AdoptionApplicationVO> listApplicationVOs(AdoptionQueryRequest request) {
        Page<AdoptionApplication> pageParam = new Page<>(request.getPage(), request.getSize());
        LambdaQueryWrapper<AdoptionApplication> wrapper = new LambdaQueryWrapper<>();
        
        if (request.getUserId() != null) {
            wrapper.eq(AdoptionApplication::getUserId, request.getUserId());
        }
        if (request.getStatus() != null) {
            wrapper.eq(AdoptionApplication::getStatus, request.getStatus());
        }
        
        wrapper.orderByDesc(AdoptionApplication::getCreatedAt);
        
        Page<AdoptionApplication> resultPage = applicationMapper.selectPage(pageParam, wrapper);
        
        List<AdoptionApplicationVO> vos = resultPage.getRecords().stream().map(app -> {
            AdoptionApplicationVO vo = new AdoptionApplicationVO();
            BeanUtils.copyProperties(app, vo);
            
            // Fill names
            User user = userMapper.selectById(app.getUserId());
            if (user != null) vo.setUserName(user.getUsername()); // or realName
            
            Plant plant = plantMapper.selectById(app.getPlantId());
            if (plant != null) vo.setPlantName(plant.getName());
            
            return vo;
        }).collect(Collectors.toList());
        
        Page<AdoptionApplicationVO> voPage = new Page<>();
        BeanUtils.copyProperties(resultPage, voPage);
        voPage.setRecords(vos);
        
        return voPage;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void auditApplication(Long auditorId, AuditApplicationRequest request) {
        AdoptionApplication app = applicationMapper.selectById(request.getId());
        if (app == null) {
            throw new RuntimeException("申请不存在");
        }
        
        User auditor = userMapper.selectById(auditorId);
        String auditorName = auditor != null ? auditor.getUsername() : "Unknown";
        
        // Logic for Initial Audit (Publisher)
        if ("INITIAL_AUDIT".equals(app.getStatus())) {
             // Verify auditor is the publisher
             Plant plant = plantMapper.selectById(app.getPlantId());
             if (plant != null && !plant.getCreatedBy().equals(auditorId) && !"ADMIN".equals(roleMapper.selectById(userRoleMapper.selectOne(new LambdaQueryWrapper<com.schoolplant.entity.UserRole>().eq(com.schoolplant.entity.UserRole::getUserId, auditorId)).getRoleId()).getRoleKey())) {
                 throw new RuntimeException("非发布者无权初审");
             }
             
             if ("PASS".equalsIgnoreCase(request.getAction())) {
                 app.setStatus("PENDING"); // Passed initial, go to Admin Pending
                 saveAuditLog(app.getId(), auditorId, auditorName, "INITIAL", "PASS", request.getComment());
                 
                 // Notify Applicant
                 notificationService.sendNotification(app.getUserId(), "认养申请初审通过", 
                         "您的认养申请已通过发布者初审，正在等待管理员复审。", "AUDIT");
                 
             } else {
                 app.setStatus("REJECTED"); // Rejected by publisher
                 if (request.getComment() != null && !request.getComment().trim().isEmpty()) {
                    app.setRejectionReason(request.getComment());
                 } else {
                    app.setRejectionReason("发布者初审未通过");
                 }
                 saveAuditLog(app.getId(), auditorId, auditorName, "INITIAL", "REJECT", request.getComment());
                 
                 // Notify Applicant
                 notificationService.sendNotification(app.getUserId(), "认养申请未通过", 
                         "您的认养申请未通过发布者初审。原因：" + app.getRejectionReason(), "AUDIT");
             }
             
             app.setUpdatedAt(LocalDateTime.now());
             applicationMapper.updateById(app);
             return;
        }

        if (!"PENDING".equals(app.getStatus())) {
            throw new RuntimeException("申请状态已变更");
        }
        
        // Admin Audit Logic (Existing)
        if ("PASS".equalsIgnoreCase(request.getAction())) {
            // Approved
            app.setStatus("APPROVED");
            app.setApprovedBy(auditorId);
            app.setApprovedAt(LocalDateTime.now());
            
            // Create Record
            AdoptionRecord record = new AdoptionRecord();
            record.setUserId(app.getUserId());
            record.setPlantId(app.getPlantId());
            LocalDate startDate = LocalDate.now();
            record.setStartDate(startDate);
            record.setEndDate(calculatePlannedEndDate(startDate, app.getAdoptionPeriodMonths()));
            record.setStatus("ACTIVE");
            recordMapper.insert(record);
            
            // Update Plant Status
            Plant plant = plantMapper.selectById(app.getPlantId());
            if (plant != null) {
                plant.setStatus("ADOPTED");
                plantMapper.updateById(plant);
            }
            
            // Log - No reason needed for approval usually, but we can log comment if provided
            saveAuditLog(app.getId(), auditorId, auditorName, "REVIEW", "PASS", request.getComment());
            
            // Notify Applicant
            String plantName = "未知植物";
            if (plant != null) plantName = plant.getName();
            notificationService.sendNotification(app.getUserId(), "认养申请审核通过", 
                    "恭喜！您申请认养的植物 [" + plantName + "] 已审核通过，请前往“我的认养”查看。", "AUDIT");
            
        } else {
            // Rejected
            app.setStatus("REJECTED");
            // Save rejection reason to application record
            if (request.getComment() != null && !request.getComment().trim().isEmpty()) {
                app.setRejectionReason(request.getComment());
            } else {
                 app.setRejectionReason("审核未通过"); // Default reason
            }
            
            // Log
            saveAuditLog(app.getId(), auditorId, auditorName, "REVIEW", "REJECT", request.getComment());
            
            // Notify Applicant
            Plant plant = plantMapper.selectById(app.getPlantId());
            String plantName = (plant != null) ? plant.getName() : "未知植物";
            notificationService.sendNotification(app.getUserId(), "认养申请未通过", 
                    "很遗憾，您申请认养的植物 [" + plantName + "] 未通过审核。原因：" + app.getRejectionReason(), "AUDIT");
        }
        
        app.setUpdatedAt(LocalDateTime.now());
        applicationMapper.updateById(app);
    }

    private LocalDate calculatePlannedEndDate(LocalDate startDate, Integer adoptionPeriodMonths) {
        int months;
        if (adoptionPeriodMonths != null && adoptionPeriodMonths > 0) {
            months = adoptionPeriodMonths;
        } else {
            months = parameterService.getInt("ADOPTION_PERIOD_MONTHS", 6);
        }

        LocalDate endExclusive = startDate.plus(months, ChronoUnit.MONTHS);
        return endExclusive.minusDays(1);
    }

    @Override
    public List<AdoptionAuditLog> listAuditLogs(Long applicationId) {
        return auditLogMapper.selectList(new LambdaQueryWrapper<AdoptionAuditLog>()
                .eq(AdoptionAuditLog::getApplicationId, applicationId)
                .orderByDesc(AdoptionAuditLog::getCreatedAt));
    }

    private void saveAuditLog(Long applicationId, Long auditorId, String auditorName, String stage, String action, String comment) {
        AdoptionAuditLog log = new AdoptionAuditLog();
        log.setApplicationId(applicationId);
        log.setAuditorId(auditorId);
        log.setAuditorName(auditorName);
        log.setAuditStage(stage);
        log.setAuditAction(action);
        log.setComment(comment);
        log.setCreatedAt(LocalDateTime.now());
        auditLogMapper.insert(log);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelApplication(Long userId, Long applicationId) {
        AdoptionApplication app = applicationMapper.selectById(applicationId);
        if (app == null) {
            throw new RuntimeException("申请不存在");
        }
        if (!app.getUserId().equals(userId)) {
            throw new RuntimeException("无权操作");
        }
        // Allow cancel in both INITIAL_AUDIT and PENDING
        if (!"PENDING".equals(app.getStatus()) && !"INITIAL_AUDIT".equals(app.getStatus())) {
            throw new RuntimeException("只能撤销待审核的申请");
        }
        
        app.setStatus("CANCELLED");
        app.setUpdatedAt(LocalDateTime.now());
        applicationMapper.updateById(app);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelAdoption(Long recordId, String reason) {
        AdoptionRecord record = recordMapper.selectById(recordId);
        if (record == null) {
            throw new RuntimeException("记录不存在");
        }
        
        record.setEndDate(LocalDate.now());
        record.setStatus("CANCELLED");
        recordMapper.updateById(record);
        
        Plant plant = plantMapper.selectById(record.getPlantId());
        if (plant != null) {
            plant.setStatus("AVAILABLE");
            plantMapper.updateById(plant);
        }
    }

    @Override
    public Page<AdoptionRecord> pageMyAdoptions(int page, int size, Long userId) {
        Page<AdoptionRecord> pageParam = new Page<>(page, size);
        Page<AdoptionRecord> resultPage = recordMapper.selectPage(pageParam, 
                new LambdaQueryWrapper<AdoptionRecord>()
                        .eq(AdoptionRecord::getUserId, userId)
                        .orderByDesc(AdoptionRecord::getStartDate));
        
        // Fill plant info
        resultPage.getRecords().forEach(record -> {
            Plant plant = plantMapper.selectById(record.getPlantId());
            if (plant != null) {
                record.setPlantName(plant.getName());
                record.setPlantCode(plant.getPlantCode());
                record.setImageUrls(plant.getImageUrls());
            }
        });
        
        return resultPage;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String finishAdoption(Long userId, Long recordId) {
        AdoptionRecord record = recordMapper.selectById(recordId);
        if (record == null) {
            throw new RuntimeException("记录不存在");
        }
        if (!record.getUserId().equals(userId)) {
            throw new RuntimeException("无权操作此记录");
        }
        if (!"ACTIVE".equals(record.getStatus())) {
            throw new RuntimeException("该认养记录已处于非活跃状态");
        }

        // 1. 更新记录状态
        record.setStatus("FINISHED");
        record.setEndDate(LocalDate.now());
        record.setIsActive(0);
        recordMapper.updateById(record);

        // 2. 更新植物状态为待认养
        Plant plant = plantMapper.selectById(record.getPlantId());
        if (plant != null) {
            plant.setStatus("AVAILABLE");
            plantMapper.updateById(plant);
        }

        // 3. 结算成果
        String msg = achievementService.updateUserAchievement(userId, record.getPlantId());
        
        // 4. 发送通知
        notificationService.sendNotification(userId, "认养圆满完成", 
                String.format("您对植物《%s》的认养已顺利结束，感谢您的悉心照顾！您可以在“认养成果”中查看本次评价。", 
                plant != null ? plant.getName() : "植物"), "SYSTEM");
                
        return msg;
    }
}
