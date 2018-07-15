local SettingLayer = class("SettingLayer", function() return display.newLayer() end)

function SettingLayer:ctor()

	self:createUI();
end

function SettingLayer:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    -- self:setContentSize(displaySize);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setAnchorPoint(cc.p(0,0))
    maskLayer:setPosition(cc.p(0, 0));
    maskLayer:setTouchEnabled(true);
    -- maskLayer:addTo(self);
    -- print("winSize.width",winSize.width,"winSize.height",winSize.height)

    -- local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(674, 433));
    -- bgSprite:setPosition(cc.p(588,320));
    -- containerLayer:addChild(bgSprite);
    local basewindow = require("show.popView_Hall.baseWindow").new()
    self:addChild(basewindow)
    -- basewindow:setPosition(-10,-70)

    local containerLayer = ccui.Layout:create()
    -- containerLayer:setAnchorPoint(cc.p(0.5,0.5))
    containerLayer:setContentSize(cc.size(1136,640))
    containerLayer:setPosition(-1136/2+724/2, -640/2+514/2)
    -- containerLayer:setBackGroundColorType(1)
    -- containerLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.containerLayer = containerLayer
    basewindow:getContentNode():addChild(containerLayer)
    local titleicon = ccui.ImageView:create("hall/setting/setWord.png")
    titleicon:setPosition(567, 561)
    containerLayer:addChild(titleicon)



    local music = ccui.ImageView:create("hall/setting/music.png");
    music:setPosition(cc.p(314,396));
    containerLayer:addChild(music);
    local musicPao = ccui.ImageView:create("common/ty_pao_pao_2.png");
    musicPao:setPosition(cc.p(314,394));
    containerLayer:addChild(musicPao);
    local music = display.newTTFLabel({text = "off",
                                size = 30,
                                color = cc.c3b(255,255,0),
                                font = FONT_PTY_TEXT,
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(containerLayer)
    music:setPosition(391, 393)

    -- local layoutLayer = ccui.Layout:create()
    -- containerLayer:addChild(layoutLayer)
    local checkBoxButton1 = ccui.Button:create("hall/setting/btn_on.png","hall/setting/btn_on.png");
	if SoundManager.bOpenMusic == 1 then
		checkBoxButton1:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
	else
		checkBoxButton1:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
	end
	
    containerLayer:addChild(checkBoxButton1)
    checkBoxButton1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                Click()
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

    checkBoxButton1:setPosition(480, 392)
    local music = display.newTTFLabel({text = "on",
                                size = 30,
                                color = cc.c3b(255,255,0),
                                font = FONT_PTY_TEXT,
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(containerLayer)
    music:setPosition(558, 393)
    --音效按钮
    local musicEffect = ccui.ImageView:create("hall/setting/musicEffect.png");
    musicEffect:setPosition(cc.p(318,281));
    containerLayer:addChild(musicEffect);
    local musicEffectPao = ccui.ImageView:create("common/ty_pao_pao_2.png");
    musicEffectPao:setPosition(cc.p(314,281));
    containerLayer:addChild(musicEffectPao);

    local musicEffect = display.newTTFLabel({text = "off",
                                size = 30,
                                color = cc.c3b(255,255,0),
                                font = FONT_PTY_TEXT,
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(containerLayer)
    musicEffect:setPosition(391, 274)


    local checkBoxButton2 = ccui.Button:create();
	if SoundManager.bOpenSound == 1 then
		
		checkBoxButton2:loadTextures("hall/setting/btn_on.png","hall/setting/btn_on.png");
	else
		checkBoxButton2:loadTextures("hall/setting/btn_off.png","hall/setting/btn_off.png");
	end
    containerLayer:addChild(checkBoxButton2)
    checkBoxButton2:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()

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

    checkBoxButton2:setPosition(480, 275)
    local music = display.newTTFLabel({text = "on",
                                size = 30,
                                color = cc.c3b(255,255,0),
                                font = FONT_PTY_TEXT,
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                --:align(display.CENTER_TOP, 337, 389)
                :addTo(containerLayer)
    music:setPosition(558, 274)
    local panel = ccui.ImageView:create("hall/setting/nk.png")
	-- panel:setScale9Enabled(true)
    -- panel:setContentSize(cc.size(132*2.10, 132*1.93))
    panel:setPosition(cc.p(725,317))
    containerLayer:addChild(panel)

    local text2 = ccui.Text:create("dear~\n你有什么好的意见或者\n建议可以向我们提哦",FONT_PTY_TEXT,24)
    text2:setColor(cc.c3b(0xf8, 0xff, 0x78))
    text2:setPosition(732, 371)
    containerLayer:addChild(text2)

    local fankui = ccui.Button:create("hall/setting/fankui.png");
    fankui:setPosition(cc.p(723,239));
    containerLayer:addChild(fankui);
    fankui:setPressedActionEnabled(true);
    fankui:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
            	self:fankuiHandler();
            end
        end
    )

    if OnlineConfig_review == "off" then
        --客服QQ
        local textQQ = ccui.Text:create("客服QQ：3100150589",FONT_PTY_TEXT,20)
        textQQ:setColor(cc.c3b(0xf8, 0xff, 0x78))
        textQQ:setPosition(730, 120)
        containerLayer:addChild(textQQ)
    end

end

function SettingLayer:fankuiHandler( )
	PlatformFeedback();
end
return SettingLayer