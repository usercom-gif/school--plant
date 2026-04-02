package com.schoolplant.service.impl;

import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.entity.SystemParameter;
import com.schoolplant.entity.User;
import com.schoolplant.mapper.SystemParameterMapper;
import com.schoolplant.service.SystemParameterService;
import com.schoolplant.service.UserService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class SystemParameterServiceImpl extends ServiceImpl<SystemParameterMapper, SystemParameter> implements SystemParameterService {

    @Autowired
    private UserService userService;

    // Local Cache
    private final Map<String, String> paramCache = new ConcurrentHashMap<>();

    @PostConstruct
    public void init() {
        initCache();
    }

    @Override
    public void initCache() {
        List<SystemParameter> list = this.list();
        for (SystemParameter param : list) {
            paramCache.put(param.getParamKey(), param.getParamValue());
        }
    }

    @Override
    public String getValue(String key) {
        if (paramCache.containsKey(key)) {
            return paramCache.get(key);
        }
        // Fallback to DB
        SystemParameter param = this.getOne(new LambdaQueryWrapper<SystemParameter>().eq(SystemParameter::getParamKey, key));
        if (param != null) {
            paramCache.put(key, param.getParamValue());
            return param.getParamValue();
        }
        return null;
    }

    @Override
    public Integer getInt(String key, Integer defaultValue) {
        String val = getValue(key);
        if (val == null) return defaultValue;
        try {
            return Integer.parseInt(val);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    @Override
    public Long getLong(String key, Long defaultValue) {
        String val = getValue(key);
        if (val == null) return defaultValue;
        try {
            return Long.parseLong(val);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    @Override
    public BigDecimal getBigDecimal(String key, BigDecimal defaultValue) {
        String val = getValue(key);
        if (val == null) return defaultValue;
        try {
            return new BigDecimal(val);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    @Override
    public void updateValue(String key, String value) {
        SystemParameter param = this.getOne(new LambdaQueryWrapper<SystemParameter>().eq(SystemParameter::getParamKey, key));
        if (param == null) {
            throw new RuntimeException("参数未找到: " + key);
        }
        
        param.setParamValue(value);
        
        // Update user info if logged in
        if (StpUtil.isLogin()) {
            Long userId = StpUtil.getLoginIdAsLong();
            param.setUpdatedBy(userId);
            User user = userService.getById(userId);
            if (user != null) {
                param.setUpdatedByName(user.getUsername());
            }
        }
        
        this.updateById(param);
        
        // Update Cache
        paramCache.put(key, value);
    }
}
