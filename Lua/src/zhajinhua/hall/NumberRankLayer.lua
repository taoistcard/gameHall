local NumberRankLayer = class( "NumberRankLayer", function() return display.newLayer() end )
function NumberRankLayer:ctor()
	
end
function NumberRankLayer:updateNum( kind,value )
	-- print(kind,value)
	local numDocument = "competeOver"
	local intervalX = 55
    local overWan = false
    local floatValue = 0--万以下的值
	if kind == 10 then
		numDocument = "winNum"
		intervalX = 15
		local tempValue = value
		if value/10000>1 then
	    	value = math.floor(value/10000)
	    	overWan = true
	    	floatValue = tempValue-value*10000
		end
	    local plus = ccui.ImageView:create("hall/winNum/plus.png")
	    plus:setPosition(-intervalX,0)
	    plus:setAnchorPoint(cc.p(0,0))
		self:addChild(plus)
	else
		numDocument = "competeOver"
		intervalX = 55
	end
	local qian = math.floor(value/1000)
	local bai = math.floor((value-qian*1000)/100)
	local shi = math.floor((value-qian*1000-bai*100)/10)
	local ge = value%10
	local vx = 0
	local vy = 0

	if qian>0 then
		local numqian = ccui.ImageView:create("hall/"..numDocument.."/"..qian..".png")
		numqian:setAnchorPoint(cc.p(0,0))
		numqian:setPosition(vx, vy)
		self:addChild(numqian)
		vx =vx+intervalX
	end
	if bai>0 then
		local numbai = ccui.ImageView:create("hall/"..numDocument.."/"..bai..".png")
		numbai:setAnchorPoint(cc.p(0,0))
		numbai:setPosition(vx, vy)
		self:addChild(numbai)
		vx =vx+intervalX
	end
	if shi>0 then
		local numshi = ccui.ImageView:create("hall/"..numDocument.."/"..shi..".png")
		numshi:setAnchorPoint(cc.p(0,0))
		numshi:setPosition(vx, vy)
		self:addChild(numshi)
		vx =vx+intervalX
	end

	local numge = ccui.ImageView:create("hall/"..numDocument.."/"..ge..".png")
	numge:setAnchorPoint(cc.p(0,0))
	numge:setPosition(vx, vy)
	self:addChild(numge)
	vx =vx+intervalX
	if kind == 10 and floatValue>0 then
	    local point = ccui.ImageView:create("hall/winNum/point.png")
	    point:setPosition(vx, vy)
	    point:setAnchorPoint(cc.p(0,0))
		self:addChild(point)
		vx =vx+11
	
		local f_qian = math.floor(floatValue/1000)
		local f_bai = math.floor((floatValue-f_qian*1000)/100)
		local f_shi = math.floor((floatValue-f_qian*1000-f_bai*100)/10)
		local f_ge = floatValue%10
		if f_qian>0 then
			local numqian = ccui.ImageView:create("hall/"..numDocument.."/"..f_qian..".png")
			numqian:setAnchorPoint(cc.p(0,0))
			numqian:setPosition(vx, vy)
			self:addChild(numqian)
			vx =vx+intervalX
		end
		--小数点后保留一位
		if f_bai>10 then
			local numbai = ccui.ImageView:create("hall/"..numDocument.."/"..f_bai..".png")
			numbai:setAnchorPoint(cc.p(0,0))
			numbai:setPosition(vx, vy)
			self:addChild(numbai)
			vx =vx+intervalX
		end
		if f_shi>10 then
			local numshi = ccui.ImageView:create("hall/"..numDocument.."/"..f_shi..".png")
			numshi:setAnchorPoint(cc.p(0,0))
			numshi:setPosition(vx, vy)
			self:addChild(numshi)
			vx =vx+intervalX
		end
		if f_ge >10 then
			local numge = ccui.ImageView:create("hall/"..numDocument.."/"..f_ge..".png")
			numge:setAnchorPoint(cc.p(0,0))
			numge:setPosition(vx, vy)
			self:addChild(numge)
			vx =vx+intervalX
		end
	end
	if kind == 10 and overWan then
	    local wan = ccui.ImageView:create("hall/winNum/wan.png")
	    wan:setPosition(vx, vy-1)
	    wan:setAnchorPoint(cc.p(0,0))
		self:addChild(wan)
	end
end
return NumberRankLayer