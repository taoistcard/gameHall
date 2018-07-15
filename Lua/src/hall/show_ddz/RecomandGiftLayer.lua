
-- Date: 2015-10-21 20:57:59

local RecomandGiftLayer = class("RecomandGiftLayer", require("ui.CCModelView"))

function RecomandGiftLayer:ctor()
    self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)

    --累计返利
    self.lTotalRebates = 0
    --宝箱已领次数
    self.dwReceiveTimes = 0
    --获得返利
    self.SumRebatesTotal = 0

    self:createUI()

end

function RecomandGiftLayer:createUI()
    self.baseNode = cc.CSLoader:createNode("view/ddz_recommand/ddz_recomandGiftLayer.csb"):addTo(self)
    self.container = self.baseNode:getChildByName("Image_1")
    self.container2 = self.baseNode:getChildByName("Image_2")

    self:initFunctionButton()

    self.progressNum = ccui.Text:create("0%","",18)
    self.progressNum:setPosition(74, 378)
    self.progressNum:setTextColor(cc.c3b(255, 228, 0))
    self.progressNum:enableOutline(cc.c4b(0,0,0,255), 2)
    self.container:addChild(self.progressNum)

    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(600,240))
    self.listView:setAnchorPoint(cc.p(0.5,0.5))
    self.listView:setPosition(335,238)
    self.container:addChild(self.listView)

    self.Text_2 = self.container2:getChildByName("Text_2")

    self.progressBar = self.container:getChildByName("progressBar")
    self.progressBar:setPercent(0)

    self.timeBg = self.container:getChildByName("invite_time_bg")
    self.timeStr = ccui.Text:create("00:00:00","",25)
    self.timeStr:setPosition(self.timeBg:getContentSize().width/2,self.timeBg:getContentSize().height/2)
    self.timeStr:setColor(cc.c3b(255, 200, 160))
    self.timeBg:addChild(self.timeStr)

    self.tip = ccui.Text:create("尚未有好友帮您赢得返利！","",26)
    self.tip:setPosition(335,290)
    self.tip:setColor(cc.c3b(255, 200, 160))
    self.container:addChild(self.tip)
    self.tip:hide()

    --人物
    local dizhu = ccui.ImageView:create("common/ty_dizhu.png")
    dizhu:setPosition(-20,60)
    self.container:addChild(dizhu)

    local light = ccui.ImageView:create("common/ty_light.png")
    light:setPosition(115, 80)
    dizhu:addChild(light)

    local action = cc.ScaleBy:create(0.8,3)
    light:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.EaseOut:create(action, 3),
                cc.EaseIn:create(action:reverse(), 3)
            )
        )
    )
end

function RecomandGiftLayer:initFunctionButton()
    --关闭
    local btnClose = ccui.Helper:seekWidgetByName(self.container, "btn_close")
    if btnClose then
        btnClose:setPressedActionEnabled(true)
        btnClose:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:hide()
                Click()
            end
        end)
    end    
    --邀请
    self.btnInvite = ccui.Helper:seekWidgetByName(self.container, "btn_invite")
    if self.btnInvite then
        self.btnInvite:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                self.btnInvite:setScale(1.1)
            elseif eventType == ccui.TouchEventType.ended then
                self.btnInvite:setScale(1.0)
                self:showInviteView()
                Click()
            elseif eventType == ccui.TouchEventType.canceled then
                self.btnInvite:setScale(1.0)
            end
        end)
    end
    --我的邀请人
    self.btnAccept = ccui.Helper:seekWidgetByName(self.container, "btn_accept_invite")
    if self.btnAccept then
        self.btnAccept:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.began then
                    self.btnAccept:setScale(1.1)
                elseif eventType == ccui.TouchEventType.ended then
                    self.btnAccept:setScale(1.0)
                    self:showInputInviteID()
                    Click()
                elseif eventType == ccui.TouchEventType.canceled then
                    self.btnAccept:setScale(1.0)
                end
            end
        )
    end
    --规则
    local btnRule = ccui.Helper:seekWidgetByName(self.container, "btn_rule")
    if btnRule then
        btnRule:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.began then
                    btnRule:setScale(1.1)
                elseif eventType == ccui.TouchEventType.ended then
                    btnRule:setScale(1.0)
                    self:showRuleLayer()
                    Click()
                elseif eventType == ccui.TouchEventType.canceled then
                    btnRule:setScale(1.0)
                end
            end
        )
    end
    --领取
    local btnGet = ccui.Helper:seekWidgetByName(self.container2, "btn_get")
    if btnGet then
        btnGet:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.began then
                    btnGet:setScale(1.1)
                elseif eventType == ccui.TouchEventType.ended then
                    btnGet:setScale(1.0)
                    if self.SumRebatesTotal <= 0 then
                        Hall.showTips("暂无返利！")
                    else
                        UserService:InviterRebatesReceiveRequest(0)
                    end
                    Click()
                elseif eventType == ccui.TouchEventType.canceled then
                    btnGet:setScale(1.0)
                end
            end
        )
    end
    --宝箱
    local btnBox = ccui.Helper:seekWidgetByName(self.container, "box_btn")
    if btnBox then
        btnBox:setPressedActionEnabled(true)
        btnBox:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    local boxLayer = require("show_ddz.BoxRewardLayer").new(self)
                    self:addChild(boxLayer, 10)
                    Click()
                end
            end
        )
    end
end

function RecomandGiftLayer:onEnter()
    --[[
    self.invitedInfo = UserService:addEventListener(HallCenterEvent.EVENT_QUERYINVITEDLIST, handler(self, self.listBack))
    self.queryInviteUser = UserService:addEventListener(HallCenterEvent.EVENT_QUERYINVITEUSER, handler(self, self.queryInviteUserBack))
    self.inviteUser = UserService:addEventListener(HallCenterEvent.EVENT_INVITEUSER, handler(self, self.inviteUserBack))
    self.inviteCodeCheck = UserService:addEventListener(HallCenterEvent.EVENT_INVITECODECHECK, handler(self, self.inviteCodeCheckBack))
    self.QueryInviteChestProgress = UserService:addEventListener(HallCenterEvent.EVENT_QUERYINVITECHESTPROGRESS, handler(self, self.queryInviteChestProgressBack))
    self.inviteChestReceive = UserService:addEventListener(HallCenterEvent.EVENT_INVITERREBATESRECEIVE, handler(self, self.inviteChestReceiveBack))

    --查询邀请列表
    UserService:queryInvitedUserList(1)
    --查询玩家是否已被邀请
    UserService:QueryInviteUserRequest()
    --查询宝箱进度
    UserService:QueryInviteChestProgressRequest()
    ]]
end

function RecomandGiftLayer:onExit()
    --[[
    UserService:removeEventListener(self.invitedInfo)
    UserService:removeEventListener(self.queryInviteUser)
    UserService:removeEventListener(self.inviteUser)
    UserService:removeEventListener(self.inviteCodeCheck)
    UserService:removeEventListener(self.QueryInviteChestProgress)
    UserService:removeEventListener(self.inviteChestReceive)
]]
    if self.tickHandle then
        scheduler.unscheduleGlobal(self.tickHandle)
        self.tickHandle = nil
    end

end

function RecomandGiftLayer:listBack(event)
    local data = protocol.hall.business_pb.CMD_MB_QueryBeInvitedUserList_Result_Pro()
    data:ParseFromString(event.data)
    print("listBack-----",#data.RecordList,data.dwUserID,data.SumRebatesTotal)

    -- local info = {};
    -- info.strNickName = "小蔓蔓"
    -- info.YesterdayRebatesTotal = 6857
    -- info.RebatesTotal = 554454155
    -- table.insert(data.RecordList, info)

    -- local info2 = {};
    -- info2.strNickName = "小蔓蔓chao"
    -- info2.YesterdayRebatesTotal = 68572
    -- info2.RebatesTotal = 564545454
    -- table.insert(data.RecordList, info2)

    -- local info3 = {};
    -- info3.strNickName = "小蔓蔓chao"
    -- info3.YesterdayRebatesTotal = 68992
    -- info3.RebatesTotal = 56459995454
    -- table.insert(data.RecordList, info3)

    if self.Text_2 then
        self.Text_2:setString("获得返利："..FormatDigitToString(data.SumRebatesTotal, 1))
        self.SumRebatesTotal = data.SumRebatesTotal
    end

    self.listData = {}
    
    for k,v in ipairs(data.RecordList) do
        print(k.."---",v.strNickName.."---",v.YesterdayRebatesTotal.."---",v.RebatesTotal)
        table.insert(self.listData,v)
    end
    self:refreshList()
end

function RecomandGiftLayer:timeStrFormat(countTime)
    local hour = math.floor(countTime/3600)
    local min = math.floor((countTime%3600)/60)
    local sec = countTime%3600%60
    local timeStr = ""
    if hour < 10 then
        timeStr = timeStr.."0"..hour..":"
    else
        timeStr = timeStr..""..hour..":"
    end
    if min < 10 then
        timeStr = timeStr.."0"..min..":"
    else
        timeStr = timeStr..""..min..":"
    end
    if sec < 10 then
        timeStr = timeStr.."0"..sec
    else
        timeStr = timeStr..""..sec
    end
    return timeStr
end

function RecomandGiftLayer:queryInviteUserBack(event)
    local data = protocol.hall.business_pb.CMD_MB_QueryInviteUser_Result_Pro()
    data:ParseFromString(event.data)
    print("queryInviteUserBack......返回数据是秒数",data.CanBeInvited,data.InviteUserID)

    if data.InviteUserID == 0 then
        -- data.CanBeInvited = 5
        local nDay = math.floor(data.CanBeInvited/(3600*24))
        if nDay < 1 then
            self.timeBg:show()
            self.btnAccept:show()
            self.btnInvite:setPositionX(200)
            --展示倒计时
            self.countTime = 24*60*60-data.CanBeInvited
            self.timeStr:setString(self:timeStrFormat(self.countTime))
            local function tick()
                if self.tickHandle then
                    self.countTime = self.countTime - 1
                    self.timeStr:setString(self:timeStrFormat(self.countTime))
                    if self.countTime <= 0 then
                        scheduler.unscheduleGlobal(self.tickHandle)
                        self.tickHandle = nil
                        --刷新界面
                        self.timeBg:hide()
                        self.btnAccept:hide()
                        self.btnInvite:setPositionX(335)
                    end
                end
            end
            self.tickHandle = scheduler.scheduleGlobal(tick, 1)
        else
            self.timeBg:hide()
            self.btnAccept:hide()
            self.btnInvite:setPositionX(335)
        end
    else
        self.timeBg:hide()
        self.btnAccept:hide()
        self.btnInvite:setPositionX(335)
    end
end

function RecomandGiftLayer:inviteUserBack(event)
    local data = protocol.hall.business_pb.CMD_MB_InviteUser_Result_Pro()
    data:ParseFromString(event.data)
    -- print("inviteUserBack......",data.nResultCode,data.szDescribe)
    if data.nResultCode == 0 then
        if self.inputInviteView then
            self.inputInviteView:removeFromParent()
            --刷新界面
            self.timeBg:hide()
            self.btnAccept:hide()
            self.btnInvite:setPositionX(335)
        end
        self:showGetAwardView(2)
        onUmengEvent("1056")
    else
        Hall.showTips(data.szDescribe)
    end
end

function RecomandGiftLayer:inviteCodeCheckBack(event)
    local data = protocol.hall.business_pb.CMD_MB_InviteCodeCheck_Result_Pro()
    data:ParseFromString(event.data)
    -- print("inviteCodeCheckBack......",data.dwInviteUserID,data.szNickName)
    if data.dwInviteUserID ~= 0 then
        self:showSureView(data.szNickName)
    else
        Hall.showTips("您输入的ID号有误，请核对后重新输入!")
    end
end

function RecomandGiftLayer:queryInviteChestProgressBack(event)
    local data = protocol.hall.business_pb.CMD_MB_QueryInviteChestProgress_Result_Pro()
    data:ParseFromString(event.data)
    -- print("queryInviteChestProgressBack......",data.dwUserID,data.nLastChestProgress,data.lTotalRebates,data.dwReceiveTimes)
    --累计返利
    self.lTotalRebates = data.lTotalRebates
    --宝箱已领次数
    self.dwReceiveTimes = data.dwReceiveTimes
    self.progressBar:setPercent(data.nLastChestProgress)
    self.progressNum:setString(data.nLastChestProgress.."%")
end

function RecomandGiftLayer:inviteChestReceiveBack(event)
    local data = protocol.hall.business_pb.CMD_MB_InviterRebatesReceive_Result_Pro()
    data:ParseFromString(event.data)
    -- print("inviteChestReceiveBack......",data.nResultCode,data.szDescribe)
    if data.nResultCode == 0 then
        self:showGetAwardView(1)
        --刷新界面
        self.SumRebatesTotal = 0
        if self.Text_2 then
            self.Text_2:setString("获得返利："..FormatDigitToString(self.SumRebatesTotal, 1))
        end
    else
        Hall.showTips("领取返利失败!")
    end    
end

function RecomandGiftLayer:refreshList()
    self.listView:removeAllItems()

    if #self.listData == 0 then
        self.tip:show()
    else
        self.tip:hide()
    end

    for k,info in ipairs(self.listData) do

        local item = display.newLayer()
        item:setContentSize(cc.size(610,86))
        
        local itemBg = ccui.ImageView:create("common/list_item.png")
        itemBg:setScale9Enabled(true)
        itemBg:setContentSize(cc.size(610, 92))
        itemBg:setPosition(300, 40)
        itemBg:setScaleX(0.94)
        item:addChild(itemBg)

        local gameIcon = cc.Sprite:create("view/ddz_recommand/invite_game.png");
        gameIcon:setPosition(60, 40)
        item:addChild(gameIcon)

        local gameIcon = cc.Sprite:create("view/ddz_recommand/invite_money.png");
        gameIcon:setPosition(40, 70)
        item:addChild(gameIcon)

        local gameIcon = cc.Sprite:create("view/ddz_recommand/invite_money.png");
        gameIcon:setPosition(470, 70)
        gameIcon:setRotation(-60)
        item:addChild(gameIcon)

        local gameIcon = cc.Sprite:create("view/ddz_recommand/invite_money.png");
        gameIcon:setPosition(560, 20)
        item:addChild(gameIcon)

        local content = ccui.Text:create("您邀请了"..FormotGameNickName(info.strNickName,6).."和您一起欢乐斗地主！","",23)
        content:setPosition(100, 62);
        content:setAnchorPoint(cc.p(0,0.5))
        content:setColor(cc.c3b(149, 71, 30))
        item:addChild(content)

        local content = ccui.Text:create("昨日为您返利"..FormatDigitToString(info.YesterdayRebatesTotal, 1).."，累计返利"..FormatDigitToString(info.RebatesTotal, 1),"",21)
        content:setPosition(100, 24);
        content:setAnchorPoint(cc.p(0,0.5))
        content:setColor(cc.c3b(149, 71, 30))
        item:addChild(content)

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(520,100))
        custom_item:addChild(item)
        custom_item:setTag(k)
        
        self.listView:pushBackCustomItem(custom_item)

    end

    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            local index = sender:getCurSelectedIndex() + 1
            local itemInfo = self.listData[index]
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

end

--主播MM动画
function RecomandGiftLayer:getZhuBoMMAnimation()
    local name = "zhubo_mm"
    local filePath = "hallEffect/zhu_bo_mm/"..name..".ExportJson"
    local imagePath = "hallEffect/zhu_bo_mm/"..name.."0.png"
    local plistPath = "hallEffect/zhu_bo_mm/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end

--邀请有礼获得奖励动画
function RecomandGiftLayer:getInviteFriendAnimation()
    local name = "yyl_liquan"
    local filePath = "hallEffect/recommand_award/"..name..".ExportJson"
    local imagePath = "hallEffect/recommand_award/"..name.."0.png"
    local plistPath = "hallEffect/recommand_award/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end

--弹出邀请链接
function RecomandGiftLayer:showInviteView()

    local winSize = cc.Director:getInstance():getWinSize();
    --蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                maskLayer:removeFromParent()
            end
        end
    )

    local bg = ccui.ImageView:create("common/ty_dialog_bg.png");
    bg:setPosition(maskLayer:getContentSize().width/2, maskLayer:getContentSize().height/2)
    maskLayer:addChild(bg)

    local dialogLine = ccui.ImageView:create("common/ty_dialog_line.png");
    dialogLine:setPosition(bg:getContentSize().width/2-7, 67)
    bg:addChild(dialogLine)

    local zhuBoMM = self:getZhuBoMMAnimation()
    zhuBoMM:ignoreAnchorPointForPosition(false)
    zhuBoMM:setAnchorPoint(cc.p(0,0))
    zhuBoMM:setPosition(cc.p(-126,-18))
    bg:addChild(zhuBoMM)
    zhuBoMM:getAnimation():playWithIndex(0)
    zhuBoMM:setRotation(-12)

    local userGameId = "357715"
    local userInfo = DataManager:getMyUserInfo()
    if userInfo then
        userGameId = tostring(userInfo.gameID)
    end    

    local urlText = "我在玩欢乐斗地主，快来和我一起玩耍吧！我的\nID是"..userGameId.."，点http://dwz.cn/2iRK5x下载欢乐斗\n地主，在游戏内“邀请有礼”“我的推荐人”中输入我\n的ID，就可以获得礼包一份哦！"

    local content = ccui.Text:create(urlText,"",22)
    content:setPosition(314, 200);
    content:setColor(cc.c3b(0x83, 0x43, 0x11))
    bg:addChild(content)

    local wxBtn = ccui.Button:create("view/ddz_recommand/invite_wx.png","view/ddz_recommand/invite_wx.png")
    wxBtn:setPressedActionEnabled(true)
    wxBtn:setPosition(cc.p(bg:getContentSize().width/2-220,94))
    bg:addChild(wxBtn)

    local wxText = ccui.Text:create("微信","",18)
    wxText:setPosition(cc.p(bg:getContentSize().width/2-220,42));
    wxText:setColor(cc.c3b(0xee, 0xe6, 0xd6))
    bg:addChild(wxText)

    local wxFriendBtn = ccui.Button:create("view/ddz_recommand/invite_wx_friend.png","view/ddz_recommand/invite_wx_friend.png")
    wxFriendBtn:setPressedActionEnabled(true)
    wxFriendBtn:setPosition(cc.p(bg:getContentSize().width/2-130,94))
    bg:addChild(wxFriendBtn)

    local wxFriendText = ccui.Text:create("朋友圈","",18)
    wxFriendText:setPosition(cc.p(bg:getContentSize().width/2-130,42));
    wxFriendText:setColor(cc.c3b(0xee, 0xe6, 0xd6))
    bg:addChild(wxFriendText)    

    local qqBtn = ccui.Button:create("view/ddz_recommand/invite_qq.png","view/ddz_recommand/invite_qq.png")
    qqBtn:setPressedActionEnabled(true)
    qqBtn:setPosition(cc.p(bg:getContentSize().width/2-40,94))
    bg:addChild(qqBtn)

    local qqText = ccui.Text:create("QQ","",18)
    qqText:setPosition(cc.p(bg:getContentSize().width/2-40,42));
    qqText:setColor(cc.c3b(0xee, 0xe6, 0xd6))
    bg:addChild(qqText)      

    local qqZoneBtn = ccui.Button:create("view/ddz_recommand/invite_qq_zone.png","view/ddz_recommand/invite_qq_zone.png")
    qqZoneBtn:setPressedActionEnabled(true)
    qqZoneBtn:setPosition(cc.p(bg:getContentSize().width/2+50,94))
    bg:addChild(qqZoneBtn)

    local qqZoneText = ccui.Text:create("QQ空间","",18)
    qqZoneText:setPosition(cc.p(bg:getContentSize().width/2+50,42));
    qqZoneText:setColor(cc.c3b(0xee, 0xe6, 0xd6))
    bg:addChild(qqZoneText)

    local sinaBtn = ccui.Button:create("view/ddz_recommand/invite_sina.png","view/ddz_recommand/invite_sina.png")
    sinaBtn:setPressedActionEnabled(true)
    sinaBtn:setPosition(cc.p(bg:getContentSize().width/2+140,94))
    bg:addChild(sinaBtn)

    local sinaText = ccui.Text:create("微博","",18)
    sinaText:setPosition(cc.p(bg:getContentSize().width/2+140,42));
    sinaText:setColor(cc.c3b(0xee, 0xe6, 0xd6))
    bg:addChild(sinaText)    

    local msgBtn = ccui.Button:create("view/ddz_recommand/invite_msg.png","view/ddz_recommand/invite_msg.png")
    msgBtn:setPressedActionEnabled(true)
    msgBtn:setPosition(cc.p(bg:getContentSize().width/2+230,94))
    bg:addChild(msgBtn)

    local msgText = ccui.Text:create("短信","",18)
    msgText:setPosition(cc.p(bg:getContentSize().width/2+230,42));
    msgText:setColor(cc.c3b(0xee, 0xe6, 0xd6))
    bg:addChild(msgText)
    
    local shareText = "我在玩欢乐斗地主，快来和我一起玩耍吧！我的ID是"..userGameId.."，点http://dwz.cn/2iRK5x下载欢乐斗地主，在游戏内“邀请有礼”“我的推荐人”中输入我的ID，就可以获得礼包一份哦！"

    wxBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                showShare(shareText,"Icon-50","1")
            end
        end
    )
    wxFriendBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                showShare(shareText,"Icon-50","2")
            end
        end
    )
    qqBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                showShare(shareText,"Icon-50","3")
            end
        end
    )
    qqZoneBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                showShare(shareText,"Icon-50","4")
            end
        end
    )
    sinaBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                showShare(shareText,"Icon-50","5")
            end
        end
    )
    msgBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                showShare(shareText,"Icon-50","6")
            end
        end
    )

end

--弹出输入邀请人ID
function RecomandGiftLayer:showInputInviteID()

    local winSize = cc.Director:getInstance():getWinSize();
    --蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.width/2, display.height/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)
    self.inputInviteView = maskLayer

    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                maskLayer:removeFromParent()
            end
        end
    )

    local bg = ccui.Button:create("common/ty_dialog_small_bg.png","common/ty_dialog_small_bg.png")
    bg:setPosition(maskLayer:getContentSize().width/2, maskLayer:getContentSize().height/2)
    bg:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- print("策策策策策策策策策策策")
            end
        end
    )
    maskLayer:addChild(bg)

    local zhuBoMM = self:getZhuBoMMAnimation()
    zhuBoMM:ignoreAnchorPointForPosition(false)
    zhuBoMM:setAnchorPoint(cc.p(0,0))
    zhuBoMM:setPosition(cc.p(-126,-18))
    bg:addChild(zhuBoMM)
    zhuBoMM:getAnimation():playWithIndex(0)
    zhuBoMM:setRotation(-12)

    local xiaoJi = ccui.ImageView:create("common/ty_xiao_ji.png");
    xiaoJi:setPosition(bg:getContentSize().width-26, 26)
    bg:addChild(xiaoJi)    

    local content = ccui.Text:create("请输入邀请人ID (一个账号只能\n被邀请一次)","",23)
    content:setPosition(bg:getContentSize().width/2, 176);
    content:setColor(cc.c3b(0x83, 0x43, 0x11))
    bg:addChild(content)

    local inputBg = ccui.ImageView:create("common/ty_input_bg.png");
    inputBg:setScale9Enabled(true);
    inputBg:setContentSize(cc.size(218, 62));
    inputBg:setPosition(bg:getContentSize().width/2, 110)
    bg:addChild(inputBg)

    local textEdit = ccui.EditBox:create(cc.size(320,35), "blank.png");
    textEdit:setPosition(cc.p(bg:getContentSize().width/2+60, 107));
    textEdit:setFontSize(34);
    textEdit:setPlaceHolder("点击输入ID");
    textEdit:setPlaceholderFontColor(cc.c3b(255,255,255));
    textEdit:setPlaceholderFontSize(28);
    textEdit:setInputMode(InputMode_PHONE_NUMBER);
    textEdit:setMaxLength(10);
    bg:addChild(textEdit);

    local chongzhi = ccui.Button:create("common/ty_sure_btn.png","common/ty_sure_btn.png")
    chongzhi:setPosition(cc.p(bg:getContentSize().width/2,40))
    chongzhi:setPressedActionEnabled(true)
    chongzhi:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                self.gameID = tonumber(textEdit:getText()) or 0
                if self.gameID == 0 then
                    Hall.showTips("请输入邀请人ID")
                else
                    UserService:InviteCodeCheckRequest(self.gameID)
                end
            end
        end
    )
    bg:addChild(chongzhi)

end

--弹出获得奖励界面(2绿钻;1金币;0礼券)
--bGold 是否是金宝箱,金宝箱显示获得30000礼券
function RecomandGiftLayer:showGetAwardView(index,bGold)

    local winSize = cc.Director:getInstance():getWinSize();
    --蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.width/2, display.height/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer,1000)

    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                maskLayer:removeFromParent()
            end
        end
    )

    --播放动画特效
    local armature = self:getInviteFriendAnimation()
    if armature then
        armature:setPosition(cc.p(maskLayer:getContentSize().width/2, maskLayer:getContentSize().height/2+26))
        maskLayer:addChild(armature)
        armature:getAnimation():playWithIndex(index)
    end

    local titleName = "view/recommandSystem/invite_lv_zuan.png"
    local contentStr = "您已成功接受邀请，恭喜获得绿钻体验2天！"
    if index == 1 then
        titleName = "view/recommandSystem/invite_coin.png"
        contentStr = "恭喜获得"..FormatDigitToString(self.SumRebatesTotal, 1).."奖励，多多邀请好友吧！"
    elseif index == 0 then
        titleName = "view/recommandSystem/invite_li_quan.png"
        if bGold then
            contentStr = "恭喜获得开箱奖励礼券30000张！"
        else
            contentStr = "恭喜获得开箱奖励礼券3000张！"
        end
    end

    local content = ccui.Text:create(contentStr,"",23)
    content:setPosition(maskLayer:getContentSize().width/2, maskLayer:getContentSize().height/2-8);
    content:setColor(cc.c3b(0xf8, 0xff, 0x9d))
    maskLayer:addChild(content)

end        

--弹出确认框
function RecomandGiftLayer:showSureView(tipInfoText)

    local winSize = cc.Director:getInstance():getWinSize();
    --蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.width/2, display.height/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                maskLayer:removeFromParent()
            end
        end
    )

    local bg = ccui.ImageView:create("common/ty_dialog_small_bg.png");
    bg:setPosition(maskLayer:getContentSize().width/2, maskLayer:getContentSize().height/2)
    maskLayer:addChild(bg)

    local zhuBoMM = self:getZhuBoMMAnimation()
    zhuBoMM:ignoreAnchorPointForPosition(false)
    zhuBoMM:setAnchorPoint(cc.p(0,0))
    zhuBoMM:setPosition(cc.p(-126,-18))
    bg:addChild(zhuBoMM)
    zhuBoMM:getAnimation():playWithIndex(0)
    zhuBoMM:setRotation(-12)

    local xiaoJi = ccui.ImageView:create("common/ty_xiao_ji.png");
    xiaoJi:setPosition(bg:getContentSize().width+10, 0)
    bg:addChild(xiaoJi)

    local content = ccui.Text:create("您的推荐人昵称为："..FormotGameNickName(tipInfoText,6).."\n请再次核对信息是否正确。","",23)
    content:setPosition(bg:getContentSize().width/2, 164);
    content:setColor(cc.c3b(0x83, 0x43, 0x11))
    bg:addChild(content)

    --确定
    local chongzhi = ccui.Button:create("common/ty_sure_btn.png","common/ty_sure_btn.png")
    chongzhi:setPosition(cc.p(bg:getContentSize().width/2-95,70))
    chongzhi:setPressedActionEnabled(true)
    chongzhi:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                UserService:InviteUserRequest(self.gameID)
                maskLayer:removeFromParent()
                Click()
            end
        end
    )
    bg:addChild(chongzhi)

    --取消
    local chongzhi = ccui.Button:create("common/ty_cancel_btn.png","common/ty_cancel_btn.png")
    chongzhi:setPosition(cc.p(bg:getContentSize().width/2+95,70))
    chongzhi:setPressedActionEnabled(true)
    chongzhi:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                maskLayer:removeFromParent()
            end
        end
    )
    bg:addChild(chongzhi)

end

--规则介绍
function RecomandGiftLayer:showRuleLayer()

    local winSize = cc.Director:getInstance():getWinSize();
    --蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.width/2, display.height/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- maskLayer:removeFromParent()
            end
        end
    )

    local bg = ccui.ImageView:create("common/pop_bg.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(700,440))
    bg:setPosition(maskLayer:getContentSize().width/2, maskLayer:getContentSize().height/2)
    maskLayer:addChild(bg)

    local titleSprite = cc.Sprite:create("common/hall_common_title.png");
    titleSprite:setPosition(cc.p(150, 400));
    bg:addChild(titleSprite);

    local title = ccui.Text:create("规则", FONT_ART_TEXT, 26)
    title:setPosition(cc.p(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2+20))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    local inputBg = ccui.ImageView:create("common/ty_inside_bg.png")
    inputBg:setScale9Enabled(true)
    inputBg:setContentSize(cc.size(600, 300))
    inputBg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-12)
    bg:addChild(inputBg)

    local content = ccui.Text:create("1、成功邀请好友（接受邀请输入邀请人ID），好友玩\n游戏就会带来一定奖励。每个账号可邀请多位好友，每\n个账号只能被邀请一次。\n2、无法邀请比自己账号早注册的玩家。\n3、如为接受邀请，请在账号注册完毕后24小时内输入\n邀请人ID，否则无法再接受任何邀请。\n4、宝箱会随着领取奖励的积累逐个开启。银箱含100元\n礼券，金箱含1000元礼券。","",22)
    content:setPosition(280, 160)
    content:setColor(cc.c3b(255, 242, 224))
    inputBg:addChild(content)

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(666,414));
    bg:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click();
                maskLayer:removeFromParent()
            end
        end
    )    

end

return RecomandGiftLayer