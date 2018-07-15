local BankLayer = class("BankLayer", require("show.popView_Hall.baseWindow") );

function BankLayer:ctor()

    self.super.ctor(self, 1);

    self:setNodeEventEnabled(true)

    self.selectScore = 0
    self.selectInsure = 0

    local size = self:getContentSize();

    local title = display.newSprite("bank/bank_title.png", size.width/2, size.height/2+250);
    self:addChild(title);
    
    local coin = cc.Sprite:create("common/btn_icon_cz.png");
    coin:setPosition(cc.p(size.width/2+100, size.height/2+180));
    coin:setAnchorPoint(cc.p(1,0.5));
    coin:setScale(0.6);
    self:addChild(coin);

    self.score = AccountInfo.score
    self.insure = AccountInfo.insure

    self.myCoins = display.newTTFLabel({text = ""..FormatNumToString(self.score),
                                        size = 30,
                                        color = cc.c3b(255,224,20),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    self.myCoins:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    self.myCoins:setAnchorPoint(cc.p(0,0.5))
    self.myCoins:setPosition(cc.p(size.width/2+110, size.height/2+180))
    self:addChild(self.myCoins)

    local insidebg = ccui.ImageView:create("common/ty_scale_bg_1.png");
    insidebg:setScale9Enabled(true);
    insidebg:setContentSize(cc.size(606,114));
    insidebg:setPosition(cc.p(size.width/2,size.height/2+96));
    self:addChild(insidebg)

    local bankSprite = display.newSprite("hall/hall_btn_icon_bank.png", 60, insidebg:getContentSize().height/2);
    insidebg:addChild(bankSprite);

    self.myCoins_gui = display.newTTFLabel({text = "保险柜金币："..FormatNumToString(self.insure),
                                        size = 30,
                                        color = cc.c3b(255,224,20),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    self.myCoins_gui:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    self.myCoins_gui:setAnchorPoint(cc.p(0,0.5))
    self.myCoins_gui:setPosition(cc.p(110, insidebg:getContentSize().height/2))
    insidebg:addChild(self.myCoins_gui)

    local btn = ccui.Button:create("common/ty_green_btn.png");
    btn:setAnchorPoint(cc.p(0.5,0.5));
    btn:setPosition(cc.p(size.width/2+230, size.height/2-48));
    btn:onClick(function() self:cunRequest() end);
    self:addChild(btn);

    local btnText = display.newSprite("bank/bank_word_cun.png", btn:getContentSize().width/2, btn:getContentSize().height/2);
    btn:addChild(btnText);

    local btn = ccui.Button:create("common/ty_yellow_btn.png");
    btn:setAnchorPoint(cc.p(0.5,0.5));
    btn:setPosition(cc.p(size.width/2+230, size.height/2-160));
    btn:onClick(function() self:quRequest() end);
    self:addChild(btn);

    local btnText = display.newSprite("bank/bank_word_qu.png", btn:getContentSize().width/2, btn:getContentSize().height/2);
    btn:addChild(btnText);

    local cun_progress = cc.ControlSlider:create("bank/bank_process_bg.png","bank/bank_process_green.png","bank/bank_process_btn_lv.png")
    self:addChild(cun_progress)
    cun_progress:setPosition(440, size.height/2-48)
    cun_progress:setMinimumValue(0);
    cun_progress:setMaximumValue(100);
    cun_progress:registerControlEventHandler(
        function ()
            self:cunprogressHandler(cun_progress);
        end,
        cc.CONTROL_EVENTTYPE_VALUE_CHANGED
    )
    self.cun_progress = cun_progress;

    --可以存的最大钱数self.score
    self.can_cun_Coins = display.newTTFLabel({text = ""..FormatNumToString(self.score),
                                        size = 20,
                                        color = cc.c3b(255,224,20),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    self.can_cun_Coins:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    self.can_cun_Coins:setAnchorPoint(cc.p(0.5,0.5))
    self.can_cun_Coins:setPosition(cc.p(656, size.height/2-48))
    self:addChild(self.can_cun_Coins,10)

    self.cun_tip_pao_pao = display.newSprite("common/ty_tip_pao_pao.png", 286, size.height/2+8);
    self:addChild(self.cun_tip_pao_pao);

    self.cun_coin_text = display.newTTFLabel({text = "0",
                                        size = 24,
                                        color = cc.c3b(255,224,20),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    self.cun_coin_text:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    self.cun_coin_text:setPosition(cc.p(self.cun_tip_pao_pao:getContentSize().width/2, self.cun_tip_pao_pao:getContentSize().height/2+4))
    self.cun_tip_pao_pao:addChild(self.cun_coin_text)


    local qu_progress = cc.ControlSlider:create("bank/bank_process_bg.png","bank/bank_process_huan.png","bank/bank_process_btn_ye.png")
    self:addChild(qu_progress)
    qu_progress:setPosition(440, size.height/2-160)
    qu_progress:setMinimumValue(0);
    qu_progress:setMaximumValue(100);
    qu_progress:registerControlEventHandler(
        function ()
            self:quprogressHandler(qu_progress);
        end,
        cc.CONTROL_EVENTTYPE_VALUE_CHANGED
    )
    self.qu_progress = qu_progress;

    --可以取的最大钱数self.score
    self.can_qu_Coins = display.newTTFLabel({text = ""..FormatNumToString(self.insure),
                                        size = 20,
                                        color = cc.c3b(255,224,20),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    self.can_qu_Coins:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    self.can_qu_Coins:setAnchorPoint(cc.p(0.5,0.5))
    self.can_qu_Coins:setPosition(cc.p(656, size.height/2-160))
    self:addChild(self.can_qu_Coins,10)

    self.qu_tip_pao_pao = display.newSprite("common/ty_tip_pao_pao.png", 286, size.height/2-106);
    self:addChild(self.qu_tip_pao_pao);

    self.qu_coin_text = display.newTTFLabel({text = "0",
                                        size = 24,
                                        color = cc.c3b(255,224,20),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    self.qu_coin_text:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    self.qu_coin_text:setPosition(cc.p(self.qu_tip_pao_pao:getContentSize().width/2, self.qu_tip_pao_pao:getContentSize().height/2+4))
    self.qu_tip_pao_pao:addChild(self.qu_coin_text)

end

function BankLayer:cunprogressHandler(sender)

    local value = sender:getValue();

    local widthmax = self.cun_progress:getContentSize().width
    local posX = 286+widthmax*value/100.0
    self.cun_tip_pao_pao:setPositionX(posX);

    local scoreNow = self.score*value/100.0;
    self.selectScore = math.floor(scoreNow)

    self.cun_coin_text:setString(FormatNumToString(self.selectScore))
end

function BankLayer:quprogressHandler(sender)
    local value = sender:getValue();

    local widthmax = self.qu_progress:getContentSize().width
    local posX = 286+widthmax*value/100.0
    self.qu_tip_pao_pao:setPositionX(posX);

    local insureNow = self.insure*value/100.0;
    self.selectInsure = math.floor(insureNow);
    self.qu_coin_text:setString(FormatNumToString(self.selectInsure))
end

function BankLayer:cunRequest()
    if self.selectScore > 0 then
        if self.isInGame then
            Hall.showTips("抱歉，游戏中不能存钱！")
        else
            BankInfo:sendDepositRequest(self.selectScore) 
        end
    else
        -- print("存款数为0")
        Hall.showTips("存款数不能为0！")
    end
end

function BankLayer:quRequest()
    if self.selectInsure > 0 then
        BankInfo:sendWithdrawRequest(self.selectInsure)
    else
        -- print("取款数为0")
        Hall.showTips("取款数不能为0！")
    end
end

function BankLayer:onEnter()
    print("BankLayer:onEnter")
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.refreshScore))  
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.refreshInsure))
end

function BankLayer:onExit()
    print("BankLayer:onExit")
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function BankLayer:refreshScore()
    print(".....BankLayer:refreshScore")
    self.score = AccountInfo.score
    self.insure = AccountInfo.insure
    self.myCoins:setString(""..FormatNumToString(self.score))
    self.myCoins_gui:setString("保险柜金币："..FormatNumToString(self.insure))
    self.can_cun_Coins:setString(""..FormatNumToString(self.score))
    self.can_qu_Coins:setString(""..FormatNumToString(self.insure))
    self.cun_progress:setValue(0)
    self.qu_progress:setValue(0)
end

function BankLayer:refreshInsure()
    print(".....BankLayer:refreshInsure")
    self.score = AccountInfo.score
    self.insure = AccountInfo.insure
    self.myCoins:setString(""..FormatNumToString(self.score))
    self.myCoins_gui:setString("保险柜金币："..FormatNumToString(self.insure))
    self.can_cun_Coins:setString(""..FormatNumToString(self.score))
    self.can_qu_Coins:setString(""..FormatNumToString(self.insure))
    self.cun_progress:setValue(0)
    self.qu_progress:setValue(0)
end

function BankLayer:setInGame(isInGame)
    self.isInGame = isInGame
end

return BankLayer;