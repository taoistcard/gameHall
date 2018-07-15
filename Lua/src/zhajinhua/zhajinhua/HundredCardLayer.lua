--卡牌，筹码，下注数目
local cardInfo = {
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",
}
local cardTypeName = {[3]="baozi.png",[15]="tonghuashun.png",[14]="tonghua.png",[6]="shunzi.png",[2]="duizi.png",[1]="danzhang.png"}
local HundredCardLayer = class("HundredChartsLayer", function() return display.newLayer() end)
local DateModel = require("zhajinhua.DateModel")
local EffectFactory = require("commonView.EffectFactory")
local handPos = {cc.p(426,436),cc.p(378,287),nil,cc.p(756,287),cc.p(705,436)}
local bigActiveAreaPos = {cc.p(335,417),cc.p(325,256),nil,cc.p(809,256),cc.p(777,416)}
local playerPos = {cc.p(209,485),cc.p(172,296),cc.p(508,210),cc.p(939,284),cc.p(933,490)}
local deltaY = 0
local cardTypePos = {cc.p(551,560+deltaY),cc.p(328,394+deltaY),cc.p(492,394+deltaY),cc.p(656,394+deltaY),cc.p(820,394+deltaY)}
local bankerScale = 0.7
local playerScale = 0.85
function HundredCardLayer:ctor(params)
	local winSize = cc.Director:getInstance():getWinSize()
	self:setContentSize(cc.size(1136,640))
	self:setPosition(0,0)
    self.data = params.dataModel;
    self.effectLayer = params.effectLayer
    self.cardArray = {}
    self.tableGoldArray = {}
    self.chipUI = {}
    self.typeArrayUI = {}
    self.bigActiveAreaArray = {}
	local otherIntervel = 16
	local myIntervel = 38
	local interval = 0
	local scaleNum = 1
	for i=1,5 do
		if i == 3 then
			interval = myIntervel
			scaleNum = bankerScale
		else
			interval = otherIntervel
			scaleNum = playerScale
		end
		self.cardArray[i] = {}
		for j=0,2 do

			local card = ccui.ImageView:create("zhajinhua/cardRedBig.png")
			card:setPosition(145,572)
			card:setScale(scaleNum)
			card:setVisible(false)
			self:addChild(card)
			self.cardArray[i][j+1] = card
		end

	end
	self:createUI()
end
function HundredCardLayer:createUI()
    for i=1,5 do
    	local typebg = ccui.ImageView:create("zhajinhua/cardTypeBg.png")
    	typebg:setPosition(cardTypePos[i])
    	-- typebg:hide()
    	self:addChild(typebg)

    	local cardType = ccui.ImageView:create()
    	cardType:setName("cardType")
    	cardType:setPosition(121, 39)
    	typebg:addChild(cardType)

    	table.insert(self.typeArrayUI, typebg)
    end
end
HundredCardLayer.r = 0
function HundredCardLayer:resetCardPos()
	for i=1,5 do
		for j=0,2 do
			local card = self.cardArray[i][j+1]
			card:loadTexture("zhajinhua/cardRedBig.png")
			card:setPosition(145,572)
			card:setVisible(false)
		end
	end
end
function HundredCardLayer:gameStart()
	local startBetEffect = EffectFactory:getInstance():getStartBet(0)
	startBetEffect:setPosition(575, 347)
	self.effectLayer:addChild(startBetEffect)
end
function HundredCardLayer:compareCard(msg)
	local compareEffect = EffectFactory:getInstance():getStartBet(1)
	compareEffect:setPosition(575, 347)
	self.effectLayer:addChild(compareEffect)
	self:performWithDelay(function ()
		self:gameEnd(msg)
	end, 2)
end
function HundredCardLayer:sendCard( banker ,myChairID)
	self:resetCardPos()
	self.AllCardData = nil
	for i=1,5 do
		self.typeArrayUI[i]:hide()
	end
	banker = 1
	myChairID = 3
	local chairID = banker or 2--self.r--
	self.r = (self.r+1)%5
	-- print("fapai==",chairID,"myChairID",myChairID)
	local index = chairID + 1
	local cardpos = {cc.p(530,587),cc.p(302,431),cc.p(468,431),cc.p(632,431),cc.p(798,431)}--重置牌的位置
	local otherIntervel = 28
	local myIntervel = 24
	local interval = 0
	local scaleNum = 1
	local moveTime = 0.2
	local delayTime = 0.1
	local temp = {}
	local myIndex = 0
	local playtemp = {1,nil,nil,1,nil}
	local bankerIndex = (chairID+5-myChairID)%5+3
	for j=1,5 do
		temp[j] = cardpos[((bankerIndex-1)+j-1)%5+1]
		-- print("temp[j]",temp[j].x,temp[j].y)
		if temp[j].y == cardpos[3].y then
			myIndex = j
		end
	end
	cardpos = temp
	local delaycount = 0
	for i=1,5 do --第一个发庄家的牌
		if i == 1 then
			interval = myIntervel
			scaleNum = bankerScale
		else
			interval = otherIntervel
			scaleNum = playerScale
		end
		local bankerNew = (banker-1+i-1)%5+1
		local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(bankerNew)--playtemp[(banker+i-1)%5+1]--
		if 1 then
			for j=0,2 do
				local card = self.cardArray[i][j+1]
				card:setPosition(145,572)
				card:setScale(scaleNum)
				card:setVisible(false)
				card:setRotation(0)
				local fun = cc.CallFunc:create(
					function ()
						SoundManager.playSendCard()
						card:setVisible(true)
					end
				)
				local moveto = cc.MoveTo:create(moveTime, cc.p(cardpos[i].x+interval*j, cardpos[i].y))
				local scaleto = cc.ScaleTo:create(moveTime, scaleNum)
				local spawn = cc.Spawn:create(moveto,scaleto)
				local seq = cc.Sequence:create(cc.DelayTime:create((delaycount)*3*delayTime+j*delayTime),fun,spawn)
				card:runAction(seq)
				
			end
			delaycount = delaycount+1
			-- self:startFollow(playerInfo.chairID)
		end

	end
	self:gameStart()
end
local playerPos = {cc.p(209,485),cc.p(172,296),cc.p(508,210),cc.p(939,284),cc.p(933,490)}
local betBtnPos = {cc.p(409,34),cc.p(172,296),cc.p(508,210),cc.p(939,284),cc.p(933,490)}
function HundredCardLayer:addScore(msg)
	local chairID = msg.wAddScoreUser
    local myChairID = DataManager:getMyChairID()
    if myChairID == Define.INVALID_CHAIR then
        myChairID = 0
        print("followCard==Define.INVALID_CHAIR",Define.INVALID_CHAIR)
    end
    local index = ((chairID+5-myChairID)%5+3-1)%5+1


    local left = 408
    local right = 708
    local top = 416
    local bottom  = 266
    local lookcard = 1
    if DateModel:getInstance():getLookCard()==1 then
        lookcard = 2
    end
    
    local chipCell = DateModel:getInstance():getCellScore() --msg.lAddScoreCount/msg.lCurrentTimes
    local addScore = msg.lAddScoreCount
    if chipCell == nil then
    	print("单元积分是NIL")
    	chipCell = 10
    end
    local chipCount = math.ceil(addScore/chipCell)
    local chipName = {[10]="chip1.png",[100]="chip2.png",[1000]="chip3.png",[10000]="chip4.png",[100000]="chip5.png",[1000000]="chip6.png",[10000000]="chip7.png",[100000000]="chip7.png",
					[50]="chip50.png",[500]="chip500.png",[5000]="chip5000.png",[50000]="chip50000.png",[500000]="chip500000.png",[5000000]="chip5000000.png",[50000000]="chip50000000.png",[500000000]="chip5000000.png"	}
    if chipName[chipCell] == nil then
    	print("chipName[chipCell]",chipName[chipCell],chipCell)
    	chipCell = 10
    end
    local chipUrl = "zhajinhua/chip/"..chipName[chipCell]
    local urlArray = {}


    if chipCount >= 10 then
    	local chushu = math.floor(chipCount/10)
    	local yushu = chipCount - chushu*10
    	for i=1,chushu do
	    	chipUrl = "zhajinhua/chip/"..chipName[chipCell*10]
	    	table.insert(urlArray, chipUrl)
    	end
    	chipCount = chushu
	    if yushu>=5 then
	    	table.insert(urlArray, "zhajinhua/chip/"..chipName[chipCell*5])
	    	for i=1,yushu-5 do
	    		table.insert(urlArray, "zhajinhua/chip/"..chipName[chipCell])
	    	end
	    	chipCount = chipCount+yushu-4
	    else
	    	for i=1,yushu do
	    		table.insert(urlArray, "zhajinhua/chip/"..chipName[chipCell])
	    	end
	    	chipCount = chipCount+yushu
	    end
    else
	    if chipCount>=5 then
	    	table.insert(urlArray, "zhajinhua/chip/"..chipName[chipCell*5])
	    	for i=1,chipCount-5 do
	    		table.insert(urlArray, "zhajinhua/chip/"..chipName[chipCell])
	    	end
	    	chipCount = chipCount-4
	    else
	    	for i=1,chipCount do
	    		table.insert(urlArray, "zhajinhua/chip/"..chipName[chipCell])
	    	end
	    end
    end
    --print("chipCount",chipCount)
    for i=1,chipCount do
	    local randx = math.random(1, 100)*(right-left)/100+left
	    local randy = math.random(1, 100)*(top-bottom)/100+bottom
	    --print("i=",i,"randx",randx,"randy ",randy,urlArray[i])
	    local chip = ccui.ImageView:create(urlArray[i])
	    chip:setPosition(playerPos[index])
	    self:addChild(chip)

	    local moveto = cc.MoveTo:create(0.2,cc.p(randx, randy))
	    chip:runAction(moveto)
	    table.insert(self.chipUI,chip)
    end


end
function HundredCardLayer:gameEnd(msg)
	local delayTime = 0.1
	local cardScale = playerScale
	for i=1,5 do
		local index = i
		local cardArray = {0x03,0x13,0x23}--msg.cbCardData[v].cbCardValue
		local total = #cardArray
		local shoupai = "";
		cardArray = self:sortCards(cardArray)
		if i == 1 then
			cardScale = bankerScale
		else
			cardScale = playerScale
		end
	    for i=1,total do
	        shoupai = shoupai..cardInfo[cardArray[i]]	        
	        local kind = math.floor(cardArray[i] / 0x10 )
	        local num = cardArray[i] % 0x10
	        local filename = "card/kb_"..kind.."_"..num..".png";
	        local card = self.cardArray[index][i]
	        print("filename",filename)
	        local scale1 = cc.ScaleTo:create(0.2, 0.1, cardScale, cardScale)
	        local scale2 = cc.ScaleTo:create(0.2, cardScale)
	        
			local fun = cc.CallFunc:create(
				function ()
					card:loadTexture(filename)
				end
			)
			local seq = cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime),scale1,fun,scale2)
			card:runAction(seq)
	    end

	    local tempindex = i
	    local cardType = GameLogic.checkCardType(cardArray)

	    self.typeArrayUI[tempindex]:getChildByName("cardType"):loadTexture("zhajinhua/"..cardTypeName[cardType])
	    self.typeArrayUI[tempindex]:show()
	    self.typeArrayUI[tempindex]:setScale(0.1)
	    local cardTypeScale = 0.6
	    if tempindex==1 then
	    	cardTypeScale = 0.45
	    end
	    local scale1 = cc.ScaleTo:create(0.5, cardTypeScale)
	    local seq = cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime),scale1)
	    self.typeArrayUI[tempindex]:runAction(seq)
	end
end
--默认从大到小
function HundredCardLayer:sortCards(cards,sortType)
	local result = {}
	local cardWithoutType = {}--没有花色
	for i,v in ipairs(cards) do
		table.insert(cardWithoutType,v%0x10)
	end
	if sortType then--
		table.sort(cardWithoutType)
		if cardWithoutType[1] == 0x01 then
			local v = table.remove(cardWithoutType,1)
			table.insert(cardWithoutType,v)
		end
	else
		table.sort(cardWithoutType,function(a,b) return a>b end)
		if cardWithoutType[#cardWithoutType] == 0x01 then
			local v = table.remove(cardWithoutType)
			table.insert(cardWithoutType,1,v)
		end
	end
	
	local flag = {0,0,0}
	for i,v in ipairs(cardWithoutType) do
		
		for j,w in ipairs(cards) do
			if v%0x10 == w%0x10 and flag[j] == 0 then
				table.insert(result,w)
				flag[j] = 1
			end
		end
	end
	return result
end
return HundredCardLayer