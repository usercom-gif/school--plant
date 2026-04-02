CREATE TABLE IF NOT EXISTS `system_parameters` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `param_key` varchar(100) NOT NULL COMMENT '参数键',
  `param_value` varchar(500) NOT NULL COMMENT '参数值',
  `description` varchar(255) DEFAULT NULL COMMENT '参数说明',
  `updated_by` bigint(20) DEFAULT NULL COMMENT '更新人ID',
  `updated_by_name` varchar(50) DEFAULT NULL COMMENT '更新人姓名',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_param_key` (`param_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统参数配置表';

-- Initialize default parameters
INSERT INTO `system_parameters` (`param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES
('ADOPTION_LIMIT', '1', '每人认养植物上限数量', 1, 'Admin', NOW()),
('ABNORMALITY_TIMEOUT_HOURS', '48', '异常处理提醒时效(小时)', 1, 'Admin', NOW()),
('KNOWLEDGE_FEATURE_LIKES', '20', '知识帖推荐点赞阈值', 1, 'Admin', NOW()),
('TASK_OVERDUE_DAYS', '3', '养护任务超期取消时长(天)', 1, 'Admin', NOW()),
('ACHIEVEMENT_COMPLETION_RATE', '100', '成果评比任务完成率阈值(%)', 1, 'Admin', NOW())
ON DUPLICATE KEY UPDATE `param_value` = VALUES(`param_value`);
