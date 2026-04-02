package com.schoolplant.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.schoolplant.dto.UserTaskSettingRequest;
import com.schoolplant.entity.UserTaskSetting;

import java.util.List;

public interface UserTaskSettingService extends IService<UserTaskSetting> {
    List<UserTaskSetting> getSettings(Long userId, Long plantId);
    void saveSettings(Long userId, Long plantId, List<UserTaskSettingRequest> requests);
}
