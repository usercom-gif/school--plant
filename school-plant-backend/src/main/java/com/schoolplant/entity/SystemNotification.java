package com.schoolplant.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("system_notifications")
public class SystemNotification implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField("title")
    private String title;

    @TableField("content")
    private String content;

    @TableField("type")
    private String type; // SYSTEM, AUDIT, REMINDER

    @TableField("is_read")
    private Integer isRead; // 0: unread, 1: read

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
