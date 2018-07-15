local VipInfoLayer = class("VipInfoLayer", function() return display.newLayer() end)
-- VipInfoLayer.tipsData = {
-- 			"1、专属绿钻标识\n2、每日工资金额8000金币\n3、破产补助金币2000\n4、银行手续费4%\n5、充值可获得额外金币6000",
-- 			"1、专属蓝钻标识\n2、每日工资金额34000金币\n3、破产补助金币5000\n4、银行手续费3%\n5、充值可获得额外金币40000",
-- 			"1、专属红钻标识\n2、每日工资金额66000金币\n3、破产补助金币8000\n4、银行手续费2%\n5、充值可获得额外金币100000",
-- 			"1、专属金钻标识\n2、每日工资金额132000金币\n3、破产补助金币10000\n4、银行手续费1%\n5、充值可获得额外金币300000",
-- 			"1、专属皇冠标识\n2、每日工资金额330000金币\n3、破产补助金币15000\n4、银行免手续费\n5、充值可获得额外金币900000"
-- 			}
VipInfoLayer.tipsData = {
"1.可领取每日VIP工资2500金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码手续费低至1.5% ",
"1.可领取每日VIP工资5000金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码手续费低至1% ",
"1.可领取每日VIP工资10000金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码手续费低至0.5% ",
"1.可领取每日VIP工资30000金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码无手续费",
"1.可领取每日VIP工资50000金币\n2.每天最多可领取破产补助金3次\n3.保险箱存筹码无手续费",

-- "1、专属绿钻标识\n2、破产补助金币5000\n3、每日领取3次破产补助\n4、银行手续费4%",
-- "1、专属蓝钻标识\n2、破产补助金币10000\n3、每日领取3次破产补助\n4、银行手续费3%",
-- "1、专属紫钻标识\n2、破产补助金币20000\n3、每日领取3次破产补助\n4、银行手续费2%",
-- "1、专属金钻标识\n2、破产补助金币50000\n3、每日领取3次破产补助\n4、银行手续费1%",
-- "1、专属皇冠标识\n2、破产补助金币100000\n3、每日领取3次破产补助\n4、银行免手续费",
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

    local bgSprite = ccui.Button:create("hallScene/personalCenter/underWriteBg.png","hallScene/personalCenter/underWriteBg.png");
    -- bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(1064,560));
    bgSprite:setPosition(cc.p(574,338));
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


    local leftArrow = ccui.Button:create("hallScene/vipInfo/arrow.png","hallScene/vipInfo/arrow.png");
    leftArrow:setPosition(cc.p(271-20,354))
    leftArrow:setPressedActionEnabled(true)
    leftArrow:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:leftArrowClickHandler(sender);
                    end
                end
            )
    self:addChild(leftArrow)
    leftArrow:setScaleX(-1)
    self.leftArrow = leftArrow
    self.leftArrow:setHighlighted(true)

    local rightArrow = ccui.Button:create("hallScene/vipInfo/arrow.png","hallScene/vipInfo/arrow.png");
    rightArrow:setPosition(cc.p(871+20,354))
    rightArrow:setPressedActionEnabled(true)
    rightArrow:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:rightArrowClickHandler(sender);
                    end
                end
            )
    -- rightArrow:setScaleX(-1)
    self:addChild(rightArrow)
    self.rightArrow = rightArrow

    local vipBg = ccui.ImageView:create("hallScene/vipInfo/shadow.png")
    vipBg:setPosition(423, 356)
    self:addChild(vipBg)

    local vipItem = ccui.ImageView:create("hallScene/vipInfo/vip1.png")
    vipItem:setPosition(410, 365)
    self:addChild(vipItem)
    self.vipItem = vipItem

    local vipTitleBg = ccui.ImageView:create("hallScene/vipInfo/wordBg.png")
    vipTitleBg:setPosition(422, 295)
    self:addChild(vipTitleBg)
    local vipTitle = ccui.Text:create("","fonts/HKBDTW12.TTF",24)
    vipTitle:setPosition(422, 295)
    vipTitle:setTextColor(cc.c4b(255,249,46,255))
    vipTitle:enableOutline(cc.c4b(76,0,112,255), 2)
    self:addChild(vipTitle)
    self.vipTitle = vipTitle

    local vipTxt = ccui.Text:create()
    vipTxt:setPosition(525, 424)
    vipTxt:setAnchorPoint(cc.p(0,1))
    vipTxt:setFontSize(20)
    vipTxt:setColor(cc.c3b(129,66,22))
    self:addChild(vipTxt)
    vipTxt:setString(VipInfoLayer.tipsData[1])
    self.vipTxt = vipTxt

    

    local sx = 450
    local sy = 250
    for i=#self.pointArray,1 ,-1 do
    	table.remove(self.pointArray,#self.pointArray)
    end
    
    for i=1,5 do
    	local point = ccui.Button:create("hallScene/vipInfo/pointNormal.png","hallScene/vipInfo/pointSelected.png");
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
	self.vipItem:loadTexture("hallScene/vipInfo/vip"..self.index..".png")
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