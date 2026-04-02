package com.schoolplant.controller;

import cn.dev33.satoken.annotation.SaCheckRole;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.schoolplant.annotation.Log;
import com.schoolplant.common.R;
import com.schoolplant.entity.SystemParameter;
import com.schoolplant.service.SystemParameterService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "系统参数配置", description = "系统参数配置")
@RestController
@RequestMapping("/system/params")
public class SystemParameterController {

    @Autowired
    private SystemParameterService parameterService;

    @Operation(summary = "获取参数列表")
    @SaCheckRole("ADMIN")
    @GetMapping("/list")
    public R<List<SystemParameter>> list(@RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<SystemParameter> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.and(w -> w.like(SystemParameter::getParamKey, keyword)
                    .or()
                    .like(SystemParameter::getDescription, keyword));
        }
        wrapper.orderByAsc(SystemParameter::getId);
        return R.ok(parameterService.list(wrapper));
    }

    @Operation(summary = "更新参数")
    @SaCheckRole("ADMIN") // Super admin check can be done via role name or permission
    @Log(module = "SYSTEM", desc = "更新系统参数", type = "UPDATE", key = "#request.key")
    @PostMapping("/update")
    public R<Void> update(@RequestBody ParameterUpdateRequest request) {
        // Simple validation
        if (request.getValue() == null) {
            return R.fail("参数值不能为空");
        }
        
        // Skip numeric check for non-numeric parameters
        if ("CURRENT_CYCLE".equals(request.getKey()) || 
            "CLOCK_IN_START_TIME".equals(request.getKey()) || 
            "CLOCK_IN_END_TIME".equals(request.getKey())) {
            // String parameters, skip numeric validation
        } else {
            // Numeric check for other parameters
            try {
                double v = Double.parseDouble(request.getValue());
                if (v < 0) {
                    return R.fail("参数值必须为非负数");
                }
            } catch (NumberFormatException e) {
                 return R.fail("参数值必须为数字");
            }
        }

        parameterService.updateValue(request.getKey(), request.getValue());
        return R.ok();
    }
    
    @Data
    public static class ParameterUpdateRequest {
        private String key;
        private String value;
    }
}
