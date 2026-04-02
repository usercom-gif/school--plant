ALTER TABLE operation_logs ADD COLUMN related_id VARCHAR(64) COMMENT '关联业务ID';
ALTER TABLE operation_logs ADD INDEX idx_related_id (related_id);
ALTER TABLE operation_logs ADD INDEX idx_operator_name (operator_name);
ALTER TABLE operation_logs ADD INDEX idx_module (module);
ALTER TABLE operation_logs ADD INDEX idx_created_at (created_at);
