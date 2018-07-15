--
-- Author: Your Name
-- Date: 2015-04-14 20:00:08
--
local HeadView = class("HeadView", function(headIndex) 
    local image = ccui.ImageView:create("common/blank.png"); 
    image:setScale9Enabled(true)
    image:setContentSize(cc.size(98,99))
    return image end );
HeadView.headType = 999 --表示自定义头像
HeadView.downloadCount = 0

HeadView.maxDownloadCount = 3
HeadView.waitDownloadCache = {}
function HeadView:ctor(headIndex,clip)

    self.clip = clip
    self.downloadCount = 0
    -- self.handler_AVATARDOWNLOADURL = UserService:addEventListener(HallCenterEvent.EVENT_AVATARDOWNLOADURL, handler(self, self.customFaceUrlBackHandler))
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "tokenId", handler(self, self.customFaceUrlBackHandler))
    self:setNodeEventEnabled(true)
    self:addHeadImage(headIndex);
    self.eventHandler = HallEvent:addEventListener(HallEvent.AVATAR_DOWNLOAD_URL_SUCCESS, handler(self, self.onDownloadCustomFaceUrlBackHandler))
end
function HeadView:onEnter()
    
end
function HeadView:onExit()
    -- UserService:removeEventListener(self.handler_AVATARDOWNLOADURL)
    HallEvent:removeEventListener(self.eventHandler)
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end
function HeadView:onDownloadCustomFaceUrlBackHandler(event)
    HeadView.downloadCount = HeadView.downloadCount - 1

    if tonumber(event.userId) == tonumber(self.userId) then 
        self.md5 = event.md5Value
        self:performWithDelay(function ()
            self:setNewHead(self.headIndex, event.userId, self.md5)
        end, 1)
    end

    if #HeadView.waitDownloadCache > 0 then
        if HeadView.maxDownloadCount > HeadView.downloadCount then
            local cacheUrl = HeadView.waitDownloadCache[#HeadView.waitDownloadCache]
            PlatformDownloadAvatarImage(cacheUrl.userId, cacheUrl.md5)
            HeadView.downloadCount = HeadView.downloadCount + 1
            table.remove(HeadView.waitDownloadCache, #HeadView.waitDownloadCache)
        end
    end
end
function HeadView:customFaceUrlBackHandler(event)
    -- print("HeadView:customFaceUrlBackHandler","self.headIndex",self.headIndex,"self.tokenID",self.tokenID,"tokenID--",event.tokenID,"url=",event.url)
    -- print(type(event.tokenID),type(self.tokenID))
    if tonumber(AccountInfo.tokenId) == tonumber(self.tokenID) then 
        -- print("event.tokenID == self.tokenID","os.time()",os.time())
        self:performWithDelay(function ( )
            self:setNewHead(self.headIndex,AccountInfo.tokenId,self.md5)
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
    if vip == nil then return end
    if vip >= 1 and vip <= 5 then
        local imageName = "hall/shop/zuan"..vip..".png";
        local size = self:getContentSize();
        local head = cc.Sprite:create(imageName);
        anchor = anchor or 1
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
    if self.clip then
    else
        self:addHeadImageWithOutClip(headIndex,tokenID,headFileMd5)
        return
    end
    self.headIndex = headIndex;
    self.tokenID = tokenID;
    self.md5 = headFileMd5
    local size = self:getContentSize();
    --头像
    local circleStencil = cc.DrawNode:create()
    local radius = 55
    local circlePoints = {}
    for i=1,360 do
        local x = math.cos(math.pi / 180 * i) * radius
        local y = math.sin(math.pi / 180 * i) * radius
        local point = cc.p(x,y)
        circlePoints[i] = point
    end
    local params = {}
    params.fillColor = cc.c4b(1,0,0,0)
    params.borderWidth = 0
    params.borderColor = cc.c4b(1,1,0,1)
    circleStencil:drawPolygon(circlePoints,params)

    local headClipImg = cc.ClippingNode:create(circleStencil)
    headClipImg:setPosition(size.width/2, size.height/2)

    self:addChild(headClipImg)

    if headIndex and headIndex > 0 and headIndex <= 37 and HeadView.headType ~= headIndex then
    
        local imageName = "head/head_"..headIndex..".png";
        local size = self:getContentSize();
        local head = cc.Sprite:create(imageName);
        head:addTo(headClipImg);  
    elseif HeadView.headType == headIndex and tokenID then
        local imageName = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)
        local size = self:getContentSize()
        local head = nil
        cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(imageName)
        if is_file_exists(imageName) then
            -- print("***文件存在")
            head = cc.Sprite:create(imageName);
            local md5 = headFileMd5
            local localmd5 = cc.Crypto:MD5File(imageName)
            -- print("HeadView--tokenID",tokenID,"md5===",md5,"localmd5==",localmd5,"url",imageName)
            if localmd5 ~= md5 then
                if HeadView.maxDownloadCount>self.downloadCount then
                    PlatformDownloadAvatarImage(tokenID,md5)
                    self.downloadCount = self.downloadCount + 1
                end
            end
        else
            head = cc.Sprite:create("head/default.png");
            if HeadView.maxDownloadCount>self.downloadCount then
                PlatformDownloadAvatarImage(tokenID,md5)
                self.downloadCount = self.downloadCount + 1
            end
        end

        head:addTo(headClipImg);  
    else
        local size = self:getContentSize();
        local head = cc.Sprite:create("head/default.png");
        head:addTo(headClipImg);
    end

    local maskCircle =  ccui.ImageView:create("head/frame.png");
    maskCircle:setPosition(cc.p(size.width/2, size.height/2))
    self:addChild(maskCircle)

end
function HeadView:addHeadImageWithOutClip(headIndex,tokenID,headFileMd5)
    self.headIndex = headIndex;
    self.tokenID = tokenID;
    self.md5 = headFileMd5

    --头像
    local size = self:getContentSize();

    if headIndex and headIndex > 0 and HeadView.headType ~= headIndex then
    
        local imageName = "head/head_"..headIndex..".png";
        
        local head = cc.Sprite:create(imageName);
        head:scale(0.77)
        head:setPosition(cc.p(size.width/2, size.height/2));
        head:addTo(self);  
    elseif HeadView.headType == headIndex and tokenID then
        local imageName = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)
        -- local size = self:getContentSize()
        local head = nil
        
        if is_file_exists(imageName) then
            -- print("***文件存在")
            head = cc.Sprite:create(imageName);
            local md5 = headFileMd5
            local localmd5 = cc.Crypto:MD5File(imageName)
            -- print("HeadView--tokenID",tokenID,"md5===",md5,"localmd5==",localmd5,"url",imageName)
            if localmd5 ~= md5 then
                if HeadView.maxDownloadCount>self.downloadCount then
                    PlatformDownloadAvatarImage(tokenID,md5)
                    self.downloadCount = self.downloadCount + 1
                end
            end
        else
            -- print("文件不存在")
            head = cc.Sprite:create("head/default.png");
            if HeadView.maxDownloadCount>self.downloadCount then
                PlatformDownloadAvatarImage(tokenID,md5)
                self.downloadCount = self.downloadCount + 1
            end
        end
        head:scale(0.77)
        head:setPosition(cc.p(size.width/2, size.height/2));
        head:addTo(self);  
    else

        -- local size = self:getContentSize();
        local head = cc.Sprite:create("head/default.png");
        head:setPosition(cc.p(size.width/2, size.height/2));
        head:addTo(self);
        head:scale(0.77)

    end
    local maskCircle =  ccui.ImageView:create("head/frame1.png");
    maskCircle:setPosition(cc.p(size.width/2, size.height/2))
    self:addChild(maskCircle)

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
    local side = self:getContentSize().width + 23;

    local contentLayer = ccui.Layout:create()
    contentLayer:setContentSize( cc.size(side * col, side * row) );
    for i = 1, count do
        
        local x = (i - 1) % col * side + side / 2;
        local y = (row - math.floor( (i - 1) / col ) - 1 ) * side + side / 2;

        local frame = ccui.ImageView:create("common/blank.png");
        frame:setScale9Enabled(true)
        frame:setContentSize(cc.size(135,135));
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
        head:scale(0.65)
        head:setPosition(cc.p(x-4, y+4));
        head:addTo(contentLayer);

        local maskCircle =  ccui.ImageView:create("head/frame1.png");
        maskCircle:setPosition(cc.p(x-4, y+4))
        maskCircle:setScale(0.83)
        contentLayer:addChild(maskCircle)

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
    exit:setPosition(cc.p(840,490));
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
