--
-- Author: <zhaxun>
-- Date: 2015-05-21 16:15:44
--

local GameItemFactory = class("GameItemFactory")

function GameItemFactory:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function GameItemFactory:getInstance()
	if not self._GameItemFactory then
		self._GameItemFactory = GameItemFactory.new()
	end
	return self._GameItemFactory;
end

-- 普通场
-- 叫地主按钮
function GameItemFactory:getBtnJDZ(callfunc)

    local button = ccui.Button:create("common/common_button4.png","common/common_button4.png","common/common_button0.png");
    button:setScale9Enabled(false);
    --button:setContentSize(cc.size(261,67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("叫地主");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    --button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )

	return button;
end
--叫地主图片
function GameItemFactory:getSprJDZ()
	return display.newSprite("play3/jdz.png")
end
--叫分
function GameItemFactory:getBtnJiaoFen(num, callfunc)

    local button = ccui.Button:create("common/common_button2.png","common/common_button2.png","common/common_button0.png")
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(120, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText(num.."分");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);

    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
    
    return button;
end
--不叫
function GameItemFactory:getBtnBJDZ(callfunc)
 
    local button = ccui.Button:create("common/common_button4.png","common/common_button4.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("不叫");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
	
	return button;
end

-- 不叫地主
function GameItemFactory:getBJDZ()
	return display.newSprite("play3/jdz.png")
end
-- 抢地主
function GameItemFactory:getBtnQDZ(callfunc)

    local button = ccui.Button:create("common/common_button4.png","common/common_button4.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("抢地主");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
	
	return button;
end

function GameItemFactory:getQDZ()
	return display.newSprite("play3/qdz.png")
end
-- 不抢
function GameItemFactory:getBtnBQDZ(callfunc)

    local button = ccui.Button:create("common/common_button4.png","common/common_button4.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("不抢");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
	
	return button;
end
--  根据传入的名字，获取蓝色按钮
function GameItemFactory:getBtnBlueByText(callfunc,txt)
    
    local button = ccui.Button:create("common/common_button2.png","common/common_button2.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText(txt);
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
    
    return button;
end

function GameItemFactory:getBtnBlue1ByText(callfunc,txt)
    
    local button = ccui.Button:create("common/button_blue.png","common/button_blue.png","common/button_blue.png");
    button:setScale9Enabled(true);
    -- button:setContentSize(cc.size(186, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText(txt);
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
    
    return button;
end
--  根据传入的名字，获取黄色按钮
function GameItemFactory:getBtnYellowByText(callfunc,txt)
    
    local button = ccui.Button:create("common/common_button4.png","common/common_button4.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText(txt);
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
    
    return button;
end
--  根据传入的名字，获取绿色按钮
function GameItemFactory:getBtnGreenByText(callfunc,txt)

    local button = ccui.Button:create("common/common_button3.png","common/common_button3.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText(txt);
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
    return button;
end
function GameItemFactory:getBtnGreen1ByText(callfunc,txt)

    local button = ccui.Button:create("common/button_green.png","common/button_green.png","common/button_green.png");
    button:setScale9Enabled(true);
    -- button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText(txt);
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
    return button;
end
function GameItemFactory:getBQDZ()
	return display.newSprite("play3/buqiang.png")
end
-- 加倍
function GameItemFactory:getJiaBei()
	return display.newSprite("play3/bujiabei.png")
end
-- 不加倍
function GameItemFactory:getBuJiaBei()
	return display.newSprite("play3/bujiabei.png")
end


--不出
function GameItemFactory:getBtnBuChu(callfunc)

    local button = ccui.Button:create("common/common_button2.png","common/common_button2.png","common/common_button0.png");
    
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("不出");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )

    return button;
end

-- 不出
function GameItemFactory:getSprBuChu()
	return display.newSprite("play3/buchu.png")
end


--重选
function GameItemFactory:getBtnChongXuan(callfunc)

    local button = ccui.Button:create("common/common_button3.png","common/common_button3.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("重选");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
    
    return button;
end

--提示
function GameItemFactory:getBtnTiShi(callfunc)

    local button = ccui.Button:create("common/common_button4.png","common/common_button4.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("提示");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )

    return button;
end


--出牌
function GameItemFactory:getBtnChuPai(callfunc)

    local button = ccui.Button:create("common/common_button2.png","common/common_button2.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("出牌");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )
    
    return button;
end

--继续游戏
function GameItemFactory:getBtnJXYX(callfunc)

    local button = ccui.Button:create("common/common_button3.png","common/common_button3.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(200, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("继续游戏");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end
        )

    return button;
end

return GameItemFactory