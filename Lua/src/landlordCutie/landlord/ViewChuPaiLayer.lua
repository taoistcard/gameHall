--
-- Author: <zhaxun>
-- Date: 2015-05-26 15:26:27
--
--
-- Author: <zhaxun>
-- Date: 2015-05-22 09:25:39
--

require("landlord.CMD_LandlordMsg")

local GameItemFactory = require("commonView.GameItemFactory"):getInstance()


local ViewChuPaiLayer = class( "ViewChuPaiLayer", function() return display.newNode() end )

local posTimer = {
	[1] = cc.p(0,0),
	[2] = cc.p(0,0),
	[3] = cc.p(0,0),
}

function ViewChuPaiLayer:switchChairID()
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
        print("ViewChuPaiLayer 座位分配失败！", self.myChairID)
    end
end

function ViewChuPaiLayer:ctor(param)
	self.playConfig = param.config
	self.cardLayer = param.cardLayer

	local myChairID = DataManager:getMyChairID()
	self.myChairID = myChairID
    self:switchChairID()

	posTimer[self.myChairID] = cc.p(display.cx, display.cy -10)
	posTimer[self.nextID] = cc.p(display.cx + 330, display.cy + 50)
	posTimer[self.preID] = cc.p(display.cx - 330, display.cy + 50)

	self.btnPlay = {}
	self.btnPlay[1] = GameItemFactory:getBtnBuChu(function() self:onClickBuChu() end):addTo(self):align(display.CENTER, display.cx-260, display.cy - 10)
	self.btnPlay[2] = GameItemFactory:getBtnChongXuan(function() self:onClickChongXuan() end):addTo(self):align(display.CENTER, display.cx-110, display.cy - 10)
	self.btnPlay[3] = GameItemFactory:getBtnTiShi(function() self:onClickTiShi() end):addTo(self):align(display.CENTER, display.cx+110, display.cy - 10)
	self.btnPlay[4] = GameItemFactory:getBtnChuPai(function() self:onClickChuPai() end):addTo(self):align(display.CENTER, display.cx+260, display.cy - 10)

	self.timer = require("commonView.CCTimer").new():addTo(self)

    self.sprPass={}
    self.sprPass[self.myChairID] = display.newSprite("play3/buchu.png"):addTo(self):align(display.CENTER, display.cx, display.cy):hide()
    self.sprPass[self.nextID] = display.newSprite("play3/buchu.png"):addTo(self):align(display.CENTER, display.cx + 300, display.cy + 105):hide()
    self.sprPass[self.preID] = display.newSprite("play3/buchu.png"):addTo(self):align(display.CENTER, display.cx - 300, display.cy + 105):hide()




end

function ViewChuPaiLayer:onEnter()

end

function ViewChuPaiLayer:onExit()

end

function ViewChuPaiLayer:showButtons(bShow)
	for k,v in ipairs(bShow) do
		if v == 1 then
			self.btnPlay[k]:setEnabled(true)
			self.btnPlay[k]:setBright(true)
			self.btnPlay[k]:show()

		elseif v == 0 then
			self.btnPlay[k]:setEnabled(false)
			self.btnPlay[k]:setBright(false)
			self.btnPlay[k]:show()

		elseif v == -1 then
			self.btnPlay[k]:hide()
		end
	end
end
--@para state 0 只显示不出
function ViewChuPaiLayer:changeButtonState(state)
	if state == 0 then
		self:showButtons({1,0,0,0})
	end	
end
function ViewChuPaiLayer:start(index)
	print("index = ", index, self.myChairID)
	if index == self.myChairID then
		local showTable = {0,1,1,1}
		self:showButtons(showTable)
		--定时闹钟
		self.timer:setPosition(posTimer[index])
		self.timer:startTimer(self.playConfig.cbTimeHeadOutCard, function() print("出牌超时") end, true, 5)
    

	else
		local showTable = {-1,-1,-1,-1}
		self:showButtons(showTable)
		--定时闹钟
		self.timer:setPosition(posTimer[index])
		self.timer:startTimer(self.playConfig.cbTimeHeadOutCard, function() print("其他玩家出牌超时") end, true, 5)
	end
end

function ViewChuPaiLayer:showChuPai(msg)

 	if msg.wCurrentUser == 65535 then
        print("出牌结束！")
        self:hide()
    
	elseif msg.wCurrentUser == self.myChairID then
		
		if self.cardLayer:eventSysChuPai() then--自动出牌
			print("延迟0.5s自动出牌！")
		else
			self.sprPass[msg.wCurrentUser]:hide()
			local showTable = {1,1,1,1}
			if msg.wOutCardUser == msg.wCurrentUser or msg.wTurnWiner == msg.wCurrentUser then
				showTable[1] = 0
				showTable[3] = 0
			end

			self:showButtons(showTable)
			--定时闹钟
			self.timer:setPosition(posTimer[msg.wCurrentUser])
			self.timer:startTimer(self.playConfig.cbTimeOutCard, function() print("自己操作超时") end, true, 5)
		end
	else
		self.sprPass[msg.wCurrentUser]:hide()
		local showTable = {-1,-1,-1,-1}
		self:showButtons(showTable)
		--定时闹钟
		self.timer:setPosition(posTimer[msg.wCurrentUser])
		self.timer:startTimer(self.playConfig.cbTimeOutCard, function() print("其他玩家操作超时") end, true, 5)
		
	end
end

function ViewChuPaiLayer:showEffectBuChu(index)
	--显示叫分信息
	self.sprPass[index]:show()
end

function ViewChuPaiLayer:showBuChuPai(msg)
--[[
	required int32							cbTurnOver 		= 1;			//一轮结束
	required int32				 			wCurrentUser 		= 2;			//当前玩家
	required int32				 			wPassCardUser 		= 3;			//放弃玩家
	]]
	self:showEffectBuChu(msg.wPassCardUser)
	self.sprPass[msg.wCurrentUser]:hide()

	if msg.wCurrentUser == self.myChairID then
		if self.cardLayer:eventSysChuPai() then--自动出牌
			print("延迟0.5s自动出牌！")
		else
			local showTable = {1,1,1,1}
			if self.cardLayer.lastOutCardUser == msg.wCurrentUser then--上一手出牌，是自己
				showTable[1] = 0
				showTable[3] = 0
				self:showButtons(showTable)
			else--上一手出牌，不是自己
				self:showButtons(showTable)
				self:changeButtonState(self.cardLayer:checkResult())
			end

			
			--定时闹钟
			self.timer:setPosition(posTimer[msg.wCurrentUser])
			self.timer:startTimer(self.playConfig.cbTimeOutCard, function() print("自己操作超时") end, true, 5)
		end
	else
		local showTable = {-1,-1,-1,-1}
		self:showButtons(showTable)
		--定时闹钟
		self.timer:setPosition(posTimer[msg.wCurrentUser])
		self.timer:startTimer(self.playConfig.cbTimeOutCard, function() print("其他玩家操作超时") end, true, 5)

	end

end

function ViewChuPaiLayer:msgOutCards(cards)
    print("ViewChuPaiLayer:msgOutCards", self.myChairID)
	DoudizhuInfo:sendOutCards(cards)
end

function ViewChuPaiLayer:onClickBuChu()
	if not self.cardLayer:isTuoGuan(self.myChairID) then
		SoundManager.playSound("sound/buttonclick.mp3")
		--通知卡牌层
		if true == self.cardLayer:eventBuChu() then
			--隐藏按钮和定时器
			self.timer:stopTimer();
			self:showButtons({-1,-1,-1,-1})
		end	
	end
end

function ViewChuPaiLayer:onClickChongXuan()
	if not self.cardLayer:isTuoGuan(self.myChairID) then
		SoundManager.playSound("sound/buttonclick.mp3")
		self.cardLayer:eventChongXuan()
	end
end

function ViewChuPaiLayer:onClickTiShi()
	if not self.cardLayer:isTuoGuan(self.myChairID) then
		SoundManager.playSound("sound/buttonclick.mp3")
		self.cardLayer:eventTiShi()
	end
end

function ViewChuPaiLayer:onClickChuPai()
	if not self.cardLayer:isTuoGuan(self.myChairID) then

		SoundManager.playSound("sound/buttonclick.mp3")
		--通知卡牌层
		if true == self.cardLayer:eventChuPai() then
			--隐藏按钮和定时器
			self.timer:stopTimer();
			self:showButtons({-1,-1,-1,-1})
		
		end
	end
end

--超时自动出牌
function ViewChuPaiLayer:onSysChuPai()
	if not self.cardLayer:isTuoGuan(self.myChairID) then
		self.cardLayer:eventSysChuPai()
	end
end

function ViewChuPaiLayer:setTime(time)
	self.timer:startTimer(time, function() print("出牌超时") end, true, 5)

end

return ViewChuPaiLayer