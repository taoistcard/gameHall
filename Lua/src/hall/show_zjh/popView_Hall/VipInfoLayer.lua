local VipInfoLayer = class("VipInfoLayer", function() return display.newLayer() end)
VipInfoLayer.tipsData = {
        "1.可领取每日VIP工资2500金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码手续费低至1.5% ",
        "1.可领取每日VIP工资5000金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码手续费低至1% ",
        "1.可领取每日VIP工资10000金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码手续费低至0.5% ",
        "1.可领取每日VIP工资30000金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码无手续费",
        "1.可领取每日VIP工资50000金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码无手续费",
            }
VipInfoLayer.pointArray = {}
VipInfoLayer.titleArray = {"绿钻VIP","蓝钻VIP","红钻VIP","金钻VIP","皇冠VIP"}
function VipInfoLayer:ctor()
	self.index = 1
	self:createUI()
end
function VipInfoLayer:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);
    maskLayer:addTouchEventListener(
    	function (sender,eventType)
    		if eventType == ccui.TouchEventType.ended then
    			self.pointArray = nil
    			self:removeFromParent()    			
    		end
    	end
    )

    local bgSprite = ccui.ImageView:create("common/pop_bg.png")
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(557, 358));
    bgSprite:setPosition(cc.p(574,338));
    bgSprite:setTouchEnabled(true);
    bgSprite:setSwallowTouches(true);
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


    local leftArrow = ccui.Button:create("hall/vipInfo/arrow.png","hall/vipInfo/arrow.png");
    leftArrow:setPosition(cc.p(271,354))
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

    local rightArrow = ccui.Button:create("hall/vipInfo/arrow.png","hall/vipInfo/arrow.png");
    rightArrow:setPosition(cc.p(875,354))
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

    local vipBg = ccui.ImageView:create("hall/vipInfo/vipBg.png")
    vipBg:setPosition(423, 386)
    self:addChild(vipBg)

    local vipItem = ccui.ImageView:create("hall/vipInfo/vip1.png")
    vipItem:setPosition(422, 395)
    self:addChild(vipItem)
    self.vipItem = vipItem

    local vipTitle = ccui.Text:create("",FONT_ART_TEXT,24)
    vipTitle:setPosition(422, 295)
    vipTitle:setTextColor(cc.c4b(251,255,5,255))
    vipTitle:enableOutline(cc.c4b(152,70,39,255), 2)
    self:addChild(vipTitle)
    self.vipTitle = vipTitle

    local vipTxt = ccui.Text:create()
    vipTxt:setPosition(525, 444)
    vipTxt:setAnchorPoint(cc.p(0,1))
    vipTxt:setFontSize(20)
    vipTxt:setColor(cc.c3b(249,250,131))
    self:addChild(vipTxt)
    vipTxt:setString(VipInfoLayer.tipsData[1])
    self.vipTxt = vipTxt

    

    local sx = 460
    local sy = 215
    for i=#self.pointArray,1 ,-1 do
    	table.remove(self.pointArray,#self.pointArray)
    end
    
    for i=1,5 do
    	local point = ccui.Button:create("hall/vipInfo/pointNormal.png","hall/vipInfo/pointSelected.png");
    	self:addChild(point)
    	point:setPosition(sx+i*38, sy)
    	table.insert(self.pointArray,point)
    end
    print("self.pointArray==",#self.pointArray)
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
	self.vipItem:loadTexture("hall/vipInfo/vip"..self.index..".png")
    self.vipTitle:setString(VipInfoLayer.titleArray[self.index])
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