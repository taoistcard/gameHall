local CouponView = class("CouponView", function() return display.newNode() end );

function CouponView:ctor(params)
	self.callback = params.lisenter

	local light = ccui.ImageView:create("liquan/light.png")
	light:addTo(self)
	light:align(display.CENTER, 1, -5)

	self.light = light

	local coupon = ccui.ImageView:create("liquan/coupon.png");
	coupon:addTo(self)
	self.coupon = coupon

end

function CouponView:setValide(isValide)
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

function CouponView:setCouponNum(count)
	
end

function CouponView:onClickCoupon()
	if self.callback then
		self.callback()
	end
end

return CouponView