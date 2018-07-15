
CMD_ZJH = {
    SUB_S_GAME_START                =            0x050009,                                 --游戏开始
    SUB_S_ADD_SCORE                 =            0x050000,                                 --加注结果
    SUB_S_GIVE_UP                   =            0x050002,                                 --放弃跟注
    SUB_S_GAME_END                  =            0x05000B,                                 --游戏结束
    SUB_S_COMPARE_CARD              =            0x050003,                                 --比牌跟注
    SUB_S_COMPARE_ALL               =            0x050010,                                   --用户全场比牌
    SUB_S_GAMECELLINFO              =            0x050011,                                --变更底注


    SUB_S_LOOK_CARD                 =            0x050004,                                 --看牌跟注

    SUB_S_OPEN_CARD                 =            0x050005,                                 --开牌消息
    SUB_S_WAIT_COMPARE              =            0x050006,                                 --等待比牌
    SUB_S_CLOCK                     =            0x05000A,                                 --用户时钟
    SUB_S_SHOW_CARD                 =            0x050008,                                 --用户亮牌


    SUB_C_ADD_SCORE                  =             0x050000,                                   --用户加注
    SUB_C_GIVE_UP                    =             0x050002,                                   --放弃跟注
    SUB_C_COMPARE_CARD               =             0x050003,                                   --比牌消息
    SUB_C_LOOK_CARD                  =             0x050004,                                   --看牌消息
    SUB_C_OPEN_CARD                  =             0x050005,                                   --开牌消息
    SUB_C_WAIT_COMPARE               =             0x050006,                                   --等待比牌
    SUB_C_FINISH_FLASH               =             0x050007,                                   --完成动画
    SUB_C_SHOW_CARD                  =             0x050008,                                   --用户亮牌
    SUB_C_COMPARE_ALL                =             0x050010,                                   --用户全场比牌

    SUB_S_STATUSFREE     			 = 				0x05000c,
    SUB_S_STATUSPLAY       			 = 			    0x05000D,
        --礼券
    SUB_C_USER_BET                     =               9,                                --用户投注
}