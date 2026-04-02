package com.schoolplant.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 帖子评论表
 */
@Data
@TableName("post_comments")
public class PostComment implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("post_id")
    private Long postId;

    @TableField("user_id")
    private Long userId;

    @TableField("parent_id")
    private Long parentId;

    @TableField("content")
    private String content;

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    // 非数据库字段
    @TableField(exist = false)
    private String username;

    @TableField(exist = false)
    private String avatarUrl;

    @TableField(exist = false)
    private String realName;

    @TableField(exist = false)
    private String parentUsername;

    @TableField(exist = false)
    private String parentRealName;

    @TableField(exist = false)
    private String parentAvatarUrl;
}
