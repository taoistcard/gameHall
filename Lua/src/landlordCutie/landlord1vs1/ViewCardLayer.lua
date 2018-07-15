--=======================================
-- filename:  ViewCardLayer.lua
-- Author: 	  <zhaxun>
-- Date:      2015-05-12 14:45:42
-- descrip:   发牌层
--=======================================
--[[
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,   //方块 A - K
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,   //梅花 A - K
    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,   //红桃 A - K
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D    //黑桃 A - K
]]

require("business.GameLogic")

local cardInfo = {
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",
}
local distance = 35

local EffectFactory = require("commonView.DDZEffectFactory")

local ViewCardLayer = class( "ViewCardLayer", function() return display.newLayer() end )
local SCALE_HAND = 1.0
local SCALE_OUT = 1.0
local SCALE_DIPAI = 1.0
local SCALE_MINGPAI = 0.8
local GreyColor = cc.c3b(128, 128, 128)

function ViewCardLayer:switchChairID()
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

function ViewCardLayer:setDataModel(dataModel)

    self.data = dataModel;
end

function ViewCardLayer:ctor(dataModel)
    self.data = dataModel;

    --self:setContentSize(cc.size(display.width,display.height))
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
    
    local myChairID = DataManager:getMyChairID()
    self.myChairID = myChairID
    print("self.myChairID" ,self.myChairID)
    self:switchChairID()

    self.posTable={}
    self.posTable[self.myChairID] = cc.p(0, -170)
    self.posTable[self.nextID] = cc.p(360,50)
    -- self.posTable[(self.myChairID+2)%3] = cc.p(-360,50)

    self.myCards={};--手牌
    self.cardPos={};--手牌坐标
    self.selCards={};--手牌选中标志
    self.cardOpen = {}--本家打出的牌
    self.bankerlogPos = cc.p(88,129)
    self.bankerlog_outPos = cc.p(50,75)
    --下家打出的牌容器
    self.outCardsNext = display.newNode():addTo(self):align(display.CENTER, display.cx + self.posTable[self.nextID].x - 60, display.cy + self.posTable[self.nextID].y + 60)
    self.nextCardsNum =17
    
    --上家打出的牌容器
    -- self.outCardsPre  = display.newNode():addTo(self):align(display.CENTER, display.cx + self.posTable[self.preID].x + 60, display.cy + self.posTable[self.preID].y + 60)
    
    self.tishiCards = nil--提示

    self.mpCardsPre={};--上家明牌
    self.mpCardsNext={};--下家明牌

    self.tip = display.newSprite("tip/meipai.png"):addTo(self):align(display.CENTER, display.cx, display.cy - 60):hide()

    self.effectLayer = display.newLayer():addTo(self,2)
    self.effectLayer:setTouchEnabled(true)
    self.effectLayer:setTouchSwallowEnabled(false)

    self.aniJB={}
    self.aniJB[self.myChairID] = display.newSprite():addTo(self.effectLayer):align(display.CENTER, display.cx - 420, display.cy - 200)
    self.aniJB[self.nextID] = display.newSprite():addTo(self.effectLayer):align(display.CENTER, display.cx + 380, display.cy + 180)
    -- self.aniJB[self.preID] = display.newSprite():addTo(self.effectLayer):align(display.CENTER, display.cx - 380, display.cy + 180)
    self:refreshRangPaiUI(false,false,0,17)
end
function ViewCardLayer:refreshRangPaiUI(isShow,isFarmer,rangpaiNum,leftNum)
    if rangpaiNum < 0 then
        rangpaiNum = 0
    end

    if self.containerRangPai then
        self.containerRangPai:removeAllChildren();
        self.containerRangPai = nil;
    end

    local containerRangPai = display.newSprite("landlord1vs1/rangbg.png"):addTo(self.effectLayer);
    containerRangPai:setPosition(cc.p(105,320));
    self.containerRangPai = containerRangPai;

    local center = cc.p( containerRangPai:getContentSize().width / 2, containerRangPai:getContentSize().height / 2);

    if isFarmer == true then

        local text = display.newSprite("landlord1vs1/nongming_word.png"):addTo(containerRangPai);
        text:setPosition(center.x, center.y);

        local rangpaiTxt = display.newBMFontLabel(
        {
            text = rangpaiNum or "",
            font = "fonts/jinbiSZ.fnt",
        }):addTo(containerRangPai);
        rangpaiTxt:setPosition(99, 64);

        local leftTxt = display.newBMFontLabel(
        {
            text = leftNum or "",
            font = "fonts/jinbiSZ.fnt",
        }):addTo(containerRangPai);
        leftTxt:setPosition(55, 28);

    else

        local text = display.newSprite("landlord1vs1/dizhu_word.png"):addTo(containerRangPai);
        text:setPosition(center.x, center.y);

        local rangpaiTxt = display.newBMFontLabel(
        {
            text = rangpaiNum or "",
            font = "fonts/jinbiSZ.fnt",
        }):addTo(containerRangPai);
        rangpaiTxt:setPosition(72, 64);

        local leftTxt = display.newBMFontLabel(
        {
            text = leftNum or "",
            font = "fonts/jinbiSZ.fnt",
        }):addTo(containerRangPai);
        leftTxt:setPosition(67, 28);


    end
 
end

function ViewCardLayer:hideJingBao(index)
    -- body
    self.aniJB[index]:setTexture("")
    self.aniJB[index]:hide()
end

function ViewCardLayer:showJingBao(index, num)
    if num <= 0 then
        self.aniJB[index]:hide()

    else
        local userInfo = DataManager:getUserInfoInMyTableByChairID(index)
        if userInfo then
            SoundManager.playEfectBaoJing(userInfo.gender, num)
        end

        self.aniJB[index]:stopAllActions()
        local ani = EffectFactory:getInstance():getAnimationByName("jingbao")
        self.aniJB[index]:runAction(cc.RepeatForever:create(cc.Animate:create(ani)))
    end
end

function ViewCardLayer:start(callBack)
    self:sendCard();
    self.callfunc = callBack
end

function ViewCardLayer:reset()
   -- self._label = nil
   -- self:removeAllChildrenWithCleanup()
   -- self:drawCard()	
end


-- 地主抄底后，显示底牌
function ViewCardLayer:drawDiPai()
    local cbBankerCardTypeArray = {"其它","单王","对2","顺子","同花","三条","全小","双王"}
    local node = display.newNode()
                    :addTo(self)
                    :align(display.CENTER, display.cx, display.cy+260)
    
    local orignalPos = cc.p(0, 0)
    local total = #self.data.dipai
    local mid = (1+total)/2
    for i=1, total, 1 do
        orignalPos.x = (i-mid)*distance*SCALE_DIPAI

        local kind = math.floor(self.data.dipai[i] / 0x10 )
        local num = self.data.dipai[i] % 0x10
        local filename = "card/kb_"..kind.."_"..num..".png";
        local card = display.newSprite(filename);
        card:align(display.CENTER, orignalPos.x, orignalPos.y)
            :addTo(node,0,0x10*kind+num)
            :scale(SCALE_DIPAI)
            :hide()
        


        local sequence = transition.sequence(
                {
                    cc.DelayTime:create(0.1*i),
                    cc.CallFunc:create(function() card:show(); end),
                    --cc.MoveTo:create(dur, destPos)
                }
            )
        card:runAction(sequence)
    end
        -- local cardType = ccui.Text:create();
        -- cardType:setString(cbBankerCardTypeArray[self.data.dipaiType])
        -- cardType:setPosition(35+20, 30)
        -- cardType:setColor(cc.c3b(255, 0, 0))
        -- cardType:setFontSize(25)
        -- node:addChild(cardType)
        
        -- local cardPlus = ccui.Text:create()
        -- cardPlus:setString(self.data.dipaiPlus.."倍")
        -- cardPlus:setPosition(-35, -30)
        -- cardPlus:setColor(cc.c3b(255, 0, 0))
        -- cardPlus:setFontSize(25)
        -- node:addChild(cardPlus)
        print("self.data.dipaiType",self.data.dipaiType,"self.data.dipaiPlus",self.data.dipaiPlus,cbBankerCardTypeArray[self.data.dipaiType])
        if self.data.dipaiType >1 and self.data.dipaiType<9 then
        
            local cardTypeBg = ccui.ImageView:create("landlord1vs1/dpbg.png")
            if cardTypeBg then
                cardTypeBg:setPosition(0, -25)
                node:addChild(cardTypeBg)
            end
            local cardType = ccui.ImageView:create("landlord1vs1/dipaitype"..(self.data.dipaiType-1)..".png")
            if cardType then
                cardType:setPosition(-35, -25)
                node:addChild(cardType)
            end
            local cardPlus = ccui.ImageView:create("landlord1vs1/dipaiplus"..self.data.dipaiPlus..".png")
            if cardPlus then
                cardPlus:setPosition(35, -25)
                node:addChild(cardPlus)
            end
        end
    self:refreshRangPaiUIByIsFarmer(self.data.isFarmer)
end


-- 刷新明牌信息
function ViewCardLayer:refreshMingPai(player)
    local cards = nil
    if player == 2 then
        cards = self.mpCardsNext
    else
        cards = self.mpCardsPre
    end

    if cards then
        local count = math.random(5,17)
        for k,v in ipairs(cards) do
            if k <= count then

                local kind = math.floor( self.data.cards[player][k] / 0x10 );--math.random(0,3);
                local num = self.data.cards[player][k] % 0x10;--math.random(1,13);
                --local kind = math.random(0,3);
                --local num = math.random(1,13);
                local filename = "card/kb_"..kind.."_"..num..".png";
                v:setTexture(filename)
                v:setTextureRect(cc.rect(0,0,50,65));
                v:show();

            else
                v:hide();
            end
        end
    end

end

-- 玩家明牌后，显示玩家所有牌
function ViewCardLayer:drawMingPai(player)
    local index = player
    local node = display.newNode()
    self:addChild(node);
	
    local orignalPos = nil
    if index == 2 then
        orignalPos = cc.p(display.cx + 300, display.cy + 200)
    else
        orignalPos = cc.p(display.cx - 250, display.cy + 200)
    end
    if index == 2 then
        orignalPos.x = orignalPos.x - 200
    elseif index == 3 then
        orignalPos.x = orignalPos.x - 50
    end

    local destPos = cc.p(orignalPos.x, orignalPos.y);
    local total = #self.data.cards[player]
    local mid = 8
    for i=1, total, 1 do

        local kind = math.floor(self.data.cards[player][i] / 0x10 );--math.random(0,3);
        local num = self.data.cards[player][i] % 0x10;--math.random(1,13);
        if i <= mid then--第一排
            destPos.x = orignalPos.x + i*distance*SCALE_MINGPAI

        elseif i <= 2*mid then--第二排
            destPos.y = orignalPos.y - 40
            destPos.x = orignalPos.x + (i-mid)*distance*SCALE_MINGPAI

        else--第三排
            destPos.y = orignalPos.y - 80
            destPos.x = orignalPos.x + (i-2*mid)*distance*SCALE_MINGPAI
        end
        

        local filename = "card/kb_"..kind.."_"..num..".png";
        
        local card = cc.Sprite:create(filename, cc.rect(0,0,50,65));
        card:align(display.CENTER, destPos.x, destPos.y)
            :addTo(node,0,0x10*kind+num)
            :hide()
        if index == 2 then
            table.insert(self.mpCardsNext, card)
        else
            table.insert(self.mpCardsPre, card)
        end

        local sequence = nil
        sequence = transition.sequence(
                        {
                            cc.DelayTime:create(0.1*i),
                            cc.CallFunc:create(function() card:show(); end),
                        }
                        )
       
        card:runAction(sequence)
    end
end

-- 游戏结束，显示所有牌
function ViewCardLayer:showAllCards(msg)
    --隐藏警报器
    self:hideJingBao(1)
    self:hideJingBao(2)


    --清空出牌
    self.outCardsNext:removeAllChildren()
    -- self.outCardsPre:removeAllChildren()

    self.cardNext:removeSelf()
    

    --显示手牌
    local n = 1
    for k,v in ipairs(msg.cbCardCount) do
        local cards = {}
        for i=n, n + v - 1 do
            table.insert(cards, msg.cbHandCardData[i])
        end
        n = n + v
        self:showPlayerCards(k, cards)
    end

    --托管颜色调整
    for k,v in ipairs(self.myCards) do
        self.myCards[k]:setColor(display.COLOR_WHITE);
    end
end

function ViewCardLayer:showAllCardsDelay(msg, delay)
    --隐藏警报器
    self:hideJingBao(1)
    self:hideJingBao(2)
    -- self:hideJingBao(2)

    self:performWithDelay(function() self:showAllCards(msg) end, delay)
end

function ViewCardLayer:showPlayerCards(index, cards)
    local node = display.newNode()
    self:addChild(node);
    
    local orignalPos = nil
    if index == self.nextID then
        orignalPos = cc.p(display.cx + 300, display.cy + 200)
        orignalPos.x = orignalPos.x - 200
    elseif index == self.preID then
        orignalPos = cc.p(display.cx - 250, display.cy + 200)
        orignalPos.x = orignalPos.x - 50
    else
        return
    end

    local destPos = cc.p(orignalPos.x, orignalPos.y);
    local total = #cards
    local mid = 8
    for i=1, total, 1 do

        local kind = math.floor(cards[i] / 0x10 )
        local num = cards[i] % 0x10
        if i <= mid then--第一排
            destPos.x = orignalPos.x + i*distance*SCALE_MINGPAI

        elseif i <= 2*mid then--第二排
            destPos.y = orignalPos.y - 40
            destPos.x = orignalPos.x + (i-mid)*distance*SCALE_MINGPAI

        else--第三排
            destPos.y = orignalPos.y - 80
            destPos.x = orignalPos.x + (i-2*mid)*distance*SCALE_MINGPAI
        end
        

        local filename = "card/kb_"..kind.."_"..num..".png";
        
        local card = display.newSprite(filename);
        card:align(display.CENTER, destPos.x, destPos.y)
            :addTo(node,0,0x10*kind+num)
            :scale(SCALE_MINGPAI)
            :hide()
        if index == 2 then
            table.insert(self.mpCardsNext, card)
        else
            table.insert(self.mpCardsPre, card)
        end

        local sequence = nil
        sequence = transition.sequence(
                        {
                            cc.DelayTime:create(0.05*i),
                            cc.CallFunc:create(function() card:show(); end),
                        }
                        )
       
        card:runAction(sequence)
    end
end

function ViewCardLayer:endSelectCards()
    if self.beganPos and self.endPos then
        local rect = cc.rect(0,0,0,0)
        if self.beganPos.x < self.endPos.x then
            rect.x = self.beganPos.x
        else 
            rect.x = self.endPos.x
        end
        if self.beganPos.y < self.endPos.y then
            rect.y = self.beganPos.y
        else
            rect.y = self.endPos.y
        end
        rect.width = math.abs(self.beganPos.x-self.endPos.x)
        rect.height = math.abs(self.beganPos.y-self.endPos.y)
        if rect.width < 1 then rect.width =1 end
        if rect.height < 1 then rect.height =1 end

        for k,v in ipairs(self.cardPos) do
            self.myCards[k]:setColor(cc.c3b(255, 255, 255))

            if cc.rectIntersectsRect(v, rect) then
                if cc.rectIntersectsRect(v, rect) then
                    if self.selCards[k] == 1 then
                        self.selCards[k] = 0;
                        local x,y = self.myCards[k]:getPosition();
                        self.myCards[k]:setPosition(cc.p(x, y -20))
                    else
                        self.selCards[k] = 1;
                        local x,y = self.myCards[k]:getPosition();
                        self.myCards[k]:setPosition(cc.p(x, y +20))
                    end

                end
            end
        end
        --自动匹配上家出牌
        if self.lastOutCardUser ~= self.myChairID and self.lastOutCards and self.isMyTurn then
            
            local selCards = {}
            local handCards = {}
            for k,v in ipairs(self.selCards) do
                if v == 1 then
                    table.insert(selCards, self.myCards[k]:getTag())
                end
                table.insert(handCards, self.myCards[k]:getTag())
            end
            
            local tipCards = GameLogic.autoTiShi(handCards, self.lastOutCards, selCards)
            if tipCards then
                self:cancelSelectCards()
                for key, var in ipairs(tipCards) do
                    self.selCards[var] = 1
                    local x,y = self.myCards[var]:getPosition();
                    self.myCards[var]:setPosition(cc.p(x, y + 20))
                end
            end

        elseif not self.lastOutCardUser or self.lastOutCardUser == self.myChairID then

            if not self.hasAutoComplete then
                --自动选出符合条件的牌型
                local selCards = {}
                local handCards = {}
                for k,v in ipairs(self.selCards) do
                    if v == 1 then
                        table.insert(selCards, self.myCards[k]:getTag())
                    end
                    table.insert(handCards, self.myCards[k]:getTag())
                end
                self.hasAutoComplete = GameLogic.autoCompleteCards(selCards, handCards)
                if self.hasAutoComplete then
                    self:cancelSelectCards()
                    for key, var in ipairs(self.hasAutoComplete) do
                        self.selCards[var] = 1
                        local x,y = self.myCards[var]:getPosition();
                        self.myCards[var]:setPosition(cc.p(x, y + 20))
                    end
                end
            end
        end

    end
end

function ViewCardLayer:selectCards()

    if self.beganPos and self.endPos then
        local rect = cc.rect(0,0,0,0)
        if self.beganPos.x < self.endPos.x then
            rect.x = self.beganPos.x
        else 
            rect.x = self.endPos.x
        end
        if self.beganPos.y < self.endPos.y then
            rect.y = self.beganPos.y
        else
            rect.y = self.endPos.y
        end
        rect.width = math.abs(self.beganPos.x-self.endPos.x)
        rect.height = math.abs(self.beganPos.y-self.endPos.y)
        if rect.width < 1 then rect.width =1 end
        if rect.height < 1 then rect.height =1 end

        for k,v in ipairs(self.cardPos) do
            if cc.rectIntersectsRect(v, rect) then
                self.myCards[k]:setColor(cc.c3b(128, 128, 128));
            else
                self.myCards[k]:setColor(cc.c3b(255, 255, 255));
            end

        end
    end

end

function ViewCardLayer:onTouchBegan()
    if self.firstTouchTime == nil then--第一次点击
        self.firstTouchTime = os.time()

    else
        if os.time() - self.firstTouchTime <=1.0 then--双击取消
            for k,v in ipairs(self.selCards) do
                if v == 1 then
                    self.selCards[k] = 0;
                    local x,y = self.myCards[k]:getPosition();
                    self.myCards[k]:runAction(cc.MoveTo:create(0.1, cc.p(x, y -20)))
                end
            end

        end

        self.firstTouchTime = nil;
    end
    
end

-- 区域选牌
function ViewCardLayer:onTouchHandler(event)

    --local name, x, y, prevX, prevY = event.name, event.x, event.y, event.prevX, event.prevY
    if event.name == "began" then

        local total = #self.myCards;
        if total >= 1 then
            local rect1=self.myCards[1]:getCascadeBoundingBox()
            local rect2=self.myCards[total]:getCascadeBoundingBox()
            local rect = cc.rectUnion(rect1,rect2);

            if cc.rectContainsPoint(rect, cc.p(event.x,event.y)) then
                self.beganPos = cc.p(event.x, event.y);
                self.endPos = cc.p(event.x,event.y);
                self:selectCards();
            
            else -- 记录双击开始
                self:onTouchBegan()
            end
        end
        return true;
        --return cc.TOUCH_BEGAN_NO_SWALLOWS -- continue event dispatching

    elseif event.name == "moved" then

        local total = #self.myCards;
            if total >= 1 then
            local rect1=self.myCards[1]:getCascadeBoundingBox()
            local rect2=self.myCards[total]:getCascadeBoundingBox()
            local rect = cc.rectUnion(rect1,rect2);
            
            if cc.rectContainsPoint(rect, cc.p(event.x,event.y)) then
                self.endPos = cc.p(event.x,event.y);
                self:selectCards();
            end
        end
        
    elseif event.name == "ended" then
        local total = #self.myCards;
        if total >= 1 then
            local rect1=self.myCards[1]:getCascadeBoundingBox()
            local rect2=self.myCards[total]:getCascadeBoundingBox()
            local rect = cc.rectUnion(rect1,rect2);
            
            if cc.rectContainsPoint(rect, cc.p(event.x,event.y)) then
                self.endPos = cc.p(event.x,event.y);
                self:endSelectCards();
                self.beganPos = nil
                self.endPos = nil
            
            else
                self:endSelectCards();
                self.beganPos = nil
                self.endPos = nil
            end
        end
    end
end

-- 游戏开始后的发牌，显示自己的牌，其他玩家牌只显示数量
function ViewCardLayer:sendCard()
    local interval = 0.12

    local newLayer = display.newLayer()
    self.sendCardLayer = newLayer
    self:addChild(newLayer,1);

    newLayer:setTouchEnabled(true)
    newLayer:setTouchSwallowEnabled(false)
    newLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    newLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)        
        self:onTouchHandler(event)
        return true--必须返回true，否则无法接受touch后面的消息
    end)

    local orignalPos = cc.p(display.cx + self.posTable[self.myChairID].x, display.cy + self.posTable[self.myChairID].y)
    local destPos = cc.p(orignalPos.x, orignalPos.y);
    local total = #self.data.cards
    local mid = (1+total)/2 -- math.floor(total/2)+1
    local distance = (1136 - 100)/17
    local shoupai = ""
    
    --绿点，先叫地主标记
    if self.data.banker ==  DataManager:getMyChairID() then
        --todo

        local greenPoint = display.newSprite("landlord1vs1/jdz_first.png")
--            :align(display.CENTER, display.cx, orignalPos.y-40)
            -- :addTo(newLayer)
        self.greenPoint = greenPoint
    end
    
    local randpos = math.random(1,total)
    print("randpos",randpos)
    for i=1, total, 1 do

        local kind = math.floor( self.data.cards[i] / 0x10 );--math.random(0,3);
        local num = self.data.cards[i] % 0x10;--math.random(1,13);
        -- print("kind-num手牌"..string.format("0x%02x",self.data.cards[i]))
        shoupai = shoupai..string.format("0x%02x",self.data.cards[i])..","
	    if i >= mid then
            orignalPos.x = display.cx + self.posTable[self.myChairID].x + (i-mid)*distance*SCALE_HAND
        end
        destPos.x = orignalPos.x - (mid-i)*distance*SCALE_HAND

	    local filename = "poker/kb_"..kind.."_"..num..".png";
	    
        -- 牌型信息用tag值纪录
        local card = display.newSprite(filename):align(display.CENTER, orignalPos.x, orignalPos.y)
                                                :addTo(newLayer,0,0x10*kind+num)
                                                :hide()
                                                :scale(SCALE_HAND)
        
        if i == randpos and self.greenPoint then
            card:addChild(self.greenPoint)
            self.greenPoint:setPosition(-146/2+95, -186/2+115)
        end
        local sequence = nil
        if i < mid then
		  sequence = transition.sequence(
				            {
				                cc.DelayTime:create(interval*i),
				                cc.CallFunc:create(function() card:show(); SoundManager.playSound("sound/sendcard.mp3"); end),
				                cc.MoveTo:create(math.abs(i-mid)*interval, destPos)
				            }
                    		)
        elseif i < total then
            sequence = transition.sequence(
                {
                    cc.DelayTime:create(interval*i),
                    cc.CallFunc:create(function() card:show(); SoundManager.playSound("sound/sendcard.mp3"); end),
                    --cc.MoveTo:create(dur, destPos)
                }
            )
        else
            sequence = transition.sequence(
                {
                    cc.DelayTime:create(interval*i),
                    cc.CallFunc:create(function() card:show(); SoundManager.playSound("sound/sendcard.mp3"); end),
                    cc.CallFunc:create(function()     
                            if self.callfunc then
                                self.callfunc();
                            end 
                        end)
                }
            )
	    end
        card:runAction(sequence)

        table.insert(self.selCards, 0)
        table.insert(self.myCards, card);
    end
    print("total==",total,"手牌------",shoupai,"self.data.isFarmer",self.data.isFarmer)
    -- if self.data.isFarmer ~= true then
    --     local bankerlog = cc.Sprite:create("poker/banner_dizhu.png")
    --     newLayer:addChild(bankerlog)
    --     self.bankerlog = bankerlog
    --     bankerlog:setPosition(orignalPos.x+20, orignalPos.y+20)
    --     -- bankerlog:setScale(0.736)
    -- end
    -- 发下家牌
    orignalPos = cc.p(display.cx + self.posTable[self.nextID].x + 30, display.cy + self.posTable[self.nextID].y - 10)
    local nextCard = display.newSprite("card/kb_0_0.png"):align(display.CENTER, orignalPos.x, orignalPos.y)
                                            :addTo(newLayer)
                                            :scale(0.5)
    

    self.nextCardsNum = 1 

    local text = ccui.Text:create(self.nextCardsNum,"",40)
    --text:setFontSize(40)
    text:setTextColor(cc.c4b(255,255,255,255))
    text:enableOutline(cc.c4b(255,255,255,255), 2)
    text:align(display.CENTER,nextCard:getContentSize().width / 2,nextCard:getContentSize().height / 2)
    text:addTo(nextCard, 0, 1)

    nextCard:runAction(transition.sequence(
                            {
                                cc.DelayTime:create(interval),
                                cc.CallFunc:create(function() self:sendNextCard(nextCard) end)
                            }))
    self.cardNext = nextCard

    -- 发上家牌
    -- orignalPos = cc.p(display.cx + self.posTable[self.preID].x -10, display.cy + self.posTable[self.preID].y - 40)
    -- local preCard = display.newSprite("card/kb_0_0.png"):align(display.CENTER, orignalPos.x, orignalPos.y)
    --                                         :addTo(newLayer)
    --                                         :scale(0.6)
    -- self.preCardsNum = 1
    -- local text = ccui.Text:create(self.preCardsNum,"",40)
    -- --text:setFontSize(40)
    -- text:setTextColor(cc.c3b(255,255,255))
    -- text:enableOutline(cc.c3b(0,0,0), 2)
    -- text:align(display.CENTER,preCard:getContentSize().width / 2,preCard:getContentSize().height / 2)
    -- text:addTo(preCard, 0, 1)
    
    -- preCard:runAction(transition.sequence(
    --                         {
    --                             cc.DelayTime:create(interval),
    --                             cc.CallFunc:create(function() self:sendPreCard(preCard) end)
    --                         }))
    -- self.cardPre = preCard

end

function ViewCardLayer:sendPreCard(sender)
    
    if self.preCardsNum < 17 then
        self.preCardsNum = self.preCardsNum + 1
        sender:getChildByTag(1):setString(tostring(self.preCardsNum))
        sender:runAction(transition.sequence(
                            {
                                cc.DelayTime:create(0.12),
                                cc.CallFunc:create(function() self:sendPreCard(sender) end)
                            }))
    end
end

function ViewCardLayer:sendNextCard(sender)
    
    if self.nextCardsNum < 17 then
        self.nextCardsNum = self.nextCardsNum + 1
        sender:getChildByTag(1):setString(tostring(self.nextCardsNum))
        sender:runAction(transition.sequence(
                            {
                                cc.DelayTime:create(0.12),
                                cc.CallFunc:create(function() self:sendNextCard(sender) end)
                            }))
    end
end

function ViewCardLayer:refreshMyCardPos()
    self.selCards = {};
    self.cardPos = {};
    local total = #self.myCards
    local distance = nil
    if total > 17 then
        distance = (1136-100)/total
    else
        distance = (1136-100)/17
    end
    for k,v in ipairs(self.myCards) do
        --cc.rectContainsPoint(
        local rect = v:getCascadeBoundingBox()
        if k ~= #self.myCards then
            table.insert(self.cardPos, k, cc.rect(rect.x,rect.y,distance*SCALE_HAND,rect.height))
        else
            table.insert(self.cardPos, k, rect)
        end
        table.insert(self.selCards, k, 0)

    end
end

--更新手牌坐标
function ViewCardLayer:moveCardsByIndex(index, mid)

    for k,v in ipairs(self.myCards) do
        if index <= mid then--向右移动distance
            if k < index and self.selCards[k] == 0 then
                self.myCards[k]:runAction(cc.MoveBy:create(0.1, cc.p(distance*SCALE_HAND, 0)))
            end
        elseif index > mid then--向左移动distance
            if k > index and self.selCards[k] == 0 then
                self.myCards[k]:runAction(cc.MoveBy:create(0.1, cc.p(-distance*SCALE_HAND, 0)))
            end
        end

    end

end

-- 出牌
function ViewCardLayer:playCards(cards)
    self:msgOutCards(cards)

    -- self.tishiCards = nil
    return true
end

function ViewCardLayer:getIndexByTag(tag)
    for k,v in ipairs(self.myCards) do
        if v ~= 0 and v:getTag() == tag then
            return k
        end
    end
    return -1
end

function ViewCardLayer:isOutCard()

end

function ViewCardLayer:drawMyOutCards(cards, isRecover)
    if isRecover then

        local orignalPos = cc.p(display.cx, display.cy + 35)

        --显示打出卡牌
        local total = #cards
        local mid = (1+total)/2
        for i=1, total, 1 do
            local kind = math.floor(cards[i] / 0x10 )
            local num = cards[i] % 0x10
            local filename = "card/kb_"..kind.."_"..num..".png";
            local card = cc.Sprite:create(filename);
            self:addChild(card)
            card:scale(SCALE_OUT)
            card:setPosition(cc.p(orignalPos.x - (mid-i)*distance*SCALE_OUT, orignalPos.y))

            table.insert(self.cardOpen, card);
        end
        
    else
        self:cancelSelectCards()

        local myCards = {}
        local total = #self.myCards
        local mid = (1+total)/2

        self.cardOpen = {}
        self.selCards = {}

        for i=1,total do
            table.insert(self.selCards, 0)
        end

        for k,v in ipairs(cards) do
            local index = self:getIndexByTag(v)
            self.selCards[index] = 1
        end


        --移动手牌位置
        for k,v in ipairs(self.selCards) do
            if v == 1 then
                table.insert(self.cardOpen, self.myCards[k]);
                --self:moveCardsByIndex(k, mid);--移动手牌位置

            else
                table.insert(myCards, self.myCards[k]);
            end
        end
        
        --更新手牌
        self.myCards = myCards
        --更新手牌坐标
        self:updateCardPos(self.myCards)
        
        --显示打出卡牌
        local total = #self.cardOpen
        local mid = (1+total)/2
        local orignalPos = cc.p(display.cx, display.cy + 35)
        for k,v in ipairs(self.cardOpen) do
            v:setColor(display.COLOR_WHITE)            
            if v:getChildByTag(100) then
                v:removeChildByTag(100)
            end
            v:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(0.1, cc.p(orignalPos.x - (mid-k)*distance*SCALE_OUT, orignalPos.y)),
                    cc.CallFunc:create(function() 
                        local tag = v:getTag()
                        local kind = math.floor(tag / 0x10 )
                        local num = tag % 0x10
                        local filename = "card/kb_"..kind.."_"..num..".png";
                        local frame = cc.SpriteFrame:create(filename, display.newSprite(filename):getTextureRect())
                        v:setSpriteFrame(frame)
                        end)
                    ))
            v:scale(SCALE_OUT)
        end        

        --显示警报
        local rangCount = 0
        local leftCount = 0
        if self.data.robTimes ~=nil then
            rangCount = self.data.robTimes
        end

        local leftcardNum = self.nextCardsNum
        if self.data.isFarmer then
            leftcardNum = #self.myCards
        end
        local warnningNum = #self.myCards
        if self.data.isFarmer then--自己是农民
            warnningNum = warnningNum-rangCount-3*self.data.farmerFirst
        end

        if self.data.farmerFirst ~=nil then
            leftCount = leftcardNum-rangCount-3*self.data.farmerFirst
            rangCount = rangCount + 3*self.data.farmerFirst
        end
        print("drawMyOutCards--drawMyOutCards--self.nextCardsNum",self.nextCardsNum,"warnningNum",warnningNum)
        if warnningNum <= 2 then
            self:showJingBao(self.myChairID, warnningNum)
        end

        --没牌的时候，隐藏地主角标
        if warnningNum == 0 then
            if self.bankerlog then
                -- local bb = getmetatable(self.bankerlog)
                -- dump(bb, "self.bankerlog")
                -- self.bankerlog:hide();
            end
        end
        self:refreshRangPaiUI(true,self.data.isFarmer,rangCount,leftCount)

        -- if #self.myCards <= 2 then
        --     self:showJingBao(self.myChairID, #self.myCards)
        -- end
    end
end

-- 出牌
function ViewCardLayer:drawNextOutCards(cards, isRecover)
    -- 清空
    self.outCardsNext:removeAllChildren()
    
    local node = self.outCardsNext
    local orignalPos = cc.p(0,0)
    local destPos = {orignalPos.x, orignalPos.y}
    local total = #cards
    local rightCard --最右边那张牌
    for i=total, 1, -1 do
        destPos.x = -i*distance*SCALE_OUT

        local kind = math.floor(cards[i] / 0x10 )
        local num = cards[i] % 0x10
        local filename = "card/kb_"..kind.."_"..num..".png";
        local card = cc.Sprite:create(filename);
        card:align(display.CENTER, orignalPos.x, orignalPos.y)
            :addTo(node, 0, cards[i])
            :scale(SCALE_OUT)
        
        local sequence = transition.sequence(
                {
                    cc.MoveTo:create(i*0.1, destPos)
                }
            )
        card:runAction(sequence)
        if i == 1 then
            rightCard = card
        end        
    end
    --设置地主角标
    if self.data.banker == self.nextID and total>0 then
        local bankerlog_out = cc.Sprite:create("poker/banner_dizhu.png")        
        bankerlog_out:setPosition(self.bankerlog_outPos)
        bankerlog_out:setScale(0.55*rightCard:getScale())
        rightCard:addChild(bankerlog_out,1,101)
    end
    --更新数量
    if not isRecover then
        self.nextCardsNum = self.nextCardsNum - #cards
    end
    if self.nextCardsNum == 0 then
        self.cardNext:hide()
    else
        self.cardNext:getChildByTag(1):setString(self.nextCardsNum)
    end

    --显示警报

    local rangCount = 0
    local leftCount = 0
    if self.data.robTimes ~=nil then
        rangCount = self.data.robTimes
    end

    local leftcardNum = self.nextCardsNum

    if self.data.isFarmer then
        leftcardNum = #self.myCards
    end
    local warnningNum = self.nextCardsNum
    if self.data.isFarmer == false then--下家是农民
        warnningNum = warnningNum-rangCount-3*self.data.farmerFirst
    end
    if self.data.farmerFirst ~=nil then
        leftCount = leftcardNum-rangCount-3*self.data.farmerFirst
        rangCount = rangCount + 3*self.data.farmerFirst
    end
    print("drawNextOutCards--drawNextOutCards--self.nextCardsNum",self.nextCardsNum,"warnningNum",warnningNum)
    if warnningNum <= 2 then
        print("ViewCardLayer----========self.myChairID",self.myChairID,"self.nextID",self.nextID)
        self:showJingBao(self.nextID, warnningNum)
    end

    self:refreshRangPaiUI(true,self.data.isFarmer,rangCount,leftCount)
end
function ViewCardLayer:refreshRangPaiUIByIsFarmer(isFarmer)
    local rangCount = 0
    local leftCount = 0
    if self.data.robTimes ~=nil then
        rangCount = self.data.robTimes
    end

    local leftcardNum = self.nextCardsNum

    if self.data.isFarmer then
        leftcardNum = #self.myCards
    end
    if self.data.farmerFirst ~=nil then
        leftCount = leftcardNum-rangCount-3*self.data.farmerFirst
        rangCount = rangCount + 3*self.data.farmerFirst
    end
    if (self.nextCardsNum-rangCount-3*self.data.farmerFirst) <= 2 then
        self:showJingBao(self.nextID, self.nextCardsNum-rangCount-3*self.data.farmerFirst)
    end

    self:refreshRangPaiUI(true,isFarmer,rangCount,leftCount)
end
-- 出牌
function ViewCardLayer:drawPreOutCards(cards)
    -- 清空
    -- self.outCardsPre:removeAllChildren()

    local node = self.outCardsPre
    local orignalPos = cc.p(0,0)
    local destPos = {orignalPos.x, orignalPos.y}
    local total = #cards
    for i=1, total, 1 do
        destPos.x = i*distance*0.6

        local kind = math.floor( cards[i] / 0x10 )
        local num = cards[i] % 0x10
        local filename = "card/kb_"..kind.."_"..num..".png";
        local card = cc.Sprite:create(filename);
        card:align(display.CENTER, orignalPos.x, orignalPos.y)
            :addTo(node, 0, cards[i])
        
        local sequence = transition.sequence(
                {
                    cc.MoveTo:create(i*0.1, destPos)
                }
            )
        card:runAction(sequence)

    end

    --更新数量
    self.preCardsNum = self.preCardsNum - #cards
    if self.preCardsNum == 0 then
        -- self.cardPre:hide()
    else
        -- self.cardPre:getChildByTag(1):setString(self.preCardsNum)
    end

    --显示警报
    if self.preCardsNum <= 2 then
        -- self:showJingBao(self.preID, self.preCardsNum)
    end
end

function ViewCardLayer:initCardPos()
    --排序
    local cards = {}
    for k,v in ipairs(self.myCards) do
        table.insert(cards, v:getTag())
    end

    GameLogic.sortCards(cards)
    local total = #self.myCards
    local distance = nil
    if total > 17 then
        distance = (1136 - 100)/total
    else
        distance = (1136 - 100)/17
    end

    self.selCards={}
	for k,v in ipairs(self.myCards) do
        local rect = v:getCascadeBoundingBox()
        if k ~= #self.myCards then
            table.insert(self.cardPos, k, cc.rect(rect.x,rect.y,distance*SCALE_HAND,rect.height))
        else
            table.insert(self.cardPos, k, rect)
        end
        table.insert(self.selCards, k, 0)

        --排序后更新卡牌信息
        v:setTag(tonumber(cards[k]))
        local kind = math.floor(v:getTag()/ 0x10)
        local num = v:getTag() % 0x10
        local filename = "poker/kb_"..kind.."_"..num..".png"
        v:setTexture(filename)
    end

end

function ViewCardLayer:onEnter()

end

function ViewCardLayer:onExit()

end

function ViewCardLayer:eventBuChu()
    self:msgPassCard()
    self:cancelSelectCards()
    if self.tip then
        self.tip:hide()
    end
    return true

end

function ViewCardLayer:eventChongXuan()
    self:cancelSelectCards()
end

function ViewCardLayer:turnOver()

    self.tishiCards = nil
    self.hasAutoComplete = nil
end
--检测是否有压的牌
function ViewCardLayer:checkResult()
    local result = -1

    if self.lastOutCardUser == self.myChairID then
        -- Hall.showTips("上次出牌是自己！", 1.0)
        return
    end

    local myCards = {}
    for k,v in ipairs(self.myCards) do
        table.insert(myCards, v:getTag())
    end
    if self.lastOutCards then
        
        if not self.tishiCards then
            local cardtype = GameLogic.analysebCardData(self.lastOutCards)
            local a,b = GameLogic.tishi(myCards, self.lastOutCards)
            if a == true and #b > 0 then

            else
                result = 0
                self.tip:stopAllActions()
                self.tip:runAction(
                    cc.Sequence:create(
                        cc.CallFunc:create(function() self.tip:show() end) 
                    )
                )
            end
        end
    end
    return result
end
function ViewCardLayer:eventTiShi()

    if self.lastOutCardUser == self.myChairID then
        Hall.showTips("上次出牌是自己！", 1.0)
        return
    end

    local myCards = {}
    for k,v in ipairs(self.myCards) do
        table.insert(myCards, v:getTag())
    end

    if self.lastOutCards then
        
        if not self.tishiCards then
            local cardtype = GameLogic.analysebCardData(self.lastOutCards)
            local a,b = GameLogic.tishi(myCards, self.lastOutCards)
            if a == true and #b > 0 then
                self.tishiCards = b
                self.tishiMark = 0
            else
                self.tip:stopAllActions()
                self.tip:runAction(cc.Sequence:create(
                    cc.CallFunc:create(function() self.tip:show() end),
                    cc.DelayTime:create(2.0),
                    cc.CallFunc:create(function() self.tip:hide() end)))
                self:eventBuChu()
            end
        end

        if self.tishiCards then
            self.tishiMark = self.tishiMark + 1
            if self.tishiMark > #self.tishiCards then
                self.tishiMark = 1
            end

            self:cancelSelectCards()

            local tipCards = self.tishiCards[self.tishiMark]
            for key, var in ipairs(tipCards) do
                self.selCards[var] = 1
                local x,y = self.myCards[var]:getPosition();
                self.myCards[var]:setPosition(cc.p(x, y +20))
            end

        end
    end
end

function ViewCardLayer:eventChuPai()
    self.hasAutoComplete = nil
    self.tishiCards = nil
    print("ViewCardLayer:eventChuPai")
    --上次出牌是自己/第一次出牌
    if self.lastOutCardUser == self.myChairID or self.lastOutCards == nil then
  
        local cards = {}
        local handCards = {}
        for k,v in ipairs(self.selCards) do
            if v == 1 then
                table.insert(cards, self.myCards[k]:getTag())
            end
            table.insert(handCards, self.myCards[k]:getTag())
        end
        
        print("##########################")
        for k,v in ipairs(cards) do
            print("1111111111111打牌信息：",cardInfo[v])
        end
        print("##########################")

        local cardtype = GameLogic.analysebCardData(cards)
        if cardtype ~= CARDS_TYPE.CT_0 then
            print("牌型解析信息：", cardtype) 
            return self:playCards(cards);
        else
            Hall.showTips("牌型无效，无法出牌！", 1.0)
        end

    elseif self.lastOutCards and self.lastOutCardUser ~= self.myChairID then
        local cards = {}
        local handCards = {}
        for k,v in ipairs(self.selCards) do
            if v == 1 then
                table.insert(cards, self.myCards[k]:getTag())
            end
            table.insert(handCards, self.myCards[k]:getTag())
        end
        

        print("##########################")
        for k,v in ipairs(cards) do
            print("22222222222准备要打牌信息：",cardInfo[v])
        end
        print("##########################")

        if GameLogic.checkOutCards(self.lastOutCards, cards) then
            return self:playCards(cards);

        else
            print("##########################")
            Hall.showTips("选择牌型不满足要求，无法出牌！", 1.0)
        end

    end

    return false
end

function ViewCardLayer:eventSysChuPai()
    if self:isTuoGuan(self.myChairID) then
        print("托管状态下，不要自动出牌!")
        return
    end

   if #self.myCards <= 4 then
        local handCards = {}
        
        for k,v in ipairs(self.myCards) do
            table.insert(handCards, self.myCards[k]:getTag())
        end
        --上次出牌是自己/第一次出牌
        if self.lastOutCardUser == self.myChairID or self.lastOutCards == nil then
            
            local cardtype = GameLogic.analysebCardData(handCards)
            if cardtype == CARDS_TYPE.CT_1 or cardtype == CARDS_TYPE.CT_2 or cardtype == CARDS_TYPE.CT_3
                    or cardtype == CARDS_TYPE.CT_4 or cardtype == CARDS_TYPE.CT_5 then
                
                self:performWithDelay(function() self:playCards(handCards) end, 0.5)
                return true
            end

        elseif self.lastOutCards and self.lastOutCardUser ~= self.myChairID then
            
            if GameLogic.checkOutCards(self.lastOutCards, handCards) then
                self:performWithDelay(function() self:playCards(handCards) end, 0.5)
                return true
            end

        end
    end

end

function ViewCardLayer:msgPassCard()

    DoudizhuInfo:sendPassCards2()

end

function ViewCardLayer:msgOutCards(cards)

    DoudizhuInfo:sendOutCards2(cards)

end

--取消选择
function ViewCardLayer:cancelSelectCards()
    for k,v in ipairs(self.selCards) do
        if v == 1 then
            print("出牌信息 index：", k)
            self.selCards[k] = 0
            local x,y = self.myCards[k]:getPosition();
            self.myCards[k]:stopAllActions()
            self.myCards[k]:setPosition(cc.p(x, y -20))
        end
    end
end

function ViewCardLayer:showBuChuPai(msg)
    self.tishiCards = nil
    self.hasAutoComplete = nil
    local userInfo = DataManager:getUserInfoInMyTableByChairID(msg.wPassCardUser)
    if userInfo then
        SoundManager.playEffectByName("pass", userInfo.gender)
    end
    

    if msg.wPassCardUser == self.myChairID then
        --上次打出的牌清空
        for _,v in ipairs(self.cardOpen) do
            v:removeSelf();
        end
        self.cardOpen={}
    
    elseif msg.wPassCardUser == self.nextID then
         -- 清空
        self.outCardsNext:removeAllChildren()

    elseif msg.wPassCardUser == self.preID then
        -- self.outCardsPre:removeAllChildren()
    end
    
    --轮到自己出牌
    if msg.wCurrentUser == self.myChairID then
        self.isMyTurn = true
        --上次打出的牌清空
        for _,v in ipairs(self.cardOpen) do
            v:removeSelf();
        end
        self.cardOpen={}
    else
        self.isMyTurn = false
    end
end

function ViewCardLayer:showChuPai(msg)
    SoundManager.playSound("sound/outcard.mp3")

    --[[
    required int32                          cbCardCount         = 1;            //出牌数目
    required int32                          wCurrentUser        = 2;            //当前玩家
    required int32                          wOutCardUser        = 3;            //出牌玩家
    repeated int32                          cbCardData      = 4;            //扑克列表
    ]]
    local cardType = GameLogic.analysebCardData(msg.cbCardData)
    local card = msg.cbCardData[1]%0x10

    local userInfo = DataManager:getUserInfoInMyTableByChairID(msg.wOutCardUser)
    if userInfo then
        SoundManager.playSoundByType(cardType, card, userInfo.gender)
    end

    print("出牌数目" , msg.cbCardCount,"当前玩家",msg.wCurrentUser,"出牌玩家",msg.wOutCardUser,"出牌数目",#msg.cbCardData)
    self.lastOutCardUser = msg.wOutCardUser
    self.lastOutCards = msg.cbCardData

    if msg.wOutCardUser == self.myChairID then
        print("自己打牌，已经显示")
        self:drawMyOutCards(msg.cbCardData)
    
    elseif msg.wOutCardUser == self.nextID then
        print("下家打牌，" .. #msg.cbCardData .. "张！")

        self:drawNextOutCards(msg.cbCardData)

    elseif msg.wOutCardUser == self.preID then
        print("上家打牌，" .. #msg.cbCardData .. "张！")

        -- self:drawPreOutCards(msg.cbCardData)
    end
    --轮到自己出牌
    if msg.wCurrentUser == self.myChairID then
        self.isMyTurn = true
        --上次打出的牌清空
        for _,v in ipairs(self.cardOpen) do
            v:removeSelf();
        end
        self.cardOpen = {}
    else
        self.isMyTurn = false
    end
    if self.tip then
        self.tip:hide()
    end
end

function ViewCardLayer:showDiPai(msg)
    --[[
    required int32                          wBankerUser         = 1;            //庄家玩家
    required int32                          wCurrentUser        = 2;            //当前玩家
    required int32                          cbBankerScore       = 3;            //庄家叫分
    repeated int32                          cbBankerCard        = 4;            //庄家扑克
    ]]
    print("cbBankerCardType",msg.cbBankerCardType,"cbBankerCardTimes",msg.cbBankerCardTimes)
    --显示底牌
    self:drawDiPai()
    print("#self.data.dipai",#self.data.dipai)
    --更新手牌
    if self.myChairID == msg.wBankerUser then
        for k,v in ipairs(self.data.dipai) do
            table.insert(self.data.cards, v)
        end

        GameLogic.sortCards(self.data.cards)

        local orignalPos = cc.p(display.cx + self.posTable[self.myChairID].x, display.cy + self.posTable[self.myChairID].y)
        local destPos = cc.p(orignalPos.x, orignalPos.y);
        local total = #self.data.cards
        local mid = (1 + total)/2 --math.floor(total/2)+1
        local distance = (1136 - 100)/20

        for i=1, total, 1 do
            destPos.x = orignalPos.x - (mid-i)*distance*SCALE_HAND
            local card = self.sendCardLayer:getChildByTag(self.data.cards[i])
            if card then
                card:setLocalZOrder(i)
                card:setPosition(destPos)
                
                self.myCards[i] = card
            
            else
                local kind = math.floor( self.data.cards[i] / 0x10 )
                local num = self.data.cards[i] % 0x10
                local filename = "poker/kb_"..kind.."_"..num..".png";
                local card = display.newSprite(filename):align(display.CENTER, destPos.x, destPos.y+20)
                                                :addTo(self.sendCardLayer, i, 0x10*kind+num)
                                                :scale(SCALE_HAND)
                
                local sequence = transition.sequence(
                            {
                                cc.DelayTime:create(0.2),
                                cc.MoveTo:create(0.3, destPos),
                            }
                            )
                card:runAction(sequence)
                if self:isTuoGuan(self.myChairID) then
                    card:setColor(GreyColor);
                end
                
                table.insert(self.selCards, 0)
                self.myCards[i] = card

            end
        end
        --设置地主角标
        if self.data.isFarmer ~= true then
            local bankerlog = cc.Sprite:create("poker/banner_dizhu.png")
            self.myCards[total]:addChild(bankerlog,total+1,100)
            self.bankerlog = bankerlog
            -- dump(self.bankerlog, "self.bankerlog")
            bankerlog:setPosition(self.bankerlogPos)
            -- bankerlog:setScale(0.736)
        end
    elseif self.nextID == msg.wBankerUser then--更新数量
        self.nextCardsNum = 20--self.nextCardsNum + #msg.cbBankerCard
        self.cardNext:getChildByTag(1):setString(self.nextCardsNum)

    elseif self.preID == msg.wBankerUser then
        self.preCardsNum = 20--self.preCardsNum + #msg.cbBankerCard
        -- self.cardPre:getChildByTag(1):setString(self.preCardsNum)
        
    end

    self:performWithDelay(function() self:initCardPos(); end, 1.0)

end

function ViewCardLayer:updateCardPos(cards)
    local orignalPos = cc.p(display.cx + self.posTable[self.myChairID].x, display.cy + self.posTable[self.myChairID].y)
    local destPos = cc.p(orignalPos.x, orignalPos.y);
    -- if #cards < 17 then
    --     orignalPos.x = orignalPos.x - 60
    -- end
    local total = #cards
    local mid = (1+total)/2 --math.floor(total/2)+1
    local distance = nil
    if total > 17 then
        distance = (1136 - 100)/total
    else
        distance = (1136 - 100)/17
    end

    for k,v in ipairs(cards) do
        destPos.x = orignalPos.x - (mid-k)*distance*SCALE_HAND
        v:setPosition(destPos)
    end
    local rightCard = cards[#cards]

    if self.data.isFarmer == false and rightCard and rightCard:getChildByTag(100) == nil then
        local bankerlog = cc.Sprite:create("poker/banner_dizhu.png")
        rightCard:addChild(bankerlog,0,100)
        self.bankerlog = bankerlog
        -- local bb = getmetatable(self.bankerlog)
        -- dump(bb, "self.bankerlog")
        bankerlog:setPosition(self.bankerlogPos)

        -- self.bankerlog:setPosition(orignalPos.x - (mid-total)*distance*SCALE_HAND+20, orignalPos.y+20)
    end
    self:refreshMyCardPos();
    
end

function ViewCardLayer:recover(msg)
        --[[                                            
    //出牌信息                                          
    required int32                          wTurnWiner      = 10;           //胜利玩家
    required int32                          cbTurnCardCount     = 11;           //出牌数目
    repeated int32                          cbTurnCardData      = 12;           //出牌数据

    //扑克信息
    repeated int32                          cbBankerCard        = 13;           //游戏底牌
    repeated int32                          cbHandCardData      = 14;           //手上扑克
    repeated int32                          cbHandCardCount     = 15;           //扑克数目

]]
    if msg.cbHandCardCount then
        for k,v in ipairs(msg.cbHandCardCount) do
            if k == self.nextID then
                self.nextCardsNum = v
            elseif k == self.preID then
                self.preCardsNum = v
            end
        end
    end
    dump(msg.cbHandCardCount, "cbHandCardCount")
    print("ViewCardLayer:recover==", self.nextCardsNum, self.preCardsNum)
    -- self.myCards = msg.cbHandCardData
    local interval = 0.01;
    -- 手牌
    local newLayer = display.newLayer()
    self.sendCardLayer = newLayer
    self:addChild(newLayer,1);

    newLayer:setTouchEnabled(true)
    newLayer:setTouchSwallowEnabled(false)
    newLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    newLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)        
        self:onTouchHandler(event)
        return true--必须返回true，否则无法接受touch后面的消息
    end)

    local orignalPos = cc.p(display.cx + self.posTable[self.myChairID].x, display.cy + self.posTable[self.myChairID].y)
    local destPos = cc.p(orignalPos.x, orignalPos.y);
    local total = #self.data.cards
    local mid = (1+total)/2
    local distance = nil
    if total > 17 then
        distance = (1136-100)/total
    else
        distance = (1136-100)/17
    end
    for i=1, total, 1 do
        local kind = math.floor(self.data.cards[i] / 0x10 );--math.random(0,3);
        local num = self.data.cards[i] % 0x10;--math.random(1,13);

        if i >= mid then
            orignalPos.x = display.cx + self.posTable[self.myChairID].x + (i-mid)*distance*SCALE_HAND
        end
        destPos.x = orignalPos.x - (mid-i)*distance*SCALE_HAND

        local filename = "poker/kb_"..kind.."_"..num..".png";
        
        -- 牌型信息用tag值纪录
        local card = display.newSprite(filename):align(display.CENTER, orignalPos.x, orignalPos.y)
                                                :addTo(newLayer,0,0x10*kind+num)
                                                :hide()
                                                :scale(SCALE_HAND)
        

        local sequence = nil
        if i < mid then
          sequence = transition.sequence(
                            {
                                cc.DelayTime:create(interval*i),
                                cc.CallFunc:create(function() card:show(); end),
                                cc.MoveTo:create(math.abs(i-mid)*interval, destPos)
                            }
                            )
        else
            sequence = transition.sequence(
                {
                    cc.DelayTime:create(interval*i),
                    cc.CallFunc:create(function() card:show(); end),
                    --cc.MoveTo:create(dur, destPos)
                }
            )
        end
        card:runAction(sequence)

        table.insert(self.selCards, 0)
        table.insert(self.myCards, card);
    end

    if self.data.isFarmer ~= true then
        local bankerlog = cc.Sprite:create("poker/banner_dizhu.png")
        self.myCards[#self.myCards]:addChild(bankerlog,0,100)
        self.bankerlog = bankerlog
        bankerlog:setPosition(self.bankerlogPos)
        -- bankerlog:setScale(0.736)
    end

    -- 发下家牌    
    total = self.nextCardsNum
    orignalPos = cc.p(display.cx + self.posTable[self.nextID].x + 30, display.cy + self.posTable[self.nextID].y - 10)
    local nextCard = display.newSprite("card/kb_0_0.png"):align(display.CENTER, orignalPos.x, orignalPos.y)
                                            :addTo(newLayer)
                                            :scale(0.5)

    local text = ccui.Text:create(total,"",40)
    text:setTextColor(cc.c3b(255,255,255))
    text:enableOutline(cc.c3b(0,0,0), 2)
    text:align(display.CENTER,nextCard:getContentSize().width / 2,nextCard:getContentSize().height / 2)
    text:addTo(nextCard, 0, 1)
    self.nextCardsNum = total
    self.cardNext = nextCard

    -- 发上家牌
    -- if self.data.preCards then
    --     total = #self.data.preCards 
    -- else
    --     total = 17
    -- end
    -- orignalPos = cc.p(display.cx + self.posTable[self.preID].x, display.cy + self.posTable[self.preID].y - 20)
    -- local preCard = display.newSprite("card/kb_0_0.png"):align(display.CENTER, orignalPos.x, orignalPos.y)
    --                                         :addTo(newLayer)
    --                                         :scale(0.6)

    -- local text = ccui.Text:create(total,"",40)
    -- text:setTextColor(cc.c3b(255,255,255))
    -- text:enableOutline(cc.c3b(0,0,0), 2)
    -- text:align(display.CENTER,preCard:getContentSize().width / 2,preCard:getContentSize().height / 2)
    -- text:addTo(preCard, 0, 1)
    -- self.preCardsNum = total
    -- self.cardPre = preCard

    --底牌
    if self.data.dipai then
        self:drawDiPai()

        --底牌已亮
        self:performWithDelay(function() self:initCardPos(); end, 1.0)
    end

    --打出的牌
    self:recoverOutCards(msg)
    self:refreshRangPaiUIByIsFarmer(self.data.isFarmer)
end

function ViewCardLayer:recoverOutCards(msg)
    print("显示打出卡牌！",msg.cbTurnCardCount)

--[[
    //出牌信息                                          
    required int32                          wTurnWiner      = 10;           //胜利玩家
    required int32                          cbTurnCardCount     = 11;           //出牌数目
    repeated int32                          cbTurnCardData      = 12;           //出牌数据
    ]]
    if msg.wTurnWiner then

        self.lastOutCardUser = msg.wTurnWiner
        self.lastOutCards = msg.cbTurnCardData

        if msg.wTurnWiner == self.myChairID then
            self:drawMyOutCards(msg.cbTurnCardData, true)
        
        elseif msg.wTurnWiner == self.nextID then
            self:drawNextOutCards(msg.cbTurnCardData, true)

        elseif msg.wTurnWiner == self.preID then
            -- self:drawPreOutCards(msg.cbTurnCardData)
        end
    end
end

function ViewCardLayer:playEffectCT()

    local spring = EffectFactory:getInstance():getAnimationSpring()
    local action3 = cc.Sequence:create( 
                                -- cc.DelayTime:create(0.4),
                                -- cc.FadeIn:create(0.1),
                                cc.CallFunc:create(function() print("播放春天特效") end),
                                cc.Animate:create(spring),
                                cc.FadeOut:create(0.1)
                                )

    display.newSprite():addTo(self.effectLayer):align(display.CENTER, display.cx, display.cy + 60):runAction(action3)
end

function ViewCardLayer:playEffectPX(cardType, index)
    local x = display.cx + self.posTable[index].x
    local y = display.cy + self.posTable[index].y

    if index == self.myChairID then
        y = display.cy + 50
    
    elseif index == self.nextID then
        x = display.cx + self.posTable[self.nextID].x - 200
        y = display.cy + self.posTable[self.nextID].y + 80

    elseif index == self.preID then
        x = display.cx + self.posTable[self.preID].x + 200
        y = display.cy + self.posTable[self.preID].y + 80
    end

    local node = display.newNode():addTo(self.effectLayer)
    :align(display.CENTER, x, y)

    local aniPx = nil
    local cardTypeX = 20
    local cardTypeY = -20
    local action1 = nil

    if cardType == CARDS_TYPE.CT_1S then--顺子
        SoundManager.playSound("sound/straight.mp3")
        aniPx = EffectFactory:getInstance():getAnimationByName("shunzi")


    elseif cardType == CARDS_TYPE.CT_2S then--连对
        
        SoundManager.playSound("sound/straight.mp3")
        aniPx = EffectFactory:getInstance():getAnimationByName("liandui")
    elseif cardType == CARDS_TYPE.CT_3S3 then--飞机
        
        SoundManager.playSound("sound/straight.mp3")
        aniPx = EffectFactory:getInstance():getAnimationByName("airplane")


    elseif cardType == CARDS_TYPE.CT_3S4 then--翅膀
        
        SoundManager.playSound("sound/straight.mp3")
        aniPx = EffectFactory:getInstance():getAnimationByName("wing")

    elseif cardType == CARDS_TYPE.CT_4 then--炸弹
        
        aniPx = EffectFactory:getInstance():getAnimationByName("bomb")
        cardTypeX = display.cx - node:getPositionX()
        cardTypeY = display.cy - node:getPositionY()

        EffectFactory:getInstance():shakeScreen(1)

    elseif cardType == CARDS_TYPE.CT_5 then--王炸
        
        aniPx = EffectFactory:getInstance():getAnimationByName("rocket")
        cardTypeX = display.cx - node:getPositionX()
        cardTypeY = display.cy - node:getPositionY()

        EffectFactory:getInstance():shakeScreen(1)
        cc.Native:vibrate()  
    else
        return
    end

    --播放牌型特效
    local sprPX = display.newSprite():addTo(node,1):align(display.CENTER, cardTypeX, cardTypeY)
    local action1 = nil
    if cardType == CARDS_TYPE.CT_3S3 then
        
        if display.cx + self.posTable[index].x < display.cx then
        
            sprPX:setScaleX(-1)
            action1 = cc.Sequence:create(cc.FadeIn:create(0.1),
                                            cc.Animate:create(aniPx),
                                            cc.MoveBy:create(0.3, cc.p(1000, 0)),
                                            cc.FadeOut:create(0.1)
                                            )

        else

            action1 = cc.Sequence:create(cc.FadeIn:create(0.1),
                                            cc.Animate:create(aniPx),
                                            cc.MoveBy:create(0.3, cc.p(-1000, 0)),
                                            cc.FadeOut:create(0.1)
                                            )
        end
    else
        action1 = cc.Sequence:create(cc.FadeIn:create(0.1),
                                        cc.Animate:create(aniPx),
                                        cc.FadeOut:create(0.1)
                                        )
    end
    
    sprPX:runAction(action1)

    self:performWithDelay(function() node:removeSelf() end, 3.5)

end

function ViewCardLayer:isTuoGuan(chairID)
    -- if self.data.isTuoGuan == nil then
    --     return false
    -- end
    local bTuoGuan = self.data.isTuoGuan
    return bTuoGuan and bTuoGuan[chairID] == 1 
end

function ViewCardLayer:tuoGuan()
    local color
    if self:isTuoGuan(self.myChairID) then
        --扑克牌灰掉
        color = GreyColor
    else
        color = display.COLOR_WHITE
    end

    for k,v in ipairs(self.myCards) do
        self.myCards[k]:setColor(color);
    end
end

return ViewCardLayer