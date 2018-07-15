CMD_GameServer={
    --登录命令
    MDM_GR_LOGON                      =          1,                                   --登录信息

    --登录模式
    SUB_GR_LOGON_USERID               =          1,                                   --I D 登录
    SUB_GR_LOGON_MOBILE               =          2,                                   --手机登录
    SUB_GR_LOGON_ACCOUNTS             =          3,                                   --帐户登录
    SUB_GP_LOGON_TOKEN_ID             =          5,                                   --统一平台标识I D 登录


    --登录结果
    SUB_GR_LOGON_SUCCESS              =          100,                                 --登录成功
    SUB_GR_LOGON_FAILURE              =          101,                                 --登录失败
    SUB_GR_LOGON_FINISH               =          102,                                 --登录完成

    --升级提示
    SUB_GR_UPDATE_NOTIFY              =          200,                                 --升级提示

    ----------------------------------------------------------------------------------
    --配置命令

    MDM_GR_CONFIG                     =          2,                                   --配置信息

    SUB_GR_CONFIG_COLUMN              =          100,                                 --列表配置
    SUB_GR_CONFIG_SERVER              =          101,                                 --房间配置
    SUB_GR_CONFIG_PROPERTY            =          102,                                 --道具配置
    SUB_GR_CONFIG_FINISH              =          103,                                 --配置完成
    SUB_GR_CONFIG_USER_RIGHT          =          104,                                 --玩家权限

    ----------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------
    --用户命令

    MDM_GR_USER                       =          3,                                   --用户信息

    --用户动作
    SUB_GR_USER_RULE                  =          1,                                   --用户规则
    SUB_GR_USER_LOOKON                =          2,                                   --旁观请求
    SUB_GR_USER_SITDOWN               =          3,                                   --坐下请求
    SUB_GR_USER_STANDUP               =          4,                                   --起立请求
    SUB_GR_USER_INVITE                =          5,                                   --用户邀请
    SUB_GR_USER_INVITE_REQ            =          6,                                   --邀请请求
    SUB_GR_USER_REPULSE_SIT           =          7,                                   --拒绝玩家坐下
    SUB_GR_USER_KICK_USER             =          8,                                   --踢出用户
    SUB_GR_USER_INFO_REQ              =          9,                                   --请求用户信息
    SUB_GR_USER_CHAIR_REQ             =          10,                                  --请求更换位置
    SUB_GR_USER_CHAIR_INFO_REQ        =          11,                                  --请求椅子用户信息
    SUB_GR_USER_WAIT_DISTRIBUTE       =          12,                                  --等待分配
    SUB_GR_USER_FAST_START            =          13,                                  --快速分配
    SUB_GR_USER_SITDOWN_AUTOMATCH     =          14,                                  --快速分配
    SUB_GR_USER_AUTOMATCH_SIGNUP      =          15,                                  --自动分配
    SUB_GR_USER_AUTOMATCH_SIGNUP_NOUSER =        17,                                  --重新加入队列

    --用户状态
    SUB_GR_USER_ENTER                 =          100,                                 --用户进入
    SUB_GR_USER_SCORE                 =          101,                                 --用户分数
    SUB_GR_USER_STATUS                =          102,                                 --用户状态
    SUB_GR_REQUEST_FAILURE            =          103,                                 --请求失败

    --聊天命令
    SUB_GR_USER_CHAT                  =          201,                                 --聊天消息
    SUB_GR_USER_EXPRESSION            =          202,                                 --表情消息
    SUB_GR_WISPER_CHAT                =          203,                                 --私聊消息
    SUB_GR_WISPER_EXPRESSION          =          204,                                 --私聊表情
    SUB_GR_COLLOQUY_CHAT              =          205,                                 --会话消息
    SUB_GR_COLLOQUY_EXPRESSION        =          206,                                 --会话表情

    --道具命令
    SUB_GR_PROPERTY_BUY               =          300,                                 --购买道具
    SUB_GR_PROPERTY_SUCCESS           =          301,                                 --道具成功
    SUB_GR_PROPERTY_FAILURE           =          302,                                 --道具失败
    SUB_GR_PROPERTY_MESSAGE           =          303,                                 --道具消息
    SUB_GR_PROPERTY_EFFECT            =          304,                                 --道具效应
    SUB_GR_PROPERTY_TRUMPET           =          305,                                 --喇叭消息


    SUB_GR_QUERY_OWN_BOX_KIND_SCORE   =          350, --查询当前用户所拥有的宝箱（送筹码的宝箱）
    SUB_GR_OPEN_BOX_KIND_SCORE        =          351, --打开宝箱（送筹码的宝箱）
    SUB_GR_OPEN_BOX_KIND_SCORE_SUCCESS=          352, --打开宝箱成功（送筹码的宝箱）
    SUB_GR_OPEN_BOX_KIND_SCORE_FAILED =          353, --打开宝箱失败（送筹码的宝箱）

    --计时宝箱
    SUB_GR_DRAW_TIMEBOXAWARD          =          600, --领取计时宝箱奖励
    SUB_GR_QUERY_TIMEBOXAWARD         =          601, --查询计时宝箱奖励

    --礼券
    SUB_GR_VOUCHER_BETTING_REPLY      =          633, --礼券投注
    SUB_GR_VOUCHER_DRAWING_REPLY      =          634, --礼券开奖
    SUB_GR_QUERY_VOUCHER_COUNT        =          635, --礼券查询
    SUB_GR_QUERY_NEARLY_DRAWED_USER   =          636, --礼券奖励历史查询
    SUB_GR_QUERY_USER_DRAWED_COUNT    =          637, -- 玩家中奖次数
    SUB_GR_WINTASKCALC_REPLY          =          638,--胜利类型任务奖励及次数回包

    SUB_GR_ALMS_RECEIVE               =          610, --领取救济金
    --房间中兑换欢乐豆
    SUB_GR_USER_EXCHAGEBEANS          =          630, --玩家兑换欢乐豆请求
    SUB_GR_QUERY_EXCHAGECOUNT         =          631, --玩家查询今天还能兑换欢乐豆数量请求
    SUB_GP_EXCHANGE_BEANS_SUCCESS     =          424, --兑换欢乐豆成功
    SUB_GP_EXCHANGE_BEANS_FAILURE     =          425, --兑换欢乐豆失败
    SUB_GP_QUERYEXCHANGE_BEANS_SUCCESS=          426, --返回今天还能兑换多少欢乐豆
    SUB_GP_QUERYEXCHANGE_BEANS_FAILURE=          427, --返回今天还能兑换多少欢乐豆失败

    --VIP主播排名 FOR 玩家
    SUB_GR_VIP_WEEK_ORDER             =          611,
    SUB_GR_VIP_YESTERDAY_ORDER        =          612,
    SUB_GR_VIP_TODAY_ORDER            =          613,
    SUB_GR_VIP_WEEK_ORDER_REPLY       =          614,
    SUB_GR_VIP_YESTERDAY_ORDER_REPLY  =          615,
    SUB_GR_VIP_TODAY_ORDER_REPLY      =          616,
    --VIP主播排名 FOR 主播
    SUB_GR_VIP_WEEK_ORDER_BY_PROPERTY_SCORE              =          617,
    SUB_GR_VIP_YESTERDAY_ORDER_BY_PROPERTY_SCORE         =          618,
    SUB_GR_VIP_TODAY_ORDER_BY_PROPERTY_SCORE             =          619,
    SUB_GR_VIP_WEEK_ORDER_BY_PROPERTY_SCORE_REPLY        =          620,
    SUB_GR_VIP_YESTERDAY_ORDER_BY_PROPERTY_SCORE_REPLY   =          621,
    SUB_GR_VIP_TODAY_ORDER_BY_PROPERTY_SCORE_REPLY       =          622,
    --查询TTCVIP魅力
    SUB_GR_QUERY_TTCVIPLOVELINESS                        =   632,     
    SUB_GP_QUERY_TTCVIP_LOVELINESS_RESULT                =   430,                             
    ----------------------------------------------------------------------------------
    --状态命令

    MDM_GR_STATUS                     =          4,                                   --状态信息

    SUB_GR_TABLE_INFO                 =          100,                                 --桌子信息
    SUB_GR_TABLE_STATUS               =          101,                                 --桌子状态


    ----------------------------------------------------------------------------------
    --银行命令
    MDM_GR_INSURE                     =          5,                                   --用户信息

    --银行命令
    SUB_GR_QUERY_INSURE_INFO          =          1,                                   --查询银行
    SUB_GR_SAVE_SCORE_REQUEST         =          2,                                   --存款操作
    SUB_GR_TAKE_SCORE_REQUEST         =          3,                                   --取款操作
    SUB_GR_TRANSFER_SCORE_REQUEST     =          4,                               --取款操作
    SUB_GR_QUERY_USER_INFO_REQUEST    =          5,                               --查询用户
    SUB_GR_DASANG_VIP_SCORE_REQUEST   =          7,                               --打赏vip

    SUB_GR_USER_INSURE_INFO           =          100,                                 --银行资料
    SUB_GR_USER_INSURE_SUCCESS        =          101,                                 --银行成功
    SUB_GR_USER_INSURE_FAILURE        =          102,                                 --银行失败
    SUB_GR_USER_TRANSFER_USER_INFO    =          103,                             --用户资料
    SUB_GR_DASANG_SUCCESS             =          109,                             --打赏成功

    ----------------------------------------------------------------------------------
    --管理命令

    MDM_GR_MANAGE                     =          6,                                   --管理命令

    SUB_GR_SEND_WARNING               =          1,                                   --发送警告
    SUB_GR_SEND_MESSAGE               =          2,                                   --发送消息
    SUB_GR_LOOK_USER_IP               =          3,                                   --查看地址
    SUB_GR_KILL_USER                  =          4,                                   --踢出用户
    SUB_GR_LIMIT_ACCOUNS              =          5,                                   --禁用帐户
    SUB_GR_SET_USER_RIGHT             =          6,                                   --权限设置

    --房间设置
    SUB_GR_QUERY_OPTION               =          7,                                   --查询设置
    SUB_GR_OPTION_SERVER              =          8,                                   --房间设置
    SUB_GR_OPTION_CURRENT             =          9,                                   --当前设置

    SUB_GR_LIMIT_USER_CHAT            =          10,                                  --限制聊天

    SUB_GR_KICK_ALL_USER              =          11,                                  --踢出用户
    SUB_GR_DISMISSGAME                =          12,                                  --解散游戏

    ----------------------------------------------------------------------------------
    --比赛命令

    MDM_GR_MATCH                      =           7,                                   --比赛命令

    SUB_GR_MATCH_FEE                  =           400,                                 --报名费用
    SUB_GR_MATCH_NUM                  =           401,                                 --等待人数
    SUB_GR_LEAVE_MATCH                =           402,                                 --退出比赛
    SUB_GR_MATCH_INFO                 =           403,                                 --比赛信息
    SUB_GR_MATCH_WAIT_TIP             =           404,                                 --等待提示
    SUB_GR_MATCH_RESULT               =           405,                                 --比赛结果
    SUB_GR_MATCH_STATUS               =           406,                                 --比赛状态
    SUB_GR_MATCH_DESC                 =           408,                                 --比赛描述

    ----------------改动以下时 请将游戏里面CMD_GAME.H的同时改动----------------------------
    SUB_GR_MATCH_INFO_ER_SPARROWS     =           410,                             --比赛信息(2人麻将)

    ----------------------------------------------------------------------------------
    --框架命令

    MDM_GF_FRAME                      =           100,                                 --框架命令

    ----------------------------------------------------------------------------------
    --框架命令

    --用户命令
    SUB_GF_GAME_OPTION                =            1,                                    --游戏配置
    SUB_GF_USER_READY                 =            2,                                   --用户准备
    SUB_GF_LOOKON_CONFIG              =            3,                                   --旁观配置

    --聊天命令
    SUB_GF_USER_CHAT                  =            10,                                  --用户聊天
    SUB_GF_USER_EXPRESSION            =            11,                                  --用户表情
    SUB_GF_USER_MULTIMEDIA            =            12,                                  --多媒体聊天信息

    --游戏信息
    SUB_GF_GAME_STATUS                =            100,                                 --游戏状态
    SUB_GF_GAME_SCENE                 =            101,                                 --游戏场景
    SUB_GF_LOOKON_STATUS              =            102,                                 --旁观状态

    --系统消息
    SUB_GF_SYSTEM_MESSAGE             =            200,                                 --系统消息
    SUB_GF_ACTION_MESSAGE             =            201,                                 --动作消息



    ----------------------------------------------------------------------------------
    --游戏命令

    MDM_GF_GAME                       =            200,                                 --游戏命令




}