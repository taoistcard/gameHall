
local GuanXianLayer = class("GuanXianLayer", function() return display.newLayer() end)

function GuanXianLayer:ctor(param)
	local guanxian = ccui.Text:create(self:getGuanXian(param.exp), "", 22);
    guanxian:setColor(param.c3b);
    self:addChild(guanxian);
    self.guanxian = guanxian
end

function GuanXianLayer:refreshGuanXian(exp)
	self.guanxian:setString(self:getGuanXian(exp))
end

function GuanXianLayer:getGuanXian(exp)
	if exp == 0 then return "无名"
	elseif exp <= 1 then return "村民"
	elseif exp <= 9 then return "办事员"
	elseif exp <= 49 then return "组长"
	elseif exp <= 199 then return "副主任"
	elseif exp <= 499 then return "主任"
	elseif exp <= 1999 then return "副村长"
	elseif exp <= 4999 then return "村长"
	elseif exp <= 9999 then return "副镇长"
	elseif exp <= 19999 then return "镇长"
	elseif exp <= 49999 then return "副县长"
	elseif exp <= 99999 then return "县长"
	elseif exp <= 199999 then return "副市长"
	elseif exp <= 499999 then return "市长"
	elseif exp <= 999999 then return "副省长"
	elseif exp <= 1999999 then return "省长"
	elseif exp <= 4999999 then return "副总统"
	elseif exp <= 19999999 then return "总统"
	elseif exp <= 9999999999999 then return "超人" end

	return "超超人"
end

return GuanXianLayer