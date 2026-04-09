package com.schoolplant.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.entity.SystemNotification;
import com.schoolplant.mapper.SystemNotificationMapper;
import com.schoolplant.service.SystemNotificationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SystemNotificationServiceImpl extends ServiceImpl<SystemNotificationMapper, SystemNotification> implements SystemNotificationService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void sendNotification(Long userId, String title, String content, String type) {
        SystemNotification notification = new SystemNotification();
        notification.setUserId(userId);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setType(type);
        notification.setIsRead(0);
        notification.setCreatedAt(LocalDateTime.now());
        save(notification);
    }

    @Override
    public long countUnread(Long userId) {
        return count(new LambdaQueryWrapper<SystemNotification>()
                .and(w -> w.eq(SystemNotification::getUserId, userId)
                           .or()
                           .eq(SystemNotification::getUserId, 0L))
                .eq(SystemNotification::getIsRead, 0));
    }

    @Override
    public List<SystemNotification> listUserNotifications(Long userId, Integer limit) {
        // Fetch specific user notifications OR global announcements (user_id = 0)
        LambdaQueryWrapper<SystemNotification> wrapper = new LambdaQueryWrapper<SystemNotification>()
                .and(w -> w.eq(SystemNotification::getUserId, userId)
                           .or()
                           .eq(SystemNotification::getUserId, 0L))
                .orderByDesc(SystemNotification::getCreatedAt);
        
        if (limit != null && limit > 0) {
            wrapper.last("LIMIT " + limit);
        }
        
        return list(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markAsRead(Long id, Long userId) {
        // If it's a global announcement (user_id = 0), marking as read is a bit tricky
        // For simplicity in MVP, we won't mutate user_id 0 to read because it affects everyone.
        // We just ignore markAsRead for user_id = 0 for now.
        lambdaUpdate()
                .eq(SystemNotification::getId, id)
                .eq(SystemNotification::getUserId, userId)
                .eq(SystemNotification::getIsRead, 0)
                .set(SystemNotification::getIsRead, 1)
                .update();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markAllAsRead(Long userId) {
        lambdaUpdate()
                .eq(SystemNotification::getUserId, userId)
                .eq(SystemNotification::getIsRead, 0)
                .set(SystemNotification::getIsRead, 1)
                .update();
    }
}
