local Player = class("Player", function() return display.newLayer(); end );
local MAX_BULLET_COUNT = 30;
--bBlankPlayer 标志等待玩家
function Player:ctor(userinfo, container, database, bBlankPlayer, blankSeat)
    self:setContentSize(cc.size(300, 80));
    self.database=database;

    if bBlankPlayer then
        self:setBlankPlayer(blankSeat)
    else
        self:setDefaultData(userinfo);
        self:setDefaultModel(container, database);
    end
end

function Player:setBlankPlayer(seat)
    local winSize = cc.Director:getInstance():getWinSize();
    local points = {winSize.width/3-30, winSize.width/3*2+30, 50, winSize.height-50};

    local bgSprite = ccui.ImageView:create("player_wait_bg.png");

    if seat == 1 then
        self:setPosition(cc.p(points[1], points[3]));
    elseif seat == 2 then
        self:setPosition(cc.p(points[2], points[3]));
    elseif seat == 3 then
        self:setPosition(cc.p(points[2], points[4]));
    elseif seat == 4 then
        self:setPosition(cc.p(points[1], points[4]));
    end

    self:addChild(bgSprite);

    local label = display.newTTFLabel({text = "等待玩家...",
                                size = 26,
                                color = cc.c3b(255,224,20),
                                -- font = FONT_PTY_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
    label:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2)
    label:enableOutline(cc.c4b(0,0,0,255),2)
    bgSprite:addChild(label)

    if FLIP_FISH then
        self:setRotation(180);
    end
end

function Player:setDefaultData(userinfo)

	self.userInfo = userinfo;
	if self.userInfo.userID == AccountInfo.userId then
		self.mainPlayer = true;
	end

	self.score = userinfo.score;
	self.time = {};
	self.seat = userinfo.chairID;
	-- self.pao_option = 1;
    self.cur_zi_dan_cost = FishInfo.gameConfig.bulletMultipleMin
    self.per_add_coin = FishInfo.gameConfig.bulletMultipleMin

    --锁定开启减速标志
    self.setLockFishSlow = false
    
end

function Player:setDefaultModel(container, database)

	local seat = self.seat;
	local nickName = self.userInfo.nickName;
	local gameID = self.userInfo.gameID;

    local bgSprite = ccui.ImageView:create("playing_bg.png");
    bgSprite:setPosition(cc.p(60,0));
    self:addChild(bgSprite)
    self.bg = bgSprite;

    local faceID = self.userInfo.faceID
    if faceID == 999 then
        faceID = 1
    end
    --玩家头像
    local headView = require("show.popView_Hall.HeadView").new(faceID,true);
    headView:setPosition(cc.p(-160,0));
    headView:setScale(0.7);
    self:addChild(headView);
    
    if self.userInfo.faceID == 999 then
        headView:setNewHead(self.userInfo.faceID, self.userInfo.platformID, self.userInfo.platformFace);
    end

    self.headView = headView;

    headView:setTouchEnabled(true)
    headView:addTouchEventListener(
        function (sender,eventType)
            if eventType == ccui.TouchEventType.began then
                sender:scale(0.75)
            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(0.7)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(0.7)
                local layer = require("show.popView_Hall.UserInfoLayer").new(self.userInfo,self)
                display.getRunningScene():addChild(layer)
            end
        end
    )

	local cannon = require("core.cannon").new(container, database, seat, self);
    cannon:setPosition(-60, 0)
	self:addChild(cannon,10);
	self.cannon = cannon;

    -- print("测试.....",cannon:getPositionX(),cannon:getPositionY())

    --只有自己可以调整炮台
    if self.mainPlayer then
        -- local freeRoom = ccui.Button:create("btn_green.png");
        local freeRoom = ccui.Button:create("blank.png");
        freeRoom:setScale9Enabled(true);
        freeRoom:setContentSize(cc.size(90, 90));
        freeRoom:setPosition(cannon:getPosition());
        freeRoom:setPressedActionEnabled(true);
        freeRoom:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.began then
                    cannon:setScale(1.1)
                elseif eventType == ccui.TouchEventType.ended then
                    -- if self.pao_option < 4 then
                    --     self.pao_option = self.pao_option + 1
                    -- end
                    -- cannon:setPaoOption(self.pao_option)
                    cannon:setScale(1.0)

                    self:popSelectPaoLayer()

                elseif eventType == ccui.TouchEventType.canceled then
                    cannon:setScale(1.0)
                end
            end
        )
        self:addChild(freeRoom,11)

        --瞄准线
        self.aimLine = {}
        for i=1,6 do
            table.insert(self.aimLine, display.newSprite("game/dian.png"):addTo(self):hide())
        end
        table.insert(self.aimLine, display.newSprite("game/focus.png"):addTo(self):hide())
    
    end

    self.labelValue = display.newTTFLabel({text = ""..FormatNumToString(self.cur_zi_dan_cost),
                                size = 24,
                                color = cc.c3b(255,224,20),
                                -- font = FONT_PTY_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
    :align(display.CENTER, cannon:getContentSize().width/2, 0)
    :addTo(cannon)
    self.labelValue:enableOutline(cc.c4b(0,0,0,255),2)

    local paoTai = ccui.ImageView:create("game/game_pao_tai_"..self.userInfo.memberOrder..".png");
    paoTai:setPosition(cc.p(cannon:getPositionX(),-13));
    self:addChild(paoTai,5)
    self.paoTai = paoTai;

    if self.mainPlayer then

    	local addBtn = ccui.Button:create("game/game_add_mult_bg.png")
    	addBtn:setPosition(cc.p(cannon:getContentSize().width/2+70,-22))
    	addBtn:setFlippedX(false)

        addBtn:onClick(
            function()
                if self.cur_zi_dan_cost < FishInfo.gameConfig.bulletMultipleMax then
                    self.cur_zi_dan_cost = self.cur_zi_dan_cost + self.per_add_coin
                end
                if self.cur_zi_dan_cost/self.per_add_coin >= 10 then
                    self.per_add_coin = self.per_add_coin * 10
                end
                if self.per_add_coin >= FishInfo.gameConfig.bulletMultipleMax then
                    self.per_add_coin = FishInfo.gameConfig.bulletMultipleMax
                end
                self.labelValue:setString(""..FormatNumToString(self.cur_zi_dan_cost))
                self.cannon:setPaoLevel(self:getFireGunLevel(self.cur_zi_dan_cost))
            end
        )

    	cannon:addChild(addBtn)

        local addSprite = display.newSprite("game/game_add_btn.png")
        addSprite:setPosition(cc.p(19,20))
        addBtn:addChild(addSprite)
    	
    	local multBtn = ccui.Button:create("game/game_add_mult_bg.png");
    	multBtn:setPosition(cc.p(cannon:getContentSize().width/2-70,-22));
    	multBtn:setFlippedX(true)

        multBtn:onClick(
            function()
                if self.cur_zi_dan_cost > FishInfo.gameConfig.bulletMultipleMin then
                    self.cur_zi_dan_cost = self.cur_zi_dan_cost - self.per_add_coin
                    --一旦减到0了就要缩小十倍，重新减
                    if self.cur_zi_dan_cost == 0 then
                        self.cur_zi_dan_cost = self.per_add_coin
                        self.per_add_coin = self.per_add_coin / 10
                        self.cur_zi_dan_cost = self.cur_zi_dan_cost - self.per_add_coin
                    end
                end
                if self.cur_zi_dan_cost/self.per_add_coin <= 0 then
                    self.per_add_coin = self.per_add_coin / 10
                end
                if self.per_add_coin <= FishInfo.gameConfig.bulletMultipleMin then
                    self.per_add_coin = FishInfo.gameConfig.bulletMultipleMin
                end
                self.labelValue:setString(""..FormatNumToString(self.cur_zi_dan_cost))
                self.cannon:setPaoLevel(self:getFireGunLevel(self.cur_zi_dan_cost))
                --减到够发一发子弹时删除破产图标
                if self.score > self.cur_zi_dan_cost and self.poSprite then
                    self.poSprite:removeFromParent()
                    self.poSprite = nil
                end
            end

    	)
    	cannon:addChild(multBtn)

    	local multSprite = display.newSprite("game/game_mult_btn.png")
    	multSprite:setPosition(cc.p(19,20))
    	multBtn:addChild(multSprite)

    end

	-- local numberLayer = require("core.rollNumGroup").new(8);
 --    numberLayer:setPosition(cc.p(200,-16));
 --    self.numberLayer = numberLayer;
 --    self:addChild(numberLayer);

    self.coin = cc.Sprite:create("common/ty_coin.png");
    self.coin:setPosition(cc.p(38, -20));
    self.coin:setAnchorPoint(cc.p(0,0.5));
    self:addChild(self.coin);

    self.numberLayer = display.newTTFLabel({text = ""..FormatNumToString(self.score),
                                size = 24,
                                color = cc.c3b(255,224,20),
                                -- font = FONT_PTY_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
    self.numberLayer:setPosition(70,-20)
    self.numberLayer:setAnchorPoint(cc.p(0,0.5));
    self.numberLayer:enableOutline(cc.c4b(0,0,0,255),2)
    self:addChild(self.numberLayer)

    if string.len(nickName) <= 0 then
        nickName = gameID
    end

    local label = display.newTTFLabel({text = FormotGameNickName(nickName,8),
                                size = 24,
                                color = cc.c3b(255,224,20),
                                -- font = FONT_PTY_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
    :align(display.CENTER, 88, 18)
    :addTo(self)
    label:enableOutline(cc.c4b(0,0,0,255),2)


    local winSize = cc.Director:getInstance():getWinSize();
    local points = {winSize.width/3-30, winSize.width/3*2+30, 50, winSize.height - 50};

	if seat == 1 then
		self:setPosition(cc.p(points[1], points[3]));
	elseif seat == 2 then
		self:setPosition(cc.p(points[2], points[3]));
	elseif seat == 3 then
		self:setPosition(cc.p(points[2], points[4]));
	elseif seat == 4 then
		self:setPosition(cc.p(points[1], points[4]));
	end


	if FLIP_FISH then
	    self:setRotation(180);
	    if seat <= 2 then
	    	self:specialForUp();
	    end
	else
		if seat > 2 then
			self:specialForUp();
		end
	end

    --破产
    if self.score < 100 then
        self:playPoChanAnimation()
    end

end

function Player:specialForUp() 

	self.cannon.model:setFlippedY(true);
	self.paoTai:setFlippedY(true);
	self.paoTai:setPositionY(self.paoTai:getPositionY() + 28);
	
	self.inUp = true;

    self.coin:setPosition(cc.p(20, -20))
    self.numberLayer:setPosition(52,-20)

end

function Player:fireToPonit(targetPt,withOutCD)
    if self.database.parent.myBulletCount>MAX_BULLET_COUNT then
        return;
    end


    withOutCD = withOutCD or false;
    if self.cannon:getCoolDownState()==false or withOutCD==true then
        self.score = self.score - self.cur_zi_dan_cost;
        if self.score < 0 then
            self.score = self.score + self.cur_zi_dan_cost;
            print("没钱了............................")
            self:playPoChanAnimation()
            --test
            -- self.cannon:rotationAndFire(targetPt,true,self.cur_zi_dan_cost);
        else
            self.cannon:rotationAndFire(targetPt,true,self.cur_zi_dan_cost,self.setLockFishSlow,withOutCD);
            self.numberLayer:setString(""..FormatNumToString(self.score))
        end
    end
end


function Player:fireToDirection(angle,cost)

    if FLIP_FISH then
        if self.seat <= 2 then
            self.cannon.model:setFlippedY(false);
        end
    else
        if self.seat > 2 then
            self.cannon.model:setFlippedY(false);
        end
    end

	if FLIP_FISH then
		angle = angle + 180;
	end
	local pos = cc.p(self.cannon:getPositionX(), self.cannon:getPositionY());
    local dis = 200;
    local targetPt = cc.p(pos.x + math.sin(math.rad(angle))*dis, pos.y + math.cos(math.rad(angle))*dis);
    targetPt = self:convertToWorldSpace(targetPt);
    self.cannon:rotationAndFire(targetPt,false,cost);

    --其他玩家的炮弹样式刷新
    self.cur_zi_dan_cost = cost
    self.labelValue:setString(""..FormatNumToString(cost))
    self.cannon:setPaoLevel(self:getFireGunLevel(self.cur_zi_dan_cost))

    self.score = self.score - self.cur_zi_dan_cost;
    if self.score < 0 then
        self.score = self.score + self.cur_zi_dan_cost;
        print("同桌其他玩家没钱了............................")
        self:playPoChanAnimation()
    else
        self.numberLayer:setString(""..FormatNumToString(self.score))
    end

    if self.cannon.model:isFlippedY() then
        self.cannon.paokou_ani:setPosition(cc.p(self.cannon.model:getContentSize().width/2,10))
    end
	
end

--kind 鱼的类型; fishMulti 鱼的倍数
function Player:changeScore(score, kind, fishMulti)

    if score and score > 0 and fishMulti and fishMulti>0 then
        self.score = self.score + score;
        -- self.numberLayer:setValue(self.score);
        self.numberLayer:setString(""..FormatNumToString(self.score))
        self:showScoreAnimation(score, kind, fishMulti)

        local _singleScore=score/fishMulti;
        if fishMulti>50 then
            for i=1, math.ceil(fishMulti/50) do

                if fishMulti>50 then
                    fishMulti=fishMulti-50
                    score=score-_singleScore*50
                    if i==1 then
                        self:getCoinAnimation(50,_singleScore*50,(i-1)%5)
                    else
                        self:performWithDelay(function()
                            self:getCoinAnimation(50,_singleScore*50,(i-1)%5)
                            end,0.2*(i-1));
                    end
                else
                    if i==1 then
                        self:getCoinAnimation(fishMulti,score,(i-1)%5)
                    else
                        self:performWithDelay(function()
                            self:getCoinAnimation(fishMulti,score,(i-1)%5)
                            end,0.2*(i-1));
                    end
                end
            end

        else
            self:getCoinAnimation(fishMulti,score,0)
        end

        --够发一发子弹时删除破产图标
        if self.score > self.cur_zi_dan_cost and self.poSprite then
            self.poSprite:removeFromParent()
            self.poSprite = nil
        end
    end

end

function Player:showScoreAnimation(score, kind, fishMulti)
    --代表大鱼
    if score and score > 0 then
        if kind and kind > 10 then
            self.scoreHighAni = self:getScoreHighAnimation()
            if self.scoreHighAni then
                self.scoreHighAni:setPosition(cc.p(self.cannon:getContentSize().width+100,self.cannon:getContentSize().height+140))
                self.cannon:addChild(self.scoreHighAni)
                self.scoreHighAni:getAnimation():playWithIndex(0)

                if FLIP_FISH then
                    if self.seat <= 2 then
                        self.scoreHighAni:setPosition(cc.p(self.cannon:getContentSize().width+100,-self.cannon:getContentSize().height-140))
                    end
                else
                    if self.seat > 2 then
                        self.scoreHighAni:setPosition(cc.p(self.cannon:getContentSize().width+100,-self.cannon:getContentSize().height-140))
                    end
                end
                -- if self.cannon.model:isFlippedY() then
                --     self.scoreHighAni:setPosition(cc.p(self.cannon:getContentSize().width+100,-self.cannon:getContentSize().height-140))
                -- end

                -- 20倍以上 显示倍数
                local posY_offset=0;
                if fishMulti>=20 then
                    local multi = display.newTTFLabel({text = " "..fishMulti.." 倍！",
                                                    size = 28,
                                                    color = cc.c3b(255,255,100),
                                                    font = FONT_PTY_TEXT,
                                                    align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                                })
                    multi:enableOutline(cc.c4b(141,0,166,255*0.7),2)
                    multi:setPosition(cc.p(self.scoreHighAni:getContentSize().width/2-140+10, self.scoreHighAni:getContentSize().height/2-140+36))
                    self.scoreHighAni:addChild(multi,100)
                    posY_offset=5;

                    local sequence = transition.sequence(
                        {
                            cc.DelayTime:create(2.4),
                            cc.CallFunc:create(function() multi:removeFromParent();end)
                        }
                    )
                    multi:runAction(sequence)
                end
                --加个label
                local content = display.newTTFLabel({text = "+"..score,
                                                    size = 40,
                                                    color = cc.c3b(255,255,100),
                                                    font = FONT_PTY_TEXT,
                                                    align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                                })
                content:enableOutline(cc.c4b(141,0,166,255*0.7),2)
                content:setPosition(cc.p(self.scoreHighAni:getContentSize().width/2-140, self.scoreHighAni:getContentSize().height/2-140-posY_offset))
                self.scoreHighAni:addChild(content,100)

                local sequence = transition.sequence(
                    {
                        cc.DelayTime:create(2.4),
                        cc.CallFunc:create(function() content:removeFromParent();end)
                    }
                )
                content:runAction(sequence)
            end

            if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
                audio.playSound("sound/rolling.mp3");
            end

            if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
                audio.playSound("sound/coins.mp3");
            end

        else
            --随机一个x,y值给label
            local randomX = math.random(-30,30)
            local randomY = math.random(-30,30)

            local textColor = cc.c3b(255,255,100)
            if self.mainPlayer then
                textColor = cc.c3b(255,224,20)
            end

            --获得金币数目飞入口袋
            local content = display.newTTFLabel({text = "+"..score,
                                                size = 40,
                                                color = textColor,
                                                font = FONT_PTY_TEXT,
                                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                            })
            content:enableOutline(cc.c4b(141,0,166,255*0.7),2)
            content:setPosition(cc.p(self.cannon:getContentSize().width/2+randomX, self.cannon:getContentSize().height+200+randomY))
            self.cannon:addChild(content)

            if FLIP_FISH then
                if self.seat <= 2 then
                    content:setPosition(cc.p(self.cannon:getContentSize().width/2+randomX, -self.cannon:getContentSize().height-200-randomY))
                end
            else
                if self.seat > 2 then
                    content:setPosition(cc.p(self.cannon:getContentSize().width/2+randomX, -self.cannon:getContentSize().height-200-randomY))
                end
            end
            -- if self.cannon.model:isFlippedY() then
            --     content:setPosition(cc.p(self.cannon:getContentSize().width/2+randomX, self.cannon:getContentSize().height-200+randomY))
            -- end

            local moveto = cc.MoveTo:create(0.6, cc.p(self.numberLayer:getPositionX(),self.numberLayer:getPositionY()));
            local easeAction = cc.EaseExponentialIn:create(moveto);

            local sequence = transition.sequence(
                {
                    cc.Sequence:create(easeAction),
                    cc.CallFunc:create(
                        function()
                            content:removeFromParent();
                            --label放大一下
                            local sequence = transition.sequence(
                                {
                                    cc.ScaleTo:create(0.1, 1.2),
                                    cc.ScaleTo:create(0.1, 1.0)
                                }
                            )                        
                            self.numberLayer:runAction(sequence)
                        end
                    )
                }
            )
            content:runAction(sequence)

            if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
                audio.playSound("sound/coin.mp3");
            end
        end
    else
        print("出错了 .............. score 为 0 .......")
    end
end

-- function Player:getFireGunLevel(gunNumber)
--     local bullet_kinds = 1
--     if(gunNumber< FishInfo.gameConfig.bulletMultipleMin*10) then
--         bullet_kinds = 1
--     elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*100 then
--          bullet_kinds = 2
--     elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*1000 then
--          bullet_kinds = 3
--     elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*10000 then
--          bullet_kinds = 4
--     end
--     return bullet_kinds;
-- end

function Player:getFireGunLevel(gunNumber)
    local bullet_kinds = 1
    if gunNumber < 100 then
        bullet_kinds = 1
    elseif gunNumber < 1000 then
         bullet_kinds = 2
    elseif gunNumber < 10000 then
         bullet_kinds = 3
    elseif gunNumber <= 100000 then
         bullet_kinds = 4
    end
    return bullet_kinds;
end

function Player:getScoreHighAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("eff_zhuanpan") == nil then
        manager:addArmatureFileInfo("effect/score_high/eff_zhuanpan0.png","effect/score_high/eff_zhuanpan0.plist","effect/score_high/eff_zhuanpan.ExportJson")
    end
    local armature = ccs.Armature:create("eff_zhuanpan")
    return armature;
end

function Player:showAimLine()
    if self.score <= 0 then
        self:hideAimLine()
        return
    end

    local x, y = self.lockFish:getPosition()
    local pos = self.lockFish:getParent():convertToWorldSpace(cc.p(x,y))
    local newPos = self:convertToNodeSpace(pos)
    local sx,sy = self.cannon:getPosition()
    local disX = (newPos.x-sx)/8
    local disY = (newPos.y-sy)/8
    for k,v in ipairs(self.aimLine) do
        v:show()
        v:setPosition(cc.p(sx+disX*(k+1), sy+disY*(k+1)))
    end

    --vip5以上开启锁定减速
    if self.userInfo and self.userInfo.memberOrder and self.userInfo.memberOrder >= 5 then
        self.setLockFishSlow = true
    end
end

function Player:hideAimLine()
    for k,v in ipairs(self.aimLine) do
        v:hide()
    end
    self.setLockFishSlow = false
end

--堆币动画
function Player:getCoinAnimation(num,score,index)

    if not num then
        print("出错了:鱼的倍数num为nil............")
        return
    end
    local offset=index*30;
    -- if num < 10 then
    --     -- print("打中10倍以下的鱼不堆币")
    --     return
    -- end

    if num > 50 then
        num = 50
    end

    local size = cc.size(37,8)

    local container = ccui.ImageView:create("blank.png");
    container:setScale9Enabled(true);
    container:setContentSize(cc.size(size.width,size.height*num));
    container:setAnchorPoint(cc.p(0,0))
    container:setPosition(-220-offset, -40)
    self:addChild(container,10000)

    if FLIP_FISH then
        if self.seat <= 2 then
            container:setFlippedY(true)
            container:setPositionY(40)
        end
    else
        if self.seat > 2 then
            container:setFlippedY(true)
            container:setPositionY(40)
        end
    end

    for i=1,1 do
        local bgSprite = display.newSprite("game/game_spec_coin.png")
        bgSprite:setAnchorPoint(cc.p(0.5,0))
        bgSprite:setPosition(size.width/2, (i-1)*size.height)
        container:addChild(bgSprite)
    end

    local start = 1

    local callFunc = function()
        start = start + 1
        if start <= num then
            local bgSprite = display.newSprite("game/game_spec_coin.png")
            bgSprite:setAnchorPoint(cc.p(0.5,0))
            bgSprite:setPosition(size.width/2, (start-1)*size.height)
            container:addChild(bgSprite)

            if start == num then
                local number = display.newTTFLabel({text = ""..FormatNumToString(score),
                                                    size = 24,
                                                    color = cc.c3b(255,224,20),
                                                    -- font = FONT_PTY_TEXT,
                                                    align = cc.ui.TEXT_ALIGN_CENTER
                                                })
                number:setPosition(size.width/2, start*size.height+5)
                number:setAnchorPoint(cc.p(0.5,0));
                number:enableOutline(cc.c4b(0,0,0,255),2)
                container:addChild(number)
            end            
        else
            container:stopAllActions()
            local sequence = transition.sequence(
                {
                    cc.Sequence:create(cc.MoveBy:create(1.0, cc.p(140,0))),
                    cc.DelayTime:create(0.3),
                    cc.CallFunc:create(
                        function()
                            container:removeFromParent();
                        end
                    )
                }
            )
            container:runAction(sequence)
            if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
                audio.playSound("sound/sound_coin.mp3");
            end
        end
    end

    local sequence = transition.sequence(
        {
            cc.DelayTime:create(0.01),
            cc.CallFunc:create(callFunc)
        }
    )
    container:runAction(cc.RepeatForever:create(sequence))

end

function Player:playPoChanAnimation()
    if not self.poSprite then
        self.poSprite = display.newSprite("game/game_po_chan.png")
        self.poSprite:setPosition(-66, 36)
        self.poSprite:setScale(2.0)
        self:addChild(self.poSprite,100)
        self.poSprite:hide()

        local sequence = transition.sequence(
            {
                cc.CallFunc:create(function() self.poSprite:show() end),
                cc.ScaleTo:create(0.1,1.0),
                cc.CallFunc:create(function() self.poSprite:show() end)
            }
        )
        self.poSprite:runAction(sequence)
    end
end

function Player:popSelectPaoLayer()
    if OnlineConfig_review == "off" then
        if self.paoLayer then
            self.paoLayer:removeFromParent()
            self.paoLayer = nil
        else
            if self.userInfo.memberOrder >= 5 then
                Hall.showTips("您已达到顶级炮台!")
            else
                self.paoLayer = require("popView.selectPaoLayer").new(self)
                self.paoLayer:setPosition(-150, 50)
                self:addChild(self.paoLayer,100)
            end
        end
    end
end

function Player:refreshScore(score)
    self.score = score
    self.numberLayer:setString(""..FormatNumToString(self.score))
    if self.score > self.cur_zi_dan_cost and self.poSprite then
        self.poSprite:removeFromParent()
        self.poSprite = nil
    end
end

return Player;
