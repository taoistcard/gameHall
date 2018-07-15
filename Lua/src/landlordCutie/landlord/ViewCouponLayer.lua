--
-- Author: <zhaxun>
-- Date: 2015-08-03 15:10:13
--
-- 投注界面--金币场
-- Author: <zhaxun>
-- Date: 2015-05-28 09:19:22
--
local GameItemFactory = require("commonView.GameItemFactory"):getInstance()

local EffectFactory = require("commonView.DDZEffectFactory")

local ViewCouponLayer = class( "ViewCouponLayer", function() return display.newLayer() end)

function ViewCouponLayer:ctor(param)
	self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)

    self.is1v1 = param and param.is1v1
    self.hisInfo = nil
    self.lastMessage = nil

	-- 礼券
    local liquan = require("commonView.CouponView").new({lisenter=handler(self,self.onClick)})
    liquan:align(display.CENTER, 710, 530)
    self:addChild(liquan)
    liquan:setValide(true)

    -- 效果
	local ani = EffectFactory:getInstance():getCouponLightAnimation()
    display.newSprite():addTo(liquan):runAction(cc.RepeatForever:create(cc.Animate:create(ani)))



	--txt
	local bgNum = display.newSprite("liquan/bg_num.png"):addTo(liquan):align(display.CENTER, 70, -40)
	local titleword = display.newTTFLabel({text = "0张",
                            size = 20,
                            color = cc.c4b(254, 235, 0, 255),
                            align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                        })

    -- titleword:setString("设置")
    -- titleword:setFontSize(24)
    -- titleword:setColor(cc.c3b(254, 234, 113))
    titleword:enableOutline(cc.c4b(254, 235, 0, 255), 2)
    titleword:setPosition(39, 14)
    titleword:addTo(bgNum)
    self.couponCount = titleword


    --投注按钮
 	local button = ccui.Button:create("common/button_green.png","common/button_green.png");
    button:setScale9Enabled(false);
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("投注");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
            	onUmengEvent("1047")
                self:onClickBet()
            end
        end
        )
    button:addTo(self)
    button:align(display.CENTER, 710, 380)
    self.btnBet = button

    --投注提示
    local bgNum = display.newSprite("liquan/bg_tip1.png"):addTo(button):align(display.CENTER, 110, 100)

    local tipLabel = display.newTTFLabel({text = "投注需要1000金币噢！",
                            size = 24,
                            color = cc.c4b(255, 255, 255, 255),
                            align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                        })
    tipLabel:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    tipLabel:setPosition(80, 100)
    tipLabel:addTo(button)

    local timeLabel = display.newTTFLabel({text = "5s",
                            size = 26,
                            color = cc.c4b(183, 255, 0, 255),
                            align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                        })
    timeLabel:enableOutline(cc.c4b(183, 255, 0, 255), 2)
    timeLabel:setPosition(220, 100)
    timeLabel:addTo(button)
    self.timeLabel = timeLabel

	self:createUI()
end

function ViewCouponLayer:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MissionInfo, "MissionInfo", handler(self, self.onServerMessage));

    self:queryHisCouponInfo()
    self:qureyTotalCoupon()
end

function ViewCouponLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
	if self.tickHandle then
		scheduler.unscheduleGlobal(self.tickHandle)
	end
end

function ViewCouponLayer:createUI()
	local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setOpacity(153)
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)
	self.maskLayer = maskLayer
	self.maskLayer:hide()

	local file = nil
	local vx = -100
	local vy = 50
	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
	if true then
		--光圈
		local effect = display.newSprite("common/effect_light.png"):addTo(maskLayer):align(display.CENTER, display.cx, display.cy + 220)
		effect:scale(2.0)
		effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
		
		--窗体
		local bgSize = cc.size(710, 500)
        local bgSprite = ccui.ImageView:create("common/pop_bg.png");
	    bgSprite:setScale9Enabled(true);
	    bgSprite:setContentSize(bgSize);
	    bgSprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
	    bgSprite:addTo(maskLayer)
	    self.bgImage = bgSprite

	
		local leftLoudspeaker = display.newSprite("#animationSuccess1.png")
		leftLoudspeaker:setPosition(bgSize.width/2-150, bgSize.height)
		leftLoudspeaker:addTo(bgSprite)

		local animation = EffectFactory:getInstance():getAnimationSuccess()
		cc.Animate:create(animation)

		leftLoudspeaker:runAction(cc.RepeatForever:create(
                                    cc.Sequence:create(
                                        cc.Animate:create(animation),
                                        cc.DelayTime:create(0.0))))

		local rightLoudspeaker = display.newSprite("#animationSuccess1.png")
		rightLoudspeaker:setPosition(bgSize.width/2+150, bgSize.height)
		rightLoudspeaker:addTo(bgSprite)
		rightLoudspeaker:setScaleX(-1)
		local animation2 = EffectFactory:getInstance():getAnimationSuccess()
		cc.Animate:create(animation2)

		rightLoudspeaker:runAction(cc.RepeatForever:create(
                                    cc.Sequence:create(
                                        cc.Animate:create(animation2),
                                        cc.DelayTime:create(0.0))))

		--title
		local title = display.newSprite("common/title.png")
		title:addTo(bgSprite,2)
		title:align(display.CENTER, bgSize.width/2, bgSize.height + 10)

		--txt
    	local titleword = display.newTTFLabel({text = "礼券池",
                                size = 50,
                                color = cc.c4b(254, 235, 0, 255),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })

	    -- titleword:setString("设置")
	    -- titleword:setFontSize(24)
	    -- titleword:setColor(cc.c3b(254, 234, 113))
	    titleword:enableOutline(cc.c4b(137,0,167,200), 2)
	    titleword:setPosition(153, 74)
	    title:addChild(titleword)


	    --关闭按钮
        local exit = ccui.Button:create("common/close.png");
	    exit:setPosition(cc.p(680,480));
	    exit:addTo(bgSprite);
	    exit:setPressedActionEnabled(true);
	    exit:addTouchEventListener(
	        function(sender,eventType)
	            if eventType == ccui.TouchEventType.ended then

	                self:onClickClose()

	            end
	        end
	    )

	    --特效
	    local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/XS.png");
		local light = cc.ParticleSystemQuad:create("effect/XS.plist");
		light:setTexture(texture2d);
		light:align(display.CENTER, bgSize.width/2, bgSize.height + 10)
		light:setScale(2)
		light:addTo(bgSprite,1)

		-- local EffectFactory = require("commonView.DDZEffectFactory");
		-- local commodityLightAnimation = EffectFactory:getInstance():getCommodityAnimation();
		-- commodityLightAnimation:setPosition(145,45);
		-- title:addChild(commodityLightAnimation);
		-- --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
		-- commodityLightAnimation:getAnimation():setSpeedScale(0.3);

	    local titleLightAnimation = EffectFactory:getInstance():getShopAnimation();
	    titleLightAnimation:setPosition(cc.p(150,50));
	    title:addChild(titleLightAnimation);


	    --下注说明
	    contentBG = display.newSprite("liquan/lq_tip0_bg.png")
	    contentBG:addTo(bgSprite)
	    contentBG:align(display.CENTER, bgSize.width/2, 338)

	    --礼券数量
	    local contentBG = display.newSprite("liquan/lq_count_bg.png")
	    contentBG:addTo(bgSprite)
	    contentBG:align(display.CENTER, bgSize.width/2, 420)

	    display.newSprite("liquan/lq_icon1.png"):addTo(contentBG):align(display.CENTER, 65, 40)
	    local txtCountLQ = display.newBMFontLabel({
                    text = "0张",
                    font = "fonts/lqc-shuzi.fnt",
                    x = 295,
                    y = 40,
                })
	    -- txtCountLQ:enableOutline(cc.c4b(137,0,167,200), 2)
	    -- txtCountLQ:setPosition(0, 33)
	    txtCountLQ:addTo(contentBG)
	    self.txtCountLQ = txtCountLQ

	    --开奖说明
	 	contentBG = display.newSprite("liquan/lq_tip1_bg.png")
	    contentBG:addTo(bgSprite)
	    contentBG:align(display.CENTER, bgSize.width/2, 230)

	    --历史信息
		contentBG = display.newSprite("liquan/lq_his_bg.png")
	    contentBG:addTo(bgSprite)
	    contentBG:align(display.CENTER, bgSize.width/2, 100)


	    self.hisInfo = {}
	    for i=1,3 do
	    	local info = {}

	    	local pos = cc.p(58 + (i-1)*190, 47)
	    	--头像
	    	local headView = require("commonView.GameHeadView").new(i);
		    
		    headView:setPosition(pos);
		    headView:setVipHead(i,i);
		    headView:addTo(contentBG);
		    headView:scale(0.8)
		    -- headView:hide()

			----昵称
        	local nickName = display.newTTFLabel({text = "",
                        size = 20,
                        color = cc.c4b(254, 235, 0, 255),
                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                    })

		    nickName:enableOutline(cc.c4b(254, 235, 0, 255), 2)
		    nickName:align(display.LEFT_CENTER, pos.x+50, pos.y+25)
		    nickName:addTo(contentBG)

			----数量
			local coupon = display.newSprite("liquan/lq_icon0.png"):addTo(contentBG):align(display.CENTER, pos.x+70, pos.y-25)
        	local count = display.newTTFLabel({text = "",
                        size = 22,
                        color = cc.c4b(254, 255, 255, 255),
                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                    })

		    count:enableOutline(cc.c4b(200,0,0,200), 2)
		    count:align(display.LEFT_CENTER, pos.x+90, pos.y-10)
		    count:addTo(contentBG)

		    ----insert to table
		    info.headView = headView:hide()
		    info.nickName = nickName:hide()
		    info.count = count:hide()
		    info.coupon = coupon:hide()
		    table.insert(self.hisInfo, info)
		    
	    end

	    --banner
	    display.newSprite("liquan/banner_l.png"):addTo(bgSprite):align(display.CNETER,0,120)
	    display.newSprite("liquan/banner_r.png"):addTo(bgSprite):align(display.CNETER,bgSize.width,180)

	end
end

function ViewCouponLayer:queryHisCouponInfo()
	print("queryHisCouponInfo")
	MissionInfo:sendQueryNearlyDrawedUserList()
end

function ViewCouponLayer:refreshHisInfo(param)
	--self.txtCountLQ--礼券数量
	--self.hisInfo[i]--历史玩家
	--[[
	//最新礼券中奖玩家
	message tag_NearlyDrawedUser_Pro
	{
		required int32							dwUserID		= 1;		// UserID
		required int32							wFaceID			= 2;		// 头像
		required int32							cbMemberOrder		= 3;		// 会员 
		required string							szNickName		= 4;		// 昵称
		required string							szUesrHeadFileName	= 5;		// 自定义头像
		required int32							wGameType		= 6;		// 游戏类型  1:斗地主 
		required int32							dwAwardItemCount	= 7;		// 礼券数量
		required string							szTokenID		= 8;
	}

	//最新礼券中奖玩家查询
	message CMD_GR_NearlyDrawedUser_Pro
	{
		repeated tag_NearlyDrawedUser_Pro				arrUserList		= 1 ;		//最新礼券中奖玩家列表
	}
	]]
	-- dump(self.lastMessage, "===lastMessage==")
	if not self.lastMessage then
		return
	end

	for k,v in ipairs(self.hisInfo) do
		local info = self.lastMessage.arrUserList[k]
		print("count of arrUserList = ", #self.lastMessage.arrUserList)
		if info then
			
			print("8888888888",k,info.dwUserID,info.wFaceID,info.cbMemberOrder,info.szNickName,info.szUesrHeadFileName,info.wGameType,info.dwAwardItemCount,info.szTokenID)

			v.nickName:show()
            v.nickName:setString(FormotGameNickName(info.szNickName,5))
            
            v.count:show()
            v.count:setString(info.dwAwardItemCount.."张")

			v.headView:show()
            v.headView:setVipHead(info.cbMemberOrder, 1)
			
			v.coupon:show()

	        local tokenID = info.szTokenID
	        local url = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)

	        local md5 = info.szUesrHeadFileName
	        local localmd5 = cc.Crypto:MD5File(url)

	        if localmd5 ~= md5 and info.wFaceID == 999 and param == 1 then
	            PlatformDownloadAvatarImage(tokenID, md5)
	        end
			v.headView:setNewHead(info.wFaceID, tokenID,md5)

		else
			v.nickName:hide()
			v.count:hide()
			v.headView:hide()
			v.coupon:hide()
		end
	end

end

function ViewCouponLayer:onClickClose()
	self:setLocalZOrder(2)

	if self.maskLayer and self.maskLayer:isVisible() then
		self.maskLayer:hide()
	end
end

function ViewCouponLayer:onServerMessage(data)
	local event = {}
    event.subId = MissionInfo.mainID
    event.data = MissionInfo.missionInfo

    if event.subId == CMD_GAME.SUB_S_VOUCHER_BET then--礼券投注
        print("礼券投注返回")
        local msg = protocol.gameServer.gameServer.mission.s2c_pb.VoucherBetting()
        msg:ParseFromString(event.data)
        self:processBetCallBack(msg)

    elseif event.subId == CMD_GAME.SUB_S_VOUCHER_DRAWING then----礼券开奖
    	print("礼券开奖返回")
        local msg = protocol.gameServer.gameServer.mission.s2c_pb.VoucherDrawing()
        msg:ParseFromString(event.data)
        self:processOpenVoucherCallBack(msg)
        --更新奖池信息
	    self:queryHisCouponInfo()
	    self:qureyTotalCoupon()

    elseif event.subId == CMD_GAME.SUB_S_VOUCHER_COUNT then----礼券查询总量
		print("礼券查询返回")
        local msg = protocol.gameServer.gameServer.mission.s2c_pb.QueryVoucherCount()
        msg:ParseFromString(event.data)
        self:processQureyVoucherCallBack(msg)

    elseif event.subId == CMD_GAME.SUB_S_NEARLYDRAWED_USERLIST then
		print("历史奖励查询返回")
        local msg = protocol.gameServer.gameServer.mission.s2c_pb.NearlyDrawedUserList()
        msg:ParseFromString(event.data)
        self.lastMessage = msg
        self:refreshHisInfo(1)

    end
end

function ViewCouponLayer:processBetCallBack(msg)
	--[[
{
	required int32				dwUserID		= 1;		//用户 I D
	required int64				lBettingScore		= 2;		//投注花费
	required int32				lResultCode		= 3;		//操作代码
	required string				szDescribeString	= 4;		//描述消息
}]]
	print(msg.dwUserID)
	print(msg.lBettingScore)
	print(msg.lResultCode)
	print(msg.szDescribeString)

	-- dump(msg, "礼券下注结果")

	if msg and msg.lResultCode == 0 then
		self:showBetTip()

		-- local userInfo = DataManager:getMyUserInfo()
		-- userInfo.tagUserInfo.lScore = userInfo.score-1000
		
		self:refreshSceneUI()
		self.btnBet:hide()
	end

end

function ViewCouponLayer:processOpenVoucherCallBack(msg)
	
--[[{
	required int32				dwUserID		= 1;		//用户 I D
	required int32				lResultCode		= 2;		//操作代码
	required string				szDescribeString	= 3;		//描述消息
	required int32				dwTotalVoucherCount	= 4;		//礼券池数量
	required int32				cbAwardItemType		= 5;		//开奖类型 1: 金币  2: 礼券
	required int32				dwAwardItemCount	= 6;		//奖励数量
	required int32				wAwardType		= 7;		//奖励类型
}]]

	print("礼券开奖结果---------------")
	print("msg.dwUserID", msg.dwUserID)
	print("msg.lResultCode", msg.lResultCode)
	print("msg.szDescribeString", msg.szDescribeString)
	print("msg.dwTotalVoucherCount", msg.dwTotalVoucherCount)
	print("msg.cbAwardItemType", msg.cbAwardItemType)
	print("msg.dwAwardItemCount", msg.dwAwardItemCount)

	if msg and msg.lResultCode == 0 then
		print("AccountInfo.present", AccountInfo.present)

		AccountInfo:setPresent(AccountInfo.present)--+msg.dwAwardItemCount)

		self:refreshSceneUI()

		self:playEffect()
		
	end
end

function ViewCouponLayer:processQureyVoucherCallBack(msg)
	--[[message CMD_GP_QueryVoucherCount_Pro
	{
		required int64				lVoucherInPoolCount	= 1;		// 池中礼券数量
		required int32				dwVoucherPoolType	= 2;		// 礼券池类型 1:斗地主 2:牛牛
	}]]
	-- dump(getmetatable(msg), "礼券查询结果") 
	if self.couponCount and msg and msg.lVoucherInPoolCount and msg.dwVoucherPoolType==1 then
		-- Hall.showTips(msg.lVoucherInPoolCount .. "张", 1)
		print(msg.lVoucherInPoolCount .. "张", 1)
		self.couponCount:setString(msg.lVoucherInPoolCount .. "张")
		self.txtCountLQ:setString(msg.lVoucherInPoolCount .. "张")
	end
end

function ViewCouponLayer:onClick()
	self:setLocalZOrder(13)

	if self.maskLayer and self.maskLayer:isVisible() then
		self.maskLayer:hide()
	elseif self.maskLayer and not self.maskLayer:isVisible() then
		self:queryHisCouponInfo()

		self.maskLayer:show()
	end

end

function ViewCouponLayer:onClickBet()
	print("ViewCouponLayer:onClickBet")
	if self.is1v1 then
		MissionInfo:sendVoucherBet2()
	else
		MissionInfo:sendVoucherBet()
	end
	
end

function ViewCouponLayer:qureyTotalCoupon()
	print("ViewCouponLayer:qureyTotalCoupon")
	MissionInfo:sendQueryVoucherCount()
end

function ViewCouponLayer:showBetTip()
	--359,112
	local bgSprite = display.newSprite("liquan/bg_tip.png"):addTo(self):align(display.CENTER, display.cx, display.cy)

	--投注提示
    local tipLabel = display.newTTFLabel({text = "恭喜您投注成功！",
                            size = 35,
                            color = cc.c4b(255, 235, 0, 255),
                            align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                        })
    tipLabel:enableOutline(cc.c4b(255, 235, 0, 255), 3)
    tipLabel:setPosition(180, 56)
    tipLabel:addTo(bgSprite)

    bgSprite:runAction(cc.Sequence:create(
    		cc.FadeIn:create(0.2),
    		cc.DelayTime:create(1.0),
    		cc.CallFunc:create(function() bgSprite:removeSelf() end)
    	))

end

function ViewCouponLayer:playEffect()
	self:setLocalZOrder(13)
	local armature = EffectFactory:getInstance():getCouponEffect();
    armature:setPosition(cc.p(display.cx, display.bottom+100))
    self:addChild(armature)
    --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
    -- armature:getAnimation():setSpeedScale(0.3);

	armature:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex)
            if evt == "end" then
            	self:setLocalZOrder(2)
                armature:removeFromParent()
            end
        end)
	armature:getAnimation():playWithIndex(0)

end

function ViewCouponLayer:setBetEnable(bEnable)

	local time = 5
    local scheduler = require("framework.scheduler")

	if bEnable then
		self.btnBet:show()

	    local function tick(dt)
	        time = time - 1
			self.timeLabel:setString(time .. "s")

	        if time <= 0 then
	            scheduler.unscheduleGlobal(self.tickHandle)
	            self.tickHandle = nil
	        end
	    end 
		self.timeLabel:setString(time .. "s")
	    self.tickHandle = scheduler.scheduleGlobal(tick, 1) -- 间隔一定时间调用

	else
		if self.tickHandle then
			scheduler.unscheduleGlobal(self.tickHandle)
			self.tickHandle = nil
		end

		self.btnBet:hide()
	end
end

function ViewCouponLayer:refreshSceneUI()
	self:getParent():getParent():initSeatInfo()
end

return ViewCouponLayer