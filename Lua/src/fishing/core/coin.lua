local Coin = class( "Coin", function() return display.newSprite("blank.png"); end )

function Coin:ctor(isLiquan)

	self:setDefaultData();
	self:setDefaultCoin();
	self.isLiquan=isLiquan;
end


function Coin:setDefaultData()

	self.path = {};
	self.time = {};

end


function Coin:setDefaultCoin()

	-- local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
 --    local pFrame = sharedSpriteFrameCache:getSpriteFrame("jb_d0.png");
 --    local coin = cc.Sprite:createWithSpriteFrame(pFrame);
 --    self:addChild(coin);


	-- local frames = display.newFrames("jb_d%d.png", 0, 12);
	-- local animation = display.newAnimation(frames, 0.02);
	-- coin:runAction(cc.RepeatForever:create(cc.Animate:create(animation)));


end


function Coin:addLinePathTo(duration, pt)

	table.insert(self.path, pt);
	table.insert(self.time, duration);

end

function Coin:goCoin()

	local paths = {};

	for i,path in ipairs(self.path) do

		local moveto = cc.MoveTo:create(self.time[i], path);
		local easeAction = cc.EaseExponentialIn:create(moveto);

		table.insert(paths, easeAction);

	end

	if self.isLiquan then
	    -- local liquan = display.newSprite("fishEffect/lq_icon1.png");
	    -- liquan:setScale(0.6);
	    -- self:addChild(liquan);

	    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
		sharedSpriteFrameCache:addSpriteFrames("fishEffect/ani_liquan0.plist");

		local frames = display.newFrames("ani_liquan%d.png", 1, 6);
		local animation = display.newAnimation(frames, 0.02);
		self:runAction(cc.Repeat:create(cc.Animate:create(animation),7))
	else
		local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
		-- sharedSpriteFrameCache:addSpriteFrames("addGold.plist");
		sharedSpriteFrameCache:addSpriteFrames("fishEffect/ani_jinbi0.plist");

		-- local frames = display.newFrames("jb_d%d.png", 0, 12);
		local frames = display.newFrames("ani_jb_%d.png", 1, 7);
		local animation = display.newAnimation(frames, 0.02);

		-- self:setScale(0.5);
		-- local coinaction = cc.Spawn:createWithTwoActions(cc.Repeat:create(cc.Animate:create(animation),3), cc.Sequence:create(paths) );

		self:runAction(cc.Repeat:create(cc.Animate:create(animation),7))
	end

	-- local kInAngleZ = 270;
	-- local kInDeltaZ = 90;
	-- local kOutAngleZ = 0;
	-- local kOutDeltaZ = 90;

	-- local duration = 0.9;

	-- local inCoin = display.newSprite("effect/coin_bao_zha/lizi_jb_baozha.png");
	-- inCoin:setVisible(false);
	-- self:addChild(inCoin);

	-- local outCoin = display.newSprite("effect/coin_bao_zha/lizi_jb_baozha.png");
	-- self:addChild(outCoin);

	-- local animIn = transition.sequence(
	--     {
	--     	cc.DelayTime:create(duration * 0.5),
	--     	cc.Show:create();
	--         cc.OrbitCamera:create(duration * 0.5, 1, 0, kInAngleZ, kInDeltaZ, 0, 0),
	--     }
	-- )
	-- inCoin:runAction(animIn);

	-- local animOut = transition.sequence(
	--     {
	--     	cc.DelayTime:create(duration * 0.5),
	--     	cc.Hide:create();
	--         cc.OrbitCamera:create(duration * 0.5, 1, 0, kOutAngleZ, kOutDeltaZ, 0, 0),
	--     }
	-- )
	-- outCoin:runAction(animOut);

	-- -- local animation = cc.Spawn:create(animIn, animOut);
	-- -- self:runAction(cc.Repeat:create(animation,3));
	--    self:setScale(0.5);
	local sequence = transition.sequence(
	    {
	        cc.Sequence:create(paths),
	        cc.CallFunc:create(function() self:removeFromParent();end)
	    }
	)

    self:runAction(sequence);

	self:setVisible(true);

end


return Coin;
