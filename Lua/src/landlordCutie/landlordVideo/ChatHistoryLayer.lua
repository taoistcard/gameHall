local ChatHistoryLayer = class("ChatHistoryLayer", function() return display.newLayer(); end );

local MAX_CHATCONTENT = 20
local SIZE_WIDTH = 430
local SIZE_HEIGHT = 128

function ChatHistoryLayer:ctor()
    self:setContentSize(cc.size(SIZE_WIDTH,SIZE_HEIGHT))

    self.chatContentArr = {}
    self:createUI()
end

function ChatHistoryLayer:createUI()
    self.scrollView = ccui.ScrollView:create()
    self.scrollView:setTouchEnabled(true)
    self.scrollView:setContentSize(self:getContentSize())        
    self.scrollView:setPosition(cc.p(0,0))
    self:addChild(self.scrollView)
end

function ChatHistoryLayer:appendChatContent(chatContent)
    local chatContentCount = table.maxn(self.chatContentArr)
    if chatContentCount > MAX_CHATCONTENT then
        table.remove(self.chatContentArr,1)
    end
    table.insert(self.chatContentArr, chatContent)
    self:refreshChatContent()
end

function ChatHistoryLayer:refreshChatContent()
    self.scrollView:removeAllChildren()
    local chatContentCount = table.maxn(self.chatContentArr)
    local posX = 0
    local posY = 0
    local height = 0
    for i=chatContentCount,1,-1 do
        local chatContent = self.chatContentArr[i]
        local chatContentLabel = self:formatChatContentLabel(chatContent)
        chatContentLabel:setPosition(cc.p(posX,posY))
        self.scrollView:addChild(chatContentLabel)
        posY = posY + chatContentLabel:getContentSize().height
        height = height + chatContentLabel:getContentSize().height
    end
    self.scrollView:setInnerContainerSize(cc.size(SIZE_WIDTH, height))
    self.scrollView:jumpToBottom()
end

function ChatHistoryLayer:formatChatContentLabel(chatContent)
    local chatContentLabel = ccui.Text:create()
    chatContentLabel:setFontSize(22)
    chatContentLabel:setColor(cc.c3b(231,220,188))
    chatContentLabel:setString(chatContent)
    local tempWidth = chatContentLabel:getContentSize().width
    local tempHeight = chatContentLabel:getContentSize().height
    local mul = 1
    if tempWidth > SIZE_WIDTH then
        mul = math.ceil(tempWidth / SIZE_WIDTH)
    end
    chatContentLabel:setTextAreaSize(cc.size(SIZE_WIDTH,mul * tempHeight))
    chatContentLabel:ignoreContentAdaptWithSize(false)
    chatContentLabel:ignoreAnchorPointForPosition(true)
    return chatContentLabel
end

return ChatHistoryLayer
