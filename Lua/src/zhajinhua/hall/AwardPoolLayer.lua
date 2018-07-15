local AwardPoolLayer = class("AwardPoolLayer",function() return display.newLayer() end)

local EffectFactory = require("commonView.EffectFactory")

local cardInfo = {
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",
}

function AwardPoolLayer:ctor(mode)

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)

    self.mode = mode
    if self.mode == 3 then
        self:popInfoLayer()
    else
       self:createUI()
    end
    self.canTouZhu = true

end

function AwardPoolLayer:onEnter()
    -- print("AwardPoolLayer:onEnter")
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(LotteryInfo, "record", handler(self, self.refreshRecord))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(LotteryInfo, "cbCardValue", handler(self, self.refreshCbCardValue))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(LotteryInfo, "poolScore", handler(self, self.refreshPoolScore))
end

function AwardPoolLayer:onExit()
    -- print("AwardPoolLayer:onExit")
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function AwardPoolLayer:refreshRecord()
    self.awardOne = {}
    self.awardTwo = {}
    self.awardThree = {}
    for i,v in ipairs(LotteryInfo.record) do
        print(i,v.awardType,v.cbCardValue,v.score,v.nickName)
        if v.awardType == 1 then
            table.insert(self.awardOne,v.nickName)
        end
        if v.awardType == 2 then
            table.insert(self.awardTwo,v.nickName)
        end
        if v.awardType == 3 then
            table.insert(self.awardThree,v.nickName)
        end
    end
    if self.awardOne[1] then
        self.name1:setString(FormotGameNickName(self.awardOne[1],9))
    end
    if self.awardOne[2] then
        self.name2:setString(FormotGameNickName(self.awardOne[2],9))
    end
    if self.awardTwo[1] then
        self.name3:setString(FormotGameNickName(self.awardTwo[1],9))
    end
    if self.awardTwo[2] then
        self.name4:setString(FormotGameNickName(self.awardTwo[2],9))
    end
    if self.awardThree[1] then
        self.name5:setString(FormotGameNickName(self.awardThree[1],9))
    end
    if self.awardThree[2] then
        self.name6:setString(FormotGameNickName(self.awardThree[2],9))
    end
end

function AwardPoolLayer:refreshCbCardValue()
    self.canTouZhu = true
    self:popAwardLayer()
end

function AwardPoolLayer:refreshPoolScore()
    if self.num_node then
        self:refreshNumString(32,36,LotteryInfo.poolScore,self.num_node,132+12)
    end
    if self.node then
        self:refreshNumString(40,62,LotteryInfo.poolScore,self.node,248)
    end
end

function AwardPoolLayer:createUI()

    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(cc.size(winSize.width,winSize.height))

    local addHeight = 20
    local addWidth = 0

    if self.mode == 1 then
        addHeight = 100
        addWidth = winSize.height/2
    end

    --奖池
    local poolBtn = ccui.Button:create("awardPool/pool_bg.png","awardPool/pool_bg.png")
    poolBtn:setAnchorPoint(cc.p(1,1))
    poolBtn:setPosition(cc.p(winSize.width-addWidth, winSize.height-addHeight))
    poolBtn:onClick( function() self:popInfoLayer() end )
    self:addChild(poolBtn)

    local animation = EffectFactory:getInstance():getPaoMaDengXiaoAni()
    animation:setPosition(poolBtn:getContentSize().width/2,poolBtn:getContentSize().height/2)
    poolBtn:addChild(animation)

    --问号图标提示
    local tipBtn = ccui.Button:create("awardPool/tip_button.png","awardPool/tip_button.png")
    tipBtn:setAnchorPoint(cc.p(1,1))
    tipBtn:setPosition(cc.p(winSize.width-poolBtn:getContentSize().width-6-addWidth, winSize.height-addHeight-10))
    tipBtn:onClick( function() self:popInfoLayer() end )
    self:addChild(tipBtn)

    self.num_node = display.newNode()
    self.num_node:setContentSize(cc.size(poolBtn:getContentSize().width, poolBtn:getContentSize().height));
    self.num_node:setPosition(cc.p(poolBtn:getContentSize().width/2, poolBtn:getContentSize().height/2))
    poolBtn:addChild(self.num_node)

    -- print("测试奖池：",LotteryInfo.poolScore,poolBtn:getContentSize().width/2)
    self:refreshNumString(32,36,LotteryInfo.poolScore,self.num_node,132+12)

    local touBtn = ccui.Button:create("awardPool/tou_zhu_btn.png","awardPool/tou_zhu_btn.png")
    touBtn:setAnchorPoint(cc.p(1,1))
    touBtn:setPosition(cc.p(winSize.width-addWidth, winSize.height-addHeight-poolBtn:getContentSize().height-10))
    touBtn:setPressedActionEnabled(true)
    touBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- self:popAwardLayer()
                if AccountInfo.score < 10000 then
                    Hall.showTips("抱歉，金币不足！")
                else
                    if self.canTouZhu then
                        self.canTouZhu = false
                        LotteryInfo:sendAddLotteryScoreRequest()
                    end
                end
            end
        end
    )
    self:addChild(touBtn)

end

function AwardPoolLayer:popInfoLayer()

    local addHeight = 0
    
    local winSize = cc.Director:getInstance():getWinSize()

    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(cc.size(winSize.width,winSize.height));
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)    

    local bankConainer = ccui.ImageView:create("awardPool/pool_info_bg.png");
    bankConainer:setPosition(cc.p(winSize.width/2, winSize.height/2-addHeight));
    maskLayer:addChild(bankConainer);

    local exit = ccui.Button:create("common/close1.png");
    exit:setPosition(cc.p(winSize.width/2+300, winSize.height/2+200-addHeight));
    maskLayer:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self.node = nil
                if self.mode == 3 then
                    self:removeFromParent()
                else
                    maskLayer:removeFromParent()    
                end
            end
        end
    )

    local touzhu = ccui.Button:create("awardPool/big_tou_zhu_btn.png");
    touzhu:setPosition(cc.p(winSize.width/2, winSize.height/2-260-addHeight));
    maskLayer:addChild(touzhu);
    touzhu:setPressedActionEnabled(true);
    touzhu:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.canTouZhu then
                    self.canTouZhu = false
                    LotteryInfo:sendAddLotteryScoreRequest()
                end
            end
        end
    )

    local title = cc.Sprite:create("common/ty_title_bg.png");
    title:setPosition(cc.p(winSize.width/2, winSize.height/2+230-addHeight));
    maskLayer:addChild(title);

    local title = cc.Sprite:create("awardPool/pool_title.png");
    title:setPosition(cc.p(winSize.width/2, winSize.height/2+240-addHeight));
    maskLayer:addChild(title);

    local numBg = cc.Sprite:create("awardPool/num_bg.png")
    numBg:setPosition(cc.p(bankConainer:getContentSize().width/2, bankConainer:getContentSize().height/2+130));
    bankConainer:addChild(numBg);

    local animation = EffectFactory:getInstance():getPaoMaDeng()
    animation:setPosition(318,215)
    bankConainer:addChild(animation)

    self.node = display.newNode()
    self.node:setContentSize(cc.size(numBg:getContentSize().width, numBg:getContentSize().height));
    self.node:setPosition(cc.p(numBg:getContentSize().width/2, numBg:getContentSize().height/2))
    numBg:addChild(self.node)

    self:refreshNumString(40,62,LotteryInfo.poolScore,self.node,248)

    local infoSprite = cc.Sprite:create("awardPool/pool_info.png")
    infoSprite:setPosition(cc.p(bankConainer:getContentSize().width/2, bankConainer:getContentSize().height/2-60));
    bankConainer:addChild(infoSprite);

    --获奖名单bg
    local scroll_bg = cc.Sprite:create("awardPool/award_scroll_bg.png")
    scroll_bg:setPosition(cc.p(infoSprite:getContentSize().width/2+8-184, infoSprite:getContentSize().height/2+16));
    infoSprite:addChild(scroll_bg);

    self.name1 = ccui.Text:create()
    self.name1:setString("暂无")
    self.name1:setColor(cc.c4b(255,255,255,255))
    self.name1:enableOutline(cc.c4b(0,0,0,255), 1)
    self.name1:setFontSize(18)
    self.name1:setPosition(cc.p(scroll_bg:getContentSize().width/2, scroll_bg:getContentSize().height/2))
    scroll_bg:addChild(self.name1)

    local scroll_bg = cc.Sprite:create("awardPool/award_scroll_bg.png")
    scroll_bg:setPosition(cc.p(infoSprite:getContentSize().width/2+8-184, infoSprite:getContentSize().height/2-16));
    infoSprite:addChild(scroll_bg);

    self.name2 = ccui.Text:create()
    self.name2:setString("暂无")
    self.name2:setColor(cc.c4b(255,255,255,255))
    self.name2:enableOutline(cc.c4b(0,0,0,255), 1)
    self.name2:setFontSize(18)
    self.name2:setPosition(cc.p(scroll_bg:getContentSize().width/2, scroll_bg:getContentSize().height/2))
    scroll_bg:addChild(self.name2)

    local scroll_bg = cc.Sprite:create("awardPool/award_scroll_bg.png")
    scroll_bg:setPosition(cc.p(infoSprite:getContentSize().width/2+8, infoSprite:getContentSize().height/2+16));
    infoSprite:addChild(scroll_bg);

    self.name3 = ccui.Text:create()
    self.name3:setString("暂无")
    self.name3:setColor(cc.c4b(255,255,255,255))
    self.name3:enableOutline(cc.c4b(0,0,0,255), 1)
    self.name3:setFontSize(18)
    self.name3:setPosition(cc.p(scroll_bg:getContentSize().width/2, scroll_bg:getContentSize().height/2))
    scroll_bg:addChild(self.name3)

    local scroll_bg = cc.Sprite:create("awardPool/award_scroll_bg.png")
    scroll_bg:setPosition(cc.p(infoSprite:getContentSize().width/2+8, infoSprite:getContentSize().height/2-16));
    infoSprite:addChild(scroll_bg);

    self.name4 = ccui.Text:create()
    self.name4:setString("暂无")
    self.name4:setColor(cc.c4b(255,255,255,255))
    self.name4:enableOutline(cc.c4b(0,0,0,255), 1)
    self.name4:setFontSize(18)
    self.name4:setPosition(cc.p(scroll_bg:getContentSize().width/2, scroll_bg:getContentSize().height/2))
    scroll_bg:addChild(self.name4)

    local scroll_bg = cc.Sprite:create("awardPool/award_scroll_bg.png")
    scroll_bg:setPosition(cc.p(infoSprite:getContentSize().width/2+8+184, infoSprite:getContentSize().height/2+16));
    infoSprite:addChild(scroll_bg);

    self.name5 = ccui.Text:create()
    self.name5:setString("暂无")
    self.name5:setColor(cc.c4b(255,255,255,255))
    self.name5:enableOutline(cc.c4b(0,0,0,255), 1)
    self.name5:setFontSize(18)
    self.name5:setPosition(cc.p(scroll_bg:getContentSize().width/2, scroll_bg:getContentSize().height/2))
    scroll_bg:addChild(self.name5)

    local scroll_bg = cc.Sprite:create("awardPool/award_scroll_bg.png")
    scroll_bg:setPosition(cc.p(infoSprite:getContentSize().width/2+8+184, infoSprite:getContentSize().height/2-16));
    infoSprite:addChild(scroll_bg);

    self.name6 = ccui.Text:create()
    self.name6:setString("暂无")
    self.name6:setColor(cc.c4b(255,255,255,255))
    self.name6:enableOutline(cc.c4b(0,0,0,255), 1)
    self.name6:setFontSize(18)
    self.name6:setPosition(cc.p(scroll_bg:getContentSize().width/2, scroll_bg:getContentSize().height/2))
    scroll_bg:addChild(self.name6)

    --请求中奖信息
    LotteryInfo:sendLotteryAwardRequest()
end

function AwardPoolLayer:popAwardLayer()

    local addHeight = -10
    
    local winSize = cc.Director:getInstance():getWinSize()

    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(cc.size(winSize.width,winSize.height));
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                maskLayer:removeFromParent();
            end
        end
    )    

    local bankConainer = ccui.ImageView:create("awardPool/award_bg.png");
    bankConainer:setPosition(cc.p(winSize.width/2, winSize.height/2-addHeight));
    maskLayer:addChild(bankConainer);

    -- local exit = ccui.Button:create("common/close1.png");
    -- exit:setPosition(cc.p(winSize.width/2+180, winSize.height/2+120-addHeight));
    -- maskLayer:addChild(exit);
    -- exit:setPressedActionEnabled(true);
    -- exit:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             maskLayer:removeFromParent();
    --         end
    --     end
    -- )

    local title = cc.Sprite:create("common/ty_title_bg_small.png");
    title:setPosition(cc.p(winSize.width/2, winSize.height/2+126-addHeight));
    maskLayer:addChild(title);

    local title = cc.Sprite:create("awardPool/award_title.png");
    title:setPosition(cc.p(winSize.width/2, winSize.height/2+134-addHeight));
    maskLayer:addChild(title);

    local infoSprite = cc.Sprite:create("common/ty_mask.png")
    infoSprite:setPosition(cc.p(bankConainer:getContentSize().width/2, bankConainer:getContentSize().height/2));
    bankConainer:addChild(infoSprite);

    --三张牌
    -- for i,v in ipairs(LotteryInfo.cbCardValue) do
    --     print(i,v)
    -- end
    -- local cardArray = {49,49,49}
    local cardArray = {LotteryInfo.cbCardValue[1],LotteryInfo.cbCardValue[2],LotteryInfo.cbCardValue[3]}
    local function getCardValue(cbCardData)
        local LOGIC_MASK_VALUE = 0x0F
        return bit.band(cbCardData,LOGIC_MASK_VALUE)
    end
    table.sort(cardArray, function(x,y) return getCardValue(x) < getCardValue(y) end )
    -- dump(cardArray, "cardArray")
    for i=1,3 do
        local kind = math.floor(cardArray[i] / 0x10 )
        local num = cardArray[i] % 0x10
        local filename = "card/kb_"..kind.."_"..num..".png";

        local cardSprite = cc.Sprite:create(filename)
        cardSprite:setPosition(cc.p(56+i*50, infoSprite:getContentSize().height/2));
        infoSprite:addChild(cardSprite);
    end

    local animation = EffectFactory:getInstance():getChangeCell1()
    animation:setPosition(bankConainer:getContentSize().width/2, bankConainer:getContentSize().height/2)
    bankConainer:addChild(animation)

    -- local AWARD_TYPE = {
    --     AD_BLACK_AAA = 1,                   --黑桃AAA豹子
    --     AD_JINHUA_BAOZI = 2,                --同色豹子
    --     AD_JINHUA_QKA = 3,                  --同色QKA
    --     AD_SHUNJIN = 4,                     --顺金类型
    --     AD_BAOZI = 5,                       --豹子类型
    --     AD_JINHUA = 6,                      --金花类型
    --     AD_SHUNZI = 7,                      --顺子类型
    -- }

    --开奖类型
    local award_type = LotteryInfo.awardType
    if award_type ~= 8 then
        --筹码
        local EffectFactory = require("commonView.EffectFactory")
        local animation2 = EffectFactory:getInstance():getChouMaAnimation()
        animation2:setPosition(bankConainer:getContentSize().width/2, bankConainer:getContentSize().height)
        bankConainer:addChild(animation2)
    end

    local filename = "type_black_AAA.png"
    local tipText = "投注成功！恭喜您获得2万筹码！"
    if award_type == 1 then
        filename = "type_black_AAA.png"
        tipText = "投注成功！恭喜您获得"..FormatNumToString(LotteryInfo.awardValue).."筹码！"
    elseif award_type == 2 then
        filename = "type_th_baozi.png"
        tipText = "投注成功！恭喜您获得200万筹码！"
    elseif award_type == 3 then
        filename = "type_qka.png"
        tipText = "投注成功！恭喜您获得50万筹码！"
    elseif award_type == 4 then
        filename = "type_ths.png"
        tipText = "投注成功！恭喜您获得20万筹码！"
    elseif award_type == 5 then
        filename = "type_bao_zi.png"
        tipText = "投注成功！恭喜您获得10万筹码！"
    elseif award_type == 6 then
        filename = "type_tong_hua.png"
        tipText = "投注成功！恭喜您获得5万筹码！"
    elseif award_type == 7 then
        filename = "type_shunzi.png"
        tipText = "投注成功！恭喜您获得2万筹码！"
    elseif award_type == 8 then
        tipText = "投注成功！未中奖，祝您下次好运！"
    end

    local infoSprite = cc.Sprite:create("awardPool/"..filename)
    infoSprite:setPosition(cc.p(bankConainer:getContentSize().width/2, -60));
    bankConainer:addChild(infoSprite);

    local congratulationTip = cc.Sprite:create("awardPool/congratulation_tip.png")
    congratulationTip:setPosition(cc.p(bankConainer:getContentSize().width/2, 60));
    bankConainer:addChild(congratulationTip);    

    if award_type == 8 then
        infoSprite:setVisible(false)
        congratulationTip:setVisible(false)
    else
        if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
            audio.playSound("sound/coins.mp3");
        end
    end

    local textInfo = ccui.Text:create()
    textInfo:setString(tipText)
    textInfo:setColor(cc.c4b(255,255,255,255))
    textInfo:enableOutline(cc.c4b(141,0,166,255), 1)
    textInfo:setFontSize(28)
    textInfo:setPosition(cc.p(bankConainer:getContentSize().width/2, -100))
    bankConainer:addChild(textInfo)    

end

function AwardPoolLayer:refreshNumString(fontSize,distance,num,node,startX)

    -- num = 199990000

    node:removeAllChildren()

    local nums = {}

    if num < 10000000 then
        while num >= 10 do
            local temp = num % 10
            num = math.floor(num/10)
            table.insert(nums, temp)
        end
        table.insert(nums, num)

        for i=1,#nums do
            local textInfo = ccui.Text:create()
            textInfo:setString(""..nums[i])
            textInfo:setColor(cc.c4b(0,0,0,255))
            textInfo:enableOutline(cc.c4b(255,255,255,255), 0.5)
            textInfo:setFontSize(fontSize)
            textInfo:setPosition(cc.p(startX-i*distance, 0))
            node:addChild(textInfo)
        end
    else
        if num < 100000000 then
            num = math.floor(num / 1000)
            table.insert(nums, "万")
            local temp = num % 10
            table.insert(nums, temp)
            table.insert(nums, ".")
            num = math.floor(num / 10)

            while num >= 10 do
                local temp = num % 10
                num = math.floor(num/10)
                table.insert(nums, temp)
            end
            table.insert(nums, num)

            for i=1,#nums do
                local textInfo = ccui.Text:create()
                textInfo:setString(""..nums[i])
                textInfo:setColor(cc.c4b(0,0,0,255))
                textInfo:enableOutline(cc.c4b(255,255,255,255), 0.5)
                textInfo:setFontSize(fontSize)
                textInfo:setPosition(cc.p(startX-i*distance, 0))
                node:addChild(textInfo)
            end
        else
            local delNum = 0
            local value = num
            value = math.floor(value / 100000000)
            if value >= 10 then
                delNum = 1
            end
            if value >= 100 then
                delNum = 2
            end
            if value >= 1000 then
                delNum = 3
            end
            if value >= 10000 then
                delNum = 5
            end

            num = math.floor(num / 10000)
            table.insert(nums, "亿")

            while num >= 10 do
                local temp = num % 10
                num = math.floor(num/10)
                table.insert(nums, temp)
                if #nums == 5 then
                    table.insert(nums, ".")
                end
            end
            table.insert(nums, num)

            while delNum >= 1 do
                delNum = delNum - 1
                table.remove(nums,2)
            end

            -- dump(nums, "nums")

            for i=1,#nums do
                local textInfo = ccui.Text:create()
                textInfo:setString(""..nums[i])
                textInfo:setColor(cc.c4b(0,0,0,255))
                textInfo:enableOutline(cc.c4b(255,255,255,255), 0.5)
                textInfo:setFontSize(fontSize)
                textInfo:setPosition(cc.p(startX-i*distance, 0))
                node:addChild(textInfo)
            end
        end
    end

end

function AwardPoolLayer:getSpecString(num)

end

return AwardPoolLayer