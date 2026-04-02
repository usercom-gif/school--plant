package com.schoolplant.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 用户养护任务设置
 */
@Data
@TableName("user_task_settings")
public class UserTaskSetting implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField("plant_id")
    private Long plantId;

    @TableField("task_type")
    private String taskType;

    @TableField("frequency_days")
    private Integer frequencyDays;

    @TableField("scheduled_time")
    private LocalTime scheduledTime;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
