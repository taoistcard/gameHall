
local hallLayer = class("hallLayer", function() return display.newLayer(); end );

function hallLayer:ctor()

    self.preConnect = false
	self:setNodeEventEnabled(true)
    self:initFrames();
    self:onNodeLoading();
    self:performWithDelay(function() Hall:showScrollMessage("欢迎来到98捕鱼...............") end, 0.2)

    if AccountInfo.score < 10000 then
        self:roomSelectAnimation(false)
    elseif AccountInfo.score > 1000000 then
        self:roomSelectAnimation(true)
    end
end

function hallLayer:initFrames()

	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
	-- sharedSpriteFrameCache:addSpriteFrames("number.plist");

end

function hallLayer:onNodeLoading()

	local winSize = cc.Director:getInstance():getWinSize();

	local backgroundLayer = display.newLayer();
	self:addChild(backgroundLayer);

	local backgroundSprite = cc.Sprite:create("hall/hall_background.jpg");
	backgroundSprite:setPosition(getSrcreeCenter());
	backgroundLayer:addChild(backgroundSprite);

    --返回
    local backBtn = ccui.Button:create("hall/hall_back.png");
    backBtn:setPosition(cc.p(70,winSize.height-70));
    backBtn:setPressedActionEnabled(true);
    backBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
				-- Hall:start()
                Hall:exitGame()
            end
        end
    )
    self:addChild(backBtn)

    --三个房间的坐标
    self.posArr = {cc.p(winSize.width/2-320,winSize.height/2+70),cc.p(winSize.width/2,winSize.height/2-10),cc.p(winSize.width/2+320,winSize.height/2+70)}

    self.roomBtns = {}
    self.curBtnPos = {1,2,3}

    for i=1,3 do
	    local armature = self:getRoomAnimation()
	    if armature then
	        armature:setPosition(self.posArr[i])
	        armature:setTag(200+i)
	        self:addChild(armature)
	        armature:getAnimation():playWithIndex(i-1)
	    end
	    if i == 1 or i == 3 then
	    	armature:setScale(0.7)
	    end
	    table.insert(self.roomBtns,armature)
    end

    --三个房间的nodeID
    self.room_node_id = {1100,1101,1102}

    self.targetNodeId = 2

    for i=2,2 do
    	local nToScale = 1.1
    	local nBackScale = 1.0
	    -- local freeRoom = ccui.Button:create("btn_green.png");
	    local freeRoom = ccui.Button:create("blank.png");
    	freeRoom:setScale9Enabled(true);
    	freeRoom:setContentSize(cc.size(300, 300));
	    freeRoom:setPosition(self.posArr[i]);
	    freeRoom:setPressedActionEnabled(true);	    
	    freeRoom:addTouchEventListener(
	        function(sender,eventType)
	            if eventType == ccui.TouchEventType.began then
	                self.roomBtns[i]:setScale(nToScale)
	            elseif eventType == ccui.TouchEventType.ended then
	                self.roomBtns[i]:setScale(nBackScale)
                    -- print("................."..self.targetNodeId)
	                self:performWithDelay(function() self:enterRoomRequest(self.targetNodeId) end, 0.2)
	            elseif eventType == ccui.TouchEventType.canceled then
	                self.roomBtns[i]:setScale(nBackScale)
	            end
	        end
	    )
	    self:addChild(freeRoom)
    end

    -- local shopBtn = ccui.Button:create("hall/hall_shop_btn.png");
    -- shopBtn:setPosition(cc.p(winSize.width-70,70));
    -- shopBtn:setPressedActionEnabled(true);
    -- shopBtn:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
                
    --         end
    --     end
    -- )
    -- self:addChild(shopBtn)

    self:initBottomBtns()

end

function hallLayer:initBottomBtns()

    local btn = ccui.Button:create("common/ty_head_icon_bg.png");
    btn:setAnchorPoint(cc.p(0,0.5));
    btn:setPosition(cc.p(10, 76));
    btn:onClick(function()
        self:openUserCenter()
    end);
    self:addChild(btn);

    local headView = require("show.popView_Hall.HeadView").new(1,true);
    headView:setPosition(cc.p(70, btn:getContentSize().height/2+10));
    headView:setScale(0.64);
    btn:addChild(headView);
    self.headView = headView;
    
    self:refreshUserInfo()

    local nameBg = display.newSprite("common/ty_name_bg.png");
    nameBg:setPosition(70, 26)
    btn:addChild(nameBg);

    local name = AccountInfo.nickName
    if string.len(name) <= 0 then
        name = AccountInfo.gameId
    end

    local name = display.newTTFLabel({text = ""..FormotGameNickName(name,2),
                                        size = 22,
                                        color = cc.c3b(255,255,255),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER
                                    })
    name:enableOutline(cc.c4b(0x03,0x08,0x06,255),2)
    name:setPosition(cc.p(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2))
    nameBg:addChild(name)
    self.name = name

    --coin
    local coinBg = ccui.ImageView:create("common/ty_name_bg.png");
    coinBg:setScale9Enabled(true);
    coinBg:setContentSize(cc.size(160, 32));
    coinBg:ignoreAnchorPointForPosition(false)
    coinBg:setAnchorPoint(cc.p(0.5,0.5));
    coinBg:setPosition(cc.p(224, 74));
    btn:addChild(coinBg)

    local coin = display.newSprite("common/ty_coin.png");
    coin:setPosition(146, 74)
    btn:addChild(coin);

    local coinLabel = display.newTTFLabel({text = ""..FormatNumToString(AccountInfo.score),
                                        size = 22,
                                        color = cc.c3b(255,255,255),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER
                                    })
    coinLabel:enableOutline(cc.c4b(0x03,0x08,0x06,255),2)
    coinLabel:setAnchorPoint(cc.p(0,0.5))
    coinLabel:setPosition(cc.p(coinBg:getContentSize().width/2-50, coinBg:getContentSize().height/2-2))
    coinBg:addChild(coinLabel)
    self.coinLabel = coinLabel

    --liquan
    local liQuanBg = ccui.ImageView:create("common/ty_name_bg.png");
    liQuanBg:setScale9Enabled(true);
    liQuanBg:setContentSize(cc.size(160, 32));
    liQuanBg:ignoreAnchorPointForPosition(false)
    liQuanBg:setAnchorPoint(cc.p(0.5,0.5));
    liQuanBg:setPosition(cc.p(224, 34));
    btn:addChild(liQuanBg)

    local liQuan = display.newSprite("common/ty_li_quan.png");
    liQuan:setPosition(146, 34)
    btn:addChild(liQuan);

    local liQuanLabel = display.newTTFLabel({text = ""..FormatNumToString(AccountInfo.present),
                                        size = 22,
                                        color = cc.c3b(255,255,255),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER
                                    })
    liQuanLabel:enableOutline(cc.c4b(0x03,0x08,0x06,255),2)
    liQuanLabel:setAnchorPoint(cc.p(0,0.5))
    liQuanLabel:setPosition(cc.p(liQuanBg:getContentSize().width/2-50, liQuanBg:getContentSize().height/2-2))
    liQuanBg:addChild(liQuanLabel)

    local startXPos = 80 + btn:getContentSize().width
    local yPos = 80

    --bank
    local btn = ccui.Button:create("common/ty_pao_pao.png");
    btn:setPosition(cc.p(startXPos, yPos));
    btn:onClick(
        function()
            local bankLayer = require("popView.BankLayer"):new()
            bankLayer:setInGame(false)
            self:addChild(bankLayer,100)
        end
    );
    self:addChild(btn);

    local sprite = display.newSprite("hall/hall_btn_icon_bank.png");
    sprite:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
    btn:addChild(sprite);

    local sprite = display.newSprite("hall/hall_btn_word_bank.png");
    sprite:setPosition(btn:getContentSize().width/2-6, -2)
    btn:addChild(sprite);

    startXPos = startXPos + 120

    --notice
    local btn = ccui.Button:create("common/ty_pao_pao.png");
    btn:setPosition(cc.p(startXPos, yPos));
    btn:onClick(function()
            local bankLayer = require("popView.NoticeLayer"):new(2)
            self:addChild(bankLayer,100)
            end);
    self:addChild(btn);
    btn:hide()

    local sprite = display.newSprite("hall/hall_btn_icon_notice.png");
    sprite:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
    btn:addChild(sprite);

    local sprite = display.newSprite("hall/hall_btn_word_notice.png");
    sprite:setPosition(btn:getContentSize().width/2-6, -2)
    btn:addChild(sprite);

    if btn:isVisible() then
        startXPos = startXPos + 120
    end

    --help
    local btn = ccui.Button:create("common/ty_pao_pao.png");
    btn:setPosition(cc.p(startXPos, yPos));
    btn:onClick(function()end);
    self:addChild(btn);
    btn:hide()

    local sprite = display.newSprite("hall/hall_btn_icon_help.png");
    sprite:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
    btn:addChild(sprite);

    local sprite = display.newSprite("hall/hall_btn_word_help.png");
    sprite:setPosition(btn:getContentSize().width/2-6, -2)
    btn:addChild(sprite);

    if btn:isVisible() then
        startXPos = startXPos + 120
    end

    if OnlineConfig_review == "off" then
        --rank
        local btn = ccui.Button:create("common/ty_pao_pao.png");
        btn:setPosition(cc.p(startXPos, yPos));
        btn:onClick(function() self:addChild(require("popView.rankWindow").new(),100); end);
        self:addChild(btn);

        local sprite = display.newSprite("hall/hall_btn_icon_rank.png");
        sprite:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
        btn:addChild(sprite);

        local sprite = display.newSprite("hall/hall_btn_word_rank.png");
        sprite:setPosition(btn:getContentSize().width/2-6, -2)
        btn:addChild(sprite);
    end

end

function hallLayer:enterRoomRequest(index)

    --用来区分”免费、激情、VIP场“
    self.roomIndex = index

	-- dump(ServerInfo.nodeItemList, "ServerInfo.nodeItemList")

    local bFind = false

    for k,v in pairs(ServerInfo.nodeItemList) do
        if self.room_node_id[index] == v.nodeID then
            if #v.serverList > 0 then
                -- dump(v.serverList, "v.serverList")
                bFind = true
                print(k.."进入"..v.nodeID..":"..v.name.."...."..self.room_node_id[index])
                local room = v.serverList[1]
                self.roomAddr = room.serverAddr
                if string.len(ServerHostBackUp) > 0 then
                    self.roomAddr = ServerHostBackUp
                end
                print("测试 ServerHostBackUp 长度 ...",string.len(ServerHostBackUp),self.roomAddr)
                self.roomPort = room.serverPort
                self.preConnect = true
                GameConnection:connectServer(self.roomAddr, self.roomPort)
                break;
            end
        end
    end

    if not bFind then
        Hall.showTips("尚未开启，请联系赵玉江同学！")
    end

end

function hallLayer:onSocketStatus(event)
	print(".... hallLayer:enterRoomRequest back ...............")
	if event.name == NetworkManagerEvent.SOCKET_CONNECTED and self.preConnect then
		RoomInfo:sendLoginRequest(0, 60)
	elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
		
	elseif event.name == NetworkManagerEvent.SOCKET_CONNECTE_FAILURE then
		
	end
end

function hallLayer:roomSelectAnimation(bLeft)

	-- self.posArr = {cc.p(winSize.width/2-320,winSize.height/2+80),cc.p(winSize.width/2,winSize.height/2-20),cc.p(winSize.width/2+320,winSize.height/2+80)}
    -- self.roomBtns = {freeRoom,vipRoom,spiritRoom}
    -- self.curBtnPos = {1,2,3}

    local step = 1
    if bLeft then
    	step = -1
    end

    --目标房间
    self.targetNodeId = self.targetNodeId - step;
    if self.targetNodeId == 4 then
        self.targetNodeId = 1
    end
    if self.targetNodeId == 0 then
        self.targetNodeId = 3
    end

	self.nextBtnPos = {self.curBtnPos[1],self.curBtnPos[2],self.curBtnPos[3]}
    for k,v in pairs(self.nextBtnPos) do
    	self.nextBtnPos[k] = self.nextBtnPos[k] + step
    	if self.nextBtnPos[k] == 4 then
    		self.nextBtnPos[k] = 1
    	end
    	if self.nextBtnPos[k] == 0 then
    		self.nextBtnPos[k] = 3
    	end
    end

    for k,btn in pairs(self.roomBtns) do
    	-- print(k,btn:getPositionX(),btn:getPositionY(),self.nextBtnPos[k])
    	-- print(k,self.posArr[self.nextBtnPos[k]].x,self.posArr[self.nextBtnPos[k]].y)
    	if self.nextBtnPos[k] == 1 or self.nextBtnPos[k] == 3 then
    		btn:setLocalZOrder(10)
    		-- btn:setScale(0.7)
    		btn:runAction(cc.ScaleTo:create(0.3, 0.7))
    	else
    		btn:setLocalZOrder(20)
    		-- btn:setScale(1.0)
    		btn:runAction(cc.ScaleTo:create(0.3, 1))
    	end
    	btn:runAction(cc.MoveTo:create(0.3,self.posArr[self.nextBtnPos[k]]))
    end

    self.nextRoomBtns = {self.roomBtns[3],self.roomBtns[1],self.roomBtns[2]}
    if bLeft then
    	self.nextRoomBtns = {self.roomBtns[2],self.roomBtns[3],self.roomBtns[1]}
    end
    self.roomBtns = {self.nextRoomBtns[1],self.nextRoomBtns[2],self.nextRoomBtns[3]}

    Hall:showScrollMessage("欢迎来到98捕鱼...............")

end

--登陆返回结果，不一定成功
function hallLayer:loginRoomResult(event)
	if RoomInfo.loginResult == false then
        print("------登陆房间失败，code:", RoomInfo.loginResultCode)
        -- RoomInfo:sendLogoutRequest()
        self:performWithDelay(function() GameConnection:closeConnect() end, 0.1)
    end
end

function hallLayer:onTableStatusChange(event)
    print("------hallLayer:onTableStatusChange:", DataManager.myUserInfo.userStatus)
    if DataManager.myUserInfo.userStatus == US_PLAYING then
        TableInfo:sendGameOptionRequest(true)
    else
        --1表示默认进入某个场(免费、激情、VIP)的第一个房间的第一个桌子
        local room = require("layer.roomLayer").new(self.roomIndex,1,1);
        display.replaceScene(room:scene());
    end
end

function hallLayer:onReceiveFishGameConfig(event)
    local gameLayer = require("layer.gameLayer").new();
    gameLayer:cacheLastSceneData(self.roomIndex,1,1)
    display.replaceScene(gameLayer:scene());
end

function hallLayer:scene()

    local winSize = cc.Director:getInstance():getWinSize();

	local scene = display.newScene("hallScene");
    scene:addChild(self);
    self.scene = scene;

	touchLayer = display.newLayer():addTo(scene);
    touchLayer:setContentSize(cc.size(winSize.width, winSize.height))
	touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE);
	touchLayer:setTouchEnabled(true);
	touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,
		function(event)
		    if event.name == "began" then
                -- print("策策策策策策策策策....began......",event.x,event.y)
		    	self.bMove = false
		    	self.bLeft = false
		    	self.xPos = event.x
		        return true
	        elseif event.name == "moved" then
                -- print("策策策策策策策策策....moved......",event.x,event.y)
	        	if event.x - self.xPos > 10 then
	        		self.bMove = true
	        		self.bLeft = false
	        	end
	        	if event.x - self.xPos < -10 then
	        		self.bMove = true
	        		self.bLeft = true
	        	end
	        elseif event.name == "ended" then
	        	if self.bMove then
	        		if self.bLeft then
	        			self:roomSelectAnimation(true)
	        		else
	        			self:roomSelectAnimation(false)
	        		end
                else
                    local rect1 = self.roomBtns[1]:getBoundingBox()
                    local rect3 = self.roomBtns[3]:getBoundingBox()

                    local pos1 = cc.p(winSize.width/2-320,winSize.height/2+70)
                    local pos3 = cc.p(winSize.width/2+320,winSize.height/2+70)

                    -- print("AAAAAAAAAAAAAAA1",rect1.width,rect1.height,rect1.x,rect1.y)
                    -- print("AAAAAAAAAAAAAAA2",event.x,event.y)
                    -- print("AAAAAAAAAAAAAAA3",winSize.width/2+320,winSize.height/2+70)

                    -- local freeRoom = ccui.Button:create("btn_green.png");
                    -- -- local freeRoom = ccui.Button:create("blank.png");
                    -- freeRoom:setScale9Enabled(true);
                    -- freeRoom:setContentSize(cc.size(math.floor(bgRect.width),math.floor(bgRect.height)));
                    -- -- freeRoom:setPosition(math.floor(bgRect.x),math.floor(bgRect.y));
                    -- freeRoom:setPosition(888,390);
                    -- freeRoom:setPressedActionEnabled(true);     
                    -- freeRoom:addTouchEventListener(
                    --     function(sender,eventType)
                    --     end
                    -- )
                    -- self:addChild(freeRoom)

                    if self:getPosIsInRect(event.x,event.y,pos1.x,pos1.y,rect1.width,rect1.height) then
                        self:roomSelectAnimation(false)
                    end
                    if self:getPosIsInRect(event.x,event.y,pos3.x,pos3.y,rect3.width,rect3.height) then
                        self:roomSelectAnimation(true)
                    end
	        	end
	        end
		end
	)
    return scene;

end

function hallLayer:getPosIsInRect(targetX,targetY,posX,posY,width,height)
    return targetX > (posX-width/2) and targetX < (posX+width/2) and targetY > (posY-height/2) and targetY < (posY+height/2)
end

function hallLayer:onEnter()

	self.bindIds = {}	
	self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "loginResult", handler(self, self.loginRoomResult))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(DataManager, "tabelStatuChange", handler(self, self.onTableStatusChange))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "gameConfig", handler(self, self.onReceiveFishGameConfig))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "nickName", handler(self, self.refreshNickName))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.refreshScore))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "userInfoChange", handler(self, self.refreshUserInfo))

	self.connected_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus))

	-- AccountInfo:sendSimulatorLoginRequest("捕鱼达人ABC")

end

function hallLayer:refreshNickName()
    self.name:setString(FormotGameNickName(AccountInfo.nickName,4))
end

function hallLayer:refreshScore()
    self.coinLabel:setString(FormatNumToString(AccountInfo.score))
end

function hallLayer:refreshUserInfo()
    self.headView:setNewHead(AccountInfo.faceId, AccountInfo.cy_userId, AccountInfo.headFileMD5);
    --vip信息
    if OnlineConfig_review == "off" and AccountInfo.memberOrder > 0 then
        self.headView:setVipHead(AccountInfo.memberOrder,1)
    end
end

function hallLayer:onExit()

    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    GameConnection:removeEventListener(self.connected_handler)
end

function hallLayer:getRoomAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("dating_changci") == nil then
        manager:addArmatureFileInfo("effect/dating_changci0.png","effect/dating_changci0.plist","effect/dating_changci.ExportJson")
    end
    local armature = ccs.Armature:create("dating_changci")
    return armature;
end

function hallLayer:openUserCenter()
    -- local layer = require("popView.userCenterLayer").new()
    local layer = require("show.popView_Hall.userCenterLayer").new()
    self:addChild(layer, 100)
end

return hallLayer