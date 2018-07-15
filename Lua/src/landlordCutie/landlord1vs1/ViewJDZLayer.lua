--
-- Author: <zhaxun>
-- Date: 2015-05-22 09:25:39
--

local GameItemFactory = require("commonView.GameItemFactory"):getInstance()


local ViewJDZLayer = class( "ViewJDZLayer", function() return display.newNode() end )

local posTimer = {
	[1] = cc.p(0,0),
	[2] = cc.p(0,0),
	[3] = cc.p(0,0),
}
ViewJDZLayer.buttonStatus = 0 --0叫地主1抢地主2让先

function ViewJDZLayer:switchChairID()
    if self.myChairID == 1 then
        self.nextID = 2
        self.preID = 3
    elseif self.myChairID == 2 then
        self.nextID = 1
        self.preID = 3
    else
        print("ViewCardLayer 座位分配失败！", self.myChairID)
    end
end

function ViewJDZLayer:ctor(param)

	self.playConfig = param.config
	self.playScene = param.scene;
	self.data = param.data

	local myChairID = DataManager:getMyChairID()
	self.myChairID = myChairID
	print("self.myChairID" ,self.myChairID)
    self:switchChairID()


	posTimer[self.myChairID] = cc.p(display.cx, display.cy -10)
	posTimer[self.nextID] = cc.p(display.cx + 330, display.cy + 50)
	-- posTimer[self.preID] = cc.p(display.cx - 380, display.cy + 100)

	-- self.btnJF = {}
	-- self.btnJF[1] = GameItemFactory:getBtnJiaoFen(1, function() self:onClickJDZ(1) end):addTo(self):align(display.CENTER, display.cx-50, display.cy - 50)
	-- self.btnJF[2] = GameItemFactory:getBtnJiaoFen(2, function() self:onClickJDZ(2) end):addTo(self):align(display.CENTER, display.cx+100, display.cy - 50)
	-- self.btnJF[3] = GameItemFactory:getBtnJiaoFen(3, function() self:onClickJDZ(3) end):addTo(self):align(display.CENTER, display.cx+250, display.cy - 50)
	self.btnBJDZ = GameItemFactory:getBtnYellowByText(function() self:onClickBJDZ() end,"不叫"):addTo(self):align(display.CENTER, display.cx+120, display.cy - 10)
	self.btnJDZ = GameItemFactory:getBtnBlueByText(function() self:onClickJDZ() end,"叫地主"):addTo(self):align(display.CENTER, display.cx-120, display.cy - 10)
	self.timer = require("commonView.CCTimer").new():addTo(self)
	self.qjc = display.newSprite("landlord1vs1/qjc.png"):addTo(self):align(display.CENTER, display.cx+10, display.cy -65)--display.newSprite landlord1vs1/qjc.png
-- self.qjc1 = display.newSprite("sound/qjc.png"):addTo(self):align(display.CENTER, display.cx-120, display.cy + 230)
	-- self:addChild(self.qjc)
	-- self.qjc:setPosition( display.cx, display.cy - 80)


	self.qdzTxtCount =  display.newBMFontLabel({
	        text = 0,
	        font = "fonts/jinbiSZ.fnt",
	    })
    self.qdzTxtCount:addTo(self):align(display.CENTER, display.cx+10, display.cy - 65)
    -- self.sprJF={}
    -- self.sprJF[self.myChairID] = display.newSprite("play3/bujiao.png"):addTo(self):align(display.CENTER, display.cx, display.cy):hide()
    -- self.sprJF[self.nextID] = display.newSprite("play3/bujiao.png"):addTo(self):align(display.CENTER, display.cx + 300, display.cy + 105):hide()
    -- self.sprJF[self.preID] = display.newSprite("play3/bujiao.png"):addTo(self):align(display.CENTER, display.cx - 300, display.cy + 105):hide()

    self.maxFen = 0;

    self.hasJDZ = false;--在发牌过程中有人托管，会直接发送不叫，跳过showJDZ
    self.buttonStatus = 0
end

function ViewJDZLayer:onEnter()

end

function ViewJDZLayer:onExit()

end

function ViewJDZLayer:showButtons(bVisible)
	print("！！！！！！！最大叫分", self.maxFen)
	-- for k,v in ipairs(self.btnJF) do
	-- 	if bVisible and k > self.maxFen then
	-- 		v:show()
	-- 	else
	-- 		v:hide()
	-- 	end
	-- end
end

function ViewJDZLayer:showJDZ(msg)
--[[
	required int32							wStartUser 		= 1;			//开始玩家
	required int32				 			wCurrentUser 		= 2;			//当前玩家
	required int32							cbValidCardData 	= 3;			//明牌扑克
	required int32							cbValidCardIndex 	= 4;			//明牌位置
	repeated int32							cbCardData 		= 5;			//扑克列表
]]
	print("开始玩家",msg.wStartUser,"当前玩家",msg.wCurrentUser,self.hasJDZ)

	if self.hasJDZ then
		return
	end

	self.qjc:setVisible(false)
	self.qdzTxtCount:setString("");

	--显示叫分按钮
	if msg.wCurrentUser == self.myChairID then
		self:showButtons(true)
		self.btnJDZ:show()
		self.btnBJDZ:show();
	else
		self:showButtons(false)
		self.btnJDZ:hide()
		self.btnBJDZ:hide()
	end

	--定时闹钟
	self.timer:setPosition(posTimer[msg.wCurrentUser])
	self.timer:startTimer(self.playConfig.cbTimeCallScore, function() print("叫分超时") end)

	--默认地主
	self.dizhu = msg.wCurrentUser
end

function ViewJDZLayer:showQDZ(msg,count)
	self.hasJDZ = true
--[[
	required int32				 			wCurrentUser 		= 1;			//下一轮谁到叫地主
	required int32							wCallScoreUser 		= 2;			//当前叫分玩家
	required int32							cbCurrentScore 		= 3;			//当前倍数
	required int32							cbUserCallScore		= 4;			//这一把是否 叫/抢 (地主)0不叫，1叫
		required int32							cbRobTimes		= 5;			//抢地主次数
	]]
	print("ViewJDZLayer:showQDZ-当前叫分玩家", msg.wCallScoreUser, "当前倍数", msg.cbCurrentScore, 
		"这一把是否 叫/抢 (地主)", msg.cbUserCallScore, "下一轮谁到叫地主", msg.wCurrentUser,"抢地主次数",msg.cbRobTimes)

	--begin----------播放声音
	local file = nil
	local index = 0
	local flag_bujiao = 0--255
	if msg.cbUserCallScore == flag_bujiao then
		index = 0
	else
		index = msg.cbUserCallScore
	end

	local userInfo = DataManager:getUserInfoInMyTableByChairID(msg.wCallScoreUser)
	if userInfo then
		-- SoundManager.playEffectByName(index .. "fen", userInfo.gender)
	end
	
	if msg.cbUserCallScore ~= flag_bujiao then
		self.maxFen = msg.cbUserCallScore
		self.dizhu = msg.wCallScoreUser
	end
	---抢地主次数更新---
	if msg.cbRobTimes>0 then
		self.qjc:setVisible(true)
		self.qdzTxtCount:setString(msg.cbRobTimes);
	end

    --对手叫地主-播放声音
    if msg.wCallScoreUser == self.myChairID then
    --todo
    else
    	local qOrj = 0--0叫地主声效1抢地主声效
    	if msg.cbRobTimes > 0 then
    		qOrj = 1
    	end
        self:soundJDZ(qOrj,msg.cbUserCallScore)
    end
    
    if msg.wCurrentUser == 65535 then
        print("msg.wCallScoreUser ",msg.wCallScoreUser,"== self.myChairID",self.myChairID,"cbUserCallScore=",msg.cbUserCallScore)
        local isfarmerfirst = (msg.wCallScoreUser == self.myChairID and msg.cbUserCallScore == 1) or (msg.wCallScoreUser ~= self.myChairID and msg.cbUserCallScore == 0)
    	if  isfarmerfirst then
    		self:showFarmerFirst(msg)
    		return false
    	else
            
	        print("叫分结束, 进入让先阶段！","self.playConfig.cbTimeHeadOutCard",self.playConfig.cbTimeHeadOutCard,"cbTimeFarmerFirst",self.playConfig.cbTimeFarmerFirst)
	        -- self:hide()
	        self.btnJDZ:hide()
			self.btnBJDZ:hide()
	        self.timer:setPosition(cc.p(display.cx + 380, display.cy + 100))
			self.timer:startTimer(self.playConfig.cbTimeFarmerFirst, function() print("等待对方让先超时") end)
	        return true, self.dizhu
    	end

    end

	--显示叫分按钮
	if msg.wCurrentUser == self.myChairID then--//下一轮谁到叫地主
		self:showButtons(true, msg.cbUserCallScore)
		if msg.cbRobTimes>0 or msg.cbUserCallScore == 1 then
			self.btnBJDZ = GameItemFactory:getBtnYellowByText(function() self:onClickBJDZ() end,"不抢"):addTo(self):align(display.CENTER, display.cx+120, display.cy - 10)
			self.btnJDZ = GameItemFactory:getBtnBlueByText(function() self:onClickJDZ() end,"抢地主"):addTo(self):align(display.CENTER, display.cx-120, display.cy - 10)
			self.buttonStatus = 1
		end
		self.btnJDZ:show();
		self.btnBJDZ:show();
		
		-- self.qjc:setVisible(false)
		-- self.qdzTxtCount:setString("");
	else
		self:showButtons(false)
		-- self.btnBJDZ = GameItemFactory:getBtnYellowByText(function() self:onClickBJDZ() end,"叫地主"):addTo(self):align(display.CENTER, display.cx-120, display.cy - 50)
		-- self.btnJDZ = GameItemFactory:getBtnBlueByText(function() self:onClickBJDZ() end,"不叫"):addTo(self):align(display.CENTER, display.cx-120, display.cy - 50)
		self.btnJDZ:hide()
		self.btnBJDZ:hide()
		
	end


	--定时闹钟
	self.timer:setPosition(posTimer[msg.wCurrentUser])
	self.timer:startTimer(self.playConfig.cbTimeCallScore, function() print("叫分超时") end)


	--显示叫分信息
	-- if msg.wCallScoreUser then
	-- 	if msg.cbUserCallScore == flag_bujiao then
	-- 		file = "play3/bujiao.png"
	-- 	else
	-- 		file = "play3/" .. msg.cbUserCallScore .. "fen.png"
	-- 	end
	-- 	self.sprJF[msg.wCallScoreUser]:setTexture(file)
	-- 	self.sprJF[msg.wCallScoreUser]:show()
	-- end

	return false, self.dizhu
end
--地主让先
function ViewJDZLayer:showFarmerFirst(msg)


	self.btnBJDZ = GameItemFactory:getBtnYellowByText(function() self:farmerFirst(1) end,"让先"):addTo(self):align(display.CENTER, display.cx-120, display.cy - 10)
	self.btnJDZ = GameItemFactory:getBtnBlueByText(function() self:farmerFirst(0) end,"不让"):addTo(self):align(display.CENTER, display.cx+120, display.cy - 10)
	self.btnJDZ:show();
	self.btnBJDZ:show();
	self.buttonStatus = 2
	--定时闹钟
	print("self.playConfig.cbTimeFarmerFirst",self.playConfig.cbTimeFarmerFirst,"msg.wCallScoreUser",msg.wCallScoreUser,"self.playConfig.cbTimeCallScore",self.playConfig.cbTimeCallScore,"cbTimeOutCard",self.playConfig.cbTimeOutCard,"cbTimeHeadOutCard",self.playConfig.cbTimeHeadOutCard)
	self.timer:setPosition(posTimer[self.myChairID])
	self.timer:startTimer(self.playConfig.cbTimeFarmerFirst,function() print("让先超时");self:farmerFirstTimeOut() end)--self.playConfig.cbTimeHeadOutCard-self.playConfig.cbTimeOutCard,

end
--让先超时处理
function ViewJDZLayer:farmerFirstTimeOut()
	-- body
	--非托管状态下才发送，否则会导致托管状态失效
	if not self:isTuoGuan(self.myChairID) then
		self:farmerFirst(0)
	end
end

function ViewJDZLayer:farmerFirst(isFarmerFirst)
	-- if isFarmerFirst == 0 then

	-- 	self.playScene:openDiPai()
	-- 	self:hide();
	-- 	-- return
	-- end
	--[[
   	local wMainID = CMD_GameServer.MDM_GF_GAME
    local wSubID = CMD_DDZ_1V1.SUB_C_FARMERFIRST
    local data = protocol.doudizhu.errendoudizhu.s2c_pb.CMD_C_FarmerFirst_Pro()
    data.bFarmerFirst = isFarmerFirst

    local pData = data:SerializeToString()
    local pDataLen = string.len(pData)

    GameCenter:sendData(wMainID,wSubID,pData,pDataLen)
    ]]
    DoudizhuInfo:sendFarmerFirst(isFarmerFirst)
    self.timer:stopTimer();
    self:hide();

    -- Hall.showTips("让先",1)
end
function ViewJDZLayer:onClickJDZ(index)

	SoundManager.playSound("sound/buttonclick.mp3")

    local userInfo = DataManager:getMyUserInfo()

	if self.buttonStatus == 0 then
	    if userInfo then
	        SoundManager.playEffectJDZ(userInfo.gender, 1)
	    end
	elseif self.buttonStatus == 1 then
	    if userInfo then
	    	local kind = math.random(1,3)
	    	print("QDZ-KIND=",kind)
	        SoundManager.playEffectQDZ(userInfo.gender,kind)
	        print("QDZ-KIND=",kind)
	    end
	end
	self.timer:stopTimer();
	self:msgJDZ(1)

	--self:showButtons(false)
	--self.btnBJDZ:hide()
end

function ViewJDZLayer:onClickBJDZ()
	SoundManager.playSound("sound/buttonclick.mp3")
    local userInfo = DataManager:getMyUserInfo()
	if self.buttonStatus == 0 then
	    if userInfo then
	        SoundManager.playEffectJDZ(userInfo.gender, 0)
	    end
	elseif self.buttonStatus == 1 then
	    if userInfo then
	    	local kind = 0--math.random(1,3)
	    	
	        SoundManager.playEffectQDZ(userInfo.gender,kind)
	        print("BQDZ-KIND=",kind)
	    end
	end
	self.timer:stopTimer();
	self:msgJDZ(0)
	--self:showJDZ(self.index+1)

	--self:showButtons(false)
	--self.btnBJDZ:hide()
end
--@params isOrder 1 order  0 noOrder
function ViewJDZLayer:soundJDZ( buttonStatus ,isOrder)
    
    local myChairID = DataManager:getMyChairID()
    local otherId = (myChairID+1)%2
    local userInfo = DataManager:getUserInfoInMyTableByChairID(otherId)
	if buttonStatus == 0 then
	    if userInfo then
	        SoundManager.playEffectJDZ(userInfo.gender, isOrder)
	    end
	elseif buttonStatus == 1 then
	    if userInfo then
	    	local kind = 0--math.random(1,3)
	    	
	        SoundManager.playEffectQDZ(userInfo.gender,isOrder)
	        print("soundJDZ-KIND=",kind,"isOrder=",isOrder)
	    end
	end
end
function ViewJDZLayer:msgJDZ(index)
	print("----------msgJDZ-----------------------分数".. index)
	DoudizhuInfo:sendCallScore2(index)
--[[
   	local wMainID = CMD_GameServer.MDM_GF_GAME
    local wSubID = CMD_DDZ_1V1.SUB_C_CALL_SCORE

    local data = protocol.doudizhu.errendoudizhu.s2c_pb.CMD_C_CallScore_Pro()
    data.cbCallScore = index

    local pData = data:SerializeToString()
    local pDataLen = string.len(pData)
    GameCenter:sendData(wMainID,wSubID,pData,pDataLen)
]]
end

function ViewJDZLayer:recover(msg)
		--显示叫分按钮

	if msg.cbRobTimes and msg.cbRobTimes>0 then
		self.btnBJDZ:removeSelf()
		self.btnJDZ:removeSelf()
		self.btnBJDZ = GameItemFactory:getBtnYellowByText(function() self:onClickBJDZ() end,"不抢"):addTo(self):align(display.CENTER, display.cx+120, display.cy - 10)
		self.btnJDZ = GameItemFactory:getBtnBlueByText(function() self:onClickJDZ() end,"抢地主"):addTo(self):align(display.CENTER, display.cx-120, display.cy - 10)
		self.buttonStatus = 1
	end
	if msg.wCurrentUser == self.myChairID then
		-- self:showButtons(true)
		self.btnBJDZ:show();
		self.btnJDZ:show()
		

	else
		-- self:showButtons(false)
		self.btnBJDZ:hide()
		self.btnJDZ:hide()
	end
	print("ViewJDZLayer:recover,,,,msg.cbRobTimes",msg.cbRobTimes,"self.playConfig.cbTimeCallScore",self.playConfig.cbTimeCallScore)
	self.qdzTxtCount:setString(msg.cbRobTimes);
	--定时闹钟
	self.timer:setPosition(posTimer[msg.wCurrentUser])
	self.timer:startTimer(self.playConfig.cbTimeCallScore, function() print("叫分超时") end)

	--默认地主
	self.dizhu = msg.cbScoreInfo[1]
	
end
function ViewJDZLayer:recoverFarmerFirst(msg)
	self.buttonStatus = 2
	if  msg.wCurrentUser ==  self.myChairID then
		self:showFarmerFirst(msg)

	else
        
        print("recoverFarmerFirst","self.playConfig.cbTimeHeadOutCard",self.playConfig.cbTimeHeadOutCard)
        -- self:hide()
        self.btnJDZ:hide()
		self.btnBJDZ:hide()
        self.timer:setPosition(cc.p(display.cx + 380, display.cy + 100))
		self.timer:startTimer(self.playConfig.cbTimeFarmerFirst, function() print("等待对方让先超时") end)

	end
	self.qdzTxtCount:setString(msg.cbRobTimes);
end
function ViewJDZLayer:setTime(time)
	print("ViewJDZLayer:setTime",time)
	self.timer:startTimer(time, function() print("叫分超时") end)
end

function ViewJDZLayer:isTuoGuan(chairID)
    local bTuoGuan = self.data.isTuoGuan
    return bTuoGuan and bTuoGuan[chairID] == 1 
end

return ViewJDZLayer