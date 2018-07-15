-----------------------------------------------------------------------------
-- local GameLayer = class("GameLayer", require("ui.CCDesignLayer") );
local GameLayer = class("GameLayer", function() return display.newLayer(); end );
local scheduler = require("framework.scheduler")

require("core.helper")
require("core.gameCollision")

local FishManager = require("core.FishManager"):getInstance();
local FishGroup = require("core.FishGroup"):getInstance();
local FishMatrix = require("core.FishMatrix"):getInstance();

local MAX_FISH_COUNT = 55;

--static
function GameLayer:scene()

	local scene = display.newScene("FishScene");
    scene:addChild(self);
    self.scene = scene;

	local touchLayer = display.newLayer():addTo(scene);
	touchLayer:setContentSize(cc.Director:getInstance():getWinSize())
	touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE);
	touchLayer:setTouchEnabled(true);
	touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    if event.name == "began" then
	    	-- print("touch",event.x,event.y);
	    	self:click(event.x,event.y);
	    	self.isFiring=true;
	        return true;
        elseif event.name == "moved" then
        	self:move(event.x,event.y);
        	return true;
        elseif event.name == "ended" then
        	self.isFiring=false;
        	return true;
        end

	end)

    return scene;

end

function GameLayer:click(x,y)

	self.lastClick = cc.p(x,y);

	if self.my then
		-- self.my:fireToPonit(self.lastClick,true);
		self:fireToPonit(self.lastClick,true);
	end

end

function GameLayer:move(x,y)
	self.lastClick = cc.p(x,y);
end

--纪录返回的时候需要传递给roomlayer的场景恢复数据
function GameLayer:cacheLastSceneData(roomIndex,roomID,sitTableId)

	self.roomIndex = roomIndex
	self.roomID = roomID
	self.sitTableId = sitTableId

end

--instance init
function GameLayer:ctor()

	-- self.super.ctor(self);
	self:setNodeEventEnabled(true);

    self:initData();
    self:initFrames();
    self:onNodeLoading();
 	self:onNodeLoaded();

end

function GameLayer:initData()

	self.paoData = {};
	self.paoData.parent = self;
	self.fishData = {};

	self.score = 0;

	self.isInFastShootCD = false
	self.isInLockFishCD = false
	self.isInAutoShootCD = false
	--标记fish的清屏CD
	self.isInClearFishCD = false
	self.canReConnect = false

	self.myBulletCount=0;
end

function GameLayer:initFrames()

	-- for SpriteFrameCache: removing unused frame:
	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
	sharedSpriteFrameCache:removeUnusedSpriteFrames();

end

function GameLayer:onNodeLoading()

	local backgroundLayer = display.newLayer();
	self:addChild(backgroundLayer);
	self.backgroundLayer = backgroundLayer;

	local backgroundSprite = cc.Sprite:create("background/bg01.jpg");
	backgroundSprite:setPosition(getSrcreeCenter());
	backgroundLayer:addChild(backgroundSprite);
	self.backgroundSprite = backgroundSprite;

	self.rotateLayer = display.newLayer();
	self:addChild(self.rotateLayer)

	local visibleSize = cc.Director:getInstance():getWinSize();
	local fishLayer = display.newLayer();
	self.rotateLayer:addChild(fishLayer);
	-- fishLayer:ignoreAnchorPointForPosition(false)
	-- fishLayer:setAnchorPoint(cc.p(0.5,0.5));
	-- fishLayer:setPosition(cc.p(visibleSize.width/2,visibleSize.height/2));
	self.fishLayer = fishLayer;
	
	-- local bulletLayer = cc.SpriteBatchNode:create("pao.pvr.ccz");
	local bulletLayer = display.newLayer();
	self.rotateLayer:addChild(bulletLayer);
	self.bulletLayer = bulletLayer;

	self.playerLayer = display.newLayer();
	self.rotateLayer:addChild(self.playerLayer);
	-- self.playerLayer:ignoreAnchorPointForPosition(false)
	-- self.playerLayer:setAnchorPoint(cc.p(0.5,0.5))
	-- self.playerLayer:setPosition(getSrcreeCenter())

	self.coinLayer = display.newLayer()
	self.rotateLayer:addChild(self.coinLayer)

	if DataManager.myUserInfo.chairID > 2 then 
		FLIP_FISH = true
		
		local winSize = cc.Director:getInstance():getWinSize()
		self.rotateLayer:setPosition(winSize.width, winSize.height)
		self.rotateLayer:setRotation(180)
	else
		FLIP_FISH = false
	end

	self:initMenuAndSkill();

end

function GameLayer:initMenuAndSkill()

	local visibleSize = cc.Director:getInstance():getWinSize();

	local autoButton = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");

	local btn_autoImage = ccui.ImageView:create("game/btn_auto.png");
	btn_autoImage:setPosition(cc.p(autoButton:getContentSize().width/2,autoButton:getContentSize().height/2));
	btn_autoImage:setScale(1.15);
	local btn_autoText = ccui.ImageView:create("game/btn_auto_text.png");
	btn_autoText:setPosition(cc.p(autoButton:getContentSize().width/2,0));
	btn_autoText:setScale(1.15);
	autoButton:addChild(btn_autoImage);
	autoButton:addChild(btn_autoText);
	autoButton:setScale(0.87);

	autoButton:setPosition(cc.p(visibleSize.width-60, visibleSize.height-125-120));
	self:addChild(autoButton);
	autoButton:setPressedActionEnabled(true);
	autoButton:addTouchEventListener(
	    function(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then
	        	if self.my.userInfo.memberOrder > 0 or PayInfo:getChargeStatusById(437) or PayInfo:getChargeStatusById(438) then
	        		self:autoShoot()
	        	else
	        		if not self.isAutoShoot and not self.isInAutoShootCD then
	        			self:autoShoot()
					    self.autoShootCDScheduler = scheduler.performWithDelayGlobal(
					    	function()
	        					self.isInAutoShootCD = true
	        					self:autoShoot()
	        					local callFunc = function()	self.isInAutoShootCD = false end
		        				local pos = cc.p(visibleSize.width-60, visibleSize.height-125-120)
		        				self:openProgressTimer(pos,20,callFunc)
					    	end,
					    	60
					    )
	        		elseif self.isAutoShoot and not self.isInAutoShootCD then
	        			self:autoShoot()
					    if self.autoShootCDScheduler then
					        scheduler.unscheduleGlobal(self.autoShootCDScheduler)
					        self.autoShootCDScheduler = nil
					    end
					    self.isInAutoShootCD = true
	        			local callFunc = function()	self.isInAutoShootCD = false end
		        		local pos = cc.p(visibleSize.width-60, visibleSize.height-125-120)
		        		self:openProgressTimer(pos,20,callFunc)
		        	else
		        		Hall.showTips("CD时间中，充值任意金额解锁限制")
	        		end
	        	end

	        end
	    end
	)
	self.btn_autoShoot = autoButton;
	self.isAutoShoot=false;

	local lockButton = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");

	local btn_lockImage = ccui.ImageView:create("game/btn_lock.png");
	btn_lockImage:setPosition(cc.p(lockButton:getContentSize().width/2,lockButton:getContentSize().height/2));
	btn_lockImage:setScale(1.15);
	local btn_lockText = ccui.ImageView:create("game/btn_lock_text.png");
	btn_lockText:setPosition(cc.p(lockButton:getContentSize().width/2,0));
	btn_lockText:setScale(1.15);
	lockButton:addChild(btn_lockImage);
	lockButton:addChild(btn_lockText);
	lockButton:setScale(0.87);

	lockButton:setPosition(cc.p(visibleSize.width-60, visibleSize.height-125-240));
	self:addChild(lockButton);
	lockButton:setPressedActionEnabled(true);
	lockButton:addTouchEventListener(
	    function(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then

	        	if OnlineConfig_review == "on" or self.my.userInfo.memberOrder > 0 then
	        		self:lockFish()
	        	else
	        		if not self.isLockFish and not self.isInLockFishCD then
	        			self:lockFish()
					    self.lockFishCDScheduler = scheduler.performWithDelayGlobal(
					    	function()
	        					self.isInLockFishCD = true
	        					self:lockFish()
	        					local callFunc = function()	self.isInLockFishCD = false end
		        				local pos = cc.p(visibleSize.width-60, visibleSize.height-125-240)
		        				self:openProgressTimer(pos,20,callFunc)
					    	end,
					    	60
					    )
	        		elseif self.isLockFish and not self.isInLockFishCD then
	        			self:lockFish()
					    if self.lockFishCDScheduler then
					        scheduler.unscheduleGlobal(self.lockFishCDScheduler)
					        self.lockFishCDScheduler = nil
					    end
					    self.isInLockFishCD = true
	        			local callFunc = function()	self.isInLockFishCD = false end
		        		local pos = cc.p(visibleSize.width-60, visibleSize.height-125-240)
		        		self:openProgressTimer(pos,20,callFunc)
		        	else
		        		Hall.showTips("CD时间中，绿钻以上解锁限制")
	        		end
	        	end

	        end
	    end
	)

	self.btn_lockFish = lockButton;
	self.isLockFish = false;

	local fastButton = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");

	local btn_fastImage = ccui.ImageView:create("game/btn_fast.png");
	btn_fastImage:setPosition(cc.p(fastButton:getContentSize().width/2,fastButton:getContentSize().height/2));
	btn_fastImage:setScale(1.15);
	local btn_fastText = ccui.ImageView:create("game/btn_fast_text.png");
	btn_fastText:setPosition(cc.p(fastButton:getContentSize().width/2,0));
	btn_fastText:setScale(1.15);
	fastButton:addChild(btn_fastImage);
	fastButton:addChild(btn_fastText);
	fastButton:setScale(0.87);


	fastButton:setPosition(cc.p(visibleSize.width-60, visibleSize.height-125-360));
	self:addChild(fastButton);
	fastButton:setPressedActionEnabled(true);
	fastButton:addTouchEventListener(
	    function(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then
	        	if OnlineConfig_review == "on" or self.my.userInfo.memberOrder >= 3 then
	        		self:fastShoot()
	        	else
	        		if not self.isFastShoot and not self.isInFastShootCD then
	        			self:fastShoot()
					    self.fastShootCDScheduler = scheduler.performWithDelayGlobal(
					    	function()
	        					self.isInFastShootCD = true
	        					self:fastShoot()
	        					local callFunc = function()	self.isInFastShootCD = false end
		        				local pos = cc.p(visibleSize.width-60, visibleSize.height-125-360)
		        				self:openProgressTimer(pos,20,callFunc)
					    	end,
					    	60
					    )
	        		elseif self.isFastShoot and not self.isInFastShootCD then
	        			self:fastShoot()
					    if self.fastShootCDScheduler then
					        scheduler.unscheduleGlobal(self.fastShootCDScheduler)
					        self.fastShootCDScheduler = nil
					    end
					    self.isInFastShootCD = true
	        			local callFunc = function()	self.isInFastShootCD = false end
		        		local pos = cc.p(visibleSize.width-60, visibleSize.height-125-360)
		        		self:openProgressTimer(pos,20,callFunc)
		        	else
		        		Hall.showTips("CD时间中，紫钻以上解锁限制")
	        		end
	        	end
	        end
	    end
	)
	self.btn_fastShoot = fastButton;
	self.isFastShoot = false;

	if not PayInfo:getChargeStatusById(437) or not PayInfo:getChargeStatusById(438) then
		local giftButton = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");

		local btn_giftImage = ccui.ImageView:create("game/btn_gift.png");
		btn_giftImage:setPosition(cc.p(giftButton:getContentSize().width/2,giftButton:getContentSize().height/2));
		btn_giftImage:setScale(1.15);

		local btn_giftText = ccui.ImageView:create("game/btn_gift_text.png");
		btn_giftText:setPosition(cc.p(giftButton:getContentSize().width/2,0));
		btn_giftText:setScale(1.15);

		giftButton:addChild(btn_giftImage);
		giftButton:addChild(btn_giftText);
		giftButton:setScale(0.87);
		giftButton:setPosition(cc.p(visibleSize.width-60, visibleSize.height-125));
		self:addChild(giftButton);

		giftButton:addTouchEventListener(
		    function(sender,eventType)
		        if eventType == ccui.TouchEventType.ended then

				    if PayInfo:getChargeStatusById(437) then
					    local newLayer = require("show.popView_Hall.GuestLiBaoLayer").new(2)
					    self:addChild(newLayer,100)
				    else
					    local newLayer = require("show.popView_Hall.GuestLiBaoLayer").new(1)
					    self:addChild(newLayer,100)
				    end
		        	-- self:test();
		        end
		    end
		)
		self.giftButton = giftButton


		if OnlineConfig_review == "on" then    --优惠充值按钮
		    giftButton:setVisible(false);
		end
	end


	local leftMenuLayer = display.newLayer();
	leftMenuLayer:setContentSize(cc.size(100, 650));
	leftMenuLayer:setPosition(cc.p(10,120));
	self:addChild(leftMenuLayer,1);

	local btn_chat = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");

	local btn_chatImage = ccui.ImageView:create("game/btn_chat.png");
	btn_chatImage:setPosition(cc.p(btn_chat:getContentSize().width/2,btn_chat:getContentSize().height/2));
	btn_chatImage:setScale(1.15);
	local btn_chatText = ccui.ImageView:create("game/btn_chat_text.png");
	btn_chatText:setPosition(cc.p(btn_chat:getContentSize().width/2,0));
	btn_chatText:setScale(1.15);
	btn_chat:addChild(btn_chatImage);
	btn_chat:addChild(btn_chatText);
	btn_chat:setScale(0.87);

	btn_chat:setPosition(cc.p(50, 50));
	leftMenuLayer:addChild(btn_chat);
	btn_chat:setPressedActionEnabled(true);
	btn_chat:addTouchEventListener(
	    function(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then
				local chatDialog = require("popView.chatDialog").new();
				self:addChild(chatDialog,99);
	        end
	    end
	)
	self.btn_chat=btn_chat;


    --bank

    local visibleHeight = cc.Director:getInstance():getWinSize().height;

    local btn_bank = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");
    btn_bank:setPosition(cc.p(50, visibleHeight-550));
    btn_bank:onClick(
        function()
            local bankLayer = require("popView.BankLayer"):new()
            bankLayer:setInGame(true)
            self:addChild(bankLayer,10000)
        end
    );
    leftMenuLayer:addChild(btn_bank);

    local sprite = display.newSprite("game/btn_bank.png");
    sprite:setPosition(btn_bank:getContentSize().width/2, btn_bank:getContentSize().height/2);
    sprite:setScale(1.15);
    btn_bank:addChild(sprite);

    local sprite = display.newSprite("game/btn_bank_text.png");
    sprite:setPosition(btn_bank:getContentSize().width/2-6, -2);
    sprite:setScale(1.15);
    btn_bank:addChild(sprite);

    btn_bank:setScale(0.87);

	self.btn_bank = btn_bank;

	local btn_rule = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");

	local btn_ruleImage = ccui.ImageView:create("game/btn_rule.png");
	btn_ruleImage:setPosition(cc.p(btn_rule:getContentSize().width/2,btn_rule:getContentSize().height/2));
	btn_ruleImage:setScale(1.15);
	local btn_ruleText = ccui.ImageView:create("game/btn_rule_text.png");
	btn_ruleText:setPosition(cc.p(btn_rule:getContentSize().width/2,0));
	btn_ruleText:setScale(1.15);
	btn_rule:addChild(btn_ruleImage);
	btn_rule:addChild(btn_ruleText);
	btn_rule:setScale(0.87);

	btn_rule:setPosition(cc.p(50, visibleHeight-450));
	leftMenuLayer:addChild(btn_rule);
	btn_rule:setPressedActionEnabled(true);
	btn_rule:addTouchEventListener(
	    function(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then
				local introDialog = require("popView.introduceDialog").new();
				self:addChild(introDialog,99);
	        end
	    end
	)
	self.btn_rule=btn_rule;

	local btn_exit = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");

	local btn_exitImage = ccui.ImageView:create("game/btn_exit.png");
	btn_exitImage:setPosition(cc.p(btn_exit:getContentSize().width/2,btn_exit:getContentSize().height/2));
	btn_exitImage:setScale(1.15);
	local btn_exitText = ccui.ImageView:create("game/btn_exit_text.png");
	btn_exitText:setPosition(cc.p(btn_exit:getContentSize().width/2,0));
	btn_exitText:setScale(1.15);
	btn_exit:addChild(btn_exitImage);
	btn_exit:addChild(btn_exitText);
	btn_exit:setScale(0.87);

	btn_exit:setPosition(cc.p(50, visibleHeight-350));
	leftMenuLayer:addChild(btn_exit);
	btn_exit:setPressedActionEnabled(true);
	btn_exit:addTouchEventListener(
	    function(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then

                TableInfo:sendUserStandUpRequest(true);

                self:cleanScheduler()

			    local room = require("layer.roomLayer").new(self.roomIndex,self.roomID,self.sitTableId);
			    room:refreshRoomList()
			    room:refreshUserList(1)
			    display.replaceScene(room:scene());

	        end
	    end
	)
	self.btn_exit=btn_exit;

	local btn_menu = ccui.Button:create("game/btn_BG.png","game/btn_selecetBG.png");

	local btn_menuImage = ccui.ImageView:create("game/btn_menu.png");
	btn_menuImage:setPosition(cc.p(btn_menu:getContentSize().width/2,btn_menu:getContentSize().height/2));
	btn_menuImage:setScale(1.15);
	btn_menu:addChild(btn_menuImage);
	btn_menu:setScale(0.87);

	btn_menu:setPosition(cc.p(50, visibleHeight-250));
	leftMenuLayer:addChild(btn_menu);
	btn_menu:setPressedActionEnabled(true);
	btn_menu:addTouchEventListener(
	    function(sender,eventType)
	        if eventType == ccui.TouchEventType.ended then
	        	self:menuClick();
	        end
	    end
	)
	self.btn_menu=btn_menu;
	self.menuHide=false;
	
	self.treasureBoxSpr = ccui.ImageView:create("game/trurebox1.png");
	self.treasureBoxSpr:setPosition(cc.p(50, 80));
	leftMenuLayer:addChild(self.treasureBoxSpr)

	self:menuClick();
end

function GameLayer:refreshButtonStatus()
	if PayInfo:getChargeStatusById(437) and PayInfo:getChargeStatusById(438) then
		self.giftButton:setVisible(false);
	end
end

function GameLayer:cleanScheduler()
    if self.updateGameScheduler then
        scheduler.unscheduleGlobal(self.updateGameScheduler)
        self.updateGameScheduler = nil
    end
    if self.autoShootCDScheduler then
        scheduler.unscheduleGlobal(self.autoShootCDScheduler)
        self.autoShootCDScheduler = nil
    end
    if self.fastShootCDScheduler then
        scheduler.unscheduleGlobal(self.fastShootCDScheduler)
        self.fastShootCDScheduler = nil
    end
    if self.lockFishCDScheduler then
        scheduler.unscheduleGlobal(self.lockFishCDScheduler)
        self.lockFishCDScheduler = nil
    end
end

function GameLayer:onNodeLoaded()

	self:prepareServerData();

	self:loadBcakground();
	-- self:initFish();
	self:initPlayers();

	if 1 == cc.UserDefault:getInstance():getIntegerForKey("Music",1) then
	    audio.playMusic("sound/scene1.mp3",true);
	end

	
end

function GameLayer:prepareServerData()

	DataManager:refreshTabelInfo();

end

function GameLayer:loadBcakground()

	-- local texture = cc.Director:getInstance():getTextureCache():addImage("background/bg02.jpg");
 --    self.backgroundSprite:setTexture(texture);

    -- local numberLayer = require("core.rollNumGroup").new(8);
    -- numberLayer:setPosition(cc.p(350,20));
    -- self.numberLayer = numberLayer;
    -- self.backgroundLayer:addChild(numberLayer);

end

function GameLayer:initFish()

	-- //注册任务调度，不断检测游戏主界面的鱼儿数量并保持指定数量
    -- local scheduler = require("framework.scheduler");
    -- self.updateFishScheduler = scheduler.scheduleGlobal(function()
    --     self:updateFish()
    -- end, 0.5)

    -- self.isFishGeneratorStarted=true;


    local fish = cc.Sprite:create("yinwu/1.png");
	fish:setPosition(getSrcreeCenter());
	self.fishLayer:addChild(fish);


    local frames = {};
	for i=1,10 do
		local filename = "yinwu/"..i..".png";
		local sprite = display.newSprite(filename);
		local frame = cc.SpriteFrame:create(filename, sprite:getTextureRect());
		frames[i] = frame;
	end

	local animation = display.newAnimation(frames, 0.1);
	fish:runAction(cc.RepeatForever:create(cc.Animate:create(animation)));

	fish:setPosition(cc.p(0,100));
	fish:runAction(cc.MoveTo:create(10,cc.p(1500,800)));


end

--active
function GameLayer:onEnter()

	self:bindEvent()

    -- //注册任务调度，不断检测子弹与鱼儿的碰撞
    local scheduler = require("framework.scheduler")
    self.updateGameScheduler = scheduler.scheduleGlobal(
    	function()
	        self:updateGame();
    	end
    	,
    	0.05
    )

    self.isFishGeneratorStarted=true;
    self:checkIsMatrixing();
end


function GameLayer:onExit()
	local scheduler = require("framework.scheduler")
	if self.autoShootScheduler ~= nil then
		scheduler.unscheduleGlobal(self.autoShootScheduler)
	end
	if self.updateGameScheduler ~= nil then
		scheduler.unscheduleGlobal(self.updateGameScheduler)
	end

	if self.bulletCompensateScheduleId ~= nil then
		scheduler.unscheduleGlobal(self.bulletCompensateScheduleId)
	end
	self:unBindEvent()
	GLOBAL_BULLET_ID = 1

	--内存清理
	self:initFrames()
end


function GameLayer:bindEvent()

    self.bindIds = {}

    self.bindIds[#self.bindIds + 1] = BindTool.bind(DataManager, "tabelInfoChange", handler(self, self.refreshPlayers))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(DataManager, "changeUser", handler(self, self.refreshOnePlayer))

    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "userFireInfo", handler(self, self.refreshUserFire))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "catchFish", handler(self, self.refreshCatchFish))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "catchSweepFish", handler(self, self.onCatchSweepFish))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "catchSweepFishResult", handler(self, self.onCatchSweepFishResult))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "fishSpawnList", handler(self, self.refreshNewFishList))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "switchScene", handler(self, self.createMatrix))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "lockTimeOut", handler(self, self.onLockTimeOut))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "bulletCompensate", handler(self, self.onBulletCompensate))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "gameScene", handler(self, self.checkIsMatrixing))

	self.bindIds[#self.bindIds + 1] = BindTool.bind(SystemMessageInfo, "msgRresh", handler(self, self.refreshSysMsgRresh))

	self.bindIds[#self.bindIds + 1] = BindTool.bind(PayInfo, "paymentNofity", handler(self, self.refreshButtonStatus))

	--游戏断线重练_恢复流程
	self.bindIds[#self.bindIds + 1] = BindTool.bind(DataManager, "tabelStatuChange", handler(self, self.onTableStatusChange))
	--重新连上游戏后返回GameConfig
	self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "gameConfig", handler(self, self.refreshFishGameConfig))

	--游戏断线重练_SOCKET状态
	self.connected_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus))
	self.connecting_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTING, handler(self, self.onSocketStatus))
	-- self.close_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CLOSED, handler(self, self.onSocketStatus))
	-- self.failure_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTE_FAILURE, handler(self, self.onSocketStatus))
	self.hall_connecting_handler = HallConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTING, handler(self, self.onSocketStatus))

end

function GameLayer:unBindEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    GameConnection:removeEventListener(self.connected_handler)
    GameConnection:removeEventListener(self.connecting_handler)
    -- GameConnection:removeEventListener(self.close_handler)
    -- GameConnection:removeEventListener(self.failure_handler)
    HallConnection:removeEventListener(self.hall_connecting_handler)
end

function GameLayer:onSocketStatus(event)
	print("..断线重连回来.. GameLayer:onSocketStatus back ...............")
	if event.name == NetworkManagerEvent.SOCKET_CONNECTED then
		RoomInfo:sendLoginRequest(0, 60)
		self.canReConnect = true
	elseif event.name == NetworkManagerEvent.SOCKET_CONNECTING then
		print(".... GameLayer:onSocketStatus back ..SOCKET_CONNECTING..")
		--关闭开炮
		if self.isAutoShoot then
			self:autoShoot()
		end
	    if self.autoShootCDScheduler then
	        scheduler.unscheduleGlobal(self.autoShootCDScheduler)
	        self.autoShootCDScheduler = nil
	    end
		self:showNetworkState()
	elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
		print(".... GameLayer:onSocketStatus back ..SOCKET_CLOSED..")
		-- GameConnection:reconnectServer()
	elseif event.name == NetworkManagerEvent.SOCKET_CONNECTE_FAILURE then
		print(".... GameLayer:onSocketStatus back ..SOCKET_CONNECTE_FAILURE..")
		-- GameConnection:reconnectServer()
	end
end

-- US_NULL                          = 0x00,                -- 没有状态
-- US_FREE                          = 0x01,                -- 站立状态
-- US_SIT                           = 0x02,                -- 坐下状态
-- US_READY                         = 0x03,                -- 同意状态
-- US_LOOKON                        = 0x04,                -- 旁观状态
-- US_PLAYING                       = 0x05,                -- 游戏状态
-- US_OFFLINE                       = 0x06,                -- 断线状态

function GameLayer:onTableStatusChange(event)
    -- print("---玩家状态---GameLayer:---",DataManager.myUserInfo.userStatus)
    -- TableInfo:sendGameOptionRequest(true)
    if self.canReConnect and DataManager.myUserInfo.userStatus == US_PLAYING then
        TableInfo:sendGameOptionRequest(true)
    end
end

function GameLayer:refreshFishGameConfig(event)
    
    if self.canReConnect then
	    -- print("---玩家场景恢复---GameLayer:refreshFishGameConfig---")
	    GLOBAL_BULLET_ID = 1
	    if self.netWorkStateLayer then
	    	self.netWorkStateLayer:stopAllActions()
	    	self.netWorkStateLayer:removeFromParent()
	    	self.netWorkStateLayer = nil
	    end
	    self.canReConnect = false
    end

end

function GameLayer:refreshSysMsgRresh()
	-- dump(SystemMessageInfo.messages, "SystemMessageInfo.messages")
	-- for k,msgarr in pairs(SystemMessageInfo.messages) do
	-- 	if k == 3 then
	--     	for _, msg in ipairs(msgarr) do
	--     		print("comSysMsg:"..msg)
	--     	end
	-- 	end
	-- end
end


function GameLayer:updateGame(dt)

    --划分网格检测碰撞区域
    self:checkCollision()

    if self.isFishGeneratorStarted then
	    self.isFishGeneratorStarted = false;
		-- FishMatrix:createFishMatrix(self,FishMatrixType.BigFishMatrix,nil);		
	end

	if self.isFiring and self.lastClick then
		self:fireToPonit(self.lastClick);
	end

	self:aimLockFish()

end

function GameLayer:checkCollision2()
	local _bullets = {}

	for bulletPoint, bullet in pairs(self.paoData) do
		if bullet.hit == false then
			table.insert(_bullets, bullet)
		end
	end
	gameCollision.splitGrid(self.fishData, _bullets)
	gameCollision.checkCollision()

end

function GameLayer:checkFishValid(checkFish)

	local valid = false;
	for fishPoint, fish in pairs(self.fishData) do
		if fish == checkFish and fish:isFishValid() then
			valid = true;
		end
	end

	return valid;

end

function GameLayer:checkCollision()

	local checkBullets = {};
	local bulletRatius={10,20,25,30};
	for bulletPoint, bullet in pairs(self.paoData) do
		
		if bullet.hit == false and bullet.collideEnable then

			if bullet.lockFish ~= nil then

				if self:checkFishValid(bullet.lockFish) then
					
					-- if isSpriteInterset(bullet.lockFish,bullet) then

					if bullet.lockFish:checkCollide(cc.p(bullet:getPositionX(),bullet:getPositionY()),bulletRatius[bullet.paoLevel]) then

						bullet:setMainTarget(bullet.lockFish);
						bullet:showNet();

			        end
				else

					bullet.lockFish = nil;

				end

			end

			if bullet.lockFish == nil then

				bullet.boundingBox = bullet:getBoundingBox();
				bullet.checkBox = getFitRectForSprite(bullet);
				table.insert(checkBullets,bullet);

			end

		end

	end


	local checkFishes = {};
	for fishPoint, fish in pairs(self.fishData) do

		if fish:isFishValid() then

			-- fish.boundingBox = fish:getBoundingBox();
			-- fish.checkBox = getFitRectForSprite(fish);
			table.insert(checkFishes,fish);

		end

	end

	for i, bullet in ipairs(checkBullets) do
		
		for j, fish in ipairs(checkFishes) do

			-- if cc.rectIntersectsRect(fish.boundingBox, bullet.boundingBox) and isIntersetRect(fish.checkBox,bullet.checkBox) then

			-- 	bullet:setMainTarget(fish);
			-- 	bullet:showNet();

			-- end

			if(fish:checkCollide(cc.p(bullet:getPositionX(),bullet:getPositionY()),bulletRatius[bullet.paoLevel]))then
				bullet:setMainTarget(fish);
				bullet:showNet();
			end

		end

	end

end


function GameLayer:fireToPonit(pt,withOutCD)
	withOutCD = withOutCD or false;
	if self.isLockFish then

		if self.my.lockFish == nil or self:checkFishValid(self.my.lockFish) == false then
			self.my.lockFish = self:getLockFish();
		end

	else

		self.my.lockFish = nil;

	end

	self.my:fireToPonit(self.lastClick,withOutCD);

end

function GameLayer:getLockFish(lockFishID)

	if lockFishID and lockFishID <= 0 then
		return nil;
	end

	local lockFish;
	local lockFishType = 8;
	for fishPoint, fish in pairs(self.fishData) do

		if fish:isFishCanLock() and fish:checkIsBigFish() and fish:isFishValid() then
			lockFish = fish;
			lockFishType = fish._fishType;
		end

		-- if fish:isFishCanLock() and fish:getFishID() == lockFishID and fish:isFishValid() then
		-- 	lockFish = fish;
		-- 	break;
		-- end

	end

	return lockFish;

end

function GameLayer:aimLockFish()

	if self.my then
		if self.isLockFish and self.my.lockFish and self:checkFishValid(self.my.lockFish) then
			-- self.my.lockFish:focus(true);
			self.my:showAimLine();
		else
			self.my:hideAimLine();
		end
	end
	
end

function GameLayer:userFire(chairID, angle, cost, lockFishID)

	local players = self.players;

	if lockFishID then

		local lockFish = self:getLockFish(lockFishID);
		players[chairID].lockFish = lockFish;

	else

		players[chairID].lockFish = nil;

	end

	if players[chairID] ~= nil then
		players[chairID]:fireToDirection(angle,cost);
	end

end

--menu
function GameLayer:autoShoot()

	if self.my then

		if self.lastClick == nil then

			local pt = getSrcreeCenter();
			pt.x = self.my:getPositionX();
			self.lastClick = pt;

		end
		if(self.isAutoShoot == false)then
		    local scheduler = require("framework.scheduler")
		    self.autoShootScheduler = scheduler.scheduleGlobal(
		    	function()
		    		--鱼清屏期间不发射子弹
		    		if not self.isInClearFishCD then
		    			self:fireToPonit(self.lastClick);
		    		end
		    	end
		    	,
		    	0.01
		    )

		    self.btn_autoShoot:setHighlighted(true);
		    self.isAutoShoot=true;
		else
			if(self.autoShootScheduler~=nil)then
				scheduler.unscheduleGlobal(self.autoShootScheduler);
				self.autoShootScheduler=nil;
			end
			self.btn_autoShoot:setHighlighted(false);
			self.isAutoShoot=false;
		end
	end

end

function GameLayer:lockFish()

	if self.my then

		if(self.isLockFish==false)then
			self.btn_lockFish:setHighlighted(true);
			self.isLockFish=true;
		else
			self.btn_lockFish:setHighlighted(false);
			self.isLockFish=false;
		end

	end

end


function GameLayer:fastShoot()

	if self.my then
    	if(self.isFastShoot==false)then
			self.my.cannon:setFast(true);
			self.btn_fastShoot:setHighlighted(true);
			self.isFastShoot=true;
		else
			self.my.cannon:setFast(false);
			self.btn_fastShoot:setHighlighted(false);
			self.isFastShoot=false;			
		end

	end

end

function GameLayer:initPlayers()

	-- dump(DataManager.tableInfo, "DataManager.tableInfo")

	local players = {};
	self.players = players;

	for i, user in ipairs(DataManager.tableInfo) do
		self:addPlayer(user)
	end

	--初始化空座位
	for i=1,4 do
		if not self.players[i] then
			self:addWaitPlayer(i)
		end
	end

end

function GameLayer:onBulletCompensate(event)
	local player = self.players[FishInfo.bulletCompensate.chairID]
	if player then
		self.treasureBoxSpr:loadTexture("game/trurebox2.png")

		local pt = cc.p(self.treasureBoxSpr:getPositionX(), self.treasureBoxSpr:getPositionY())
		pt = self.treasureBoxSpr:getParent():convertToWorldSpace(pt)
		pt = self.coinLayer:convertToNodeSpace(pt)
		
    	self:gainCoin(FishInfo.bulletCompensate.chairID, pt, 11, false)
		
		self.bulletCompensateScheduleId = scheduler.performWithDelayGlobal(function(dt)
			self.treasureBoxSpr:loadTexture("game/trurebox1.png")
			player:changeScore(FishInfo.bulletCompensate.compensateScore)
			self.bulletCompensateScheduleId = nil
		end, 2)
	end
end

function GameLayer:checkIsMatrixing(event)
	if not FishInfo.gameScene then
		return
	end

	if FishInfo.gameScene.specialSceneLeftTime>0 then
		self:showGameTip(FishInfo.gameScene.specialSceneLeftTime,"其他玩家正在捕获鱼阵，耐心等待哦！")
	end
end



function GameLayer:addPlayer(userInfo)

	-- print("----addPlayer----", userInfo.chairID)

	--解决player被重复添加的问题
	local temp = self.playerLayer:getChildByTag(userInfo.chairID)
	if temp then
		temp:removeFromParent()
	end

	local player = require("core.player").new(userInfo,self.bulletLayer,self.paoData);
	self.playerLayer:addChild(player);
	player:setTag(userInfo.chairID);

	self.players[userInfo.chairID] = player;
	if userInfo.userID == AccountInfo.userId then
		self.my = player;
	end
end

function GameLayer:addWaitPlayer(seat)

	local player = require("core.player").new(nil,nil,nil,true,seat);
	self.playerLayer:addChild(player);
	self.players[seat] = player;

end

function GameLayer:menuClick()
	local visibleHeight = cc.Director:getInstance():getWinSize().height;

	if(self.menuHide==false)then
		self.menuHide=true;

		local rotate = cc.RotateTo:create(0.5,180);
		local callFunc = cc.CallFunc:create(function () self:hideMenu(); end) ;
  		self.btn_menu:runAction(cc.Sequence:create(rotate,callFunc));	

  		local moveto = cc.MoveTo:create(0.52,cc.p(50,visibleHeight-250));
  		self.btn_exit:runAction(moveto:clone());
  		self.btn_rule:runAction(moveto:clone());
  		self.btn_bank:runAction(moveto:clone());
  		self.btn_chat:runAction(moveto:clone());

  		self.treasureBoxSpr:setVisible(true)
	else
		self.menuHide=false;
		local rotate = cc.RotateTo:create(0.5,0);
		self.btn_menu:runAction(rotate);
		self.btn_exit:show();
		self.btn_exit:runAction(cc.MoveTo:create(0.5,cc.p(50,visibleHeight-350)));
		self.btn_rule:show();
		self.btn_rule:runAction(cc.MoveTo:create(0.5,cc.p(50,visibleHeight-450)));
		self.btn_bank:show();
		self.btn_bank:runAction(cc.MoveTo:create(0.5,cc.p(50,visibleHeight-550)));
		self.btn_chat:show();
		self.btn_chat:runAction(cc.MoveTo:create(0.5,cc.p(50,visibleHeight-650)));

		self.treasureBoxSpr:setVisible(false)
	end
end

function GameLayer:hideMenu()
	self.btn_exit:hide();
	self.btn_rule:hide();
	self.btn_bank:hide();
	self.btn_chat:hide();
end


function GameLayer:catchFishWithNet(net)

	local bullet = net;
	local fishList = {};

	--add main target
	local mainTarget = net.mainTarget;
	table.insert(fishList,mainTarget:getFishID());
	mainTarget:setInAttack(bullet,true);

	for fishPoint, fish in pairs(self.fishData) do

		-- local interset = isSpriteInterset(fish,net);
		local interset=false;
		if(fish ~= mainTarget) then
			interset = fish:checkCollide(cc.p(bullet:getPositionX(),bullet:getPositionY()),75+25*bullet.paoLevel);
		end

		if interset and fish ~= mainTarget then

			fish:setInAttack(bullet,false);

			--ignore so many fish to up catch fish rate.
			if #fishList < 2 and fish._fishType <= mainTarget._fishType then
				table.insert(fishList,fish:getFishID());
			end

		end

	end

    if bullet.myFire then
        FishInfo:sendBigNetCatchFishRequest(bullet.id , fishList )
    end

end

function GameLayer:gainScore(chairID, score, kind, fishMulti)

	local players = self.players;
	if players[chairID] ~= nil then
		players[chairID]:changeScore(score, kind, fishMulti);
	end

	if self.my.seat == chairID and fishMulti>= 15 then
		if fishMulti > 30 or (fishMulti>= 15 and score>=50000) then
			self:callBonusAni(score);
		end
	end
end

function GameLayer:gainCoin(chairID, pt, onum, isLiquan)
	local flip=1
	if chairID==3 or chairID==4 then
		flip=-1
	end
	local players = self.players;
	if players[chairID] == nil then
		return;
	end
	local player = players[chairID];
	local target = cc.p(player:getPositionX(),player:getPositionY());
	if pt==nil then
		pt=cc.p(player:getPositionX()+math.random(0,30)-15,player:getPositionY()+math.random(0,30)-15);
	end

	local tangle;
	local step;

	local coinType = onum / 10;
	local num = onum % 10;
	if num <= 0 or num > 10 then
        return;
    end

    if num == 1 then
        tangle = 0;
        step = tangle;
    elseif num == 2 then
        tangle = math.pi/6;
        step = tangle;
    elseif(num == 3) then
        tangle = math.pi/3;
        step = tangle/(num-1);
    else 
        tangle = math.pi/2;
        step = tangle/(num-1);
    end

    if isLiquan then
    	tangle = math.pi/8;
    	step = tangle/(num);
    end

    for i=1,num do

    	local angle;
    	if num %2 == 1 then
            angle = math.pi/2+math.pow(-1.0,i)*step*(math.floor(i/2));
        else 
            angle = (math.pi/2 - tangle/2)+(step*(i-1));
        end


        local coin = require("core.coin").new(isLiquan);
        coin:setPosition(pt);

        coin:addLinePathTo(0.2, cc.p(pt.x+175*math.cos(angle),pt.y+(175*math.sin(angle)-75)*flip));
        coin:addLinePathTo(1, target);

        if isLiquan then
        	pt=cc.p(pt.x+math.random(0,10)-5,pt.y+math.random(0,10)-5);
        	coin:setPosition(pt);
        	coin:setVisible(false);
        	self.coinLayer:addChild(coin,num-i);
        	self:performWithDelay(
		      function()
		      	coin:goCoin();
		      end,
		      1.35+(i-1)*0.1
		    )
        else
        	self.coinLayer:addChild(coin,num-i);
        	coin:goCoin();
    	end

        if FLIP_FISH then
        	coin:setRotation(180);
        end

    end
end

function GameLayer:updateBonus()

end

function GameLayer:addFish(fishType, pathType, fishID)

	-- if fishType == 1 or fishType == 2 then

	-- 	if self.test1111 then
	-- 		return 
	-- 	else
	-- 		self.test1111=true;
	-- 		local _fishobj=FishManager:createSpecificFish(self, 20, 0);
	-- 		self.fishLayer:addChild(_fishobj);
	-- 		_fishobj:goFish();
	-- 		self.fishLayer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))

	-- 		local sequence = cc.Sequence:create(cc.RotateTo:create(5,180),cc.RotateTo:create(5,360))
	-- 		self.fishLayer:runAction(cc.RepeatForever:create(sequence));
	-- 		return
	-- 	end	
	-- end

	-- if fishType~=15 and fishType~=16 then
	-- 	return
	-- end

	local _fishobj = FishManager:createSpecificFish(self, fishType, pathType);
	_fishobj:setFishID(fishID);
	self.fishLayer:addChild(_fishobj);
	_fishobj:goFish();

	self.fishData[fishID] = _fishobj;


	-- local num = 8 - fishType;
	-- if num < 0 then num=0 end
	-- for i=1,num do
	-- 	local followFish = FishManager:createSpecificFish(self, fishType, pathType);
	-- 	followFish:setFishID(9999);
	-- 	self.fishLayer:addChild(followFish);
	-- 	followFish:goFish();
	-- end


	-- local _fishShadow = FishManager:createSpecificFish(self, fishType, pathType);
	-- self.fishLayer:addChild(_fishShadow);
	-- _fishShadow:goFish();
	-- _fishShadow:setPosition(cc.p(_fishobj:getPositionX()+20,_fishobj:getPositionY()+20));
	-- _fishShadow:setColor(cc.c3b(0,0,0));
	-- _fishShadow:setLocalZOrder(-1);



	-- 鱼组测试
	-- local _fishGroup=FishGroup:createFishGroup(self,3,fishType, pathType);
	-- for k, _fish in pairs(_fishGroup) do
	-- 	_fish:setFishID(fishID);
	-- 	self.fishLayer:addChild(_fish);
	-- 	_fish:goFish();
	-- end

	-- if self.isFishGeneratorStarted then
	--     self.isFishGeneratorStarted = false;
	-- 	FishMatrix:createFishMatrix(self,FishMatrixType.BigFishMatrix,nil);
	-- end
end

function GameLayer:addFishGroup(fishType, pathType, IdArray)
	-- if true then
	-- 	return
	-- end

	local _fishGroup=FishGroup:createFishGroup(self,#IdArray,fishType, pathType);
	for k, _fish in ipairs(_fishGroup) do
		_fish:setFishID(IdArray[k]);
		self.fishLayer:addChild(_fish);
		_fish:goFish();
		self.fishData[IdArray[k]] = _fish;
	end
end

function GameLayer:refreshOnePlayer(event)
	-- print("---GameLayer:refreshOnePlayer---------")
	for i=1,4 do
		if self.players[i] and self.players[i].userInfo and self.players[i].userInfo.userID == DataManager.changeUserInfo.userID then
			self.players[i]:refreshScore(DataManager.changeUserInfo.score)
		end
	end
end

--server interface
function GameLayer:refreshPlayers(event)
	-- print("---GameLayer:refreshPlayers--begin-------")
	--测试数据
	for j, user in ipairs(DataManager.tableInfo) do
		-- print("player score------",user.tableID,user.chairID,user.gameID,user.score)
	end
	-- print("---GameLayer:refreshPlayers--end-------")

	local players = self.players;
	for i = 1, 4 do
		local justSeat = players[i];
		local nowSeat;
		for j, user in ipairs(DataManager.tableInfo) do
			if user.chairID == i then
				nowSeat = user;
				break;
			end
		end
		if justSeat ~= nil and justSeat.userInfo ~= nil and (nowSeat == nil or nowSeat.userID ~= justSeat.userInfo.userID) then
			players[i] = nil;
			justSeat:removeFromParent();
		end
		if players[i] ~= nil and players[i].userInfo == nil and nowSeat ~= nil then
			players[i]:removeFromParent()
			players[i] = nil
			self:addPlayer(nowSeat)
		end
		-- if self.players[i] and nowSeat then
		-- 	self.players[i]:refreshScore(nowSeat.score)
		-- end
	end

	--刷新空座位
	for i=1,4 do
		if not self.players[i] then
			self:addWaitPlayer(i)
		end
	end

	--桌子上一个人也没有
	if #DataManager.tableInfo == 0 then
		print("出现了桌子上一个人也没有到情况!!!!")
		self.my = nil
	    if self.netWorkStateLayer then
	    	self.netWorkStateLayer:stopAllActions()
	    	self.netWorkStateLayer:removeFromParent()
	    	self.netWorkStateLayer = nil
	    end
	    Hall.showTips("连接超时，请重新登录游戏!",3)
	end
end

function GameLayer:refreshUserFire(event)

	--如果坐在我的对面，就将角度值加上180
	-- if DataManager.myUserInfo.chairID > 2 then event.value.angle = event.value.angle + 180 end

	-- event字段
	-- tem.bulletKind = response.bulletKind
	-- tem.bulletID = response.bulletID
	-- tem.chairID = response.chairID
	-- tem.angle = response.angle
	-- tem.bulletMultiple = response.bulletMultiple
	-- tem.lockFishID = response.lockFishID

	-- print("User Fire .................."..event.value.bulletKind.."...AAAA..."..event.value.bulletMultiple,event.value.lockFishID)

	-- 炮弹价格 event.value.bulletMultiple

	local cost = event.value.bulletMultiple
    if not cost then
        print("出错了....玩家发的子弹没有价值....强制为100....")
        cost = 100
    end

	self:userFire(event.value.chairID, event.value.angle, cost, event.value.lockFishID);

end

function GameLayer:refreshCatchFish(event)


	-- tem.fishID = response.fishID
	-- tem.chairID = response.chairID
	-- tem.fishKind = response.fishKind
	-- tem.fishScore = response.fishScore
	-- tem.fishMulti = response.fishMulti

	local catchinfo = FishInfo.catchFish
	-- print("-----抓到鱼了--------",catchinfo.fishID,catchinfo.fishMulti);

	local tarFish = nil
	for k, fish in pairs(self.fishData) do
		if fish:getFishID() == catchinfo.fishID then
			tarFish = fish
			break
		end
	end
	
	if tarFish then
		if tarFish._fishType == FishType.FISH_FROZEN then --定屏鱼
			print("----定屏鱼--type---", tarFish._fishType)
			self:onCatchLockFish();
		-- elseif tarFish._fishType == FishType.FISH_ZHADAN then
		-- 	print("----炸弹鱼--type---", tarFish._fishType)
		-- 	self:onCatchSmallBomFish(tarFish);
		-- elseif tarFish._fishType == FishType.FISH_DAZHADAN then --超级炸弹鱼
		-- 	print("----大炸弹鱼--type---", tarFish._fishType)
		-- 	self:onCatchBomFish()
		end


		local pt = cc.p(tarFish:getPosition());
		-- if tarFish:checkIsLiQuan()==false then
			local multi=catchinfo.fishMulti/3;
			if multi >=10 then
				multi=9;
			elseif multi<1 then
				multi=1;
			end
			local onum=10+math.floor(multi);
			if tarFish._fishType == 26 then -- 26 是大宝箱
				onum=15;
			end
    		self:gainCoin(catchinfo.chairID, pt, onum, tarFish:checkIsLiQuan());
    	-- end

    	tarFish:killFish()
	else

		print("gain coin without Fish!!!!!!!!!!!!!!")
		local multi=catchinfo.fishMulti/3;
		if multi >=10 then
			multi=9;
		elseif multi<1 then
			multi=1;
		end
		local onum=10+math.floor(multi);
    	self:gainCoin(catchinfo.chairID, nil, onum, false);
	
	end

	self:gainScore(catchinfo.chairID, catchinfo.fishScore, catchinfo.fishKind, catchinfo.fishMulti);

end

function GameLayer:onCatchSweepFish(event)
	local tarFish = nil
	for k, fish in pairs(self.fishData) do
		if fish:getFishID() == event.value.fishID then
			tarFish = fish
			break
		end
	end
	print("----炸弹鱼--type---", tarFish._fishType)
	if tarFish then
		if tarFish._fishType == FishType.FISH_FROZEN then --定屏鱼
			self:onCatchLockFish();
			tarFish:killFish();
		elseif tarFish._fishType == FishType.FISH_ZHADAN then
			self:onCatchSmallBomFish(tarFish);
			tarFish:killFish();
		elseif tarFish._fishType == FishType.FISH_DAZHADAN then --超级炸弹鱼
			self:onCatchBomFish()
			tarFish:killFish()
		end
	else
		print("----炸弹鱼已经死了，才抓到有点奇怪-----")
	end
end

function GameLayer:onCatchSweepFishResult(event)
	local killFishIdList = FishInfo.catchSweepFishResult.fishIDList
	for _, fishId in ipairs(killFishIdList) do
		if self.fishData[fishId] then
			
			local pt = cc.p(self.fishData[fishId]:getPosition());
			-- if self.fishData[fishId]:checkIsLiQuan()==false then
				local multi=FishInfo.catchSweepFishResult.fishMulti/3;
				if multi >=10 then
					multi=9;
				elseif multi<1 then
					multi=1;
				end
				local onum=10+math.floor(multi);
				if self.fishData[fishId]._fishType == 26 then -- 26 是大宝箱
					onum=15;
				end
	    		self:gainCoin(FishInfo.catchSweepFishResult.chairID, pt, onum, self.fishData[fishId]:checkIsLiQuan());
	    	-- end
	    	self.fishData[fishId]:killFish();

		else
			print("gain coin without Fish!!!!!!!!!!!!!!")
			local multi=FishInfo.catchSweepFishResult.fishMulti/3;
			if multi >=10 then
				multi=9;
			elseif multi<1 then
				multi=1;
			end
			local onum=10+math.floor(multi);
			self:gainCoin(FishInfo.catchSweepFishResult.chairID, nil, onum, false);
		end
	end
	self:gainScore(FishInfo.catchSweepFishResult.chairID, FishInfo.catchSweepFishResult.fishScore, FishInfo.catchSweepFishResult.fishKind, FishInfo.catchSweepFishResult.fishMulti);
end

function GameLayer:onCatchBomFish()
	local fishIds = {}
	for k, fish in pairs(self.fishData) do
		fishIds[#fishIds + 1] = fish:getFishID()
	end

	FishInfo:sendCatchSweepFishRequest(FishInfo.catchSweepFish.chairID, FishInfo.catchSweepFish.fishID, fishIds)
end

function GameLayer:onCatchSmallBomFish(bombFish)
	local fishIds = {}
	for k, fish in pairs(self.fishData) do
		local xD=fish:getPositionX() - bombFish:getPositionX();
		local yD=fish:getPositionY() - bombFish:getPositionY();

		if(xD*xD+yD*yD<=120*120)then
			fishIds[#fishIds + 1] = fish:getFishID()
		end
	end
	if(#fishIds>0)then
		FishInfo:sendCatchSweepFishRequest(FishInfo.catchSweepFish.chairID, FishInfo.catchSweepFish.fishID, fishIds)
	end
end

--锁定所有活着的鱼
function GameLayer:onCatchLockFish()
	--to do
	for k, fish in pairs(self.fishData) do
		fish:frozen();
	end
end

--重置所有的鱼，让其恢复游动
function GameLayer:onLockTimeOut(event)
	--to do
	for k, fish in pairs(self.fishData) do
		fish:resumeFrozen();
	end
end

function GameLayer:refreshNewFishList(event)
	-- print("refreshNewFishList begin")
	local lastFishType=-1;
	local lastFishPath=-1;
	local lastFishGroup={};
	local lastFishID=-1;
	local groupFlag=false;
	for k, item in ipairs(FishInfo.fishSpawnList) do
		if(lastFishType == item.fishKind and lastFishPath == item.pathID)then
			if(groupFlag==false)then
				groupFlag=true;
				lastFishGroup={};
				table.insert(lastFishGroup,lastFishID);
				table.insert(lastFishGroup,item.fishID);
			else
				table.insert(lastFishGroup,item.fishID);
			end
		else
			if(groupFlag)then
				groupFlag=false;
				self:addFishGroup(lastFishType, lastFishPath, lastFishGroup);
			else
				if(k~=1)then
					self:addFish(lastFishType, lastFishPath, lastFishID);
				end
			end
		end
		lastFishType = item.fishKind; 
		lastFishPath = item.pathID;
		lastFishID = item.fishID;
		-- print("Type: ",item.fishKind, " path : ",item.pathID," ID : ",item.fishID);
		if(k == #FishInfo.fishSpawnList)then
			if(groupFlag)then
				self:addFishGroup(lastFishType, lastFishPath, lastFishGroup);
			else
				self:addFish(lastFishType, lastFishPath, lastFishID);
			end
		end
	end
	-- print("refreshNewFishList end")
end
function GameLayer:test()
	for k, fish in pairs(self.fishData) do
		-- fish:frozen(5);
		-- fish:quickGoOut();

	end
	-- FishMatrix:createBigRingMatrix(self);	
	-- FishMatrix:createSineMatrix(self);	
	-- FishMatrix:createTestBigFishMatrix(self);
	-- FishMatrix:createTestBoxMatrix(self);	
	
end

function GameLayer:	callBonusAni(goldText)
	local bonusLayer = display.newLayer();
	-- bonusLayer:setPositionY();
	bonusLayer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
	if cc.Director:getInstance():getWinSize().height<=1080 then
		bonusLayer:setScale(0.88);
	end
	self:addChild(bonusLayer,98)
	local armature = self:getBonusAnimation()
	if armature then
	    armature:setPosition(cc.p(0,-175))
	    bonusLayer:addChild(armature);
	    armature:getAnimation():playWithIndex(0);

		local money = display.newTTFLabel({text = goldText,
                                        size = 55,
                                        color = cc.c3b(255,224,19),
                                        font = FONT_PTY_TEXT
                                    })
	    money:enableOutline(cc.c4b(240,0,0,255),1);
	    money:setPosition(cc.p(0, -175));
	    money:setAnchorPoint(cc.p(0.5,0.5));
	    money:setScale(0.1);

	    money:runAction(cc.ScaleTo:create(0.25, 1));

	    bonusLayer:addChild(money,1);
	end

	self:performWithDelay(
		function()
		  	bonusLayer:removeFromParent();
		end,
		2.9
	)
end

function GameLayer:refreshSitDown(event)
	print("坐下成功，请求游戏配置数据")
	TableInfo:sendGameOptionRequest(true)
end

function GameLayer:createMatrix( event )
	print("createMatrix is called")
	self:cleanFishGetOut();
	local winSize = cc.Director:getInstance():getWinSize();
	local particle = cc.ParticleSystemQuad:create("effect/lizi_paopao_1.plist");
	particle:setPosition(cc.p(winSize.width/2, -50));
	self:addChild(particle);

	local function playPop(dt)
		-- local particle = cc.ParticleSystemQuad:create("effect/lizi_paopao_1.plist");
		-- local winSize = cc.Director:getInstance():getWinSize();
		-- particle:setPosition(cc.p(winSize.width/2, -50));
		-- self:addChild(particle);
		FishMatrix:createFishMatrix(self,FishInfo.switchScene.sceneKind,FishInfo.switchScene.fishList);	
	end

	local scheduler = require("framework.scheduler");
    scheduler.performWithDelayGlobal(playPop, 0.4);

    --提示鱼阵即将出来
    self:showGameTip(4,"等待鱼阵开始，暂时不能出炮哦！ ")
	
    --关闭触屏的按住不动射击
	self.isFiring=false
end

function GameLayer:cleanFishGetOut()
	for k, fish in pairs(self.fishData) do
		fish:quickGoOut();
	end
	if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
	    -- audio.playSound("sound/WaveEnter.mp3");
	    audio.playSound("sound/Bubbling.mp3");
	end
end

--游戏内提示
function GameLayer:showGameTip(second , words)

	self.isInClearFishCD = true

    local winSize = cc.Director:getInstance():getWinSize()

    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)

    --bgSprite
    local bgSprite = display.newSprite("game/game_tip_bg.png"):pos(winSize.width/2, winSize.height/2)
    bgSprite:setScaleX(1.2)
    bgSprite:addTo(maskLayer)

    local tip = ccui.Text:create(words..second.."s",FONT_PTY_TEXT,28)
    tip:setPosition(winSize.width/2, winSize.height/2)
    tip:setColor(cc.c3b(0xfb, 0xdd, 0x1d))
    tip:enableOutline(cc.c4b(0x00,0x0d,0x07,255),2)
    maskLayer:addChild(tip)

    local callFunc = function()
        if second > 0 then
        	second = second - 1
        	tip:setString(words..second.."s")
        end
        if second == 0 then
        	maskLayer:stopAllActions()
		    local sequence = transition.sequence(
		        {
		            cc.DelayTime:create(0.3),
		            cc.CallFunc:create(
		            	function()
		            		self.isInClearFishCD = false
		            		maskLayer:removeFromParent()
		            	end
		            )
		        }
		    )
		    maskLayer:runAction(sequence)
        end
    end

    local sequence = transition.sequence(
        {
            cc.DelayTime:create(1.0),
            cc.CallFunc:create(callFunc)
        }
    )
    maskLayer:runAction(cc.RepeatForever:create(sequence))

end

--游戏内网络不好提示
function GameLayer:showNetworkState()

    if self.netWorkStateLayer then
    	self.netWorkStateLayer:stopAllActions()
    	self.netWorkStateLayer:removeFromParent()
    	self.netWorkStateLayer = nil
    end

    local winSize = cc.Director:getInstance():getWinSize()

    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)

    self.netWorkStateLayer = maskLayer

    --bgSprite
    local bgSprite = display.newSprite("game/game_tip_bg.png"):pos(winSize.width/2, winSize.height/2)
    bgSprite:setScaleX(1.2)
    bgSprite:addTo(maskLayer)

    local tip = ccui.Text:create("网络异常，重连中 ",FONT_PTY_TEXT,28)
    tip:setPosition(winSize.width/2, winSize.height/2)
    tip:setColor(cc.c3b(0xfb, 0xdd, 0x1d))
    tip:enableOutline(cc.c4b(0x00,0x0d,0x07,255),2)
    maskLayer:addChild(tip)

    local startNum = 1

    local callFunc = function()
        
        startNum = startNum + 1
        if startNum % 4 == 1 then
        	tip:setString("网络异常，重连中 .")
        elseif startNum % 4 == 2 then
        	tip:setString("网络异常，重连中 ..")
        elseif startNum % 4 == 3 then
        	tip:setString("网络异常，重连中 ...")
        end
    end

    local sequence = transition.sequence(
        {
            cc.DelayTime:create(1.0),
            cc.CallFunc:create(callFunc)
        }
    )
    maskLayer:runAction(cc.RepeatForever:create(sequence))

end

--扇形进度条
function GameLayer:openProgressTimer(pos,time,callback)

	-- local winSize = cc.Director:getInstance():getWinSize()
	local myProgressTimer = cc.ProgressTimer:create(cc.Sprite:create("game/baiyuan.png"))
	myProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	myProgressTimer:setPercentage(100)
	-- myProgressTimer:setPosition(cc.p(winSize.width/2,winSize.height/2))
	myProgressTimer:setPosition(pos)
	myProgressTimer:runAction(cc.RepeatForever:create(cc.ProgressTo:create(time, 0)))
    local sequence = transition.sequence(
        {
        	cc.DelayTime:create(time),
            cc.CallFunc:create(callback)
        }
    )
    myProgressTimer:runAction(sequence)
	self:addChild(myProgressTimer)

end


function GameLayer:getBonusAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("ani_taibangle") == nil then
        manager:addArmatureFileInfo("effect/ani_taibangle/ani_taibangle0.png","effect/ani_taibangle/ani_taibangle0.plist","effect/ani_taibangle/ani_taibangle.ExportJson")
    end
    local armature = ccs.Armature:create("ani_taibangle")
    return armature;
end


return GameLayer;
