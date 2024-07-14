/*
 Navicat MySQL Data Transfer

 Source Server         : voyager
 Source Server Type    : MySQL
 Source Server Version : 80028
 Source Host           : 127.0.0.1:33069
 Source Schema         : voyager_user

 Target Server Type    : MySQL
 Target Server Version : 80028
 File Encoding         : 65001

 Date:04/07/2024 17:14:49
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `users` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT COMMENT '用户唯一标识符',
    `username` VARCHAR(255) UNIQUE NOT NULL COMMENT '用户名，必须唯一',
    `email` VARCHAR(255) UNIQUE NOT NULL COMMENT '用户邮箱，必须唯一',
    `password_hash` VARCHAR(255) NOT NULL COMMENT '用户密码的哈希值',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录最后更新时间',
    `profile_picture` VARCHAR(255) DEFAULT NULL COMMENT '用户头像的URL',
    `bio` TEXT DEFAULT NULL COMMENT '用户简介',
    PRIMARY KEY (`id`),
    INDEX (`username`),
    INDEX (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表，存储用户基本信息';


SET FOREIGN_KEY_CHECKS = 1;
