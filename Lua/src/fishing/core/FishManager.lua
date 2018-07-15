
local FishManager = class("FishManager")
local _fishManager = nil;
_freshRateArray = {
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
    25,--// FISH_ZHADAN,
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

FishType = {
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

newFishMax=26;

function FishManager:getInstance()
    if _fishManager == nil then
        _fishManager = FishManager.new();
    end
    return _fishManager;
end

function FishManager:ctor()
	self._fishLockArray={};
	self._fishRingLockArray={};
	for i=1,FishType.FISH_All_TYPEMAX do
    	table.insert(self._fishLockArray,false);
  	end
  	for i=1,SpecialAttr.SPEC_NONE do
    	table.insert(self._fishRingLockArray,false);
  	end
end

function FishManager:createSpecFish( parent )
    local specArray = {
        FishType.FISH_REDAIZIYU,
        FishType.FISH_XIAOCHOUYU,
        FishType.FISH_HETUN,
        FishType.FISH_SHITOUYU,
        FishType.FISH_DENGLONGYU,
        FishType.FISH_SHENXIANYU,
        FishType.FISH_WUGUI,
        FishType.FISH_HUDIEYU
    };
    local _r = math.random(1,#specArray);
    local x = specArray[_r];
    -- print("_r ",_r," x ",x," Length ",#specArray);
    local _fish = self:createSpecificFish(parent,specArray[_r],true);

    local n = 0;
    for i=1,#self._fishRingLockArray do	
        if(self._fishRingLockArray[i] == false)then
            n=n+1;
        end
    end
    if(n ~= 0) then
        local t = math.random(0,n);
        local f = 1;
        for i=1,#self._fishRingLockArray do	
            if(self._fishRingLockArray[i]==false)then
              if(t == 0)then
                  break;
              end
              t=t-1;
            end
            f=f+1;
        end
        _fish:setSpec(f);
        
    end

    if(_fish._spec==SpecialAttr.SPEC_HYLL)then
      if(_fish._fishType == FishType.FISH_REDAIZIYU or _fish._fishType == FishType.FISH_XIAOCHOUYU or _fish._fishType == FishType.FISH_HETUN or _fish._fishType == FishType.FISH_SHITOUYU)then
        _fish._attackRate=5;
      elseif(_fish._fishType == FishType.FISH_DENGLONGYU or _fish._fishType == FishType.FISH_SHENXIANYU or _fish._fishType == FishType.FISH_WUGUI or _fish._fishType == FishType.FISH_HUDIEYU)then
        _fish._attackRate=4;
      end
    elseif(_fish._spec==SpecialAttr.SPEC_ZDYQ or _fish._spec==SpecialAttr.SPEC_YWYQ)then
      if(_fish._fishType == FishType.FISH_REDAIZIYU or _fish._fishType == FishType.FISH_XIAOCHOUYU or _fish._fishType == FishType.FISH_HETUN )then
        _fish._attackRate=5;
      elseif(_fish._fishType == FishType.FISH_SHITOUYU or _fish._fishType == FishType.FISH_DENGLONGYU or _fish._fishType == FishType.FISH_SHENXIANYU )then
        _fish._attackRate=4;
      elseif(_fish._fishType == FishType.FISH_WUGUI or _fish._fishType == FishType.FISH_HUDIEYU)then
        _fish._attackRate=3;
      end
    else
      if(_fish._fishType == FishType.FISH_REDAIZIYU or _fish._fishType == FishType.FISH_XIAOCHOUYU)then
        _fish._attackRate=5;
      elseif(_fish._fishType == FishType.FISH_HETUN or _fish._fishType == FishType.FISH_SHITOUYU)then
        _fish._attackRate=4;
      elseif(_fish._fishType == FishType.FISH_DENGLONGYU or _fish._fishType == FishType.FISH_SHENXIANYU)then
        _fish._attackRate=3;
      elseif(_fish._fishType == FishType.FISH_WUGUI or _fish._fishType == FishType.FISH_HUDIEYU)then
        _fish._attackRate=2;
      end
    end

    _fish._speedTime = 18;
    return _fish;
end

function FishManager:createSpecificFish( parent , type , path)
  local _fish = require("core.Fish").new(type);
  -- local _fish = require("Core.Fish").new(type);
  -- _fish:init();
  _fish:generateFrameAnimation();
  if(path>0)then
    _fish:generateFishPath(path);
  end
  _fish._parent=parent;
  return _fish;
end

function FishManager:createGroupFish( parent , type , path , topFish, groupIndex)
  local _fish = require("core.Fish").new(type);

  _fish:generateFrameAnimation();
  if( path > 0 and topFish ~= nil and groupIndex ~= 0)then
    _fish:generateFishPath(path, groupIndex, topFish);
  elseif(path>0)then
    _fish:generateFishPath(path);
  end
  _fish._parent=parent;
  return _fish;
end


function FishManager:getFishFilePrefix( type )
    if(type<=newFishMax)then
        local fishfilename="fish"..type;
        return fishfilename;
    elseif(type==FishType.FISH_XIAOGUANGYU)then
        return "xiaoguangyu";
    elseif(type==FishType.FISH_XIAOCAOYU)then
        return "xiaocaoyu";
    elseif(type==FishType.FISH_REDAIYU)then
        return "redaiyu";
    elseif(type==FishType.FISH_DAYANJINYU)then
        return "dayanjinyu";
    elseif(type==FishType.FISH_SHUIMU)then
        return "shuimu";
    elseif(type==FishType.FISH_SHANWEIYU)then
        return "shanweiyu";
    elseif(type==FishType.FISH_REDAIZIYU)then
        return "redaiziyu";
    elseif(type==FishType.FISH_XIAOCHOUYU)then
        return "xiaochouyu";
    elseif(type==FishType.FISH_HETUN)then
        return "hetun";
    elseif(type==FishType.FISH_WUZEI)then
        return "wuzei";
    elseif(type==FishType.FISH_SHITOUYU)then
        return "shitouyu";
    elseif(type==FishType.FISH_SHENXIANYU)then
        return "shenxianyu";
    elseif(type==FishType.FISH_WUGUI)then
        return "wugui";
    elseif(type==FishType.FISH_DENGLONGYU)then
        return "denglongyu";
    elseif(type==FishType.FISH_SHIBANYU)then
        return "shibanyu";
    elseif(type==FishType.FISH_HUDIEYU)then
        return "hudieyu";
    elseif(type==FishType.FISH_LINGDANGYU)then
        return "lingdangyu";
    elseif(type==FishType.FISH_JIANYU)then
        return "jianyu";
    elseif(type==FishType.FISH_MOGUIYU)then
        return "moguiyu";
    elseif(type==FishType.FISH_FEIYU)then
        return "feiyu";
    elseif(type==FishType.FISH_LONGXIA)then
        return "longxia";
    elseif(type==FishType.FISH_ZHADAN)then
        return "haitun";
    elseif(type==FishType.FISH_DAZHADAN)then
        return "dayinsha";
    elseif(type==FishType.FISH_FROZEN)then
        return "lanjing";
    elseif(type==FishType.FISH_ZHENZHUBEI)then
        return "zhenzhubei";
    elseif(type==FishType.FISH_XIAOFEIYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_ALILAN)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_ZHADANFISH)then
        return "zhadan";
    elseif(type==FishType.FISH_XIAOHUANGCI)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_LANGUANGYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_QICAIYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_YINGWULUO)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_TIAOWENYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_GANGKUIYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_HAIGUAI)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_HGZHADAN)then
        return "xiaofeiyu";
    else
        return "xiaoguangyu";
    end  
end

function FishManager:getRefreshFishType()
    local freshRateTotal = 0;
    local _i = 1;
  
    if (true)then--//(GameData::getSharedGameData()->getGameType() == GameType_Normal)
        --//? FISH_NORMAL_TYPEMAX-1
        for i=1,FishType.FISH_NORMAL_TYPEMAX do	
            if(self._fishLockArray[i] == false)then
                freshRateTotal = freshRateTotal+_freshRateArray[i];
            end
            _i=i;
        end
        local t = math.random(0,freshRateTotal);
        for i=1,FishType.FISH_NORMAL_TYPEMAX do		
            if(self._fishLockArray[i])then

            else
                if(t < _freshRateArray[i])then
                	_i=i;
                    break;
                end
                t = t -_freshRateArray[i];  
            end
            _i=i;
        end
        if (_i >= FishType.FISH_NORMAL_TYPEMAX)then
            _i = FishType.FISH_NORMAL_TYPEMAX - 1;
        end
        return _i;
    else
        for i=FishType.FISH_XIAOHUANGCI,FishType.FISH_HAIGUAI do		
            freshRateTotal = freshRateTotal + _freshRateArray[i];
            _i=i;
        end
        local t = math.random(0,freshRateTotal);
        for i=FishType.FISH_XIAOHUANGCI,FishType.FISH_HAIGUAI do
            if (t < _freshRateArray[i])then
            	_i=i;
               break;
            end
            t = t -_freshRateArray[i];
            _i=i;
        end
        if (_i >= FishType.FISH_HAIGUAI)then
            _i = FishType.FISH_HAIGUAI - 1;
        end
        return _i;
    end
end

function FishManager:getRefreshFishNum(type)
        if(FishType.FISH_XIAOGUANGYU)then
            return math.random(0,4)+4;
        elseif(FishType.FISH_XIAOCAOYU)then
            return math.random(0,3)+4;
        elseif(FishType.FISH_REDAIYU)then
            return math.random(0,3)+2;
        elseif(FishType.FISH_DAYANJINYU or FishType.FISH_ALILAN)then
            return math.random(0,2)+3;
        elseif(FishType.FISH_SHUIMU or FishType.FISH_SHENXIANYU or FishType.FISH_WUZEI or FishType.FISH_XIAOCHOUYU)then
            return math.random(0,2)+2;
        elseif(FishType.FISH_SHANWEIYU or FishType.FISH_REDAIZIYU or FishType.FISH_HETUN or FishType.FISH_WUGUI or FishType.FISH_DENGLONGYU or FishType.FISH_HUDIEYU or FishType.FISH_LINGDANGYU or FishType.FISH_SHIBANYU)then
            return math.random(0,2)+1;
        elseif(FishType.FISH_SHITOUYU)then
            return math.random(0,3)+1;
        elseif(FishType.FISH_XIAOFEIYU)then
            return 6;
        elseif(FishType.FISH_XIAOHUANGCI)then
            return math.random(0, 2 )+ 6;
        elseif(FishType.FISH_LANGUANGYU)then
            return math.random(0, 1 )+ 5;
        elseif(FishType.FISH_QICAIYU)then
            return math.random(0, 2 )+ 3;
        elseif(FishType.FISH_YINGWULUO or FishType.FISH_TIAOWENYU)then
            return math.random(0, 1 )+ 1;    
        else
            return 1;    
        end    
        -- elseif(FishType.FISH_JIANYU)then
        -- elseif(FishType.FISH_FEIYU)then
        -- elseif(FishType.FISH_LONGXIA)then
        -- elseif(FishType.FISH_ZHADAN)then
        -- elseif(FishType.FISH_DAZHADAN)then
        -- elseif(FishType.FISH_FROZEN)then
        -- elseif(FishType.FISH_ZHENZHUBEI)then
        -- elseif(FishType.FISH_GANGKUIYU)then
        -- elseif(FishType.FISH_HAIGUAI)then
end

function FishManager:lockFish(types,lck)
  if(types >= FishType.FISH_NORMAL_TYPEMAX)then
    return;
  end
  self._fishLockArray[type] = lck;
end


return FishManager