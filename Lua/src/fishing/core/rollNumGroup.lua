local RollNumGroup = class("RollNumGroup", function() return display.newLayer(); end );

function RollNumGroup:ctor(digit)

	self:setDefaultData();
	self:initAllNumber(digit);

end


function RollNumGroup:setDefaultData()

	self.value = 0;

	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
	sharedSpriteFrameCache:addSpriteFrames("number.plist");

end

function RollNumGroup:initAllNumber(digit)

	local pt = cc.p(0,0);
	local RollNumArray = {};
	self.RollNumArray = RollNumArray;
	for i = 1, digit do

		local pRollNum = require("core.rollNum").new();
		RollNumArray[i] = pRollNum;
		self:addChild(pRollNum);
		pRollNum:setPosition(pt);
		pt.x = pt.x - NUMBERWIDTH;

	end

end

function RollNumGroup:setValue(value)

	if self.value == value then
		return;
	end

	local up = self.value < value;
	self.value = value;

	for i, pRollNum in ipairs(self.RollNumArray) do
		
		local num = math.floor( value % 10 );

		if pRollNum:getNumber() ~= num then
			pRollNum:setNumber(num, up);
		end
		value = value / 10;

	end

end


return RollNumGroup;
