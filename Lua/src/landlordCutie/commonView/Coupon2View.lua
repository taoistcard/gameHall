local Coupon2View = class("Coupon2View", function() return display.newNode() end );

function Coupon2View:ctor(params)
	self.callback = params.lisenter

	local light = ccui.ImageView:create("liquan/light.png")
	light:addTo(self)
	light:align(display.CENTER, 1, -5)

	self.light = light

	local coupon = ccui.ImageView:create("liquan/coupon2.png");
	coupon:addTo(self)
	self.coupon = coupon

end

function Coupon2View:setValide(isValide)
	if isValide then
	    self.coupon:setTouchEnabled(true);
	    self.coupon:addTouchEventListener(function(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then
	            self:onClickCoupon();
	        end
	    end)

	    self.light:setVisible(true)

	    self.light:runAction(cc.RepeatForever:create(
	    						cc.Sequence:create(cc.FadeIn:create(0.8),
	    											cc.FadeOut:create(0.8))))

	else
		self.coupon:setTouchEnabled(false)
		self.light:setVisible(false)
		self.light:stopAllActions()
	end

end

function Coupon2View:setCouponNum(count)
	
end

function Coupon2View:onClickCoupon()
	if self.callback then
		self.callback()
	end
end

return Coupon2View