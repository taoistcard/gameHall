--
-- Author: Your Name
-- Date: 2015-04-14 20:00:08
--
local HeadView = class("HeadView", function(headIndex) return ccui.ImageView:create("head/frame.png"); end );
HeadView.headType = 999 --表示自定义头像
HeadView.maxDownloadCount = 3
function HeadView:ctor(headIndex)
    self.downloadCount = 1
    self:setNodeEventEnabled(true)
    self:addHeadImage(headIndex);

    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "tokenId", handler(self, self.customFaceUrlBackHandler))
    self:setNodeEventEnabled(true)
    self:addHeadImage(headIndex);
end
function HeadView:onEnter()
    
end

function HeadView:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function HeadView:customFaceUrlBackHandler(event)
    -- print("HeadView:customFaceUrlBackHandler","self.headIndex",self.headIndex,"self.tokenID",self.tokenID,"tokenID--",event.tokenID,"url=",event.url)
    -- print(type(event.tokenID),type(self.tokenID))
    if tonumber(event.tokenID) == tonumber(self.tokenID) then 
        -- print("event.tokenID == self.tokenID","os.time()",os.time())
        self:performWithDelay(function ( )
            self:setNewHead(self.headIndex,event.tokenID,self.md5)
        end, 1)

    end
end
function HeadView:setNewHead(headIndex,tokenID,headFileMd5)

    self:removeAllChildren();

    self:addHeadImage(headIndex,tokenID,headFileMd5);

    if self.modify == true then
        
        self:addModifySprite()

    end

end

function HeadView:setVipHead(vip, anchor)
    if OnlineConfig_review == "on" then
        return
    end

    if vip and vip >= 1 and vip <= 5 then
        local imageName = "hallScene/shop/zuan"..vip..".png";
        print("======", imageName)
        local size = self:getContentSize();
        local head = cc.Sprite:create(imageName);
        if anchor then
            if anchor == 1 then--右上
                head:setPosition(cc.p(size.width*0.85, size.height*0.9));
            elseif anchor == 2 then--左上
                head:setPosition(cc.p(size.width*0.1, size.height*0.9));
            elseif anchor == 3 then--左下
                head:setPosition(cc.p(size.width*0.1, size.height*0.2));
            elseif anchor == 4 then--右下
                head:setPosition(cc.p(size.width*0.85, size.height*0.2));
            end

        else
            head:setPosition(cc.p(size.width*0.8, size.height*0.3));
        end
        head:addTo(self);
    end
end

function HeadView:addHeadImage(headIndex,tokenID,headFileMd5)
    self.headIndex = headIndex;
    self.tokenID = tokenID;
    self.md5 = headFileMd5
    if headIndex and headIndex > 0 and headIndex <= 37 and HeadView.headType ~= headIndex then
    
        local imageName = "head/head_"..headIndex..".png";
        local size = self:getContentSize();
        local head = cc.Sprite:create(imageName);
        head:scale(0.7)
        head:setPosition(cc.p(size.width/2-4, size.height/2+4));
        head:addTo(self);  

    elseif HeadView.headType == headIndex and tokenID then
        local imageName = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)
        local size = self:getContentSize()
        local head = nil
        
        if is_file_exists(imageName) then
            -- print("***文件存在")
            head = cc.Sprite:create(imageName);
            local md5 = headFileMd5
            local localmd5 = cc.Crypto:MD5File(imageName)
            -- print("HeadView--tokenID",tokenID,"md5===",md5,"localmd5==",localmd5,"url",imageName)
            if localmd5 ~= md5 and self.downloadCount < HeadView.maxDownloadCount then
                PlatformDownloadAvatarImage(tokenID,md5)
                self.downloadCount = self.downloadCount + 1
            end
        else
            -- print("文件不存在")
            head = cc.Sprite:create("head/default.png");
            if HeadView.maxDownloadCount>self.downloadCount then
                PlatformDownloadAvatarImage(self.tokenID,self.md5)
                self.downloadCount = self.downloadCount + 1
            end
        end
        head:scale(0.7)
        head:setPosition(cc.p(size.width/2-4, size.height/2+4));
        head:addTo(self);  
    else

        local size = self:getContentSize();
        local head = cc.Sprite:create("head/default.png");
        head:setPosition(cc.p(size.width/2, size.height/2));
        head:addTo(self);
        head:scale(0.7)

    end


end

function HeadView:addModifySprite()

    local size = self:getContentSize();
    local tool = cc.Sprite:create("blank.png");
    tool:setPosition(cc.p(size.width*9/10, size.height*1/10));
    tool:addTo(self);

    self:setTouchEnabled(true);
    self:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:showHeadSelect();
        end
    end)

end

function HeadView:setModifyMode(callback)

    self.modify = true;

    if self.headIndex > 0 then
        self:setNewHead(self.headIndex,self.tokenID);
    end

    if callback ~= nil then
        self.modifyCallback = callback;
    end
    
end

function HeadView:showHeadSelect()

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    local newLayer = display.newLayer();
    newLayer:ignoreAnchorPointForPosition(false);
    newLayer:setAnchorPoint(cc.p(0.5,0.5));
    newLayer:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    newLayer:setContentSize(displaySize);

    local runningScene = display.getRunningScene();
    runningScene:addChild(newLayer);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(newLayer);

    local bgSprite = ccui.ImageView:create("view/frame3.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(560, 360));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:addTo(newLayer);

    local count = 37;
    local col = 4;
    local row = math.ceil ( count / col ); 
    local side = self:getContentSize().width + 20;

    local contentLayer = ccui.Layout:create()
    contentLayer:setContentSize( cc.size(side * col, side * row) );
    for i = 1, count do
        
        local x = (i - 1) % col * side + side / 2;
        local y = (row - math.floor( (i - 1) / col ) - 1 ) * side + side / 2;

        local frame = ccui.ImageView:create("head/frame.png");
        frame:setPosition(cc.p(x, y));
        frame:addTo(contentLayer);

        frame:setTouchEnabled(true);
        frame:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    newLayer:removeFromParent();
                    self:selectNewIndex(i);

                end
            end
        )

        local imageName = "head/head_"..i..".png";
        local head = cc.Sprite:create(imageName);
        head:scale(0.7)
        head:setPosition(cc.p(x-4, y+4));
        head:addTo(contentLayer);

    end

    local heads = ccui.ScrollView:create();
    heads:setDirection(ccui.ScrollViewDir.vertical);
    heads:setContentSize(cc.size(side * col, 330));
    heads:setInnerContainerSize(cc.size(side * col, side * row));
    heads:setAnchorPoint(cc.p(0.5,0.5));
    heads:setPosition(568, 325);
    heads:addChild(contentLayer);
    heads:addTo(newLayer);

    

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(830,470));
    newLayer:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                newLayer:removeFromParent();

            end
        end
    )

end

function HeadView:selectNewIndex(headIndex)

    self:setNewHead(headIndex);

    if self.modifyCallback ~= nil then
        self.modifyCallback(headIndex,self.tokenID);
    end

end

return HeadView
