--
-- Author: <zhaxun>
-- Date: 2015-05-22 09:25:39
--

require("landlord.CMD_LandlordMsg")

local GameItemFactory = require("commonView.GameItemFactory"):getInstance()


local ViewJDZLayer = class( "ViewJDZLayer", function() return display.newNode() end )

local posTimer = {
	[1] = cc.p(0,0),
	[2] = cc.p(0,0),
	[3] = cc.p(0,0),
}

function ViewJDZLayer:switchChairID()
    if self.myChairID == 1 then
        self.nextID = 2
        self.preID = 3
    elseif self.myChairID == 2 then
        self.nextID = 3
        self.preID = 1
    elseif self.myChairID == 3 then
        self.nextID = 1
        self.preID = 2
    else
        print("ViewJDZLayer 座位分配失败！", self.myChairID)
    end
end

function ViewJDZLayer:ctor(param)

	self.playConfig = param.config

	local myChairID = DataManager:getMyChairID()
	self.myChairID = myChairID
	print("self.myChairID" ,self.myChairID)
    self:switchChairID()

	posTimer[self.myChairID] = cc.p(display.cx-120, display.cy -10)
	posTimer[self.nextID] = cc.p(display.cx + 330, display.cy + 50)
	posTimer[self.preID] = cc.p(display.cx - 330, display.cy + 50)

	self.btnJF = {}
	self.btnJF[1] = GameItemFactory:getBtnJiaoFen(1, function() self:onClickJDZ(1) end):addTo(self):align(display.CENTER, display.cx-20, display.cy - 10)
	self.btnJF[2] = GameItemFactory:getBtnJiaoFen(2, function() self:onClickJDZ(2) end):addTo(self):align(display.CENTER, display.cx+120, display.cy - 10)
	self.btnJF[3] = GameItemFactory:getBtnJiaoFen(3, function() self:onClickJDZ(3) end):addTo(self):align(display.CENTER, display.cx+260, display.cy - 10)
	self.btnBJDZ = GameItemFactory:getBtnBJDZ(function() self:onClickBJDZ() end):addTo(self):align(display.CENTER, display.cx-240, display.cy - 10)
	self.timer = require("commonView.CCTimer").new():addTo(self)


    self.sprJF={}
    self.sprJF[self.myChairID] = display.newSprite("play3/bujiao.png"):addTo(self):align(display.CENTER, display.cx, display.cy):hide()
    self.sprJF[self.nextID] = display.newSprite("play3/bujiao.png"):addTo(self):align(display.CENTER, display.cx + 300, display.cy + 105):hide()
    self.sprJF[self.preID] = display.newSprite("play3/bujiao.png"):addTo(self):align(display.CENTER, display.cx - 300, display.cy + 105):hide()

    self.maxFen = 0;
	self.dizhu = 0;

    self.hasJDZ = false;--在发牌过程中有人托管，会直接发送不叫，跳过showJDZ
end

function ViewJDZLayer:onEnter()

end

function ViewJDZLayer:onExit()

end

function ViewJDZLayer:showButtons(bVisible)
	print("！！！！！！！最大叫分", self.maxFen)
	for k,v in ipairs(self.btnJF) do
		if bVisible then
			v:show()
			if k > self.maxFen then
				v:setEnabled(true)
				v:setBright(true)
			else
				v:setEnabled(false)
				v:setBright(false)
			end
		else
			v:hide()
			
		end
	end
end

function ViewJDZLayer:showJDZ(msg)
--[[
	required int32							wStartUser 		= 1;			//开始玩家
	required int32				 			wCurrentUser 		= 2;			//当前玩家
	required int32							cbValidCardData 	= 3;			//明牌扑克
	required int32							cbValidCardIndex 	= 4;			//明牌位置
	repeated int32							cbCardData 		= 5;			//扑克列表
]]
	if self.hasJDZ then
		return
	end

	--显示叫分按钮
	if msg.wCurrentUser == self.myChairID then
		self:showButtons(true)
		self.btnBJDZ:show();
	else
		self:showButtons(false)
		self.btnBJDZ:hide()
	end

	--定时闹钟
	self.timer:setPosition(posTimer[msg.wCurrentUser])
	self.timer:startTimer(self.playConfig.cbTimeCallScore, function() print("叫分超时") end)

	--默认地主
	self.dizhu = msg.wCurrentUser
	
end

function ViewJDZLayer:showQDZ(msg)
	self.hasJDZ = true
--[[
	required int32				 			wCurrentUser 		= 1;			//当前谁轮到叫分
	required int32							wCallScoreUser 		= 2;			//当前叫分玩家
	required int32							cbCurrentScore 		= 3;			//当前最高叫分
	required int32							cbUserCallScore		= 4;			//这一把叫分
	]]
	print("当前叫分玩家", msg.wCallScoreUser, "当前最高叫分", msg.cbCurrentScore, 
		"这一把叫分", msg.cbUserCallScore, "当前谁轮到叫分", msg.wCurrentUser)

	--begin----------播放声音
	local file = nil
	local index = 0
	if msg.cbUserCallScore == 255 then
		index = 0
	else
		index = msg.cbUserCallScore
	end

	local userInfo = DataManager:getUserInfoInMyTableByChairID(msg.wCallScoreUser)
	if userInfo then
		SoundManager.playEffectByName(index .. "fen", userInfo.gender)
	end
	
	if msg.cbUserCallScore ~= 255 then
		self.maxFen = msg.cbUserCallScore
		self.dizhu = msg.wCallScoreUser
	end

    if msg.wCurrentUser == 65535 then
        print("叫分结束, 进入出牌阶段！")
        self:hide()
        return true, self.dizhu
    end

	--显示叫分按钮
	if msg.wCurrentUser == self.myChairID then
		self:showButtons(true, msg.cbUserCallScore)
		self.btnBJDZ:show();
	else
		self:showButtons(false)
		self.btnBJDZ:hide()
	end

	--定时闹钟
	self.timer:setPosition(posTimer[msg.wCurrentUser])
	self.timer:startTimer(self.playConfig.cbTimeCallScore, function() print("叫分超时") end)


	--显示叫分信息
	if msg.wCallScoreUser then
		if msg.cbUserCallScore == 255 then
			file = "play3/bujiao.png"
		else
			file = "play3/" .. msg.cbUserCallScore .. "fen.png"
		end
		self.sprJF[msg.wCallScoreUser]:setTexture(file)
		self.sprJF[msg.wCallScoreUser]:show()
	end

	return false, self.dizhu
end

function ViewJDZLayer:onClickJDZ(index)

	SoundManager.playSound("sound/buttonclick.mp3")
	self.timer:stopTimer();
	self:msgJDZ(index)

	--self:showButtons(false)
	--self.btnBJDZ:hide()
end

function ViewJDZLayer:onClickBJDZ()
	SoundManager.playSound("sound/buttonclick.mp3")
	self.timer:stopTimer();
	self:msgJDZ(0)
	--self:showJDZ(self.index+1)

	--self:showButtons(false)
	--self.btnBJDZ:hide()
end

function ViewJDZLayer:msgJDZ(index)
	print("msgJDZ".. index)

	DoudizhuInfo:sendCallScore(index)
end

function ViewJDZLayer:recover(msg)
	--显示叫分按钮
	self.dizhu = 0
	for k,v in ipairs(msg.cbScoreInfo) do
		if v ~= 255 then
			if v > self.maxFen then
				self.maxFen = v
				--默认地主
				self.dizhu = k
			end
		end
	end

	if msg.wCurrentUser == self.myChairID then
		self:showButtons(true)
		self.btnBJDZ:show();
	else
		self:showButtons(false)
		self.btnBJDZ:hide()
	end

	--定时闹钟
	self.timer:setPosition(posTimer[msg.wCurrentUser])
	self.timer:startTimer(self.playConfig.cbTimeCallScore, function() print("叫分超时") end)
	
end

function ViewJDZLayer:setTime(time)
	self.timer:startTimer(time, function() print("叫分超时") end)
end

return ViewJDZLayer