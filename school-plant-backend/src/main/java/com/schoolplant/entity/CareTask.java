package com.schoolplant.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("care_tasks")
public class CareTask implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("plant_id")
    private Long plantId;

    @TableField("adopter_id")
    private Long userId;

    @TableField("task_template_id")
    private Long taskTemplateId;

    @TableField("task_type")
    private String taskType;

    @TableField("task_description")
    private String taskDescription;

    @TableField("due_date")
    private LocalDate dueDate;

    @TableField("completed_date")
    private LocalDate completedDate;

    @TableField("status")
    private String status;

    @TableField("image_url")
    private String imageUrl;

    @TableField(exist = false)
    private List<String> imageUrls;

    @TableField("scheduled_time")
    private LocalDateTime scheduledTime;

    @TableField("is_user_defined")
    private Integer isUserDefined;

    @TableField("abnormality_id")
    private Long abnormalityId;

    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic(value = "0", delval = "1")
    private Integer deleted;
    
    // Helper method for completion logic if needed, but not as property
    public void setCompletedAt(LocalDateTime completedAt) {
        if (completedAt != null) {
            this.completedDate = completedAt.toLocalDate();
        }
    }
}
