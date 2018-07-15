local RuleLayer = class("RuleLayer",function ()	return display.newLayer()end)
local cardInfo = {
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",
}
function RuleLayer:ctor()
	self:createUI()
    -- self:setBackGroundColorType(1)
    -- self:setBackGroundColor(cc.c3b(100,123,100))
end
function RuleLayer:createUI()
	local cardName = {
		{0x01,0x31,0x21},
		{0x2A,0x29,0x28},
		{0x0D,0x0B,0x09},
		{0x0A,0x19,0x28},
		{0x09,0x09,0x3B},
		{0x2C,0x3A,0x08},
	}
	local typeName = {"豹子","同花顺","同花","顺子" ,"对子" ,"单张"}
	local scale = 0.67
	local cardSize = ccui.ImageView:create("card/kb_0_0.png"):getContentSize()
	local cardInterval = 2
	local topInterval = 4
	local leftInterval = 10
	local wordWidth = 81
	local wordInterval = 10
	local bgWidth = leftInterval*2+(cardSize.width*scale+cardInterval)*3-cardInterval+wordInterval+wordWidth
	local bgHeight = (cardSize.height*scale+cardInterval)*6-cardInterval+topInterval*2
    local ruleBg = ccui.ImageView:create("common/pop_bg2.png")
    ruleBg:setScale9Enabled(true)
    ruleBg:setContentSize(cc.size(bgWidth,bgHeight))
    ruleBg:setAnchorPoint(cc.p(0,0))
    ruleBg:setPosition(0, 63)
    ruleBg:setTouchEnabled(true)
    ruleBg:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:slideIn()
            end
        end
    )
    -- self:addChild(ruleBg)
    self.ruleBg = ruleBg
    self.bgWidth = bgWidth
    local chipLayer = ccui.Layout:create()
    -- chipLayer:setAnchorPoint(cc.p(0.5,0.5))
    chipLayer:setContentSize(cc.size(1136,640))
    -- chipLayer:setPosition(30,-chipLayer:getContentSize().height-80)
    -- chipLayer:setBackGroundColorType(1)
    -- chipLayer:setBackGroundColor(cc.c3b(100,123,100))
    
    chipLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:slideIn()
            end
        end
    )
    self.chipLayer = chipLayer
    self:addChild(chipLayer)
    chipLayer:addChild(ruleBg)
    for i=1,6 do
    	for j=1,3 do
    		local kind = math.floor(cardName[i][j] / 0x10 )
	        local num = cardName[i][j] % 0x10
	        local filename = "card/kb_"..kind.."_"..num..".png";
    		local card = ccui.ImageView:create(filename)
    		card:setPosition(leftInterval+(cardSize.width*scale+cardInterval)*(j-1), topInterval+(cardSize.height*scale+cardInterval)*(5-(i-1)))
    		card:setAnchorPoint(cc.p(0,0))
    		card:setScale(scale)
    		ruleBg:addChild(card)
    	end
    	local typetxt = ccui.Text:create(typeName[i],"",27)
    	typetxt:setPosition(leftInterval+(cardSize.width*scale+cardInterval)*(3)-cardInterval+wordInterval, topInterval+(cardSize.height*scale+cardInterval)*(5-(i-1))+cardSize.height*scale/2)
    	typetxt:setAnchorPoint(cc.p(0,0.5))
    	ruleBg:addChild(typetxt)
    end
end
function RuleLayer:slideOut()
	self.ruleBg:setPosition(-self.bgWidth+0, 63)
	local moveby = cc.MoveBy:create(0.2, cc.p(self.bgWidth, 0))
    local fun = cc.CallFunc:create(function ()
        self.ruleBg:setPosition(0+0, 63)
    end)
	self.ruleBg:runAction(cc.Sequence:create(moveby,fun))
    self.chipLayer:setTouchEnabled(true)
end
function RuleLayer:slideIn()
	self.ruleBg:setPosition(0, 63)
	local moveby = cc.MoveBy:create(0.2, cc.p(-self.bgWidth, 0))
    local fun = cc.CallFunc:create(function ()
        self.ruleBg:setPosition(-self.bgWidth+0, 63)
    end)
	self.ruleBg:runAction(cc.Sequence:create(moveby,fun))
    self.chipLayer:setTouchEnabled(false)
end
return RuleLayer