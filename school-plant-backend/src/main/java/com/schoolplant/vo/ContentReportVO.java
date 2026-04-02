package com.schoolplant.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ContentReportVO {
    private Long id;
    private Long postId;
    private String postTitle;
    private String postAuthorName;
    private Long reporterId;
    private String reporterName;
    private String reason;
    private String status; // PENDING, REVIEWED, RESOLVED
    private Long reviewedBy;
    private String reviewerName;
    private LocalDateTime reviewedAt;
    private LocalDateTime createdAt;
}
