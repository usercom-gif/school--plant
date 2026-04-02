package com.schoolplant.service.impl;

import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.dto.ContentReportQueryRequest;
import com.schoolplant.entity.ContentReport;
import com.schoolplant.entity.KnowledgePost;
import com.schoolplant.entity.User;
import com.schoolplant.mapper.ContentReportMapper;
import com.schoolplant.mapper.KnowledgePostMapper;
import com.schoolplant.mapper.UserMapper;
import com.schoolplant.service.ContentReportService;
import com.schoolplant.service.SystemNotificationService;
import com.schoolplant.vo.ContentReportVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ContentReportServiceImpl extends ServiceImpl<ContentReportMapper, ContentReport> implements ContentReportService {

    @Autowired
    private KnowledgePostMapper postMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private SystemNotificationService notificationService;

    @Override
    public Page<ContentReportVO> getReportList(ContentReportQueryRequest request) {
        Page<ContentReport> page = new Page<>(request.getPage(), request.getSize());
        LambdaQueryWrapper<ContentReport> wrapper = new LambdaQueryWrapper<>();
        
        if (StringUtils.hasText(request.getStatus())) {
            wrapper.eq(ContentReport::getStatus, request.getStatus());
        }
        
        wrapper.orderByDesc(ContentReport::getCreatedAt);
        
        Page<ContentReport> reportPage = this.page(page, wrapper);
        Page<ContentReportVO> voPage = new Page<>(reportPage.getCurrent(), reportPage.getSize(), reportPage.getTotal());
        
        List<ContentReportVO> voList = reportPage.getRecords().stream().map(this::convertToVO).collect(Collectors.toList());
        voPage.setRecords(voList);
        
        return voPage;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleReport(Long id, String action, String reason) {
        ContentReport report = this.getById(id);
        if (report == null) {
            throw new RuntimeException("举报记录不存在");
        }
        
        KnowledgePost post = postMapper.selectById(report.getPostId());
        String postTitle = post != null ? post.getTitle() : "原帖子";
        
        Long adminId = StpUtil.getLoginIdAsLong();
        User admin = userMapper.selectById(adminId);
        String adminInfo = admin != null ? String.format("%s (%s)", admin.getRealName(), admin.getPhone()) : "管理员";

        if ("DELETE_POST".equals(action)) {
            if (post != null) {
                postMapper.deleteById(post.getId());
                // 通知作者
                String authorMsg = String.format("因%s，您的帖子《%s》被删除，如有疑问请联系管理员%s", 
                    StringUtils.hasText(reason) ? reason : "违反社区规定", 
                    postTitle, 
                    adminInfo);
                notificationService.sendNotification(
                    post.getAuthorId(), 
                    "帖子处理通知", 
                    authorMsg, 
                    "SYSTEM"
                );
            }
            // 通知举报人
            String reporterMsg = String.format("您举报的帖子《%s》经核查，处理结果为：%s。感谢您的监督！", 
                postTitle, 
                StringUtils.hasText(reason) ? reason : "已删除该违规帖子");
            notificationService.sendNotification(
                report.getReporterId(), 
                "举报处理反馈", 
                reporterMsg, 
                "SYSTEM"
            );
        } else {
            // IGNORE
            // 通知举报人
            String reporterMsg = String.format("您举报的帖子《%s》经核查，处理结果为：%s。感谢您的监督！", 
                postTitle, 
                StringUtils.hasText(reason) ? reason : "经核实内容正常");
            notificationService.sendNotification(
                report.getReporterId(), 
                "举报处理反馈", 
                reporterMsg, 
                "SYSTEM"
            );
        }
        
        report.setStatus("RESOLVED");
        report.setReviewedBy(adminId);
        report.setReviewedAt(LocalDateTime.now());
        this.updateById(report);
    }

    private ContentReportVO convertToVO(ContentReport report) {
        ContentReportVO vo = new ContentReportVO();
        BeanUtils.copyProperties(report, vo);
        
        KnowledgePost post = postMapper.selectById(report.getPostId());
        if (post != null) {
            vo.setPostTitle(post.getTitle());
            User author = userMapper.selectById(post.getAuthorId());
            if (author != null) {
                vo.setPostAuthorName(author.getRealName());
            }
        }
        
        User reporter = userMapper.selectById(report.getReporterId());
        if (reporter != null) {
            vo.setReporterName(reporter.getRealName());
        }
        
        if (report.getReviewedBy() != null) {
            User reviewer = userMapper.selectById(report.getReviewedBy());
            if (reviewer != null) {
                vo.setReviewerName(reviewer.getRealName());
            }
        }
        
        return vo;
    }
}
