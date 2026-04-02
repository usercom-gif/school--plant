package com.schoolplant.controller;

import cn.dev33.satoken.annotation.SaCheckRole;
import cn.dev33.satoken.annotation.SaMode;
import cn.dev33.satoken.stp.StpUtil;
import com.alibaba.excel.EasyExcel;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.schoolplant.common.R;
import com.schoolplant.dto.OperationLogQueryRequest;
import com.schoolplant.entity.OperationLog;
import com.schoolplant.service.OperationLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

@Tag(name = "操作日志管理", description = "操作日志管理")
@RestController
@RequestMapping("/system/log")
public class OperationLogController {

    @Autowired
    private OperationLogService logService;

    @Operation(summary = "查询操作日志列表")
    @SaCheckRole("ADMIN") // Only Admin
    @GetMapping("/list")
    public R<Page<OperationLog>> list(OperationLogQueryRequest request) {
        Page<OperationLog> page = logService.listLogs(request);
        return R.ok(page);
    }

    @Operation(summary = "查询我的操作日志")
    @SaCheckRole(value = {"ADMIN", "MAINTAINER"}, mode = SaMode.OR)
    @GetMapping("/my")
    public R<Page<OperationLog>> my(OperationLogQueryRequest request) {
        request.setOperatorId(StpUtil.getLoginIdAsLong());
        Page<OperationLog> page = logService.listLogs(request);
        return R.ok(page);
    }
    
    @Operation(summary = "导出操作日志")
    @SaCheckRole("ADMIN")
    @GetMapping("/export")
    public void export(OperationLogQueryRequest request, HttpServletResponse response) throws IOException {
        // Limit export size if needed, or get all
        request.setSize(10000); // Max 10000 for safety
        Page<OperationLog> page = logService.listLogs(request);
        List<OperationLog> list = page.getRecords();
        
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("操作日志", "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");
        
        EasyExcel.write(response.getOutputStream(), OperationLog.class)
                .sheet("Logs")
                .doWrite(list);
    }
}
