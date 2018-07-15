local MarriageInfo = class("MarriageInfo",function ()
	return display.newLayer()
end)
function MarriageInfo:ctor(huntMarriage)
	self:createUI(huntMarriage)
end
function MarriageInfo:createUI(huntMarriage)
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);
	--外框
	local frame = display.newScale9Sprite("view/frame3.png", display.cx, display.cy, cc.size(595, 310), cc.rect(60, 60, 20, 20))
	           :addTo(self)
				:align(display.CENTER, display.cx, display.cy)
	self.frame = frame
	--内框
	local frame2 = display.newScale9Sprite("view/frame2.png", 105, 160, cc.size(168, 243), cc.rect(20, 20, 10, 10))
	:addTo(frame)

    --头像👦
    local headView = require("commonView.GameHeadView").new(1);
    headView:addTo(frame2)
    headView:align(display.CENTER, 90, 170)
    self.headView = headView

    --self.icon:setGlobalZOrder(-1)
    self.txtName = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 90, 95)
                :addTo(frame2)
    self.txtID = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 90, 65)
                :addTo(frame2)
    
    self.txtSex = display.newTTFLabel({text = "性别：",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 80, 30)
                :addTo(frame2)
    local picSex = ccui.ImageView:create()
    picSex:setPosition(130, 30)
    frame2:addChild(picSex)
    self.picSex = picSex

	--关闭按钮
    local button = ccui.Button:create("view/btn_close.png");
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:close()
                SoundManager.playSound("sound/buttonclick.mp3")
            end
        end
        )
    button:addTo(frame)
    button:align(display.CENTER, 580, 295)



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
        :align(display.CENTER, 245+170, 255)
    sprite:setScale(1.25)
    self.txtML = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 245+170+30, 255)
                :addTo(frame)
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        sprite:hide()
    end                  

    



    --经验条
    local userInfo = DataManager:getMyUserInfo()
    local bg = display.newScale9Sprite("hall/personalCenter/level_bg.png", 0, 0, cc.size(60, 28))
    bg:addTo(frame)
    bg:align(display.LEFT_BOTTOM, 215, 195)

    local level = "LV." .. getLevelByExp(userInfo.medal)
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

    local expBG = display.newSprite("hall/personalCenter/exp_background.png"):addTo(frame)
    expBG:align(display.LEFT_BOTTOM, 280, 195)
    self.expProgress = display.newProgressTimer("hall/personalCenter/exp_now.png", display.PROGRESS_TIMER_BAR):addTo(frame)
    self.expProgress:align(display.LEFT_BOTTOM, 280, 195)
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
    level:addTo(self.expProgress):align(display.CENTER, 140, 14)
    self.expDesc = level

    --彩礼
    local caili = FormatNumToString(huntMarriage.lGiftForMarry)
    local needGold = ccui.Text:create("要求彩礼："..caili,"",22)
    needGold:setAnchorPoint(cc.p(0,0))
    needGold:setPosition(215, 146)
    needGold:setColor(cc.c3b(255, 255, 128))
    frame:addChild(needGold)
    local lv = getLevelByExp(huntMarriage.dwTargetUserLevel)
    local needLevel = ccui.Text:create("要求等级："..lv,"",22)
    needLevel:setAnchorPoint(cc.p(0,0))
    needLevel:setPosition(400, 146)
    needLevel:setColor(cc.c3b(255, 255, 128))
    frame:addChild(needLevel)
    --身家
    local treasure = FormatNumToString(huntMarriage.lTargetUserGold)
    local needTreasure = ccui.Text:create("要求身家："..treasure,"",22)
    needTreasure:setAnchorPoint(cc.p(0,0))
    needTreasure:setPosition(215, 114)
    needTreasure:setColor(cc.c3b(255, 255, 128))
    frame:addChild(needTreasure)
    --婚姻时间
    local lefttime = huntMarriage.dwTimeLimit
    local minute = lefttime%60
    local hour = (lefttime-minute)/60%24
    local day = ((lefttime-minute)/60-hour)/24
    local leftTimeTxt = day.."天"..hour.."小时"..minute.."分"

    local lastTime = ccui.Text:create("愿意保持婚姻时间："..leftTimeTxt,"",22)
    lastTime:setAnchorPoint(cc.p(0,0))
    lastTime:setColor(cc.c3b(255, 255, 128))
    lastTime:setPosition(215, 86)
    frame:addChild(lastTime)
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
end
function MarriageInfo:setIcon(id, tokenID,headFileMd5)
    self.headView:setNewHead(id, tokenID,headFileMd5)
end

function MarriageInfo:setName(name)
	self.txtName:setString(FormotGameNickName(name,5))
end

function MarriageInfo:setID(ID)
    self.txtID:setString(tostring(ID))

end

function MarriageInfo:setHLD(dd)
    if self.txtHLD then
        self.txtHLD:setString(FormatNumToString(dd))
    end    
end
function MarriageInfo:setLQ(lq,isshow)
    self.txtLQ:setString(FormatNumToString(lq))
    if isshow ~= nil and isshow == false then
        self.txtLQ:hide()
        self.imgLQ:hide()
    else
        self.txtLQ:show()
        self.imgLQ:show()
    end
end
function MarriageInfo:setGold(gold)
    if self.txtGOLD then
        self.txtGOLD:setString(FormatNumToString(gold))
    end
    
end
function MarriageInfo:setML(ml)
    self.txtML:setString(FormatNumToString(ml))
end
function MarriageInfo:setMaxGold(gold)
    self.txtZGJE:setString(FormatNumToString(gold).."金币")
end
function MarriageInfo:setUnderWrite(underWrite)
    if underWrite == nil or underWrite == "" then
        underWrite = "尚未编辑个性签名。"
    end
    local re2 = ccui.RichElementText:create(2, cc.c3b(255, 255, 255), 255, underWrite, "Helvetica", 22)
    self.txtUnderWrite:removeElement(1)
    self.txtUnderWrite:pushBackElement(re2)
    self.txtUnderWrite:formatText()
end

--todo
function MarriageInfo:setLevelInfo(medal)

    local levelInfo = getLevelInfo(medal)

    self.level:setString("LV." .. levelInfo.level)
    
    self.expProgress:setPercentage(100*levelInfo.curNextLevelExp/levelInfo.nextLevelExp)
    self.expDesc:setString(levelInfo.curNextLevelExp .. "/" .. levelInfo.nextLevelExp)
end

function MarriageInfo:setSex(sex)
    if sex == 1 then
        -- self.txtSex:setString("性别：男")
        self.picSex:loadTexture("common/man.png")
    else
        -- self.txtSex:setString("性别：女")
        self.picSex:loadTexture("common/woman.png")
    end
end

function MarriageInfo:setVip(vip)

    local VIP_LABEL = {
    "绿钻VIP",
    "蓝钻VIP",
    "紫钻VIP",
    "金钻VIP",
    "王冠VIP",
    }
    self.headView:setVipHead(vip)

end
function MarriageInfo:close()
	self:removeFromParent()
end
return MarriageInfo