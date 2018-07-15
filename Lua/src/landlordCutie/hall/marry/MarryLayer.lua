local MarryLayer = class("MarryLayer", function () return display.newLayer() end )



function MarryLayer:ctor()
	self:createUI()
	self.huntMarriagesList = {}
	self:setNodeEventEnabled(true)
end

function MarryLayer:onEnter()
	print("MarryLayer:onEnter")
    UserService:queryMarriagesInfo()
	self.QUERYHUNTMARRIAGES = UserService:addEventListener(HallCenterEvent.EVENT_QUERYHUNTMARRIAGES, handler(self, self.receiveListHandler))

    UserService:queryHuntingMarriages(1)
    self.MARRIAGEPROPOSE = UserService:addEventListener(HallCenterEvent.EVENT_MARRIAGEPROPOSE, handler(self, self.marriageProposeHandler))
    self.MARRIAGEINFO = UserService:addEventListener(HallCenterEvent.EVENT_MARRIAGEINFO, handler(self, self.marriageInfoHandler))
    self.MARRIAGEHUNTCANCEL = UserService:addEventListener(HallCenterEvent.EVENT_MARRIAGEHUNTCANCEL, handler(self, self.marriageHuntCancelHandler))
    self.MARRIAGEHUNT = UserService:addEventListener(HallCenterEvent.EVENT_MARRIAGEHUNT, handler(self, self.marriageHuntHandler))
end

function MarryLayer:onExit()
	print("MarryLayer:onExit")
	UserService:removeEventListener(self.MARRIAGEPROPOSE)
    UserService:removeEventListener(self.MARRIAGEINFO)
    UserService:removeEventListener(self.MARRIAGEHUNTCANCEL)
end

function MarryLayer:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local titlelight = ccui.ImageView:create("common/effect_light.png");
    titlelight:setScaleY(0.94)
    titlelight:setScaleX(1.71)
    titlelight:setPosition(cc.p(573,506));
    self:addChild(titlelight);
    -- local rotateBy = cc.RotateBy:create(2, 360)
    -- titlelight:runAction(cc.RepeatForever:create(rotateBy))

    local EffectFactory = require("commonView.DDZEffectFactory");
    local titleLightAnimation = EffectFactory:getInstance():getJieHunAnimation();
    titleLightAnimation:setPosition(cc.p(567,495));
    self:addChild(titleLightAnimation,1);


    local bglayer = ccui.ImageView:create("hall/marry/bg.png")
    bglayer:setPosition(582, 260)
    self:addChild(bglayer)
    self.bglayer = bglayer

    -- local title = ccui.ImageView:create("hall/marry/title.png")
    -- title:setPosition(393, 534)
    -- bglayer:addChild(title)


    -- local titleLove = ccui.ImageView:create("hall/marry/love.png")
    -- titleLove:setPosition(192, 499)
    -- bglayer:addChild(titleLove)

    local close = ccui.Button:create("common/close.png")
    close:setPosition(735, 474)
    bglayer:addChild(close)
    close:addTouchEventListener(
    	function ( sender,eventType )
    		if eventType == ccui.TouchEventType.ended then
    			self:closeHandler()
    		end
    	end
    )
    local tip  = ccui.Text:create("很抱歉你搜索的ID还未发起征婚","",20)
    tip:setPosition(383,400)
    -- tip:setAnchorPoint(cc.p())
    tip:setColor(cc.c3b(218, 141, 80))
    self.tip = tip
    tip:hide()
    bglayer:addChild(tip)
--  listview
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(650,310))
    self.listView:setAnchorPoint(cc.p(0,0))
    self.listView:setPosition(83,138)
    bglayer:addChild(self.listView)

    local myInfo = DataManager:getMyUserInfo()
    local myMarriagesInfo = myInfo.marriagesInfo
    local marriedUI = {}
    local marryUI = {}
    self.marriedUI = marriedUI
    self.marryUI = marryUI
    -- if myMarriagesInfo.dwTargetUserID and myMarriagesInfo.dwTargetUserID ~= 0 then
    	local frame = require("commonView.GameHeadView").new(1)--ccui.ImageView:create("play3/frame.png")
    	frame:setPosition(129, 83)
    	frame:setScale(0.65)
    	bglayer:addChild(frame)
        table.insert(marriedUI,frame)
        self.myHead = frame

    	local mynickname = ccui.Text:create("最爱斗地主","",18)
    	mynickname:setColor(cc.c3b(241, 207, 139))
        mynickname:setAnchorPoint(cc.p(0,0.5))
    	mynickname:setPosition(170, 96)
        mynickname:setString(myInfo.nickName)
        mynickname:setName("mynickname")
    	bglayer:addChild(mynickname)
        table.insert(marriedUI,mynickname)

    	local loveliness = ccui.ImageView:create("common/loveliness.png")
    	loveliness:setPosition(182, 67)
    	loveliness:setScale(0.8)
    	bglayer:addChild(loveliness)
        table.insert(marriedUI,loveliness)

    	local myloveValue = ccui.Text:create("33.5万","",18)
		myloveValue:setPosition(203, 70)
        myloveValue:setString(myInfo:loveliness())
        myloveValue:setName("myloveValue")
		myloveValue:setAnchorPoint(cc.p(0,0.5))
		myloveValue:setColor(cc.c3b(241, 207, 139))
		bglayer:addChild(myloveValue)
        table.insert(marriedUI,myloveValue)

		local love = ccui.ImageView:create("hall/marry/love.png")
		love:setPosition(299, 85)
		love:setScale(0.5)
		bglayer:addChild(love)
        table.insert(marriedUI,love)

    	local frame = require("commonView.GameHeadView").new(1)--ccui.ImageView:create("play3/frame.png")
    	frame:setPosition(368, 83)
    	frame:setScale(0.65)
    	bglayer:addChild(frame)
        table.insert(marriedUI,frame)
        self.spouseHead = frame

    	local spouse = ccui.Text:create("最爱斗地主","",18)
    	spouse:setColor(cc.c3b(241, 207, 139))
        spouse:setAnchorPoint(cc.p(0,0.5))
    	spouse:setPosition(409, 96)
        spouse:setString(myMarriagesInfo.szNickName)
        spouse:setName("spouse")
    	bglayer:addChild(spouse)
        table.insert(marriedUI,spouse)

    	local loveliness = ccui.ImageView:create("common/loveliness.png")
    	loveliness:setPosition(423, 67)
    	loveliness:setScale(0.8)
    	bglayer:addChild(loveliness)
        table.insert(marriedUI,loveliness)

    	local spouseloveValue = ccui.Text:create("33.5万","",18)
		spouseloveValue:setPosition(444, 70)
        spouseloveValue:setString(myMarriagesInfo.dwLoveLiness)
        spouseloveValue:setName("spouseloveValue")
		spouseloveValue:setAnchorPoint(cc.p(0,0.5))
		spouseloveValue:setColor(cc.c3b(241, 207, 139))
		bglayer:addChild(spouseloveValue)
        table.insert(marriedUI,spouseloveValue)

		local marriagebreak = ccui.Button:create("common/button_green.png");
		marriagebreak:setScale9Enabled(true)
		marriagebreak:setContentSize(cc.size(163*1.12, 72))
		marriagebreak:setPosition(cc.p(623, 94));
		marriagebreak:setTitleFontName(FONT_ART_BUTTON);
		marriagebreak:setTitleText("离婚");
		marriagebreak:setTitleColor(cc.c3b(255,255,255));
		marriagebreak:setTitleFontSize(28);
		marriagebreak:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
		bglayer:addChild(marriagebreak);
		marriagebreak:setPressedActionEnabled(true);
		marriagebreak:addTouchEventListener(
		    function(sender,eventType)
		        if eventType == ccui.TouchEventType.ended then
		            self:marriagebreakHandler()
		        end
		    end
		)
        table.insert(marriedUI,marriagebreak)

		local baozhiqi = ccui.Text:create("婚姻保质期：","",16)
		baozhiqi:setPosition(561, 54)
		baozhiqi:setColor(cc.c3b(241, 207, 139))
		bglayer:addChild(baozhiqi)
        table.insert(marriedUI,baozhiqi)

        local lefttime = myMarriagesInfo.dwDatediff
        local minute = lefttime%60
        local hour = (lefttime-minute)/60%24
        local day = ((lefttime-minute)/60-hour)/24
		local leftTimeTxt = ccui.Text:create("1天2小时3分","",16)
		leftTimeTxt:setPosition(609, 54)
        leftTimeTxt:setString(day.."天"..hour.."小时"..minute.."分")
        leftTimeTxt:setName("leftTimeTxt")
		leftTimeTxt:setColor(cc.c3b(241, 207, 139))
		leftTimeTxt:setAnchorPoint(cc.p(0,0.5))
		bglayer:addChild(leftTimeTxt)
        table.insert(marriedUI,leftTimeTxt)

	-- else
        local zslovefenge = ccui.ImageView:create("hall/marry/zslovefenge.png")
        zslovefenge:setPosition(605,79)
        bglayer:addChild(zslovefenge);
		local marriagehunting = ccui.Button:create("common/button_green.png")
		marriagehunting:setScale9Enabled(true)
	    marriagehunting:setContentSize(cc.size(163*1.12, 72))
	    marriagehunting:setPosition(cc.p(605,79));
	    marriagehunting:setTitleFontName(FONT_ART_BUTTON);
	    marriagehunting:setTitleText("征婚");
	    marriagehunting:setTitleColor(cc.c3b(255,255,255));
	    marriagehunting:setTitleFontSize(28);
	    marriagehunting:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
	    bglayer:addChild(marriagehunting);
	    marriagehunting:setPressedActionEnabled(true);
	    marriagehunting:addTouchEventListener(
	        function(sender,eventType)
	            if eventType == ccui.TouchEventType.ended then

	                self:marriagehuntingHandler()
	            end
	        end
	    )
        table.insert(marryUI,marriagehunting)

        local changeMarriages = ccui.Button:create("common/button_blue.png")
        changeMarriages:setScale9Enabled(true)
        changeMarriages:setContentSize(cc.size(163*1.12, 72))
        changeMarriages:setPosition(cc.p(160,79));
        changeMarriages:setTitleFontName(FONT_ART_BUTTON);
        changeMarriages:setTitleText("换一批");
        changeMarriages:setTitleColor(cc.c3b(255,255,255));
        changeMarriages:setTitleFontSize(28);
        changeMarriages:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
        bglayer:addChild(changeMarriages);
        changeMarriages:setPressedActionEnabled(true);
        changeMarriages:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    self:changeMarriagesHandler()
                end
            end
        )
        table.insert(marryUI,changeMarriages)
        local searchButton = ccui.Button:create("common/button_blue.png")
        searchButton:setScale9Enabled(true)
        searchButton:setContentSize(cc.size(163*1.12, 72))
        searchButton:setPosition(cc.p(340,79));
        searchButton:setTitleFontName(FONT_ART_BUTTON);
        searchButton:setTitleText("精确搜索");
        searchButton:setTitleColor(cc.c3b(255,255,255));
        searchButton:setTitleFontSize(28);
        searchButton:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
        bglayer:addChild(searchButton);
        searchButton:setPressedActionEnabled(true);
        searchButton:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    self:searchButtonHandler()
                end
            end
        )
        table.insert(marryUI,searchButton)
        --取消征婚
        local marriagehuntCancel = ccui.Button:create("common/button_green.png")
        marriagehuntCancel:setScale9Enabled(true)
        marriagehuntCancel:setContentSize(cc.size(163*1.12, 72))
        marriagehuntCancel:setPosition(cc.p(405,79));
        marriagehuntCancel:setTitleFontName(FONT_ART_BUTTON);
        marriagehuntCancel:setTitleText("取消征婚");
        marriagehuntCancel:setTitleColor(cc.c3b(255,255,255));
        marriagehuntCancel:setTitleFontSize(28);
        marriagehuntCancel:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
        bglayer:addChild(marriagehuntCancel);
        marriagehuntCancel:setPressedActionEnabled(true);
        marriagehuntCancel:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    self:marriagehuntCancelHandler()
                end
            end
        )
        self.marriagehuntCancel = marriagehuntCancel
    -- end
    self:refreshBottomUI(myMarriagesInfo)
    -- self:refreshList()
end

function MarryLayer:changeMarriagesHandler()
    
    UserService:queryHuntingMarriages(1)
end

function MarryLayer:searchButtonHandler()
    local search = require("hall.marry.MarriageSearch").new()
    self:addChild(search, 10)
end

--离婚
function MarryLayer:marriagebreakHandler()
    local myInfo = DataManager:getMyUserInfo()
    local myMarriagesInfo = myInfo.marriagesInfo

	local hunt = require("hall.marry.MarriageBreak").new(myMarriagesInfo.szNickName)
	self:addChild(hunt,10)

    -- 
    -- UserService:sendMarriageHuntCancel()
end

--征婚
function MarryLayer:marriagehuntingHandler()
	-- body
	local hunt = require("hall.marry.MarriageHunt").new()
	self:addChild(hunt,10)
end

function MarryLayer:marriagehuntCancelHandler()
    local hunt = require("hall.marry.MarriageHuntCancel").new()
    self:addChild(hunt,10)
end

function MarryLayer:receiveListHandler(event)
	-- body
	local marriages = protocol.hall.business_pb.DBR_GR_QueryHuntingMarriages_Result_Pro()
    marriages:ParseFromString(event.data)
    -- print("receiveListHandler--cbCount",marriages.cbCount)
    local huntMarriagesList = {}
    for k,v in ipairs(marriages.HuntingMarriagesInfo) do
        -- print(k,v.szNickName,v.dwLoveLiness,v.lGiftForMarry,v.strLoveStroy)
        table.insert(self.huntMarriagesList,v)
        table.insert(huntMarriagesList,v)
    end
    self.currentMarriageList = huntMarriagesList
	self:refreshList(huntMarriagesList)
end
function MarryLayer:marriageHuntDetail(huntMarriage)
    local marriageInfo = require("hall.marry.MarriageInfo").new(huntMarriage)
    marriageInfo:setGold(huntMarriage.lUserScore)
    marriageInfo:setML(huntMarriage.dwLoveLiness)
    -- marriageInfo:setMaxGold(huntMarriage.dwLoveLiness)
    marriageInfo:setUnderWrite(huntMarriage.szUnderWrite)
    marriageInfo:setLevelInfo(huntMarriage.dwUserMedal)
    marriageInfo:setSex(huntMarriage.cbGender)
    marriageInfo:setVip(huntMarriage.cbMemberOrder)
    marriageInfo:setName(huntMarriage.szNickName)
    marriageInfo:setIcon(huntMarriage.wFaceID,huntMarriage.szTokenID,huntMarriage.szHeadFile)
    self:addChild(marriageInfo, 10)
end
function MarryLayer:refreshList(huntMarriagesList)
    self.listView:removeAllItems()
	local i =  1
    local length = #huntMarriagesList
    if length == 0 then
        self.tip:show()
    else
        self.tip:hide()
    end
    
    local myuserid = DataManager:getMyUserID()
	for k,huntMarriage in ipairs(huntMarriagesList) do
        local bangItemLayer = ccui.Button:create("common/list_item.png")
        -- bangItemLayer:loadTexture("common/list_item.png")
        bangItemLayer:setScale9Enabled(true)
        bangItemLayer:setContentSize(cc.size(630,112))
        -- bangItemLayer:setCapInsets(cc.rect(250,40,10,10))
        bangItemLayer:setPressedActionEnabled(true);
        bangItemLayer:ignoreAnchorPointForPosition(true)
        bangItemLayer:setName("ListItem")
        bangItemLayer:setTag(i)
        bangItemLayer:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    self:marriageHuntDetail(huntMarriage)
                end
            end
        )
        local zs1 = ccui.ImageView:create("hall/marry/zslove.png")
        bangItemLayer:addChild(zs1)
        zs1:setPosition(111, 93)
        zs1:setScale(0.7)
        local zs2 = ccui.ImageView:create("hall/marry/zslove.png")
        bangItemLayer:addChild(zs2)
        zs2:setPosition(403, 90)
        zs2:setScaleX(-0.7)
        zs2:setScaleY(0.7)
        local zs3 = ccui.ImageView:create("hall/marry/zslove.png")
        bangItemLayer:addChild(zs3)
        zs3:setPosition(450, 70)
        

        local frame = require("commonView.GameHeadView").new(1);--ccui.ImageView:create("play3/frame.png")
        frame:setPosition(60, 56)
        frame:setScale(0.8)
        frame:setNewHead(huntMarriage.wFaceID,huntMarriage.szTokenID,huntMarriage.szHeadFile)
        bangItemLayer:addChild(frame)

        local nickname = ccui.Text:create("最爱斗地主","",22)
        nickname:setColor(cc.c3b(131, 66, 21))
        nickname:setPosition(108, 73)
        nickname:setAnchorPoint(cc.p(0,0.5))
        bangItemLayer:addChild(nickname)
        local nameshow = huntMarriage.szNickName
        -- print("string.len==",string.len(huntMarriage.szNickName),#huntMarriage.szNickName)
        local maxlength = 12
        if string.len(huntMarriage.szNickName) >maxlength then
            nameshow = string.sub(huntMarriage.szNickName,1,maxlength)..".."
        end
        nickname:setString(nameshow)

        local loveliness = ccui.ImageView:create("common/loveliness.png")
    	loveliness:setPosition(123, 39)
    	bangItemLayer:addChild(loveliness) 

    	local myloveValue = ccui.Text:create("33.5万","",18)
		myloveValue:setPosition(148, 41)
		myloveValue:setAnchorPoint(cc.p(0,0.5))
		myloveValue:setColor(cc.c3b(131, 66, 21))
		bangItemLayer:addChild(myloveValue)
		myloveValue:setName("myloveValue")
		myloveValue:setString(FormatNumToString(huntMarriage.dwLoveLiness))

		local loveWord = ccui.ImageView:create("hall/marry/loveWord.png")
		loveWord:setPosition(275, 76)
		bangItemLayer:addChild(loveWord)

		local lovemsg = ccui.Text:create("爱情宣言","",20)
        lovemsg:setColor(cc.c3b(131, 66, 21))
        lovemsg:setPosition(340, 72)
        bangItemLayer:addChild(lovemsg)


        ----跑马灯start
        local scrollTextContainer = ccui.Layout:create()
        scrollTextContainer:setContentSize(cc.size(220,22))
        -- scrollTextContainer:setBackGroundColorType(1)
        -- scrollTextContainer:setBackGroundColor(cc.c3b(100,123,100))
        scrollTextContainer:setPosition(231, 28)
        scrollTextContainer:setClippingEnabled(true)
        bangItemLayer:addChild(scrollTextContainer)

        local loveContent = ccui.Text:create("爱情宣言爱情宣言爱情宣言","",20)
        loveContent:setColor(cc.c3b(131, 66, 21))
        loveContent:setAnchorPoint(cc.p(0,0))
        loveContent:setPosition(0, 0)
        scrollTextContainer:addChild(loveContent)
        loveContent:setString(huntMarriage.strLoveStroy)
        --滚动
        if scrollTextContainer:getContentSize().width < loveContent:getContentSize().width then
            local moveDistance = loveContent:getContentSize().width - scrollTextContainer:getContentSize().width
            local moveDuration = moveDistance / 20

            local scrollAction = cc.RepeatForever:create(cc.Sequence:create(
                            cc.DelayTime:create(0.5),
                            cc.MoveBy:create(moveDuration, cc.p(-moveDistance,0)),
                            cc.DelayTime:create(1),
                            cc.CallFunc:create(function() 
                                loveContent:setPosition(cc.p(0,0))
                            end)
                        ))
            loveContent:runAction(scrollAction)
        end
        ----跑马灯end
        local songcaili = ccui.Button:create("hall/marry/song.png","hall/marry/song.png","hall/marry/songEnabled.png")
        songcaili:setPosition(539, 73)
        bangItemLayer:addChild(songcaili)
        songcaili:setTag(huntMarriage.dwUserID)
        songcaili:setPressedActionEnabled(true)
        songcaili:addTouchEventListener(
        	function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                	self:giveHandler(sender,huntMarriage)
                end
            end
        )
        -- print(myuserid,"···",huntMarriage.dwUserID)
        if myuserid == huntMarriage.dwUserID then
            songcaili:setEnabled(false)
            songcaili:setBright(false)
        else
            songcaili:setEnabled(true)
            songcaili:setBright(true)
        end
        local goldIcon = ccui.ImageView:create("common/gold.png")
        goldIcon:setPosition(496, 24)
        goldIcon:setScale(0.7)
        bangItemLayer:addChild(goldIcon)

        local cailiNum = ccui.Text:create("33.5万","",22)
        cailiNum:setColor(cc.c3b(131, 66, 21))
        cailiNum:setPosition(518, 27)
        cailiNum:setAnchorPoint(cc.p(0,0.5))
        bangItemLayer:addChild(cailiNum)
        cailiNum:setName("cailiNum")
        cailiNum:setString(FormatNumToString(huntMarriage.lGiftForMarry))

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(bangItemLayer:getContentSize())
        custom_item:addChild(bangItemLayer)
        custom_item:setTag(i)
     --    custom_item:setAnchorPoint(cc.p(0,1))
     --    custom_item:setBackGroundColorType(1)
    	-- custom_item:setBackGroundColor(cc.c3b(100,123,100))
        
        self.listView:pushBackCustomItem(custom_item)
        i = i+1
	end
end

function MarryLayer:giveHandler(sender,huntMarriage)
	local userinfo = DataManager:getMyUserInfo()
	if huntMarriage.lGiftForMarry > userInfo.score then
		local marriageTip = require("hall.marry.MarriageTip").new({kind=1,content="您现在的身家不够付彩礼！快去充值吧！"})
		self:addChild(marriageTip,10)
        return
	end
	local userID = sender:getTag()
	local propose = require("hall.marry.MarriagePropose").new(huntMarriage)
    self.selectName = huntMarriage.szNickName
	self:addChild(propose,10,101)
end

function MarryLayer:marriageProposeHandler(data)
    -- nResultCode 4   szDescribe  对方没有征婚您不能进行求婚!
    -- nResultCode 0   szDescribe
    local event = data.data
    if event.nResultCode == 0 then

        UserService:queryMarriagesInfo()
        UserService:sendQueryInsureInfo()

        local content = "恭喜您！\""..self.selectName.."\"接受了您的彩礼，现在你们是夫妻咯！"--event.szDescribe
        local marriageTip = require("hall.marry.MarriageTip").new({kind=2,content=content})
        self:addChild(marriageTip,10)

        local proposeLayer = self:getChildByTag(101);
        if proposeLayer then
            proposeLayer:removeFromParent();
        end

    elseif event.nResultCode == 6 then

        local content = event.szDescribe
        local marriageTip = require("hall.marry.MarriageTip").new({kind=1,content=content})
        self:addChild(marriageTip,10)

    elseif event.nResultCode == 999 then

        for k,huntMarriage in ipairs(self.currentMarriageList) do
            if huntMarriage.dwUserID == event.dwAcceptorUserID then
                huntMarriage.lGiftForMarry  = event.lGiftForMarry
                huntMarriage.lTargetUserGold = event.lTargetUserGold
                huntMarriage.dwTargetUserLevel = event.dwTargetUserLevel
                huntMarriage.dwTimeLimit = event.dwTimeLimit
                self:refreshList(self.currentMarriageList)
            end
        end

    else
        local content = event.szDescribe
        local marriageTip = require("hall.marry.MarriageTip").new({kind=2,content=content})
        self:addChild(marriageTip,10)
    end    

end

function MarryLayer:marriageHuntHandler(event)

end

function MarryLayer:marriageHuntCancelHandler(event)

end

function MarryLayer:marriageInfoHandler(event)
    self:refreshBottomUI(event.data)
end

function MarryLayer:refreshBottomUI(marriagesInfo)
    local userID = marriagesInfo.dwTargetUserID or 0
    if 0 == userID then
        for k,v in pairs(self.marriedUI) do
            v:hide()
        end
        for k,v in pairs(self.marryUI) do
            v:show()
        end
        self.marriagehuntCancel:hide()
    elseif -1 == userID then
        self.marriagehuntCancel:show()
        for k,v in pairs(self.marriedUI) do
            v:hide()
        end
        for k,v in pairs(self.marryUI) do
            v:hide()
        end
    else
        for k,v in pairs(self.marriedUI) do
            v:show()
        end
        for k,v in pairs(self.marryUI) do
            v:hide()
        end
        self.marriagehuntCancel:hide()
        local myInfo = DataManager:getMyUserInfo()
        local lefttime = marriagesInfo.dwDatediff
        local minute = lefttime%60
        local hour = (lefttime-minute)/60%24
        local day = ((lefttime-minute)/60-hour)/24
        self.bglayer:getChildByName("mynickname"):setString(myInfo.nickName)
        self.bglayer:getChildByName("myloveValue"):setString(myInfo:loveliness())
        self.bglayer:getChildByName("spouse"):setString(marriagesInfo.szNickName)
        self.bglayer:getChildByName("spouseloveValue"):setString(marriagesInfo.dwLoveLiness)
        self.bglayer:getChildByName("leftTimeTxt"):setString(day.."天"..hour.."小时"..minute.."分")
        self.myHead:setNewHead(myInfo.faceID, myInfo.platformID,myInfo.platformFace)
        self.spouseHead:setNewHead(marriagesInfo.wFaceID, marriagesInfo.szTokenID,marriagesInfo.szHeadFile)
    end
end

function MarryLayer:closeHandler()
	UserService:removeEventListener(self.QUERYHUNTMARRIAGES)
	self:removeFromParent()
end

return MarryLayer