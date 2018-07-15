Define = {

        -- --------------------------------------------------------------------------------
        -- 数值定义

        --游戏模式
        GAME_GENRE_GOLD                  =        0x0001,       --金币类型
        GAME_GENRE_SCORE                 =        0x0002,       --点值类型
        GAME_GENRE_MATCH                 =        0x0004,       --比赛类型
        GAME_GENRE_EDUCATE               =        0x0008,       --训练类型
        GAME_GENRE_HAPPYBEANS            =        0x0010,       --欢乐豆类型
        GAME_AUTO_ALLOC                  =        0x0040,       --匹配模式

        -- 头像大小
        FACE_CX                          = 48,                  -- 头像宽度
        FACE_CY                          = 48,                  -- 头像高度

        -- 长度定义
        LEN_LESS_ACCOUNTS                = 6,                   -- 最短帐号
        LEN_LESS_NICKNAME                = 6,                   -- 最短昵称
        LEN_LESS_PASSWORD                = 6,                   -- 最短密码

        -- 人数定义
        MAX_CHAIR                        = 100,                 -- 最大椅子
        MAX_TABLE                        = 512,                 -- 最大桌子
        MAX_COLUMN                       = 32,                  -- 最大列表
        MAX_ANDROID                      = 256,                 -- 最大机器
        MAX_PROPERTY                     = 128,                 -- 最大道具
        MAX_WHISPER_USER                 = 16,                  -- 最大私聊

        -- 列表定义
        MAX_KIND                         = 128,                 -- 最大类型
        MAX_SERVER                       = 1024,                -- 最大房间

        -- 参数定义
        INVALID_CHAIR                    = 0xFFFF,              -- 无效椅子
        INVALID_TABLE                    = 0xFFFFFFFF,          -- 无效桌子

        -- 税收定义
        REVENUE_BENCHMARK                = 0,                  -- 税收起点
        REVENUE_DENOMINATOR              = 1000,               -- 税收分母

        -- --------------------------------------------------------------------------------
        -- 系统参数

        -- 积分类型
        -- #define SCORE LONGLONG --积分类型
        -- #define SCORE_STRING TEXT("%I64d") --积分类型

        -- 游戏状态
        GAME_STATUS_FREE                 = 0,                   -- 空闲状态
        GAME_STATUS_PLAY                 = 100,                 -- 叫分状态
        GAME_STATUS_PLAYING              = 101,                 -- 出牌状态
        GAME_STATUS_FIRST                = 102,                 -- 让先状态
        GAME_SCENE_BET                   = 109,                 --投注状态
        GAME_STATUS_WAIT                 = 200,                 -- 等待状态

        -- 系统参数
        LEN_USER_CHAT                    = 128,                 -- 聊天长度
        TIME_USER_CHAT                   = 1,                  -- 聊天间隔
        TRUMPET_MAX_CHAR                 = 128,                 -- 喇叭长度

        -- --------------------------------------------------------------------------------
        -- 索引质数

        -- 列表质数
        PRIME_TYPE                       = 11,                 -- 种类数目
        PRIME_KIND                       = 53,                 -- 类型数目
        PRIME_NODE                       = 101,                -- 节点数目
        PRIME_PAGE                       = 53,                 -- 自定数目
        PRIME_SERVER                     = 1009,               -- 房间数目

        -- 人数质数
        PRIME_SERVER_USER                = 503,                -- 房间人数
        PRIME_ANDROID_USER               = 503,                -- 机器人数
        PRIME_PLATFORM_USER              = 100003,             -- 平台人数

        -- --------------------------------------------------------------------------------
        -- 数据长度

        -- 资料数据
        LEN_MD5                          = 33,                  -- 加密密码
        LEN_USERNOTE                     = 32,                  -- 备注长度
        LEN_ACCOUNTS                     = 32,                  -- 帐号长度
        LEN_NICKNAME                     = 32,                  -- 昵称长度
        LEN_PASSWORD                     = 33,                  -- 密码长度
        LEN_GROUP_NAME                   = 32,                  -- 社团名字
        LEN_UNDER_WRITE                  = 32,                  -- 个性签名
        LEN_MAX_URL                      = 1024,                -- URL
        -- 长度

        -- 数据长度
        LEN_QQ                           = 16,                  -- Q
        -- Q
        -- 号码
        LEN_EMAIL                        = 33,                  -- 电子邮件
        LEN_USER_NOTE                    = 256,                 -- 用户备注
        LEN_SEAT_PHONE                   = 33,                  -- 固定电话
        LEN_MOBILE_PHONE                 = 12,                  -- 移动电话
        LEN_PASS_PORT_ID                 = 19,                  -- 证件号码
        LEN_COMPELLATION                 = 16,                  -- 真实名字
        LEN_DWELLING_PLACE               = 128,                 -- 联系地址

        -- 机器标识
        LEN_NETWORK_ID                   = 13,                  -- 网卡长度
        LEN_MACHINE_ID                   = 33,                  -- 序列长度

        -- 列表数据
        LEN_TYPE                         = 32,                  -- 种类长度
        LEN_KIND                         = 32,                  -- 类型长度
        LEN_NODE                         = 32,                  -- 节点长度
        LEN_PAGE                         = 32,                  -- 定制长度
        LEN_SERVER                       = 32,                  -- 房间长度
        LEN_PROCESS                      = 32,                  -- 进程长度

        -- --------------------------------------------------------------------------------

        -- 用户关系
        CP_NORMAL                        = 0,                   -- 未知关系
        CP_FRIEND                        = 1,                   -- 好友关系
        CP_DETEST                        = 2,                   -- 厌恶关系
        CP_SHIELD                        = 3,                   -- 屏蔽聊天

        -- --------------------------------------------------------------------------------

        -- 性别定义
        GENDER_FEMALE                    = 0,                   -- 女性性别
        GENDER_MANKIND                   = 1,                   -- 男性性别

        -- --------------------------------------------------------------------------------

        -- 游戏模式
        GAME_GENRE_GOLD                  = 0x0001,              -- 金币类型
        GAME_GENRE_SCORE                 = 0x0002,              -- 点值类型
        GAME_GENRE_MATCH                 = 0x0004,              -- 比赛类型
        GAME_GENRE_EDUCATE               = 0x0008,              -- 训练类型

        -- 分数模式
        SCORE_GENRE_NORMAL               = 0x0100,              -- 普通模式
        SCORE_GENRE_POSITIVE             = 0x0200,              -- 非负模式

        -- --------------------------------------------------------------------------------

        -- 用户状态
        US_NULL                          = 0x00,                -- 没有状态
        US_FREE                          = 0x01,                -- 站立状态
        US_SIT                           = 0x02,                -- 坐下状态
        US_READY                         = 0x03,                -- 同意状态
        US_LOOKON                        = 0x04,                -- 旁观状态
        US_PLAYING                       = 0x05,                -- 游戏状态
        US_OFFLINE                       = 0x06,                -- 断线状态

        -- --------------------------------------------------------------------------------

        -- 比赛状态
        MS_NULL                          = 0x00,                -- 没有状态
        MS_SIGNUP                        = 0x01,                -- 报名状态
        MS_MATCHING                      = 0x02,                -- 比赛状态
        MS_OUT                           = 0x03,                -- 淘汰状态

        -- --------------------------------------------------------------------------------

        -- 房间规则
        SRL_LOOKON                       = 0x00000001,          -- 旁观标志
        SRL_OFFLINE                      = 0x00000002,          -- 断线标志
        SRL_SAME_IP                      = 0x00000004,          -- 同网标志

        -- 房间规则
        SRL_ROOM_CHAT                    = 0x00000100,          -- 聊天标志
        SRL_GAME_CHAT                    = 0x00000200,          -- 聊天标志
        SRL_WISPER_CHAT                  = 0x00000400,          -- 私聊标志
        SRL_HIDE_USER_INFO               = 0x00000800,          -- 隐藏标志

        -- --------------------------------------------------------------------------------
        -- 列表数据

        -- 无效属性
        UD_NULL                          = 0,                   -- 无效子项
        UD_IMAGE                         = 100,                 -- 图形子项
        UD_CUSTOM                        = 200,                 -- 自定子项

        -- 基本属性
        UD_GAME_ID                       = 1,                   -- 游戏标识
        UD_USER_ID                       = 2,                   -- 用户标识
        UD_NICKNAME                      = 3,                   -- 用户昵称

        -- 扩展属性
        UD_GENDER                        = 10,                  -- 用户性别
        UD_GROUP_NAME                    = 11,                  -- 社团名字
        UD_UNDER_WRITE                   = 12,                  -- 个性签名

        -- 状态信息
        UD_TABLE                         = 20,                  -- 游戏桌号
        UD_CHAIR                         = 21,                  -- 椅子号码

        -- 积分信息
        UD_SCORE                         = 30,                  -- 用户分数
        UD_GRADE                         = 31,                  -- 用户成绩
        UD_USER_MEDAL                    = 32,                  -- 用户经验
        UD_EXPERIENCE                    = 33,                  -- 用户经验
        UD_LOVELINESS                    = 34,                  -- 用户魅力
        UD_WIN_COUNT                     = 35,                  -- 胜局盘数
        UD_LOST_COUNT                    = 36,                  -- 输局盘数
        UD_DRAW_COUNT                    = 37,                  -- 和局盘数
        UD_FLEE_COUNT                    = 38,                  -- 逃局盘数
        UD_PLAY_COUNT                    = 39,                  -- 总局盘数

        -- 积分比率
        UD_WIN_RATE                      = 40,                  -- 用户胜率
        UD_LOST_RATE                     = 41,                  -- 用户输率
        UD_DRAW_RATE                     = 42,                  -- 用户和率
        UD_FLEE_RATE                     = 43,                  -- 用户逃率
        UD_GAME_LEVEL                    = 44,                  -- 游戏等级

        -- 扩展信息
        UD_NOTE_INFO                     = 50,                  -- 用户备注
        UD_LOOKON_USER                   = 51,                  -- 旁观用户

        -- 图像列表
        UD_IMAGE_FLAG                    = (100 + 1),      -- 用户标志
        UD_IMAGE_GENDER                  = (100 + 2),      -- 用户性别
        UD_IMAGE_STATUS                  = (100 + 3),      -- 用户状态

        -- --------------------------------------------------------------------------------
        -- 数据库定义

        DB_ERROR                         = -1,                  -- 处理失败
        DB_SUCCESS                       = 0,                   -- 处理成功
        DB_NEEDMB                        = 18,                  -- 处理失败

        -- --------------------------------------------------------------------------------
        -- 道具标示
        PT_USE_MARK_DOUBLE_SCORE         = 0x0001,              -- 双倍积分
        PT_USE_MARK_FOURE_SCORE          = 0x0002,              -- 四倍积分
        PT_USE_MARK_GUARDKICK_CARD       = 0x0010,              -- 防踢道具
        PT_USE_MARK_POSSESS              = 0x0020,              -- 附身道具

        MAX_PT_MARK                      = 4,                   -- 标识数目

        -- 有效范围
        VALID_TIME_DOUBLE_SCORE          = 3600,                -- 有效时间
        VALID_TIME_FOUR_SCORE            = 3600,                -- 有效时间
        VALID_TIME_GUARDKICK_CARD        = 3600,                -- 防踢时间
        VALID_TIME_POSSESS               = 3600,                -- 附身时间
        VALID_TIME_KICK_BY_MANAGER       = 3600,                -- 游戏时间

        -- --------------------------------------------------------------------------------
        -- 设备类型
        DEVICE_TYPE_PC                   = 0x00,                -- PC
        DEVICE_TYPE_ANDROID              = 0x10,                -- Android
        DEVICE_TYPE_ITOUCH               = 0x20,                -- iTouch
        DEVICE_TYPE_IPHONE               = 0x40,                -- iPhone
        DEVICE_TYPE_IPAD                 = 0x80,                -- iPad

        -- ------------------------------------------------------------------------------/
        -- 手机定义

        -- 视图模式
        VIEW_MODE_ALL                    = 0x0001,              -- 全部可视
        VIEW_MODE_PART                   = 0x0002,              -- 部分可视

        -- 信息模式
        VIEW_INFO_LEVEL_1                = 0x0010,              -- 部分信息
        VIEW_INFO_LEVEL_2                = 0x0020,              -- 部分信息
        VIEW_INFO_LEVEL_3                = 0x0040,              -- 部分信息
        VIEW_INFO_LEVEL_4                = 0x0080,              -- 部分信息

        -- 其他配置
        RECVICE_GAME_CHAT                = 0x0100,              -- 接收聊天
        RECVICE_ROOM_CHAT                = 0x0200,              -- 接收聊天
        RECVICE_ROOM_WHISPER             = 0x0400,              -- 接收私聊

        -- 行为标识
        BEHAVIOR_LOGON_NORMAL            = 0x0000,              -- 普通登录
        BEHAVIOR_LOGON_IMMEDIATELY       = 0x1000,              -- 立即登录

        -- ------------------------------------------------------------------------------/
        -- 处理结果
        RESULT_ERROR                     = -1,                  -- 处理错误
        RESULT_SUCCESS                   = 0,                   -- 处理成功
        RESULT_FAIL                      = 1,                   -- 处理失败

        -- ------------------------------------------------------------------------------/
        -- 变化原因
        SCORE_REASON_WRITE               = 0,                   -- 写分变化
        SCORE_REASON_INSURE              = 1,                   -- 银行变化
        SCORE_REASON_PROPERTY            = 2,                   -- 道具变化
        SCORE_REASON_MATCH_FEE           = 3,                   -- 比赛报名
        SCORE_REASON_MATCH_QUIT          = 4,                   -- 比赛退赛

        -- ------------------------------------------------------------------------------/

        -- 登录房间失败原因
        LOGON_FAIL_SERVER_INVALIDATION   = 200,                 -- 房间失效

        -- ------------------------------------------------------------------------------

        -- 通用查询字段
        COMMON_FLAG_QUERY_BOX_PRESENT    = "query_box_present", -- 客户端主动查询宝箱礼券
        COMMON_FLAG_NOTIFY_BOX_PRESENT   = "notify_box_present", -- 主站主动推送通知宝箱礼券
        COMMON_FLAG_OPEN_BOX_PRESENT     = "open_box_present",  -- 用户主动打开宝箱礼券

        COMMON_REPLY_FIELD_SEPARATOR     = "\\|\\*\\|",             -- 相互字段采用竖线分割
        COMMON_REPLY_FIELD_USERID        = "UserID",            -- 用户ID
        COMMON_REPLY_FIELD_SCORE         = "Score",             -- 个人筹码
        COMMON_REPLY_FIELD_INSURE_SCORE  = "InsureScore",       -- 个人银行
        COMMON_REPLY_FIELD_BOX_PRESENT   = "BoxPresent",        -- 个人宝箱中拥有的礼券
        COMMON_REPLY_FIELD_TOTAL_PRESENT = "TotalPresent",      -- 个人现在有用的礼券
        COMMON_REPLY_FIELD_GIFT          = "Gift",               -- 个人元宝

        --------------------------------------------------------------------------------------
        DTP_GP_UI_NICKNAME              = 1,                            --用户昵称
        DTP_GP_UI_USER_NOTE             = 2,                            --用户说明
        DTP_GP_UI_UNDER_WRITE           = 3,                            --个性签名
        DTP_GP_UI_QQ                    = 4,                            --Q Q 号码
        DTP_GP_UI_EMAIL                 = 5,                            --电子邮件
        DTP_GP_UI_SEAT_PHONE            = 6,                            --固定电话
        DTP_GP_UI_MOBILE_PHONE          = 7,                            --移动电话
        DTP_GP_UI_COMPELLATION          = 8,                             --真实名字
        DTP_GP_UI_DWELLING_PLACE        = 9,                             --联系地址

        --系统消息定义 ------------------------------------------------------------------------------
        SMT_CHAT             =       0x0001,                              --聊天消息
        SMT_EJECT            =       0x0002,                              --弹出消息
        SMT_GLOBAL           =       0x0004,                              --全局消息
        SMT_PROMPT           =       0x0008,                              --提示消息
        SMT_TABLE_ROLL       =       0x0010,                              --滚动消息

        SMT_SEND_JIUJI       =       0x0020,                              --发送救济消息
        SMT_SEND_VOUCHER     =       0x0080,                              --发送礼券消息

        SMT_SYSTEM_MSG       =       0x1000,                              --系统消息
        SMT_PLYER_MSG        =       0x2000,                              --玩家喊话消息
        SMT_AWARD_MSG        =       0x4000,                              --奖励消息
        SMT_ACTIVITY_MSG     =       0x8000,                              --活动消息


}

--keyblord
InputMode_ANY = 0;
InputMode_EMAIL_ADDRESS = 1;
InputMode_NUMERIC = 2;
InputMode_PHONE_NUMBER = 3;
InputMode_URL = 4;
InputMode_DECIMAL = 5;
InputMode_SINGLE_LINE = 6;
