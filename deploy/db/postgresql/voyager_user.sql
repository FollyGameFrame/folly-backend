
-- ----------------------------
-- Table structure for user
-- ----------------------------
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    username VARCHAR(128) NOT NULL UNIQUE,
    display_name VARCHAR(255),
    avatar_url VARCHAR(512),
    lang_tag VARCHAR(18) NOT NULL DEFAULT 'en',
    location VARCHAR(255),
    timezone VARCHAR(255),
    metadata JSONB NOT NULL DEFAULT '{}',
    wallet JSONB NOT NULL DEFAULT '{}',
    email VARCHAR(255) UNIQUE,
    password BYTEA CHECK (length(password) < 32000),
    facebook_id VARCHAR(128) UNIQUE,
    google_id VARCHAR(128) UNIQUE,
    gamecenter_id VARCHAR(128) UNIQUE, -
    steam_id VARCHAR(128) UNIQUE,
    custom_id VARCHAR(128) UNIQUE,
    edge_count INT NOT NULL DEFAULT 0 CHECK (edge_count >= 0),
    create_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    update_time TIMESTAMPTZ NOT NULL DEFAULT now(), -
    verify_time TIMESTAMPTZ NOT NULL DEFAULT '1970-01-01 00:00:00 UTC',
    disable_time TIMESTAMPTZ NOT NULL DEFAULT '1970-01-01 00:00:00 UTC'
);

-- 添加表注释
COMMENT ON TABLE users IS '用户表，存储用户基本信息';
-- 添加字段注释
COMMENT ON COLUMN users.id IS '用户ID，主键';
COMMENT ON COLUMN users.username IS '用户名，唯一且不能为空';
COMMENT ON COLUMN users.display_name IS '显示名称';
COMMENT ON COLUMN users.avatar_url IS '头像URL';
COMMENT ON COLUMN users.lang_tag IS '语言标签，默认值为''en''';
COMMENT ON COLUMN users.location IS '位置';
COMMENT ON COLUMN users.timezone IS '时区';
COMMENT ON COLUMN users.metadata IS '用户元数据，JSON格式，默认值为空JSON';
COMMENT ON COLUMN users.wallet IS '用户钱包信息，JSON格式，默认值为空JSON';
COMMENT ON COLUMN users.email IS '邮箱，唯一';
COMMENT ON COLUMN users.password IS '密码，长度限制为32000字节';
COMMENT ON COLUMN users.facebook_id IS 'Facebook ID，唯一';
COMMENT ON COLUMN users.google_id IS 'Google ID，唯一';
COMMENT ON COLUMN users.gamecenter_id IS 'GameCenter ID，唯一';
COMMENT ON COLUMN users.steam_id IS 'Steam ID，唯一';
COMMENT ON COLUMN users.custom_id IS '自定义ID，唯一';
COMMENT ON COLUMN users.edge_count IS '边缘计数，非负整数，默认值为0';
COMMENT ON COLUMN users.create_time IS '创建时间，默认值为当前时间';
COMMENT ON COLUMN users.update_time IS '更新时间，默认值为当前时间';
COMMENT ON COLUMN users.verify_time IS '验证时间，默认值为1970-01-01 00:00:00 UTC';
COMMENT ON COLUMN users.disable_time IS '禁用时间，默认值为1970-01-01 00:00:00 UTC';

-- 添加索引以加速查询
CREATE INDEX idx_users_username ON users (username);
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_facebook_id ON users (facebook_id);
CREATE INDEX idx_users_google_id ON users (google_id);
CREATE INDEX idx_users_gamecenter_id ON users (gamecenter_id);
CREATE INDEX idx_users_steam_id ON users (steam_id);
CREATE INDEX idx_users_custom_id ON users (custom_id);

-- ----------------------------
-- Table structure for user_device
-- ----------------------------
CREATE TABLE IF NOT EXISTS user_device (
    id VARCHAR(128) PRIMARY KEY,
    user_id UUID NOT NULL,
    UNIQUE (user_id, id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE -
);

-- 添加表注释
COMMENT ON TABLE user_device IS '用户设备表，存储用户的设备信息';
-- 添加字段注释
COMMENT ON COLUMN user_device.id IS '设备ID，主键';
COMMENT ON COLUMN user_device.user_id IS '用户ID，外键';

-- 添加索引以加速查询
CREATE INDEX idx_user_device_user_id ON user_device (user_id);


-- ----------------------------
-- Table structure for user_edge
-- ----------------------------
CREATE TABLE IF NOT EXISTS user_edge (
    source_id UUID NOT NULL CHECK (source_id <> '00000000-0000-0000-0000-000000000000'),
    position BIGINT NOT NULL,
    update_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    destination_id UUID NOT NULL CHECK (destination_id <> '00000000-0000-0000-0000-000000000000'),
    state SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (source_id, state, position),
    FOREIGN KEY (source_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (destination_id) REFERENCES users (id) ON DELETE CASCADE,
    UNIQUE (source_id, destination_id)
);

-- 添加表注释
COMMENT ON TABLE user_edge IS '用户边表，存储用户之间的边信息（记录用户之间的关系：如好友关系、邀请等）';
-- 添加字段注释
COMMENT ON COLUMN user_edge.source_id IS '源用户ID，外键且不能为空';
COMMENT ON COLUMN user_edge.position IS '位置，不能为空';
COMMENT ON COLUMN user_edge.update_time IS '更新时间，默认值为当前时间';
COMMENT ON COLUMN user_edge.destination_id IS '目标用户ID，外键且不能为空';
COMMENT ON COLUMN user_edge.state IS '状态，默认值为0';

-- 添加索引以加速查询
CREATE INDEX IF NOT EXISTS user_edge_auto_index_fk_destination_id_ref_users ON user_edge (destination_id);



