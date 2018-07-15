--
-- Author: <zhaxun>
-- Date: 2015-05-29 15:58:23
--


local ViewPlayerInfo = class( "ViewPlayerInfo", require("ui.CCModelView"))

function ViewPlayerInfo:ctor(param)
    self.super.ctor(self);

    self.isHappyBeans = param[1]
    self.userIndex = param[2]
	--外框
	local frame = display.newScale9Sprite("common/pop_bg.png", display.cx, display.cy, cc.size(595, 310))
	           :addTo(self)
				:align(display.CENTER, DESIGN_WIDTH/2,DESIGN_HEIGHT/2)
	self.frame = frame
	--内框
	local frame2 = display.newScale9Sprite("common/panel.png", 105, 155, cc.size(168, 243), cc.rect(20, 20, 10, 10))
	:addTo(frame)

    --头像
    local headView = require("commonView.HeadView").new(1);
    headView:addTo(frame2)
    headView:align(display.CENTER, 85, 170)
    headView:setScale(0.89)
    self.headView = headView

    --self.icon:setGlobalZOrder(-1)
    self.txtName = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 85, 85)
                :addTo(frame2)
    self.txtID = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 85, 65)
                :addTo(frame2)
    self.txtID:setVisible(false)
    
    self.txtSex = display.newTTFLabel({text = "性别：",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 70, 35)
                :addTo(frame2)
    local picSex = ccui.ImageView:create()
    picSex:setPosition(130, 30)
    frame2:addChild(picSex)
    picSex:setScale(0.7)
    self.picSex = picSex

	--关闭按钮
    local button = ccui.Button:create("common/close.png");
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickClose()
                SoundManager.playSound("sound/buttonclick.mp3")
            end
        end
        )
    button:addTo(frame)
    button:align(display.CENTER, 580, 295)

    --huanledou
    local sprite = ccui.ImageView:create("common/huanledou.png")
        :addTo(frame)
        :align(display.CENTER, 245, 255)
    self.spHLD = sprite
    self.txtHLD = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 245+30, 255)
                :addTo(frame)

    --JINBI  
    local sprite = ccui.ImageView:create("common/gold.png")
        :addTo(frame)
        :align(display.CENTER, 245, 255)--+170
    self.spGOLD = sprite
    self.txtGOLD = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 245+30, 255)--+170
                :addTo(frame)

    --meili
    local sprite = display.newSprite("common/loveliness.png")
        :addTo(frame)
        :align(display.CENTER, 255+170, 255)
    sprite:setScale(1.25)
    self.txtML = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 255+170+30, 255)
                :addTo(frame)
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        sprite:hide()
    end            
    --liquan
    local sprite = display.newSprite("common/ty_lq_icon.png")
        :addTo(frame)
        :align(display.CENTER, 245, 195)--+170
    self.txtLQ = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 245+30, 195)--+170
                :addTo(frame)
    self.imgLQ = sprite
    -- if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        self.imgLQ:hide()
        self.txtLQ:hide()
    -- end            

    --因为隐藏了礼券而把下面的元素拔高的基准值
    local heightadd = 50
    --zuigaojine
    display.newTTFLabel({text = "历史最高金额：  ",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_BOTTOM, 215, 132 + heightadd)
                :addTo(frame)
                --:hide()
    self.txtZGJE = display.newTTFLabel({text = "即将到来",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                align = cc.ui.TEXT_ALIGN_LEFT -- 文字内部居中对齐
                            })
                :align(display.LEFT_BOTTOM, 370, 132 + heightadd)
                :addTo(frame)
                --:hide()

    --会员
    -- display.newTTFLabel({text = "会员  ",
    --                             size = 24,
    --                             color = cc.c3b(255,255,128),
    --                             --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
    --                         })
    --             :align(display.LEFT_BOTTOM, 215, 60)
    --             :addTo(frame)
    --             --:hide()
    -- self.txtVIP = display.newTTFLabel({text = "金冠VIP",
    --                             size = 24,
    --                             color = cc.c3b(255,255,128),
    --                             align = cc.ui.TEXT_ALIGN_LEFT -- 文字内部居中对齐
    --                         })
    --             :align(display.LEFT_BOTTOM, 270, 60)
    --             :addTo(frame)
    --             --:hide()

    --经验条
    local bg = display.newScale9Sprite("hall/personalCenter/level_bg.png", 0, 0, cc.size(60, 28))
    bg:addTo(frame)
    bg:align(display.LEFT_BOTTOM, 215, 90 + heightadd * 0.6)

    local level = "LV.1"
    level = display.newTTFLabel({
            text = level,
            color = cc.c3b(255, 255, 255),
            size = 24,
            --strokeWidth = 2,
            align  = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
    level:addTo(bg):align(display.LEFT_CENTER, 0, 12)
    self.level = level

    --官衔
    -- local guanxian = ccui.Text:create("村委主任", "", 22);
    -- guanxian:setColor(cc.c3b(255,255,130));
    -- --guanxian:setAnchorPoint(cc.p(0,0.5));
    -- guanxian:setPosition(cc.p(330, 105));
    -- frame:addChild(guanxian);
    -- self.guanxian = guanxian;

    self.guanxian = require("hall.GuanXianLayer").new({exp=0, c3b=cc.c3b(255,255,130)})
    self.guanxian:setPosition(cc.p(330, 105 + heightadd * 0.6));
    frame:addChild(self.guanxian);


    local expBG = display.newSprite("hall/personalCenter/exp_background.png"):addTo(frame)
    expBG:align(display.LEFT_BOTTOM, 380, 90 + heightadd * 0.6)
    self.expProgress = display.newProgressTimer("hall/personalCenter/exp_now.png", display.PROGRESS_TIMER_BAR):addTo(frame)
    self.expProgress:align(display.LEFT_BOTTOM, 380, 90 + heightadd * 0.6)
    self.expProgress:setMidpoint(cc.p(0, 0.5))
    self.expProgress:setBarChangeRate(cc.p(1.0, 0))
    self.expProgress:setPercentage(50)
    --local expCurrent = display.newProgressTimer("hall/personalCenter/exp_add.png", display.PROGRESS_TIMER_BAR)
    
    level = display.newTTFLabel({
            text = "27/156",
            color = cc.c3b(255, 255, 128),
            size = 24,
            --strokeWidth = 2,
            align  = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
    level:addTo(self.expProgress):align(display.CENTER, 97, 14)
    self.expDesc = level

    --个性签名
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(cc.size(360, 55))
    local re1 = ccui.RichElementText:create(1, cc.c3b(255,255,128), 255, "个性签名：", "Helvetica", 22)
    local re2 = ccui.RichElementText:create(2, cc.c3b(255, 255, 255), 255, "", "Helvetica", 22)
    richText:pushBackElement(re1)
    richText:pushBackElement(re2)
    richText:setPosition(cc.p(392, 50))
    frame:addChild(richText)
    self.txtUnderWrite = richText
    self:refreshByIndex(param)
end
function ViewPlayerInfo:refreshByIndex(param)
    self.isHappyBeans = param[1]
    self.userIndex = param[2]
    if self.isHappyBeans and self.userIndex ~= 0 then
        self.txtHLD:show()
        self.txtGOLD:hide()
        self.spHLD:show()
        self.spGOLD:hide()
        self.spHLD:loadTexture("common/huanledou.png")
        self.spGOLD:loadTexture("common/huanledou.png")
    else
        self.txtHLD:hide()
        self.txtGOLD:show()
        self.spHLD:hide()
        self.spGOLD:show()
        self.spHLD:loadTexture("common/gold.png")
        self.spGOLD:loadTexture("common/gold.png")
    end
end
function ViewPlayerInfo:onClickClose()
	print("ViewPlayerInfo:onClickClose")
    self:removeSelf()
end

function ViewPlayerInfo:setIcon(id, tokenID,headFileMd5)
    self.headView:setNewHead(id, tokenID,headFileMd5)
end

function ViewPlayerInfo:setName(name)
	self.txtName:setString(FormotGameNickName(name,5))
end

function ViewPlayerInfo:setID(ID)
    self.txtID:setString(tostring(ID))

end

function ViewPlayerInfo:setHLD(dd)
    if self.txtHLD then
        self.txtHLD:setString(FormatNumToString(dd))
    end    
end
function ViewPlayerInfo:setLQ(lq,isshow)
    self.txtLQ:setString(FormatNumToString(lq))
    if isshow ~= nil and isshow == false then
        self.txtLQ:hide()
        self.imgLQ:hide()
    else
        -- self.txtLQ:show()
        -- self.imgLQ:show()
    end
end
function ViewPlayerInfo:setGold(gold)
    if self.txtGOLD then
        self.txtGOLD:setString(FormatNumToString(gold))
    end
    
end
function ViewPlayerInfo:setML(ml)
    self.txtML:setString(FormatNumToString(ml))
end
function ViewPlayerInfo:setMaxGold(gold)
    self.txtZGJE:setString(FormatNumToString(gold).."金币")
end
function ViewPlayerInfo:setUnderWrite(underWrite)
    if underWrite == nil or underWrite == "" then
        underWrite = "尚未编辑个性签名。"
    end
    local re2 = ccui.RichElementText:create(2, cc.c3b(255, 255, 255), 255, underWrite, "Helvetica", 22)
    self.txtUnderWrite:removeElement(1)
    self.txtUnderWrite:pushBackElement(re2)
    self.txtUnderWrite:formatText()
end

--todo
function ViewPlayerInfo:setLevelInfo(medal)

    local levelInfo = getLevelInfo(medal)

    self.level:setString("LV." .. levelInfo.level)
    
    self.expProgress:setPercentage(100*levelInfo.curNextLevelExp/levelInfo.nextLevelExp)
    self.expDesc:setString(levelInfo.curNextLevelExp .. "/" .. levelInfo.nextLevelExp)

    self.guanxian:refreshGuanXian(levelInfo.curNextLevelExp)
end

function ViewPlayerInfo:setSex(sex)
    if sex == 1 then
        -- self.txtSex:setString("性别：男")
        self.picSex:loadTexture("common/sex1.png")
    else
        -- self.txtSex:setString("性别：女")
        self.picSex:loadTexture("common/sex0.png")
    end
end

function ViewPlayerInfo:setVip(vip)

    local VIP_LABEL = {
    "绿钻VIP",
    "蓝钻VIP",
    "紫钻VIP",
    "金钻VIP",
    "王冠VIP",
    }
    self.headView:setVipHead(vip)
    -- if vip > 0 and vip <=5 then
    --     self.txtVIP:setString(VIP_LABEL[vip])
    -- else
    --     self.txtVIP:setString("普通会员")
    -- end
end

function ViewPlayerInfo:onEnter()

end

function ViewPlayerInfo:onExit()

end

-- 区域选牌
function ViewPlayerInfo:onTouchHandler(event)

    --local name, x, y, prevX, prevY = event.name, event.x, event.y, event.prevX, event.prevY
    if event.name == "began" then
        print("onTouchHandler---began")
		if not cc.rectContainsPoint(self.frame:getBoundingBox(), cc.p(event.x,event.y)) then
			self:hide()
		end
        
        return cc.TOUCH_BEGAN_NO_SWALLOWS -- continue event dispatching

    elseif event.name == "moved" then
        

    elseif event.name == "ended" then


    end
end


return ViewPlayerInfo