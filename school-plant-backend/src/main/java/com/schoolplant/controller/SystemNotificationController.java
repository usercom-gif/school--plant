package com.schoolplant.controller;

import cn.dev33.satoken.annotation.SaCheckLogin;
import cn.dev33.satoken.stp.StpUtil;
import com.schoolplant.common.R;
import com.schoolplant.entity.SystemNotification;
import com.schoolplant.service.SystemNotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "系统通知管理", description = "系统通知管理")
@RestController
@RequestMapping("/system/notification")
public class SystemNotificationController {

    @Autowired
    private SystemNotificationService notificationService;

    @Operation(summary = "获取我的通知列表")
    @SaCheckLogin
    @GetMapping("/list")
    public R<List<SystemNotification>> list(@RequestParam(defaultValue = "20") Integer limit) {
        Long userId = StpUtil.getLoginIdAsLong();
        return R.ok(notificationService.listUserNotifications(userId, limit));
    }

    @Operation(summary = "获取未读数量")
    @SaCheckLogin
    @GetMapping("/unread-count")
    public R<Long> unreadCount() {
        Long userId = StpUtil.getLoginIdAsLong();
        return R.ok(notificationService.countUnread(userId));
    }

    @Operation(summary = "标记单个已读")
    @SaCheckLogin
    @PostMapping("/read/{id}")
    public R<Void> read(@PathVariable Long id) {
        Long userId = StpUtil.getLoginIdAsLong();
        notificationService.markAsRead(id, userId);
        return R.ok();
    }

    @Operation(summary = "标记所有已读")
    @SaCheckLogin
    @PostMapping("/read-all")
    public R<Void> readAll() {
        Long userId = StpUtil.getLoginIdAsLong();
        notificationService.markAllAsRead(userId);
        return R.ok();
    }
}
