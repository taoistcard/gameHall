local GameBankLayer = class("GameBankLayer",function() return display.newLayer() end)

function GameBankLayer:ctor()
    self.score = 0
    self.insure = 0
    self.selectScore = 0
    self.selectInsure = 0


    self:setNodeEventEnabled(true)
    self:registerGameEvent();
    

    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    self:setContentSize(contentSize)
    -- 蒙板
    local maskLayer = ccui.ImageView:create("common/black.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)
    -- local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
    -- maskImg:setPosition(cc.p(757, winSize.height / 2));
    -- maskLayer:addChild(maskImg)

    self:createUI();
    self:queryHandler();
    
end
function GameBankLayer:onExit()

	self:removeGameEvent()
end
function GameBankLayer:onEnter()

end
function GameBankLayer:createUI()
    local contentSize = self:getContentSize()

    local bankConainer = ccui.ImageView:create()
    bankConainer:loadTexture("common/pop_bg.png")
    bankConainer:setScale9Enabled(true)
    bankConainer:setContentSize(cc.size(622,435))
    bankConainer:setCapInsets(cc.rect(115,215,1,1))
    bankConainer:setPosition(cc.p(display.cx,display.cy))
    self:addChild(bankConainer)

    local title_text_bg = ccui.ImageView:create()
    title_text_bg:loadTexture("common/pop_title.png")
    title_text_bg:setAnchorPoint(cc.p(0,0.5))
    title_text_bg:setPosition(cc.p(45,395))
    bankConainer:addChild(title_text_bg)
    local title_text = ccui.Text:create("银行", FONT_ART_TEXT, 24)
    title_text:setColor(cc.c3b(255,233,110));
    title_text:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    title_text:setPosition(cc.p(68,65));
    title_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    title_text_bg:addChild(title_text);

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(590,400));
    bankConainer:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeGameEvent();
                self:removeFromParent();
            end
        end
    )

    local treasureInfo = ccui.ImageView:create()
    treasureInfo:loadTexture("common/panel.png")
    treasureInfo:setContentSize(cc.size(520,140))
    treasureInfo:setScale9Enabled(true)
    treasureInfo:setCapInsets(cc.rect(39,39,1,1))
    treasureInfo:setPosition(cc.p(305,280))
    bankConainer:addChild(treasureInfo)
    local curGoldText = ccui.Text:create()
    curGoldText:setString("现有金币：")
    curGoldText:setColor(cc.c4b(255,249,85,255))
    curGoldText:enableOutline(cc.c4b(83,19,13,255), 2)
    curGoldText:setFontSize(24)
    curGoldText:setAnchorPoint(cc.p(0,0.5))
    curGoldText:setPosition(cc.p(30,90))
    treasureInfo:addChild(curGoldText)
    self.curGoldValue = ccui.Text:create()
    self.curGoldValue:setString("0")
    self.curGoldValue:setColor(cc.c3b(245,240,209))
    self.curGoldValue:setFontSize(24)
    self.curGoldValue:setAnchorPoint(cc.p(0,0.5))
    self.curGoldValue:setPosition(cc.p(140,90))
    treasureInfo:addChild(self.curGoldValue)
    local curInsureGoldText = ccui.Text:create()
    curInsureGoldText:setString("银行金币：")
    curInsureGoldText:setColor(cc.c4b(255,249,85,255))
    curInsureGoldText:enableOutline(cc.c4b(83,19,13,255), 2)
    curInsureGoldText:setFontSize(24)
    curInsureGoldText:setAnchorPoint(cc.p(0,0.5))
    curInsureGoldText:setPosition(cc.p(30,50))
    treasureInfo:addChild(curInsureGoldText)
    self.curInsureGoldValue = ccui.Text:create()
    self.curInsureGoldValue:setString("0")
    self.curInsureGoldValue:setColor(cc.c3b(200,191,100))
    self.curInsureGoldValue:setFontSize(24)
    self.curInsureGoldValue:setAnchorPoint(cc.p(0,0.5))
    self.curInsureGoldValue:setPosition(cc.p(140,50))
    treasureInfo:addChild(self.curInsureGoldValue)
    local goldCoins = ccui.ImageView:create("landlord1vs1/bankMoney.png");
    goldCoins:setPosition(cc.p(410, 60));
    treasureInfo:addChild(goldCoins);


    self.quprogress = cc.ControlSlider:create("hall/bank/bank_process_bg.png","hall/bank/bank_process_blue.png","hall/bank/bank_process_button.png")
    self.quprogress:setPosition(cc.p(230,110))
    bankConainer:addChild(self.quprogress)
    self.quprogress:setMinimumValue(0);
    self.quprogress:setMaximumValue(100);
    self.quprogress:registerControlEventHandler(
        function ()
            self:quprogressHandler(self.quprogress)
        end,cc.CONTROL_EVENTTYPE_VALUE_CHANGED
        )
    local qutips = ccui.ImageView:create("hall/bank/qipao.png")
    -- qutips:setScale9Enabled(true)
    qutips:setCapInsets(cc.rect(30,29,1,1))
    -- qutips:setContentSize(cc.size(120,59))
    qutips:setPosition(95, 165)
    self.qutips = qutips;
    bankConainer:addChild(qutips)
    local qutxt = ccui.Text:create()
    qutxt:setFontSize(22)
    qutxt:setColor(cc.c3b(82,53,21))
    qutxt:setString("0")
    qutxt:setPosition(40, 35)
    qutips:addChild(qutxt)
    self.qutxt = qutxt;
    local qubutton = ccui.Button:create("landlordVideo/video_greenbutton_bg.png");
    qubutton:setScale9Enabled(true)
    qubutton:setContentSize(cc.size(160,67))
    qubutton:setPosition(cc.p(500,110));
    qubutton:setTitleFontName(FONT_ART_BUTTON);
    qubutton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    qubutton:setTitleText("取金币");
    qubutton:setTitleColor(cc.c3b(255,255,255));
    qubutton:setTitleFontSize(28);
    bankConainer:addChild(qubutton);
    qubutton:setPressedActionEnabled(true);
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
    curInsureTxt:enableOutline(cc.c4b(40,6,3,255), 2)
    curInsureTxt:setString("0")
    curInsureTxt:setPosition(400, 70)
    curInsureTxt:setAnchorPoint(cc.p(1,0.5))
    bankConainer:addChild(curInsureTxt)
    self.curInsureTxt = curInsureTxt;
end

function GameBankLayer:quprogressHandler( sender )
    local value = sender:getValue();

    local insureNow = self.insure*value/100.0;
    local widthmax = self.quprogress:getContentSize().width
    local posX = 95+widthmax*value/100.0
    self.qutips:setPositionX(posX);

    self.selectInsure = math.floor(insureNow);
    self.qutxt:setString(FormatNumToString(self.selectInsure))
end
function GameBankLayer:resetProgress()
    self.selectInsure = 0
    self.qutxt:setString(FormatNumToString(self.selectInsure))
    local posX = 95
    self.qutips:setPositionX(posX);
    self.quprogress:setValue(0)
end

function GameBankLayer:queryHandler()
    BankInfo:sendQueryRequest()
end

--取钱
function GameBankLayer:qubuttonHandler()

    if self.insure <=0 then
        Hall.showTips("您没有可以去的金币了，请前往商城去充值吧", 1)
        return
    end

    if self.selectInsure > 0 then
        BankInfo:sendWithdrawRequest(self.selectInsure)
    end
    
end

--查询成功
function GameBankLayer:queryBackHandler(event)
    -- print("queryBackHandler",event.score,event.insure,tostring(self))
    self.score = event.score;
    self.insure = event.insure;
    self.curGoldValue:setString(FormatDigitToString(self.score, 1))
    self.curInsureGoldValue:setString(FormatDigitToString(self.insure, 1))
    self.curInsureTxt:setString(FormatDigitToString(self.insure, 1))
end

--银行操作成功
function GameBankLayer:bankSucceseHandler()
    self.score = AccountInfo.score;
    self.insure = AccountInfo.insure;

    print("score",AccountInfo.score,AccountInfo.insure)
    self.curInsureGoldValue:setString(FormatNumToString(AccountInfo.insure))
    self.curGoldValue:setString(FormatNumToString(AccountInfo.score));
    self.curInsureTxt:setString(FormatNumToString(AccountInfo.insure))
   
    self:resetProgress();
end

function GameBankLayer:registerGameEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.bankSucceseHandler))
end
function GameBankLayer:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end
return GameBankLayer