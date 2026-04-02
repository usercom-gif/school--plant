package com.schoolplant.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.dto.OperationLogQueryRequest;
import com.schoolplant.entity.OperationLog;
import com.schoolplant.mapper.OperationLogMapper;
import com.schoolplant.service.OperationLogService;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class OperationLogServiceImpl extends ServiceImpl<OperationLogMapper, OperationLog> implements OperationLogService {

    @Async
    @Override
    public void saveLog(OperationLog log) {
        // Save async
        this.save(log);
    }

    @Override
    public Page<OperationLog> listLogs(OperationLogQueryRequest request) {
        Page<OperationLog> page = new Page<>(request.getPage(), request.getSize());
        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();

        if (request.getOperatorId() != null) {
            wrapper.eq(OperationLog::getUserId, request.getOperatorId());
        }

        if (StringUtils.hasText(request.getOperatorName())) {
            wrapper.like(OperationLog::getOperatorName, request.getOperatorName());
        }
        if (StringUtils.hasText(request.getModule())) {
            wrapper.eq(OperationLog::getModule, request.getModule());
        }
        if (StringUtils.hasText(request.getOperationType())) {
            wrapper.eq(OperationLog::getOperationType, request.getOperationType());
        }
        if (StringUtils.hasText(request.getStartTime())) {
            wrapper.ge(OperationLog::getCreatedAt, request.getStartTime());
        }
        if (StringUtils.hasText(request.getEndTime())) {
            wrapper.le(OperationLog::getCreatedAt, request.getEndTime());
        }

        wrapper.orderByDesc(OperationLog::getCreatedAt);
        return this.page(page, wrapper);
    }
}
