local NumberLayer = class( "NumberLayer", function() return display.newLayer() end )
function NumberLayer:ctor()
	
end
function NumberLayer:updateNum( kind,value )
	-- print(kind,value)

	local numDocument = "num1"
	local intervalX = 19
    local overWan = false
    local overYi = false
    local floatValue = 0--万以下的值
	if kind == 10 then
		numDocument = "winNum"
		intervalX = 15
		local tempValue = value

		if value/100000000>1 then
	    	value = math.floor(value/100000000)
	    	overYi = true
	    	floatValue = tempValue-value*100000000
	    elseif value/10000>1 then
	    	value = math.floor(value/10000)
	    	overWan = true
	    	floatValue = tempValue-value*10000
		end
	    local plus = ccui.ImageView:create("zhajinhua/winNum/plus.png")
	    plus:setPosition(-intervalX,0)
	    plus:setAnchorPoint(cc.p(0,0))
		self:addChild(plus)
	else
		numDocument = "num"..kind
		intervalX = 19
	end
	local qian = math.floor(value/1000)
	local bai = math.floor((value-qian*1000)/100)
	local shi = math.floor((value-qian*1000-bai*100)/10)
	local ge = value%10
	local vx = 0
	local vy = 0

	if qian>0 then
		local numqian = ccui.ImageView:create("zhajinhua/"..numDocument.."/"..qian..".png")
		numqian:setAnchorPoint(cc.p(0,0))
		numqian:setPosition(vx, vy)
		self:addChild(numqian)
		vx =vx+intervalX
	end
	if bai>0 or qian>0 then
		local numbai = ccui.ImageView:create("zhajinhua/"..numDocument.."/"..bai..".png")
		numbai:setAnchorPoint(cc.p(0,0))
		numbai:setPosition(vx, vy)
		self:addChild(numbai)
		vx =vx+intervalX
	end
	if shi>0 or qian>0 or bai>0 then
		local numshi = ccui.ImageView:create("zhajinhua/"..numDocument.."/"..shi..".png")
		numshi:setAnchorPoint(cc.p(0,0))
		numshi:setPosition(vx, vy)
		self:addChild(numshi)
		vx =vx+intervalX
	end

	local numge = ccui.ImageView:create("zhajinhua/"..numDocument.."/"..ge..".png")
	numge:setAnchorPoint(cc.p(0,0))
	numge:setPosition(vx, vy)
	self:addChild(numge)
	vx =vx+intervalX
	if kind == 10 and floatValue>0 then
	    local point = ccui.ImageView:create("zhajinhua/winNum/point.png")
	    point:setPosition(vx, vy)
	    point:setAnchorPoint(cc.p(0,0))
		self:addChild(point)
		vx =vx+11
		local xishu = 1
		if overYi then
			xishu = 10000
		end
		local f_qian = math.floor(floatValue/(1000*xishu))
		local f_bai = math.floor((floatValue-f_qian*(1000*xishu))/(100*xishu))
		local f_shi = math.floor((floatValue-f_qian*(1000*xishu)-f_bai*(100*xishu))/(10*xishu))
		local f_ge = floatValue/xishu%(10)
		-- print("floatValue",floatValue,"f_qian",f_qian,"f_bai",f_bai,"f_shi",f_shi,"f_ge",f_ge)
		if f_qian>=0 then
			local numqian = ccui.ImageView:create("zhajinhua/"..numDocument.."/"..f_qian..".png")
			numqian:setAnchorPoint(cc.p(0,0))
			numqian:setPosition(vx, vy)
			self:addChild(numqian)
			vx =vx+intervalX
		end
		--小数点后保留一位
		if f_bai>10 then
			local numbai = ccui.ImageView:create("zhajinhua/"..numDocument.."/"..f_bai..".png")
			numbai:setAnchorPoint(cc.p(0,0))
			numbai:setPosition(vx, vy)
			self:addChild(numbai)
			vx =vx+intervalX
		end
		if f_shi>10 then
			local numshi = ccui.ImageView:create("zhajinhua/"..numDocument.."/"..f_shi..".png")
			numshi:setAnchorPoint(cc.p(0,0))
			numshi:setPosition(vx, vy)
			self:addChild(numshi)
			vx =vx+intervalX
		end
		if f_ge >10 then
			local numge = ccui.ImageView:create("zhajinhua/"..numDocument.."/"..f_ge..".png")
			numge:setAnchorPoint(cc.p(0,0))
			numge:setPosition(vx, vy)
			self:addChild(numge)
			vx =vx+intervalX
		end
	end
	if kind == 10 then
		local wan
		if overYi then
			wan = ccui.ImageView:create("zhajinhua/winNum/yi.png")
		elseif overWan then
			wan = ccui.ImageView:create("zhajinhua/winNum/wan.png")
		else
			--todo
		end
		if wan then
		    wan:setPosition(vx, vy-1)
		    wan:setAnchorPoint(cc.p(0,0))
			self:addChild(wan)
		end
	end
end
return NumberLayer