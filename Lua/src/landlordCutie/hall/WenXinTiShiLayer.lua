--温馨提示
local WenXinTiShiLayer = class("WenXinTiShiLayer", function() return display.newLayer() end)
_WenXinTiShiLayer = nil


WenXinTiShiLayer.kind = 1--1
WenXinTiShiLayer.lefttime = 0
WenXinTiShiLayer.curRoomIndex = false--1无限场2初级场3中级场4高级场
SystemNoticeType = 
{
    SystemNoticeType_Enter_Bean_Receive_Alms    = 0,    -- 欢乐豆场 进入时 破产补助 通知
    SystemNoticeType_Bust_Bean_Receive_Alms     = 1,    -- 欢乐豆场 破产时 破产补助 通知
    SystemNoticeType_Bust_Bean                  = 2,    -- 欢乐豆场 补助次数用完时 通知
    SystemNoticeType_Enter_Gold_Receive_Alms    = 3,    -- 金币场 进入时 破产补助 通知
    SystemNoticeType_Bust_Gold_Receive_Alms     = 4,    -- 金币场 破产时 破产补助 通知
    SystemNoticeType_Bust_Gold                  = 5,    -- 金币场 补助次数用完时 通知
    SystemNoticeType_Wealth_Overflow            = 6,    -- 用户财富超过最大准入时 通知
    SystemNoticeType_FristRegister_Alms         = 7,    -- 注册用户 给初始补助 通知
    ClientNoticeType_goNextRoom                 = 100,    -- 转战中（高）级场
    SystemNoticeType_Regular_Customer           = 8,    -- 斗地主老用户导入后 元宝转换为金币
    SystemNoticeType_BeanServer_Gold_Limit      = 9,    -- 斗地主欢乐豆场 最大金币限制
    SystemNoticeType_BeanRank_Win_Notice        = 10,   -- 斗地主欢乐豆场 排名 获奖通知
};
function WenXinTiShiLayer:ctor(params,tipStr,curRoomIndex)
	-- body
	self.kind = params
	self.tipStr = tipStr or ""
    self.curRoomIndex = curRoomIndex or false
        
    self:createUI(params,self.tipStr)

    -- if SystemNoticeType.SystemNoticeType_BeanRank_Win_Notice == self.kind then
    --     self:createRankingBeanUI(self.tipStr)
    -- else
    --     self:createUI(params,self.tipStr)
    -- end
end
function WenXinTiShiLayer:getInstance()
    if _WenXinTiShiLayer == nil then
        _WenXinTiShiLayer = WenXinTiShiLayer:new()
    end
    return _WenXinTiShiLayer
end

function WenXinTiShiLayer:createRankingBeanUI(tipStr)

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    --外框
    local frame = display.newScale9Sprite("view/frame3.png", display.cx, display.cy, cc.size(590, 255), cc.rect(60, 60, 20, 20))
               :addTo(self)
            :align(display.CENTER, display.cx, display.cy)


    --content
    local content = display.newTTFLabel({text = tipStr,
                                size = 22,
                                color = cc.c3b(255,255,130),
                                --font = "sxslst.ttf",
                                dimensions = cc.size(425, 60),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_TOP, 50, 170)
                :addTo(frame)


end

function WenXinTiShiLayer:createUI(kind,tipStr)
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);
    local tipArray = {
    		"您的欢乐豆数量为800，本场至少需要1000才\n能参加，再坚持一会，系统君正带着3000欢乐\n豆赶来救你",
    		"系统君正赶来为您提供3000欢乐豆，再坚持一会儿",
    		"您的欢乐豆数量为800，本场至少需要1000才能参加！",
    		"尊贵的绿钻VIP用户，您的金币数量为800，本场至少需要1000才能参加，是否领取系统为您赠送的2000（每天一次）金币破产补助",
    		"尊贵的绿钻VIP用户，系统为您提供1000金币破产补助（每天一次），祝您鸿运大发哦",
    		"客官，看你骨骼惊奇，是块斗地主的好料，初级场不适合你，还是去中（高）场去看看吧。",
    		"客官，经过初级场的磨练，您已经大有作为，快去中级场继续战斗吧。",
    		"客官，您已经是大师级别了，这里已经不适合您，还是去高级场大展身手吧。",
    		"客官，我果然没看错你，高手场才是您真正应该战斗的地方",
    		"客官，您的金币低于50000，本场要高于50000才能参与"
		}
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    -- bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(674,433));
    bgSprite:setPosition(cc.p(588,320));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(593,210));
    panel:setPosition(589, 348)
    self:addChild(panel)

    local title = ccui.ImageView:create("common/pop_title.png")
    title:setPosition(391, 498)
    self:addChild(title)
    local word = display.newTTFLabel({text = "温馨提示",
                                size = 24,
                                color = cc.c3b(255,233,110),
                                font = FONT_ART_TEXT,
                            })
                :addTo(self)
    word:setPosition(388, 520)
    word:setTextColor(cc.c4b(251,248,142,255))
    word:enableOutline(cc.c4b(137,0,167,200), 2)
    -- local rolePic = ccui.ImageView:create("hall/login/landlord.png")
    -- rolePic:setPosition(250, 320)
    -- self:addChild(rolePic)
    -- rolePic:setScale(0.5631)
    -- self.rolePic = rolePic

    -- local goods = ccui.ImageView:create("hall/pochan/golds.png")
    -- goods:setPosition(561, 295)
    -- self:addChild(goods)

    local tiptxt = ccui.Text:create()
    tiptxt:setPosition(584,377)--(628, 333)
    tiptxt:setFontSize(25)
    -- tipStr = "尊贵的绿钻VIP用户，您的金币数量为800，本场至少需要1000才能参加，是否领取系统为您赠送的2000（每天一次）金币破产补助"
    local tipword = tipStr
    
    self.tiptxt = tiptxt;

    if SystemNoticeType.SystemNoticeType_Bust_Bean_Receive_Alms == kind or SystemNoticeType.SystemNoticeType_Enter_Bean_Receive_Alms == kind then
    	--todo
        panel:setContentSize(cc.size(593,183));
        panel:setPosition(589, 361)
        local dropbtn = ccui.Button:create("common/common_button4.png","common/common_button4.png")
        dropbtn:setScale9Enabled(true)
        dropbtn:setContentSize(cc.size(240,70))
        dropbtn:setPosition(466, 189)
        dropbtn:setZoomScale(0.1)
        dropbtn:setPressedActionEnabled(true)
        dropbtn:setTitleText("马上获取欢乐豆")
        dropbtn:setTitleFontSize(30)
        dropbtn:setTitleFontName(FONT_ART_BUTTON)
        dropbtn:setTitleColor(cc.c4b(255, 255, 255,255))
        dropbtn:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2)
        dropbtn:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:dropHandler(sender)
                end
            end
            )
        self:addChild(dropbtn)

        local tiptxt2 = ccui.Text:create()
        tiptxt2:setPosition(740, 251)
        tiptxt2:setFontSize(22)
        tiptxt2:setColor(cc.c3b(255, 255, 0))
        self:addChild(tiptxt2)
        tiptxt2:setString("还有      就到了，坚持住！")
        self.tiptxt2 = tiptxt2;

        local countdown = ccui.Text:create()
        countdown:setPosition(672, 251)
        self:addChild(countdown)
        countdown:setFontSize(22)
        countdown:setColor(cc.c3b(0, 255, 0))
        countdown:setString("10s")
        self.countdown = countdown;

        local receivebtn = ccui.Button:create("common/common_button0.png","common/common_button0.png")
        receivebtn:setScale9Enabled(true)
        receivebtn:setContentSize(cc.size(184,67))
        receivebtn:setPosition(741, 188)
        receivebtn:setZoomScale(0.1)
        receivebtn:setPressedActionEnabled(true)
        receivebtn:setTitleText("领取")
        receivebtn:setTitleFontSize(30)
        receivebtn:setTitleFontName(FONT_ART_BUTTON)
        receivebtn:setTitleColor(cc.c4b(255, 255, 255,255))
        receivebtn:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        receivebtn:setEnabled(false)
        receivebtn:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:receiveHandler(sender,1,kind)
                end
            end
            )
        self:addChild(receivebtn)
        local count = 10
        self.lefttime = count

        local callfunc = cc.CallFunc:create(function() 
        	self.lefttime = self.lefttime - 1;
        	self.countdown:setString(self.lefttime.."s")
        	if self.lefttime ==0 then
        		receivebtn:setEnabled(true)
        		tiptxt2:setVisible(false)
        		countdown:setVisible(false)
        		receivebtn:loadTextures("common/button_green.png","common/button_green.png")
        	end
        	end);

        local sequence = transition.sequence(
            {

                cc.DelayTime:create(1),
                callfunc
            }
        )
        local repeatAction = cc.Repeat:create(sequence,count)
        bgSprite:runAction(repeatAction)

    elseif SystemNoticeType.SystemNoticeType_Bust_Bean == kind then
        --todo
        local cancelbtn = ccui.Button:create("common/button_green.png","common/button_green.png")
        cancelbtn:setScale9Enabled(true)
        cancelbtn:setContentSize(cc.size(184, 67))
        cancelbtn:setPosition(741, 190)
        cancelbtn:setZoomScale(0.1)
        cancelbtn:setPressedActionEnabled(true)
        cancelbtn:setTitleText("取消")
        cancelbtn:setTitleFontSize(30)
        cancelbtn:setTitleFontName(FONT_ART_BUTTON)
        cancelbtn:setTitleColor(cc.c4b(255, 255, 255,255))
        cancelbtn:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        -- cancelbtn:setEnabled(false)
        cancelbtn:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:cancelHandler(sender)
                end
            end
            )
        self:addChild(cancelbtn)

        local dropbtn = ccui.Button:create("common/common_button4.png","common/common_button4.png")
        dropbtn:setScale9Enabled(true)
        dropbtn:setContentSize(cc.size(192,73))
        dropbtn:setPosition(446, 190)
        dropbtn:setZoomScale(0.1)
        dropbtn:setPressedActionEnabled(true)
        dropbtn:setTitleText("获取欢乐豆")
        dropbtn:setTitleFontSize(30)
        dropbtn:setTitleFontName(FONT_ART_BUTTON)
        dropbtn:setTitleColor(cc.c4b(255, 255, 255,255))
        dropbtn:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2)
        dropbtn:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:dropHandler(sender)
                end
            end
            )
        self:addChild(dropbtn)

    elseif SystemNoticeType.SystemNoticeType_Enter_Gold_Receive_Alms == kind or SystemNoticeType.SystemNoticeType_Bust_Gold_Receive_Alms == kind then
        local receiveGoldBtn = ccui.Button:create("common/common_button3.png","common/common_button3.png")
        receiveGoldBtn:setScale9Enabled(true)
        receiveGoldBtn:setContentSize(cc.size(184,67))
        receiveGoldBtn:setPosition(590, 179)
        receiveGoldBtn:setZoomScale(0.1)
        receiveGoldBtn:setPressedActionEnabled(true)
        receiveGoldBtn:setTitleText("获取金币")
        receiveGoldBtn:setTitleFontSize(30)
        receiveGoldBtn:setTitleFontName(FONT_ART_BUTTON)
        receiveGoldBtn:setTitleColor(cc.c4b(255, 255, 255,255))
        receiveGoldBtn:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        receiveGoldBtn:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:receiveGoldHandler(sender,2,kind)
                end
            end
            )
        self:addChild(receiveGoldBtn)

    elseif SystemNoticeType.SystemNoticeType_FristRegister_Alms == kind then
        local iSeeBtn = ccui.Button:create("common/common_button3.png","common/common_button3.png")
        iSeeBtn:setScale9Enabled(true)
        iSeeBtn:setContentSize(cc.size(184,67))
        iSeeBtn:setPosition(590, 179)
        iSeeBtn:setZoomScale(0.1)
        iSeeBtn:setPressedActionEnabled(true)
        iSeeBtn:setTitleText("我知道了")
        iSeeBtn:setTitleFontSize(30)
        iSeeBtn:setTitleFontName(FONT_ART_BUTTON)
        iSeeBtn:setTitleColor(cc.c4b(255, 255, 255,255))
        iSeeBtn:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        iSeeBtn:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:close()
                end
            end
            )
        self:addChild(iSeeBtn)
    elseif SystemNoticeType.SystemNoticeType_Regular_Customer == kind then
        local iSeeBtn = ccui.Button:create("common/common_button3.png","common/common_button3.png")
        iSeeBtn:setScale9Enabled(true)
        iSeeBtn:setContentSize(cc.size(184,67))
        iSeeBtn:setPosition(590, 179)
        iSeeBtn:setZoomScale(0.1)
        iSeeBtn:setPressedActionEnabled(true)
        iSeeBtn:setTitleText("我知道了")
        iSeeBtn:setTitleFontSize(30)
        iSeeBtn:setTitleFontName(FONT_ART_BUTTON)
        iSeeBtn:setTitleColor(cc.c4b(255, 255, 255,255))
        iSeeBtn:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        iSeeBtn:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:close()
                end
            end
            )
        self:addChild(iSeeBtn)
    elseif SystemNoticeType.SystemNoticeType_Wealth_Overflow == kind or SystemNoticeType.ClientNoticeType_goNextRoom == kind then
        local goNextBtnName = {"","转战中级场","转战高级场"}--{"","自动匹配","自动匹配"}


        local roomIndex = RunTimeData:getRoomIndexByConnectServer()
        if self.curRoomIndex then
            roomIndex = self.curRoomIndex
        end
        local titleText = goNextBtnName[roomIndex]
        local tipStr1 = ""
        if roomIndex == 2 then
            tipStr1 = "客官，看你骨骼惊奇，是块斗地主的好料，初级场不适合你，还是去中场去看看吧。"
            --检测下一个场是否超出准入限制
            local wCurKind = RunTimeData:getCurGameID()
            local nodeItem = ServerInfo:getNodeItemByIndex(wCurKind, 1)
            local userInfo = DataManager:getMyUserInfo()
            local isnext = true
            local gameServer = nodeItem.serverList[roomIndex+1]
            if gameServer and userInfo then
                local min = gameServer.minEnterScore
                local max = gameServer.maxEnterScore
                            
                if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then

                    if (userInfo.beans <= max or max == 0) then
                        isnext = false
                        
                    end

                else
                    if (userInfo.score <= max or max == 0) then
                        isnext = false
                        
                    end
                end
            end

            if isnext then
                
                tipStr1 = "客官，我果然没看错你，高手场才是您真正应该战斗的地方"
                roomIndex = roomIndex+1
            end  
        elseif roomIndex == 3 then
            tipStr1 = "客官，我果然没看错你，高手场才是您真正应该战斗的地方"
        end
        titleText = goNextBtnName[roomIndex]
        tipword = tipStr1


        local goNextRoomBtn = ccui.Button:create("common/common_button3.png","common/common_button3.png")
        goNextRoomBtn:setScale9Enabled(true)
        goNextRoomBtn:setContentSize(cc.size(157*1.2222, 73*1.05))
        goNextRoomBtn:setPosition(590, 179)
        goNextRoomBtn:setZoomScale(0.1)
        goNextRoomBtn:setPressedActionEnabled(true)
        goNextRoomBtn:setTitleText(titleText)
        goNextRoomBtn:setTitleFontSize(30)
        goNextRoomBtn:setTitleFontName(FONT_ART_BUTTON)
        goNextRoomBtn:setTitleColor(cc.c4b(255, 255, 255,255))
        goNextRoomBtn:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        goNextRoomBtn:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:goNextRoomHandler(sender)
                end
            end
            )
        self:addChild(goNextRoomBtn)        
    end

    tiptxt:setString(tipword)
    tiptxt:setColor(cc.c3b(253, 237, 181))
    tiptxt:setTextAreaSize(cc.size(540,100))
    tiptxt:ignoreContentAdaptWithSize(false)
    tiptxt:setTextHorizontalAlignment(0)
    tiptxt:setTextVerticalAlignment(0)
    self:addChild(tiptxt)

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(891,508));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then


                self:close();

            end
        end
    )
end
function WenXinTiShiLayer:countdownHandler()
	-- body
end
function WenXinTiShiLayer:goNextRoomHandler(sender)
    RunTimeData:onClickFastStart()
end
--@params kind 0,3 大厅1，4 房间里
--@params moneyType = 0bean 1gold
function WenXinTiShiLayer:receiveGoldHandler(sender,moneyType,kind)
    -- body
    print("receiveGoldHandler-kind=",kind)
    -- if kind == 3 or kind == 0 then
        HallCenter:receiveGold(moneyType)
    -- else
    --     GameCenter:receiveGold(moneyType)
    -- end
    self:close();


end
function WenXinTiShiLayer:dropHandler( sender )
	-- Hall.showTips("dropHandler",1)
    -- GameCenter:closeRoomSocket()
    local popFrom = 0
    if self.kind == 1 then
        popFrom = 1
    end
    local buy = require("hall.ShopLayer").new(1,popFrom)

    self:getParent():addChild(buy,11)
    self:close();
end
function WenXinTiShiLayer:receiveHandler( sender ,moneyType,kind)
	-- Hall.showTips("receiveHandler",1)
    print("receiveHandler-kind=",kind)
    -- if kind == 3 or kind == 0 then
        HallCenter:receiveGold(moneyType)
    -- else
    --     GameCenter:receiveGold(moneyType)
    -- end
    self:close();
end
function WenXinTiShiLayer:cancelHandler( sender)

	-- Hall.showTips("cancel",1)
    --站起
    -- GameCenter:standUp();
    -- GameCenter:closeRoomSocketDelay(3.0)
    self:close();
end
function WenXinTiShiLayer:close()
    --self:removeAllChildren()
    self:removeSelf();
end
return WenXinTiShiLayer