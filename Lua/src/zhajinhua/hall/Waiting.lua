
local Waiting = class("Waiting",function() return display.newLayer() end)


function Waiting:ctor()

    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(winSize.width,winSize.height)
    self:setContentSize(contentSize)

    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(contentSize);
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(contentSize.width/2, display.cy));
    maskLayer:setTouchEnabled(true)
    maskLayer:setOpacity(50)
    self:addChild(maskLayer)

    self:createUI();

end

function Waiting:createUI()
    local contentSize = self:getContentSize()

    local coreimg = ccui.ImageView:create("common/waiting_core.png");
    coreimg:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2));
    self:addChild(coreimg);

    self.imgs = {}
    self.huases = { "common/waiting1.png", "common/waiting4.png", "common/waiting3.png", 
				    "common/waiting2.png", "common/waiting1.png", "common/waiting4.png", 
				    "common/waiting3.png", "common/waiting2.png", "common/waiting1.png", 
				    "common/waiting4.png", "common/waiting3.png", "common/waiting2.png"}
	self.positions = {	cc.p(contentSize.width / 2, contentSize.height / 2 + 75),
						cc.p(contentSize.width / 2 + 35, contentSize.height / 2 + 62),
						cc.p(contentSize.width / 2 + 61, contentSize.height / 2 + 37),
						cc.p(contentSize.width / 2 + 72, contentSize.height / 2 ),
						cc.p(contentSize.width / 2 + 61, contentSize.height / 2 - 37),
						cc.p(contentSize.width / 2 + 35, contentSize.height / 2 - 62),
						cc.p(contentSize.width / 2, contentSize.height / 2 - 70),
						cc.p(contentSize.width / 2 - 35, contentSize.height / 2 - 62),
						cc.p(contentSize.width / 2 - 63, contentSize.height / 2 - 38),
						cc.p(contentSize.width / 2 - 75, contentSize.height / 2),
						cc.p(contentSize.width / 2 - 64, contentSize.height / 2 + 38),
						cc.p(contentSize.width / 2 - 36, contentSize.height / 2 + 64)
					}

	for k, v in ipairs(self.huases) do
		local posimg = ccui.ImageView:create(v);
	    posimg:setPosition(self.positions[k]);
	    self:addChild(posimg);
	    self.imgs[k] = posimg
	    posimg:setOpacity(50)
	end
	
	self.curIndex = 1

	local function fadexunhuan()
		self.curimg = self.imgs[self.curIndex]
		local sequce = cc.Sequence:create(
									cc.FadeTo:create(0.1, 255),
                                    cc.CallFunc:create(function() 
                                    	self.curimg:setOpacity(100)
                                    	self.curIndex = self.curIndex + 1
                                    	if self.curIndex > 12 then self.curIndex = 1 end
                                    	fadexunhuan()
                                    end)
                       )
		self.curimg:runAction(sequce)
	end

	fadexunhuan()
end


return Waiting