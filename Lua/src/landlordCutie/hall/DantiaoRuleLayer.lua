local DantiaoRuleLayer = class("DantiaoRuleLayer",function() return display.newLayer() end)

function DantiaoRuleLayer:ctor()
	self:createUI()
end
function DantiaoRuleLayer:createUI()
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

    --窗体
    local bgSize = cc.size(675, 434)
    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(bgSize);
    bgSprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    bgSprite:addTo(maskLayer)
    
    --标题
    local titleSprite = cc.Sprite:create("common/pop_title.png");
    titleSprite:setPosition(cc.p(145, 400));
    bgSprite:addChild(titleSprite);

    local title = ccui.Text:create("规则", FONT_ART_TEXT, 35)
    title:setPosition(cc.p(66,68))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    --bg
    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(580,300));
    panel:setPosition(338,210)
    bgSprite:addChild(panel)


    local listView = ccui.ListView:create()
    -- set list view ex direction
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(580, 280))
    listView:setPosition(15,10)
    panel:addChild(listView)
    

    local infoArray = {
        "*牌数：",
        "整副牌只有46张牌，牌库没有3和4，每人首发17张牌，废牌有9张，底牌有3张；",
        "*叫牌规则：",
        "拿到“明牌”的叫牌，明牌即是牌上有一个标识绿点的牌",
        "*出牌规则： ",
        "出牌规则同标准斗地主规则一致；",
        "*翻倍规则：",
        "本玩法一局定天下，根据不同房间的准入要求，每局的输赢是固定金币数，不计底分和倍数。",
        "*输赢： ",
        "初级场固定输赢10万金币，中级场固定输赢100万金币，高级场固定输赢1000万金币，豪华场固定输赢1亿金币。"}

    local custom_itemY = 400
    local custom_itemX = 580
    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
    custom_item:setAnchorPoint(cc.p(0,1))
    custom_item:setPosition(300, 100)

    local intervalI = {0,1,2,1,1,1,1,1,2,1}

    local length = #infoArray
    for i=1,length do 
        local height = 0
        for j=1,i do
            height = height + intervalI[j]
        end

        infoText = ccui.Text:create("","",20)
        infoText:setPosition(0, custom_itemY-height*30)
        infoText:setAnchorPoint(cc.p(0,1))
        infoText:setColor(cc.c3b(249,247,123))
        infoText:setString(infoArray[i])
        infoText:setTextAreaSize(cc.size(580,400))
        infoText:ignoreContentAdaptWithSize(false)
        infoText:setTextHorizontalAlignment(0)
        infoText:setTextVerticalAlignment(0)
        custom_item:addChild(infoText)
    end
    listView:pushBackCustomItem(custom_item)

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(640,406));
    exit:addTo(bgSprite);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeSelf()
            end
        end
    )

end
return DantiaoRuleLayer