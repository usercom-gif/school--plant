package com.schoolplant.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("adoption_records")
public class AdoptionRecord implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long plantId;

    @TableField(exist = false)
    private String plantName;

    @TableField(exist = false)
    private String plantCode;

    @TableField(exist = false)
    private String imageUrls; // For display

    private LocalDate startDate;
    
    @TableField(updateStrategy = FieldStrategy.IGNORED) // Allow null if needed, but here we want to allow null insert
    private LocalDate endDate; // Nullable
    
    private String status; // ACTIVE, FINISHED, CANCELLED
    
    @TableField(insertStrategy = FieldStrategy.NEVER, updateStrategy = FieldStrategy.NEVER)
    private Integer isActive; // Generated column mapping
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    
    @TableLogic(value = "0", delval = "1")
    private Integer deleted;
}
