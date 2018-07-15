local cardInfo = {
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",
}
local ViewCardLayer = class( "ViewCardLayer", function() return display.newLayer() end )
local DateModel = require("zhajinhua.DateModel")
local EffectFactory = require("commonView.EffectFactory")
local ischeat = EVILBOY--false--开启作弊，可以看别人看过的牌
local cardTypeName = {[3]="baozi.png",[15]="tonghuashun.png",[14]="tonghua.png",[6]="shunzi.png",[2]="duizi.png",[1]="danzhang.png"}
function ViewCardLayer:setDataModel(dataModel)

    self.data = dataModel;
end
local handPos = {cc.p(426,436),cc.p(378,287),nil,cc.p(756,287),cc.p(705,436)}
local bigActiveAreaPos = {cc.p(335,417),cc.p(325,256),nil,cc.p(809,256),cc.p(777,416)}
local playerPos = {cc.p(209,485),cc.p(172,296),cc.p(508,210),cc.p(939,284),cc.p(933,490)}
local deltaY = -4
local cardTypePos = {cc.p(332,394+deltaY),cc.p(323,235+deltaY),cc.p(674,114+deltaY),cc.p(808,232+deltaY),cc.p(773,395+deltaY)}
function ViewCardLayer:ctor(params)
	-- dump(params, "params")
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
			scaleNum = 1
		else
			interval = otherIntervel
			scaleNum = 0.7
		end
		self.cardArray[i] = {}
		for j=0,2 do

			local card = ccui.ImageView:create("zhajinhua/cardRed.png")
			card:setPosition(703,518)
			card:setScale(scaleNum)
			card:setVisible(false)
			self:addChild(card)
			self.cardArray[i][j+1] = card
		end

	end

    local compareHandLayer = ccui.Layout:create()
    -- compareHandLayer:setAnchorPoint(cc.p(0.5,0.5))
    compareHandLayer:setContentSize(cc.size(1136,640))
    self.effectLayer:addChild(compareHandLayer)
    self.compareHandLayer = compareHandLayer
    -- 蒙板
   	local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    local maskLayer = ccui.ImageView:create("common/black.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2,DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    compareHandLayer:addChild(maskLayer)
    compareHandLayer:hide()
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(1000, 600));
    compareHandLayer:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                compareHandLayer:hide()                
            end
        end
    )

    self.handArray = {}
    for i=1,5 do
    	if i ~= 3 then
	    	local hand = ccui.Button:create("zhajinhua/shou.png")
	    	hand:setPosition(handPos[i])
	    	compareHandLayer:addChild(hand)
	    	hand:setTag(i)
	    	hand:hide()
	    	hand:addTouchEventListener(
		        function(sender,eventType)
		            if eventType == ccui.TouchEventType.ended then
		    			self:compareCardByUserID(sender)
		            end
		        end
		    )
		    self.handArray[i] = hand
		    if i>3 then
		    	hand:setScaleX(-1)
		    end
		    local bigActiveArea = ccui.Button:create("common/blank.png")
		    bigActiveArea:setScale9Enabled(true)
		    bigActiveArea:setContentSize(cc.size(70,70))
		    bigActiveArea:setPosition(bigActiveAreaPos[i])
		    compareHandLayer:addChild(bigActiveArea)
		    bigActiveArea:setTag(i)
		    bigActiveArea:addTouchEventListener(
		        function(sender,eventType)
		            if eventType == ccui.TouchEventType.ended then
		    			self:compareCardByUserID(sender)
		            end
		        end
		    )
		    self.bigActiveAreaArray[i] = bigActiveArea
    	end
    	local typebg = ccui.ImageView:create("zhajinhua/cardTypeBg.png")
    	typebg:setPosition(cardTypePos[i])
    	typebg:hide()
    	self:addChild(typebg)

    	local cardType = ccui.ImageView:create()
    	cardType:setName("cardType")
    	cardType:setPosition(121, 39)
    	typebg:addChild(cardType)

    	table.insert(self.typeArrayUI, typebg)
    end
end
ViewCardLayer.r = 0
function ViewCardLayer:resetCardPos()
	for i=1,5 do
		for j=0,2 do
			local card = self.cardArray[i][j+1]
			card:loadTexture("zhajinhua/cardRed.png")
			card:setPosition(703,518)
			card:setVisible(false)
		end
	end
end
function ViewCardLayer:dropCard(msg)

	local index = (msg.wGiveUpUser+5-DateModel:getInstance():getBankerUser())%5+1
    for i=1,3 do
        local filename = "zhajinhua/cardGray.png";
        local card = self.cardArray[index][i]
        card:loadTexture(filename)
    end
end
function ViewCardLayer:showCompareHand(otherPlayer,chairArry,compareCard)
	self.compareHandLayer:show()
	self.otherPlayer = otherPlayer
	self.chairArry = chairArry
	self.callback = compareCard

	local deltaX = 4
	for i,v in ipairs(self.otherPlayer) do
		for j,w in ipairs(chairArry) do
			if w == v.chairID then				
				self.handArray[j]:show()
				self.bigActiveAreaArray[j]:show()
				self.handArray[j]:setPosition(handPos[j].x-deltaX, handPos[j].y)
				local moveby = cc.MoveBy:create(0.5, cc.p(deltaX*2,0))
				self.handArray[j]:runAction(cc.RepeatForever:create(cc.Sequence:create(moveby,moveby:reverse())))
			end
		end
	end

end
function ViewCardLayer:compareCardByUserID(sender)
	local index = sender:getTag()
	self.compareHandLayer:hide()
	local userinfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(self.chairArry[index])
	-- print("userinfo.chairID",userinfo.chairID)
	self.callback(userinfo.chairID)
	for i=1,5 do
		if i~= 3 then
			self.handArray[i]:hide()
			self.bigActiveAreaArray[i]:hide()
			self.handArray[i]:setPosition(handPos[i])
			self.handArray[i]:stopAllActions()
		end
	end
end
function ViewCardLayer:compareCard( msg )
	local myChairID = DataManager:getMyChairID()
	local hideCard = {}
	local interval = 38
	local destPos = {cc.p(376,375),cc.p(692,375)}
	local cardpos = {cc.p(319,417),cc.p(309,256),cc.p(633,146),cc.p(793,256),cc.p(761,416)}
	local showUI = {}
	local totalAnimationTime = 5
    -- 蒙板
   	local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(winSize.width,winSize.height)
    local maskLayer = ccui.ImageView:create("common/black.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2,DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self.effectLayer:addChild(maskLayer)
    table.insert(showUI, maskLayer)
    local failurePos 
	for i,v in ipairs(msg.wCompareUser) do
		-- print("比牌用户",v)
		local index = (v+5-DateModel:getInstance():getBankerUser())%5+1
		local tempindex = ((v+5-myChairID)%5+2)%5+1
		for j=1,3 do
			local card = self.cardArray[index][j]
			card:hide()
			table.insert(hideCard,card)
		end
		if v == msg.wLostUser then
			failurePos = cc.p(destPos[i].x+10,destPos[i].y)
		end
		-- print("tempindex",tempindex)
		for k=0,2 do
			local card = ccui.ImageView:create("zhajinhua/cardRed.png")
			card:setPosition(playerPos[tempindex].x+interval*k, playerPos[tempindex].y)
			self.effectLayer:addChild(card)
			if k==1 then
				local nickname = ccui.Text:create(FormotGameNickName(DataManager:getUserInfoInMyTableByChairIDExceptLookOn(v).nickName,7),"",24)
				nickname:setPosition(43, -35)
				nickname:setColor(cc.c3b(181, 201, 116))
				card:addChild(nickname)
				table.insert(showUI, nickname)
			end
			local move = cc.MoveTo:create(0.5, cc.p(destPos[i].x+interval*k, destPos[i].y))
			local delay = cc.DelayTime:create(1)
			local delay2 = cc.DelayTime:create(3)
			local dosomething = cc.CallFunc:create(
				function ()
					if msg.wLostUser == v then
						card:loadTexture("zhajinhua/cardBroken.png")
					end					
				end)
			local moveback = cc.MoveTo:create(0.5, cc.p(cardpos[tempindex].x+interval*k, cardpos[tempindex].y))
			local seq = cc.Sequence:create(move,delay,dosomething,delay2,moveback)
			card:runAction(seq)
			table.insert(showUI, card)
		end

	end
	self:performWithDelay(function ()
		local failureEffect =  EffectFactory:getInstance():getCompareFailureArmature()
		failureEffect:setPosition(failurePos)
		self.effectLayer:addChild(failureEffect)
		SoundManager.playBaoZha()
	end, 1.5)
	local vsLight = ccui.ImageView:create("zhajinhua/vsLight.png")
	vsLight:setPosition(570, 352)
	self.effectLayer:addChild(vsLight)
	local vs = ccui.ImageView:create("zhajinhua/vs.png")
	vs:setPosition(570, 358)
	table.insert(showUI, vsLight)
	table.insert(showUI, vs)
	self.effectLayer:addChild(vs)	
	local compareEffect = EffectFactory:getInstance():getCompareCardAnimation(0)
	compareEffect:setPosition(570, 358)
	self.effectLayer:addChild(compareEffect)
	table.insert(showUI, compareEffect)
	-- print("-----------compareCard", os.date("%H:%M:%S", os.time()))
	DateModel:getInstance():setCompareDelayTime(totalAnimationTime)
	self:performWithDelay(function ( )
		for i,v in ipairs(msg.wCompareUser) do
			local index = (v+5-DateModel:getInstance():getBankerUser())%5+1
			for j=1,3 do
				local card = self.cardArray[index][j]				
				if msg.wLostUser == v then
					card:loadTexture("zhajinhua/cardBroken.png")
					-- print("cardBroken")	
					-- print("-----------compareCard-performWithDelay", os.date("%H:%M:%S", os.time()))		
				end
				card:show()
			end
		end

		for i,v in ipairs(showUI) do
			v:removeFromParent()
		end
		DateModel:getInstance():setCompareDelayTime(0)
	end, totalAnimationTime)--最后两个人比牌6秒后服务端回游戏结束报，所以这里延迟要小于6秒
	SoundManager.playLight()
end
function ViewCardLayer:openCard(winner,playerChairIDLeft)
	local myChairID = DataManager:getMyChairID()
	local hideCard = {}
	local interval = 0--38
	local destPos = {cc.p(570,375),cc.p(570,375),cc.p(570,375),cc.p(570,375),cc.p(570,375)}
	local cardpos = {cc.p(319,417),cc.p(309,256),cc.p(633,146),cc.p(793,256),cc.p(761,416)}
	local showUI = {}
    -- 蒙板
   	local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    local maskLayer = ccui.ImageView:create("common/black.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2,DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self.effectLayer:addChild(maskLayer)
    table.insert(showUI, maskLayer)
	for i,v in ipairs(playerChairIDLeft) do
		-- print("开牌用户",v)
		local index = (v+5-DateModel:getInstance():getBankerUser())%5+1
		local tempindex = ((v+5-myChairID)%5+2)%5+1
		for j=1,3 do
			local card = self.cardArray[index][j]
			card:hide()
			table.insert(hideCard,card)
		end
		-- print("tempindex",tempindex)
		for k=0,2 do
			local card = ccui.ImageView:create("zhajinhua/cardRed.png")
			card:setPosition(playerPos[tempindex].x+interval*k, playerPos[tempindex].y)
			self.effectLayer:addChild(card)
			local move = cc.MoveTo:create(0.4, cc.p(destPos[i].x+interval*k, destPos[i].y))
			local delay = cc.DelayTime:create(1)
			local moveback = cc.MoveTo:create(0.5, cc.p(cardpos[tempindex].x+interval*k, cardpos[tempindex].y))
			local seq = cc.Sequence:create(move,delay,moveback)			
			card:runAction(seq)
			table.insert(showUI, card)
		end
	end
	local vsLight = ccui.ImageView:create("zhajinhua/vsLight.png")
	vsLight:setPosition(570, 352)
	self.effectLayer:addChild(vsLight)
	local vs = ccui.ImageView:create("zhajinhua/vs.png")
	vs:setPosition(570, 358)
	table.insert(showUI, vsLight)
	table.insert(showUI, vs)
	self.effectLayer:addChild(vs)	
	local compareEffect = EffectFactory:getInstance():getCompareCardAnimation(1)
	compareEffect:setPosition(570, 358)
	self.effectLayer:addChild(compareEffect)
	table.insert(showUI, compareEffect)
	-- print("-----------openCard", os.date("%H:%M:%S", os.time()))
	self:performWithDelay(function ( )
		for i,v in ipairs(playerChairIDLeft) do
			local index = (v+5-DateModel:getInstance():getBankerUser())%5+1
			for j=1,3 do
				local card = self.cardArray[index][j]				
				if winner ~= v then
					card:loadTexture("zhajinhua/cardBroken.png")
					-- print("cardBroken")	
					-- print("-----------openCard-performWithDelay", os.date("%H:%M:%S", os.time()))		
				end
				card:show()
			end
		end
		for i,v in ipairs(showUI) do
			v:removeFromParent()
		end
		SoundManager.playBaoZha()
	end, 2)--最后两个人比牌6秒后服务端回游戏结束报，所以这里延迟要小于6秒
	SoundManager.playLight()
end
function ViewCardLayer:sendCard( banker ,myChairID)
	self:resetCardPos()
	self.AllCardData = nil
	for i=1,5 do
		self.typeArrayUI[i]:hide()
	end
	local chairID = banker or 2--self.r--
	self.r = (self.r+1)%5
	-- print("fapai==",chairID,"myChairID",myChairID)
	local index = chairID + 1
	local cardpos = {cc.p(319,417),cc.p(309,256),cc.p(633,146),cc.p(793,256),cc.p(761,416)}--重置牌的位置
	local otherIntervel = 16
	local myIntervel = 38
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
		if i == myIndex then
			interval = myIntervel
			scaleNum = 1
		else
			interval = otherIntervel
			scaleNum = 0.7
		end
		local bankerNew = (banker-1+i-1)%5+1
		local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(bankerNew)--playtemp[(banker+i-1)%5+1]--
		if playerInfo then
			for j=0,2 do
				local card = self.cardArray[i][j+1]
				card:setPosition(703,518)
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
			self:startFollow(playerInfo.chairID)
		end

	end
end
--开局投注
function ViewCardLayer:startFollow(chairID)
	local followMsg = {}
	followMsg.wAddScoreUser = chairID
	followMsg.lCurrentTimes = 1
	followMsg.lAddScoreCount = DateModel:getInstance():getCellScore()
	self:followCard(followMsg)
end
function ViewCardLayer:lookCard(msg)
	local myLookon = DataManager:getMyUserStatus() == Define.US_LOOKON
	-- print("myLookon",myLookon)
	local index = (msg.wLookCardUser+5-DateModel:getInstance():getBankerUser())%5+1
 	--打印发的牌
    local shoupai = "";
    local total = #msg.cbCardData
    local radian = {0,20,30}
    local cardArray = {}
    for i,v in ipairs(msg.cbCardData) do
    	cardArray[i] = v
    end
    cardArray = self:sortCards(cardArray)
    for i=1,total do

        -- shoupai = shoupai..string.format("0x%02x",cardArray[i])..","--cardInfo[
        shoupai = shoupai..cardInfo[cardArray[i]]
        local kind = math.floor(cardArray[i] / 0x10 )
        local num = cardArray[i] % 0x10
        local filename = "card/kb_"..kind.."_"..num..".png";
        local card = self.cardArray[index][i]
        
		-- if msg.wLookCardUser ~= DataManager:getMyChairID() then
			local rotateTo = cc.RotateTo:create(0.2,radian[i])
			card:runAction(rotateTo)
		-- end
		if (msg.wLookCardUser == DataManager:getMyChairID() and myLookon == false) or ischeat then
			card:loadTexture(filename)
		end
    end
    if (msg.wLookCardUser == DataManager:getMyChairID() and myLookon == false and DateModel:getInstance():getTiShiPaiXing())or ischeat then
	    --显示牌型
	    local myChairID = DataManager:getMyChairID()
	    local tempindex = ((msg.wLookCardUser+5-myChairID)%5+2)%5+1
	    local cardType = GameLogic.checkCardType(cardArray)
	    -- if cardType == CARDS_TYPE.CT_1 then
	    -- else
		    self.typeArrayUI[tempindex]:getChildByName("cardType"):loadTexture("zhajinhua/"..cardTypeName[cardType])
		    self.typeArrayUI[tempindex]:show()
		    if tempindex==3 then
		    	self.typeArrayUI[tempindex]:setScale(1)
		    else
		    	self.typeArrayUI[tempindex]:setScale(0.5)
		    end
		    -- print("cardTypeName",cardTypeName[cardType],"shoupai",shoupai)
	    -- end
	end
    
    -- print("看牌的桌位号",msg.wLookCardUser,"发牌total",total,"shoupai",shoupai)
end
local playerPos = {cc.p(209,485),cc.p(172,296),cc.p(508,210),cc.p(939,284),cc.p(933,490)}
function ViewCardLayer:followCard(msg)
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
function ViewCardLayer:showCard(msg)
	local myChairID = DataManager:getMyChairID()
	local hideCard = {}
	local interval = 38
	local destPos = {cc.p(550, 358),cc.p(692,375)}
	local showUI = {}
	local cardDataInfo = {}
	local cardDataProto = nil
	if self.AllCardData then
		--todo	
	    for k,v in ipairs(self.AllCardData) do
	        print(k,"v",v.wChairID)
	        if v.wChairID == msg.wShowUser then
	        	cardDataProto = v.cbCardValue
	        end
	        for l,w in ipairs(v.cbCardValue) do--v=CardData_Pro
	            print(l,cardInfo[w])
	        end
	    end
	else
		print("没有牌的数据")
		return
    end
    for i,v in ipairs(cardDataProto) do
    	cardDataInfo[i] = v
    end
    cardDataInfo = self:sortCards(cardDataInfo)
    -- 蒙板
   	local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    local maskLayer = ccui.ImageView:create("common/black.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2,DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self.effectLayer:addChild(maskLayer)
    table.insert(showUI, maskLayer)

    local  v = msg.wShowUser
	local index = (v+5-DateModel:getInstance():getBankerUser())%5+1
	local tempindex = ((v+5-myChairID)%5+2)%5+1
	for j=1,3 do
		local card = self.cardArray[index][j]
		card:hide()
		table.insert(hideCard,card)
	end
	print("tempindex",tempindex)
	for k=0,2 do		
        local kind = math.floor(cardDataInfo[k+1] / 0x10 )
        local num = cardDataInfo[k+1] % 0x10
        local filename = "card/kb_"..kind.."_"..num..".png";
        print("filename",filename)
		local card = ccui.ImageView:create(filename)--"zhajinhua/cardRed.png"
		card:setPosition(playerPos[tempindex].x+interval*k, playerPos[tempindex].y)
		self.effectLayer:addChild(card)
		local move = cc.MoveTo:create(0.2, cc.p(destPos[1].x+interval*k, destPos[1].y))
		card:runAction(move)
		table.insert(showUI, card)
	end
	SoundManager.playShowCards()
	if DateModel:getInstance():getTiShiPaiXing() then
	    local time = 0.2
	    local scaleArray = {1.5,3}
	    local alphaArray = {0,55}
	    local fadeIn = cc.FadeIn:create(time)
	    local fadeout = cc.FadeOut:create(time)
	    local fadeArray = {fadeIn,fadeout}
	    for i=1,2 do
			local typebg = ccui.ImageView:create("zhajinhua/cardTypeBg.png")
			-- typebg:setPosition(playerPos[tempindex].x+38, playerPos[tempindex].y)
			typebg:setPosition(destPos[1].x+38, destPos[1].y+40)
			typebg:setScale(2)
			local cardType = GameLogic.checkCardType(cardDataInfo)
			local cardTypeImage = ccui.ImageView:create("zhajinhua/"..cardTypeName[cardType])
			cardTypeImage:setPosition(121,39)
			cardTypeImage:setScale(1)
			typebg:addChild(cardTypeImage)
	      	typebg:setScale(scaleArray[i])
	      	typebg:setOpacity(alphaArray[i])
	      	typebg:setCascadeOpacityEnabled(true)
			self.effectLayer:addChild(typebg)
			table.insert(showUI, typebg)

		    local scale = cc.ScaleTo:create(time, 1)
			local move = cc.MoveTo:create(time, cc.p(destPos[1].x+38, destPos[1].y-30))
			
			typebg:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.Spawn:create(scale,move,fadeArray[i])))
		end
	end
	local armature = EffectFactory:getInstance():getShowCardArmature()
	armature:setPosition(570, 358)
	self.effectLayer:addChild(armature)
	self:performWithDelay(function ( )
		-- for i,v in ipairs(msg.wCompareUser) do
			local index = (v+5-DateModel:getInstance():getBankerUser())%5+1
			for j=1,3 do
				local card = self.cardArray[index][j]				
				-- if msg.wLostUser == v then
				-- 	card:loadTexture("zhajinhua/cardBroken.png")
				-- 	print("cardBroken")	
				-- 	print("-----------compareCard-performWithDelay", os.date("%H:%M:%S", os.time()))		
				-- end
				card:show()
			end
		-- end
		for i,v in ipairs(showUI) do
			v:removeFromParent()
		end
		-- SoundManager.playBaoZha()
	end, 2)--最后两个人比牌6秒后服务端回游戏结束报，所以这里延迟要小于6秒
end
function ViewCardLayer:gameEnd(msg,winChairID,playerLeftToOpenCardChairID)
	-- print("-----------ViewCardLayer:gameEnd", os.date("%H:%M:%S", os.time()))
	local myLookon = DataManager:getMyUserStatus() == Define.US_LOOKON
	local isPlaying = DataManager:getMyUserStatus() == Define.US_PLAYING
	local showcardArray = {}
	local myChairID = DataManager:getMyChairID()
    for k,v in ipairs(msg.cbCardData) do
        -- print(k,"v",v.wChairID)
        for l,w in ipairs(v.cbCardValue) do--v=CardData_Pro
            -- print(l,cardInfo[w])
        end
    end
    self.AllCardData = msg.cbCardData
    for i,v in ipairs(msg.wCompareUser) do
        -- print("比牌用户",i-1,v.wChairID,"myChairID",myChairID)
        if v.cbCardValue == nil then
        	v.cbCardValue = {}
        end
        if i == myChairID then
            for ll,ww in ipairs(v.cbCardValue) do--v=CardData_Pro没人ww就是65535
                if ww<=5 then
                	-- print("ww",ww)
                    table.insert(showcardArray, ww)
                end
            end
        end
        if v.cbCardValue then
	        for l,w in ipairs(v.cbCardValue) do--v=CardData_Pro
	            -- print("v.cbCardValue",l,w)
	        end
        end
    end
    for i,v in ipairs(showcardArray) do
    	-- print("showcardArray",v)
    end
    for i,v in ipairs(playerLeftToOpenCardChairID) do
    	table.insert(showcardArray, v)
    end

    table.insert(showcardArray, myChairID)

    if myChairID == Define.INVALID_CHAIR then
        myChairID = 0
        print("followCard==Define.INVALID_CHAIR",Define.INVALID_CHAIR)
    end
    local index = ((winChairID+5-myChairID)%5+3-1)%5+1
    -- print("index",index,"winChairID",winChairID,"myChairID",myChairID)
    ---收拢筹码的动画
    if #self.chipUI>14 then
		for i,v in ipairs(self.chipUI) do
	      local moveby = cc.MoveBy:create(0.5, cc.p(0,40))
	      local scale = cc.ScaleTo:create(0.5, 1.5)
	      local seq1 = cc.Sequence:create(moveby,cc.MoveBy:create(0.5, cc.p(0,-10)))
	      local seq2 = cc.Sequence:create(scale,cc.ScaleTo:create(0.5, 1.2))
	      local delayTime = 0.1*math.random(1, 5)
	      local delayToPlayer = cc.DelayTime:create(0.1+0.1*math.random(1, 5))
	      local movetoPlayer = cc.MoveTo:create(0.1, playerPos[index])
	      local playSound = cc.CallFunc:create(function() SoundManager.playGetChip() end)
	      local removeself = cc.CallFunc:create(function() v:removeSelf() end)

	      v:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.Spawn:create(seq1,seq2),delayToPlayer,movetoPlayer,playSound,removeself))
		end
	else
		for i,v in ipairs(self.chipUI) do
			local moveto = cc.MoveTo:create(0.5,playerPos[index])
			v:runAction(cc.Sequence:create(moveto,cc.CallFunc:create(function() v:removeSelf() end)))
		end
	end
	self.chipUI = {}
	if DateModel:getInstance():getLookOn() == 1 then
		for k,v in pairs(TableInfo.usersLookonInfo.isAllowLookon) do
			if DataManager:getMyChairID() == k and v then
				DateModel:getInstance():setAllowLookFromServer(1)
			end
		end
	end
	if (myLookon and DateModel:getInstance():getAllowLookFromServer() == 0) or (myLookon == false and isPlaying==false) then
		showcardArray = {}
	end
	-- print("myLookon",myLookon,"isPlaying",isPlaying,"#showcardArray",#showcardArray)
	-- print("showcardArray",showcardArray[1],showcardArray[2],showcardArray[3],showcardArray[4],showcardArray[5])
	for j,v in ipairs(showcardArray) do
		local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(v)
		if playerInfo and playerInfo.userStatus == Define.US_PLAYING then
			--todo
		
			local index = (v+5-DateModel:getInstance():getBankerUser())%5+1
			-- local total = msg.cbCardData[v+1].cbCardValue
			local cardArray = msg.cbCardData[v].cbCardValue
			local total = #cardArray
			local shoupai = "";
			cardArray = self:sortCards(cardArray)
		    for i=1,total do

		        -- shoupai = shoupai..string.format("0x%02x",cardArray[i])..","--cardInfo[
		        shoupai = shoupai..cardInfo[cardArray[i]]	        
		        local kind = math.floor(cardArray[i] / 0x10 )
		        local num = cardArray[i] % 0x10
		        local filename = "card/kb_"..kind.."_"..num..".png";
		        local card = self.cardArray[index][i]
		        -- print("filename",filename)
		        card:loadTexture(filename)
		    end
		    if DateModel:getInstance():getTiShiPaiXing() then
			    --显示牌型
			    local tempindex = ((v+5-myChairID)%5+2)%5+1
			    local cardType = GameLogic.checkCardType(cardArray)
			    -- if cardType == CARDS_TYPE.CT_1 then
			    -- else
				    self.typeArrayUI[tempindex]:getChildByName("cardType"):loadTexture("zhajinhua/"..cardTypeName[cardType])
				    self.typeArrayUI[tempindex]:show()
				    if tempindex==3 then
				    	self.typeArrayUI[tempindex]:setScale(1)
				    else
				    	self.typeArrayUI[tempindex]:setScale(0.5)
				    end
				    -- print("cardTypeName",cardTypeName[cardType],"shoupai",shoupai)
			    -- end 
		    end
	    end
	end
    --飘赢的数字start
    local winScore = 0
    for i,v in ipairs(msg.lGameScore) do
    	if i == winChairID then
    		winScore = v
    	end
    end

    local piao = require("zhajinhua.NumberLayer").new()
    piao:updateNum(10, winScore)
    piao:setPosition(playerPos[index].x-15,playerPos[index].y-10)
    self.effectLayer:addChild(piao)
    local move = cc.MoveBy:create(2,cc.p(0,70))
    local disAppear = cc.CallFunc:create(function ()
    	piao:removeFromParent()
    end) 
    piao:runAction(cc.Sequence:create(move,disAppear))

    --飘赢的数字end
	-- print("-----------gameEnd", os.date("%H:%M:%S", os.time()))
end
function ViewCardLayer:recoverGame(msg)
    local myChairID = DataManager:getMyChairID()
    if myChairID == Define.INVALID_CHAIR then
        myChairID = 0
        print("myChairID==Define.INVALID_CHAIR",Define.INVALID_CHAIR)
    end
    local banker = DateModel:getInstance():getBankerUser()
    -- local prepreID = (myChairID+3)%5
    -- local preID =(myChairID+4)%5
    -- local nextID = (myChairID+1)%5
    -- local nextnextID = (myChairID+2)%5
    -- local chairArry = {prepreID,preID,myChairID,nextID,nextnextID}
    local chairID = banker or 2
	local temp = {}
	local myIndex = 0
	local cardpos = {cc.p(319,417),cc.p(309,256),cc.p(633,146),cc.p(793,256),cc.p(761,416)}--重置牌的位置
	local otherIntervel = 16
	local myIntervel = 38
	local interval = 0
	local scaleNum = 1

    for i,v in ipairs(msg.bMingZhu) do
        -- print("看牌状态",i,v)
    end
	local bankerIndex = (chairID+5-myChairID)%5+3
	for j=1,5 do
		temp[j] = cardpos[((bankerIndex-1)+j-1)%5+1]
		-- print("temp[j]",temp[j].x,temp[j].y)
		if temp[j].y == cardpos[3].y then
			myIndex = j
		end
	end
	cardpos = temp
	--从庄家开始发牌
    for i=1,5 do    	
    	local bankerNew = (banker-1+i-1)%5+1
    	local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(bankerNew)
    	if playerInfo and (playerInfo.userStatus == Define.US_PLAYING or playerInfo.userStatus == Define.US_OFFLINE)then
    		if i==myIndex then
    			scaleNum = 1
    			interval = myIntervel
    		else
    			scaleNum = 0.7
    			interval = otherIntervel
    		end
    		local radian = {0,20,30}
			for j=0,2 do
				local card = self.cardArray[i][j+1]
				card:setPosition(cc.p(cardpos[i].x+interval*j, cardpos[i].y))
				card:setScale(scaleNum)
				card:setVisible(true)	
				card:setRotation(0)
				if msg.bMingZhu[bankerNew]==1 and bankerNew ~= myChairID then
					local rotateTo = cc.RotateTo:create(0.2,radian[j+1])
					card:runAction(rotateTo)
				end

			end
			-- print("msg.bMingZhu","selectChairID=",selectChairID,msg.bMingZhu[selectChairID])
    	end
    end
end
--默认从大到小
function ViewCardLayer:sortCards(cards,sortType)
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
return ViewCardLayer