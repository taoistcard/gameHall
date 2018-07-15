-- 结算界面
-- Author: <zhaxun>
-- Date: 2015-05-28 09:19:22
--

require("landlord.CMD_LandlordMsg")

local GameItemFactory = require("commonView.GameItemFactory"):getInstance()

local EffectFactory = require("commonView.DDZEffectFactory")

local ViewResultLayer = class( "ViewResultLayer", function() return display.newLayer() end)

function ViewResultLayer:switchChairID()
    if self.myChairID == 1 then
        self.nextID = 2
        self.preID = 3
    elseif self.myChairID == 2 then
        self.nextID = 3
        self.preID = 1
    elseif self.myChairID == 3 then
        self.nextID = 1
        self.preID = 2
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
	if bWin == 1 then
		--光圈
		local effect = display.newSprite("common/effect_light.png"):addTo(self):align(display.CENTER, display.cx, display.cy + 180)
		effect:scale(2.0)
		--窗体
		self.bgImage = display.newSprite("result/win_bg.png")
		self.bgImage:addTo(self):align(display.CENTER, display.cx, display.cy + 60)

		local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/wuxing_lizi.png");
		local light = cc.ParticleSystemQuad:create("effect/wuxing_lizi.plist");
		light:setTexture(texture2d);
		light:setPosition(cc.p(display.cx, display.cy + 160));
		self:addChild(light)
		


		effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))


	else
		local effect = display.newSprite("result/lose_effect.png"):addTo(self):align(display.CENTER, display.cx, display.cy + 180)
		effect:scale(2.0)

		self.bgImage = display.newSprite("result/lose_bg.png")
		self.bgImage:addTo(self):align(display.CENTER, display.cx, display.cy + 60)

		local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/luoyel.png");
		local light = cc.ParticleSystemQuad:create("effect/luoyel.plist");
		light:setTexture(texture2d);
		light:setPosition(cc.p(display.cx, display.cy + 200));
		light:scale(1.5)
		self:addChild(light)


		effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)))
	end

	local total = #self.result.lGameScore
	for i=1,total do
		if i == self.myChairID then 
			self:initMyView(i)
		else
			self:initOtherView(i)
		end
	end
	
	-- 继续按钮
	GameItemFactory:getBtnJXYX(function() self:onClickJX() end):addTo(self):align(display.CENTER, display.cx+100, display.cy - 260)--741, 188
	-- 换桌按钮
    local button = ccui.Button:create("common/common_button3.png","common/common_button3.png");
    button:setScale9Enabled(true)
    button:setContentSize(cc.size(160,70))
    button:setZoomScale(0.1)
    button:setPressedActionEnabled(true)
    button:setTitleText("换桌")
    button:setTitleFontSize(30)
    button:setTitleFontName(FONT_ART_BUTTON)
    button:setTitleColor(cc.c4b(255, 255, 255,255))
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onChangeTable();
            end
        end
        )
    button:align(display.CENTER, display.cx-100, display.cy - 260)
    button:addTo(self)
    self.btnChangeTable = button

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
	elseif self.timer <= -999 then
		--todo
	else
		self:onClickJX()
	end

end

function ViewResultLayer:initMyView(index)
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
	local frame = display.newSprite("play3/frame.png"):addTo(self.bgImage):align(display.CENTER, 166+20, 225-20)
	self.myIcon = display.newSprite(path):addTo(frame):scale(0.7):align(display.CENTER, 45, 55)


	-- 金币／欢乐豆
	self.isHappyBeans = (bit.band(RunTimeData:getCurGameServerType(),Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE)
    if self.isHappyBeans then
        path = "common/huanledou.png"
    else
        path = "common/gold.png"
    end
    display.newSprite(path):addTo(self.bgImage):align(display.CENTER, 300-180, 265+10)
    local gold = self.result.lGameScore[index]
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
	gold:addTo(self.bgImage):align(display.LEFT_CENTER, 340-180, 265+10)
	-- 底分和倍数
	local curGameID = RunTimeData:getCurGameID()
	local difen = ccui.Text:create()
    difen:setPosition(500+38, 265+30)
    difen:setFontSize(22)
    difen:setColor(cc.c3b(241, 255, 126))
    self.bgImage:addChild(difen)
    difen:setString("底分:"..self.data:getDiFen())

	local beishu = ccui.Text:create()
    beishu:setPosition(345, 280)
    beishu:setFontSize(22)
    beishu:setAnchorPoint(cc.p(0,1))
    beishu:setColor(cc.c3b(250,237,100))
    self.bgImage:addChild(beishu)
    local beishuinfo = "("	    
    if self.data:getBombCount() >0 then
    	beishuinfo = beishuinfo..self.data:getBombCount().."个炸弹X"..(2^self.data:getBombCount()).."倍,"
    end
    print("王炸",self.data:getRocket())
    if self.data:getRocket() then
    	beishuinfo = beishuinfo.."王炸 X2倍,"
    end
    if self.data:getRobPlus() > 1 then
    	beishuinfo = beishuinfo.."抢地主 X"..self.data:getRobPlus().."倍,"
    end

	if curGameID == 200 then
		
	elseif curGameID == 202 then
	    if self.data:getDipaiPlus()>1 then
	    	local cbBankerCardTypeArray = {"其它","单王","对2","顺子","同花","三条","全小","双王"}
	    	local dipaiType = ""
	    	if self.data:getDipaiType()>0 then
	    		dipaiType = cbBankerCardTypeArray[self.data:getDipaiType()]
	    	end	    		
	    	beishuinfo = beishuinfo..dipaiType.." X"..self.data:getDipaiPlus().."倍,"
	    end
	    if self.data.farmerFirst == 1 then
	    	beishuinfo = beishuinfo.."让先 X3倍,"
	    end
	end

    if self.data:getSpring() then
    	beishuinfo = beishuinfo.."春天 X2倍,"
    end	
    beishuinfo = string.sub(beishuinfo,1,#beishuinfo-1)
    beishuinfo = beishuinfo..")"
	print("beishuinfo",beishuinfo)
    beishu:setString(beishuinfo)
    beishu:setTextAreaSize(cc.size(270,100))
    beishu:ignoreContentAdaptWithSize(false)
    beishu:setTextHorizontalAlignment(0)
    beishu:setTextVerticalAlignment(0)
	-- 等级
	local userInfo = DataManager:getMyUserInfo()
	local bg = display.newScale9Sprite("hall/personalCenter/level_bg.png", 0, 0, cc.size(60, 30)):addTo(self.bgImage):align(display.CENTER, 300-10, 220+15)

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
	local expBG = display.newSprite("hall/personalCenter/exp_background.png"):addTo(self.bgImage):align(display.LEFT_CENTER, 260, 180)
	local expLast = display.newProgressTimer("hall/personalCenter/exp_now.png", display.PROGRESS_TIMER_BAR):addTo(self.bgImage):align(display.LEFT_CENTER, 260, 180)
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
    expDesc:addTo(self.bgImage):align(display.CENTER, 400, 180)

    expLast:setPercentage(100*levelInfo.curNextLevelExp/levelInfo.nextLevelExp)
    expDesc:setString(levelInfo.curNextLevelExp .. "/" .. levelInfo.nextLevelExp)

end

function ViewResultLayer:initOtherView(index)

	-- 地主
	if index == self.data.banker then
		display.newSprite("play3/icon_dz.png"):addTo(self.bgImage):align(display.CENTER, self.posOther.x, self.posOther.y):scale(0.5)
	end

	-- 金币
	local nameColor = cc.c3b(241, 202, 53)
	local gold = self.result.lGameScore[index]
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
	gold:addTo(self.bgImage):align(display.LEFT_CENTER, self.posOther.x + 250, self.posOther.y)

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
	name:addTo(self.bgImage):align(display.LEFT_CENTER, self.posOther.x + 50, self.posOther.y)
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

function ViewResultLayer:onChangeTable()
	-- GameCenter:standUp()
	-- TableInfo:sendUserStandUpRequest()
    -- GameCenter:autoMatch()
	self:hide()

	if self.callFunc then
		self.callFunc(2)
	end
	
end

function ViewResultLayer:onClickClose()
	-- GameCenter:standUp()
	TableInfo:sendUserStandUpRequest()
	self:hide()
	if self.callFunc then
		self.callFunc(0)
	end
end
return ViewResultLayer