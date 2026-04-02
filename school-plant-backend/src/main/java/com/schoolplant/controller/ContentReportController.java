package com.schoolplant.controller;

import cn.dev33.satoken.annotation.SaCheckRole;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.schoolplant.annotation.Log;
import com.schoolplant.common.R;
import com.schoolplant.dto.ContentReportQueryRequest;
import com.schoolplant.service.ContentReportService;
import com.schoolplant.vo.ContentReportVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Tag(name = "内容举报管理", description = "内容举报管理")
@RestController
@RequestMapping("/system/report")
public class ContentReportController {

    @Autowired
    private ContentReportService reportService;

    @Operation(summary = "获取举报列表")
    @SaCheckRole("ADMIN")
    @GetMapping("/list")
    public R<Page<ContentReportVO>> list(ContentReportQueryRequest request) {
        return R.ok(reportService.getReportList(request));
    }

    @Operation(summary = "处理举报")
    @SaCheckRole("ADMIN")
    @Log(module = "SYSTEM", desc = "处理内容举报", type = "UPDATE", key = "#id")
    @PostMapping("/{id}/handle")
    public R<Void> handle(@PathVariable Long id, @RequestParam String action, @RequestParam(required = false) String reason) {
        reportService.handleReport(id, action, reason);
        return R.ok();
    }
}
