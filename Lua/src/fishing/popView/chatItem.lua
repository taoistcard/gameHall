local chatItem = class("chatItem", function() return display.newLayer(); end );

function chatItem:ctor(head, name, isSelf, message)
	self:createBase(head, name, isSelf, message);
end

function chatItem:createBase(head, name, isSelf, message)

	local speaker=display.newLayer();

	local headView = require("show.popView_Hall.HeadView").new(1,true);
    headView:setAnchorPoint(cc.p(0.5,0))
	headView:setPosition(cc.p(0.5,0.5))
    headView:setScale(0.8)
	speaker:addChild(headView)

	local nicknameLabel = ccui.Text:create(name, FONT_PTY_TEXT, 24);
    nicknameLabel:setColor(cc.c3b(255,255,255));
    nicknameLabel:enableOutline(cc.c4b(0,0,0,255),2);
    nicknameLabel:setPosition(cc.p(0, 0));
    speaker:addChild(nicknameLabel);

    self:addChild(speaker);

	local wordsLayer=display.newLayer();
    local pop = ccui.ImageView:create("popView/chat_pop.png");
    pop:setScale9Enabled(true);
    pop:setPosition(cc.p(0,0));
    self.pop=pop;
    wordsLayer:addChild(pop,3);
    local greenBG = ccui.ImageView:create("userCenter/btn_change_headImg_bg.png");
    greenBG:setScale9Enabled(true);
    wordsLayer:addChild(greenBG,1);

    local words = display.newTTFLabel({text = message,
                                        size = 24,
                                        color = cc.c3b(255,255,255),
                                        font = FONT_PTY_TEXT,
                                        dimensions = cc.size(320, 0),
                                        align = cc.ui.TEXT_ALIGN_LEFT,
                                    })
    words:enableOutline(cc.c4b(4,115,21,255),1);
    wordsLayer:addChild(words,2);
    wordsLayer:setPosition(cc.p(60,0));

    pop:setContentSize(cc.size(words:getContentSize().width+40,words:getContentSize().height+24));
    greenBG:setContentSize(cc.size(words:getContentSize().width+20,words:getContentSize().height+16));
    -- greenBG:setScaleX((words:getContentSize().width+30)/greenBG:getContentSize().width);
    -- greenBG:setScaleY((words:getContentSize().height+10)/greenBG:getContentSize().height);

    self:addChild(wordsLayer);

    local itemHeight = headView:getContentSize().height+20;
    if(itemHeight<words:getContentSize().height+10)then
        itemHeight=words:getContentSize().height+10;
    end
    self.itemHeight=itemHeight;

	if(isSelf)then
        speaker:setPosition(cc.p(540-60,0));
        pop:setFlippedX(false);
		wordsLayer:setPosition(cc.p(540-(80+headView:getContentSize().width/2+10+words:getContentSize().width/2),itemHeight/2));
	else
		speaker:setPosition(cc.p(60,0));
        pop:setFlippedX(true);
        wordsLayer:setPosition(cc.p(80+headView:getContentSize().width/2+10+words:getContentSize().width/2,itemHeight/2));
	end
end

return chatItem;