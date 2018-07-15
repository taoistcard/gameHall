local introduceDialog = class("introduceDialog", require("show.popView_Hall.baseWindow") );

local FishManager = require("core.FishManager"):getInstance();

function introduceDialog:ctor()
    self.super.ctor(self,2);

	self:createUI();
end

function introduceDialog:createUI( )

	-- local bg= ccui.ImageView:create("common/ty-nk2.png");
	-- bg:setPosition(cc.p(393,105));
	-- bg:setAnchorPoint(cc.p(0,0));
	-- self:addChild(bg);
    
    local size = self:getContentSize();

    local title_fish = display.newSprite("popView/title_introFish.png", size.width/2, size.height/2+250);
    self:addChild(title_fish);
    self.title_fish=title_fish;
    local title_skill = display.newSprite("popView/title_introSkill.png", size.width/2, size.height/2+250);
    self:addChild(title_skill);
    self.title_skill=title_skill;

   	self:createFishIntro();
   	self:createSkillIntro();

   	local btn_fish = ccui.Button:create("popView/yuleijies.png","common/ty_154_lv_btn.png");
    self:addChild(btn_fish);
    btn_fish:setPosition(cc.p(size.width/2-256, size.height/2+120));
    btn_fish:onClick(function()self:chooseFish();end);
    self.btn_fish=btn_fish;

    local btn_fishText = ccui.ImageView:create("popView/btn_introFish_text.png");
    btn_fishText:setPosition(cc.p(btn_fish:getContentSize().width/2,btn_fish:getContentSize().height/2));
    btn_fish:addChild(btn_fishText);
    self.btn_fishText=btn_fishText;

    local btn_skill = ccui.Button:create("popView/caozjis.png","common/ty_154_lv_btn.png");
    self:addChild(btn_skill);
    btn_skill:setPosition(cc.p(size.width/2-256, size.height/2+40));
    btn_skill:onClick(function()self:chooseSkill();end);
    self.btn_skill=btn_skill;

    local btn_skillText = ccui.ImageView:create("popView/btn_introSkill_text.png");
    btn_skillText:setPosition(cc.p(btn_skill:getContentSize().width/2,btn_skill:getContentSize().height/2));
    btn_skill:addChild(btn_skillText);

    self.btn_skillText=btn_skillText;

    self:chooseFish();
end

function introduceDialog:chooseFish()
	self.btn_fish:setHighlighted(true);
	self.btn_skill:setHighlighted(false);
	self.fishListView:show();
	self.skillListView:hide();
	self.title_fish:show();
	self.title_skill:hide();
	self.btn_fishText:show();
	self.btn_skillText:hide();

end

function introduceDialog:chooseSkill()
	self.btn_fish:setHighlighted(false);
	self.btn_skill:setHighlighted(true);
	self.fishListView:hide();
	self.skillListView:show();
	self.title_fish:hide();
	self.title_skill:show();
	self.btn_fishText:hide();
	self.btn_skillText:show();

end

function introduceDialog:createFishIntro()

    local size = self:getContentSize();

	self.fishListView = ccui.ListView:create();
    self.fishListView:setDirection(ccui.ScrollViewDir.vertical);
    self.fishListView:setBounceEnabled(true);
    self.fishListView:setContentSize(cc.size(476, 375));
    self.fishListView:setPosition(size.width/2-166,size.height/2-190);
    self:addChild(self.fishListView);

    local fishScale={1,1,1,1,1,0.8,0.65,0.65,0.6,0.75,0.6,0.5,0.4,0.35,0.28,0.28,0.28,0.25,0.32,0.3,0.25};
    local fishBonuse={2,2,3,4,5,6,7,8,9,10,12,15,18,20,25,30,35,"?","?","?","?"};

    local curretItem=nil;
    for i=1,21 do
    	if(i%3==1)then
    		local custom_item = ccui.Layout:create();
	    	custom_item:setContentSize(cc.size(460, 88));
	    	self.fishListView:pushBackCustomItem(custom_item);
	    	curretItem=custom_item;

	    	local cutLine = ccui.ImageView:create("popView/cut_line.png");
			cutLine:setScaleX(460/cutLine:getContentSize().width);
			cutLine:setPosition(cc.p(230,0));
			curretItem:addChild(cutLine,1);
    	end
    	local fish = cc.Sprite:createWithSpriteFrameName((FishManager:getFishFilePrefix(i).."-yd-1.png"));
    	fish:setAnchorPoint(cc.p(0.5,0.5));
    	fish:setPosition(cc.p(36+((i-1)%3)*(459/3),50));
    	fish:setScale(fishScale[i]);
    	curretItem:addChild(fish);

    	local bonus = display.newTTFLabel({text = "="..fishBonuse[i].."倍",
                                        size = 24,
                                        color = cc.c3b(255,224,19),
                                        font = FONT_PTY_TEXT
                                    })
	    bonus:enableOutline(cc.c4b(0,0,0,255),2);
	    bonus:setPosition(cc.p(75+((i-1)%3)*(459/3), 33));
	    bonus:setAnchorPoint(cc.p(0,0));
	    curretItem:addChild(bonus,2);

    end 

end

function introduceDialog:createSkillIntro()

    local size = self:getContentSize();

	self.skillListView = ccui.ListView:create();
    self.skillListView:setDirection(ccui.ScrollViewDir.vertical);
    self.skillListView:setBounceEnabled(true);
    self.skillListView:setContentSize(cc.size(476, 375));
    self.skillListView:setPosition(size.width/2-166,size.height/2-190);
    self:addChild(self.skillListView);
	
    local iconPath={"game/btn_auto.png","game/btn_lock.png","game/btn_fast.png"};
    local iconTextPath={"game/btn_auto_text.png","game/btn_lock_text.png","game/btn_fast_text.png"};
    local introduceWords={"自动射击，解放你的双手！","锁定大鱼，轻松赢取金币！","快速射击，土豪必备！"};

    for i=1,3 do
	    local custom_item = ccui.Layout:create();
	    custom_item:setContentSize(cc.size(460, 125));

	    
	    local iconBG = ccui.ImageView:create("game/btn_BG.png");
		local iconImage = ccui.ImageView:create(iconPath[i]);
		iconImage:setPosition(cc.p(iconBG:getContentSize().width/2,iconBG:getContentSize().height/2));
		iconImage:setScale(1.15);
		local iconText = ccui.ImageView:create(iconTextPath[i]);
		iconText:setPosition(cc.p(iconBG:getContentSize().width/2,0));
		iconText:setScale(1.15);
		iconBG:addChild(iconImage);
		iconBG:addChild(iconText);
		iconBG:setScale(0.87);
		iconBG:setPosition(cc.p(65,70));
		local cutLine = ccui.ImageView:create("popView/cut_line.png");
		cutLine:setScaleX(460/cutLine:getContentSize().width);
		cutLine:setPosition(cc.p(230,-30));
		iconBG:addChild(cutLine);
		custom_item:addChild(iconBG);


		local introduce = display.newTTFLabel({text = introduceWords[i],
                                        size = 24,
                                        color = cc.c3b(255,224,19),
                                        font = FONT_PTY_TEXT
                                    })
	    introduce:enableOutline(cc.c4b(0,0,0,255),2);
	    introduce:setPosition(cc.p(130, 50));
	    introduce:setAnchorPoint(cc.p(0,0));
	    custom_item:addChild(introduce);


		self.skillListView:pushBackCustomItem(custom_item);
	end

end

return introduceDialog;