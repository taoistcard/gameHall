
local VipInfoLayer = class("VipInfoLayer", require("show.popView_Hall.baseWindow") );

VipInfoLayer.tipsData = {
    "1.可领取每日VIP工资2500金币\n2.每天可领取破产补助金3次\n3.保险箱存筹码手续费低至4%\n4.子弹加速",
    "1.可领取每日VIP工资5000金币\n2.每天可领取破产补助金3次\n3.保险箱存筹码手续费低至3%\n4.解锁子弹无限反弹功能",
    "1.可领取每日VIP工资1万金币\n2.每天可领取破产补助金3次\n3.保险箱存筹码手续费低至2%\n4.解除急速射击CD限制",
    "1.可领取每日VIP工资3万金币\n2.每天可领取破产补助金3次\n3.保险箱存筹码手续费低至1%\n4.解锁子弹追踪功能",
    "1.可领取每日VIP工资5万金币\n2.每天可领取破产补助金3次\n3.保险箱存筹码无手续费\n4.开启锁定减速功能"
}
VipInfoLayer.pointArray = {}

function VipInfoLayer:ctor()
    self.super.ctor(self, 5);
	self.index = 1
	self:createUI()
end

function VipInfoLayer:createUI()

    local winSize = cc.Director:getInstance():getWinSize();

    local title = display.newSprite("shop/vipInfo/vip_title.png", winSize.width/2, winSize.height/2+210);
    title:setScale(1.2)
    self:addChild(title);

    -- local bgSprite = ccui.Button:create("btn_green.png");
    local bgSprite = ccui.Button:create("blank.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(640, 340));
    bgSprite:setPosition(cc.p(winSize.width/2, winSize.height/2-30));
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

    -- local leftArrow = ccui.Button:create("shop/vipInfo/arrow.png","shop/vipInfo/arrow.png");
    -- leftArrow:setPosition(cc.p(winSize.width/2-300, winSize.height/2))
    -- leftArrow:setPressedActionEnabled(true)
    -- leftArrow:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:leftArrowClickHandler(sender);
    --         end
    --     end
    -- )
    -- self:addChild(leftArrow)
    -- self.leftArrow = leftArrow
    -- self.leftArrow:setHighlighted(true)

    -- local rightArrow = ccui.Button:create("shop/vipInfo/arrow.png","shop/vipInfo/arrow.png");
    -- rightArrow:setPosition(cc.p(winSize.width/2+300, winSize.height/2))
    -- rightArrow:setPressedActionEnabled(true)
    -- rightArrow:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:rightArrowClickHandler(sender);
    --         end
    --     end
    -- )
    -- rightArrow:setScaleX(-1)
    -- self:addChild(rightArrow)
    -- self.rightArrow = rightArrow

    local vipBg = ccui.ImageView:create("shop/vipInfo/vipBg.png")
    vipBg:setPosition(winSize.width/2-140, winSize.height/2+10)--423, 386
    self:addChild(vipBg)

    local vipItem = ccui.ImageView:create("shop/vipInfo/vip1.png")
    vipItem:setPosition(vipBg:getContentSize().width/2, vipBg:getContentSize().height/2)
    vipBg:addChild(vipItem)
    self.vipItem = vipItem

    local vipTxt = ccui.Text:create()
    vipTxt:setPosition(winSize.width/2-20, winSize.height/2+74)
    vipTxt:setAnchorPoint(cc.p(0,1))
    vipTxt:setFontSize(21)
    vipTxt:setColor(cc.c3b(255,255,255))
    vipTxt:enableOutline(cc.c4b(0,48,98,255),2)
    self:addChild(vipTxt)
    vipTxt:setString(VipInfoLayer.tipsData[1])
    self.vipTxt = vipTxt

    local sx = winSize.width/2-180
    local sy = winSize.height/2-154

    self.pointArray = {}
    
    for i=1,5 do
    	local point = ccui.Button:create("shop/vipInfo/pointNormal.png","shop/vipInfo/pointSelected.png");
    	self:addChild(point)
    	point:setPosition(sx+i*60, sy)
    	table.insert(self.pointArray,point)
    end
    
    self:refreshUI()
end

function VipInfoLayer:leftArrowClickHandler()
	self.index = self.index - 1
	if self.index < 1 then
		self.index = 5
	end
	self:refreshUI()
end

function VipInfoLayer:rightArrowClickHandler()
	self.index = self.index + 1
	if self.index >5 then
		self.index = 1
	end
	self:refreshUI()
end

function VipInfoLayer:refreshUI()
	for k,v in pairs(self.pointArray) do
		if k== self.index then
			if v then
				v:setHighlighted(true)
			end
		else
			if v then
				v:setHighlighted(false)
			end
		end
	end
	self.vipTxt:setString(VipInfoLayer.tipsData[self.index])
	self.vipItem:loadTexture("shop/vipInfo/vip"..self.index..".png")
end

function VipInfoLayer:onSliderTable()
    
    local dis = self.touchEndPos.x - self.touchBeginPos.x
    if dis > 10 then
        self:rightArrowClickHandler()
    elseif dis < -10 then
        self:leftArrowClickHandler()
    end
    self.touchEndPos = nil
    self.touchBeginPos = nil
end

return VipInfoLayer