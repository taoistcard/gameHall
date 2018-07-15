CMD_GAME = {
	HEART_BEAT 										= 0x010000,
	LOGIN 											= 0x010100,
	LOGIN_ANDROID 									= 0x010108,
	LOGOUT 											= 0x010109,
	SERVER_CONFIG  									= 0x010102,
	TABLE_STATUS  									= 0x010104,
	TABLE_STATUS_LIST  								= 0x010105,
	USER_INFO  										= 0x010106,
	USER_INFO_LIST  								= 0x010107,

	USER_CHAT  										= 0x010400,
	USER_EXPRESSION  								= 0x010401,
	USER_MULTIMEDIA  								= 0x010402,

	BUY_PROPERTY  									= 0x010302,
	USE_PROPERTY  									= 0x010304,
	SEND_TRUMPET  									= 0x010307,
	PROPERTY_CONFIG									= 0x010300,
	PROPERTY_REPOSITORY								= 0x010301,
	TRUMPET_SCORE 									= 0x010303,
	USE_PROPERTY_BRODCAST 							= 0x010305,
	PROPERTY_REPOSITORY_UPDATE						= 0x010306,
	TRUMPET_MSG  									= 0x010308,

	USER_SITDOWN  									= 0x010200,
	GAME_OPTION										= 0x010202,
	USER_STAND_UP									= 0x010204,
	USER_READY										= 0x010206,
	USER_LOOK_ON									= 0x010207,
	KICK_USER										= 0x010208,


	AUTO_MATCH										= 0x010230,

	USER_STATUS  									= 0x010201,
	GAME_STATUS  									= 0x010203,
	ALL_PLAYER_LEFT  								= 0x010205,
	KICK_USER_NOTIFY  								= 0x010209,
	USERSLOOKONINFO									= 0x01020A,

	WITHDRAW_BANK									= 0x010701,
	QUERY_BANK										= 0x010702,

	USER_SCORE_PUSH  								= 0x01ff01,
	PAY_MENT_NOTIFY  								= 0x01ff02,

	ADD_LOTTERY_SCORE								= 0x010900,
	LOTTERY_AWARD									= 0x010901,
	LOTTERY_SINK_INFO								= 0x010902,

	
    SUB_C_VOUCHER_BET               =            0x051000, --"doudizhu.c2s.CMD_C_VoucherBetting_Pro",   --用户投注
    SUB_C_QUERY_VOUCHER             =            0x010802, --"gameServer.mission.c2s.QueryVoucherInfo",     --查询池中礼券数量
    SUB_C_QUERY_VOUCHER_PLAYER      =            0x010804, --"gameServer.mission.c2s.QueryVoucherInfo",     --最新礼券中奖玩家查询
    SUB_C_QUERY_VOUCHER_COUNT       =            0x010805, --"gameServer.mission.c2s.QueryVoucherInfo",     --最新玩家中奖次数查询
                
    SUB_S_WINTASK                   =            0x010800, --"gameServer.mission.s2c.userWinTaskCalc",      --胜利类型任务奖励及次数回包
    SUB_S_VOUCHER_DRAWING           =            0x010801, --"gameServer.mission.s2c.VoucherDrawing",       --礼券开奖
    SUB_S_VOUCHER_COUNT             =            0x010802, --"gameServer.mission.s2c.QueryVoucherCount",    --查询池中礼券数量
    SUB_S_VOUCHER_BET               =            0x010803, --"gameServer.mission.s2c.VoucherBetting",       --礼券投注

    SUB_S_NEARLYDRAWED_USERLIST     =            0x010804, --"gameServer.mission.s2c.NearlyDrawedUserList", --最新礼券中奖玩家
    SUB_S_USERDRAWED_COUNTLIST      =            0x010805, --"gameServer.mission.s2c.UserDrawedCountList",  --玩家中奖次数
    SUB_S_MISSION_COUNTINFO         =            0x010806, --"gameServer.mission.s2c.MissionCountInfo",     --打出大牌类型任务,胜利类型任务奖励及次数回包

}