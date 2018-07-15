local CCDesignLayer = class("CCDesignLayer", function() return display.newLayer(); end );


function CCDesignLayer:ctor()

    local winSize = cc.Director:getInstance():getWinSize();
    -- 设计尺寸 1136*640
    self:setContentSize(cc.size(display.width,display.height));
    self:setPosition(cc.p(winSize.width/2,winSize.height/2));
    self:setAnchorPoint(cc.p(0.5,0.5));
    self:ignoreAnchorPointForPosition(false);
    -- self:addChild(self.container)
end

function CCDesignLayer:scene()

	local scene = display.newScene();
    scene:addChild(self);
    self.scene = scene;
    return scene;

end

function CCDesignLayer:showMyAera()

	local colorLayer = display.newColorLayer(cc.c4b(255,0,0,128));
	colorLayer:setContentSize(cc.size(display.width,display.height));
	self:addChild(colorLayer);

end


return CCDesignLayer