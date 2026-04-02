package com.schoolplant.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.schoolplant.entity.SystemParameter;
import java.math.BigDecimal;

public interface SystemParameterService extends IService<SystemParameter> {
    
    /**
     * Initialize cache on startup
     */
    void initCache();
    
    /**
     * Get parameter value by key
     */
    String getValue(String key);

    /**
     * Get parameter value by key with default
     */
    default String getValue(String key, String defaultValue) {
        String val = getValue(key);
        return val != null ? val : defaultValue;
    }
    
    /**
     * Get parameter value as Integer
     */
    Integer getInt(String key, Integer defaultValue);
    
    /**
     * Get parameter value as Long
     */
    Long getLong(String key, Long defaultValue);
    
    /**
     * Get parameter value as BigDecimal
     */
    BigDecimal getBigDecimal(String key, BigDecimal defaultValue);
    
    /**
     * Update parameter value
     */
    void updateValue(String key, String value);
}
