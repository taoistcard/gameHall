local SettingLayer = class("SettingLayer", function() return display.newLayer() end)

function SettingLayer:ctor()

	self:createUI();
end

function SettingLayer:createUI()
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

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(674, 433));
    bgSprite:setPosition(cc.p(588,320));
    self:addChild(bgSprite);

    local titlebg = ccui.ImageView:create("common/pop_title.png");
    -- titlebg:setScale9Enabled(true);
    -- titlebg:setContentSize(cc.size(674, 433));
    titlebg:setPosition(cc.p(389,497));
    self:addChild(titlebg);

    local titleicon = cc.Sprite:create("hall/setting/setIcon.png")
    titleicon:setPosition(363, 521)
    self:addChild(titleicon)

    local titleword = display.newTTFLabel({text = "设置",
                                size = 24,
                                color = cc.c4b(254, 234, 113,255),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })

    -- titleword:setString("设置")
    -- titleword:setFontSize(24)
    -- titleword:setColor(cc.c3b(254, 234, 113))
    titleword:enableOutline(cc.c4b(137,0,167,200), 2)
    titleword:setPosition(412, 519)
    self:addChild(titleword)

	local CHECKBOX_BUTTON_IMAGES = {
	    off = "hall/setting/btn_off.png",
	    off_pressed = "hall/setting/btn_off.png",
	    off_disabled = "hall/setting/btn_off.png",
	    on = "hall/setting/btn_on.png",
	    on_pressed = "hall/setting/btn_on.png",
	    on_disabled = "hall/setting/btn_on.png",
	}

    -- local music = cc.Sprite:create("hall/setting/music.png")
    -- music:setPosition(297, 331)
    -- self:addChild(music)
    local music = display.newTTFLabel({text = "音乐",
                                size = 28,
                                color = cc.c3b(255,255,255),
                                font = FONT_ART_TEXT,
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(self)
    music:setPosition(338, 387)

    local layoutLayer = ccui.Layout:create()
    self:addChild(layoutLayer)
    local checkBoxButton1 = ccui.Button:create("hall/setting/btn_on.png","hall/setting/btn_on.png");
	if SoundManager.bOpenMusic == 1 then
		checkBoxButton1:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
	else
		checkBoxButton1:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
	end
	
    self:addChild(checkBoxButton1)
    checkBoxButton1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	Click();
            	if SoundManager.bOpenMusic == 1 then
                    SoundManager.stopMusic();
            		checkBoxButton1:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
            		SoundManager.saveMusicSwitch(0)
            	else
            		checkBoxButton1:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
            		SoundManager.saveMusicSwitch(1)
                    SoundManager.playMusic("sound/hallbgm.mp3", true)
            	end

            end
        end
    )

    checkBoxButton1:setPosition(468, 387)

    -- local musicEffect = cc.Sprite:create("hall/setting/musicEffect.png")
    -- musicEffect:setPosition(297, 248)
    -- self:addChild(musicEffect)

    local musicEffect = display.newTTFLabel({text = "音效",
                                size = 28,
                                color = cc.c3b(255,255,255),
                                font = FONT_ART_TEXT,
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(self)
    musicEffect:setPosition(338, 298)


    local checkBoxButton2 = ccui.Button:create();
	if SoundManager.bOpenSound == 1 then
		
		checkBoxButton2:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
	else
		checkBoxButton2:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
	end
    self:addChild(checkBoxButton2)
    checkBoxButton2:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	Click();
            	if SoundManager.bOpenSound == 1 then
            		checkBoxButton2:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
            		SoundManager.saveSoundSwitch(0)
            	else
            		checkBoxButton2:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
            		SoundManager.saveSoundSwitch(1)
            	end
                

            end
        end
    )

    checkBoxButton2:setPosition(470, 295)

    local panel = ccui.ImageView:create("common/panel.png")
	panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(132*2.10, 132*1.93));
    panel:setPosition(cc.p(715,324));
    self:addChild(panel);

    local text2 = ccui.Text:create()
    text2:setString("dear~\n你有什么好的意见或者\n建议可以向我们提哦")
    text2:setFontSize(24)
    text2:setColor(cc.c3b(246, 243, 127))
    text2:setPosition(725, 376)
    self:addChild(text2)

    local fankui = ccui.Button:create("common/common_button2.png");
    fankui:setScale9Enabled(true)
    fankui:setContentSize(cc.size(163*1.12, 72))
    fankui:setPosition(cc.p(714,258));
    fankui:setTitleFontName(FONT_ART_BUTTON);
    fankui:setTitleText("反馈");
    fankui:setTitleColor(cc.c3b(255,255,255));
    fankui:setTitleFontSize(28);
    fankui:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    self:addChild(fankui);
    fankui:setPressedActionEnabled(true);
    fankui:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	self:fankuiHandler();
                

            end
        end
    )

    local help = ccui.Button:create("common/common_button3.png");
    help:setScale9Enabled(true)
    help:setContentSize(cc.size(163*1.12, 72))
    help:setPosition(cc.p(420,208));
    help:setTitleFontName(FONT_ART_BUTTON);
    help:setTitleText("帮助");
    help:setTitleColor(cc.c3b(255,255,255));
    help:setTitleFontSize(28);
    help:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    self:addChild(help);
    help:setPressedActionEnabled(true);
    help:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:helpHandler();
                

            end
        end
    )

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
function SettingLayer:helpHandler()
    local help = require("hall.HelpLayer").new()

    self:addChild(help)
end
function SettingLayer:musicHandler( checkbox )

	if checkbox:isButtonSelected() then
        -- SoundManager.saveMusicSwitch(1)
        print("isButtonSelected")
    else
        -- SoundManager.saveMusicSwitch(0)
    end
    Click();
end
function SettingLayer:musicEffectHandler( checkbox )	
	if checkbox:isButtonSelected() then
        SoundManager.saveSoundSwitch(1)
    else
        SoundManager.saveSoundSwitch(0)
    end
    Click();
end
function SettingLayer:fankuiHandler( )
	PlatformFeedback();
	Click();
end
return SettingLayer