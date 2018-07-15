
local Fish = class("Fish", function() return display.newSprite("blank.png");end)

local _freshRateArray = {
    100,--// FISH_XIAOGUANGYU = 0,
    90,--// FISH_XIAOCAOYU,
    90,--// FISH_REDAIYU,
    80,--// FISH_DAYANJINYU,
    80,--// FISH_SHUIMU,
    70,--// FISH_SHANWEIYU,
    70,--// FISH_REDAIZIYU,
    60,--// FISH_XIAOCHOUYU,
    60,--// FISH_HETUN,
    50,--// FISH_WUZEI,
    50,--// FISH_SHITOUYU,
    45,--// FISH_SHENXIANYU,
    45,--// FISH_WUGUI,
    40,--// FISH_DENGLONGYU,
    40,--// FISH_SHIBANYU,
    35,--// FISH_HUDIEYU,
    35,--// FISH_LINGDANGYU,
    35,--// FISH_JIANYU,
    30,--// FISH_MOGUIYU,
    30,--// FISH_FEIYU,
    30,--// FISH_LONGXIA,
    25,--// FISH_HAITUN,
    25,--// FISH_DAZHADAN,
    25,--// FISH_FROZEN,
    30,--// FISH_ZHENZHUBEI,
    30,--// FISH_XIAOFEIYU,
    50,--// FISH_ALILAN,
    0,--// FISH_ZHADANFISH,
    0,--// FISH_NORMAL_TYPEMAX (NO USE)
    80,--// FISH_XIAOHUANGCI
    80,--// FISH_LANGUANGYU
    60,--// FISH_QICAIYU
    50,--// FISH_YINGWULUO
    50,--// FISH_TIAOWENYU
    40,--// FISH_GANGKUIYU
    0,--// FISH_HAIGUAI
    0--// FISH_HGZHADAN
};

local FishType = {
	FISH_XIAOGUANGYU=1,
	FISH_XIAOCAOYU=2,
	FISH_REDAIYU=3,
	FISH_DAYANJINYU=4,
	FISH_SHUIMU=5,
	FISH_SHANWEIYU=6,
	FISH_REDAIZIYU=7,
	FISH_XIAOCHOUYU=8,
	FISH_HETUN=9,
	FISH_WUZEI=10,
	FISH_SHITOUYU=11,
	FISH_SHENXIANYU=12,
	FISH_WUGUI=13,
	FISH_DENGLONGYU=14,
	FISH_SHIBANYU=15,
	FISH_HUDIEYU=16,
	FISH_LINGDANGYU=17,
	FISH_JIANYU=18,
	FISH_MOGUIYU=19,
	FISH_FEIYU=20,
	FISH_LONGXIA=21,
	FISH_ZHADAN=22,
	FISH_DAZHADAN=23,
	FISH_FROZEN=24,
	FISH_ZHENZHUBEI=25,
	FISH_XIAOFEIYU=26,
	FISH_ALILAN=27,
	FISH_ZHADANFISH=28,
	FISH_NORMAL_TYPEMAX=29,
	FISH_XIAOHUANGCI=30,
	FISH_LANGUANGYU=31,
	FISH_QICAIYU=32,
	FISH_YINGWULUO=33,
	FISH_TIAOWENYU=34,
	FISH_GANGKUIYU=35,
	FISH_HAIGUAI=36,
	FISH_HGZHADAN=37,
	FISH_All_TYPEMAX=38
};

local SpecialAttr = {
	SPEC_HLYQ=1,
	SPEC_HYLL=2,
	SPEC_TLYQ=3,
	SPEC_DASIXI=4,
	SPEC_ZDYQ=5,
	SPEC_YWYQ=6,
	SPEC_NONE=7
};

-- FishManager._fishLockArray={};
-- FishManager._fishRingLockArray={};

local FishManager = require("core.FishManager"):getInstance();
local FishPath = require("core.FishPath"):getInstance();


function Fish:ctor(fishtype)
  -- self.super.ctor(self);
  -- self._fishLockArray={};
  self.isTurning=false;
  self._fishID=-1;
  self._fishType = self:getLocalType(fishtype);
  if self._fishType > newFishMax then
    self._fishType = 1;
  end

  -- self._fishType=18;
  -- if(self._fishType==22 or self._fishType==23 or self._fishType==24)then
  --   self._fishType=25;
    -- print("fishType:22 23 24 pic not have!!!  change fishtype to 25");
  -- end
  -- if(fishtype==0)then
  --   self._fishType=1;
  -- else
  --   self._fishType=fishtype;
  -- end
  self._spec=SpecialAttr.SPEC_NONE;
  self._specSprite=nil;
  self._activeFrameDelay = 0.15;
  self._deadFrameDelay = 0.15;
  self._lastPostion=cc.p(-1,-1);
  self._FlipRotate=0;
  self._flipY=false;
  self._frozenTimer=-1;
  self._isFrozen=false;
  self._testSlowCount=0;
  self._slowTimer=-1;
  -- self._originColor = self.getColor();

  self:reloadFishFrame();
  self:initFishType(type);

  if(self._fishCD ~=0) then
      if(FishManager._fishLockArray[self._fishType] == false)then
          FishManager:lockFish(self._fishType, true);
      end
  end

  --self:setRotation(90);
  self:setNodeEventEnabled(true);
  self.updateFishScheduler = nil;

  self:loadSpecialDeath();
  -- if(self._fishType<=newFishMax)then
  --   self:setFlippedX(true);
  -- end
  self.shadow = display.newSprite();
  self:addChild(self.shadow,-1); 


  -- self:setScale(0.5);
end

function Fish:getLocalType( fishtype )
  -- if true then
  --   -- return math.random(1,5);s
  --   return 21;
  -- end


  if(fishtype == 21)then
    return 24;
  elseif(fishtype == 22)then
    return 22;
  elseif(fishtype == 23)then
    return 23;
  elseif(fishtype == 40)then
    return 21;
  elseif(fishtype == 44)then
    return 25;
  elseif(fishtype == 45)then
    return 26;
  end

  return fishtype+1;
end

function Fish:initFishType( fishtype ) 

  if(self._fishType == FishType.FISH_XIAOGUANGYU) then --1
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._turnFrameCount = 11;
      self._scoreRate = 0.25;
      self._attackRate = 150;
      self._activeFrameDelay = 0.06;
      self._speedTime = 13;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 25;
  elseif(self._fishType == FishType.FISH_XIAOCAOYU) then --2
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._turnFrameCount = 11;
      self._scoreRate = 0.5;
      self._attackRate = 120;
      self._activeFrameDelay = 0.08;
      self._speedTime = 12;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 25;
  elseif(self._fishType == FishType.FISH_REDAIYU) then --3
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._turnFrameCount = 11;
      self._scoreRate = 1;
      self._attackRate = 100;
      self._activeFrameDelay = 0.08;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_DAYANJINYU) then --4
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._turnFrameCount = 11;
      self._scoreRate = 2;
      self._attackRate = 80;
      self._speedTime = 15;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_SHUIMU) then --5
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._turnFrameCount = 11;
      self._scoreRate = 3;
      self._attackRate = 50;
      self._speedTime = 36;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 40;
  elseif(self._fishType == FishType.FISH_SHANWEIYU) then --6
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._turnFrameCount = 11;
      self._scoreRate = 4;
      self._attackRate = 18;
      self._speedTime = 30;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 35;
  elseif(self._fishType == FishType.FISH_REDAIZIYU) then --7
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._turnFrameCount = 11;
      self._scoreRate = 5;
      self._attackRate = 16;
      self._speedTime = 30;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 35;
  elseif(self._fishType == FishType.FISH_XIAOCHOUYU) then --8
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._turnFrameCount = 11;
      self._scoreRate = 6;
      self._attackRate = 14;
      self._activeFrameDelay = 0.1;
      self._speedTime = 30;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 40;
  elseif(self._fishType == FishType.FISH_HETUN) then --9
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._scoreRate = 7;
      self._attackRate = 12;
      self._speedTime = 34;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 50;
      self._collideAreas={};
      table.insert(self._collideAreas,{cc.p(0,22),cc.p(-50,0),cc.p(0,-22),cc.p(50,0)});

  elseif(self._fishType == FishType.FISH_WUZEI) then --10
      self._activeFrameCount = 15;
      self._deadFrameCount = 8;
      self._scoreRate = 8;
      self._attackRate = 12;
      self._speedTime = 44;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 50;
  elseif(self._fishType == FishType.FISH_SHITOUYU) then --11
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._scoreRate = 9;
      self._attackRate = 10;
      self._activeFrameDelay = 0.06;
      self._speedTime = 32;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 35;
  elseif(self._fishType == FishType.FISH_SHENXIANYU) then --12
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._scoreRate = 10;
      self._attackRate = 10;
      self._activeFrameDelay = 0.08;
      self._speedTime = 40;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 40;
  elseif(self._fishType == FishType.FISH_WUGUI) then --13
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._scoreRate = 12;
      self._attackRate = 11;
      self._speedTime = 32;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 55;
  elseif(self._fishType == FishType.FISH_DENGLONGYU) then --14
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._scoreRate = 15;
      self._attackRate = 10;
      self._activeFrameDelay = 0.12;
      self._speedTime = 28;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 65;
  elseif(self._fishType == FishType.FISH_SHIBANYU) then --15
      self._activeFrameCount = 5;
      self._deadFrameCount = 10;
      self._scoreRate = 18;
      self._attackRate = 9;
      self._speedTime = 32;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 112;
      self._collideAreas={};
      table.insert(self._collideAreas,{cc.p(0,38),cc.p(-112,0),cc.p(0,-38),cc.p(112,0)});
  elseif(self._fishType == FishType.FISH_HUDIEYU) then --16
      self._activeFrameCount = 7;
      self._deadFrameCount = 10;
      self._scoreRate = 20;
      self._attackRate = 8;
      self._speedTime = 36;
      self._genCornNum = 22;
      self._fishCD = 0;
      self._radius = 115;
      self._collideAreas={};
      table.insert(self._collideAreas,{cc.p(0,20),cc.p(-115,0),cc.p(0,-20),cc.p(115,0)});
      table.insert(self._collideAreas,{cc.p(55,60),cc.p(0,0),cc.p(55,-60),cc.p(110,0)});

  elseif(self._fishType == FishType.FISH_LINGDANGYU) then --17
      self._activeFrameCount = 7;
      self._deadFrameCount = 10;
      self._scoreRate = 25;
      self._attackRate = 7;
      self._speedTime = 36;
      self._genCornNum = 22;
      self._fishCD = 0;
      self._radius = 115;
      self._collideAreas={};
      table.insert(self._collideAreas,{cc.p(0,20),cc.p(-115,0),cc.p(0,-20),cc.p(115,0)});
      table.insert(self._collideAreas,{cc.p(55,60),cc.p(0,0),cc.p(55,-60),cc.p(110,0)});

  elseif(self._fishType == FishType.FISH_JIANYU) then --18
      self._activeFrameCount = 9;
      self._deadFrameCount = 10;
      self._scoreRate = 30;
      self._attackRate = 6;
      self._speedTime = 60;
      self._genCornNum = 22;
      self._fishCD = 5;
      self._radius = 133;
      self._collideAreas={};
      table.insert(self._collideAreas,{cc.p(0,70),cc.p(-133,0),cc.p(0,-70),cc.p(133,0)});
  elseif(self._fishType == FishType.FISH_MOGUIYU) then --19
      self._activeFrameCount = 9;
      self._deadFrameCount = 10;
      self._scoreRate = 35;
      self._attackRate = 5;
      self._speedTime = 45;
      self._genCornNum = 23;
      self._fishCD = 0;
      self._radius = 75;
  elseif(self._fishType == FishType.FISH_FEIYU) then --20
      self._activeFrameCount = 9;
      self._deadFrameCount = 9;
      self._scoreRate = 40;
      self._attackRate = 4;
      self._activeFrameDelay = 0.1;
      self._speedTime = 60;
      self._genCornNum = 23;
      self._fishCD = 5;
      self._radius = 140;
      self._collideAreas={};
      table.insert(self._collideAreas,{cc.p(40,140),cc.p(0,80),cc.p(40,20),cc.p(80,80)});
      table.insert(self._collideAreas,{cc.p(0,20),cc.p(-70,-30),cc.p(0,-80),cc.p(70,-30)});
  elseif(self._fishType == FishType.FISH_LONGXIA) then --21
      self._activeFrameCount = 7;
      self._deadFrameCount = 10;
      self._scoreRate = 50;
      self._attackRate = 3;
      self._activeFrameDelay = 0.1;
      self._speedTime = 44;
      self._genCornNum = 23;
      self._fishCD = 5;
      self._radius = 150;
      self._collideAreas={};
      table.insert(self._collideAreas,{cc.p(0,45),cc.p(-150,0),cc.p(0,-45),cc.p(150,0)});
  elseif(self._fishType == FishType.FISH_ZHADAN) then --22
      self._activeFrameCount = 8;
      self._deadFrameCount = 0;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
  elseif(self._fishType == FishType.FISH_DAZHADAN) then --23
      self._activeFrameCount = 8;
      self._deadFrameCount = 0;
      self._scoreRate = 80;
      self._attackRate = 2;
      self._speedTime = 44;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 75;
  elseif(self._fishType == FishType.FISH_FROZEN) then --24
      self._activeFrameCount = 7;
      self._deadFrameCount = 0;
      self._scoreRate = 100;
      self._attackRate = 2;
      self._activeFrameDelay = 0.2;
      self._speedTime = 44;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 55;
  elseif(self._fishType == FishType.FISH_ZHENZHUBEI) then --25
      self._activeFrameCount = 10;
      self._deadFrameCount = 12;
      self._scoreRate = 10;
      self._attackRate = 12;
      self._speedTime = 60;
      self._genCornNum = 1;
      self._fishCD = 30;
      self._radius = 35;
  elseif(self._fishType == FishType.FISH_XIAOFEIYU) then --26
      self._activeFrameCount = 10;
      self._deadFrameCount = 12;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 60;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 70;
  elseif(self._fishType == FishType.FISH_ALILAN) then --27
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 28;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_ZHADANFISH) then --28
      self._activeFrameCount = 5;
      self._deadFrameCount = 6;
      self._scoreRate = 0;
      self._attackRate = 2;
      self._speedTime = 44;
      self._genCornNum = 0;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_XIAOHUANGCI) then --29
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 14;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_LANGUANGYU) then --30
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 14;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_QICAIYU) then --
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 14;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_YINGWULUO) then -- 
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 14;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_TIAOWENYU) then --
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 14;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_GANGKUIYU) then --
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 14;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_HAIGUAI) then --
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 14;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_HGZHADAN) then --
      self._activeFrameCount = 7;
      self._deadFrameCount = 3;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 14;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  -- elseif(self._fishType == FishType.FISH_NORMAL_TYPEMAX) then
  
  -- elseif(self._fishType == FishType.FISH_All_TYPEMAX) then
  
  else
      print("------------未定义的鱼的类型------", self._fishType)


      self._fishType = FishType.FISH_XIAOGUANGYU;
      self._activeFrameCount = 10;
      self._deadFrameCount = 10;
      self._scoreRate = 0.25;
      self._attackRate = 150;
      self._activeFrameDelay = 0.06;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 15;
  end

end

function Fish:drawCollideAreas()
    -- 只是用来测试碰撞的区域标示用
    if self._collideAreas ~= nil then

        for i,v in ipairs(self._collideAreas) do

            for j,w in ipairs(v) do

                local pos = display.newTTFLabel({text = "("..w.x..","..w.y..")",
                                                size = 12,
                                                color = cc.c3b(255,255-(i-1)*255,255-(i-1)*255),
                                                font = FONT_PTY_TEXT,
                                                align = cc.ui.TEXT_ALIGN_CENTER });
                pos:setPosition(cc.p(self:getContentSize().width/2+w.x,self:getContentSize().height/2+w.y));
                self:addChild(pos);
            end
        end   
    end   
end

function Fish:onEnter()

  -- local prefix = FishManager:getFishFilePrefix(self._fishType);
  -- local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
  -- for i=1,self._activeFrameCount do
  --     local frame = sharedSpriteFrameCache:getSpriteFrame((prefix.."-yd-"..i..".png"));  
  --     frame:retain();
  -- end

  -- if self._turnFrameCount ~=nil and self._turnFrameCount ~= 0 then
  --   for i=1,self._turnFrameCount do
  --       local frame = sharedSpriteFrameCache:getSpriteFrame((prefix.."-fs-"..i..".png"));  
  --       frame:retain();
  --   end
  -- end

  -- for i=1,self._deadFrameCount do
  --     local frame = sharedSpriteFrameCache:getSpriteFrame((prefix.."-sw-"..i..".png"));  
  --     frame:retain();
  -- end

end

function Fish:onExit()
  if (self.updateFishScheduler ~= nil) then
    scheduler.unscheduleGlobal(self.updateFishScheduler);
  end

  -- local prefix = FishManager:getFishFilePrefix(self._fishType);
  -- local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
  -- for i=1,self._activeFrameCount do
  --     local frame = sharedSpriteFrameCache:getSpriteFrame((prefix.."-yd-"..i..".png"));  
  --     frame:release();
  -- end

  -- if self._turnFrameCount ~=nil and self._turnFrameCount ~= 0 then
  --   for i=1,self._turnFrameCount do
  --       local frame = sharedSpriteFrameCache:getSpriteFrame((prefix.."-fs-"..i..".png"));  
  --       frame:release();
  --   end
  -- end

  -- for i=1,self._deadFrameCount do
  --     local frame = sharedSpriteFrameCache:getSpriteFrame((prefix.."-sw-"..i..".png"));  
  --     frame:release();
  -- end

end

function Fish:reloadFishFrame()

  -- remember update fish plist
  local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
  local fishType = self._fishType;

  if fishType < 10 then
    sharedSpriteFrameCache:addSpriteFrames("fish/fish1.plist");
  end
  
  if fishType >= 10 and fishType <= 15 then
    sharedSpriteFrameCache:addSpriteFrames("fish/fish2.plist");
  end

  if fishType >= 15 and fishType <= 17 then
    sharedSpriteFrameCache:addSpriteFrames("fish/fish3.plist");
  end

  if fishType >= 17 and fishType <= 18 then
    sharedSpriteFrameCache:addSpriteFrames("fish/fish4.plist");
  end

  if fishType >= 18 and fishType <= 19 then
    sharedSpriteFrameCache:addSpriteFrames("fish/fish5.plist");
  end

  if fishType >= 19 and fishType <= 20 then
    sharedSpriteFrameCache:addSpriteFrames("fish/fish6.plist");
  end

  if fishType >= 21 and fishType <= 24 then
    sharedSpriteFrameCache:addSpriteFrames("fish/fish7.plist");
  end

  if fishType >= 25 and fishType <= 26 then
    sharedSpriteFrameCache:addSpriteFrames("fish/fish8.plist");
  end

end


function Fish:generateFishPath(path, groupIndex, topFish)
  if(groupIndex==nil)then
    groupIndex=0
  end
  FishPath:createFishPath(self, path, groupIndex, topFish);
end

function Fish:followFishPath(path, groupIndex, topFish)
  FishPath:createFollowPath(self, path, groupIndex, topFish);
end

function Fish:generateFrameAnimation()

  self:reloadFishFrame();
  local frames=nil;
  frames = display.newFrames((FishManager:getFishFilePrefix(self._fishType).."-yd-%d.png"), 1, self._activeFrameCount);
  -- if self._fishType == 1 then
    -- local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    -- sharedSpriteFrameCache:addSpriteFrames("new/fish1.plist");
    -- frames = display.newFrames("fish1-yd".."-%d.png", 1, 10);
  -- end

  self._activeFrameAnimation = display.newAnimation(frames, self._activeFrameDelay)

  -- local deadframes;
  -- if(self._fishType == FishType.FISH_HGZHADAN)then
  --   deadframes = display.newFrames((FishManager:getFishFilePrefix(FishType.FISH_ZHADANFISH).."_d%d.png"), 0, self._deadFrameCount);
  -- else
  --   deadframes = display.newFrames((FishManager:getFishFilePrefix(self._fishType).."_d%d.png"), 0, self._deadFrameCount);
  -- end
  -- self._deadFrameAnimation = display.newAnimation(deadframes, self._deadFrameDelay);
  -- if(deadframes==nil)then
  --   print("deadframes == nil deadframes == nil deadframes == nil")
  -- end
  -- if(self._deadFrameAnimation == nil )then
  --   print("_deadFrameAnimation == nil _deadFrameAnimation == nil _deadFrameAnimation == nil")
  -- end



  self:setSpriteFrame(frames[1]);
  self:setAnchorPoint(cc.p(0.5,0.5));


  -- local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
  -- local filename = (FishManager:getFishFilePrefix(self._fishType).."-yd-1.png");
  -- -- filename = "fish18-yd-1.png";
  -- print(filename);
  -- local pFrame = sharedSpriteFrameCache:getSpriteFrame(filename);
  -- print(pFrame,tostring(pFrame));
  -- local shadow = cc.Sprite:createWithSpriteFrame(pFrame);
  -- shadow:setPosition(cc.p(20,20));
  -- shadow:setColor(cc.c3b(0,0,0));
  -- -- shadow:setRotation(180)
  -- shadow:setLocalZOrder(-1);
  -- self:addChild(shadow);
  -- self.shadow = shadow;

  -- self:drawCollideAreas();--标示碰撞区域
end

function Fish:turnAnimation()
  -- print("turnAnimation start~~~~~~~~~~~~~")

  -- self:stopAllActions();
  -- self.shadow:stopAllActions();
  
  self:getTurnAnimate();
  if(self._turnAnimation ~= nil and self.aimateSpeed and self.shadowSpeed)then
    local animate= cc.Animate:create(self._turnAnimation); 
    -- self.shadow:stopAction(self.shadow:getChildByTag(99));
    self.shadowSpeed:setSpeed(0);
    self.shadow:runAction(animate);
    
    local callFunc = cc.CallFunc:create(function () self:fishTurnedCBK(); end) ;
    self:getTurnAnimate();
    local animate2= cc.Animate:create(self._turnAnimation);
    -- self:stopAction(self:getChildByTag(99));
    self.aimateSpeed:setSpeed(0);
    self:runAction(cc.Sequence:create(animate2,callFunc));

    -- self.shadow:stopAction(self.shadow:getChildByTag(99));
    -- self.shadow:runAction(animate);
    
    self.isTurning=true;
  else
    self:fishTurnedCBK();
  end

end  

function Fish:getTurnAnimate()

    if(self._turnFrameCount ~=nil and self._turnFrameCount ~= 0)then
        self:reloadFishFrame();
        local frames=nil;
        frames = display.newFrames((FishManager:getFishFilePrefix(self._fishType).."-fs-%d.png"), 1, self._turnFrameCount)
        self._turnAnimation = display.newAnimation(frames,0.05);
    end
end

function Fish:fishTurnedCBK()
      if self._flipY then
            self:setFlipRotate( false );
            self:setFlipScreen(FLIP_FISH);
      else
            self:setFlipRotate( true );
            self:setFlipScreen(FLIP_FISH);
      end


      local currentX,currentY=self:getPosition();
      local angle = math.atan2((currentY-self._lastPostion.y),(currentX-self._lastPostion.x));
      local rot=0 - (angle * 360)/(2*math.pi)+self._FlipRotate;
      self:setRotation(rot);
      self:shadowPos(rot);
      self.isTurning=false;

      self:generateFrameAnimation();
      -- local animate2= cc.Animate:create(self._activeFrameAnimation);
      -- self.shadow:runAction(cc.Repeat:create(animate2,100));
      if self.aimateSpeed and self.shadowSpeed then
        self.aimateSpeed:setSpeed(self.pathSpeed:getSpeed());
        self.shadowSpeed:setSpeed(self.pathSpeed:getSpeed());
      end
end


function Fish:setSpec(spec)
    local pstr=nil;
    if(spec==SpecialAttr.SPEC_DASIXI)then
        pstr = "dasixi.png";
        
    elseif(spec==SpecialAttr.SPEC_HLYQ)then
        pstr = "hlyq.png";
        
    elseif(spec==SpecialAttr.SPEC_TLYQ)then
        pstr = "tlyq.png";
        
    elseif(spec==SpecialAttr.SPEC_HYLL)then
        pstr = "hyll.png";
        
    elseif(spec==SpecialAttr.SPEC_ZDYQ)then
        pstr = "zdyq.png";
        
    elseif(spec==SpecialAttr.SPEC_YWYQ)then
        pstr = "bjyq.png";
    end
    
    if(pstr)then
        self._spec = spec;
        self._specSprite = cc.Sprite:create(pstr);
        self:addChild(self._specSprite,-1);
        local a = self:getContentSize();
        local b = self._specSprite:getContentSize();

        self._specSprite:setPosition(ccp(a.width/2,a.height/2));
        self._specSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.0, 150)));
        local lbRepeate2 = cc.RepeatForever:create(cc.Sequence:create(updown2,updown2:reverse()))
        
    end

end

function Fish:goFish()
    local fishaction = nil;
    local animate= cc.Animate:create(self._activeFrameAnimation);
    local mainAction;
    local pathAction;
    
    local callFunc = cc.CallFunc:create(function () self:fishStopCBK(); end) ;
    if(self._fishPath ~= NULL) then
        table.insert(self._fishPath,callFunc);
         pathAction=self._fishPath[1];
        for i=2,#self._fishPath do
          pathAction=cc.Sequence:create(pathAction,self._fishPath[i]);
        end
        mainAction = cc.Repeat:create(animate,100);
        mainAction:setTag(99);
        fishaction = cc.Spawn:create(mainAction,pathAction);
        table.remove(self._fishPath);

        local speed = cc.Speed:create(pathAction, 1);
        self:runAction(speed);
        self.pathSpeed=speed;
    else
        -- fishaction = cc.Sequence:create(cc.Repeat:create(animate,100),callFunc);
        mainAction = cc.Sequence:create(cc.Repeat:create(animate,100),callFunc);
    end

    -- self:runAction(mainAction);



    local aimateSpeed = cc.Speed:create(mainAction, 1);
    self:runAction(aimateSpeed);
    self.aimateSpeed=aimateSpeed;

    local animate2= cc.Animate:create(self._activeFrameAnimation);
    local shadowMainAction=cc.Repeat:create(animate2,100);
    shadowMainAction:setTag(99);

    local shadowSpeed = cc.Speed:create(shadowMainAction, 1);
    self.shadowSpeed=shadowSpeed;
    self.shadow:runAction(shadowSpeed);
    self.shadow:setColor(cc.c3b(10,10,10));
    self.shadow:setOpacity(128);


    self._lastPostion=cc.p(self:getPositionX(),self:getPositionY());

    -- self._lastPostion=cc.p(self:getPosition().x,self:getPosition().y);

    local scheduler = require("framework.scheduler");
    self.updateFishScheduler = scheduler.scheduleGlobal(function()
        self:update()
    end, 0.1)

    self.originColor = self:getColor();

end

function Fish:fishStopCBK()
  
    if(FishManager._fishLockArray[self._fishType] == true)then
      self:setVisible(false);
      local callFunc = cc.CallFunc:create(function () self:unLockAndRelease(); end) ;
      self:runAction(cc.Sequence:create(cc.DelayTime:create(self._fishCD),callFunc));
    else
      self._parent.fishData[self._fishID] = nil;
      local scheduler = require("framework.scheduler");
      self:removeSelf();
    end

end

function Fish:unLockAndRelease()
  FishManager:lockFish(self._fishType,false);
  self._parent.fishData[self._fishID] = nil
  local scheduler = require("framework.scheduler");
  self:removeSelf();
end

function Fish:isFishValid()
  return self:isFishAlive() and self:isFishInScreen();
end

function Fish:isFishAlive()
  if self.isKilled then
    return false;
  end
  return true;
end

function Fish:isFishInScreen()
  local winSize = cc.Director:getInstance():getWinSize();
  local screenRect = cc.rect(0,0,winSize.width,winSize.height);
  -- local fishRect = self:getBoundingBox();
  -- if cc.rectIntersectsRect(screenRect, fishRect) then
  --   return true;
  -- end
  -- return false;

  if self:getPositionX() >= 0 and self:getPositionX() <= winSize.width then
    if self:getPositionY() >= 0 and self:getPositionY() <= winSize.height then
      return true;
    end
  end
  return false;

end

function Fish:killFish()
  if (self.updateFishScheduler ~= nil) then
    scheduler.unscheduleGlobal(self.updateFishScheduler);
  end
  self:stopAllActions();
  self.shadow:stopAllActions();
  self.isKilled = true;
  self:setColor(self.originColor);
  if self:checkIsLiQuan() then
    self:performWithDelay(
      function()
        local particlePlist = nil
        if self._fishType==FishType.FISH_ZHENZHUBEI then
          particlePlist="fishEffect/lizi_liquan.plist";
        else
          particlePlist="fishEffect/lizi_liquand.plist";
        end
        local particle = cc.ParticleSystemQuad:create(particlePlist)
        particle:setPosition(self:getCenter())
        self:addChild(particle)
      end,
      1.35
    )
  elseif self:checkIsBigFish() then

    --打中大鱼金币暴烈粒子特效
  
    local particle = cc.ParticleSystemQuad:create("effect/coin_bao_zha/lizi_jb_baozha.plist")
    particle:setPosition(self:getCenter())
    self:addChild(particle)
         

    
    --死忙爆炸
    local deadAni = self:getBigFishDeadAnimation()
    if deadAni then
        deadAni:setPosition(self:getCenter())
        self:addChild(deadAni)
        deadAni:getAnimation():playWithIndex(0)
    end

    self:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.1, 1.5)
            -- cc.RotateBy:create(1.0, 900)
        ))

    self:performWithDelay(
      function()
        particle:removeFromParent()
        deadAni:removeFromParent()
        --鱼死亡动作
        self:runAction(cc.Sequence:create(
                -- cc.DelayTime:create(0.1),
                cc.RotateBy:create(1.0, 900)
            ))
        --死亡坠落的动作
        self:runAction(cc.Sequence:create(
                -- cc.DelayTime:create(0.1),
                cc.ScaleTo:create(1.0, 0.6)
            ))
      end,
      0.44
    )
  end

  self:runSpecialDeath();
  self._parent.fishData[self._fishID] = nil;

  if(self._deadFrameCount==0)then
    local func = cc.CallFunc:create(function () self:fishDeadCBK(); end) ;
    local action = cc.DelayTime:create(0.5);
    self:runAction(cc.Sequence:create(action,func));
    return
  end

  self:reloadFishFrame();
  local deadframes;
  deadframes = display.newFrames((FishManager:getFishFilePrefix(self._fishType).."-sw-%d.png"), 1, self._deadFrameCount)

  self._deadFrameAnimation = display.newAnimation(deadframes, self._deadFrameDelay);
  local animate= cc.Animate:create(self._deadFrameAnimation);
  -- local animate= cc.Animate:create(self._activeFrameAnimation);
  local callFunc = cc.CallFunc:create(function () self:fishDeadCBK(); end) ;
  self:runAction(cc.Sequence:create(animate,callFunc));

  local animate2= cc.Animate:create(self._deadFrameAnimation);
  self.shadow:runAction(animate2);

  self:playDeadSound()
end

function Fish:fishDeadCBK()
  FishManager:lockFish(self._fishType,false);
  -- self._parent.fishData[self._fishID] = nil;
  local scheduler = require("framework.scheduler");
  
  self:removeSelf();
end

function Fish:setFishID( fishID)
  self._fishID=fishID ;

  -- local id=tostring(fishID);
  -- local text = ccui.Text:create(id,"launcher/font.TTF", 24);
  -- text:setColor(cc.c3b(255,0,0));
  -- text:setPosition(cc.p(self:getContentSize().height/2, self:getContentSize().width/2));
  -- text:setRotation(-90);
  -- self:addChild(text);
end

function Fish:getFishID()
  if(self._fishID<0)then
    print("warning!  fishID <0  ")
  end
  return self._fishID;
end

function Fish:shadowPos( rot )
  self.shadow:setPosition(cc.p(self:getContentSize().width/2-10*math.cos(math.rad(rot))+10*math.sin(math.rad(rot)),self:getContentSize().height/2-10*math.sin(math.rad(rot))-10*math.cos(math.rad(rot))));
end

function Fish:update(dt)
    local currentX,currentY=self:getPosition();

    if(self._lastPostion.x~=currentX or self._lastPostion.y~=currentY)then
      if(self.isTurning==false)then
        if self._flipY then
            if(self._lastPostion.x<currentX)then
                self:turnAnimation();
            end
        else
            if(self._lastPostion.x>currentX)then
                self:turnAnimation();
            end
        end
      end
        local angle = math.atan2((currentY-self._lastPostion.y),(currentX-self._lastPostion.x));
        local rot=0 - (angle * 360)/(2*math.pi)+self._FlipRotate;
        self:setRotation(rot);
        self:shadowPos(rot);

        self._lastPostion=cc.p(currentX,currentY);

    end

    if self.inAttackTime then
      self:setColor(cc.c3b(240,150,140));
      self.inAttackTime = self.inAttackTime - 1;
      if self.inAttackTime <= 0 then
        self.inAttackTime = nil;
      end
      self._testSlowCount=self._testSlowCount+1;
      -- if(self._testSlowCount%2==1)then
      --     cc.Director:getInstance():getActionManager():pauseTarget(self);
      --     cc.Director:getInstance():getActionManager():pauseTarget(self.shadow);
      -- else
      --     cc.Director:getInstance():getActionManager():resumeTarget(self);
      --     cc.Director:getInstance():getActionManager():resumeTarget(self.shadow);
      -- end
      -- if(self.speed)then
      --   self.speed:setSpeed(0.1);
      -- end
    elseif(self._isFrozen or self._isSlow)then
      self:setColor(cc.c3b(120,120,225));
    else
      self:setColor(self.originColor);

      -- cc.Director:getInstance():getActionManager():resumeTarget(self);
      -- cc.Director:getInstance():getActionManager():resumeTarget(self.shadow);
      -- if(self.speed)then
      --   self.speed:setSpeed(1);
      -- end
    end

    if(self._frozenTimer~=-1)then
      if(self._frozenTimer<os.time())then
        self._frozenTimer=-1;
        self:resumeFrozen();
      end
    end

    if(self._slowTimer~=-1)then
      if(self._slowTimer<os.time())then
        self._slowTimer=-1;
        self.pathSpeed:setSpeed(1);
        self.aimateSpeed:setSpeed(1);
        self.shadowSpeed:setSpeed(1);
        self:setColor(self.originColor);
        self._isSlow=false;
      end
    end

end

function Fish:setFlipRotate( flipY )
  if(flipY)then

    self:setFlippedX(true);
    self:setFlippedY(true);
    self.shadow:setFlippedX(true);
    -- self.shadow:setFlippedY(true);
    self._FlipRotate=180;

    self._flipY=true;
  else
    if(self._fishType>newFishMax)then
      self:setFlippedY(false);
      self.shadow:setFlippedY(false);
      self._FlipRotate=0;
    else
      self:setFlippedX(false);
      self:setFlippedY(false);
      self.shadow:setFlippedX(false);
      -- self.shadow:setFlippedY(false);
      self._FlipRotate=0;
    end
    self._flipY=false;
  end

end

function Fish:getCenter()

  local center = cc.p(self:getContentSize().width/2,self:getContentSize().height/2);
  -- if self._fishType == 13 then
  --   if FLIP_FISH then
  --     center.y = center.y + 35;
  --   else
  --     center.y = center.y - 35;
  --   end
  -- end
  -- if self._fishType == 16 or self._fishType == 17 then
  --   if self._FlipRotate == 180 then
  --     center.x = center.x - 50;
  --   else
  --     center.x = center.x + 50;
  --   end
  --   if FLIP_FISH then
  --     center.y = center.y + 25;
  --   else
  --     center.y = center.y - 25;
  --   end
  -- end
  return center;

end

function Fish:setInAttack(bullet, isAttackSlow)
  
  -- 增加大鱼被打中特效
  if self:checkIsBigFish() then
      local hitAni = self:getHitBigFishAnimation()
      if hitAni then
          hitAni:setPosition(self:getCenter())
          self:addChild(hitAni)
          hitAni:getAnimation():playWithIndex(0)
      end
  else
      self.inAttackTime = 2;--0.2s
  end

  if(bullet.bSetLockFishSlow and self.pathSpeed)then
    -- self._slowTimer=os.time()+3;
    self.pathSpeed:setSpeed(0.5);
    self.aimateSpeed:setSpeed(0.5);
    self.shadowSpeed:setSpeed(0.5);
    self:setColor(cc.c3b(120,120,225));
    self._isSlow=true;
  end

  -- self:playInAttackSound()

end

function Fish:focus(bFocus)

  -- if self.focusSprite == nil and bFocus then
  --   local focusSprite = display.newSprite("game/focus.png");
  --   focusSprite:setPosition(self:getCenter());
  --   self:addChild(focusSprite);
  --   self.focusSprite = focusSprite;
  -- end
  -- if self.focusSprite then
  --   self.focusSprite:setVisible(bFocus);
  -- end
end

function Fish:frozen( delay )
  if(delay)then
    self._frozenTimer=os.time()+delay;
  end
  cc.Director:getInstance():getActionManager():pauseTarget(self);
  cc.Director:getInstance():getActionManager():pauseTarget(self.shadow);
  self:setColor(cc.c3b(120,120,225));
  self._isFrozen=true;
end

function Fish:resumeFrozen()
  cc.Director:getInstance():getActionManager():resumeTarget(self);
  cc.Director:getInstance():getActionManager():resumeTarget(self.shadow);
  self:setColor(self.originColor);
  self._isFrozen=false;
end

--获取碰撞区域大小
function Fish:getCollisionRect()
    local rect = {}
    rect.x, rect.y = self:getPosition()
    rect.width = 50
    rect.height = 50
    return rect
end

function Fish:loadSpecialDeath()
  local manager = ccs.ArmatureDataManager:getInstance();
  if(self._fishType == FishType.FISH_ZHADAN)then
    if manager:getAnimationData("eff_baozha") == nil then
        -- manager:addArmatureFileInfo("fishEffect/eff_dabaozha.ExportJson");
        manager:addArmatureFileInfo("fishEffect/eff_baozha0.png","fishEffect/eff_baozha0.plist","fishEffect/eff_baozha.ExportJson");
    end
    self.specDeath = ccs.Armature:create("eff_baozha");
  elseif(self._fishType == FishType.FISH_DAZHADAN)then
    if manager:getAnimationData("eff_dabaozha") == nil then
        manager:addArmatureFileInfo("fishEffect/eff_dabaozha0.png","fishEffect/eff_dabaozha0.plist","fishEffect/eff_dabaozha.ExportJson");
        
    end
    self.specDeath = ccs.Armature:create("eff_dabaozha");
  elseif(self._fishType == FishType.FISH_FROZEN)then  
    if manager:getAnimationData("eff_dingping") == nil then
        manager:addArmatureFileInfo("fishEffect/eff_dingping0.png","fishEffect/eff_dingping0.plist","fishEffect/eff_dingping.ExportJson");
    end
    self.specDeath = ccs.Armature:create("eff_dingping");
  end
  if(self.specDeath~=nil)then
    self.specDeath:setPosition(cc.p(0,0));    
    self.specDeath:setVisible(false);
    self:addChild(self.specDeath,2);
  end
end

function Fish:runSpecialDeath()
  self:loadSpecialDeath();
  if(self.specDeath~=nil)then
    self.specDeath:setVisible(true);
    self.specDeath:getAnimation():playWithIndex(0);
  end
end

--大鱼被打中特效
function Fish:getHitBigFishAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("eff_hit_dayu") == nil then
        manager:addArmatureFileInfo("effect/attack_big_fish/eff_hit_dayu0.png","effect/attack_big_fish/eff_hit_dayu0.plist","effect/attack_big_fish/eff_hit_dayu.ExportJson")
    end
    local armature = ccs.Armature:create("eff_hit_dayu")
    return armature;
end

--大鱼死亡动画
function Fish:getBigFishDeadAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("eff_die_baozha") == nil then
        manager:addArmatureFileInfo("effect/dead_big_fish/eff_die_baozha0.png","effect/dead_big_fish/eff_die_baozha0.plist","effect/dead_big_fish/eff_die_baozha.ExportJson")
    end
    local armature = ccs.Armature:create("eff_die_baozha")
    return armature;
end

function Fish:quickGoOut()
  self:stopAllActions();

  if(self._isFrozen)then
    self:resumeFrozen();
  end

  if(self._isSlow)then
    self._isSlow=false;
    self._slowTimer=-1;
  end

  local fishaction = nil;
  self:generateFrameAnimation();
  local animate= cc.Animate:create(self._activeFrameAnimation);
    
  local callFunc = cc.CallFunc:create(function () self:fishStopCBK(); end) ;

  local winSize = cc.Director:getInstance():getWinSize();

  local self_x,self_y=self:getPosition();

  local end_Y=-20;
  if(self_y>winSize.height-self_y)then
    end_Y=winSize.height+20;
  end
  local end_X=self_x+math.random(0,800)-400;

  local result_X=(end_X-self_x)/3+self_x;
  local result_Y=(end_Y-self_y)/3+self_y;

  local bezier ={
        cc.p(result_X,result_Y),
        cc.p(result_X,result_Y),
        cc.p(end_X, end_Y)
    };

  -- print("self_x : ",self_x," self_y : ",self_y," result_X : ",result_X," result_Y : ",result_Y," end_X : ",end_X," end_Y : ",end_Y);

  local bezierTo = cc.BezierTo:create(0.8, bezier);
  local fadeOut =  cc.FadeOut:create(0.8);
  local getOutAction=cc.Sequence:create(cc.Spawn:create(fadeOut,bezierTo),callFunc);
  fishaction = cc.Spawn:create(cc.Repeat:create(animate,100),getOutAction);
  self:runAction(fishaction);

  self.pathSpeed = nil;
  self.aimateSpeed = nil;
end

function Fish:setFlipScreen( isflip )

    self:setFlippedY(isflip);
    self.shadow:setFlippedY(isflip);

  if(isflip)then
    self.shadow:setPosition(cc.p(self:getContentSize().width/2+10,self:getContentSize().height/2+10));
  else
    self.shadow:setPosition(cc.p(self:getContentSize().width/2-10,self:getContentSize().height/2-10));
  end
end

function Fish:checkIsBigFish()
  if(self._fishType>=FishType.FISH_SHIBANYU 
    and self._fishType ~= FishType.FISH_ZHADAN
    and self._fishType ~= FishType.FISH_DAZHADAN
    and self._fishType ~= FishType.FISH_FROZEN)
  then
    return true
  end

  return false;
end

function Fish:checkIsLiQuan()--是否是礼券鱼
  if(self._fishType == FishType.FISH_ZHENZHUBEI
    or self._fishType == FishType.FISH_XIAOFEIYU)
  then
    return true
  end

  return false;
end

--设置某个鱼的速度
function Fish:setFishSpeed(speed)
    if self.pathSpeed then
        self.pathSpeed:setSpeed(speed);
        self.aimateSpeed:setSpeed(speed);
    end
end

function Fish:playInAttackSound()
    local time = 0
    if self._fishType == 5 then
        time = 1
    elseif self._fishType == 6 then
        time = 2
    elseif self._fishType == 7 then
        time = 2
    elseif self._fishType == 8 then
        time = 2
    elseif self._fishType == 10 then
        time = 4
    elseif self._fishType == 11 then
        time = 2
    elseif self._fishType == 12 then
        time = 3
    elseif self._fishType == 13 then
        time = 2
    elseif self._fishType == 14 then
        time = 4
    elseif self._fishType == 15 then
        time = 3
    elseif self._fishType == 17 then
        time = 3
    elseif self._fishType == 18 then
        time = 2
    elseif self._fishType == 19 then
        time = 4
    end

    local filePath = "sound/fish_hit_"..self._fishType..".mp3"
    if self._fishType >= 5 and self._fishType <= 19 and cc.FileUtils:getInstance():isFileExist(filePath) and 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
        if Is_Playing_Sound then
        else
            Is_Playing_Sound = true
            audio.playSound(filePath)
            self:performWithDelay(function() Is_Playing_Sound = false; end, time)
        end
    end
end

function Fish:playDeadSound()
    if self._fishType == 5 then
        time = 2
    elseif self._fishType == 6 then
        time = 2
    elseif self._fishType == 7 then
        time = 2
    elseif self._fishType == 8 then
        time = 2
    elseif self._fishType == 10 then
        time = 4
    elseif self._fishType == 11 then
        time = 1
    elseif self._fishType == 12 then
        time = 2
    elseif self._fishType == 13 then
        time = 1
    elseif self._fishType == 14 then
        time = 3
    elseif self._fishType == 15 then
        time = 2
    elseif self._fishType == 17 then
        time = 4
    elseif self._fishType == 18 then
        time = 4
    elseif self._fishType == 19 then
        time = 2
    end
    local filePath = "sound/fish_hit_miss_"..self._fishType..".mp3"
    if self._fishType >= 5 and self._fishType <= 19 and cc.FileUtils:getInstance():isFileExist(filePath) and 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
        if Is_Playing_Sound then
        else
            Is_Playing_Sound = true
            audio.playSound(filePath)
            self:performWithDelay(function() Is_Playing_Sound = false; end, time)
        end        
    end
end

function Fish:checkCollide( target_pos , net_Ratius)
  local t_x = target_pos.x - self:getPositionX();
  local t_y = target_pos.y - self:getPositionY();

  if (t_x*t_x + t_y*t_y > self._radius*self._radius + net_Ratius*net_Ratius) then
    return false
  end

  if self._collideAreas == nil then
    return true;
  else
    return self:checkCollideAreas( target_pos , net_Ratius)
  end
end

function Fish:checkCollideAreas( target_pos, net_Ratius)
    local Xt=target_pos.x - self:getPositionX();
    local Yt=target_pos.y - self:getPositionY();
    local rot=math.rad(self:getRotation());
    local sinRot=math.sin(rot);
    local cosRot=math.cos(rot);
    local turn_X = 1;
    if self._flipY then
        turn_X=-1;
    end

    for i,v in ipairs(self._collideAreas) do
        local Xa=v[1].x*cosRot*turn_X + v[1].y*sinRot;
        local Ya=v[1].y*cosRot - v[1].x*sinRot*turn_X;
        local Xb=v[2].x*cosRot*turn_X + v[2].y*sinRot;
        local Yb=v[2].y*cosRot - v[2].x*sinRot*turn_X;
        local Xc=v[3].x*cosRot*turn_X + v[3].y*sinRot;
        local Yc=v[3].y*cosRot - v[3].x*sinRot*turn_X;
        local Xd=v[4].x*cosRot*turn_X + v[4].y*sinRot;
        local Yd=v[4].y*cosRot - v[4].x*sinRot*turn_X;

        local x0=(Xa+Xc)/2;
        local y0=(Ya+Yc)/2;

        local midPoints1={cc.p(Xa,Ya),cc.p(Xc,Yc)};
        local midPoints2={cc.p(Xb,Yb),cc.p(Xd,Yd)};
        table.sort( midPoints1, function(a, b) return (a.x - Xt) * (a.x - Xt) + (a.y - Yt) * (a.y - Yt) < (b.x - Xt) * (b.x - Xt) + (b.y - Yt) * (b.y - Yt) end )
        table.sort( midPoints2, function(a, b) return (a.x - Xt) * (a.x - Xt) + (a.y - Yt) * (a.y - Yt) < (b.x - Xt) * (b.x - Xt) + (b.y - Yt) * (b.y - Yt) end )

        local result=self:IsCircleIntersectRectangle(Xt,Yt,net_Ratius,x0,y0,midPoints1[1].x,midPoints1[1].y,midPoints2[1].x,midPoints2[1].y);
        if result then
            return true;
        end
    end
    return false;
end


-- 计算两点之间的距离
function Fish:DistanceBetweenTwoPoints( x1,  y1,  x2,  y2)
  return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
end

-- 计算点(x, y)到经过两点(x1, y1)和(x2, y2)的直线的距离
function Fish:DistanceFromPointToLine( x, y, x1, y1, x2, y2)
  local a = y2 - y1;
  local b = x1 - x2;
  local c = x2 * y1 - x1 * y2;

  return math.abs(a * x + b * y + c) / math.sqrt(a * a + b * b);
end

-- 圆与矩形碰撞检测
-- 圆心(x, y), 半径r, 矩形中心(x0, y0), 矩形上边中心(x1, y1), 矩形右边中心(x2, y2)
function Fish:IsCircleIntersectRectangle( x, y, r, x0, y0, x1, y1, x2, y2)

  local w1 = self:DistanceBetweenTwoPoints(x0, y0, x2, y2);
  local h1 = self:DistanceBetweenTwoPoints(x0, y0, x1, y1);
  local w2 = self:DistanceFromPointToLine(x, y, x0, y0, x1, y1);
  local h2 = self:DistanceFromPointToLine(x, y, x0, y0, x2, y2);

  if (w2 > w1 + r) then
    return false;
  end
  if (h2 > h1 + r) then
    return false;
  end

  if (w2 <= w1)then
    return true;
  end
  if (h2 <= h1) then
    return true;
  end

  if((w2 - w1) * (w2 - w1) + (h2 - h1) * (h2 - h1) <= r * r)then
    return true;
  end
  return false;
end

function Fish:isFishCanLock()
  if self._fishType < 5 or self._fishType==FishType.FISH_ZHADAN or self._fishType==FishType.FISH_DAZHADAN 
    or self._fishType==FishType.FISH_FROZEN or self._fishType==25 or self._fishType==26 then
    return false
  end
  return true
end


return Fish