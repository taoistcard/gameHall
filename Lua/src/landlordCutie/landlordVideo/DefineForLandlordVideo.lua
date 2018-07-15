LandlordVideoCmd = {
	--主命令200 子命令列表
	SUB_S_GAME_FREE				 = 99,									--游戏空闲
	SUB_S_GAME_START			 = 100,									--游戏开始
	SUB_S_PLACE_JETTON			 = 101,									--用户下注
	SUB_S_GAME_END				 = 102,									--游戏结束
	SUB_S_APPLY_BANKER			 = 103,									--申请庄家
	SUB_S_CHANGE_BANKER			 = 104,									--切换庄家
	SUB_S_CHANGE_USER_SCORE		 = 105,									--更新积分
	SUB_S_SEND_RECORD			 = 106,									--游戏记录
	SUB_S_PLACE_JETTON_FAIL		 = 107,									--下注失败
	SUB_S_CANCEL_BANKER			 = 108,									--取消申请
	SUB_S_ADMIN_COMMDN			 = 109,									--系统控制
	SUB_S_SEND_RECORD_EX		 = 110,									--游戏记录(扩展)
	SUB_S_SEND_USERS_SCORE_RESULT= 111,							        --每个玩家输赢记录

	SUB_C_PLACE_JETTON           = 1
}

LandlordVideoGameStatus = {
	--游戏状态
    GAME_SCENE_FREE            = Define.GAME_STATUS_FREE, 
    GAME_SCENE_PLACE_JETTON    = Define.GAME_STATUS_PLAY, 
    GAME_SCENE_GAME_END        = Define.GAME_STATUS_PLAY+1
}

LandlordEvent = {
	SHOW_ROOMCHANGELAYER = "SHOW_ROOMCHANGELAYER",
	CHANGE_VIDEO_GAMEROOM = "CHANGE_VIDEO_GAMEROOM",
}