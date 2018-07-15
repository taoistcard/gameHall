local FishGroup = class("FishGroup")
local _fishGroup = nil;

local FishGroupType = {
        FishGroupLine = 0,
        FishGroupRand = 1
    };


function FishGroup:getInstance()
    if _fishGroup == nil then
        _fishGroup = FishGroup.new();
    end
    return _fishGroup;
end

local FishManager = require("core.FishManager"):getInstance();



function FishGroup:createFishGroup( parent, num, fish_type, path_type )

	-- print("num "..num.." fish_type "..fish_type.." path_type "..path_type)

	-- if fish_type>1 then
	-- 	return self:createFishNormalGroup(parent,num,fish_type,path_type);
	-- end

	-- return self:createFishRandGroup(parent,num,fish_type,path_type);


	if((num+fish_type+path_type)%5==0)then
		return self:createFishRandGroup(parent,num,fish_type,path_type);
	elseif((num+fish_type+path_type)%5<=2 and fish_type<4)then
		return self:createFishLineGroup(parent,num,fish_type,path_type);
	else
		return self:createFishNormalGroup(parent,num,fish_type,path_type);
	end

end	

function FishGroup:createFishLineGroup( parent, num, fish_type, path_type )
	local fishPf = nil;
	local fishP = nil;
	local interval = 0.5;
	local size = cc.Director:getInstance():getWinSize();
	local fishArray= {};
	-- print("fish Line group num : "..num.."  fish type:"..fish_type)
	for i=1,num do
		if(fishPf==nil)then
			fishPf = FishManager:createSpecificFish(parent,fish_type,path_type);
			fishP = fishPf;
		else
			fishP = FishManager:createSpecificFish(parent,fish_type,0);
			fishP._fishPath = {};
			interval = fishP._speedTime * fishP._radius*2/size.width;
			local _delay=interval*(i-1);
			table.insert(fishP._fishPath,cc.DelayTime:create(_delay));
			for j=1,#fishPf._fishPath do
				local ActionCopy = fishPf._fishPath[j]:clone();
				table.insert(fishP._fishPath,ActionCopy);
			end
			
			fishP:setPosition(fishPf:getPosition());
			-- fishP:setFlippedX(FLIP_FISH);

			if(fishPf._flipY)then
				fishP:setFlipRotate(true);
			end

			fishP:setFlipScreen(FLIP_FISH);


		end
		table.insert(fishArray,fishP);
	end
	return fishArray;
end	

local distanceData={{1,1},{-1,1},{0,-4},{0,-2},{1,1.5},{-1,-1},{0.5,-2},{-0.5,-3},
					{0.5,-3},{-0.5,-2},{1.5,1},{0,-5},{0.5,-5},{0.5,-3},{-1.5,1},{1,-1}};


function FishGroup:createFishRandGroup( parent, num, fish_type, path_type )
	local fishPf = nil;
	local fishP = nil;
	local interval = 0.5;
	local size = cc.Director:getInstance():getWinSize();
	local fishArray= {};
	-- print("fish Rand group num : "..num.."  fish type:"..fish_type)
	for i=1,num do
		if(fishPf==nil)then
			fishPf = FishManager:createSpecificFish(parent,fish_type,path_type);
			fishP = fishPf;
		else
			fishP = FishManager:createSpecificFish(parent,fish_type,0);
			fishP._fishPath = {};
			interval = fishP._speedTime * fishP._radius*2/size.width;
			local _delay=interval*(i-1);
			table.insert(fishP._fishPath,cc.DelayTime:create(_delay));

			for j=1,#fishPf._fishPath do
				local ActionCopy = fishPf._fishPath[j]:clone();
				table.insert(fishP._fishPath,ActionCopy);
			end
			local pX=fishPf:getPositionX()+distanceData[i][1]*fishP._radius;
			local pY=fishPf:getPositionY()+distanceData[i][2]*fishP._radius;
   			fishP:setPosition(cc.p(pX,pY));

			if(fishPf._flipY)then
				fishP:setFlipRotate(true);
			end

			fishP:setFlipScreen(FLIP_FISH);

		end
		table.insert(fishArray,fishP);
	end
	return fishArray;
end	


function FishGroup:createFishNormalGroup( parent, num, fish_type, path_type )
	local fishPf = nil;
	local fishP = nil;
	local interval = 0.5;
	local size = cc.Director:getInstance():getWinSize();
	local fishArray= {};
	-- print("fish normal group num : "..num.."  fish type:"..fish_type)
	for i=1,num do
		if(fishPf==nil)then
			fishPf = FishManager:createSpecificFish(parent,fish_type,path_type);
			fishP = fishPf;
		else
			fishP = FishManager:createGroupFish(parent,fish_type,path_type,fishPf, i);
		end
		table.insert(fishArray,fishP);
	end
	return fishArray;
end	


return FishGroup