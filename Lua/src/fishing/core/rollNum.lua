local RollNum = class( "RollNum", function() return display.newSprite("blank.png"); end )

NUMBERHEIGHT = 30;
NUMBERWIDTH = 22;
TEXTUREHEIGHT = 300;

local scheduler = require("framework.scheduler");

function RollNum:ctor()

	self:setNodeEventEnabled(true)

	self:setDefaultData();
	self:setDefaultNumber();

end

function RollNum:onExit()

	if self.updateNumberSchedule then
		scheduler.unscheduleGlobal(self.updateNumberSchedule);
		self.updateNumberSchedule = nil;
	end

end

function RollNum:setDefaultData()

	self.number = 0;

	self.Up = true;
	self.CurTexH = 0;
	self.EndTexH = 0;
	self.Rolling = false;

end


function RollNum:setDefaultNumber()

	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    local tpFrame = sharedSpriteFrameCache:getSpriteFrame("number.png");
    local pTexture = tpFrame:getTexture();
    self.pTexture = pTexture;

    local pFrame = cc.SpriteFrame:createWithTexture(self.pTexture, cc.rect(0, 0, NUMBERWIDTH, NUMBERHEIGHT));
    self:setSpriteFrame(pFrame);

end


function RollNum:updateNumber()

	if self.Rolling and self.CurTexH == self.EndTexH then

		if self.updateNumberSchedule then
			scheduler.unscheduleGlobal(self.updateNumberSchedule);
			self.updateNumberSchedule = nil;
		end
		return;

	end

	if self.Up then
	
	    self.CurTexH = self.CurTexH + 5;
	    if self.CurTexH >= TEXTUREHEIGHT then
	        self.CurTexH = 0;
	    end
	
	else
	
	    self.CurTexH = self.CurTexH - 5;
	    if self.CurTexH < 0 then
	        self.CurTexH = TEXTUREHEIGHT;
	    end

	end

    local h = self.CurTexH;
    if self.CurTexH >= TEXTUREHEIGHT - NUMBERHEIGHT then

        h = TEXTUREHEIGHT - NUMBERHEIGHT;

    end

    local pFrame = cc.SpriteFrame:createWithTexture(self.pTexture, cc.rect(0, h, NUMBERWIDTH, NUMBERHEIGHT));
    self:setSpriteFrame(pFrame);
    self.Rolling = true;


end


function RollNum:setNumber(var, up)

	if self.updateNumberSchedule then
		scheduler.unscheduleGlobal(self.updateNumberSchedule);
		self.updateNumberSchedule = nil;
	end

	self.number = var;
	self.Up = up;

	self.EndTexH = var * (NUMBERHEIGHT);
	self.updateNumberSchedule = scheduler.scheduleGlobal(
    	function()
	        self:updateNumber();
    	end
    	,
    	0.02
    )

end

function RollNum:getNumber()

	return self.number;

end

return RollNum;
