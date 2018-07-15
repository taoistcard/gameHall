
local SettingNormalLayer = class("SettingNormalLayer", function() return display.newLayer() end)

local DateModel = require("zhajinhua.DateModel"):getInstance()

function SettingNormalLayer:ctor()

	self:createUI();
end

function SettingNormalLayer:createUI()
	local displaySize = cc.size(DESIGN_WIDTH,DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(636, 400));
    bgSprite:setPosition(cc.p(588,320));
    self:addChild(bgSprite);

    local titlebg = ccui.ImageView:create("common/pop_title.png");
    titlebg:setScale9Enabled(true);
    titlebg:setContentSize(cc.size(200, 52));
    titlebg:setPosition(cc.p(318, 365));
    bgSprite:addChild(titlebg);

    local titleword = display.newTTFLabel({text = "通用设置",
                                size = 24,
                                color = cc.c4b(254, 234, 113,255),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })

    titleword:enableOutline(cc.c4b(137,0,167,200), 2)
    titleword:setPosition(100, 28)
    titlebg:addChild(titleword)

	local CHECKBOX_BUTTON_IMAGES = {
	    off = "hall/setting/btn_off.png",
	    off_pressed = "hall/setting/btn_off.png",
	    off_disabled = "hall/setting/btn_off.png",
	    on = "hall/setting/btn_on.png",
	    on_pressed = "hall/setting/btn_on.png",
	    on_disabled = "hall/setting/btn_on.png",
	}


    local music = display.newTTFLabel({text = "进入房间自动坐下",
                                size = 28,
                                color = cc.c3b(255,255,255),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(bgSprite)
    music:setAnchorPoint(cc.p(0,0.5))
    music:setPosition(50, 320)

    local checkBoxButton1 = ccui.Button:create("hall/setting/btn_on.png","hall/setting/btn_on.png");
	if DateModel:getAutoSitDown() == true then
		checkBoxButton1:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
	else
		checkBoxButton1:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
	end
	
    bgSprite:addChild(checkBoxButton1)
    checkBoxButton1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
            	Click();
            	if DateModel:getAutoSitDown() == true then
            		checkBoxButton1:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
            		DateModel:setAutoSitDown(false)
            	else
            		checkBoxButton1:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
            		DateModel:setAutoSitDown(true)
            	end
            end
        end
    )

    checkBoxButton1:setPosition(450, 320)



    local musicEffect = display.newTTFLabel({text = "牌型提示",
                                size = 28,
                                color = cc.c3b(255,255,255),
                                font = FONT_ART_TEXT,
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(bgSprite)
    musicEffect:setAnchorPoint(cc.p(0,0.5))
    musicEffect:setPosition(50, 240)

    local checkBoxButton2 = ccui.Button:create();
	if DateModel:getTiShiPaiXing() == true then
		checkBoxButton2:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
	else
		checkBoxButton2:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
	end
    bgSprite:addChild(checkBoxButton2)
    checkBoxButton2:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
            	Click();
            	if DateModel:getTiShiPaiXing() == true then
            		checkBoxButton2:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
            		DateModel:setTiShiPaiXing(false)
            	else
            		checkBoxButton2:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
            		DateModel:setTiShiPaiXing(true)
            	end
                

            end
        end
    )

    checkBoxButton2:setPosition(450, 240)

    

    local music = display.newTTFLabel({text = "是否允许旁观",
                                size = 28,
                                color = cc.c3b(255,255,255),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(bgSprite)
    music:setAnchorPoint(cc.p(0,0.5))
    music:setPosition(50, 160)

    local checkBoxButton3 = ccui.Button:create("hall/setting/btn_on.png","hall/setting/btn_on.png");
    if DateModel:getAllowLookOne() == true then
        checkBoxButton3:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
    else
        checkBoxButton3:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
    end
    
    bgSprite:addChild(checkBoxButton3)
    checkBoxButton3:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click();
                if DateModel:getAllowLookOne() == true then
                    checkBoxButton3:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
                    DateModel:setAllowLookOne(false)
                else
                    checkBoxButton3:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
                    DateModel:setAllowLookOne(true)
                end
            end
        end
    )

    checkBoxButton3:setPosition(450, 160)




    local music = display.newTTFLabel({text = "聊天屏蔽",
                                size = 28,
                                color = cc.c3b(255,255,255),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(bgSprite)
    music:setAnchorPoint(cc.p(0,0.5))
    music:setPosition(50, 80)

    local checkBoxButton4 = ccui.Button:create("hall/setting/btn_on.png","hall/setting/btn_on.png");
    if DateModel:getListenChat() == true then
        checkBoxButton4:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
    else
        checkBoxButton4:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
    end
    
    bgSprite:addChild(checkBoxButton4)
    checkBoxButton4:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                Click();
                if DateModel:getListenChat() == true then
                    checkBoxButton4:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
                    DateModel:setListenChat(false)
                else
                    checkBoxButton4:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
                    DateModel:setListenChat(true)
                end
            end
        end
    )

    checkBoxButton4:setPosition(450, 80)



    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(891,507));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	Click();
                self:removeFromParent();

            end
        end
    )
end

function SettingNormalLayer:helpHandler()
    local help = require("hall.HelpLayer").new()

    self:addChild(help)
end
function SettingNormalLayer:musicHandler( checkbox )

	if checkbox:isButtonSelected() then
        -- SoundManager.saveMusicSwitch(1)
        print("isButtonSelected")
    else
        -- SoundManager.saveMusicSwitch(0)
    end
    Click();
end
function SettingNormalLayer:musicEffectHandler( checkbox )	
	if checkbox:isButtonSelected() then
        SoundManager.saveSoundSwitch(1)
    else
        SoundManager.saveSoundSwitch(0)
    end
    Click();
end
function SettingNormalLayer:fankuiHandler( )
--	Hall.showTips("反馈",1)
	PlatformFeedback();
	Click();
end
return SettingNormalLayer