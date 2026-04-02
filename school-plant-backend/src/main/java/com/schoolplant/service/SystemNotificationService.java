package com.schoolplant.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.schoolplant.entity.SystemNotification;
import java.util.List;

public interface SystemNotificationService extends IService<SystemNotification> {
    
    /**
     * 发送系统通知
     */
    void sendNotification(Long userId, String title, String content, String type);

    /**
     * 获取用户未读通知数量
     */
    long countUnread(Long userId);

    /**
     * 获取用户通知列表
     */
    List<SystemNotification> listUserNotifications(Long userId, Integer limit);

    /**
     * 标记单个通知为已读
     */
    void markAsRead(Long id, Long userId);

    /**
     * 标记所有为已读
     */
    void markAllAsRead(Long userId);
}
