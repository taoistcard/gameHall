local baseWindow = require("show.popView_Hall.baseWindow")

local UserInfoLayer = class("UserInfoLayer", baseWindow)

function UserInfoLayer:ctor(userInfo,parent)
    self.userInfo = userInfo
    self.parent = parent
    self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    self:createUI();
    -- dump(userInfo, "userInfo")
    self:setDefaultData();
    -- self:setBlankMask()

    self.giftIdArr = {106,205,100,104}
    self.giftValue = {}
    self.giftValue[106] = 500
    self.giftValue[205] = 50000
    self.giftValue[100] = 500
    self.giftValue[104] = 50000
end

function UserInfoLayer:onEnter()
    self:bindEvent()
end

function UserInfoLayer:onExit()
    self:unBindEvent()
end

function UserInfoLayer:bindEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "buyPropertyResult", handler(self, self.onBuyPropertySuccess));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "usePropertyResult", handler(self, self.onUsePropertyResult));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "usePropertyBroadcast", handler(self, self.onPropertySuccess));
end

function UserInfoLayer:unBindEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function UserInfoLayer:createUI()

    local size = cc.Director:getInstance():getWinSize();
    local center = cc.p(size.width / 2, size.height / 2);
    local cx = center.x;
    local cy = center.y;
    local contentNode = self:getContentNode()

    local titleSprite = ccui.ImageView:create("hallUserCenter/meili_title.png");
    titleSprite:setPosition(cc.p(360, 515));
    contentNode:addChild(titleSprite, 2);

    --昵称
    local nicknameLabel = ccui.Text:create("昵称同步中", FONT_PTY_TEXT, 24);
    nicknameLabel:setColor(cc.c3b(255,255,255));
    nicknameLabel:setPosition(cc.p(136, 430));
    nicknameLabel:enableOutline(cc.c4b(0,0,0,255),2)
    contentNode:addChild(nicknameLabel);
    self.nicknameLabel = nicknameLabel;

    local headView = require("show.popView_Hall.HeadView").new(1,true);
    headView:setPosition(cc.p(136, 350));
    contentNode:addChild(headView);
    self.headView = headView;

    --Sex
    local manLabelText = "性别: 女"
    if self.userInfo.gender == 1 then
        manLabelText = "性别: 男"
    end
    local manLabel = ccui.Text:create(manLabelText, FONT_PTY_TEXT, 24);
    manLabel:setAnchorPoint(cc.p(0.5,0.5));
    manLabel:setColor(cc.c3b(255,255,255));
    manLabel:enableOutline(cc.c4b(0,0,0,255),2);
    manLabel:setPosition(cc.p(136, 260));
    contentNode:addChild(manLabel);
    self.manLabel = manLabel

    --ID
    local idLabel = ccui.Text:create("[游戏ID]", FONT_PTY_TEXT, 24);
    idLabel:setColor(cc.c3b(255,255,255));
    idLabel:enableOutline(cc.c4b(0,0,0,255),2);
    idLabel:setPosition(cc.p(457, 430));
    contentNode:addChild(idLabel);
    self.idLabel = idLabel;

    local startX = 230
    local addWidth = 20

    --gold
    local coinImage = ccui.ImageView:create();
    coinImage:loadTexture("common/ty_coin.png");
    coinImage:setPosition(cc.p(startX,370));
    coinImage:setAnchorPoint(cc.p(0,0.5));
    coinImage:scale(1.3);
    contentNode:addChild(coinImage)

    startX = startX + coinImage:getContentSize().width + addWidth

    local coinLabel = display.newTTFLabel({text = "0",
                                size = 22,
                                color = cc.c3b(255,224,20),
                                font = FONT_PTY_TEXT
                            })
    coinLabel:setAnchorPoint(cc.p(0,0.5));
    coinLabel:setPosition(cc.p(startX,370));
    coinLabel:enableOutline(cc.c4b(0,0,0,255),2);
    contentNode:addChild(coinLabel)
    self.coinLabel = coinLabel;

    startX = startX + coinLabel:getContentSize().width + addWidth

    --魅力值
    local meiLi = ccui.ImageView:create();
    meiLi:loadTexture("hallUserCenter/meili_icon.png");
    meiLi:setPosition(cc.p(startX, 370));
    meiLi:setAnchorPoint(cc.p(0,0.5));
    contentNode:addChild(meiLi)
    self.meiLi = meiLi

    startX = startX + meiLi:getContentSize().width +addWidth

    local meiLiLabel = display.newTTFLabel({text = "0",
                                size = 22,
                                color = cc.c3b(255,224,20),
                                font = FONT_PTY_TEXT
                            })
    meiLiLabel:setAnchorPoint(cc.p(0,0.5));
    meiLiLabel:setPosition(cc.p(startX,370));
    meiLiLabel:enableOutline(cc.c4b(0,0,0,255),2);
    contentNode:addChild(meiLiLabel)
    self.meiLiLabel = meiLiLabel;

    startX = startX + meiLiLabel:getContentSize().width + addWidth

    startX = 230

    --礼券
    local lqImage = ccui.ImageView:create();
    lqImage:loadTexture("common/ty_quan.png");
    lqImage:setPosition(cc.p(startX, 310));
    lqImage:setAnchorPoint(cc.p(0,0.5));
    contentNode:addChild(lqImage)

    startX = startX + lqImage:getContentSize().width + addWidth

    local coinLabel = display.newTTFLabel({text = "0",
                                size = 22,
                                color = cc.c3b(255,224,20),
                                font = FONT_PTY_TEXT
                            })
    coinLabel:setAnchorPoint(cc.p(0,0.5));
    coinLabel:setPosition(cc.p(startX, 310));
    coinLabel:enableOutline(cc.c4b(0,0,0,255),2);
    contentNode:addChild(coinLabel)
    self.lqLabel = coinLabel;

    startX = startX + coinLabel:getContentSize().width + addWidth

    --银行
    local bankboxImage = cc.Sprite:create("common/ty_bank.png");
    bankboxImage:setPosition(cc.p(startX, 310));
    bankboxImage:setAnchorPoint(cc.p(0,0.5));
    bankboxImage:scale(0.8)
    contentNode:addChild(bankboxImage);
    self.bankboxImage = bankboxImage

    startX = startX + bankboxImage:getContentSize().width + addWidth

    local bankboxLabel = display.newTTFLabel({text = "",
                                size = 22,
                                color = cc.c3b(255,224,20),
                                font = FONT_PTY_TEXT
                            })
    bankboxLabel:setAnchorPoint(cc.p(0,0.5));
    bankboxLabel:setPosition(cc.p(startX, 310));
    bankboxLabel:enableOutline(cc.c4b(0,0,0,255),2);
    contentNode:addChild(bankboxLabel);
    self.bankboxLabel = bankboxLabel;

    startX = startX + bankboxLabel:getContentSize().width + addWidth


    local signLabel = ccui.Text:create("个性签名：暂无", FONT_PTY_TEXT, 24);
    signLabel:setAnchorPoint(cc.p(0,0.5));
    signLabel:setColor(cc.c3b(255,255,255));
    signLabel:enableOutline(cc.c4b(0,0,0,255),2);
    signLabel:setPosition(cc.p(230, 260));
    contentNode:addChild(signLabel);
    self.signLabel = signLabel

    -- local contentLabel = ccui.Text:create("............................", FONT_PTY_TEXT, 24);
    -- contentLabel:setAnchorPoint(cc.p(0,0.5));
    -- contentLabel:setColor(cc.c3b(255,255,255));
    -- contentLabel:enableOutline(cc.c4b(0,0,0,255),2);
    -- contentLabel:setPosition(cc.p(230, 210));
    -- contentNode:addChild(contentLabel);

    local signLabel = ccui.Text:create("赠送道具：", FONT_PTY_TEXT, 26);
    signLabel:setAnchorPoint(cc.p(0,0.5));
    signLabel:setColor(cc.c3b(255,255,255));
    signLabel:enableOutline(cc.c4b(0,0,0,255),2);
    signLabel:setPosition(cc.p(60, 222));
    contentNode:addChild(signLabel);
    
    local meiliBg = ccui.ImageView:create();
    meiliBg:loadTexture("hallUserCenter/meili_bg.png");
    meiliBg:setScale9Enabled(true);
    meiliBg:setContentSize(cc.size(600, 136));
    meiliBg:setPosition(cc.p(362, 134));
    contentNode:addChild(meiliBg)

    local pos = {cc.p(362-222,150),cc.p(362-74,150),cc.p(362+74,150),cc.p(362+222,150)}
    local labels = {"+1","+100","-1","-100"}
    local filename = {"meili_flower","meili_car","meili_egg","meili_lei"}
    local value = {"500","5万","500","5万"}
    local btnName = {"bind_btn_bg_3","bind_btn_bg_3","bind_btn_bg_2","bind_btn_bg_2"}
    for i=1,4 do

        local addSprite = display.newSprite("hallUserCenter/"..filename[i]..".png")
        addSprite:setPosition(pos[i])
        contentNode:addChild(addSprite)

        local labelValue = display.newTTFLabel({text = "魅力值",
                                    size = 18,
                                    color = cc.c3b(255,255,255),
                                    align = cc.ui.TEXT_ALIGN_CENTER
                                })
        :align(display.CENTER,pos[i].x-30,pos[i].y+38)
        :addTo(contentNode)
        labelValue:enableOutline(cc.c4b(0,0,0,255),2)

        local labelValue = display.newTTFLabel({text = labels[i],
                                    size = 20,
                                    color = cc.c3b(255,255,255),
                                    align = cc.ui.TEXT_ALIGN_CENTER
                                })
        :align(display.CENTER,pos[i].x+40,pos[i].y-10)
        :addTo(contentNode)
        labelValue:enableOutline(cc.c4b(0,0,0,255),2)        

        local btn = ccui.Button:create("hallUserCenter/"..btnName[i]..".png");
        btn:setPosition(cc.p(pos[i].x,pos[i].y-56));
        btn:onClick(function() self:sendGift(i) end);
        contentNode:addChild(btn);

        local coin = cc.Sprite:create("common/ty_coin.png");
        coin:setPosition(cc.p(18, btn:getContentSize().height/2));
        coin:setAnchorPoint(cc.p(0,0.5));
        btn:addChild(coin);

        local coinLabel = display.newTTFLabel({text = value[i],
                                            size = 22,
                                            color = cc.c3b(255,255,255),
                                            font = FONT_PTY_TEXT,
                                            align = cc.ui.TEXT_ALIGN_CENTER
                                        })
        coinLabel:enableOutline(cc.c4b(0x03,0x08,0x06,255),1)
        coinLabel:setAnchorPoint(cc.p(0,0.5))
        coinLabel:setPosition(cc.p(57, btn:getContentSize().height/2-2))
        btn:addChild(coinLabel)
    end

end

function UserInfoLayer:setDefaultData()
    self.headView:setNewHead(self.userInfo.faceID, self.userInfo.platformID, self.userInfo.platformFace); 
    --vip信息
    if OnlineConfig_review == "off" and self.userInfo.memberOrder > 0 then
        self.headView:setVipHead(self.userInfo.memberOrder,1)
    end    
    local nickName = FormotGameNickName(self.userInfo.nickName, 5);
    self.nicknameLabel:setString(nickName);
    self.idLabel:setString("[游戏ID:" .. self.userInfo.gameID.."]");
    self.coinLabel:setString(FormatNumToString(self.userInfo.score));
    self.lqLabel:setString(FormatNumToString(self.userInfo.present));
    self.bankboxLabel:setString(FormatNumToString(self.userInfo.insure));
    self.meiLiLabel:setString(FormatNumToString(self.userInfo.loveLiness));

    if AccountInfo.gameId ~= self.userInfo.gameID then
        self.lqLabel:setString("---");
        self.bankboxLabel:setString("---");
    end

    self.bankboxImage:setPositionX(self.lqLabel:getPositionX()+self.lqLabel:getContentSize().width+20)
    self.bankboxLabel:setPositionX(self.bankboxImage:getPositionX()+self.bankboxImage:getContentSize().width+10)

    self.meiLi:setPositionX(self.coinLabel:getPositionX()+self.coinLabel:getContentSize().width+20)
    self.meiLiLabel:setPositionX(self.meiLi:getPositionX()+self.meiLi:getContentSize().width+20)

    if self.userInfo.signature and string.len(self.userInfo.signature) <= 0 then
        self.signLabel:setString("个性签名：暂无");
    elseif self.userInfo.signature then
        self.signLabel:setString("个性签名："..self.userInfo.signature);
    end
 
end

function UserInfoLayer:sendGift(index)

    if AccountInfo.gameId == self.userInfo.gameID then
        if self.userInfo.score < self.giftValue[self.giftIdArr[index]] then
            Hall.showTips("您的金币不足！")
            return
        end
    end

    PropertyInfo:sendBuyPropertyRequest(self.giftIdArr[index], 1)

end

function UserInfoLayer:onBuyPropertySuccess()
    if PropertyInfo.buyPropertyResult.code == 1 then
        --开始使用道具
        local propertyID = PropertyInfo.buyPropertyResult.propertyID
        local propertyCount = PropertyInfo.buyPropertyResult.propertyCount
        PropertyInfo:sendUsePropertyRequest(propertyID, propertyCount, self.userInfo.userID)
    elseif PropertyInfo.buyPropertyResult.code == 4 then
        Hall.showTips("您的金币不足！")
    end
end

function UserInfoLayer:onUsePropertyResult()
    local result = false
    local propertySuccess = PropertyInfo.usePropertyResult

    print("propertySuccess.code......",propertySuccess.code,propertySuccess.propertyCount)
    if propertySuccess.code == 1 then
        result = true
        Hall.showTips("赠送成功！", 1.0)

        self.meiLi:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.1, 1.1),
                cc.ScaleTo:create(0.2, 1.0),
                cc.ScaleTo:create(0.1, 1.05),
                cc.ScaleTo:create(0.2, 1.0)
            ))

        if propertySuccess.propertyID == 106 or propertySuccess.propertyID == 205 then
            self.userInfo.loveLiness = self.userInfo.loveLiness + self.giftValue[propertySuccess.propertyID]/500
        else
            self.userInfo.loveLiness = self.userInfo.loveLiness - self.giftValue[propertySuccess.propertyID]/500
        end

        local sequence = transition.sequence(
            {
                cc.ScaleTo:create(0.1, 1.2),
                cc.CallFunc:create(function() self.meiLiLabel:setString(FormatNumToString(self.userInfo.loveLiness)); end),
                cc.ScaleTo:create(0.1, 1.0)
            }
        )                        
        self.meiLiLabel:runAction(sequence)

        if AccountInfo.gameId == self.userInfo.gameID then
            -- print("测试",self.giftValue[propertySuccess.propertyID],propertySuccess.propertyID,self.userInfo.score)
            -- self.userInfo.score = self.userInfo.score - self.giftValue[propertySuccess.propertyID]
            self.coinLabel:setString(FormatNumToString(self.userInfo.score));
        end

    end
    if result == false then
        Hall.showTips("赠送失败！", 1.0)
    end    
end

function UserInfoLayer:onPropertySuccess()
end

return UserInfoLayer