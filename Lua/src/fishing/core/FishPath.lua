local FishPath = class("FishPath")
local _fishGroup = nil;
local FishPathType={
    FISH_PATHTYPE_A = 1,
    FISH_PATHTYPE_B = 2,
    FISH_PATHTYPE_C = 3,
    FISH_PATHTYPE_D = 4,
    FISH_PATHTYPE_E = 5,
    FISH_PATHTYPE_STATIC = 6
}
function FishPath:getInstance()
    if _fishGroup == nil then
        _fishGroup = FishPath.new();
    end
    return _fishGroup;
end
local randomFakeSeed =1;
function FishPath:ctor()
end

function FishPath:createFishPath(fish, path, groupIndex, topFish)
    -- local pathType=self:getFishPathType(fish._fishtype)
    self._path=path;
    randomFakeSeed=self._path*fish._fishType;


    -- self:generateFishPathH(fish,groupIndex);


    local r=FishPath:fakeRandom( 0, 371 )%100;

    -- if fish._fishType > 9 then
    --     r=r%60;
    -- end

    -- if(r<10)then
    --     self:generateFishPathB(fish,groupIndex);
    -- elseif(r<60)then
    --     self:generateFishPathC(fish,groupIndex);
    -- else
    --     self:generateFishPathA(fish,groupIndex);
    -- end

    if fish._fishType<=2 then
        if(r<=20)then
            self:generateFishPathA(fish,groupIndex);
        elseif(r<=20+15)then
            self:generateFishPathC(fish,groupIndex);
        elseif(r<=35+5)then
            self:generateFishPathF(fish,groupIndex);
        elseif(r<=40+15)then
            self:generateFishPathG(fish,groupIndex);
        elseif(r<=55+10)then
            self:generateFishPathE(fish,groupIndex);
        else
            self:generateFishPathH(fish,groupIndex);
        end
    elseif fish._fishType<=8 then --13
        if(r<=25)then
            self:generateFishPathA(fish,groupIndex);
        elseif(r<=25+25)then
            self:generateFishPathB(fish,groupIndex);
        elseif(r<=50+25)then
            self:generateFishPathC(fish,groupIndex);
        else
            self:generateFishPathE(fish,groupIndex);
        end
    else
        if(r<=20)then
            self:generateFishPathA(fish,groupIndex);
        elseif(r<=20+40)then
            self:generateFishPathB(fish,groupIndex);
        else
            self:generateFishPathC(fish,groupIndex);
        end
    end
end

function FishPath:createFollowPath(fish, path, topFish, groupIndex)
    self._path=path;
    randomFakeSeed=self._path*fish._fishType;


    self:generateFishPathH(fish,groupIndex);

    -- local r=FishPath:fakeRandom( 0, 133 )%100;

    -- if fish._fishType > 9 then
    --     r=r%60;
    -- end

    -- if(r<10)then
    --     self:generateFishPathB(fish,groupIndex);
    -- elseif(r<60)then
    --     self:generateFishPathC(fish,groupIndex);
    -- else
    --     self:generateFishPathA(fish,groupIndex);
    -- end
end


function FishPath:getFishPathType(fishtype)
    return FishPathType.FISH_PATHTYPE_A;
end

function FishPath:generateFishPathA( fish, groupIndex)
    fish._fishPath={};

    local start_X=0;
    local start_Y=0;
    local end_X=0;
    local end_Y=0;

    local s = fish:getContentSize();
    
    local visibleSize = cc.Director:getInstance():getWinSize();

    -- local _offsetX=-visibleSize.width/2;
    -- local _offsetY=-visibleSize.height/2;

    local _offsetX=0;
    local _offsetY=0;

    if(self._path%2==1) then
        start_X = -s.width*3+_offsetX;
        start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
        end_X=visibleSize.width+s.width*3+_offsetX;
        end_Y=FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
    else
        end_X = -s.width*3+_offsetX;
        end_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
        start_X=visibleSize.width+s.width*3+_offsetX;
        start_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
        fish:setFlipRotate(true);

        -- start_X = -s.width;
        -- start_Y = FishPath:fakeRandom(0,visibleSize.height);
        -- end_X=visibleSize.width+s.width
        -- end_Y=FishPath:fakeRandom(0,visibleSize.height);

        -- start_X = visibleSize.width - start_X;
        -- start_Y = visibleSize.height - start_Y;
        -- end_X = visibleSize.width - end_X;
        -- end_Y = visibleSize.height - end_Y;
        -- fish:setScaleY(-1);
    end
    local timerOffset=0;
    if(groupIndex~=0)then
        randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
        start_X = start_X + FishPath:fakeRandom(0,177)%300-150;
        start_Y = start_Y + FishPath:fakeRandom(0,133)%300-150;
        end_X = end_X + FishPath:fakeRandom(0,245)%300-150;
        end_Y = end_Y + FishPath:fakeRandom(0,237)%300-150;
        timerOffset = (FishPath:fakeRandom(0,50)-25)/10;


        -- start_X = start_X + math.random(0,80)-40;
        -- start_Y = start_Y + math.random(0,80)-40;
        -- end_X = end_X + math.random(0,80)-40;
        -- end_Y = end_Y + math.random(0,80)-40;
        -- timerOffset = math.random(0,2)-1;
    end


    local middle1=FishPath:getMDCurvePointRate( cc.p(start_X, start_Y), cc.p(end_X, end_Y),0.3,false);
    local c1=FishPath:getMDCurvePointRate( cc.p(start_X, start_Y), middle1,0.4,true);
    -- c1=cc.p(c1.x+math.random(0,100),c1.y+math.random(0,100));
    local c2=FishPath:getReflectPoint(c1,middle1,0.7);


    
    local bezier1 ={
        c1,
        c1,
        middle1
    };

    local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

    local bezier2 ={
        c2,
        c2,
        cc.p(end_X, end_Y)
    };

    local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);

    table.insert(fish._fishPath,bezierTo1);
    table.insert(fish._fishPath,bezierTo2);

    fish:setPosition(start_X,start_Y);
    fish:setFlipScreen(FLIP_FISH);
end


function FishPath:generateFishPathB( fish, groupIndex )
    fish._fishPath={};

    local start_X=0;
    local start_Y=0;
    local end_X=0;
    local end_Y=0;

    local s = fish:getContentSize();
    
    local visibleSize = cc.Director:getInstance():getWinSize();

    -- local _offsetX=-visibleSize.width/2;
    -- local _offsetY=-visibleSize.height/2;
    local _offsetX=0;
    local _offsetY=0;

    if(self._path%2==1) then
        start_X = -s.width*3+_offsetX;
        start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
        end_X=visibleSize.width+s.width*3+_offsetX;
        end_Y=FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
    else
        end_X = -s.width*3+_offsetX;
        end_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
        start_X=visibleSize.width+s.width*3+_offsetX;
        start_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
        fish:setFlipRotate(true);
    end


    local timerOffset=0;
    if(groupIndex~=0)then
        randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
        start_X = start_X + FishPath:fakeRandom(0,1177)%400-200;
        start_Y = start_Y + FishPath:fakeRandom(0,1147)%400-200;
        end_X = end_X + FishPath:fakeRandom(0,1245)%400-200;
        end_Y = end_Y + FishPath:fakeRandom(0,1237)%400-200;
        timerOffset = (FishPath:fakeRandom(0,30)-15)/10;


        -- start_X = start_X + math.random(0,80)-40;
        -- start_Y = start_Y + math.random(0,80)-40;
        -- end_X = end_X + math.random(0,80)-40;
        -- end_Y = end_Y + math.random(0,80)-40;
        -- timerOffset = math.random(0,2)-1;
    end

    local middle1=FishPath:getMDCurvePointRate( cc.p(start_X, start_Y), cc.p(end_X, end_Y),0.3,false);
    local c1=FishPath:getMDCurvePointRate( cc.p(start_X, start_Y), middle1,0.4,true);
    -- c1=cc.p(c1.x+math.random(0,100),c1.y+math.random(0,100));
    local c2=FishPath:getReflectPoint(middle1,cc.p(end_X, end_Y),0.7);

    -- local bezier1 ={
    --     c1,
    --     c2,
    --     cc.p(end_X, end_Y)
    -- };

    -- local bezier1 ={
    --     cc.p(end_X, end_Y),
    --     cc.p(visibleSize.width/2,visibleSize.height/2),
    --     cc.p(start_X, start_Y)
    -- };

    local bezier1 ={
        cc.p(visibleSize.width*1/4,visibleSize.height),
        cc.p(visibleSize.width*3/4,0),
        cc.p(end_X, end_Y)
    };

    local bezierTo1 = cc.BezierTo:create(fish._speedTime+timerOffset, bezier1);

    table.insert(fish._fishPath,bezierTo1);



    fish:setPosition(start_X,start_Y);
    fish:setFlipScreen(FLIP_FISH);

end

function FishPath:generateFishPathC( fish, groupIndex )
    fish._fishPath={};

    local start_X=0;
    local start_Y=0;
    local end_X=0;
    local end_Y=0;

    local s = fish:getContentSize();
    
    local visibleSize = cc.Director:getInstance():getWinSize();

    local _offsetX=0;
    local _offsetY=0;

    if(self._path%2==1) then
        start_X = -s.width*3+_offsetX;
        start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
        end_X=visibleSize.width+s.width*3+_offsetX;
        end_Y=FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
    else
        end_X = -s.width*3+_offsetX;
        end_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
        start_X=visibleSize.width+s.width*3+_offsetX;
        start_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
        fish:setFlipRotate(true);
    end




    local _r=FishPath:fakeRandom(0,2);
    local c1;
    local c2;
    local c21;
    local c22;

    local timerOffset=0;
    if(groupIndex~=0)then
        randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
        start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
        start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
        end_X = end_X + FishPath:fakeRandom(0,1245)%300-150;
        end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
        timerOffset = (FishPath:fakeRandom(0,50)-25)/10;

        -- start_X = start_X + math.random(0,80)-40;
        -- start_Y = start_Y + math.random(0,80)-40;
        -- end_X = end_X + math.random(0,80)-40;
        -- end_Y = end_Y + math.random(0,80)-40;
        -- timerOffset = math.random(0,2)-1;
    end
    local midPos=FishPath:genRandMDPoint(cc.p(start_X,start_Y),cc.p(end_X,end_Y))

    if(_r==1)then
        c1=cc.p((midPos.x-start_X)/4+start_X,math.max(start_Y,midPos.y));
        c2=cc.p((midPos.x-start_X)/4*3+start_X,math.max(start_Y,midPos.y));
        c21=cc.p((end_X-midPos.x)/4+midPos.x,math.min(end_Y,midPos.y));
        c22=cc.p((end_X-midPos.x)/4*3+midPos.x,math.min(end_Y,midPos.y));
    else
        c1=cc.p((midPos.x-start_X)/4+start_X,math.min(start_Y,midPos.y));
        c2=cc.p((midPos.x-start_X)/4*3+start_X,math.min(start_Y,midPos.y));
        c21=cc.p((end_X-midPos.x)/4+midPos.x,math.max(end_Y,midPos.y));
        c22=cc.p((end_X-midPos.x)/4*3+midPos.x,math.max(end_Y,midPos.y));
    end

    local bezier1 ={
        c1,
        c2,
        midPos
    };

    local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

    local bezier2 ={
        c21,
        c22,
        cc.p(end_X, end_Y)
    };

    local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);


    table.insert(fish._fishPath,bezierTo1);
    table.insert(fish._fishPath,bezierTo2);
    fish:setPosition(start_X,start_Y);
    fish:setFlipScreen(FLIP_FISH);

end


function FishPath:generateFishPathD( fish, groupIndex )

    fish._fishPath={};

    local start_X=0;
    local start_Y=0;
    local end_X=0;
    local end_Y=0;

    local s = fish:getContentSize();
    
    local visibleSize = cc.Director:getInstance():getWinSize();

    local _offsetX=0;
    local _offsetY=0;

    -- if(self._path%2==1) then
        start_X = -s.width*3+_offsetX;
        start_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
        end_X = -s.width*3+_offsetX;
        end_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
    -- else
    --     end_X = -s.width*3+_offsetX;
    --     end_Y = FishPath:fakeRandom(0,86423)%visibleSize.height+_offsetY;
    --     start_X=visibleSize.width+s.width*3+_offsetX;
    --     start_Y = FishPath:fakeRandom(0,74584)%visibleSize.height+_offsetY;
    --     fish:setFlipRotate(true);
    -- end




    local _r=FishPath:fakeRandom(0,2);
    local c1;
    local c2;
    local c21;
    local c22;

    local timerOffset=0;
    if(groupIndex~=0)then
        randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
        start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
        start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
        end_X = end_X + FishPath:fakeRandom(0,1245)%300-150;
        end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
        timerOffset = (FishPath:fakeRandom(0,50)-25)/10;

        -- start_X = start_X + math.random(0,80)-40;
        -- start_Y = start_Y + math.random(0,80)-40;
        --- end_X = end_X + math.random(0,80)-40;
        -- end_Y = end_Y + math.random(0,80)-40;
        -- timerOffset = math.random(0,2)-1;
    end
    local midPos=FishPath:genRandMDPoint(cc.p(start_X,start_Y),cc.p(end_X,end_Y))

    -- if(_r==1)then

        c1=cc.p(visibleSize.width*1/4,visibleSize.height*3/4);
        c2=cc.p(visibleSize.width*3/4,visibleSize.height*3/4);
        c21=cc.p(visibleSize.width*3/4,0);
        c22=cc.p(visibleSize.width*1/4,0);

        -- c1=cc.p((midPos.x-start_X)/4+start_X,math.max(start_Y,midPos.y));
        -- c2=cc.p((midPos.x-start_X)/4*3+start_X,math.max(start_Y,midPos.y));
        -- c21=cc.p((end_X-midPos.x)/4+midPos.x,math.min(end_Y,midPos.y));
        -- c22=cc.p((end_X-midPos.x)/4*3+midPos.x,math.min(end_Y,midPos.y));
    -- else

        -- c1=cc.p(visibleSize.width*1/4,visibleSize.height*1/4);
        -- c2=cc.p(visibleSize.width*3/4,visibleSize.height*1/4);
        -- c21=cc.p(visibleSize.width*3/4,visibleSize.height*3/4);
        -- c22=cc.p(visibleSize.width*1/4,visibleSize.height*3/4);
        
        -- c1=cc.p((midPos.x-start_X)/4+start_X,math.min(start_Y,midPos.y));
        -- c2=cc.p((midPos.x-start_X)/4*3+start_X,math.min(start_Y,midPos.y));
        -- c21=cc.p((end_X-midPos.x)/4+midPos.x,math.max(end_Y,midPos.y));
        -- c22=cc.p((end_X-midPos.x)/4*3+midPos.x,math.max(end_Y,midPos.y));
    -- end



    local bezier1 ={
        c1,
        c2,
        cc.p(visibleSize.width*4/5,visibleSize.height/2)
    };

    local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

    local bezier2 ={
        c21,
        c22,
        cc.p(end_X, end_Y)
    };

    local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);


    table.insert(fish._fishPath,bezierTo1);
    table.insert(fish._fishPath,bezierTo2);
    fish:setPosition(start_X,start_Y);
    fish:setFlipScreen(FLIP_FISH);

end

function FishPath:generateFishPathE( fish, groupIndex , isMatrix) --大圆环

    fish._fishPath={};

    local start_X=0;
    local start_Y=0;
    local end_X=0;
    local end_Y=0;

    local s = fish:getContentSize();
    
    local visibleSize = cc.Director:getInstance():getWinSize();

    local _r=FishPath:fakeRandom(0,8);

    if(isMatrix)then
        self._path=1;
        fish._speedTime=25;
        if(groupIndex%4==1)then
            _r=0;
        elseif(groupIndex%4==2)then
            _r=3;
        elseif(groupIndex%4==3)then
            _r=4;
        else
            _r=7;
        end
    end

    if(_r==0) then
        start_X = -150;
        start_Y = visibleSize.height+100;
        end_X = visibleSize.width+150;
        end_Y = visibleSize.height+100;
    elseif(_r==1) then
        end_X = -150;
        end_Y = visibleSize.height+100;
        start_X = visibleSize.width+150;
        start_Y = visibleSize.height+100;
    elseif(_r==2) then
        start_X = -150;
        start_Y = -100;
        end_X = visibleSize.width+150;
        end_Y = -100;
        -- fish:setFlipRotate(true);
    elseif(_r==3) then
        end_X = -150;
        end_Y = -100;
        start_X = visibleSize.width+150;
        start_Y = -100;
        -- fish:setFlipRotate(true);
    elseif(_r==4) then
        start_X = -100;
        -- start_Y = -FishPath:fakeRandom(0,86423)%(visibleSize.height/4)+_offsetY;
        start_Y = -150;
        end_X = -100;
        -- end_Y = FishPath:fakeRandom(0,74584)%(visibleSize.height/4)+visibleSize.height+_offsetY;
        end_Y = visibleSize.height+150;
    elseif(_r==5) then
        end_X  = -100;
        end_Y = -150;
        start_X= -100;
        start_Y = visibleSize.height+150;
    elseif(_r==6) then
        start_X = visibleSize.width+100;
        start_Y = -150;
        end_X = visibleSize.width+100;
        end_Y = visibleSize.height+150;
        fish:setFlipRotate(true);
    else
        end_X = visibleSize.width+100;
        end_Y = -150;
        start_X = visibleSize.width+100;
        start_Y = visibleSize.height+150;
    end





    local c1;
    local c2;
    local c21;
    local c22;
    local midPos;

    local timerOffset=0;
    local fudu=1;
    if(isMatrix)then
        fudu=0.5;
    end

    if(groupIndex~=0)then
        randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
        start_X = start_X + (FishPath:fakeRandom(0,1177)%300-150)*fudu;
        start_Y = start_Y + (FishPath:fakeRandom(0,1133)%300-150)*fudu;
        end_X = end_X + (FishPath:fakeRandom(0,1245)%300-150)*fudu;
        end_Y = end_Y + (FishPath:fakeRandom(0,1237)%300-150)*fudu;
        timerOffset = (FishPath:fakeRandom(0,80)-40)/10;

        if(isMatrix)then
            timerOffset=0;
        end

    end

    local _offsetX=(FishPath:fakeRandom(0,1177)%(visibleSize.width/6))*fudu;
    local _offsetY=FishPath:fakeRandom(0,1237)%(visibleSize.height/6);


    if(_r==0) then

        c1=cc.p(visibleSize.width+_offsetX,visibleSize.height);
        c2=cc.p(visibleSize.width+_offsetX,visibleSize.height*1/4-_offsetY);
        c21=cc.p(-_offsetX,visibleSize.height*1/4-_offsetY);
        c22=cc.p(-_offsetX,visibleSize.height);
        midPos=cc.p((visibleSize.width+_offsetX)/2,visibleSize.height*1/4-_offsetY);
    elseif(_r==1) then
        c22=cc.p(visibleSize.width+_offsetX,visibleSize.height);
        c21=cc.p(visibleSize.width+_offsetX,visibleSize.height*1/4-_offsetY);
        c2=cc.p(-_offsetX,visibleSize.height*1/4-_offsetY);
        c1=cc.p(-_offsetX,visibleSize.height);
        midPos=cc.p((visibleSize.width+_offsetX)/2,visibleSize.height*1/4-_offsetY);
    elseif(_r==2) then
        c1=cc.p(visibleSize.width+_offsetX,0);
        c2=cc.p(visibleSize.width+_offsetX,visibleSize.height*3/4+_offsetY);
        c21=cc.p(-_offsetX,visibleSize.height*3/4+_offsetY);
        c22=cc.p(-_offsetX,0);
        midPos=cc.p((visibleSize.width+_offsetX)/2,visibleSize.height*3/4+_offsetY);
    elseif(_r==3) then
        c22=cc.p(visibleSize.width+_offsetX,0);
        c21=cc.p(visibleSize.width+_offsetX,visibleSize.height*3/4+_offsetY);
        c2=cc.p(-_offsetX,visibleSize.height*3/4+_offsetY);
        c1=cc.p(-_offsetX,0);
        midPos=cc.p((visibleSize.width+_offsetX)/2,visibleSize.height*3/4+_offsetY);
    elseif(_r==4) then

        c1=cc.p(0,visibleSize.height+_offsetY);
        c2=cc.p(visibleSize.width*3/4+_offsetX,visibleSize.height+_offsetY);
        c21=cc.p(visibleSize.width*3/4+_offsetX,-_offsetY);
        c22=cc.p(0,-_offsetY);
        midPos=cc.p(visibleSize.width*3/4+_offsetX,(visibleSize.height+_offsetY)/2);
    elseif(_r==5) then
        c22=cc.p(0,visibleSize.height+_offsetY);
        c21=cc.p(visibleSize.width*3/4+_offsetX,visibleSize.height+_offsetY);
        c2=cc.p(visibleSize.width*3/4+_offsetX,-_offsetY);
        c1=cc.p(0,-_offsetY);
        midPos=cc.p(visibleSize.width*3/4+_offsetX,(visibleSize.height+_offsetY)/2);
    elseif(_r==6) then
        c1=cc.p(visibleSize.width,visibleSize.height+_offsetY);
        c2=cc.p(visibleSize.width*1/4-_offsetX,visibleSize.height+_offsetY);
        c21=cc.p(visibleSize.width*1/4-_offsetX,-_offsetY);
        c22=cc.p(visibleSize.width,-_offsetY);
        midPos=cc.p(visibleSize.width*1/4-_offsetX,(visibleSize.height+_offsetY)/2);
    else
        c22=cc.p(visibleSize.width,visibleSize.height+_offsetY);
        c21=cc.p(visibleSize.width*1/4-_offsetX,visibleSize.height+_offsetY);
        c2=cc.p(visibleSize.width*1/4-_offsetX,-_offsetY);
        c1=cc.p(visibleSize.width,-_offsetY);
        midPos=cc.p(visibleSize.width*1/4-_offsetX,(visibleSize.height+_offsetY)/2);
    end



    local bezier1 ={
        c1,
        c2,
        midPos
    };

    local bezierTo1 = cc.BezierTo:create(fish._speedTime/2+timerOffset, bezier1);

    local bezier2 ={
        c21,
        c22,
        cc.p(end_X, end_Y)
    };

    local bezierTo2 = cc.BezierTo:create(fish._speedTime/2-timerOffset, bezier2);


    table.insert(fish._fishPath,bezierTo1);
    table.insert(fish._fishPath,bezierTo2);
    fish:setPosition(start_X,start_Y);
    fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathF( fish, groupIndex ) --大圈套小圈
    fish._fishPath={};

    local start_X=0;
    local start_Y=0;
    local end_X=0;
    local end_Y=0;

    local _offsetX=0;
    local _offsetY=0;
    local timerOffset=0;

    local s = fish:getContentSize();
    
    local visibleSize = cc.Director:getInstance():getWinSize();

    start_X = 200;
    start_Y = -200;
    end_X = -100;
    end_Y = visibleSize.height;


    if(groupIndex~=0)then
        randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
        start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
        start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
        end_X = end_X + FishPath:fakeRandom(0,1245)%300-150;
        end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
        timerOffset = (FishPath:fakeRandom(0,20)-10)/10;

        _offsetX=FishPath:fakeRandom(0,541)%150-75;
        _offsetY=FishPath:fakeRandom(0,743)%200-100;
    end

    local pointArray = {cc.p(start_X-100,start_Y-100),cc.p(start_X+_offsetX,start_Y+_offsetY),cc.p(637+_offsetX,300+_offsetY),cc.p(487+_offsetX,500+_offsetY),cc.p(320+_offsetX,378+_offsetY),cc.p(427+_offsetX,254+_offsetY),cc.p(550+_offsetX,365),cc.p(400+_offsetX,570+_offsetY),cc.p(end_X+_offsetX,end_Y+_offsetY),cc.p(end_X-100,end_Y+100)}

    local rate = 0.25;
    fish:setPosition(start_X,start_Y);
    for i=2,#pointArray-2 do
        local c1_X=pointArray[i].x+rate*(pointArray[i+1].x-pointArray[i-1].x);
        local c1_y=pointArray[i].y+rate*(pointArray[i+1].y-pointArray[i-1].y);
        local c2_X=pointArray[i+1].x-rate*(pointArray[i+2].x-pointArray[i].x);
        local c2_y=pointArray[i+1].y-rate*(pointArray[i+2].y-pointArray[i].y);

        local bezier ={
            cc.p(c1_X,c1_y),
            cc.p(c2_X,c2_y),
            pointArray[i+1]
        };
        local time = (fish._speedTime+timerOffset)/(#pointArray-1);
        -- if(i==2 or i == #pointArray-2)then time=time*1.5 end;
        local bezierTo = cc.BezierTo:create(time, bezier);
        table.insert(fish._fishPath,bezierTo);
    end
    fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathG( fish, groupIndex ) -- 一边三小弯
    fish._fishPath={};


    local start_X=0;
    local start_Y=0;
    local end_X=0;
    local end_Y=0;

    local s = fish:getContentSize();
    
    local visibleSize = cc.Director:getInstance():getWinSize();
    local _r=FishPath:fakeRandom(0,133);

    local _offsetX=0;
    local _offsetY=0;
    local timerOffset=0;


    start_X = FishPath:fakeRandom(0,visibleSize.width)/2;
    start_Y = visibleSize.height+160;
    end_X = visibleSize.width+160;
    end_Y = 260+FishPath:fakeRandom(0,visibleSize.width)%200;

    local c1=cc.p(visibleSize.width*3/5+FishPath:fakeRandom(0,1637)%visibleSize.width/3,start_Y-100-FishPath:fakeRandom(0,739)%50);
    local c2=cc.p(visibleSize.width/10+FishPath:fakeRandom(0,1327)%visibleSize.width/4,c1.y-100-FishPath:fakeRandom(0,941)%100);
    local c3=cc.p(c2.x+150+FishPath:fakeRandom(0,2819)%50,c2.y-150-FishPath:fakeRandom(0,661)%50);
    local c4=cc.p(c2.x,c3.y-(c2.y-c3.y));
    local c5=cc.p((end_X-c4.x)/2+c4.x,20+FishPath:fakeRandom(0,743)%100);

    if(groupIndex~=0)then
        randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);
        start_X = start_X + FishPath:fakeRandom(0,1177)%300-150;
        start_Y = start_Y + FishPath:fakeRandom(0,1133)%300-150;
        end_X = end_X + FishPath:fakeRandom(0,1245)%300-150;
        end_Y = end_Y + FishPath:fakeRandom(0,1237)%300-150;
        timerOffset = (FishPath:fakeRandom(0,20)-10)/10;

        _offsetX=FishPath:fakeRandom(0,541)%150-75;
        _offsetY=FishPath:fakeRandom(0,743)%200-100;

        -- start_X = start_X + math.random(0,80)-40;
        -- start_Y = start_Y + math.random(0,80)-40;
        -- end_X = end_X + math.random(0,80)-40;
        -- end_Y = end_Y + math.random(0,80)-40;
        -- timerOffset = math.random(0,2)-1;
    end


    local pointArray;
    if(_r%2==1)then
        pointArray = {cc.p(start_X-100,start_Y+100),cc.p(start_X,start_Y),c1,c2,c3,c4,c5,cc.p(end_X,end_Y),cc.p(end_X+100,end_Y-100)}
        fish:setPosition(start_X,start_Y);
    else
        pointArray = {cc.p(end_X+100,end_Y-100),cc.p(end_X,end_Y),c5,c4,c3,c2,c1,cc.p(start_X,start_Y),cc.p(start_X-100,start_Y+100)}
        fish:setPosition(end_X,end_Y);
    end

    local rate = 0.25;

    for i=2,#pointArray-2 do
        local c1_X=pointArray[i].x+rate*(pointArray[i+1].x-pointArray[i-1].x)+_offsetX;
        local c1_y=pointArray[i].y+rate*(pointArray[i+1].y-pointArray[i-1].y)+_offsetY;
        local c2_X=pointArray[i+1].x-rate*(pointArray[i+2].x-pointArray[i].x)+_offsetX;
        local c2_y=pointArray[i+1].y-rate*(pointArray[i+2].y-pointArray[i].y)+_offsetY;

        local bezier ={
            cc.p(c1_X,c1_y),
            cc.p(c2_X,c2_y),
            cc.p(pointArray[i+1].x+_offsetX,pointArray[i+1].y+_offsetY)
        };

        local time = fish._speedTime/(#pointArray-3);
        if(i%2==1)then
           time = time + timerOffset;
        else
           time = time - timerOffset;
        end
        local bezierTo = cc.BezierTo:create(time, bezier);
        table.insert(fish._fishPath,bezierTo);

        -- print("c1_X "..c1_X.." c1_Y "..c1_y.." c2_X "..c2_X.." c2_y "..c2_y.." i_x "..pointArray[i+1].x.." i_Y "..pointArray[i+1].y.." i:"..i)
    end
    fish:setFlipScreen(FLIP_FISH);
end

function FishPath:generateFishPathH( fish, groupIndex ) --三圈
    fish._fishPath={};

    local start_X=0;
    local start_Y=0;
    local end_X=0;
    local end_Y=0;

    local s = fish:getContentSize();
    
    local visibleSize = cc.Director:getInstance():getWinSize();
    local _r=FishPath:fakeRandom(0,133);
    local mode=FishPath:fakeRandom(0,15)%2;


    randomFakeSeed=(self._path+groupIndex)*(fish._fishType+groupIndex);

    start_X = self:fakeRandom(visibleSize.width/3-100,visibleSize.width/3+100);
    start_Y = -150 - self:fakeRandom(0,50);
    end_X = -self:fakeRandom(s.width,s.width+50);
    end_Y = self:fakeRandom(visibleSize.height/3-100,visibleSize.height/3+100);

    local t_Arr = {1,0,-1,0};
    local p_Arr = {1,1,-1,-1};
    local _t = self:fakeRandom(-start_Y+150,-start_Y+250);

    if(mode==1)then
        start_X = self:fakeRandom(visibleSize.width*2/3-100,visibleSize.width*2/3+100);
        start_Y = 150 + self:fakeRandom(0,50)+visibleSize.height;
        t_Arr = {-1,0,1,0};
        p_Arr = {-1,-1,1,1};
        _t = self:fakeRandom(start_Y-visibleSize.height+150,start_Y-visibleSize.height+250);
    end

    local c_aX=0;
    local c_aY=0;
    local point_now = cc.p(start_X,start_Y);
    fish:setPosition(start_X,start_Y);


    local rate =-1;
    if(_r%2==1)then
        rate=0.5;
        -- end_X=-end_X+visibleSize.width;
    end

    local bezierNum=12;
    for i=1,bezierNum do
        local point_next = cc.p ( point_now.x + _t*p_Arr[(i%4) +1] , point_now.y + _t*p_Arr[(i-1)%4 +1]); 
        local c1=cc.p(point_now.x + rate*_t*t_Arr[(i-1)%4+1], point_now.y + rate*_t*t_Arr[(i+2)%4+1]);
        local c2=cc.p(point_next.x + rate*_t*t_Arr[(i+2)%4+1], point_next.y + rate*_t*t_Arr[(i+1)%4+1]);

        local bezier ={
            c1,
            c2,
            point_next
        };

        local time = fish._speedTime*2/bezierNum;
        local bezierTo = cc.BezierTo:create(time, bezier);
        table.insert(fish._fishPath,bezierTo);
        if(_r%2==1)then
            _t = 100+self:fakeRandom(0,127*i+47*i)%200;
        else
            _t = 200+self:fakeRandom(0,127*i+47*i)%200;
        end
        point_now=cc.p(point_next.x,point_next.y);

        if(i==bezierNum)then
            if c1.x-point_now.x < 0 then
                end_X=-end_X+visibleSize.width;
            end
        end
    end


    local bezierEnd ={
        cc.p(point_now.x,point_now.y+(point_now.x-end_Y)*0.5),
        cc.p(end_X-(end_X-point_now.x)*0.5,end_Y),
        cc.p(end_X,end_Y)
    };

    local bezierToEnd = cc.BezierTo:create(fish._speedTime*2/bezierNum, bezierEnd);
    table.insert(fish._fishPath,bezierToEnd);

    fish:setFlipScreen(FLIP_FISH);



end

function FishPath:generateFishPathI( fish, groupIndex, beginUp, roundNum ) -- 类似正弦函数前进 ， 鱼阵上用
    if(beginUp == nil)then
        beginUp=true;
    end
    if(roundNum == nil)then
        roundNum=FishPath:fakeRandom(5,15);
    end

    fish._fishPath={};
    local visibleSize = cc.Director:getInstance():getWinSize();
    local roundDistance=visibleSize.width/roundNum;
    local start_X = - roundDistance;
    local start_Y = visibleSize.height/2;
    local p_Arr = {1,1,-1,-1};
    local t_xArr = {0,1};
    local t_yArr = {1,0,-1,0};

    local point_now = cc.p(start_X,start_Y);
    fish:setPosition(start_X,start_Y);
    local _t=roundDistance/2;
    local rate=0.5;

    local upDownDelay=0;
    if(beginUp)then
        upDownDelay=2;
    end

    for i=1,(roundNum+2)*2 do
        local point_next = cc.p ( point_now.x + _t , point_now.y + _t*p_Arr[(i+upDownDelay)%4 +1]); 
        local c1=cc.p(point_now.x + rate*_t*t_xArr[(i-1+upDownDelay)%2+1], point_now.y + rate*_t*t_yArr[(i-1+upDownDelay)%4+1]);
        local c2=cc.p(point_next.x - rate*_t*t_xArr[(i+upDownDelay)%2+1], point_next.y + rate*_t*t_yArr[(i+2+upDownDelay)%4+1]);

        local bezier ={
            c1,
            c2,
            point_next
        };

        local time = 20/(roundNum*2);
        local bezierTo = cc.BezierTo:create(time, bezier);
        table.insert(fish._fishPath,bezierTo);
        point_now=cc.p(point_next.x,point_next.y);
    end
    fish:setFlipScreen(FLIP_FISH);
end

function FishPath:getMDCurvePointRate(startPos, endPos, rate, plus)
    local angle = math.atan2(startPos.y - endPos.y, startPos.x - endPos.x);
    
    if(plus)then
        angle = angle + math.pi/2;
    else
        angle = angle - math.pi/2;
    end
    
    local distance = rate * math.sqrt((startPos.x-endPos.x)*(startPos.x-endPos.x) + (startPos.y-endPos.y)*(startPos.y-endPos.y))/2;
    
    local _x = distance*math.cos(angle);
    local _y = distance*math.sin(angle);

    local Pos=cc.p((startPos.x+endPos.x)/2+_x, (startPos.y+endPos.y)/2+_y)
    
    return Pos;
end

function FishPath:getReflectPoint(startPos, origin, rate)
    local Pos=cc.p(origin.x+(origin.x-startPos.x)*rate,origin.y+(origin.y-startPos.y)*rate)

    return Pos;
end


function FishPath:genRandMDPoint(startPos, endPos)
    local _r=FishPath:fakeRandom(0,3);
    local start_X=startPos.x;
    local start_Y=startPos.y;
    local end_X=endPos.x;
    local end_Y=endPos.y;
    if(_r==0)then
        local result_X=(end_X-start_X)/3+start_X;
        local result_Y=(end_Y-start_Y)/3+start_Y;
        return cc.p(result_X,result_Y);
    elseif(_r==1)then
        local result_X=(end_X-start_X)/3*2+start_X;
        local result_Y=(end_Y-start_Y)/3*2+start_Y;
        return cc.p(result_X,result_Y);
    else
        local result_X=(end_X-start_X)/2+start_X;
        local result_Y=(end_Y-start_Y)/2+start_Y;
        return cc.p(result_X,result_Y);
    end
end

function FishPath:fakeRandom( startNum, endNum )
    -- print("randomFakeSeed"..randomFakeSeed);

    return ((randomFakeSeed*131497+35729)%(endNum-startNum)) + startNum;
end

return FishPath


