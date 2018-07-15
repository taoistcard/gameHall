local AnchorInfoLayer = class("AnchorInfoLayer", function() return display.newLayer(); end );

function AnchorInfoLayer:ctor()
    self:setContentSize(cc.size(530,210))
    self:createUI()
end

function AnchorInfoLayer:createUI()
    local anchorInfoBg = ccui.ImageView:create("common/panel.png")
    anchorInfoBg:setContentSize(cc.size(530,205))
    anchorInfoBg:setScale9Enabled(true)
    anchorInfoBg:setPosition(cc.p(265,105))
    self:addChild(anchorInfoBg)

    local anchorTableBg = ccui.ImageView:create("common/panel.png")
    anchorTableBg:setContentSize(cc.size(320,190))
    anchorTableBg:setScale9Enabled(true)
    anchorTableBg:setPosition(cc.p(165,102))
    self:addChild(anchorTableBg)

    local anchorTable = ccui.ImageView:create()
    anchorTable:setScale(0.27)
    anchorTable:setPosition(cc.p(160,95))
    anchorTableBg:addChild(anchorTable)
    self.anchorTable = anchorTable

    local headItem = ccui.ImageView:create()
    headItem:loadTexture("landlordVideo/vipAnchorHeadBg.png")
    headItem:setPosition(cc.p(70,145))
    headItem:setContentSize(cc.size(116,78))
    headItem:setScale9Enabled(true)
    headItem:setCapInsets(cc.rect(27,14,1,1))
    anchorTableBg:addChild(headItem)
    
    local caodan = cc.Sprite:create("landlordVideo/video_default_bg.png", cc.rect(0,0,112, 74))
    caodan:addTo(headItem)
    caodan:pos(58, 39)

    self.headImage = ccui.ImageView:create()
    self.headImage:setPosition(cc.p(58,39))
    headItem:addChild(self.headImage)



    self.roomNameLabel = ccui.Text:create()
    self.roomNameLabel:setFontSize(24)
    self.roomNameLabel:setString("超级大赢家的牌桌")
    self.roomNameLabel:setColor(cc.c3b(255,214,31))
    self.roomNameLabel:enableOutline(cc.c4b(73,36,13,255), 2)
    self.roomNameLabel:setAnchorPoint(cc.p(0,0.5))
    self.roomNameLabel:setPosition(cc.p(15,22))
    anchorTableBg:addChild(self.roomNameLabel)

    local nicknameTxt = ccui.Text:create()
    nicknameTxt:setFontSize(20)
    nicknameTxt:setString("姓  名：")
    nicknameTxt:setColor(cc.c3b(255,214,31))
    nicknameTxt:enableOutline(cc.c4b(73,36,13,255), 2)
    nicknameTxt:setAnchorPoint(cc.p(0,0.5))
    nicknameTxt:setPosition(cc.p(335,160))
    anchorInfoBg:addChild(nicknameTxt)

    self.nickNameLabel = ccui.Text:create()
    self.nickNameLabel:setFontSize(20)
    self.nickNameLabel:setString("超级大赢家")
    self.nickNameLabel:setColor(cc.c3b(250,255,255))
    self.nickNameLabel:enableOutline(cc.c4b(73,36,13,255), 2)
    self.nickNameLabel:setAnchorPoint(cc.p(0,0.5))
    self.nickNameLabel:setPosition(cc.p(405,160))
    anchorInfoBg:addChild(self.nickNameLabel)

    local anchorOnlineBg = ccui.ImageView:create("landlordVideo/anchorInfoTxtBg.png")
    anchorOnlineBg:setAnchorPoint(cc.p(0,0.5))
    anchorOnlineBg:setPosition(cc.p(340,100))
    anchorInfoBg:addChild(anchorOnlineBg)
    local anchorOnlineIcon = ccui.ImageView:create("landlordVideo/anchorOnlineIcon.png")
    anchorOnlineIcon:setPosition(cc.p(5,15))
    anchorOnlineBg:addChild(anchorOnlineIcon)
    local onlineTxt = ccui.Text:create()
    onlineTxt:setFontSize(20)
    onlineTxt:setString("人气")
    onlineTxt:setColor(cc.c3b(255,214,31))
    onlineTxt:enableOutline(cc.c4b(73,36,13,255), 2)
    onlineTxt:setAnchorPoint(cc.p(1,0.5))
    onlineTxt:setPosition(cc.p(60,15))
    anchorOnlineBg:addChild(onlineTxt)

    self.onlineNumLabel = ccui.Text:create()
    self.onlineNumLabel:setFontSize(18)
    self.onlineNumLabel:setString("4.5万")
    self.onlineNumLabel:setColor(cc.c3b(255,214,31))
    self.onlineNumLabel:enableOutline(cc.c4b(73,36,13,255), 2)
    self.onlineNumLabel:setAnchorPoint(cc.p(0,0.5))
    self.onlineNumLabel:setPosition(cc.p(415,100))
    anchorInfoBg:addChild(self.onlineNumLabel)

    local anchorLoveBg = ccui.ImageView:create("landlordVideo/anchorInfoTxtBg.png")
    anchorLoveBg:setAnchorPoint(cc.p(0,0.5))
    anchorLoveBg:setPosition(cc.p(340,40))
    anchorInfoBg:addChild(anchorLoveBg)
    local anchorLoveIcon = ccui.ImageView:create("landlordVideo/anchorLoveIcon.png")
    anchorLoveIcon:setPosition(cc.p(5,15))
    anchorLoveBg:addChild(anchorLoveIcon)
    local loveTxt = ccui.Text:create()
    loveTxt:setFontSize(18)
    loveTxt:setString("魅力")
    loveTxt:setColor(cc.c3b(255,135,49))
    loveTxt:enableOutline(cc.c3b(73,36,13), 2)
    loveTxt:setAnchorPoint(cc.p(1,0.5))
    loveTxt:setPosition(cc.p(60,15))
    anchorLoveBg:addChild(loveTxt)

    self.loveNumLabel = ccui.Text:create()
    self.loveNumLabel:setFontSize(18)
    self.loveNumLabel:setString("4.5万")
    self.loveNumLabel:setColor(cc.c3b(255,135,49))
    self.loveNumLabel:enableOutline(cc.c4b(73,36,13,255), 2)
    self.loveNumLabel:setAnchorPoint(cc.p(0,0.5))
    self.loveNumLabel:setPosition(cc.p(415,40))
    anchorInfoBg:addChild(self.loveNumLabel)
    
end

function AnchorInfoLayer:updateAnchorInfo(gameServer)
    if gameServer == nil then
        return
    end
    local gameServerID = gameServer:getServerID()
    --头像
    self.headImage:loadTexture("hall/vipRoom/viproom_default.png")
    self.headImage:setScale(0.28)
    --昵称
    local nickName = VideoAnchorManager:getAnchorName(gameServerID)
    self.nickNameLabel:setString(FormotGameNickName(nickName,6))
    self.roomNameLabel:setString(nickName.."的牌桌")
    --在线
    self.onlineNumLabel:setString(gameServer:getOnLineCount())
    --魅力
    local loveliness = VideoAnchorManager:getVipAnchorLoveliness(gameServer:getServerID())
    self.loveNumLabel:setString(loveliness)
    --牌桌
    local serverIndex = VideoAnchorManager:getAnchorGameServerIndex(gameServerID)
    if serverIndex then
        self.anchorTable:loadTexture("landlordVideo/vip_table_"..serverIndex..".png")
    end
end

return AnchorInfoLayer
