package com.schoolplant.annotation;

import java.lang.annotation.*;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Log {
    /**
     * 模块名称
     */
    String module() default "";

    /**
     * 操作类型
     */
    String type() default "";

    /**
     * 操作描述
     */
    String desc() default "";
    
    /**
     * 关联业务ID的SpEL表达式 (e.g., "#id", "#plant.id")
     */
    String key() default "";
}
