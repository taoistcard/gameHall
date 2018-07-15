
local selectPaoLayer = class("selectPaoLayer", function() return display.newLayer(); end );

function selectPaoLayer:ctor(parent)
    self.parent = parent
    --test
    -- self.parent.userInfo.memberOrder = 3
    self:setContentSize(cc.size(300, 340))
	self.index = self.parent.userInfo.memberOrder + 2
	self:createUI()
end

function selectPaoLayer:createUI()

    local winSize = self:getContentSize()

    -- local bgSprite = ccui.Button:create("btn_green.png");
    local bgSprite = ccui.Button:create("blank.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(300, 340));
    bgSprite:setPosition(cc.p(winSize.width/2, winSize.height/2));
    bgSprite:setTouchEnabled(true);
    bgSprite:addTouchEventListener(
        function (sender,eventType)
            if eventType == ccui.TouchEventType.began then
                self.touchBeginPos = sender:getTouchBeganPosition()
            elseif eventType == ccui.TouchEventType.ended then
                self.touchEndPos = sender:getTouchEndPosition()
                self:onSliderTable()
            end
        end
    )
    self:addChild(bgSprite);

    local leftArrow = ccui.Button:create("game/arrow.png","game/arrow.png");
    leftArrow:setPosition(cc.p(winSize.width/2-150, winSize.height/2))
    leftArrow:setPressedActionEnabled(true)
    leftArrow:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:leftArrowClickHandler(sender);
            end
        end
    )
    self:addChild(leftArrow)
    self.leftArrow = leftArrow
    self.leftArrow:setHighlighted(true)

    local rightArrow = ccui.Button:create("game/arrow.png","game/arrow.png");
    rightArrow:setPosition(cc.p(winSize.width/2+150, winSize.height/2))
    rightArrow:setPressedActionEnabled(true)
    rightArrow:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:rightArrowClickHandler(sender);
            end
        end
    )
    rightArrow:setScaleX(-1)
    self:addChild(rightArrow)
    self.rightArrow = rightArrow

    local vipBg = ccui.ImageView:create("game/game_pop_bg.png")
    vipBg:setPosition(winSize.width/2, winSize.height/2)--423, 386
    self:addChild(vipBg)

    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
    local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao1-l1.png")
    local vipItem = cc.Sprite:createWithSpriteFrame(pFrame)
    vipItem:setPosition(vipBg:getContentSize().width/2-4, vipBg:getContentSize().height/2+30)
    vipBg:addChild(vipItem)
    self.vipItem = vipItem

    --解锁按钮
    local btn = ccui.Button:create("game/game_btn.png");
    btn:setAnchorPoint(cc.p(0.5,0.5));
    btn:setPosition(cc.p(winSize.width/2, 80));
    btn:onClick(
        function()
            local newLayer = require("popView.getCoinLayer").new(self.index-1)
            display.getRunningScene():addChild(newLayer)
        end
    );
    self:addChild(btn);
    self.lock_btn = btn;

    local btnWord = display.newSprite("game/game_unlock_word.png")
    btnWord:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
    btn:addChild(btnWord)

    --使用按钮
    local use_btn = ccui.Button:create("game/game_btn_use.png");
    use_btn:setAnchorPoint(cc.p(0.5,0.5));
    use_btn:setPosition(cc.p(winSize.width/2, 80));
    use_btn:onClick(
        function()
            --使用炮台
            self.parent.cannon:setPaoOption(self.index)
        end
    );
    self:addChild(use_btn);
    self.use_btn = use_btn;

    local btnWord = display.newSprite("game/game_use_word.png")
    btnWord:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
    use_btn:addChild(btnWord)    

    self.lockSprite = display.newSprite("game/game_lock.png")
    self.lockSprite:setAnchorPoint(cc.p(0.5,0.5))
    self.lockSprite:setPosition(winSize.width/2, winSize.height/2+40)
    self:addChild(self.lockSprite)
    
    self:refreshUI()
end

function selectPaoLayer:leftArrowClickHandler()
	self.index = self.index - 1
	if self.index < self.parent.userInfo.memberOrder + 2 then
		self.index = 6
	end
	self:refreshUI()
end

function selectPaoLayer:rightArrowClickHandler()
	self.index = self.index + 1
	if self.index > 6 then
		self.index = self.parent.userInfo.memberOrder + 2
	end
	self:refreshUI()
end

function selectPaoLayer:refreshUI()

    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
    local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.index.."-l1.png")
    self.vipItem:setSpriteFrame(pFrame)

    if (self.parent.userInfo.memberOrder+1) >= self.index then
        self.lock_btn:hide()
        self.use_btn:show()
        self.lockSprite:hide()
    else
        self.lock_btn:show()
        self.use_btn:hide()
        self.lockSprite:show()
    end

end

function selectPaoLayer:onSliderTable()
    
    local dis = self.touchEndPos.x - self.touchBeginPos.x
    if dis > 10 then
        self:rightArrowClickHandler()
    elseif dis < -10 then
        self:leftArrowClickHandler()
    end
    self.touchEndPos = nil
    self.touchBeginPos = nil
end

return selectPaoLayer