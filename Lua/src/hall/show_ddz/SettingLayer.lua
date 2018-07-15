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

    local bgSprite = ccui.ImageView:create("hall_frame_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(612, 343));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("hall_frame.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(574, 299));
    panel:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(panel);

    local titleSprite = cc.Sprite:create("common/hall_title_bg.png");
    titleSprite:setPosition(cc.p(displaySize.width / 2, 490));
    self:addChild(titleSprite,2);

    local pcWord = ccui.ImageView:create("hallScene/setting/setWord.png");
    pcWord:setPosition(214, 55);
    titleSprite:addChild(pcWord);


    local music = display.newTTFLabel({text = "音乐",
                                size = 28,
                                color = cc.c3b(254,255,121),
                                font = "fonts/HKBDTW12.TTF",
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(self)
    music:setPosition(338, 387)

    local layoutLayer = ccui.Layout:create()
    self:addChild(layoutLayer)
    local checkBoxButton1 = ccui.Button:create("hallScene/setting/btn_on.png","hallScene/setting/btn_on.png");
	if SoundManager.bOpenMusic == 1 then
		checkBoxButton1:loadTextures("hallScene/setting/btn_on.png","hallScene/setting/btn_on.png");
	else
		checkBoxButton1:loadTextures("hallScene/setting/btn_off.png","hallScene/setting/btn_off.png");
	end
	
    self:addChild(checkBoxButton1)
    checkBoxButton1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	Click();
            	if SoundManager.bOpenMusic == 1 then
                    SoundManager.stopMusic();
            		checkBoxButton1:loadTextures("hallScene/setting/btn_off.png","hallScene/setting/btn_off.png");
            		SoundManager.saveMusicSwitch(0)
            	else
            		checkBoxButton1:loadTextures("hallScene/setting/btn_on.png","hallScene/setting/btn_on.png");
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
                                color = cc.c3b(254,255,121),
                                font = "fonts/HKBDTW12.TTF",
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(self)
    musicEffect:setPosition(338, 298)


    local checkBoxButton2 = ccui.Button:create();
	if SoundManager.bOpenSound == 1 then
		
		checkBoxButton2:loadTextures("hallScene/setting/btn_on.png","hallScene/setting/btn_on.png");
	else
		checkBoxButton2:loadTextures("hallScene/setting/btn_off.png","hallScene/setting/btn_off.png");
	end
    self:addChild(checkBoxButton2)
    checkBoxButton2:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	Click();
            	if SoundManager.bOpenSound == 1 then
            		checkBoxButton2:loadTextures("hallScene/setting/btn_off.png","hallScene/setting/btn_off.png");
            		SoundManager.saveSoundSwitch(0)
            	else
            		checkBoxButton2:loadTextures("hallScene/setting/btn_on.png","hallScene/setting/btn_on.png");
            		SoundManager.saveSoundSwitch(1)
            	end
                

            end
        end
    )

    checkBoxButton2:setPosition(470, 295)



    local splitLine = ccui.ImageView:create("hallScene/personalCenter/splitLine.png");
    splitLine:setScale9Enabled(true);
    splitLine:setContentSize(cc.size(2, 222));
    splitLine:setPosition(570,325);
    self:addChild(splitLine);

    local text2 = ccui.Text:create("","fonts/HKBDTW12.TTF",20)
    text2:setString("Dear:\n\t你有什么好的意见或者\n建议可以向我们提哦")
    text2:setFontSize(20)
    text2:setColor(cc.c3b(254,255,121))
    text2:setPosition(725, 376)
    self:addChild(text2)

    local text2 = ccui.Text:create("","fonts/HKBDTW12.TTF",20)
    text2:setString("客服QQ：2764024642")
    text2:setFontSize(20)
    text2:setColor(cc.c3b(50,255,50))
    text2:setPosition(725, 210)
    self:addChild(text2)

    local fankui = ccui.Button:create("hallScene/setting/fankui.png");
    -- fankui:setScale9Enabled(true)
    -- fankui:setContentSize(cc.size(163*1.12, 72))
    fankui:setPosition(cc.p(714,268));
    -- fankui:setTitleFontName(FONT_ART_BUTTON);
    -- fankui:setTitleText("反馈");
    -- fankui:setTitleColor(cc.c3b(255,255,255));
    -- fankui:setTitleFontSize(28);
    -- fankui:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    self:addChild(fankui);
    fankui:setPressedActionEnabled(true);
    fankui:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	self:fankuiHandler();
                

            end
        end
    )


    local exit = ccui.Button:create("common/hall_close.png");
    exit:setPosition(cc.p(860,480));
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
	--Hall.showTips("反馈",1)
	PlatformFeedback();
	Click();
end
return SettingLayer