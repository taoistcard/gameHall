local chatDialog = class("chatDialog", require("show.popView_Hall.baseWindow") );

function chatDialog:ctor(parant)
    self.super.ctor(self,3);
    self.parant=parant;
	self:createUI();

    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ChatInfo, "chatMsg", handler(self, self.addMesage))  
    self:setNodeEventEnabled(true);
end

function chatDialog:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function chatDialog:createUI()

	local contentNode = self:getContentNode()
	local size = self:getContentSize();
	local title_chat = display.newSprite("popView/title_chat.png", size.width/2, size.height/2+250);
    self:addChild(title_chat);


    local inputBg = ccui.ImageView:create("common/ty_progress_bg.png");
	inputBg:setScale9Enabled(true);
	-- inputBg:setContentSize(cc.size(340*37/50,37));
	inputBg:setContentSize(cc.size(343,56));
	inputBg:setAnchorPoint(cc.p(0.5,0.5));
	-- inputBg:setScale(50/37);
	inputBg:setPosition(cc.p(235,91));
	contentNode:addChild(inputBg);


	local scaleLayer = display.newLayer();
	local btn_send = ccui.Button:create("common/ty_green_btn.png");
    btn_send:setAnchorPoint(cc.p(0.5,0.5));
    -- btn_send:setPosition(cc.p(490, 90));
    btn_send:onClick(function() self:sendMessage() end);
    -- contentNode:addChild(btn_send);
    scaleLayer:addChild(btn_send);
    scaleLayer:setPosition(cc.p(490, 90));
    btn_send:setPosition(cc.p(0, 0));
    scaleLayer:setScale(0.8);
    contentNode:addChild(scaleLayer);
    
  	local btn_send_text = ccui.ImageView:create("popView/btn_sendMsg_text.png");
	btn_send_text:setPosition(cc.p(btn_send:getContentSize().width/2,btn_send:getContentSize().height/2-4));
	btn_send_text:setScale(1.25);
	btn_send:addChild(btn_send_text);

    local messageField = ccui.EditBox:create(cc.size(305, 47), "blank.png");
    messageField:setAnchorPoint(cc.p(0,0.5));
    messageField:setPosition(cc.p(85, 88));
    messageField:setFontSize(24);
    messageField:setPlaceHolder("输入聊天内容");
    messageField:setPlaceholderFontColor(cc.c3b(170,170,170));
    messageField:setPlaceholderFontSize(22);
    messageField:setMaxLength(50);
    self.messageField=messageField;
    contentNode:addChild(messageField);

    local icon_laba1 = display.newSprite("popView/chat_loudSpeaker_1.png", 160 , 45);
    contentNode:addChild(icon_laba1);
    icon_laba1:setScale(0.8);

    local icon_laba2 = display.newSprite("popView/chat_loudSpeaker_2.png", 270 , 45);
    contentNode:addChild(icon_laba2);
    icon_laba2:setScale(0.8);

    local btn_laba1 = ccui.Button:create("game/btn_BG.png");
    btn_laba1:setAnchorPoint(cc.p(0.5,0.5));
    btn_laba1:setPosition(cc.p(0, 0));
    btn_laba1:onClick(function() self:selectLaba1() end);
    local scaleLayer1 = display.newLayer();
	scaleLayer1:addChild(btn_laba1);
    scaleLayer1:setPosition(cc.p(210, 45));
    scaleLayer1:setScale(0.4);
    contentNode:addChild(scaleLayer1);

    local btn_laba2 = ccui.Button:create("game/btn_BG.png");
    btn_laba2:setAnchorPoint(cc.p(0.5,0.5));
    btn_laba2:setPosition(cc.p(0, 0));
    btn_laba2:onClick(function() self:selectLaba2() end);
    local scaleLayer2 = display.newLayer();
	scaleLayer2:addChild(btn_laba2);
    scaleLayer2:setPosition(cc.p(320, 45));
    scaleLayer2:setScale(0.4);
    contentNode:addChild(scaleLayer2);

    local iconSelectLaba1 = display.newSprite("popView/chat_select.png", 210 , 45);
    contentNode:addChild(iconSelectLaba1,2);
    self.iconSelectLaba1=iconSelectLaba1;
    self.isSelectLaba1=false;

    local iconSelectLaba2 = display.newSprite("popView/chat_select.png", 320 , 45);
    contentNode:addChild(iconSelectLaba2,2);
    self.iconSelectLaba2=iconSelectLaba2;
    self.isSelectLaba2=false;

    self:updateSelectIcon();

	local tips = display.newTTFLabel({text = "小喇叭:可向本游戏所有玩家发送信息。",
                                        size = 14,
                                        color = cc.c3b(255,255,255),
                                        font = FONT_PTY_TEXT
                                    })
	tips:enableOutline(cc.c4b(0,0,0,255),1);
	tips:setPosition(cc.p(350, 45));
	tips:setAnchorPoint(cc.p(0,0.5));
	contentNode:addChild(tips);
	self.tips=tips;

	self.chatListView = ccui.ListView:create();
    self.chatListView:setDirection(ccui.ScrollViewDir.vertical);
    self.chatListView:setClippingType(1);
    self.chatListView:setBounceEnabled(true);
    self.chatListView:setContentSize(cc.size(540, 318));
    self.chatListView:setPosition(94,145);
    contentNode:addChild(self.chatListView);

    self:setMessages( );
end

function chatDialog:sendMessage()

    ChatInfo:sendUserChatRequest(0, self.messageField:getText());
    self.messageField:setText("");
end


function chatDialog:selectLaba1()
	if(self.isSelectLaba1)then
		self.isSelectLaba1=false;
	else
		self.isSelectLaba1=true;
	end
	self:updateSelectIcon();
end

function chatDialog:selectLaba2()
	if(self.isSelectLaba2)then
		self.isSelectLaba2=false;
	else
		self.isSelectLaba2=true;
	end
	self:updateSelectIcon();
end

function chatDialog:updateSelectIcon()
	self.iconSelectLaba1:setVisible(self.isSelectLaba1);
	self.iconSelectLaba2:setVisible(self.isSelectLaba2);
end

function chatDialog:setMessages( )
    for i,v in ipairs(ChatInfo.chatList) do
    
        local message_item = ccui.Layout:create();
        local isSelf=false;
        if(ChatInfo.chatMsg.sendUserID==AccountInfo.userId)then
            isSelf=true
        end
        local message = require("popView.chatItem").new(1,v.sendNickname,isSelf,v.content);
        message_item:addChild(message);
        message_item:setContentSize(cc.size(628, message.itemHeight));

        self.chatListView:pushBackCustomItem(message_item);
    end

end

function chatDialog:addMesage( event )
    local message_item = ccui.Layout:create();
    local isSelf=false;
    if(ChatInfo.chatMsg.sendUserID==AccountInfo.userId)then
        isSelf=true
    end
    local message = require("popView.chatItem").new(1,ChatInfo.chatMsg.sendNickname,isSelf,ChatInfo.chatMsg.content);
    message_item:addChild(message);
    message_item:setContentSize(cc.size(628, message.itemHeight));

    self.chatListView:pushBackCustomItem(message_item);

end

return chatDialog;