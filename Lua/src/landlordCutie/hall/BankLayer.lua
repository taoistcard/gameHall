local BankLayer = class("BankLayer",function() return display.newLayer() end)

function BankLayer:ctor(inGame)
    self.inGame = inGame or false
    self.score = 0
    self.insure = 0
    self.selectScore = 0
    self.selectInsure = 0

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    self:registerGameEvent();

    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize
    if inGame then
        contentSize = cc.size(656,winSize.height)
    else
        contentSize = cc.size(winSize.width,winSize.height)
    end
    self:setContentSize(contentSize)
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(contentSize);
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(contentSize.width/2, display.cy));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    self:createUI();

    BankInfo:sendQueryRequest()
end

function BankLayer:createUI()
    local contentSize = self:getContentSize()

    local bankConainer = ccui.ImageView:create("common/pop_bg.png");
    bankConainer:setScale9Enabled(true);
    bankConainer:setContentSize(cc.size(674, 433));
    bankConainer:setPosition(cc.p(588,320));
    self:addChild(bankConainer);

    local tiao = ccui.ImageView:create("hall/bank/tiao.png");
    tiao:setPosition(cc.p(620,518));
    self:addChild(tiao);

    local pop_title = ccui.ImageView:create("common/pop_title.png");
    pop_title:setPosition(cc.p(390,497));
    self:addChild(pop_title);

    local pig = ccui.ImageView:create("hall/bank/pig.png");
    pig:setPosition(cc.p(358,522));
    self:addChild(pig);

    local bankword = display.newTTFLabel({text = "银行",
                                size = 24,
                                color = cc.c3b(255,233,110),
                                font = FONT_ART_TEXT,
                            })
                :addTo(self)
    bankword:setPosition(413, 520)
    bankword:setTextColor(cc.c4b(251,248,142,255))
    bankword:enableOutline(cc.c4b(137,0,167,200), 2)

    local texttitle = ccui.Text:create()
    texttitle:setString("VIP等级越高，存金币小费越便宜哦！")
    texttitle:setColor(cc.c4b(255,233,110,255))
    texttitle:enableOutline(cc.c4b(141,0,166,255), 2)
    texttitle:setFontSize(20)
    texttitle:setPosition(624, 521)
    self:addChild(texttitle)

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(892,507));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeGameEvent();
                self:removeFromParent();
            end
        end
    )



    -- local treasureInfo = ccui.ImageView:create()
    -- treasureInfo:loadTexture("landlordVideo/otherplayer_bg.png")
    -- treasureInfo:setContentSize(cc.size(460,120))
    -- treasureInfo:setScale9Enabled(true)
    -- treasureInfo:setCapInsets(cc.rect(39,39,1,1))
    -- treasureInfo:setPosition(cc.p(275,410))
    -- self:addChild(treasureInfo)

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(535, 97));
    panel:setPosition(cc.p(588,403));
    self:addChild(panel);

    self.curGoldValue = ccui.Text:create()
    self.curGoldValue:setString("携带金币：0")
    self.curGoldValue:setColor(cc.c3b(200,191,100))
    self.curGoldValue:setFontSize(22)
    self.curGoldValue:setAnchorPoint(cc.p(1,0.5))
    self.curGoldValue:setPosition(cc.p(840,479))
    self:addChild(self.curGoldValue)

    self.curInsureGoldValue = ccui.Text:create()
    self.curInsureGoldValue:setString("银行金币：0")
    self.curInsureGoldValue:setColor(cc.c3b(200,191,100))
    self.curInsureGoldValue:setFontSize(22)
    self.curInsureGoldValue:setAnchorPoint(cc.p(0,0.5))
    self.curInsureGoldValue:setPosition(cc.p(500,400))
    self:addChild(self.curInsureGoldValue)

    local gold1 = ccui.ImageView:create("common/gold.png");
    gold1:setPosition(cc.p(388, 377));
    self:addChild(gold1);

    local gold2 = ccui.ImageView:create("common/gold.png");
    gold2:setPosition(cc.p(439, 395));
    self:addChild(gold2);

    local gold3 = ccui.ImageView:create("common/gold.png");
    gold3:setPosition(cc.p(402, 422));
    self:addChild(gold3);

---存银行

    local cunprogress = cc.ControlSlider:create("hall/bank/bank_process_bg.png","hall/bank/bank_process_blue.png","hall/bank/bank_process_button.png")
    self:addChild(cunprogress)
    cunprogress:setPosition(466, 284)
    cunprogress:setMinimumValue(0);
    cunprogress:setMaximumValue(100);
    cunprogress:registerControlEventHandler(
        function (  )
            self:cunprogressHandler(cunprogress);
        end,
        cc.CONTROL_EVENTTYPE_VALUE_CHANGED
        )
    self.cunprogress = cunprogress;

    local cuntips = ccui.ImageView:create("hall/bank/qipao.png")
    -- cuntips:setScale9Enabled(true)
    -- cuntips:setCapInsets(cc.rect(23,20,1,1))
    -- cuntips:setContentSize(cc.size(110,40))
    cuntips:setPosition(cc.p(330, 325))
    self:addChild(cuntips)
    self.cuntips = cuntips;
    local cuntxt = ccui.Text:create()
    cuntxt:setFontSize(18)
    cuntxt:setColor(cc.c3b(82,53,21))
    cuntxt:setString("0")
    cuntxt:setPosition(35, 30)
    cuntips:addChild(cuntxt)
    self.cuntxt = cuntxt;
    local cunbutton = ccui.Button:create("common/button_blue.png");
    cunbutton:setScale(0.8)
    cunbutton:setPosition(cc.p(813,288));
    self:addChild(cunbutton);
    cunbutton:setPressedActionEnabled(true);
    cunbutton:setTitleFontName(FONT_ART_BUTTON)
    cunbutton:setTitleText("存金币");
    cunbutton:setTitleColor(cc.c3b(255,255,255));
    cunbutton:setTitleFontSize(28);
    cunbutton:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    cunbutton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:cunbuttonHandler();

            end
        end
    )
    local curGoldTxt = ccui.Text:create()
    curGoldTxt:setFontSize(22)
    curGoldTxt:setColor(cc.c3b(200,191,100))
    curGoldTxt:setString("0")
    curGoldTxt:setPosition(681, 285)
    -- curGoldTxt:setAnchorPoint(cc.p(1,0.5))
    self:addChild(curGoldTxt)
    self.curGoldTxt = curGoldTxt;

    --取钱
    self.quprogress = cc.ControlSlider:create("hall/bank/bank_process_bg.png","hall/bank/bank_process_green.png","hall/bank/bank_process_button.png")
    self.quprogress:setPosition(cc.p(466,192))
    self:addChild(self.quprogress)
    self.quprogress:setMinimumValue(0);
    self.quprogress:setMaximumValue(100);
    self.quprogress:registerControlEventHandler(
        function ()
            self:quprogressHandler(self.quprogress)
        end,cc.CONTROL_EVENTTYPE_VALUE_CHANGED
        )
    local qutips = ccui.ImageView:create("hall/bank/qipao.png")
    -- qutips:setScale9Enabled(true)
    -- qutips:setCapInsets(cc.rect(23,20,1,1))
    -- qutips:setContentSize(cc.size(110,40))
    qutips:setPosition(330, 227)
    self.qutips = qutips;
    self:addChild(qutips)
    local qutxt = ccui.Text:create()
    qutxt:setFontSize(18)
    qutxt:setColor(cc.c3b(82,53,21))
    qutxt:setString("0")
    qutxt:setPosition(35, 30)
    qutips:addChild(qutxt)
    self.qutxt = qutxt;
    local qubutton = ccui.Button:create("common/button_green.png");
    qubutton:setScale(0.8)
    qubutton:setPosition(cc.p(812,195));
    self:addChild(qubutton);
    qubutton:setPressedActionEnabled(true);
    qubutton:setTitleFontName(FONT_ART_BUTTON)
    qubutton:setTitleText("取金币");
    qubutton:setTitleColor(cc.c3b(255,255,255));
    qubutton:setTitleFontSize(28);
    qubutton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    qubutton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:qubuttonHandler();

            end
        end
    )
    local curInsureTxt = ccui.Text:create()
    curInsureTxt:setFontSize(22)
    curInsureTxt:setColor(cc.c3b(200,191,100))
    curInsureTxt:setString("0")
    curInsureTxt:setPosition(681, 191)
    -- curInsureTxt:setAnchorPoint(cc.p(1,0.5))
    self:addChild(curInsureTxt)
    self.curInsureTxt = curInsureTxt;
end
function BankLayer:cunprogressHandler(sender)
    local value = sender:getValue();

    local scoreNow = self.score*value/100.0;
    local widthmax = self.cunprogress:getContentSize().width
    local posX = 330+widthmax*value/100.0
    self.cuntips:setPositionX(posX);
    self.selectScore = math.floor(scoreNow)
    self.cuntxt:setString(FormatNumToString(self.selectScore))
end
function BankLayer:quprogressHandler( sender )
    local value = sender:getValue();

    local insureNow = self.insure*value/100.0;
    local widthmax = self.quprogress:getContentSize().width
    local posX = 330+widthmax*value/100.0
    self.qutips:setPositionX(posX);

    self.selectInsure = math.floor(insureNow);
    self.qutxt:setString(FormatNumToString(self.selectInsure))
end
function BankLayer:resetProgress()
    self.selectScore = 0
    self.cuntxt:setString(FormatNumToString(self.selectScore))
    local posX = 330
    self.cuntips:setPositionX(posX);
    self.cunprogress:setValue(0)

    self.selectInsure = 0
    self.qutxt:setString(FormatNumToString(self.selectInsure))
    local posX = 330
    self.qutips:setPositionX(posX);
    self.quprogress:setValue(0)
end
function BankLayer:queryHandler()
    local dwUserID = DataManager:getMyUserID()
    print("DataManager:getMyUserID()",dwUserID)

    if self.inGame == false then
        
        UserService:sendQueryInsureInfo()
    else
        local queryInsureInfo = protocol.hall.treasureInfo_pb.CMD_GR_C_QueryInsureInfo_Pro()
        queryInsureInfo.cbActivityGame = dwUserID
        local pData = queryInsureInfo:SerializeToString()
        local pDataLen = string.len(pData)

        local main = CMD_GameServer.MDM_GR_INSURE
        local sub = CMD_GameServer.SUB_GR_QUERY_INSURE_INFO
        
        GameCenter:sendData(main,sub,pData,pDataLen)
    end
end

--取钱
function BankLayer:qubuttonHandler()
    if self.insure <=0 then
        Hall.showTips("您没有可以去的金币了，请前往商城去充值吧", 1)
        return
    end

    if self.selectInsure > 0 then
        BankInfo:sendWithdrawRequest(self.selectInsure)
    end
end

--存钱
function BankLayer:cunbuttonHandler()
    if self.inGame == false then
        if self.selectScore > 0 then
            BankInfo:sendDepositRequest(self.selectScore)
        end
    else
        Hall.showTips("游戏中不能存筹码",2) 
    end
end

--银行操作成功
function BankLayer:bankSucceseHandler()
    self.score = AccountInfo.score;
    self.insure = AccountInfo.insure;

    self.curInsureGoldValue:setString("银行金币："..FormatNumToString(AccountInfo.insure))
    self.curGoldValue:setString("携带金币："..FormatNumToString(AccountInfo.score));
    self.curInsureTxt:setString(FormatNumToString(AccountInfo.insure))
    self.curGoldTxt:setString(FormatNumToString(AccountInfo.score));

    self:resetProgress();
end

--银行操作失败
function BankLayer:bankFailureHandler(event)
    Hall.showTips(event.msg)
end

function BankLayer:registerGameEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.bankSucceseHandler))
end

function BankLayer:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

return BankLayer