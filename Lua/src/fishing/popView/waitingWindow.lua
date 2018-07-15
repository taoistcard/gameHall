local WaitingWindow = class( "WaitingWindow", function() return display.newLayer(); end )

function WaitingWindow:createBaseWindow(mode)


end



function WaitingWindow:ctor(mode)

    self:initMaskLayer();

    self.frame = 0;



    self:setFrame();

end

function WaitingWindow:initMaskLayer(mode)

    local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("black.png")
    maskLayer:setOpacity(153)
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)
    self:setContentSize(winSize);

    local icon = display.newSprite("waiting.png", winSize.width/2, winSize.height/2)
    self:addChild(icon);

    self.text = display.newTTFLabel({text = "网络请求中",
                                size = 28,
                                color = cc.c3b(255,255,100),
                                font = FONT_PTY_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
    :align(display.CENTER, winSize.width/2, winSize.height/2-100)
    :addTo(self);

end

function WaitingWindow:setFrame()

	local string = "网络请求中";
	local count = self.frame % 7;
	for i=1,count do
		string = string.."."
	end
    self.text:setString(string);

end

function WaitingWindow:showWaiting(timeout)

	timeout = timeout or 10;
	local sequence = transition.sequence(
	    {
	        cc.DelayTime:create(timeout),
	        cc.CallFunc:create(function() self:timeout();end)
	    }
	)
    self:runAction(sequence);

	local sequence2 = transition.sequence(
	    {
	        cc.DelayTime:create(1),
	        cc.CallFunc:create(function() self:nextFrame();end)
	    }
	)
    self:runAction(sequence2);

end

function WaitingWindow:timeoutDelegate(delegate)

	self.delegate = delegate;

end

function WaitingWindow:timeout()

	if self.delegate and self.delegate.timeoutCallback then
		self.delegate:timeoutCallback();
	end

	self:dismiss();

end

function WaitingWindow:dismiss()

	self:removeFromParent();

end

function WaitingWindow:nextFrame()

	self.frame = self.frame + 1;
	self:setFrame();
	local sequence = transition.sequence(
	    {
	        cc.DelayTime:create(1),
	        cc.CallFunc:create(function() self:nextFrame();end)
	    }
	)
    self:runAction(sequence);

end

return WaitingWindow;