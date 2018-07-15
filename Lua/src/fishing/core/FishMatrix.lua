local FishMatrix = class("FishMatrix")
local _fishMatrix = nil;

FishMatrixType = {
        BigFishMatrix =100,
        FishMatrixNormal = 101,
        BombMatrix = 102,
        BigRingMatrix = 103,
        SineMatrix = 104,
        GoldFishMatrix = 105,
        GoldBoxMatrix = 106,
        FishMatrixMax = 6
};

local BigFishMatrix={
		1,
	   2,2,
	  2,4,2,
	 2,2,2,2,
	7,7,7,7,7,
   7,7,7,7,7,7,
    7,7,7,7,7,
     7,7,7,7,
	  7,7,7,
	    5,
	   5,5 	
};
local BigFishLineDate={1,2,3,4,5,6,5,4,3,1,2}

local FishManager = require("core.FishManager"):getInstance();
local FishPath = require("core.FishPath"):getInstance();

function FishMatrix:getInstance()
    if _fishMatrix == nil then
        _fishMatrix = FishMatrix.new();
    end
    return _fishMatrix;
end

function FishMatrix:createFishMatrix( parent, Matrixtype , fishesInfo)
	print("Matrixtype :",Matrixtype);



	if(Matrixtype==FishMatrixType.FishMatrixNormal)then
		FishMatrix:createNormalMatrix(parent,fishesInfo);
	elseif(Matrixtype==FishMatrixType.BigFishMatrix)then
		FishMatrix:createBigFishMatrix(parent,fishesInfo);
	elseif(Matrixtype==FishMatrixType.BombMatrix)then
		FishMatrix:createBombMatrix(parent,fishesInfo);	
	elseif(Matrixtype==FishMatrixType.BigRingMatrix)then
		FishMatrix:createBigRingMatrix(parent,fishesInfo);	
	elseif(Matrixtype==FishMatrixType.SineMatrix)then
		FishMatrix:createSineMatrix(parent,fishesInfo);	
	elseif(Matrixtype==FishMatrixType.GoldFishMatrix)then
		FishMatrix:createGoldFishMatrix(parent,fishesInfo);	
	elseif(Matrixtype==FishMatrixType.GoldBoxMatrix)then
		FishMatrix:createGoldBoxMatrix(parent,fishesInfo);	
	else
		FishMatrix:createDefaultMatrix(parent,fishesInfo);
	end
end

function FishMatrix:createNormalMatrix(parent,fishesInfo)
	if(fishesInfo==nil or #fishesInfo<60)then
		print("createNormalMatrix error  fishesInfo number < 60");
	end
	local visibleSize = cc.Director:getInstance():getWinSize();
	local offsetX=0;
	for i,item in ipairs(fishesInfo) do
		local fishType=item.fishKind;
		local line=(i-1)%5;
		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setFishID(item.fishID);
		fish._fishPath = {};
		fish:setPosition(cc.p(-100-offsetX, visibleSize.height/2+50*(line-2)))
		local action = cc.MoveTo:create(55, cc.p(visibleSize.width*2-offsetX,visibleSize.height/2+50*(line-2)));
		table.insert(fish._fishPath,action);
		fish:goFish();
		parent.fishLayer:addChild(fish);
		parent.fishData[ item.fishID ] = fish;
		-- fish:setFlippedX(FLIP_FISH);

		fish:setFlipScreen(FLIP_FISH);

		if(line==4)then
			offsetX=offsetX+fish._radius*2+20;
		end
	end
end

function FishMatrix:createBigFishMatrix(parent,fishesInfo)
	local visibleSize = cc.Director:getInstance():getWinSize();
	local fishIndex=1;
	local offsetX=0;
	local offsetX_V=0;
	for k, line in ipairs(BigFishLineDate) do 
		for i=1, line do
			local item=fishesInfo[fishIndex];
			local fish = FishManager:createSpecificFish(parent,item.fishKind,0);
			fish._fishPath = {};
			fish:setFishID(item.fishID);
			fish:setPosition(cc.p(-100-offsetX, visibleSize.height/2+(line-1)*25-(i-1)*50))
			local action = cc.MoveTo:create(60, cc.p(visibleSize.width*2-offsetX,visibleSize.height/2+(line-1)*25-(i-1)*50));
			table.insert(fish._fishPath,cc.DelayTime:create(5));
			table.insert(fish._fishPath,action);
			fish:goFish();
			parent.fishLayer:addChild(fish);
			parent.fishData[ item.fishID ] = fish;
			-- fish:setFlippedX(FLIP_FISH);
			fish:setFlipScreen(FLIP_FISH);

			fishIndex=fishIndex+1;
			offsetX_V=fish._radius*2*2/3;
		end
		offsetX=offsetX+offsetX_V;
	end
end

local bombMatrixFish={15,15,15,15,15,15,15,15,9,9,9,9,9,9,9,9,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,23};
local unitDistance = 35;
local distanceData={{6,4},{-8,4},{6,-4},{-8,-4},{3,7},{-5,7},{3,-7},{-5,-7},
					{4,4},{-4,4},{4,-4},{-4,-4},{6,0},{-6,0},{0,6},{0,-6},
					{4,2},{-4,2},{4,-2},{-4,-2},{2,4},{-2,4},{2,-4},{-2,-4},
					{2,2},{-2,2},{2,-2},{-2,-2},{3,0},{-3,0},{0,3},{0,-3},
					{0,0}};


function FishMatrix:createBombMatrix(parent,fishesInfo)
	local visibleSize = cc.Director:getInstance():getWinSize();
	for i,item in ipairs(fishesInfo) do
		-- local item=fishesInfo[fishIndex];
		local fishType=item.fishKind;
		-- local fishtype=bombMatrixFish[i];
		local aX=distanceData[i][1]*unitDistance;
		local aY=distanceData[i][2]*unitDistance;

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish:setPosition(cc.p(-visibleSize.width/2+aX, visibleSize.height/2+aY))
		parent.fishLayer:addChild(fish);

		fish._fishPath = {};
		local action = cc.MoveTo:create(60, cc.p(visibleSize.width+visibleSize.width/2+aX,visibleSize.height/2+aY));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFlipScreen(FLIP_FISH);

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
	end
end

function FishMatrix:createBigRingMatrix(parent,fishesInfo)
	local visibleSize = cc.Director:getInstance():getWinSize();

	for i,item in ipairs(fishesInfo)  do
		local fish = FishManager:createSpecificFish(parent,item.fishKind,0);
		parent.fishLayer:addChild(fish);
		if i~=121 then
			FishPath:generateFishPathE(fish,i,true);
			local _delay=0.2*(i-1)+5;
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));
		else
			fish._fishPath={};
			fish:setPosition(cc.p(-260, visibleSize.height/2));
			local action1 = cc.MoveTo:create(8, cc.p(visibleSize.width/2,visibleSize.height/2));
			local action2 = cc.MoveTo:create(6, cc.p(visibleSize.width+300,visibleSize.height/2));
			table.insert(fish._fishPath,action1);
			table.insert(fish._fishPath,cc.DelayTime:create(30));
			table.insert(fish._fishPath,action2);
			fish:setFlipScreen(FLIP_FISH);
		end

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
		fish:goFish();
	end

end

function FishMatrix:createSineMatrix(parent,fishesInfo)
	local visibleSize = cc.Director:getInstance():getWinSize();
	-- for i=1,30 do
	-- 	local fish = FishManager:createSpecificFish(parent,6,0);

	-- 	FishPath:generateFishPathI(fish,i,true,4);
	-- 	parent.fishLayer:addChild(fish);

	-- 	local interval = 20 * fish:getContentSize().width/visibleSize.width;
	-- 	local _delay=interval/1.5*(i-1);
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
	-- 	fish:goFish();
	-- end
	-- for i=1,30 do
	-- 	local fish = FishManager:createSpecificFish(parent,6,0);

	-- 	FishPath:generateFishPathI(fish,i,false,4);
	-- 	parent.fishLayer:addChild(fish);

	-- 	local interval = 20 * fish:getContentSize().width/visibleSize.width;
	-- 	local _delay=interval/1.5*(i-1);
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
	-- 	fish:goFish();
	-- end
	-- for i=1,60 do
	-- 	local fish = FishManager:createSpecificFish(parent,0,0);

	-- 	FishPath:generateFishPathI(fish,i,true,8);
	-- 	parent.fishLayer:addChild(fish);

	-- 	local interval = 20 * fish:getContentSize().width/visibleSize.width;
	-- 	local _delay=interval/2*(i-1)+20/8;
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
	-- 	fish:goFish();
	-- end
	-- for i=1,60 do
	-- 	local fish = FishManager:createSpecificFish(parent,0,0);

	-- 	FishPath:generateFishPathI(fish,i,false,8);
	-- 	parent.fishLayer:addChild(fish);

	-- 	local interval = 20 * fish:getContentSize().width/visibleSize.width;
	-- 	local _delay=interval/2*(i-1)+20/8;
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
	-- 	fish:goFish();
	-- end
	-- for i=1,5 do
	-- 	local fish = FishManager:createSpecificFish(parent,15+i,0);
	-- 	parent.fishLayer:addChild(fish);
	-- 	fish._fishPath={};
	-- 	fish:setPosition(cc.p(-i*260, visibleSize.height/2));
	-- 	local action = cc.MoveTo:create(60, cc.p(visibleSize.width*3-i*260,visibleSize.height/2));
	-- 	table.insert(fish._fishPath,action);
	-- 	table.insert(fish._fishPath,1,cc.DelayTime:create(10));		
	-- 	fish:setFlipScreen(FLIP_FISH);
	-- 	fish:goFish();
	-- end

	for i,item in ipairs(fishesInfo) do
		local fish = FishManager:createSpecificFish(parent,item.fishKind,0);
		parent.fishLayer:addChild(fish);
		fish._fishPath={};

		if(i<=30)then
			FishPath:generateFishPathI(fish,i,true,4);
			-- local interval = 20 * fish._radius*2/visibleSize.width;--因为新的鱼的编号改过了  所以现在鱼阵的位置不对 临时改一下
			local interval = 20 * fish:getContentSize().width/visibleSize.width;
			local _delay=interval/1.5*(i-1);
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));	
		elseif(i<=60)then
			FishPath:generateFishPathI(fish,i,false,4);
			-- local interval = 20 * fish._radius*2/visibleSize.width;--因为新的鱼的编号改过了  所以现在鱼阵的位置不对 临时改一下
			local interval = 20 * fish:getContentSize().width/visibleSize.width;
			local _delay=interval/1.5*(i-30-1);
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));
		elseif(i<=120)then
			FishPath:generateFishPathI(fish,i-60,true,8);
			-- local interval = 20 * fish._radius*2/visibleSize.width;--因为新的鱼的编号改过了  所以现在鱼阵的位置不对 临时改一下
			local interval = 20 * fish:getContentSize().width/visibleSize.width;
			local _delay=interval/2*(i-60-1)+20/8;
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
		elseif(i<=180)then
			FishPath:generateFishPathI(fish,i-120,false,8);
			-- local interval = 20 * fish._radius*2/visibleSize.width;--因为新的鱼的编号改过了  所以现在鱼阵的位置不对 临时改一下
			local interval = 20 * fish:getContentSize().width/visibleSize.width;
			local _delay=interval/2*(i-120-1)+20/8;
			table.insert(fish._fishPath,1,cc.DelayTime:create(_delay));		
		elseif(i<=185)then
			fish:setPosition(cc.p(-(i-180)*260, visibleSize.height/2));
			local action = cc.MoveTo:create(60, cc.p(visibleSize.width*3-(i-180)*260,visibleSize.height/2));
			table.insert(fish._fishPath,action);
			table.insert(fish._fishPath,1,cc.DelayTime:create(10));		
			fish:setFlipScreen(FLIP_FISH);
		end

		fish:setFishID(item.fishID);
		parent.fishData[ item.fishID ] = fish;
		fish:goFish();
	end
end


function FishMatrix:createDefaultMatrix(parent,fishesInfo)

	local visibleSize = cc.Director:getInstance():getWinSize();
	local offsetX=0;
	for i,item in ipairs(fishesInfo) do
		local fishType=item.fishKind;
		local fishID=item.fishID;
		local line=i%5;
		local fish = FishManager:createSpecificFish(parent,fishType,0);

		fish._fishPath = {};
		fish:setPosition(cc.p(-100-offsetX, visibleSize.height/2+50*(line-2)))
		local action = cc.MoveTo:create(40, cc.p(visibleSize.width*2-offsetX,visibleSize.height/2+50*(line-2)));
		table.insert(fish._fishPath,action);
		fish:goFish();
		fish:setFishID(fishID);
		parent.fishLayer:addChild(fish);
		parent.fishData[fishID] = fish;
		-- fish:setFlippedX(FLIP_FISH);
		fish:setFlipScreen(FLIP_FISH);
		if(line==4)then
			offsetX=offsetX+fish._radius*2+10;
		end
	end
end

function FishMatrix:createTestMatrix(parent)

	local visibleSize = cc.Director:getInstance():getWinSize();
	local offsetX=10;
	for i=1,newFishMax do
		local line=i%5;
		local fish = FishManager:createSpecificFish(parent,i-1,0);
		fish:setPosition(cc.p(visibleSize.width-offsetX, visibleSize.height/2+50*(line-2)))
		parent.fishLayer:addChild(fish);
		if(line==4)then
			offsetX=offsetX+fish._radius*2;
		end
	end
end


local testBigFishMatrix={
		2,
	  2,2,2,
	 2,3,2,2,
	2,2,2,2,2,
   7,7,7,7,7,7,
  7,24,24,24,24,24,7,
  7,24,24,24,24,24,7,
   7,24,24,24,24,7,
    7,24,24,24,7,
     7,24,24,7,
	  7,24,7,
	    5,
	   5,5 	
};

local testBigFishLineDate={1,3,4,5,6,7,7,6,5,4,3,1,2}

function FishMatrix:createGoldFishMatrix(parent,fishesInfo)
	local visibleSize = cc.Director:getInstance():getWinSize();
	local fishIndex=1;
	local offsetX=0;
	local offsetX_V=0;

	for k,line in ipairs(testBigFishLineDate)  do
		for i=1, line do
			local item=fishesInfo[fishIndex];
			local fish = FishManager:createSpecificFish(parent,item.fishKind,0);
			fish._fishPath = {};
			fish:setFishID(item.fishID);
			fish:setPosition(cc.p(-200-offsetX, visibleSize.height/2+(line-1)*25-(i-1)*50))
			local action = cc.MoveTo:create(65, cc.p(visibleSize.width*2-offsetX,visibleSize.height/2+(line-1)*25-(i-1)*50));
			table.insert(fish._fishPath,cc.DelayTime:create(5));
			table.insert(fish._fishPath,action);
			fish:goFish();
			parent.fishLayer:addChild(fish);
			parent.fishData[ item.fishID ] = fish;
			fish:setFlipScreen(FLIP_FISH);

			fishIndex=fishIndex+1;
			offsetX_V=fish._radius*2*2/3;
		end
		offsetX=offsetX+offsetX_V;
	end

	for i=1, 4 do
		local item=fishesInfo[fishIndex];
		local fish = FishManager:createSpecificFish(parent,item.fishKind,0);
		fish._fishPath = {};
		fish:setFishID(item.fishID);
		fish:setPosition(cc.p(-150-((i%2)*600), visibleSize.height/2+225-(math.floor((i-1)/2)*450)));
		local action = cc.MoveTo:create(65, cc.p(visibleSize.width*2-150-((i%2)*600),visibleSize.height/2+225-(math.floor((i-1)/2)*450)));
		table.insert(fish._fishPath,cc.DelayTime:create(2));
		table.insert(fish._fishPath,action);
		fish:goFish();
		parent.fishLayer:addChild(fish);
		parent.fishData[ item.fishID ] = fish;
		fish:setFlipScreen(FLIP_FISH);
		fishIndex=fishIndex+1;
	end
end

function FishMatrix:createTestBigFishMatrix(parent)
	local visibleSize = cc.Director:getInstance():getWinSize();
	local fishIndex=1;
	local offsetX=0;
	local offsetX_V=0;
	for k, line in ipairs(testBigFishLineDate) do 
		for i=1, line do
			local item=testBigFishMatrix[fishIndex];
			local fish = FishManager:createSpecificFish(parent,item,0);
			fish._fishPath = {};
			fish:setFishID(1);
			fish:setPosition(cc.p(-200-offsetX, visibleSize.height/2+(line-1)*25-(i-1)*50))
			local action = cc.MoveTo:create(65, cc.p(visibleSize.width*2-offsetX,visibleSize.height/2+(line-1)*25-(i-1)*50));
			table.insert(fish._fishPath,cc.DelayTime:create(5));
			table.insert(fish._fishPath,action);
			fish:goFish();
			parent.fishLayer:addChild(fish);
			fish:setFlipScreen(FLIP_FISH);

			fishIndex=fishIndex+1;
			offsetX_V=fish._radius*2*2/3;
		end
		offsetX=offsetX+offsetX_V;
	end

	for i=1, 4 do
		local fish = FishManager:createSpecificFish(parent,17,0);
		fish._fishPath = {};
		fish:setFishID(1);
		fish:setPosition(cc.p(-150-((i%2)*600), visibleSize.height/2+225-(math.floor((i-1)/2)*450)));
		local action = cc.MoveTo:create(65, cc.p(visibleSize.width*2-150-((i%2)*600),visibleSize.height/2+225-(math.floor((i-1)/2)*450)));
		table.insert(fish._fishPath,cc.DelayTime:create(2));
		table.insert(fish._fishPath,action);
		fish:goFish();
		parent.fishLayer:addChild(fish);
		fish:setFlipScreen(FLIP_FISH);
	end 
end

local smallBoxPosX={0,40,80,120,160,200,160,120,80,40}
local smallBoxPosY={100,90,77.5,60,35,0,-35,-60,-77.5,-90}
local bigBoxPosX={-210,-70,70};
local bigBoxPosY={0,70,70};

function FishMatrix:createGoldBoxMatrix(parent,fishesInfo)
		local visibleSize = cc.Director:getInstance():getWinSize();
	local fishIndex=1;
	local offsetX=0;
	local offsetX_V=0;
	local half=1;
	for i,item in ipairs(fishesInfo) do
		local fishType=item.fishKind;
		local _d=i;
		if i>10 and i<=20 then
			half=-1;
			_d=i-10;
		end
		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish._fishPath = {};
		table.insert(fish._fishPath,cc.DelayTime:create(2));
		fish:setFishID(item.fishID);
		if i<=20 then
			fish:setPosition(cc.p(-420-smallBoxPosX[_d]*half*2, visibleSize.height/2+smallBoxPosY[_d]*half*2));
			local action = cc.MoveTo:create(70, cc.p(visibleSize.width*2-smallBoxPosX[_d]*half*2,visibleSize.height/2+smallBoxPosY[_d]*half*2));
			table.insert(fish._fishPath,action);
		else
			if i<=23 then
				_d=i-20;
				half=1;
			else
				_d=i-23;
				half=-1;
			end
			fish:setPosition(cc.p(-420-bigBoxPosX[_d]*half, visibleSize.height/2+bigBoxPosY[_d]*half));
			local action = cc.MoveTo:create(70, cc.p(visibleSize.width*2-bigBoxPosX[_d]*half,visibleSize.height/2+bigBoxPosY[_d]*half));
			table.insert(fish._fishPath,action);
		end
		fish:goFish();
		parent.fishLayer:addChild(fish);
		parent.fishData[ item.fishID ] = fish;
		fish:setFlipScreen(FLIP_FISH);
	end
end

function FishMatrix:createTestBoxMatrix(parent)
	local visibleSize = cc.Director:getInstance():getWinSize();
	local fishIndex=1;
	local offsetX=0;
	local offsetX_V=0;
	local half=1;
	for i=1, 26 do
		local _d=i;
		if i>10 and i<=20 then
			half=-1;
			_d=i-10;
		end
		local fishType=24;
		if i>20 then
			fishType=25;
		end

		local fish = FishManager:createSpecificFish(parent,fishType,0);
		fish._fishPath = {};
		table.insert(fish._fishPath,cc.DelayTime:create(2));
		fish:setFishID(1);
		if i<=20 then
			fish:setPosition(cc.p(-420-smallBoxPosX[_d]*half*2, visibleSize.height/2+smallBoxPosY[_d]*half*2));
			local action = cc.MoveTo:create(65, cc.p(visibleSize.width*2-smallBoxPosX[_d]*half*2,visibleSize.height/2+smallBoxPosY[_d]*half*2));
			table.insert(fish._fishPath,action);
		else
			if i<=23 then
				_d=i-20;
				half=1;
			else
				_d=i-23;
				half=-1;
			end
			fish:setPosition(cc.p(-420-bigBoxPosX[_d]*half, visibleSize.height/2+bigBoxPosY[_d]*half));
			local action = cc.MoveTo:create(65, cc.p(visibleSize.width*2-bigBoxPosX[_d]*half,visibleSize.height/2+bigBoxPosY[_d]*half));
			table.insert(fish._fishPath,action);
		end
		fish:goFish();
		parent.fishLayer:addChild(fish);
		fish:setFlipScreen(FLIP_FISH);
	end

end

return FishMatrix