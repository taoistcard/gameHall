-- 结算界面
-- Author: <zhaxun>
-- Date: 2015-05-28 09:19:22
--

local GameItemFactory = require("commonView.GameItemFactory"):getInstance()

local EffectFactory = require("commonView.DDZEffectFactory")

local ViewResultLayer = class( "ViewResultLayer", function() return display.newLayer() end)

function ViewResultLayer:switchChairID()
    if self.myChairID == 1 then
        self.nextID = 2
        self.preID = 3
    elseif self.myChairID == 2 then
        self.nextID = 1
        self.preID = 3
    else
    	print("ViewResultLayer 座位分配失败！", self.myChairID)
    end
end
function ViewResultLayer:ctor(param)
    --self.super.ctor(self)
    local winSize = cc.Director:getInstance():getWinSize()

	self.data = param.data
	self.callFunc = param.lisenter

	self.myChairID = DataManager:getMyChairID()
    self:switchChairID()

    self.posOther = cc.p(160, 130)

end

function ViewResultLayer:onEnter()

end

function ViewResultLayer:onExit()

end

function ViewResultLayer:test()
end

function ViewResultLayer:start(msg)
	-- 胜利／失败图片显示
	local myScore = msg.lGameScore[self.myChairID]
	print("我的结算：", myScore)
	if myScore and myScore > 0 then--胜利
        self:performWithDelay(function() self:showWinEffect() end, 3.0)

	elseif myScore and myScore <= 0 then--失败
		self:performWithDelay(function() self:showLoseEffect() end, 3.0)

	end

	self.result = msg

end

function ViewResultLayer:showWinEffect()
	SoundManager.playSound("sound/win.mp3", false)

	local node = display.newNode():align(display.CENTER, display.cx, 1000):addTo(self)
	if self.myChairID == self.data.banker then --地主
		self.sprite = display.newSprite("result/win_dz.png")
			:addTo(node,1)
			--:align(display.CENTER, display.cx, 1000)

	else
		self.sprite = display.newSprite("result/win_nm.png")
			:addTo(node,1)
			--:align(display.CENTER, display.cx, 1000)
	end
	

	local effect = display.newSprite("common/effect_light.png"):addTo(node):align(display.CENTER, 0, 51)
	effect:scale(1.0)
	effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
	
	--self.sprite:setGlobalZOrder(2)
	--effect:setGlobalZOrder(1)

	transition.moveTo(node, {time = 1.5, y = display.cy, easing = "BOUNCEOUT"})

	self:performWithDelay(function() self:showResultView(1); node:hide() end, 3.0)

end

function ViewResultLayer:showLoseEffect()
	SoundManager.playSound("sound/lose.mp3", false)

	local node = display.newNode():align(display.CENTER, display.cx, 1000):addTo(self)
	if self.myChairID == self.data.banker then --地主
		self.sprite = display.newSprite("result/lose_dz.png")
			:addTo(node,1)
			--:align(display.CENTER, display.cx, 1000)
		    
	else
		self.sprite = display.newSprite("result/lose_nm.png")
			:addTo(node,1)
			--:align(display.CENTER, display.cx, 1000)
	end
	
	local effect = display.newSprite("result/lose_effect.png"):addTo(node):align(display.CENTER, 0, 58)
	effect:scale(1.0)
	effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
	
	-- self.sprite:setGlobalZOrder(2)
	-- effect:setGlobalZOrder(1)

	transition.moveTo(node, {time = 1.5, y = display.cy, easing = "BOUNCEOUT"})

	self:performWithDelay(function() self:showResultView(0); node:hide() end, 3.0)

end

function ViewResultLayer:showResultView(bWin)
	local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setOpacity(153)
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)
	
	local file = nil
	local vx = -100
	local vy = 50
	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
	if bWin == 1 then
		--光圈
		local effect = display.newSprite("common/effect_light.png"):addTo(self):align(display.CENTER, display.cx, display.cy + 180)
		effect:scale(2.0)

		local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/XS.png");
		local light = cc.ParticleSystemQuad:create("effect/XS.plist");
		light:setTexture(texture2d);
		light:setPosition(cc.p(display.cx, display.cy + 160+50));
		light:setScale(2)
		
		
		--窗体
		-- self.bgImage = display.newSprite("result/win_bg.png")--win_bg_dantiao
		-- self.bgImage:addTo(self):align(display.CENTER, display.cx, display.cy + 60)

		self.bgImage = display.newSprite("result/win_bg_dantiao.png")--win_bg_dantiao
		self.bgImage:addTo(self):align(display.CENTER, display.cx+9.5, display.cy + 60-32.5)

		effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))

		local down = display.newSprite("result/successDown.png")
		down:addTo(self):align(display.CENTER, display.cx-6.5, display.cy+60+149.5)

		local leftLoudspeaker = display.newSprite("#animationSuccess1.png")
		leftLoudspeaker:setPosition(display.cx-130, display.cy+60+147.5)
		self:addChild(leftLoudspeaker)

		local animation = EffectFactory:getInstance():getAnimationSuccess()
		cc.Animate:create(animation)

		leftLoudspeaker:runAction(cc.RepeatForever:create(
                                    cc.Sequence:create(
                                        cc.Animate:create(animation),
                                        cc.DelayTime:create(0.0))))

		local rightLoudspeaker = display.newSprite("#animationSuccess1.png")
		rightLoudspeaker:setPosition(display.cx+121.5, display.cy+60+147.5)
		self:addChild(rightLoudspeaker)
		rightLoudspeaker:setScaleX(-1)
		local animation2 = EffectFactory:getInstance():getAnimationSuccess()
		cc.Animate:create(animation2)

		rightLoudspeaker:runAction(cc.RepeatForever:create(
                                    cc.Sequence:create(
                                        cc.Animate:create(animation2),
                                        cc.DelayTime:create(0.0))))

		local up = display.newSprite("result/successUp.png")
		up:addTo(self):align(display.CENTER, display.cx-3.5, display.cy+60+110.5)

		if self.myChairID == self.data.banker then --地主
			local sprite = display.newSprite("result/win_dz_dantiao.png")
				:addTo(self)
				:align(display.CENTER, display.cx-315.5, display.cy +60+ 72.5)
			    
		else
			local sprite = display.newSprite("result/win_nm_dantiao.png")
				:addTo(self)
				:align(display.CENTER, display.cx-315.5, display.cy + 60+72.5)
		end
		self:addChild(light)
	else
		local effect = display.newSprite("result/lose_effect.png"):addTo(self):align(display.CENTER, display.cx, display.cy + 180)
		effect:scale(2.0)


		local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/rain.png");
		local light = cc.ParticleSystemQuad:create("effect/rain.plist");
		light:setTexture(texture2d);
		light:setPosition(cc.p(display.cx, display.cy + 160));
		light:setScale(2)
		

		self.bgImage = display.newSprite("result/lose_bg_dantiao.png")
		self.bgImage:addTo(self):align(display.CENTER, display.cx+5.5, display.cy + 60-45.5)


		effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)))


		local title = display.newSprite("#animationFailure1.png")
		title:setPosition(display.cx+1.5, display.cy +60+137.5)
		self:addChild(title)
		local animation = EffectFactory:getInstance():getAnimationFailure()
		cc.Animate:create(animation)

		title:runAction(                
						cc.Sequence:create(
                        cc.Animate:create(animation),
                        cc.DelayTime:create(0.5)))


		local cloud1 = display.newSprite("result/cloud.png")
		self:addChild(cloud1)
		cloud1:setPosition(display.cx-278.5, display.cy +60+257.5)
		cloud1:setScale(1.5)
		local action1 = cc.MoveBy:create(9,cc.p(200,0))
		cloud1:runAction(action1)

		local cloud2 = display.newSprite("result/cloud.png")
		self:addChild(cloud2)
		cloud2:setPosition(display.cx-178.5, display.cy +60+215.5)
		-- cloud2:setScale(1.5)
		local action2 = cc.MoveBy:create(9,cc.p(200,0))
		cloud2:runAction(action2)

		local cloud3 = display.newSprite("result/cloud.png")
		self:addChild(cloud3)
		cloud3:setPosition(display.cx+239.5, display.cy +60+243.5)
		cloud3:setScaleX(1.5)

		local action3 = cc.MoveBy:create(9,cc.p(-200,0))
		cloud3:runAction(action3)

		if self.myChairID == self.data.banker then --地主
			local sprite = display.newSprite("result/lose_dz_dantiao.png")
				:addTo(self)
				:align(display.CENTER, display.cx-315.5, display.cy +60+72.5)
			    
		else
			local sprite = display.newSprite("result/lose_nm_dantiao.png")
				:addTo(self)
				:align(display.CENTER, display.cx-315.5, display.cy +60+ 72.5)
		end
		self:addChild(light)
	end

	local total = #self.result.lGameScore
	for i=0,total-1 do
		if i == self.myChairID then 
			self:initMyView(i)
		else
			self:initOtherView(i)
		end
	end

	-- 继续按钮
	GameItemFactory:getBtnJXYX(function() self:onClickJX() end):addTo(self):align(display.CENTER, display.cx, display.cy - 260)

	-- 倒计时
	self.timer = 10
	self.timeLabel = display.newTTFLabel({
	        text = self.timer,
	        color = cc.c3b(193, 238, 69),
	        size = 60,
	        font = FONT_ART_TEXT,
	        strokeWidth = 2,
	        align  = cc.TEXT_ALIGNMENT_CENTER,
	        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	        dimensions = cc.size(600,0)
	    })
	self.timeLabel:addTo(self):align(display.CENTER, display.cx, display.cy - 190)

	self:performWithDelay(function() self:onTimer() end, 1.0)

	-- other    
	self.sprite:hide()

	--播放特效
	--self:initEffect(bWin)
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(871,500));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickClose()
				self.timer = -999
            end
        end
    )
end

function ViewResultLayer:onTimer()

	self.timer = self.timer -1
	if self.timer >= 0 then
		self:performWithDelay(function() self:onTimer() end, 1.0)

		self.timeLabel:setString(self.timer)
	else
		self:onClickJX()
	end

end

function ViewResultLayer:initMyView(index)
	local vy = 0
	-- 头像
	local faceID = DataManager:getMyUserInfo().faceID
	local path = nil
	if faceID >= 1 and faceID <= 37 then
		path = "head/head_" .. faceID .. ".png"
	elseif faceID == 999 then
		local tokenID = DataManager:getMyUserInfo().platformID
		path = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)
	else
		path = "head/default.png"
	end
	local frame = display.newSprite("play3/frame.png"):addTo(self.bgImage):align(display.CENTER, 166, 225+vy)
	self.myIcon = display.newSprite(path):addTo(frame):scale(0.7):align(display.CENTER, 45, 55)


	-- 金币／欢乐豆
	self.isHappyBeans = (bit.band(RunTimeData:getCurGameServerType(),Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE)
    if self.isHappyBeans then
        path = "common/huanledou.png"
    else
        path = "common/gold.png"
    end
    display.newSprite(path):addTo(self.bgImage):align(display.CENTER, 300, 265+vy)
    local gold = self.result.lGameScore[index+1]
	if gold > 0 then
		gold = "+" .. FormatNumToString(gold)
		gold = display.newBMFontLabel({
	        text = gold,
	        font = "fonts/jinbiSZ.fnt",
	    })
	else
		gold = display.newBMFontLabel({
	        text = FormatNumToString(gold),
	        font = "fonts/SBshuzi.fnt",
	    })
	end
	gold:addTo(self.bgImage):align(display.LEFT_CENTER, 340, 265+vy)

	-- 等级
	local userInfo = DataManager:getMyUserInfo()
	local bg = display.newScale9Sprite("hall/personalCenter/level_bg.png", 0, 0, cc.size(60, 30)):addTo(self.bgImage):align(display.CENTER, 300, 220+vy)

	local levelInfo = getLevelInfo(userInfo.medal)
	local level = display.newTTFLabel({
	        text = "LV." .. levelInfo.level,
	        color = cc.c3b(193, 238, 69),
	        size = 26,
	        strokeWidth = 2,
	        align  = cc.TEXT_ALIGNMENT_CENTER,
	        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	    })
	level:addTo(bg):align(display.LEFT_CENTER, 5, 15)

	--经验条 -- 现在协议中没有，后面再加
	local expBG = display.newSprite("hall/personalCenter/exp_background.png"):addTo(self.bgImage):align(display.LEFT_CENTER, 260, 180+vy)
	local expLast = display.newProgressTimer("hall/personalCenter/exp_now.png", display.PROGRESS_TIMER_BAR):addTo(self.bgImage):align(display.LEFT_CENTER, 260, 180+vy)
	expLast:setMidpoint(cc.p(0, 0.5))
    expLast:setBarChangeRate(cc.p(1.0, 0))

	--local expCurrent = display.newProgressTimer("hall/personalCenter/exp_add.png", display.PROGRESS_TIMER_BAR):addTo(self.bgImage):align(display.LEFT_CENTER, 220, 175)
	local expDesc = display.newTTFLabel({
            text = "27/156",
            color = cc.c3b(255, 255, 128),
            size = 24,
            --strokeWidth = 2,
            align  = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
    expDesc:addTo(self.bgImage):align(display.CENTER, 400, 180+vy)

    expLast:setPercentage(100*levelInfo.curNextLevelExp/levelInfo.nextLevelExp)
    expDesc:setString(levelInfo.curNextLevelExp .. "/" .. levelInfo.nextLevelExp)

end

function ViewResultLayer:initOtherView(index)
	local vy = -45
	-- 地主
	if index == self.data.banker then
		display.newSprite("play3/icon_dz.png"):addTo(self.bgImage):align(display.CENTER, self.posOther.x, self.posOther.y+vy):scale(0.5)
	end

	-- 金币
	local nameColor = cc.c3b(241, 202, 53)
	local gold = self.result.lGameScore[index+1]
	if gold > 0 then
		gold = "+" .. FormatNumToString(gold)
		gold = display.newBMFontLabel({
	        text = gold,
	        font = "fonts/jinbiSZ.fnt",
	        size = 26,
	    })
	else
		nameColor = cc.c3b(200,203,202)
		gold = display.newBMFontLabel({
	        text = FormatNumToString(gold),
	        font = "fonts/SBshuzi.fnt",
	        size = 26,
	    })
	end
	gold:addTo(self.bgImage):align(display.LEFT_CENTER, self.posOther.x + 250, self.posOther.y+vy)

	-- 昵称
	local name = display.newTTFLabel({
	        text = FormotGameNickName(self.data.playerName[index],8),
	        color = nameColor,
	        size = 26,
	        font = FONT_ART_TEXT,
	        strokeWidth = 2,
	        align  = cc.TEXT_ALIGNMENT_LEFT,
	        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	        dimensions = cc.size(600,0)
	    })
	name:addTo(self.bgImage):align(display.LEFT_CENTER, self.posOther.x + 50, self.posOther.y+vy)
	print("self.data.playerName[" .. index .. "]:" .. self.data.playerName[index])

	self.posOther.y = self.posOther.y - 40
end

function ViewResultLayer:initEffect(bWin)
	if bWin == 1 then

	    local particle = cc.ParticleSystemQuad:create("particle/win.plist")
	    particle:setScale(1.5)
	    --particle:setEmissionRate(20000)
	    particle:addTo(self,999):align(display.CENTER, display.cx, display.cy+180)
	    
	else
		--乌云
		local sprWY = display.newSprite("#wyrl.png"):addTo(self,999):align(display.CENTER, display.cx +200, display.cy+200)
		sprWY:runAction(cc.RepeatForever:create(
				            cc.Sequence:create(
				                cc.MoveBy:create(10, cc.p(-100, 0)),
								cc.MoveBy:create(10, cc.p(100, 0))
									)
									)
						)

		sprWY = display.newSprite("#wylr.png"):addTo(self,999):align(display.CENTER, display.cx -200, display.cy+200)
		sprWY:runAction(cc.RepeatForever:create(
				            cc.Sequence:create(
				                cc.MoveBy:create(10, cc.p(100, 0)),
								cc.MoveBy:create(10, cc.p(-100, 0))
									           )
			                                    )
			            )

		--下雨
	    local particle = cc.ParticleSystemQuad:create("particle/lose.plist")
	    particle:setScale(1.5)
	    --particle:setEmissionRate(20000)
	    particle:addTo(self,999):align(display.CENTER, display.cx, display.cy+200)
	
	end
end

function ViewResultLayer:onClickJX()
	print("onClickJX")
	SoundManager.playSound("sound/buttonclick.mp3")

	self:hide()

	if self.callFunc then
		self.callFunc(1)
	end
end

function ViewResultLayer:onClickClose()
    TableInfo:sendUserStandUpRequest()
	self:hide()
	if self.callFunc then
		self.callFunc(0)
	end
end

return ViewResultLayer