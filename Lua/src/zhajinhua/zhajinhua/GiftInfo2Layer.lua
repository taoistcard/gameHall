local GiftInfo2Layer = class("GiftInfo2Layer", function() return display.newLayer() end )

function GiftInfo2Layer:ctor(params)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.sendGiftCallBack = params.sendGiftFunc
    self.sendGiftCallBackTarget = params.sendGiftCallBackTarget
    self:createUI(params.sceneID)
    self.targetUserID = nil
    self.targetUserIDArray = nil
    self:setNodeEventEnabled(true)
end
function GiftInfo2Layer:onEnter()
    -- if NEW_SERVER then
    --     self.handler1 = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_INSURE_FOR_ROOMBANK, handler(self, self.queryBackHandler))
    -- else
    --     self.handler1 = GameCenter:addEventListener(GameCenterEvent.EVENT_QUERY_INSURE_FOR_GAMEBANK, handler(self, self.queryBackHandler))
    -- end
    self.bindIds = {}
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.queryBackHandler))

end
function GiftInfo2Layer:onExit()
    -- if NEW_SERVER then
    --     UserService:removeEventListener(self.handler1)
    -- else
    --     GameCenter:removeEventListener(self.handler1)
    -- end
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end
function GiftInfo2Layer:createUI(sceneID)
    local popBg = ccui.ImageView:create()
    popBg:loadTexture("view/frame3.png")
    popBg:setScale9Enabled(true)
    popBg:setContentSize(cc.size(438,421))
    popBg:setPosition(543,303)
    self:addChild(popBg)


    local kuangBg = ccui.ImageView:create("giftLayer/kuangBg.png")
    kuangBg:setScale9Enabled(true)
    kuangBg:setContentSize(cc.size(140,28))
    kuangBg:setPosition(118, 388)
    popBg:addChild(kuangBg)
    local chip = ccui.ImageView:create("hall/room/chouma_icon.png")
    chip:setPosition(6, 12)
    chip:setScale(0.7)
    kuangBg:addChild(chip)
    local curGoldLabel = ccui.Text:create()
    curGoldLabel:setFontSize(17)
    curGoldLabel:setColor(cc.c3b(0xf6,0xfe,0))
    curGoldLabel:enableOutline(cc.c3b(0x3a,0x13,0), 2)
    curGoldLabel:setAnchorPoint(cc.p(0,0.5))
    curGoldLabel:setPosition(cc.p(32,15))
    kuangBg:addChild(curGoldLabel)
    curGoldLabel:setString(FormatDigitToString(DataManager:getMyUserInfo().score, 1))
    self.curGoldLabel = curGoldLabel

    local kuangBg = ccui.ImageView:create("giftLayer/kuangBg.png")
    kuangBg:setScale9Enabled(true)
    kuangBg:setContentSize(cc.size(140,28))
    kuangBg:setPosition(292, 388)
    popBg:addChild(kuangBg)
    local chip = ccui.ImageView:create("common/hall_icon_bank.png")
    chip:setPosition(6, 12)
    chip:setScale(0.7)
    kuangBg:addChild(chip)
    local curGoldLabel = ccui.Text:create()
    curGoldLabel:setFontSize(17)
    curGoldLabel:setColor(cc.c3b(0xf6,0xfe,0))
    curGoldLabel:enableOutline(cc.c3b(0x3a,0x13,0), 2)
    curGoldLabel:setAnchorPoint(cc.p(0,0.5))
    curGoldLabel:setPosition(cc.p(32,15))
    kuangBg:addChild(curGoldLabel)
    curGoldLabel:setString(FormatDigitToString(DataManager:getMyUserInfo().insure, 1))
    self.bankLabel = curGoldLabel

    local giftInfoScrollView = ccui.ListView:create()
    giftInfoScrollView:setTouchEnabled(true)
    giftInfoScrollView:setContentSize(cc.size(390, 350))
    giftInfoScrollView:setPosition(cc.p(28,12))
    giftInfoScrollView:setDirection(ccui.ScrollViewDir.vertical)
    popBg:addChild(giftInfoScrollView)

    local giftIndexArr = {100,103,104,106,110,205}--{18,19,208,209,210,211}--{500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515}
    
    local propertyCount = #giftIndexArr--PropertyConfigInfo:propertyCount()
    local row = 1
    local col = 1
    if (propertyCount % 3) == 0 then
        row = propertyCount / 3
    else
        row = math.modf(propertyCount / 3) + 1
    end
    -- giftInfoScrollView:setInnerContainerSize(cc.size(500, 162 * row))
    
    for i=1,row do

        local customItem = ccui.Layout:create()
        customItem:setContentSize(cc.size(390,175))
        customItem:setPosition(cc.p(0,0))
        giftInfoScrollView:pushBackCustomItem(customItem)
        for j=1,3 do
            if (i-1)*3+j <= propertyCount then
                local gift = PropertyConfigInfo:obtainPropertyobjectByIndex(giftIndexArr[(i-1)*3+j])
                local posX = (j - 1) * 130
                local posY = (row - 1) * 0
                local giftItem = require("zhajinhua.GiftItem2Layer").new({sceneID=sceneID,
                                                                            sendGiftFunc=
                                                                                function(giftIndex,giftPrice,giftCount,isall) 
                                                                                    self:sendGift(giftIndex,giftPrice,giftCount,isall) 
                                                                                end
                                                                                ,parentContainer=self})
                giftItem:updateGiftItemInfo(gift)
                giftItem:setPosition(posX, posY)
                customItem:addChild(giftItem)
            end
        end
    end

    --关闭按钮
    local closeButton = ccui.Button:create("common/close2.png")
    closeButton:setPressedActionEnabled(true)
    closeButton:setPosition(cc.p(428,416))
    popBg:addChild(closeButton)
    closeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager.playSound("sound/buttonclick.mp3")
                self:onCloseClick()
            end
        end)
end

function GiftInfo2Layer:showGiftInfo2Layer(targetUserID,targetUserIDArray)
    -- if NEW_SERVER then
    --     UserService:sendQueryInsureInfo()
    -- else
    --     local dwUserID = PlayerInfo:getMyUserID()
    --     GameCenter:queryInsureInfoInGame(dwUserID)
    -- end
    BankInfoInGame:sendQueryRequest()
    self.targetUserID = targetUserID
    self.targetUserIDArray = targetUserIDArray
    self:show()
end
function GiftInfo2Layer:queryBackHandler(event)
    print("GiftInfo2Layer-queryBackHandler111 ",AccountInfo.score, AccountInfo.insure)
    self.score = AccountInfo.score;
    self.insure = AccountInfo.insure
    self.curGoldLabel:setString(FormatDigitToString(self.score, 1))
    self.bankLabel:setString(FormatDigitToString(self.insure, 1))
end
function GiftInfo2Layer:sendGift(giftIndex,giftPrice,giftCount,isall)
    if isall == nil then
        print("sendGift:",giftIndex,giftPrice,giftCount,tostring(self))
        -- self:dispatchEvent({name=GameCenterEvent.EVENT_BUY_PROPERTY,giftIndex=giftIndex,giftPrice=giftPrice,giftCount=giftCount,targetUserID=self.targetUserID})
        self.sendGiftCallBack(self.sendGiftCallBackTarget,{giftIndex=giftIndex,giftPrice=giftPrice,giftCount=giftCount,targetUserID=self.targetUserID})
    else
        self:sendGiftAll(giftIndex,giftPrice,giftCount)
    end
end

function GiftInfo2Layer:sendGiftAll(giftIndex,giftPrice,giftCount)
    for i,v in ipairs(self.targetUserIDArray) do
        if DataManager:getMyUserID() == v then--如果是减魅力的，那么不送自己
            local gift = PropertyConfigInfo:obtainPropertyobjectByIndex(giftIndex)
            if gift:getRecvLoveLiness()>0 then
                -- self:dispatchEvent({name=GameCenterEvent.EVENT_BUY_PROPERTY,giftIndex=giftIndex,giftPrice=giftPrice,giftCount=giftCount,targetUserID=v})
                self.sendGiftCallBack(self.sendGiftCallBackTarget,{giftIndex=giftIndex,giftPrice=giftPrice,giftCount=giftCount,targetUserID=v})
            end
        else
            -- self:dispatchEvent({name=GameCenterEvent.EVENT_BUY_PROPERTY,giftIndex=giftIndex,giftPrice=giftPrice,giftCount=giftCount,targetUserID=v})
            self.sendGiftCallBack(self.sendGiftCallBackTarget,{giftIndex=giftIndex,giftPrice=giftPrice,giftCount=giftCount,targetUserID=v})
        end
        
    end
end
function GiftInfo2Layer:onCloseClick()
    self:hide()
end

return GiftInfo2Layer
