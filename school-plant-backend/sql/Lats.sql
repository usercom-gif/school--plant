/*
 Navicat Premium Dump SQL

 Source Server         : Thesis
 Source Server Type    : MySQL
 Source Server Version : 90300 (9.3.0)
 Source Host           : localhost:3306
 Source Schema         : campus_plant_system

 Target Server Type    : MySQL
 Target Server Version : 90300 (9.3.0)
 File Encoding         : 65001

 Date: 02/04/2026 18:36:17
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for abnormality_process_logs
-- ----------------------------
DROP TABLE IF EXISTS `abnormality_process_logs`;
CREATE TABLE `abnormality_process_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `abnormality_id` bigint NOT NULL COMMENT '异常ID',
  `operator_id` bigint NOT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作人姓名',
  `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '动作: REPORT, ASSIGN, HANDLE, RESOLVE, CLOSE',
  `comment` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_abnormality_id` (`abnormality_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='异常处理流程日志';

-- ----------------------------
-- Records of abnormality_process_logs
-- ----------------------------
BEGIN;
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (1, 3, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-05 15:34:53');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (2, 3, 1, 'ADMIN', 'ASSIGN', '分派给养护员ID: 5', '2026-03-05 15:43:31');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (3, 4, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-05 16:30:40');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (4, 4, 1, 'ADMIN', 'ASSIGN', '分派给养护员ID: 5', '2026-03-05 16:32:35');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (5, 5, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-16 12:05:20');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (6, 6, 3, 'USER', 'REPORT', '用户上报异常', '2026-03-16 18:37:41');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (7, 6, 1, 'ADMIN', 'ASSIGN', '分派给养护员ID: 5', '2026-03-16 18:46:45');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (8, 5, 1, 'ADMIN', 'ASSIGN', '分派给养护员ID: 5', '2026-03-16 18:46:50');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (9, 1, 5, 'MAINTAINER', 'UNRESOLVED', '养护员标记处理失败', '2026-03-17 17:43:03');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (10, 7, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-18 10:26:35');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (11, 8, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-18 10:49:33');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (12, 9, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-18 10:50:17');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (13, 10, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-18 11:33:20');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (14, 11, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-18 15:11:53');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (15, 12, 4, 'USER', 'REPORT', '用户上报异常', '2026-03-18 15:12:28');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (16, 6, 5, 'MAINTAINER', 'RESOLVE', '养护员完成处理', '2026-03-18 15:14:12');
INSERT INTO `abnormality_process_logs` (`id`, `abnormality_id`, `operator_id`, `operator_name`, `action`, `comment`, `created_at`) VALUES (17, 13, 2, 'USER', 'REPORT', '用户上报异常', '2026-03-19 18:03:31');
COMMIT;

-- ----------------------------
-- Table structure for achievements
-- ----------------------------
DROP TABLE IF EXISTS `achievements`;
CREATE TABLE `achievements` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '成就记录ID，主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `plant_id` bigint NOT NULL COMMENT '认养植物ID',
  `adoption_start_date` date NOT NULL COMMENT '认养开始日期',
  `adoption_end_date` date DEFAULT NULL COMMENT '认养结束日期',
  `tasks_completed` int DEFAULT '0' COMMENT '已完成任务数',
  `total_tasks` int DEFAULT '0' COMMENT '总任务数',
  `task_completion_rate` decimal(5,2) DEFAULT '0.00' COMMENT '任务完成率（百分比）',
  `plant_health_score` decimal(5,2) DEFAULT '0.00' COMMENT '植物健康分',
  `is_outstanding` tinyint DEFAULT '0' COMMENT '是否优秀养护人：0-否，1-是',
  `certificate_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '电子荣誉证书URL',
  `adoption_cycle` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '认养周期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `adoption_duration_days` int DEFAULT '0' COMMENT '认养时长(天)',
  `composite_score` decimal(5,2) DEFAULT '0.00' COMMENT '综合评分',
  `user_real_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户真实姓名',
  `student_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '学号/职工号',
  PRIMARY KEY (`id`),
  KEY `plant_id` (`plant_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_semester` (`adoption_cycle`),
  KEY `idx_is_outstanding` (`is_outstanding`),
  CONSTRAINT `achievements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `achievements_ibfk_2` FOREIGN KEY (`plant_id`) REFERENCES `plants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='认养成果与评比表';

-- ----------------------------
-- Records of achievements
-- ----------------------------
BEGIN;
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (1, 2, 1, '2026-01-01', '2026-01-26', 0, 2, 0.00, 90.00, 0, 'https://example.com/certificate/wang_xiaoming_fall2025.pdf', '2026-Cycle1', '2026-01-03 16:01:24', '2026-03-06 16:59:50', 30, 45.00, '王小明', '2025001');
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (2, 2, 4, '2025-09-01', '2025-12-31', 24, 25, 50.00, 92.00, 0, 'https://example.com/certificate/wang_xiaoming_fall2025.pdf', '2025-Cycle1', '2026-01-03 16:01:24', '2026-03-06 16:59:47', 30, 50.00, '王小明', '2025001');
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (3, 3, 2, '2026-02-03', NULL, 10, 10, 100.00, 95.00, 1, NULL, '2024-Cycle1', '2026-03-05 17:41:51', '2026-03-06 17:03:17', 30, 97.00, '何杰', '2025002');
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (4, 7, 3, '2026-01-19', NULL, 7, 10, 70.00, 80.00, 0, NULL, '2024-Cycle1', '2026-03-05 17:41:51', '2026-04-02 17:53:32', 45, 72.50, '何瑜', NULL);
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (7, 2, 1, '2026-01-01', NULL, 0, 2, 0.00, 100.00, 0, NULL, '2024-Cycle1', '2026-03-06 16:55:15', '2026-03-06 16:55:15', 180, 50.00, '王小明', '2025001');
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (8, 4, 6, '2026-03-05', NULL, 0, 1, 0.00, 100.00, 0, NULL, '2024-Cycle1', '2026-03-06 16:55:15', '2026-04-02 17:58:25', 0, 50.00, '张炜', '2025003');
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (9, 2, 1, '2026-01-01', NULL, 0, 2, 0.00, 90.00, 0, NULL, '2023-Cycle2', '2026-03-19 18:07:13', '2026-03-19 18:07:13', 180, 45.00, '王小明', '2025001');
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (10, 3, 2, '2026-03-16', NULL, 0, 1, 0.00, 100.00, 0, NULL, '2023-Cycle2', '2026-03-19 18:07:13', '2026-03-19 18:07:13', 0, 50.00, '何杰', '2025002');
INSERT INTO `achievements` (`id`, `user_id`, `plant_id`, `adoption_start_date`, `adoption_end_date`, `tasks_completed`, `total_tasks`, `task_completion_rate`, `plant_health_score`, `is_outstanding`, `certificate_url`, `adoption_cycle`, `created_at`, `updated_at`, `adoption_duration_days`, `composite_score`, `user_real_name`, `student_id`) VALUES (11, 4, 6, '2026-03-05', NULL, 0, 1, 0.00, 40.00, 0, NULL, '2023-Cycle2', '2026-03-19 18:07:13', '2026-04-02 17:58:25', 0, 20.00, '张伟', '2025003');
COMMIT;

-- ----------------------------
-- Table structure for adoption_applications
-- ----------------------------
DROP TABLE IF EXISTS `adoption_applications`;
CREATE TABLE `adoption_applications` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '认养申请ID，主键',
  `user_id` bigint NOT NULL COMMENT '申请人用户ID',
  `plant_id` bigint NOT NULL COMMENT '申请认养的植物ID',
  `adoption_period_months` int NOT NULL DEFAULT '6' COMMENT '认养周期（月数，默认6个月即1学期）',
  `care_experience` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '养护经验说明',
  `status` enum('PENDING','APPROVED','REJECTED','INITIAL_AUDIT','INITIAL_PASSED','REVIEW_PASSED','CANCELLED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '申请状态',
  `rejection_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '驳回原因',
  `approved_by` bigint DEFAULT NULL COMMENT '审核人用户ID',
  `approved_at` timestamp NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '申请理由',
  `plan` text COLLATE utf8mb4_unicode_ci COMMENT '养护计划',
  `contact_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系方式',
  PRIMARY KEY (`id`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_plant_id` (`plant_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `adoption_applications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `adoption_applications_ibfk_2` FOREIGN KEY (`plant_id`) REFERENCES `plants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `adoption_applications_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='认养申请表';

-- ----------------------------
-- Records of adoption_applications
-- ----------------------------
BEGIN;
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (1, 2, 1, 6, '我在家中养过樱花盆栽，了解其生长习性和养护要点。可以保证每周定期浇水和观察生长状况。', 'APPROVED', '下次', 1, '2026-01-01 10:30:00', '2026-01-03 16:00:01', '2026-03-03 17:29:56', NULL, NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (2, 3, 2, 6, '我对银杏树很感兴趣，虽然没有直接养护经验，但我学习能力强，会认真按照指导进行养护。', 'REJECTED', '学习知识了再来', NULL, NULL, '2026-01-03 16:00:01', '2026-02-28 18:25:13', NULL, NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (3, 4, 3, 6, '我家附近就有桂花树，每年都能闻到香味。我了解桂花的基本养护需求，愿意承担认养责任。', 'REJECTED', '下一次', 1, '2026-01-02 14:20:00', '2026-01-03 16:00:01', '2026-02-28 18:23:00', NULL, NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (4, 2, 4, 6, '紫薇树已经有人认养了，但我还是想申请试试。', 'REJECTED', '一次下', 1, '2026-01-01 11:00:00', '2026-01-03 16:00:01', '2026-03-03 18:24:51', NULL, NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (5, 4, 2, 6, '我在家养过银杏树，我承诺我一定养的好，请放心我', 'APPROVED', '学习知识了再来', NULL, NULL, '2026-02-28 18:55:59', '2026-03-04 17:45:15', NULL, NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (6, 4, 2, 6, '我在家养过银杏树，我承诺我一定养的好，请放心我', 'REJECTED', '学习知识了再来', NULL, NULL, '2026-03-02 23:32:47', '2026-03-03 18:24:57', NULL, NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (7, 4, 2, 6, '我在家养过银杏树，我承诺我一定养的好，请放心我', 'REJECTED', '学习知识了再来', NULL, NULL, '2026-03-03 17:43:01', '2026-03-03 18:25:05', NULL, NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (8, 4, 2, 6, '我家种植了10年的隐形红啊哈佛阿福啊发酵', 'REJECTED', NULL, NULL, NULL, '2026-03-05 11:12:57', '2026-03-05 11:25:21', '用户认养申请', NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (9, 4, 6, 6, '额为发热服务而非唯粉我无法为人父为人万人次', 'CANCELLED', NULL, NULL, NULL, '2026-03-05 12:00:23', '2026-04-02 17:58:25', '用户认养申请', NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (10, 4, 6, 6, '12345123451234512342345234', 'APPROVED', NULL, NULL, NULL, '2026-03-05 12:12:50', '2026-04-02 17:58:25', '用户认养申请', NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (11, 3, 2, 6, '我家养了10年的老银杏树，我一直跟着学这干。', 'APPROVED', NULL, NULL, NULL, '2026-03-16 18:26:05', '2026-03-16 18:26:23', '用户认养申请', NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (12, 9, 3, 6, '12345678HIUEWHFUWEHFW', 'REJECTED', '看不懂你说的什么', NULL, NULL, '2026-03-17 11:18:45', '2026-04-02 17:53:32', '用户认养申请', NULL, NULL);
INSERT INTO `adoption_applications` (`id`, `user_id`, `plant_id`, `adoption_period_months`, `care_experience`, `status`, `rejection_reason`, `approved_by`, `approved_at`, `created_at`, `updated_at`, `reason`, `plan`, `contact_phone`) VALUES (13, 2, 1, 6, '我前面就是养得这个，我想再继续照顾他，希望可以。', 'APPROVED', NULL, 1, '2026-03-19 19:00:20', '2026-03-19 19:00:09', '2026-03-19 19:00:20', '用户认养申请', NULL, '13800138002');
COMMIT;

-- ----------------------------
-- Table structure for adoption_audit_logs
-- ----------------------------
DROP TABLE IF EXISTS `adoption_audit_logs`;
CREATE TABLE `adoption_audit_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '审核记录ID',
  `application_id` bigint NOT NULL COMMENT '认养申请ID',
  `auditor_id` bigint NOT NULL COMMENT '审核人ID',
  `auditor_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核人姓名',
  `audit_stage` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REVIEW',
  `audit_action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审核动作',
  `comment` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核意见',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '审核时间',
  PRIMARY KEY (`id`),
  KEY `idx_application_id` (`application_id`),
  KEY `idx_auditor_id` (`auditor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='认养申请审核记录表';

-- ----------------------------
-- Records of adoption_audit_logs
-- ----------------------------
BEGIN;
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (1, 2, 1, 'Admin-1', ' ', 'REJECT', '学习知识了再来', '2026-02-28 18:25:13');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (2, 5, 1, 'Admin-1', ' ', 'PASS', '很好加油', '2026-02-28 18:56:44');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (4, 6, 1, 'admin', ' ', 'REJECTED', '你的说法没有说服力', '2026-03-03 00:15:21');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (5, 7, 1, 'admin', ' ', 'REJECTED', '下一次\n', '2026-03-03 18:13:35');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (6, 8, 1, 'admin', 'REVIEW', 'REJECTED', '理由不充分', '2026-03-05 11:25:21');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (7, 10, 3, '229971004', 'REVIEW', 'INITIAL_PASS', '我觉得可以放心交给她', '2026-03-05 12:13:39');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (8, 10, 1, 'admin', 'REVIEW', 'APPROVED', '12', '2026-03-05 12:18:06');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (9, 11, 1, 'admin', 'REVIEW', 'APPROVED', '很好', '2026-03-16 18:26:23');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (10, 12, 1, 'admin', 'REVIEW', 'REJECT', '看不懂你说的什么', '2026-03-17 11:19:18');
INSERT INTO `adoption_audit_logs` (`id`, `application_id`, `auditor_id`, `auditor_name`, `audit_stage`, `audit_action`, `comment`, `created_at`) VALUES (11, 13, 1, 'admin', 'REVIEW', 'PASS', '', '2026-03-19 19:00:20');
COMMIT;

-- ----------------------------
-- Table structure for adoption_records
-- ----------------------------
DROP TABLE IF EXISTS `adoption_records`;
CREATE TABLE `adoption_records` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '认养记录ID，主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `plant_id` bigint NOT NULL COMMENT '植物ID',
  `start_date` date NOT NULL COMMENT '认养开始日期',
  `end_date` date DEFAULT NULL COMMENT '结束日期',
  `status` enum('ACTIVE','FINISHED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE-进行中，FINISHED-已结束，CANCELLED-已取消',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT '0' COMMENT '逻辑删除：0-未删，1-已删',
  `is_active` tinyint DEFAULT '1' COMMENT '是否有效',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_plant_id` (`plant_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `adoption_records_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `adoption_records_ibfk_2` FOREIGN KEY (`plant_id`) REFERENCES `plants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='认养记录表';

-- ----------------------------
-- Records of adoption_records
-- ----------------------------
BEGIN;
INSERT INTO `adoption_records` (`id`, `user_id`, `plant_id`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`, `deleted`, `is_active`) VALUES (1, 2, 1, '2026-01-01', '2026-03-19', 'FINISHED', '2026-01-01 10:30:00', '2026-01-01 10:30:00', 0, 1);
INSERT INTO `adoption_records` (`id`, `user_id`, `plant_id`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`, `deleted`, `is_active`) VALUES (2, 4, 6, '2026-03-05', NULL, 'ACTIVE', '2026-03-05 12:18:06', '2026-04-02 17:58:25', 0, 1);
INSERT INTO `adoption_records` (`id`, `user_id`, `plant_id`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`, `deleted`, `is_active`) VALUES (3, 3, 2, '2026-03-16', NULL, 'ACTIVE', '2026-03-16 18:26:23', '2026-03-16 18:26:23', 0, 1);
INSERT INTO `adoption_records` (`id`, `user_id`, `plant_id`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`, `deleted`, `is_active`) VALUES (4, 2, 1, '2026-03-19', '2026-09-18', 'ACTIVE', '2026-03-19 19:00:20', '2026-03-19 19:00:20', 0, 1);
COMMIT;

-- ----------------------------
-- Table structure for care_tasks
-- ----------------------------
DROP TABLE IF EXISTS `care_tasks`;
CREATE TABLE `care_tasks` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '养护任务ID，主键',
  `plant_id` bigint NOT NULL COMMENT '关联植物ID',
  `adopter_id` bigint NOT NULL COMMENT '认养人用户ID',
  `task_template_id` bigint DEFAULT NULL COMMENT '关联任务模板ID',
  `task_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务类型',
  `task_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务描述',
  `due_date` date NOT NULL COMMENT '截止日期',
  `completed_date` date DEFAULT NULL COMMENT '完成日期',
  `status` enum('PENDING','COMPLETED','OVERDUE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '任务状态：PENDING-待完成，COMPLETED-已完成，OVERDUE-已超时',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除',
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '完成任务凭证图片URL',
  `scheduled_time` datetime DEFAULT NULL COMMENT '计划执行时间',
  `is_user_defined` tinyint DEFAULT '0' COMMENT '是否用户自定义',
  `abnormality_id` bigint DEFAULT NULL COMMENT '打卡时上报的异常ID',
  PRIMARY KEY (`id`),
  KEY `task_template_id` (`task_template_id`),
  KEY `idx_adopter_id` (`adopter_id`),
  KEY `idx_plant_id` (`plant_id`),
  KEY `idx_status` (`status`),
  KEY `idx_due_date` (`due_date`),
  CONSTRAINT `care_tasks_ibfk_1` FOREIGN KEY (`plant_id`) REFERENCES `plants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `care_tasks_ibfk_2` FOREIGN KEY (`adopter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `care_tasks_ibfk_3` FOREIGN KEY (`task_template_id`) REFERENCES `task_templates` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='养护任务表';

-- ----------------------------
-- Records of care_tasks
-- ----------------------------
BEGIN;
INSERT INTO `care_tasks` (`id`, `plant_id`, `adopter_id`, `task_template_id`, `task_type`, `task_description`, `due_date`, `completed_date`, `status`, `created_at`, `updated_at`, `deleted`, `image_url`, `scheduled_time`, `is_user_defined`, `abnormality_id`) VALUES (1, 1, 2, 1, '浇水', '彻底浇灌樱花树根部，确保土壤湿润但不积水，每次约20升水。', '2026-01-10', NULL, 'OVERDUE', '2026-01-03 16:00:01', '2026-01-03 16:00:01', 0, NULL, NULL, 0, NULL);
INSERT INTO `care_tasks` (`id`, `plant_id`, `adopter_id`, `task_template_id`, `task_type`, `task_description`, `due_date`, `completed_date`, `status`, `created_at`, `updated_at`, `deleted`, `image_url`, `scheduled_time`, `is_user_defined`, `abnormality_id`) VALUES (2, 1, 2, 3, '施肥', '施用复合肥，每株约100克，均匀撒在树冠投影范围内。', '2026-02-15', NULL, 'OVERDUE', '2026-01-03 16:00:01', '2026-01-03 16:00:01', 0, NULL, NULL, 0, NULL);
INSERT INTO `care_tasks` (`id`, `plant_id`, `adopter_id`, `task_template_id`, `task_type`, `task_description`, `due_date`, `completed_date`, `status`, `created_at`, `updated_at`, `deleted`, `image_url`, `scheduled_time`, `is_user_defined`, `abnormality_id`) VALUES (3, 2, 3, 4, '浇水', '银杏树耐旱，仅在连续干旱时浇水，每次约15升。', '2026-01-15', NULL, 'OVERDUE', '2026-01-03 16:00:01', '2026-01-03 16:00:01', 0, NULL, NULL, 0, NULL);
INSERT INTO `care_tasks` (`id`, `plant_id`, `adopter_id`, `task_template_id`, `task_type`, `task_description`, `due_date`, `completed_date`, `status`, `created_at`, `updated_at`, `deleted`, `image_url`, `scheduled_time`, `is_user_defined`, `abnormality_id`) VALUES (4, 3, 4, 6, '浇水', '桂花喜湿润，保持土壤微湿，每次浇水约15升。', '2026-01-08', NULL, 'OVERDUE', '2026-01-03 16:00:01', '2026-01-03 16:00:01', 0, NULL, NULL, 0, NULL);
INSERT INTO `care_tasks` (`id`, `plant_id`, `adopter_id`, `task_template_id`, `task_type`, `task_description`, `due_date`, `completed_date`, `status`, `created_at`, `updated_at`, `deleted`, `image_url`, `scheduled_time`, `is_user_defined`, `abnormality_id`) VALUES (5, 2, 3, NULL, '浇水', '银杏树耐旱，仅在连续干旱时浇水，每次约15升。', '2026-03-18', NULL, 'OVERDUE', '2026-03-17 04:13:32', '2026-04-02 18:00:21', 0, NULL, '2026-03-18 13:00:00', 0, NULL);
INSERT INTO `care_tasks` (`id`, `plant_id`, `adopter_id`, `task_template_id`, `task_type`, `task_description`, `due_date`, `completed_date`, `status`, `created_at`, `updated_at`, `deleted`, `image_url`, `scheduled_time`, `is_user_defined`, `abnormality_id`) VALUES (6, 6, 4, NULL, '松土', '用户自定义任务', '2026-03-19', NULL, 'OVERDUE', '2026-03-18 04:10:08', '2026-04-02 18:00:21', 0, NULL, '2026-03-19 13:00:00', 1, NULL);
INSERT INTO `care_tasks` (`id`, `plant_id`, `adopter_id`, `task_template_id`, `task_type`, `task_description`, `due_date`, `completed_date`, `status`, `created_at`, `updated_at`, `deleted`, `image_url`, `scheduled_time`, `is_user_defined`, `abnormality_id`) VALUES (7, 6, 4, NULL, '检查虫害', '用户自定义任务', '2026-03-19', NULL, 'OVERDUE', '2026-03-18 04:10:08', '2026-04-02 18:00:21', 0, NULL, '2026-03-19 13:00:00', 1, NULL);
COMMIT;

-- ----------------------------
-- Table structure for content_reports
-- ----------------------------
DROP TABLE IF EXISTS `content_reports`;
CREATE TABLE `content_reports` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '举报记录ID，主键',
  `post_id` bigint NOT NULL COMMENT '被举报帖子ID',
  `reporter_id` bigint NOT NULL COMMENT '举报人用户ID',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '举报原因',
  `status` enum('PENDING','REVIEWED','RESOLVED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '处理状态：PENDING-待审核，REVIEWED-已审核，RESOLVED-已解决',
  `reviewed_by` bigint DEFAULT NULL COMMENT '审核人用户ID',
  `reviewed_at` timestamp NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `reporter_id` (`reporter_id`),
  KEY `reviewed_by` (`reviewed_by`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `content_reports_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `knowledge_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `content_reports_ibfk_2` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `content_reports_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='内容举报表';

-- ----------------------------
-- Records of content_reports
-- ----------------------------
BEGIN;
INSERT INTO `content_reports` (`id`, `post_id`, `reporter_id`, `reason`, `status`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES (1, 2, 4, '内容不够详细，缺乏实用性', 'REVIEWED', 1, '2026-01-02 16:00:00', '2026-01-03 16:01:24');
INSERT INTO `content_reports` (`id`, `post_id`, `reporter_id`, `reason`, `status`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES (2, 5, 2, '感觉他说的不对', 'RESOLVED', 1, '2026-03-19 18:10:28', '2026-03-19 17:56:43');
INSERT INTO `content_reports` (`id`, `post_id`, `reporter_id`, `reason`, `status`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES (3, 5, 2, '还是不对正确我感觉', 'RESOLVED', 1, '2026-03-19 18:14:10', '2026-03-19 18:13:57');
INSERT INTO `content_reports` (`id`, `post_id`, `reporter_id`, `reason`, `status`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES (4, 5, 2, '12', 'RESOLVED', 1, '2026-03-19 18:22:47', '2026-03-19 18:15:35');
COMMIT;

-- ----------------------------
-- Table structure for knowledge_posts
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_posts`;
CREATE TABLE `knowledge_posts` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '知识帖子ID，主键',
  `author_id` bigint NOT NULL COMMENT '作者用户ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子内容',
  `tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标签（如#浇水技巧）',
  `is_featured` tinyint DEFAULT '0' COMMENT '是否推荐：0-否，1-是',
  `like_count` int DEFAULT '0' COMMENT '点赞数量',
  `status` enum('ACTIVE','REPORTED','DELETED','PENDING','REJECTED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_tag` (`tag`),
  KEY `idx_is_featured` (`is_featured`),
  KEY `idx_like_count` (`like_count`),
  CONSTRAINT `knowledge_posts_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='植物知识分享表';

-- ----------------------------
-- Records of knowledge_posts
-- ----------------------------
BEGIN;
INSERT INTO `knowledge_posts` (`id`, `author_id`, `title`, `content`, `tag`, `is_featured`, `like_count`, `status`, `created_at`, `updated_at`) VALUES (1, 2, '樱花树春季养护全攻略', '春季是樱花树生长的关键时期，需要注意以下几点：1. 及时浇水，保持土壤湿润；2. 花后及时修剪，去除残花；3. 施用氮磷钾复合肥；4. 注意蚜虫', '#樱花养护', 0, 7, 'ACTIVE', '2026-01-03 16:01:24', '2026-01-03 16:01:24');
INSERT INTO `knowledge_posts` (`id`, `author_id`, `title`, `content`, `tag`, `is_featured`, `like_count`, `status`, `created_at`, `updated_at`) VALUES (2, 3, '银杏树的四季管理要点', '银杏树是优秀的园林树种，四季管理要点：春季注意防风，夏季适当浇水，秋季及时清理落叶，冬季做好防寒措施。银杏树生长缓慢，需要耐心养护。', '#银杏养护', 1, 22, 'ACTIVE', '2026-01-03 16:01:24', '2026-03-17 09:48:30');
INSERT INTO `knowledge_posts` (`id`, `author_id`, `title`, `content`, `tag`, `is_featured`, `like_count`, `status`, `created_at`, `updated_at`) VALUES (3, 6, '校园植物认养的意义与价值', '参与校园植物认养不仅能美化环境，还能培养我们的责任感和环保意识。通过亲手养护植物，我们能更深入地了解植物的生长规律，体验生命的奇', '#认养意义', 0, 6, 'ACTIVE', '2026-01-03 16:01:24', '2026-01-03 16:01:24');
INSERT INTO `knowledge_posts` (`id`, `author_id`, `title`, `content`, `tag`, `is_featured`, `like_count`, `status`, `created_at`, `updated_at`) VALUES (4, 2, '浇水的正确方法', '浇水不是越多越好！要根据植物种类、季节、天气来调整。一般原则：见干见湿，浇则浇透。避免中午高温时浇水，最好选择早晨或傍晚。', '#浇水技巧', 0, 6, 'ACTIVE', '2026-01-03 16:01:24', '2026-01-03 16:01:24');
INSERT INTO `knowledge_posts` (`id`, `author_id`, `title`, `content`, `tag`, `is_featured`, `like_count`, `status`, `created_at`, `updated_at`) VALUES (5, 4, '多肉植物的日常养护技巧', '多肉植物以其肥厚多汁的叶片和顽强的生命力深受喜爱，日常养护需注意以下几点：\n光照：多肉大多喜光，春秋冬三季可给予充足直射光，夏季需遮阴避免暴晒，防止叶片灼伤。\n浇水：遵循 “干透浇透” 原则，待土壤完全干透后再浇透，避免频繁浇水导致烂根；空气干燥时可向植株周围喷雾增湿，勿直接喷在叶片上。\n土壤：选用疏松透气的颗粒土（如泥炭土 + 珍珠岩 + 火山石按 3:2:1 比例混合），保证排水性，防止积水。\n温度：适宜生长温度为 15-28℃，冬季需保持 5℃以上，避免冻伤；夏季高温时注意通风降温。\n常见问题：若叶片发软发皱，多为缺水；若叶片透明化水，多为浇水过多烂根，需及时脱盆修剪烂根并重新栽种。', '#多肉植物#室内绿植#养护指南', 0, 4, 'ACTIVE', '2026-02-27 01:07:59', '2026-02-27 01:07:59');
INSERT INTO `knowledge_posts` (`id`, `author_id`, `title`, `content`, `tag`, `is_featured`, `like_count`, `status`, `created_at`, `updated_at`) VALUES (6, 4, '绿萝养护心得', '绿萝是典型的懒人友好型植物，耐阴、好养活，适合新手。\n光照：放在散光处，避免阳光直射，不然叶子容易发黄、灼伤。\n浇水：见干见湿，土表干了再浇透，别积水，否则容易烂根。\n温度：喜温暖，冬天注意防冻，别放在风口。\n施肥：生长期偶尔浇点稀释的营养液，叶片会更油绿茂密。\n特点：可以土培也可以水培，枝条长长了还能垂吊或爬墙，净化空气效果也不错。\n', '养护心得', 0, 4, 'ACTIVE', '2026-03-03 11:27:51', '2026-03-03 11:27:51');
COMMIT;

-- ----------------------------
-- Table structure for operation_logs
-- ----------------------------
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '操作日志ID',
  `user_id` bigint DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作人姓名',
  `operator_role` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作人角色',
  `module` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所属模块',
  `operation_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作类型',
  `operation_desc` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作描述',
  `operation_content` json DEFAULT NULL COMMENT '操作内容(JSON)',
  `operation_result` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作结果(SUCCESS/FAILURE)',
  `error_msg` varchar(2000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '错误信息',
  `ip_address` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户代理',
  `execution_time` bigint DEFAULT NULL COMMENT '执行时长(ms)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `related_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关联业务ID',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_module` (`module`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_related_id` (`related_id`),
  KEY `idx_operator_name` (`operator_name`)
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统操作日志表';

-- ----------------------------
-- Records of operation_logs
-- ----------------------------
BEGIN;
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (1, 1, 'admin', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 12, \"name\": \"桃花树\", \"family\": \"蔷薇科\", \"number\": 0, \"region\": \"和园1号宿舍\", \"status\": \"ADOPTED\", \"species\": \"桃树\", \"careTips\": \"养护时要注重虫害，生病等情况\", \"imageUrls\": \"/api/profile/a5b57cca-0ac8-453a-b9d3-dd45266f42e1.jpg\", \"plantCode\": \"P983265\", \"description\": \"比较好养活\", \"plantingYear\": {\"leap\": true, \"value\": 2020}, \"careDifficulty\": 3, \"lightRequirement\": \"全日照\", \"locationDescription\": \"宿舍挨着河的\"}]', 'SUCCESS', NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1, '2026-03-05 14:45:11', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (2, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 2, '2026-03-05 15:12:10', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (3, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 3, '2026-03-05 15:12:12', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (4, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 4, '2026-03-05 15:12:13', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (5, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 5, '2026-03-05 15:14:53', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (6, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 1, '2026-03-05 15:15:00', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (7, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 2, '2026-03-05 15:15:55', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (8, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 3, '2026-03-05 15:17:27', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (9, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 4, '2026-03-05 15:17:47', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (10, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 5, '2026-03-05 15:18:21', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (11, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 32, '2026-03-05 15:18:28', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (12, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败: java.io.FileNotFoundException: /private/var/folders/yn/tm4c1q453vv0ry9kr_0dmx_w0000gn/T/tomcat.8080.12589939140554112180/work/Tomcat/localhost/api/./uploads/53d0c4c5-3ee6-45e2-880f-1965f1277ce4_c0ecaed7db5d71997aee442723bf297c.png (No such file or directory)', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 34, '2026-03-05 15:29:13', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (13, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败: java.io.FileNotFoundException: /private/var/folders/yn/tm4c1q453vv0ry9kr_0dmx_w0000gn/T/tomcat.8080.12589939140554112180/work/Tomcat/localhost/api/./uploads/7426c6af-3e2a-4d20-b45e-a1f5cbde0958_c0ecaed7db5d71997aee442723bf297c.png (No such file or directory)', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 24, '2026-03-05 15:29:36', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (14, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败: java.io.FileNotFoundException: /private/var/folders/yn/tm4c1q453vv0ry9kr_0dmx_w0000gn/T/tomcat.8080.12589939140554112180/work/Tomcat/localhost/api/./uploads/21478286-b442-4167-ae21-b2b4e6a39536_c0ecaed7db5d71997aee442723bf297c.png (No such file or directory)', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 24, '2026-03-05 15:30:32', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (15, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '图片上传失败: java.io.FileNotFoundException: /private/var/folders/yn/tm4c1q453vv0ry9kr_0dmx_w0000gn/T/tomcat.8080.12589939140554112180/work/Tomcat/localhost/api/./uploads/080137d9-e97f-4756-8e05-377cbc856193_c0ecaed7db5d71997aee442723bf297c.png (No such file or directory)', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 3, '2026-03-05 15:30:48', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (16, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '\n### Error updating database.  Cause: java.sql.SQLException: Data truncated for column \'abnormality_type\' at row 1\n### The error may exist in com/schoolplant/mapper/PlantAbnormalityMapper.java (best guess)\n### The error may involve com.schoolplant.mapper.PlantAbnormalityMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO plant_abnormalities  ( plant_id, reporter_id,  abnormality_type, description, image_urls, suggested_solution, status,        created_at, updated_at )  VALUES (  ?, ?,  ?, ?, ?, ?, ?,        ?, ?  )\n### Cause: java.sql.SQLException: Data truncated for column \'abnormality_type\' at row 1\n; Data truncated for column \'abnormality_type\' at row 1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 3, '2026-03-05 15:31:49', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (17, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '\n### Error updating database.  Cause: java.sql.SQLException: Data truncated for column \'status\' at row 1\n### The error may exist in com/schoolplant/mapper/PlantAbnormalityMapper.java (best guess)\n### The error may involve com.schoolplant.mapper.PlantAbnormalityMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO plant_abnormalities  ( plant_id, reporter_id,  abnormality_type, description, image_urls, suggested_solution, status,        created_at, updated_at )  VALUES (  ?, ?,  ?, ?, ?, ?, ?,        ?, ?  )\n### Cause: java.sql.SQLException: Data truncated for column \'status\' at row 1\n; Data truncated for column \'status\' at row 1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 4, '2026-03-05 15:33:00', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (18, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'FAILURE', '\n### Error updating database.  Cause: java.sql.SQLException: Data truncated for column \'status\' at row 1\n### The error may exist in com/schoolplant/mapper/PlantAbnormalityMapper.java (best guess)\n### The error may involve com.schoolplant.mapper.PlantAbnormalityMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO plant_abnormalities  ( plant_id, reporter_id,  abnormality_type, description, image_urls, suggested_solution, status,        created_at, updated_at )  VALUES (  ?, ?,  ?, ?, ?, ?, ?,        ?, ?  )\n### Cause: java.sql.SQLException: Data truncated for column \'status\' at row 1\n; Data truncated for column \'status\' at row 1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 5, '2026-03-05 15:33:28', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (19, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 5, '2026-03-05 15:34:53', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (20, 1, 'admin', 'ADMIN', 'ABNORMALITY', 'UPDATE', '分派工单', '[3, 5]', 'SUCCESS', NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 3, '2026-03-05 15:43:31', '3');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (21, 1, 'admin', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 12, \"name\": \"桃花树\", \"family\": \"蔷薇科\", \"number\": 0, \"region\": \"和园1号宿舍\", \"status\": \"ADOPTED\", \"species\": \"桃树\", \"careTips\": \"养护时要注重虫害，生病等情况\", \"imageUrls\": \"/api/profile/a5b57cca-0ac8-453a-b9d3-dd45266f42e1.jpg\", \"plantCode\": \"P983265\", \"description\": \"比较好养活\", \"plantingYear\": {\"leap\": true, \"value\": 2020}, \"careDifficulty\": 5, \"lightRequirement\": \"全日照\", \"locationDescription\": \"宿舍挨着河的\"}]', 'SUCCESS', NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 2, '2026-03-05 16:04:31', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (22, 1, 'admin', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 11, \"name\": \"Test Plant 5d7ad56c\", \"number\": 0, \"status\": \"AVAILABLE\", \"species\": \"Species_72348b\", \"imageUrls\": \"\", \"plantCode\": \"P-8eaf3e\", \"description\": \"A test plant\", \"plantingYear\": {\"leap\": false, \"value\": 2022}, \"careDifficulty\": 2, \"lightRequirement\": \"全日照\", \"waterRequirement\": \"高\", \"locationDescription\": \"Location_1abf82\"}]', 'SUCCESS', NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 3, '2026-03-05 16:05:42', '11');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (23, 4, 'zhangwei', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 53, '2026-03-05 16:30:40', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (24, 1, 'admin', 'ADMIN', 'ABNORMALITY', 'UPDATE', '分派工单', '[4, 5]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 53, '2026-03-05 16:32:35', '4');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (25, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 3, '2026-03-05 17:21:13', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (26, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 5, '2026-03-05 17:26:10', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (27, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 3, '2026-03-05 17:26:45', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (28, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 3, '2026-03-05 17:29:42', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (29, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 3, '2026-03-05 17:29:58', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (30, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 3, '2026-03-05 17:30:07', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (31, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 5, '2026-03-05 17:30:12', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (32, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 5, '2026-03-05 17:31:45', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (33, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 4, '2026-03-05 17:32:03', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (34, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 13, '2026-03-05 17:32:24', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (35, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 34, '2026-03-05 17:33:43', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (36, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 34, '2026-03-05 17:33:54', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (37, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 12, '2026-03-05 17:34:06', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (38, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 21, '2026-03-05 17:36:51', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (39, 1, '张管理员', 'ADMIN', 'SYSTEM', 'UPDATE', '更新系统参数', '[{\"key\": \"CURRENT_CYCLE\", \"value\": \"2026-Cycle1\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 34, '2026-03-05 17:38:38', 'CURRENT_CYCLE');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (40, 1, '张管理员', 'ADMIN', 'ACHIEVEMENT', 'UPDATE', '生成周期报告', '[\"2024-Cycle1\"]', 'FAILURE', '\n### Error updating database.  Cause: java.sql.SQLException: Field \'plant_id\' doesn\'t have a default value\n### The error may exist in com/schoolplant/mapper/AchievementMapper.java (best guess)\n### The error may involve com.schoolplant.mapper.AchievementMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO achievements  ( user_id,    tasks_completed, total_tasks, task_completion_rate, adoption_duration_days, plant_health_score, composite_score, is_outstanding,  adoption_cycle, created_at, updated_at )  VALUES (  ?,    ?, ?, ?, ?, ?, ?, ?,  ?, ?, ?  )\n### Cause: java.sql.SQLException: Field \'plant_id\' doesn\'t have a default value\n; Field \'plant_id\' doesn\'t have a default value', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 22, '2026-03-05 17:48:19', '2024-Cycle1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (41, 1, '张管理员', 'ADMIN', 'ACHIEVEMENT', 'UPDATE', '生成周期报告', '[\"2023-Cycle2\"]', 'FAILURE', '\n### Error updating database.  Cause: java.sql.SQLException: Field \'plant_id\' doesn\'t have a default value\n### The error may exist in com/schoolplant/mapper/AchievementMapper.java (best guess)\n### The error may involve com.schoolplant.mapper.AchievementMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO achievements  ( user_id,    tasks_completed, total_tasks, task_completion_rate, adoption_duration_days, plant_health_score, composite_score, is_outstanding,  adoption_cycle, created_at, updated_at )  VALUES (  ?,    ?, ?, ?, ?, ?, ?, ?,  ?, ?, ?  )\n### Cause: java.sql.SQLException: Field \'plant_id\' doesn\'t have a default value\n; Field \'plant_id\' doesn\'t have a default value', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 55, '2026-03-05 17:52:57', '2023-Cycle2');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (42, 1, '张管理员', 'ADMIN', 'ACHIEVEMENT', 'UPDATE', '生成周期报告', '[\"2024-Cycle1\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 3, '2026-03-06 16:55:15', '2024-Cycle1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (43, 1, '张管理员', 'ADMIN', 'ACHIEVEMENT', 'UPDATE', '生成周期报告', '[\"2024-Cycle1\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 2, '2026-03-06 16:55:21', '2024-Cycle1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (44, 1, '张管理员', 'ADMIN', 'ACHIEVEMENT', 'UPDATE', '生成周期报告', '[\"2024-Cycle1\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 2, '2026-03-06 16:57:34', '2024-Cycle1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (45, 1, '张管理员', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 12, \"name\": \"桃花树\", \"family\": \"蔷薇科\", \"number\": 0, \"region\": \"和园1号宿舍\", \"status\": \"ADOPTED\", \"species\": \"桃树\", \"careTips\": \"养护时要注重虫害，生病等情况\", \"imageUrls\": \"/api/profile/7737f66e-d5ab-4ab6-b018-e96d44034fc7.jpg\", \"plantCode\": \"P983265\", \"description\": \"比较好养活\", \"plantingYear\": {\"leap\": true, \"value\": 2020}, \"careDifficulty\": 5, \"lightRequirement\": \"全日照\", \"locationDescription\": \"宿舍挨着河的\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 2, '2026-03-07 16:14:42', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (46, 4, '张炜', 'USER', 'KNOWLEDGE', 'INSERT', '发布帖子评论', '[{\"id\": 1, \"postId\": 1, \"userId\": 4, \"content\": \"做的好\", \"createdAt\": \"2026-03-12 16:42:01.984435\", \"updatedAt\": \"2026-03-12 16:42:01.985241\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', 2, '2026-03-12 16:42:02', '1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (47, 4, '张炜', 'USER', 'KNOWLEDGE', 'INSERT', '发布帖子评论', '[{\"id\": 1, \"postId\": 1, \"userId\": 4, \"content\": \"感觉说的好\\n\", \"createdAt\": \"2026-03-12 16:58:38.927975\", \"updatedAt\": \"2026-03-12 16:58:38.929060\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', 1, '2026-03-12 16:58:39', '1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (48, 3, '何杰', 'USER', 'KNOWLEDGE', 'INSERT', '发布帖子评论', '[{\"id\": 2, \"postId\": 1, \"userId\": 3, \"content\": \"我也觉得\", \"parentId\": 1, \"createdAt\": \"2026-03-12 16:58:59.944069\", \"updatedAt\": \"2026-03-12 16:58:59.944177\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0.1 Mobile/15E148 Safari/604.1', 3, '2026-03-12 16:59:00', '1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (49, 1, '张管理员', 'ADMIN', 'ACHIEVEMENT', 'UPDATE', '生成周期报告', '[\"2024-Cycle1\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 3, '2026-03-12 17:14:35', '2024-Cycle1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (50, 4, '张炜', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', 3, '2026-03-16 12:05:20', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (51, 1, '张管理员', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 4, \"name\": \"紫薇树\", \"family\": \"千屈菜科\", \"number\": 23, \"region\": \"南校区\", \"status\": \"ADOPTED\", \"species\": \"Lagerstroemia indica\", \"imageUrls\": \"/api/profile/fba95cc1-a42b-4898-bd7e-10e367bc1da3.jpg\", \"plantCode\": \"PLT004\", \"description\": \"夏季开花，花期长，耐旱耐热，需要定期\", \"plantingYear\": {\"leap\": false, \"value\": 2021}, \"careDifficulty\": 3, \"lightRequirement\": \"全日照\", \"waterRequirement\": \"中等\", \"locationDescription\": \"南校区运动场边\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', 4, '2026-03-16 17:04:16', '4');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (74, 1, '张管理员', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 12, \"name\": \"桃花树\", \"family\": \"蔷薇科\", \"number\": 0, \"region\": \"和园1号宿舍\", \"status\": \"ADOPTED\", \"species\": \"桃树\", \"careTips\": \"养护时要注重虫害，生病等情况\", \"imageUrls\": \"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/e9ae351b-03bb-42cf-bddd-a19cdb62545a.jpg\", \"plantCode\": \"P983265\", \"description\": \"比较好养活\", \"plantingYear\": {\"leap\": true, \"value\": 2020}, \"careDifficulty\": 5, \"lightRequirement\": \"全日照\", \"locationDescription\": \"宿舍挨着河的\"}]', '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', NULL, '2026-03-16 18:20:25', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (75, 1, '张管理员', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 4, \"name\": \"紫薇树\", \"family\": \"千屈菜科\", \"number\": 23, \"region\": \"南校区\", \"status\": \"ADOPTED\", \"species\": \"Lagerstroemia indica\", \"imageUrls\": \"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/6f37e874-c04f-4dae-b517-0794af1cde3b.jpg\", \"plantCode\": \"PLT004\", \"description\": \"夏季开花，花期长，耐旱耐热，需要定期\", \"plantingYear\": {\"leap\": false, \"value\": 2021}, \"careDifficulty\": 3, \"lightRequirement\": \"全日照\", \"waterRequirement\": \"中等\", \"locationDescription\": \"南校区运动场边\"}]', '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', NULL, '2026-03-16 18:22:33', '4');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (76, 1, '张管理员', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 2, \"name\": \"银杏树\", \"family\": \"银杏科\", \"number\": 12, \"region\": \"东校区\", \"status\": \"AVAILABLE\", \"species\": \"Ginkgo biloba\", \"imageUrls\": \"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/d34da890-dda0-4306-8bbd-a1b14adcb794.jpg\", \"plantCode\": \"PLT002\", \"description\": \"古老树种，秋季叶片金黄，抗污染能力强，适合\", \"plantingYear\": {\"leap\": false, \"value\": 2018}, \"careDifficulty\": 2, \"lightRequirement\": \"全日照\", \"waterRequirement\": \"低\", \"locationDescription\": \"东校区教学楼A栋旁\"}]', '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', NULL, '2026-03-16 18:23:55', '2');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (77, 1, '张管理员', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 3, \"name\": \"桂花树\", \"family\": \"木犀科\", \"number\": 20, \"region\": \"西校区\", \"status\": \"AVAILABLE\", \"species\": \"Osmanthus fragrans\", \"imageUrls\": \"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/1f36634f-aa07-4be1-a241-6474a93680ea.jpg\", \"plantCode\": \"PLT003\", \"description\": \"常绿灌木，秋季开花，香气浓郁，需要定期\", \"plantingYear\": {\"leap\": false, \"value\": 2019}, \"careDifficulty\": 2, \"lightRequirement\": \"半阴\", \"waterRequirement\": \"中等\", \"locationDescription\": \"西校区宿舍区花园\"}]', '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', NULL, '2026-03-16 18:24:08', '3');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (78, 3, '何杰', 'USER', 'ADOPTION', 'INSERT', '提交认养申请', '[{\"plantId\": 2, \"contactPhone\": \"13800138003\", \"careExperience\": \"我家养了10年的老银杏树，我一直跟着学这干。\", \"adoptionPeriodMonths\": 10}]', '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', NULL, '2026-03-16 18:26:05', '2');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (79, 1, '张管理员', 'ADMIN', 'ADOPTION', 'AUDIT', '审核认养申请', '[{\"id\": 11, \"action\": \"PASS\", \"comment\": \"很好\"}]', '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', NULL, '2026-03-16 18:26:23', '11');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (80, 3, '何杰', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', NULL, '2026-03-16 18:37:42', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (81, 1, '张管理员', 'ADMIN', 'ABNORMALITY', 'UPDATE', '分派工单', '[6, 5]', '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', NULL, '2026-03-16 18:46:45', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (82, 1, '张管理员', 'ADMIN', 'ABNORMALITY', 'UPDATE', '分派工单', '[5, 5]', '成功', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', NULL, '2026-03-16 18:46:50', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (83, 1, '张管理员', 'ADMIN', 'KNOWLEDGE', 'UPDATE', '推荐知识帖子', '[2, true]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 6, '2026-03-17 09:48:42', '2');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (84, 1, '张管理员', 'ADMIN', 'KNOWLEDGE', 'UPDATE', '推荐知识帖子', '[4, false]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 3, '2026-03-17 09:48:43', '4');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (85, 1, '张管理员', 'ADMIN', 'KNOWLEDGE', 'UPDATE', '推荐知识帖子', '[3, false]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 4, '2026-03-17 09:48:44', '3');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (86, 1, '张管理员', 'ADMIN', 'KNOWLEDGE', 'UPDATE', '推荐知识帖子', '[1, false]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 6, '2026-03-17 09:48:44', '1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (87, 9, '何炜', 'USER', 'ADOPTION', 'INSERT', '提交认养申请', '[{\"plantId\": 3, \"contactPhone\": \"13800138008\", \"careExperience\": \"12345678HIUEWHFUWEHFW\", \"adoptionPeriodMonths\": 6}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 10, '2026-03-17 11:18:45', '3');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (88, 1, '张管理员', 'ADMIN', 'ADOPTION', 'AUDIT', '审核认养申请', '[{\"id\": 12, \"action\": \"REJECT\", \"comment\": \"看不懂你说的什么\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 20, '2026-03-17 11:19:18', '12');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (89, 5, '陈园艺师', 'MAINTAINER', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 5, \"name\": \"竹子\", \"family\": \"禾本科\", \"number\": 28, \"region\": \"北校区\", \"status\": \"AVAILABLE\", \"species\": \"Bambusa multiplex\", \"imageUrls\": \"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/5b8424d1-351c-4fe0-82ef-d22faa4b61ee.jpg\", \"plantCode\": \"PLT005\", \"description\": \"丛生竹，生长迅速，需要控制蔓延，定期疏笋。\", \"plantingYear\": {\"leap\": false, \"value\": 2017}, \"careDifficulty\": 2, \"lightRequirement\": \"半阴\", \"waterRequirement\": \"高\", \"locationDescription\": \"北校区湖边\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', 29, '2026-03-17 17:02:35', '5');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (90, 5, '陈园艺师', 'MAINTAINER', 'PLANT', 'INSERT', '新增植物', '[{\"name\": \"测试植物\", \"region\": \"测试区域\", \"species\": \"测试品种\", \"plantCode\": \"TEST-CHEN-PLANT-001\", \"careDifficulty\": 1, \"locationDescription\": \"测试位置\"}]', 'SUCCESS', NULL, '127.0.0.1', 'curl/8.7.1', 8, '2026-03-17 17:04:57', '测试植物');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (91, 5, '陈园艺师', 'MAINTAINER', 'ABNORMALITY', 'UPDATE', '标记处理失败', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', 494, '2026-03-17 17:43:03', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (92, 4, '张炜', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 2879, '2026-03-18 10:26:35', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (93, 4, '张炜', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 2900, '2026-03-18 10:49:33', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (94, 4, '张炜', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 1906, '2026-03-18 10:50:17', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (95, 4, '张炜', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 3540, '2026-03-18 11:33:20', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (96, 4, '张炜', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 2506, '2026-03-18 15:11:53', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (97, 4, '张炜', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 1739, '2026-03-18 15:12:28', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (98, 5, '陈园艺师', 'MAINTAINER', 'ABNORMALITY', 'UPDATE', '处理工单', '[6, \"拔出叶子进行观察\", \"无\", \"好了\", null]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', 15, '2026-03-18 15:14:12', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (99, 1, '张卫', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 1, \"name\": \"樱花树\", \"family\": \"蔷薇科\", \"number\": 10, \"region\": \"中央校区\", \"status\": \"ADOPTED\", \"species\": \"Prunus serrulata\", \"imageUrls\": \"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/5f134931-3352-44ac-bb97-ed6609fa8671.jpg\", \"plantCode\": \"PLT001\", \"description\": \"日本晚樱，春季开花，花期3-4月，需要\", \"plantingYear\": {\"leap\": true, \"value\": 2020}, \"careDifficulty\": 3, \"lightRequirement\": \"全日照\", \"waterRequirement\": \"中等\", \"locationDescription\": \"主校区图书馆前广场\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 24, '2026-03-19 17:47:50', '1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (100, 2, '王小明', 'USER', 'KNOWLEDGE', 'INSERT', '举报知识帖子', '[5, \"感觉他说的不对\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 11, '2026-03-19 17:56:43', '5');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (101, 2, '王小明', 'USER', 'ADOPTION', 'INSERT', '提交认养申请', '[{\"plantId\": 8, \"contactPhone\": \"13800138002\", \"careExperience\": \"123132132131231232123123\", \"adoptionPeriodMonths\": 2}]', 'FAILURE', '您已达到认养上限 (1 株)', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 20, '2026-03-19 18:02:21', '8');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (102, 2, '王小明', 'USER', 'ABNORMALITY', 'INSERT', '上报异常', NULL, 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 7520, '2026-03-19 18:03:31', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (103, 1, '张卫', 'ADMIN', 'ACHIEVEMENT', 'UPDATE', '生成周期报告', '[\"2023-Cycle2\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 80, '2026-03-19 18:07:13', '2023-Cycle2');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (104, 1, '张卫', 'ADMIN', 'ACHIEVEMENT', 'UPDATE', '生成周期报告', '[\"2023-Cycle2\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 98, '2026-03-19 18:07:20', '2023-Cycle2');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (105, 1, '张卫', 'ADMIN', 'SYSTEM', 'UPDATE', '处理内容举报', '[2, \"IGNORE\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 11, '2026-03-19 18:10:28', '2');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (106, 2, '王小明', 'USER', 'KNOWLEDGE', 'INSERT', '举报知识帖子', '[5, \"还是不对正确我感觉\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 7, '2026-03-19 18:13:57', '5');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (107, 1, '张卫', 'ADMIN', 'SYSTEM', 'UPDATE', '处理内容举报', '[3, \"IGNORE\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 3, '2026-03-19 18:14:10', '3');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (108, 2, '王小明', 'USER', 'KNOWLEDGE', 'INSERT', '举报知识帖子', '[5, \"12\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 9, '2026-03-19 18:15:35', '5');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (109, 1, '张卫', 'ADMIN', 'SYSTEM', 'UPDATE', '处理内容举报', '[4, \"IGNORE\", \"经核实，改帖子无违反社区规则\"]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 32, '2026-03-19 18:22:47', '4');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (110, 2, '王小明', 'USER', 'ADOPTION', 'UPDATE', '完成认养并提交成果', '[1]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 63, '2026-03-19 18:47:50', '1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (111, 2, '王小明', 'USER', 'ADOPTION', 'INSERT', '提交认养申请', '[{\"plantId\": 1, \"contactPhone\": \"13800138002\", \"careExperience\": \"我前面就是养得这个，我想再继续照顾他，希望可以。\", \"adoptionPeriodMonths\": 6}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 31, '2026-03-19 19:00:09', '1');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (112, 1, '张卫', 'ADMIN', 'ADOPTION', 'AUDIT', '审核认养申请', '[{\"id\": 13, \"action\": \"PASS\", \"comment\": \"\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 24, '2026-03-19 19:00:20', '13');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (113, 1, '张卫', 'ADMIN', 'USER', 'UPDATE', '修改用户', '[{\"id\": 9, \"email\": \"admin@test.com\", \"phone\": \"13800000001\", \"roleId\": 2, \"status\": 1}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 10, '2026-03-20 10:00:37', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (114, 8, '张强', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 13, \"name\": \"测试植物\", \"family\": \"蔷薇科\", \"number\": 0, \"region\": \"测试区域\", \"status\": \"AVAILABLE\", \"species\": \"测试品种\", \"careTips\": \"定期施肥，定期浇水，定期除虫\", \"imageUrls\": \"/images/default-plant.png\", \"plantCode\": \"TEST-CHEN-PLANT-001\", \"growthCycle\": \"春天开花\", \"plantingYear\": {\"leap\": false, \"value\": 2026}, \"careDifficulty\": 1, \"lightRequirement\": \"半阴\", \"waterRequirement\": \"中\", \"locationDescription\": \"测试位置\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 28, '2026-03-20 10:14:17', '13');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (115, 8, '张强', 'ADMIN', 'PLANT', 'UPDATE', '修改植物', '[{\"id\": 13, \"name\": \"测试植物\", \"family\": \"蔷薇科\", \"number\": 0, \"region\": \"测试区域\", \"status\": \"AVAILABLE\", \"species\": \"测试品种\", \"careTips\": \"定期施肥，定期浇水，定期除虫\", \"imageUrls\": \"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/6183dfe8-4570-40ad-8f4a-34e45a2a3539.jpg\", \"plantCode\": \"TEST-CHEN-PLANT-001\", \"growthCycle\": \"春天开花\", \"plantingYear\": {\"leap\": false, \"value\": 2026}, \"careDifficulty\": 1, \"lightRequirement\": \"半阴\", \"waterRequirement\": \"中\", \"locationDescription\": \"测试位置\"}]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 14, '2026-03-20 10:14:38', '13');
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (116, 1, '张卫', 'ADMIN', 'USER', 'DELETE', '删除用户', '[[1]]', 'SUCCESS', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 3, '2026-03-25 18:48:41', NULL);
INSERT INTO `operation_logs` (`id`, `user_id`, `operator_name`, `operator_role`, `module`, `operation_type`, `operation_desc`, `operation_content`, `operation_result`, `error_msg`, `ip_address`, `user_agent`, `execution_time`, `created_at`, `related_id`) VALUES (117, 3, '何杰', 'USER', 'ADOPTION', 'INSERT', '提交认养申请', '[{\"plantId\": 3, \"contactPhone\": \"13800138003\", \"careExperience\": \"气氛娃娃额v额哇v风微风微风份多福多寿我丰富\", \"adoptionPeriodMonths\": 6}]', 'FAILURE', '您已达到认养上限 (1 株)', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Trae/1.107.1 Chrome/142.0.7444.235 Electron/39.2.7 Safari/537.36', 12, '2026-04-02 18:26:07', '3');
COMMIT;

-- ----------------------------
-- Table structure for permissions
-- ----------------------------
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '权限ID，主键',
  `permission_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限标识符（如：plant:view, plant:edit, adoption:approve）',
  `permission_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '权限描述',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '所属模块（user, plant, adoption, task, abnormality, knowledge, achievement, system）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `permission_key` (`permission_key`),
  KEY `idx_module` (`module`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表';

-- ----------------------------
-- Records of permissions
-- ----------------------------
BEGIN;
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (1, 'user:view', '查看用户信息', '查看用户基本信息', 'user', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (2, 'user:edit', '编辑用户信息', '修改个人信息', 'user', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (3, 'user:delete', '删除用户', '禁用或删除用户账号', 'user', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (4, 'user:list', '查看用户列表', '查看所有用户列表', 'user', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (5, 'plant:view', '查看植物信息', '查看植物详细信息', 'plant', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (6, 'plant:create', '创建植物信息', '添加新植物记录', 'plant', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (7, 'plant:edit', '编辑植物信息', '修改植物信息', 'plant', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (8, 'plant:delete', '删除植物信息', '删除植物记录', 'plant', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (9, 'plant:list', '查看植物列表', '浏览所有植物', 'plant', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (10, 'plant:import', '导入植物数据', '批量导入植物信息', 'plant', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (11, 'plant:export', '导出植物数据', '批量导出植物信息', 'plant', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (12, 'adoption:apply', '提交认养申请', '申请认养植物', 'adoption', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (13, 'adoption:view', '查看认养申请', '查看自己的认养申请', 'adoption', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (14, 'adoption:approve', '审核认养申请', '批准或驳回认养申请', 'adoption', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (15, 'adoption:list', '查看认养列表', '查看所有认养申请', 'adoption', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (16, 'adoption:cancel', '取消认养关系', '主动取消认养', 'adoption', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (17, 'adoption:certificate', '生成认养证书', '生成电子认养证书', 'adoption', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (18, 'task:view', '查看养护任务', '查看分配的任务', 'task', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (19, 'task:complete', '完成养护任务', '标记任务为已完成', 'task', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (20, 'task:list', '查看任务列表', '查看所有相关任务', 'task', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (21, 'task:generate', '生成养护任务', '手动或自动创建任务', 'task', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (22, 'abnormality:report', '上报植物异常', '报告植物健康问题', 'abnormality', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (23, 'abnormality:view', '查看异常报告', '查看自己上报的异常', 'abnormality', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (24, 'abnormality:assign', '分配异常处理', '将异常分配给养护员', 'abnormality', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (25, 'abnormality:resolve', '处理异常问题', '标记异常为已解决', 'abnormality', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (26, 'abnormality:list', '查看异常列表', '查看所有异常报告', 'abnormality', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (27, 'knowledge:create', '发布知识帖子', '分享养护经验', 'knowledge', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (28, 'knowledge:view', '查看知识帖子', '阅读知识分享', 'knowledge', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (29, 'knowledge:edit', '编辑知识帖子', '修改自己的帖子', 'knowledge', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (30, 'knowledge:delete', '删除知识帖子', '删除帖子（自己或管理）', 'knowledge', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (31, 'knowledge:like', '点赞知识帖子', '为帖子点赞', 'knowledge', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (32, 'knowledge:feature', '推荐优质内容', '标记为推荐阅读', 'knowledge', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (33, 'knowledge:report', '举报违规内容', '举报不当内容', 'knowledge', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (34, 'achievement:view', '查看认养成果', '查看个人成果统计', 'achievement', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (35, 'achievement:list', '查看成果排行榜', '查看全校成果排名', 'achievement', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (36, 'achievement:evaluate', '评估认养成果', '进行成果评比', 'achievement', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (37, 'achievement:certificate', '生成荣誉证书', '生成优秀养护人证书', 'achievement', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (38, 'system:param:view', '查看系统参数', '查看系统配置', 'system', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (39, 'system:param:edit', '编辑系统参数', '修改系统配置', 'system', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (40, 'system:log:view', '查看操作日志', '查看系统操作记录', 'system', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `permissions` (`id`, `permission_key`, `permission_name`, `description`, `module`, `created_at`, `updated_at`) VALUES (41, 'system:role:manage', '管理角色权限', '配置角色和权限', 'system', '2026-01-03 15:56:15', '2026-01-03 15:56:15');
COMMIT;

-- ----------------------------
-- Table structure for plant_abnormalities
-- ----------------------------
DROP TABLE IF EXISTS `plant_abnormalities`;
CREATE TABLE `plant_abnormalities` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '异常记录ID，主键',
  `plant_id` bigint NOT NULL COMMENT '关联植物ID',
  `reporter_id` bigint NOT NULL COMMENT '上报人用户ID',
  `maintainer_id` bigint DEFAULT NULL COMMENT '分配的养护员ID',
  `abnormality_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '异常类型',
  `urgency` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'MEDIUM' COMMENT '紧急程度: HIGH, MEDIUM, LOW',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '异常详细描述 (可选)',
  `image_urls` json DEFAULT NULL COMMENT '异常图片URL数组（JSON格式）',
  `suggested_solution` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '建议解决方案',
  `status` enum('PENDING','REPORTED','ASSIGNED','RESOLVED','CLOSED','UNRESOLVED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '状态',
  `assigned_at` datetime DEFAULT NULL COMMENT '分派时间',
  `resolution_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '处理说明',
  `materials_used` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '使用材料',
  `effect_evaluation` text COLLATE utf8mb4_unicode_ci COMMENT '效果评估',
  `resolution_image_urls` text COLLATE utf8mb4_unicode_ci COMMENT '处理后照片JSON',
  `resolved_at` timestamp NULL DEFAULT NULL COMMENT '解决时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `overtime_alert_sent` tinyint(1) DEFAULT '0' COMMENT '是否已发送超时提醒',
  `reporter_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '上报人姓名',
  `reporter_contact` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '上报人联系方式',
  `care_task_id` bigint DEFAULT NULL COMMENT '关联的养护任务ID',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '植物具体位置（任意植物上报时必填）',
  PRIMARY KEY (`id`),
  KEY `maintainer_id` (`maintainer_id`),
  KEY `idx_plant_id` (`plant_id`),
  KEY `idx_reporter_id` (`reporter_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `plant_abnormalities_ibfk_1` FOREIGN KEY (`plant_id`) REFERENCES `plants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `plant_abnormalities_ibfk_2` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `plant_abnormalities_ibfk_3` FOREIGN KEY (`maintainer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='植物健康异常表';

-- ----------------------------
-- Records of plant_abnormalities
-- ----------------------------
BEGIN;
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (1, 1, 2, 5, 'PESTS', 'MEDIUM', '樱花树叶片背面发现大量蚜虫，叶片开始卷曲发黄。', NULL, '建议使用吡虫啉溶液喷洒，浓度1:1000，连续喷洒3天，注意保护益虫。', 'UNRESOLVED', NULL, '使用吡虫啉溶液喷洒，浓度1:1000，连续喷洒3天，注意保护益虫。', '吡虫啉溶液喷洒，浓度1:1000，连续喷洒3天', '无效果', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/unresolved/1/b1fe7607-f95f-456a-85e1-bea9382fc44a_c0ecaed7db5d71997aee442723bf297c.png\"]', '2026-03-17 17:43:03', '2026-01-03 16:00:01', '2026-03-17 17:43:03', 1, '王小明', '13800138002', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (2, 4, 2, 5, 'YELLOW_LEAVES', 'MEDIUM', '紫薇树部分叶片出现黄化现象，可能与土壤pH值有关。', NULL, '建议检测土壤pH值，如偏碱可施用硫酸亚铁调节，同时增加有机肥。', 'UNRESOLVED', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-03 16:00:01', '2026-03-18 15:33:43', 0, '王小明', '13800138002', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (3, 6, 4, 5, '病害', 'MEDIUM', '叶子有斑点', '[\"/uploads/624eb8c9-dfcd-46db-a77b-87ba2dca2fcf_c0ecaed7db5d71997aee442723bf297c.png\"]', 'AI分析服务暂时不可用', 'ASSIGNED', '2026-03-05 15:43:31', NULL, NULL, NULL, NULL, NULL, '2026-03-05 15:34:53', '2026-04-02 17:58:25', 1, '张伟', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (4, 6, 4, 5, '病害', 'MEDIUM', '叶子有斑点', '[\"/uploads/d26bd83c-b6ec-400a-bb46-8453cd622d02_c0ecaed7db5d71997aee442723bf297c.png\"]', 'AI分析服务暂时不可用', 'ASSIGNED', '2026-03-05 16:32:35', NULL, NULL, NULL, NULL, NULL, '2026-03-05 16:30:40', '2026-04-02 17:58:25', 1, '张炜', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (5, 6, 4, 5, '病害', 'MEDIUM', '植物看着斑点，我不知道怎么弄', '[\"/uploads/9662bfbc-179e-44a4-a9fa-468619110d3f_c0ecaed7db5d71997aee442723bf297c.png\"]', '识别结果：图片特征不明显，无法可靠判断植物状态（置信度：0.35）\n养护建议：\n1）补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）\n2）描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议\n提示：建议补充清晰近景与叶背照片以提高准确性。', 'ASSIGNED', '2026-03-16 18:46:50', NULL, NULL, NULL, NULL, NULL, '2026-03-16 12:05:20', '2026-04-02 17:58:25', 1, '张炜', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (6, 2, 3, 5, '病害', 'MEDIUM', '看着叶子怪怪的', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/report/2/be82b686-c135-45e6-bbdc-7b2be0b89dde_c0ecaed7db5d71997aee442723bf297c.png\"]', '识别结果：图片特征不明显，无法可靠判断植物状态（置信度：0.35）\n养护建议：\n1）补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）\n2）描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议\n提示：建议补充清晰近景与叶背照片以提高准确性。', 'RESOLVED', '2026-03-16 18:46:45', '拔出叶子进行观察', '无', '好了', '[]', '2026-03-18 15:14:12', '2026-03-16 18:37:41', '2026-03-18 15:14:12', 0, '何杰', '13800138003', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (7, 6, 4, NULL, '病害', 'MEDIUM', '刚觉像是生病了', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/report/12/7055d0b3-6006-4780-b37e-a7c6c044c338_c0ecaed7db5d71997aee442723bf297c.png\"]', '识别结果：图片特征不明显，无法可靠判断植物状态（置信度：0.35）\n养护建议：\n1）补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）\n2）描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议\n提示：建议补充清晰近景与叶背照片以提高准确性。', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-18 10:26:35', '2026-04-02 17:58:25', 0, '张炜', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (8, 6, 4, NULL, '病害', 'MEDIUM', '刚觉像是生病了', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/report/12/63b9f097-bd81-40fa-a82f-ac061b8024f3_c0ecaed7db5d71997aee442723bf297c.png\"]', '识别结果：图片特征不明显，无法可靠判断植物状态（置信度：0.35）\n养护建议：\n1）补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）\n2）描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议\n提示：建议补充清晰近景与叶背照片以提高准确性。', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-18 10:49:33', '2026-04-02 17:58:25', 0, '张炜', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (9, 6, 4, NULL, '病害', 'MEDIUM', '看着 有斑点，我不知道到底是什么问题。', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/report/12/3a92cdfa-aed8-471e-9966-1f27297553c2_c0ecaed7db5d71997aee442723bf297c.png\"]', '识别结果：图片特征不明显，无法可靠判断植物状态（置信度：0.35）\n养护建议：\n1）补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）\n2）描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议\n提示：建议补充清晰近景与叶背照片以提高准确性。', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-18 10:50:17', '2026-04-02 17:58:25', 0, '张炜', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (10, 6, 4, NULL, '病害', 'MEDIUM', '叶子上有黄色斑点，植物看着不健康', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/report/12/df61fc6e-62ec-464e-9060-0be6fcac5133_c0ecaed7db5d71997aee442723bf297c.png\"]', '识别结果：图片特征不明显，无法可靠判断植物状态（置信度：0.35）\n养护建议：\n1）补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）\n2）描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议\n提示：建议补充清晰近景与叶背照片以提高准确性。', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-18 11:33:20', '2026-04-02 17:58:25', 0, '张炜', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (11, 6, 4, NULL, '病害', 'MEDIUM', '叶子上有黄色斑点，植物看着不健康', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/report/12/2e420b7a-b25c-4aa0-800f-3dae9bed36c0_c0ecaed7db5d71997aee442723bf297c.png\"]', '识别结果：图片特征不明显，无法可靠判断植物状态（置信度：0.35）\n养护建议：\n1）补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）\n2）描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议\n提示：建议补充清晰近景与叶背照片以提高准确性。', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-18 15:11:53', '2026-04-02 17:58:25', 0, '张炜', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (12, 6, 4, NULL, '病害', 'MEDIUM', '叶子上有斑点坏死的情况', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/report/12/9670922c-ca14-4e62-8979-ac066db11888_c0ecaed7db5d71997aee442723bf297c.png\"]', '识别结果：图片特征不明显，无法可靠判断植物状态（置信度：0.35）\n养护建议：\n1）补充上传：整体照 + 叶片近景 + 叶背近景（自然光、对焦清晰）\n2）描述症状：是否黄叶、斑点、卷曲、掉叶、虫体等，便于更准确给出建议\n提示：建议补充清晰近景与叶背照片以提高准确性。', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-18 15:12:28', '2026-04-02 17:58:25', 0, '张炜', '13800138004', NULL, NULL);
INSERT INTO `plant_abnormalities` (`id`, `plant_id`, `reporter_id`, `maintainer_id`, `abnormality_type`, `urgency`, `description`, `image_urls`, `suggested_solution`, `status`, `assigned_at`, `resolution_description`, `materials_used`, `effect_evaluation`, `resolution_image_urls`, `resolved_at`, `created_at`, `updated_at`, `overtime_alert_sent`, `reporter_name`, `reporter_contact`, `care_task_id`, `location`) VALUES (13, 1, 2, NULL, '病害', 'MEDIUM', '樱花树叶片背面发现大量蚜虫，叶片开始卷曲发黄', '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/abnormality/report/1/85769689-b8c6-4fea-8d97-08726a050237_c0ecaed7db5d71997aee442723bf297c.png\"]', '判定结果如下：\n\n植物品种Prunus serrulata+异常类型：[症状概述：樱花树叶片背面发现大量蚜虫，叶片开始卷曲发黄；可能诱因：真菌性叶斑病（如炭疽病、褐斑病）或虫害影响，常伴随高湿环境、通风不良、叶面长时间潮湿；初步解决方案：重点检查叶背与枝条是否有虫体/虫卵；可先用清水冲洗或棉签擦拭，如发现蚜虫/红蜘蛛等，可使用对应杀虫剂或肥皂水（低浓度）处理并观察 3-5 天，先隔离异常植株（或与健康植株保持距离），避免交叉感染。（置信度：0.48）]\n\n判定依据说明：\n\n症状特征：根据用户描述（樱花树叶片背面发现大量蚜虫，叶片开始卷曲发黄），结合图片分析显示：图片特征不明显，但结合描述疑似虫害/虫咬导致异常，建议记录并补充环境信息（浇水频率、光照强度、通风情况、近期施肥/换盆、异常出现时间）。\n环境诱因：常见于高湿、通风差、叶面长时间潮湿或密植环境，有助于真菌/虫害发生。\n标准术语：统一表述为“叶斑病类异常”。\n解决建议：重点检查叶背与枝条是否有虫体/虫卵；可先用清水冲洗或棉签擦拭，如发现蚜虫/红蜘蛛等，可使用对应杀虫剂或肥皂水（低浓度）处理并观察 3-5 天，先隔离异常植株（或与健康植株保持距离），避免交叉感染\n如需更具体判定，请补充植物品种及环境描述。\n', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-19 18:03:31', '2026-03-19 18:03:31', 0, '王小明', '13800138002', NULL, NULL);
COMMIT;

-- ----------------------------
-- Table structure for plants
-- ----------------------------
DROP TABLE IF EXISTS `plants`;
CREATE TABLE `plants` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '植物ID，主键',
  `plant_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '植物编号，唯一标识',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '植物名称',
  `species` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '植物品种',
  `number` bigint NOT NULL DEFAULT '0' COMMENT '植物数量',
  `family` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '科属',
  `location_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '位置描述',
  `region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '校园区域（如中央校区、东校区等）',
  `care_difficulty` tinyint NOT NULL DEFAULT '1' COMMENT '养护难度等级（1-5，1为简单，5为困难）',
  `status` enum('AVAILABLE','ADOPTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AVAILABLE' COMMENT '植物状态：AVAILABLE-待认养，ADOPTED-已认养',
  `health_status` enum('HEALTHY','SICK') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'HEALTHY' COMMENT '健康状态：HEALTHY-健康，SICK-生病',
  `planting_year` year DEFAULT NULL COMMENT '种植年份',
  `light_requirement` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '光照需求（全日照、半阴、全阴）',
  `water_requirement` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '水分需求（低、中、高）',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '植物详细描述',
  `care_tips` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '养护要点',
  `growth_cycle` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生长周期',
  `image_urls` json DEFAULT NULL COMMENT '植物图片URL数组（JSON格式）',
  `created_by` bigint NOT NULL COMMENT '创建者用户ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间（软删除）',
  `user_real_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '发布者姓名',
  `user_phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '发布者电话',
  PRIMARY KEY (`id`),
  UNIQUE KEY `plant_code` (`plant_code`),
  KEY `created_by` (`created_by`),
  KEY `idx_status` (`status`),
  KEY `idx_region` (`region`),
  KEY `idx_care_difficulty` (`care_difficulty`),
  KEY `idx_plant_code` (`plant_code`),
  CONSTRAINT `plants_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='植物信息表';

-- ----------------------------
-- Records of plants
-- ----------------------------
BEGIN;
INSERT INTO `plants` (`id`, `plant_code`, `name`, `species`, `number`, `family`, `location_description`, `region`, `care_difficulty`, `status`, `health_status`, `planting_year`, `light_requirement`, `water_requirement`, `description`, `care_tips`, `growth_cycle`, `image_urls`, `created_by`, `created_at`, `updated_at`, `deleted_at`, `user_real_name`, `user_phone`) VALUES (1, 'PLT001', '樱花树', 'Prunus serrulata', 10, '蔷薇科', '主校区图书馆前广场', '中央校区', 3, 'ADOPTED', 'HEALTHY', 2020, '全日照', '中等', '日本晚樱，春季开花，花期3-4月，需要', NULL, NULL, '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/5f134931-3352-44ac-bb97-ed6609fa8671.jpg\"]', 1, '2026-01-03 16:00:01', '2026-03-02 10:47:00', NULL, '张管理员', '13800138001');
INSERT INTO `plants` (`id`, `plant_code`, `name`, `species`, `number`, `family`, `location_description`, `region`, `care_difficulty`, `status`, `health_status`, `planting_year`, `light_requirement`, `water_requirement`, `description`, `care_tips`, `growth_cycle`, `image_urls`, `created_by`, `created_at`, `updated_at`, `deleted_at`, `user_real_name`, `user_phone`) VALUES (2, 'PLT002', '银杏树', 'Ginkgo biloba', 12, '银杏科', '东校区教学楼A栋旁', '东校区', 2, 'ADOPTED', 'HEALTHY', 2018, '全日照', '低', '古老树种，秋季叶片金黄，抗污染能力强，适合', NULL, NULL, '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/d34da890-dda0-4306-8bbd-a1b14adcb794.jpg\"]', 1, '2026-01-03 16:00:01', '2026-03-02 10:47:00', NULL, '张管理员', '13800138001');
INSERT INTO `plants` (`id`, `plant_code`, `name`, `species`, `number`, `family`, `location_description`, `region`, `care_difficulty`, `status`, `health_status`, `planting_year`, `light_requirement`, `water_requirement`, `description`, `care_tips`, `growth_cycle`, `image_urls`, `created_by`, `created_at`, `updated_at`, `deleted_at`, `user_real_name`, `user_phone`) VALUES (3, 'PLT003', '桂花树', 'Osmanthus fragrans', 20, '木犀科', '西校区宿舍区花园', '西校区', 2, 'AVAILABLE', 'HEALTHY', 2019, '半阴', '中等', '常绿灌木，秋季开花，香气浓郁，需要定期', NULL, NULL, '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/1f36634f-aa07-4be1-a241-6474a93680ea.jpg\"]', 1, '2026-01-03 16:00:01', '2026-03-02 10:47:00', NULL, '张管理员', '13800138001');
INSERT INTO `plants` (`id`, `plant_code`, `name`, `species`, `number`, `family`, `location_description`, `region`, `care_difficulty`, `status`, `health_status`, `planting_year`, `light_requirement`, `water_requirement`, `description`, `care_tips`, `growth_cycle`, `image_urls`, `created_by`, `created_at`, `updated_at`, `deleted_at`, `user_real_name`, `user_phone`) VALUES (4, 'PLT004', '紫薇树', 'Lagerstroemia indica', 23, '千屈菜科', '南校区运动场边', '南校区', 3, 'ADOPTED', 'HEALTHY', 2021, '全日照', '中等', '夏季开花，花期长，耐旱耐热，需要定期', NULL, NULL, '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/6f37e874-c04f-4dae-b517-0794af1cde3b.jpg\"]', 1, '2026-01-03 16:00:01', '2026-03-02 10:47:00', NULL, '张管理员', '13800138001');
INSERT INTO `plants` (`id`, `plant_code`, `name`, `species`, `number`, `family`, `location_description`, `region`, `care_difficulty`, `status`, `health_status`, `planting_year`, `light_requirement`, `water_requirement`, `description`, `care_tips`, `growth_cycle`, `image_urls`, `created_by`, `created_at`, `updated_at`, `deleted_at`, `user_real_name`, `user_phone`) VALUES (5, 'PLT005', '竹子', 'Bambusa multiplex', 28, '禾本科', '北校区湖边', '北校区', 2, 'AVAILABLE', 'HEALTHY', 2017, '半阴', '高', '丛生竹，生长迅速，需要控制蔓延，定期疏笋。', NULL, NULL, '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/5b8424d1-351c-4fe0-82ef-d22faa4b61ee.jpg\"]', 1, '2026-01-03 16:00:01', '2026-03-02 10:47:00', NULL, '张管理员', '13800138001');
INSERT INTO `plants` (`id`, `plant_code`, `name`, `species`, `number`, `family`, `location_description`, `region`, `care_difficulty`, `status`, `health_status`, `planting_year`, `light_requirement`, `water_requirement`, `description`, `care_tips`, `growth_cycle`, `image_urls`, `created_by`, `created_at`, `updated_at`, `deleted_at`, `user_real_name`, `user_phone`) VALUES (6, 'P983265', '桃花树', '桃树', 0, '蔷薇科', '宿舍挨着河的', '和园1号宿舍', 5, 'ADOPTED', 'HEALTHY', 2020, '全日照', NULL, '比较好养活', '养护时要注重虫害，生病等情况', NULL, '[\"https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/e9ae351b-03bb-42cf-bddd-a19cdb62545a.jpg\"]', 3, '2026-03-05 11:59:20', '2026-04-02 17:58:25', NULL, '何杰', '13800138003');
COMMIT;

-- ----------------------------
-- Table structure for post_comments
-- ----------------------------
DROP TABLE IF EXISTS `post_comments`;
CREATE TABLE `post_comments` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID，主键',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `user_id` bigint NOT NULL COMMENT '评论用户ID',
  `parent_id` bigint DEFAULT NULL COMMENT '父评论ID（用于回复功能）',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parent_id` (`parent_id`),
  CONSTRAINT `post_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `knowledge_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_comments_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `post_comments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子评论表';

-- ----------------------------
-- Records of post_comments
-- ----------------------------
BEGIN;
INSERT INTO `post_comments` (`id`, `post_id`, `user_id`, `parent_id`, `content`, `created_at`, `updated_at`) VALUES (1, 1, 4, NULL, '感觉说的好\n', '2026-03-12 16:58:39', '2026-03-12 16:58:39');
INSERT INTO `post_comments` (`id`, `post_id`, `user_id`, `parent_id`, `content`, `created_at`, `updated_at`) VALUES (2, 1, 3, 1, '我也觉得', '2026-03-12 16:59:00', '2026-03-12 16:59:00');
COMMIT;

-- ----------------------------
-- Table structure for post_likes
-- ----------------------------
DROP TABLE IF EXISTS `post_likes`;
CREATE TABLE `post_likes` (
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `user_id` bigint NOT NULL COMMENT '点赞用户ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`post_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `post_likes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `knowledge_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子点赞表';

-- ----------------------------
-- Records of post_likes
-- ----------------------------
BEGIN;
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (1, 1, '2026-03-23 17:47:02');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (1, 2, '2026-03-19 17:56:03');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (1, 4, '2026-03-02 11:34:48');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (1, 5, '2026-03-25 18:42:55');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (2, 1, '2026-03-23 17:46:57');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (2, 2, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (2, 3, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (2, 4, '2026-02-27 00:01:27');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (2, 5, '2026-03-17 10:41:57');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (2, 6, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (3, 1, '2026-03-23 17:47:01');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (3, 2, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (3, 3, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (3, 4, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (3, 5, '2026-03-25 18:42:52');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (3, 6, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (4, 1, '2026-03-23 17:47:01');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (4, 2, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (4, 3, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (4, 4, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (4, 5, '2026-03-25 18:42:53');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (4, 6, '2026-01-03 16:01:24');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (5, 1, '2026-03-23 17:47:00');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (5, 2, '2026-03-19 17:56:05');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (5, 4, '2026-03-02 23:36:20');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (5, 5, '2026-03-25 18:42:51');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (6, 1, '2026-03-23 17:46:58');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (6, 2, '2026-03-19 17:56:05');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (6, 4, '2026-03-04 16:51:33');
INSERT INTO `post_likes` (`post_id`, `user_id`, `created_at`) VALUES (6, 5, '2026-03-25 18:42:49');
COMMIT;

-- ----------------------------
-- Table structure for role_permissions
-- ----------------------------
DROP TABLE IF EXISTS `role_permissions`;
CREATE TABLE `role_permissions` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- ----------------------------
-- Records of role_permissions
-- ----------------------------
BEGIN;
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 1, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 2, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 5, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 9, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 12, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 13, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 16, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 18, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 19, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 20, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 22, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 23, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 27, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 28, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 29, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 31, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 33, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 34, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (1, 35, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 1, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 2, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 3, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 4, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 5, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 6, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 7, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 8, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 9, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 10, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 11, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 12, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 13, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 14, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 15, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 16, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 17, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 18, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 19, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 20, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 21, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 22, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 23, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 24, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 25, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 26, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 27, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 28, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 29, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 30, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 31, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 32, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 33, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 34, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 35, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 36, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 37, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 38, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 39, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 40, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (2, 41, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 1, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 5, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 9, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 13, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 15, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 18, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 20, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 23, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 24, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 25, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 26, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 28, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 34, '2026-01-03 15:56:15');
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`) VALUES (3, 35, '2026-01-03 15:56:15');
COMMIT;

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID，主键',
  `role_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色标识符（USER, ADMIN, MAINTAINER）',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '角色描述',
  `is_system_role` tinyint DEFAULT '1' COMMENT '是否系统内置角色：1-是，0-否',
  `status` tinyint DEFAULT '1' COMMENT '角色状态：1-启用，0-禁用',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_key` (`role_key`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- ----------------------------
-- Records of roles
-- ----------------------------
BEGIN;
INSERT INTO `roles` (`id`, `role_key`, `role_name`, `description`, `is_system_role`, `status`, `created_at`, `updated_at`) VALUES (1, 'USER', '普通用户', '学生/教职工，可认养植物、完成任务、分享知识', 1, 1, '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `roles` (`id`, `role_key`, `role_name`, `description`, `is_system_role`, `status`, `created_at`, `updated_at`) VALUES (2, 'ADMIN', '管理员', '园艺社成员，拥有全系统管理权限', 1, 1, '2026-01-03 15:56:15', '2026-01-03 15:56:15');
INSERT INTO `roles` (`id`, `role_key`, `role_name`, `description`, `is_system_role`, `status`, `created_at`, `updated_at`) VALUES (3, 'MAINTAINER', '养护员', '专业养护人员，负责处理植物异常', 1, 1, '2026-01-03 15:56:15', '2026-01-03 15:56:15');
COMMIT;

-- ----------------------------
-- Table structure for system_notifications
-- ----------------------------
DROP TABLE IF EXISTS `system_notifications`;
CREATE TABLE `system_notifications` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '接收用户ID',
  `title` varchar(100) NOT NULL COMMENT '标题',
  `content` text NOT NULL COMMENT '内容',
  `type` varchar(20) DEFAULT 'SYSTEM' COMMENT '类型: SYSTEM, AUDIT, REMINDER',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '是否已读',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统通知表';

-- ----------------------------
-- Records of system_notifications
-- ----------------------------
BEGIN;
INSERT INTO `system_notifications` (`id`, `user_id`, `title`, `content`, `type`, `is_read`, `created_at`) VALUES (1, 3, '认养申请审核通过', '恭喜！您申请认养的植物 [银杏树] 已审核通过，请前往“我的认养”查看。', 'AUDIT', 1, '2026-03-16 18:26:23');
INSERT INTO `system_notifications` (`id`, `user_id`, `title`, `content`, `type`, `is_read`, `created_at`) VALUES (2, 9, '认养申请未通过', '很遗憾，您申请认养的植物 [桂花树] 未通过审核。原因：看不懂你说的什么', 'AUDIT', 1, '2026-03-17 11:19:18');
INSERT INTO `system_notifications` (`id`, `user_id`, `title`, `content`, `type`, `is_read`, `created_at`) VALUES (3, 2, '举报处理反馈', '您举报的帖子《多肉植物的日常养护技巧》经核查，处理结果为：经核实，改帖子无违反社区规则。感谢您的监督！', 'SYSTEM', 1, '2026-03-19 18:22:47');
INSERT INTO `system_notifications` (`id`, `user_id`, `title`, `content`, `type`, `is_read`, `created_at`) VALUES (4, 2, '认养圆满完成', '您对植物《樱花树》的认养已顺利结束，感谢您的悉心照顾！您可以在“认养成果”中查看本次评价。', 'SYSTEM', 1, '2026-03-19 18:47:50');
INSERT INTO `system_notifications` (`id`, `user_id`, `title`, `content`, `type`, `is_read`, `created_at`) VALUES (5, 2, '认养申请审核通过', '恭喜！您申请认养的植物 [樱花树] 已审核通过，请前往“我的认养”查看。', 'AUDIT', 0, '2026-03-19 19:00:20');
COMMIT;

-- ----------------------------
-- Table structure for system_parameters
-- ----------------------------
DROP TABLE IF EXISTS `system_parameters`;
CREATE TABLE `system_parameters` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '参数ID，主键',
  `param_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数键名',
  `param_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数值',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '参数描述',
  `updated_by` bigint NOT NULL COMMENT '最后更新人ID',
  `updated_by_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '最后更新人姓名',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `param_key` (`param_key`),
  KEY `updated_by` (`updated_by`),
  KEY `idx_param_key` (`param_key`),
  CONSTRAINT `system_parameters_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统参数配置表';

-- ----------------------------
-- Records of system_parameters
-- ----------------------------
BEGIN;
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (1, 'ADOPTION_PERIOD_MONTHS', '6', '默认认养周期', 1, '张管理员', '2026-03-18 10:05:01');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (2, 'TASK_GENERATION_DAYS', '7', '自动任务生成间隔天数', 1, '张管理员', '2026-01-25 21:34:13');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (3, 'EVALUATION_START_DATE', '2026-01-01', '成果评比开始日期', 1, '张管理员', '2026-01-25 21:34:13');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (4, 'EVALUATION_END_DATE', '2026-06-30', '成果评比结束日期', 1, '张管理员', '2026-01-25 21:34:14');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (5, 'MIN_TASK_COMPLETION_RATE', '1.00', '优秀养护人最低任务完成率（1.00=100%）', 1, '张管理员', '2026-01-25 21:34:15');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (6, 'ABNORMALITY_REMINDER_HOURS', '48', '异常处理超时提醒小时数', 1, '张管理员', '2026-01-25 21:34:16');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (7, 'MAX_ADOPTIONS_PER_USER', '1', '每个用户最多可认养植物数量', 1, '张管理员', '2026-01-25 21:34:16');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (8, 'TASK_OVERDUE_DAYS', '3', '任务逾期自动取消认养资格天数', 1, '张管理员', '2026-01-25 21:34:17');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (9, 'ADOPTION_LIMIT', '1', '每人认养植物上限数量', 1, 'Admin', '2026-03-02 18:30:00');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (10, 'ABNORMALITY_TIMEOUT_HOURS', '48', '异常处理提醒时效(小时)', 1, 'Admin', '2026-03-02 18:30:00');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (11, 'KNOWLEDGE_FEATURE_LIKES', '20', '知识帖推荐点赞阈值', 1, 'Admin', '2026-03-02 18:30:00');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (12, 'ACHIEVEMENT_COMPLETION_RATE', '100', '成果评比任务完成率阈值(%)', 1, 'Admin', '2026-03-02 18:30:00');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (14, 'CURRENT_CYCLE', '2026-Cycle1', '当前认养周期', 1, 'admin', '2026-03-05 17:03:27');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (15, 'CLOCK_IN_START_TIME', '12:50', '打卡开始时间', 1, 'Admin', '2026-03-05 17:20:59');
INSERT INTO `system_parameters` (`id`, `param_key`, `param_value`, `description`, `updated_by`, `updated_by_name`, `updated_at`) VALUES (16, 'CLOCK_IN_END_TIME', '13:10', '打卡结束时间', 1, 'Admin', '2026-03-05 17:20:59');
COMMIT;

-- ----------------------------
-- Table structure for task_templates
-- ----------------------------
DROP TABLE IF EXISTS `task_templates`;
CREATE TABLE `task_templates` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务模板ID，主键',
  `plant_species` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '适用植物品种',
  `task_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务类型（浇水、修剪、施肥等）',
  `task_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务详细描述',
  `frequency_days` int NOT NULL COMMENT '任务生成频率（天数）',
  `duration_minutes` int DEFAULT NULL COMMENT '预计完成时间（分钟）',
  `seasonality` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '季节性（春季、夏季、秋季、冬季、全年）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `operation_requirements` text COLLATE utf8mb4_unicode_ci COMMENT '操作要求',
  `score_standard` text COLLATE utf8mb4_unicode_ci COMMENT '评分标准',
  `status` tinyint DEFAULT '1' COMMENT '状态：1-启用，0-禁用',
  PRIMARY KEY (`id`),
  KEY `idx_plant_species` (`plant_species`),
  KEY `idx_task_type` (`task_type`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='养护任务模板表';

-- ----------------------------
-- Records of task_templates
-- ----------------------------
BEGIN;
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (1, 'Prunus serrulata', '浇水', '彻底浇灌樱花树根部，确保土壤湿润但不积水，每次约20升水。', 5, 15, '全年', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (2, 'Prunus serrulata', '修剪', '修剪枯枝、病枝和交叉枝，保持树冠通风透光，促进花芽分化。', 90, 60, '冬季', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (3, 'Prunus serrulata', '施肥', '施用复合肥，每株约100克，均匀撒在树冠投影范围内。', 60, 20, '春季', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (4, 'Ginkgo biloba', '浇水', '银杏树耐旱，仅在连续干旱时浇水，每次约15升。', 10, 10, '夏季', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (5, 'Ginkgo biloba', '清理', '清理落叶和杂草，保持树盘清洁。', 30, 25, '秋季', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (6, 'Osmanthus fragrans', '浇水', '桂花喜湿润，保持土壤微湿，每次浇水约15升。', 4, 12, '全年', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (7, 'Osmanthus fragrans', '施肥', '花期前后施用磷钾肥，促进开花和香气。', 45, 15, '秋季', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (8, 'Lagerstroemia indica', '浇水', '紫薇耐旱，但在花期需要充足水分，每次约18升。', 6, 14, '夏季', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (9, 'Lagerstroemia indica', '修剪', '花后及时修剪残花，促进二次开花。', 30, 20, '夏季', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (10, 'Bambusa multiplex', '浇水', '竹子需水量大，保持土壤湿润，每次浇水约25升。', 3, 18, '全年', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
INSERT INTO `task_templates` (`id`, `plant_species`, `task_type`, `task_description`, `frequency_days`, `duration_minutes`, `seasonality`, `created_at`, `updated_at`, `operation_requirements`, `score_standard`, `status`) VALUES (11, 'Bambusa multiplex', '疏笋', '移除过密的新笋，控制竹林蔓延，保持通风。', 15, 40, '春季', '2026-01-03 16:00:01', '2026-01-03 16:00:01', NULL, NULL, 1);
COMMIT;

-- ----------------------------
-- Table structure for user_roles
-- ----------------------------
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

-- ----------------------------
-- Records of user_roles
-- ----------------------------
BEGIN;
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (1, 2, '2026-01-03 15:56:15');
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (2, 1, '2026-01-03 15:56:15');
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (3, 1, '2026-01-03 15:56:15');
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (4, 1, '2026-01-03 15:56:15');
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (5, 3, '2026-03-05 14:26:52');
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (6, 1, '2026-01-03 15:56:15');
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (7, 1, '2026-03-05 14:39:13');
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (8, 2, '2026-03-20 10:00:37');
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`) VALUES (9, 1, '2026-03-06 17:14:18');
COMMIT;

-- ----------------------------
-- Table structure for user_task_settings
-- ----------------------------
DROP TABLE IF EXISTS `user_task_settings`;
CREATE TABLE `user_task_settings` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `plant_id` bigint NOT NULL COMMENT '植物ID',
  `task_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务类型',
  `frequency_days` int NOT NULL COMMENT '频率(天)',
  `scheduled_time` time NOT NULL COMMENT '每日执行时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_plant` (`user_id`,`plant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户养护任务设置';

-- ----------------------------
-- Records of user_task_settings
-- ----------------------------
BEGIN;
INSERT INTO `user_task_settings` (`id`, `user_id`, `plant_id`, `task_type`, `frequency_days`, `scheduled_time`, `created_at`, `updated_at`) VALUES (1, 4, 6, '浇水', 3, '13:00:00', '2026-03-12 17:36:40', '2026-04-02 18:03:05');
INSERT INTO `user_task_settings` (`id`, `user_id`, `plant_id`, `task_type`, `frequency_days`, `scheduled_time`, `created_at`, `updated_at`) VALUES (2, 4, 6, '施肥', 14, '13:00:00', '2026-03-12 17:36:40', '2026-04-02 18:03:05');
INSERT INTO `user_task_settings` (`id`, `user_id`, `plant_id`, `task_type`, `frequency_days`, `scheduled_time`, `created_at`, `updated_at`) VALUES (3, 4, 6, '松土', 7, '13:00:00', '2026-03-12 17:36:40', '2026-04-02 18:03:05');
INSERT INTO `user_task_settings` (`id`, `user_id`, `plant_id`, `task_type`, `frequency_days`, `scheduled_time`, `created_at`, `updated_at`) VALUES (4, 4, 6, '检查虫害', 7, '13:00:00', '2026-03-12 17:36:40', '2026-04-02 18:03:05');
INSERT INTO `user_task_settings` (`id`, `user_id`, `plant_id`, `task_type`, `frequency_days`, `scheduled_time`, `created_at`, `updated_at`) VALUES (5, 3, 2, '浇水', 3, '13:00:00', '2026-04-02 17:40:37', '2026-04-02 18:03:05');
INSERT INTO `user_task_settings` (`id`, `user_id`, `plant_id`, `task_type`, `frequency_days`, `scheduled_time`, `created_at`, `updated_at`) VALUES (6, 3, 2, '施肥', 14, '13:00:00', '2026-04-02 17:40:38', '2026-04-02 18:03:05');
INSERT INTO `user_task_settings` (`id`, `user_id`, `plant_id`, `task_type`, `frequency_days`, `scheduled_time`, `created_at`, `updated_at`) VALUES (7, 3, 2, '松土', 7, '13:00:00', '2026-04-02 17:40:38', '2026-04-02 18:03:05');
INSERT INTO `user_task_settings` (`id`, `user_id`, `plant_id`, `task_type`, `frequency_days`, `scheduled_time`, `created_at`, `updated_at`) VALUES (8, 3, 2, '清理', 7, '13:00:00', '2026-04-02 17:40:38', '2026-04-02 18:03:05');
COMMIT;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID，主键',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名，唯一标识',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户密码（加密存储）',
  `real_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '真实姓名',
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '学号（学生）或工号（教职工）',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号码',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱地址',
  `status` tinyint DEFAULT '1' COMMENT '用户状态：1-启用，0-禁用',
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '删除时间（软删除）',
  `token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户token',
  `token_expire_time` timestamp NULL DEFAULT NULL COMMENT '用户token过期时间',
  `is_real_name_modified` tinyint(1) DEFAULT '0' COMMENT '真实姓名是否已修改过',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_username` (`username`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ----------------------------
-- Records of users
-- ----------------------------
BEGIN;
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (1, 'admin', '14e1b600b1fd579f47433b88e8d85291', '张卫', 'ADMIN001', '13800138001', 'admin@campus.edu.cn', 1, 'https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/05c9b4de-4349-420e-b84e-d135510cbea9.jpg', '2026-01-03 15:56:15', '2026-04-02 17:41:21', NULL, '3c38cafe-e98e-4c00-ae0e-4cade8c9b574', '2026-04-09 17:41:21', 0);
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (2, 'student_wang', '14e1b600b1fd579f47433b88e8d85291', '王小明', '2025001', '13800138002', 'wangxiaoming@campus.edu.cn', 1, 'https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/b74dd855-9c5a-4a3a-b93f-19dd71600a2e.jpg', '2026-01-03 15:56:15', '2026-03-19 17:55:01', NULL, '82358995-2d2c-4c72-841f-eaa667de637d', '2026-03-26 17:46:53', 0);
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (3, '229971004', '14e1b600b1fd579f47433b88e8d85291', '何杰', '2025002', '13800138003', 'lixiaohong@campus.edu.cn', 1, '/api/profile/390fbc20-f65d-4936-86ec-707a5adbf60b.jpg', '2026-01-03 15:56:15', '2026-03-30 11:25:19', NULL, '3c4ac35c-8810-48a4-8655-1f1f18121c35', '2026-04-06 11:25:19', 0);
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (4, 'zhangwei', '14e1b600b1fd579f47433b88e8d85291', '张伟', '2025003', '13800138004', 'zhangwei@campus.edu.cn', 1, '/api/profile/8a3b6c25-e6c2-4816-942a-245733318019.jpg', '2026-01-03 15:56:15', '2026-03-20 11:01:07', NULL, '78f04781-9d72-429d-ac86-da11ecb9824b', '2026-03-27 11:01:07', 0);
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (5, 'chen', '14e1b600b1fd579f47433b88e8d85291', '陈园艺师', 'MAINT001', '13800138005', 'chenyuanyi@campus.edu.cn', 1, 'https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/625f7d60-96ec-4c7b-8561-6d6fa820ce4e.jpg', '2026-01-03 15:56:15', '2026-03-19 17:45:30', NULL, 'd07f081c-1f6c-435a-926f-c6f985553898', '2026-03-26 17:45:30', 0);
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (6, 'teacher_liu', '14e1b600b1fd579f47433b88e8d85291', '刘教授', 'TEACH001', '13800138006', 'liujiaoshou@campus.edu.cn', 1, NULL, '2026-01-03 15:56:15', '2026-02-25 17:24:45', NULL, NULL, NULL, 0);
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (7, '229971005', '14e1b600b1fd579f47433b88e8d85291', '何瑜', '229971005', '15923470001', '15923470001@qq.com', 1, NULL, '2026-02-28 17:40:00', '2026-04-02 18:35:11', NULL, '8bc53f9d-76e9-401e-8510-9a027d81c5cb', '2026-04-09 18:35:11', 0);
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (8, 'admin1', '14e1b600b1fd579f47433b88e8d85291', '张强', 'ADMIN001', '13800000001', 'admin@test.com', 1, 'https://beiyijie-1377872876.cos.ap-guangzhou.myqcloud.com/profile/13983d30-f1bc-487b-b994-99d1dcbcbd6d.jpg', '2026-03-02 23:55:51', '2026-04-02 17:53:32', NULL, '6003b01e-63df-4e38-a8b6-cb833e5476dc', '2026-03-27 10:00:47', 0);
INSERT INTO `users` (`id`, `username`, `password`, `real_name`, `student_id`, `phone`, `email`, `status`, `avatar_url`, `created_at`, `updated_at`, `deleted_at`, `token`, `token_expire_time`, `is_real_name_modified`) VALUES (9, '229971006', '14e1b600b1fd579f47433b88e8d85291', '何炜', '229971004', '13800138008', 'hj945218@gmail.com', 1, NULL, '2026-03-06 17:14:18', '2026-04-02 17:53:32', NULL, '5872920a-5e76-4328-8a52-5ee4d560a453', '2026-03-24 11:18:24', 0);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
