local Bullet = class( "Bullet", function() return display.newSprite("blank.png"); end )
-- local Bullet = class( "Bullet", function() 
--     local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
--     local pFrame = sharedSpriteFrameCache:getSpriteFrame("shot01.png");
--     local bullet = cc.Sprite:createWithSpriteFrame(pFrame);
--     return bullet;
-- end ) 

--memberOrder 子弹所属玩家的vip等级
function Bullet:ctor(database,paoOption,paoLevel,memberOrder,bSetLockFishSlow)

    self.database = database;
    self.gameLayer = database.parent;

    self.paoOption = paoOption;
    self.paoLevel = paoLevel;

    self.memberOrder = memberOrder
    --打出的子弹是否减速
    self.bSetLockFishSlow = bSetLockFishSlow

    self:setDefaultData();
    self:createDefaultBullet();

    --vip2以上自动开启子弹无限反弹
    if self.memberOrder and self.memberOrder >= 2 then
        self.foreverReflect = true
    else
        self.foreverReflect = false
    end

    --vip4以上自动开启子弹追踪模式
    if self.memberOrder and self.memberOrder >= 4 then
        self.follow = true
    else
        self.follow = false
    end

    self:setNodeEventEnabled(true);
    self.collideEnable=false;

    local sequence = transition.sequence(
        {
            cc.DelayTime:create(0.05),
            cc.CallFunc:create(function() self.collideEnable=true;end)
        }
    )
    self:runAction(sequence);
end

function Bullet:onExit()
  if(self.updateBulletScheduler ~= nil)then
    scheduler.unscheduleGlobal(self.updateBulletScheduler);
  end

  if self.myFire then
    if self.database.parent.myBulletCount>0 then
        self.database.parent.myBulletCount=self.database.parent.myBulletCount-1;
    end
  end
end

function Bullet:setDefaultData()

    self.reflectTimes = 0;
    --vip1以上自动开启子弹加速
    if self.memberOrder and self.memberOrder >= 1 then
        self.speed = 900;
    else
        self.speed = 680;
    end
    self.hit = false;
    self.id = GLOBAL_BULLET_ID

end

--设置无限反弹
function Bullet:setReflectForever()
    self.foreverReflect = true
end

function Bullet:createDefaultBullet()

    -- local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    -- local pFrame = sharedSpriteFrameCache:getSpriteFrame("shot01.png");
    -- local bullet = cc.Sprite:createWithSpriteFrame(pFrame);
    -- self:addChild(bullet);
    -- self.model = bullet;

    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    sharedSpriteFrameCache:addSpriteFrames("pao-zd.plist");
    local pFrame = sharedSpriteFrameCache:getSpriteFrame("zd"..self.paoOption.."-l"..self.paoLevel..".png");
    self:setSpriteFrame(pFrame);

end

function Bullet:shootTo(pt)

    if self.follow and self.lockFish then
        self:shootToFish();
    else
        self:shootToPos(pt);
    end

end

function Bullet:shootToPos(pt)

    local ptTo = self:getParent():convertToNodeSpace(pt);
    local ptFrom = cc.p(self:getPositionX(),self:getPositionY());
    local angle =  math.atan((ptTo.x-ptFrom.x)/(ptTo.y-ptFrom.y)) / math.pi * 180;

    local rotation = angle;
    if ptFrom.y > ptTo.y then
        rotation = 180 + angle;
    end
    self:setRotation(rotation);

    local size = cc.Director:getInstance():getWinSize();

    local k = (ptFrom.y - ptTo.y)/(ptFrom.x-ptTo.x);
    local b = ptFrom.y-k*ptFrom.x;
    local target = {cc.p(0,b), cc.p(size.width, size.width*k+b), cc.p(-b/k, 0), cc.p((size.height-b)/k, size.height)};--cross with left, cross with right, cross with down, cross with up
    local targetPt;
    local rc = cc.rect(0, 0, size.width, size.height);

    for i = 1, 4 do
        if cc.rectContainsPoint(rc,target[i]) and (ptTo.y - ptFrom.y) * (target[i].y-ptFrom.y) > 0 then
            targetPt = target[i];
            break;
        end
    end
    -- print(ptFrom.x,ptFrom.y,ptTo.x,ptTo.y);
    -- print(targetPt.x,targetPt.y);
    local ccpDistance = math.sqrt( (ptFrom.x-targetPt.x)*(ptFrom.x-targetPt.x) + (ptFrom.y-targetPt.y)*(ptFrom.y-targetPt.y) );
    local speed = self.speed;
    local moveSec = ccpDistance / speed;

    local sequence = transition.sequence(
        {
            cc.MoveTo:create(moveSec, targetPt),
            cc.CallFunc:create(function() self:reflect();end)
        }
    )
    self:runAction(sequence);

    self.ptLastStart = ptFrom;


end

function Bullet:reflect()

    self:setFlippedY(false);

    self.reflectTimes = self.reflectTimes + 1;

    if self.reflectTimes > 9 and not self.foreverReflect then
        self:disappear();
        return;
    end

    local ptLastStart = self.ptLastStart;
    local ptFrom = cc.p(self:getPositionX(),self:getPositionY());
    local size = cc.Director:getInstance():getWinSize();

    local k = -(ptFrom.y - ptLastStart.y)/(ptFrom.x-ptLastStart.x);
    local b = ptFrom.y-k*ptFrom.x;
    local target = {cc.p(0,b), cc.p(size.width, size.width*k+b), cc.p(-b/k, 0), cc.p((size.height-b)/k, size.height)};--cross with left, cross with right, cross with down, cross with up
    local realTarget;
    local rc = cc.rect(0, 0, size.width, size.height);

    for i = 1, 4 do
        if ( math.floor(target[i].x) ~= math.floor(ptFrom.x) or math.floor(target[i].y) ~= math.floor(ptFrom.y) ) and cc.rectContainsPoint(rc,target[i]) then
            realTarget = target[i];
            break;
        end
    end

    --容错
    if realTarget then
        local angle = math.atan((realTarget.x-ptFrom.x)/(realTarget.y-ptFrom.y)) / math.pi * 180;
        local rotation = angle;
        if ptFrom.y > realTarget.y then
            rotation = 180 + angle;
        end
        self:setRotation(rotation);


        local ccpDistance = math.sqrt( (ptFrom.x-realTarget.x)*(ptFrom.x-realTarget.x) + (ptFrom.y-realTarget.y)*(ptFrom.y-realTarget.y) );
        local speed = self.speed;
        local moveSec = ccpDistance / speed;

        local sequence = transition.sequence(
            {
                cc.MoveTo:create(moveSec, realTarget),
                cc.CallFunc:create(function() self:reflect();end)
            }
        )
        self:runAction(sequence);
    else
        print("...异常 Bullet:reflect ... realTarget 为 nil ...")
    end

    self.ptLastStart = ptFrom;

end

function Bullet:setMainTarget(fish)

    self.mainTarget = fish;

end

function Bullet:showNet()

    -- if true then
    --     return;
    -- end

    self.hit = true;
    self:hitFish();

    self:stopAllActions();
    -- -- self.model:setVisible(false);

    -- local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    -- local pFrame = sharedSpriteFrameCache:getSpriteFrame("net01x_0.png");
    -- local net = cc.Sprite:createWithSpriteFrame(pFrame);
    -- self:addChild(net);
    -- self.net = net;

    -- local texture = cc.Director:getInstance():getTextureCache():addImage("net01x_0.png");
    -- self:setTexture(texture);

    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    sharedSpriteFrameCache:addSpriteFrames("pao-zd.plist");

    local fileName = "wang"..self.paoLevel..".png";
    local pFrame = sharedSpriteFrameCache:getSpriteFrame(fileName);
    self:setSpriteFrame(pFrame);

    self:setScale(0.3);
    local sequence = transition.sequence(
        {
            cc.ScaleTo:create(0.2, 1.0),
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function() self:disappear();end)
        }
    )
    self:runAction(sequence);

    self:catchFish();

    -- local shape4 = display.newRect(cc.rect(0, 0, 10, 10),
    --     {fillColor = cc.c4f(1,0,0,1), borderColor = cc.c4f(0,1,0,1), borderWidth = 5});
    -- shape4:setOpacity(0.5);
    -- self:addChild(shape4);

    -- local sp = display.newSprite("btn_green.png");
    -- self:addChild(sp);

    if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
        audio.playSound("sound/net.mp3");
    end

end


function Bullet:catchFish()

    self.gameLayer:catchFishWithNet(self);

end

function Bullet:disappear()

    self:stopAllActions();
    self:removeFromParent();
    if self.net then
        self.net:setVisible(false);
    end
    self.database[ tostring(self) ] = nil;

end

--获取碰撞区域大小
function Bullet:getCollisionRect()

    local rect = {}
    rect.x, rect.y = self:getPosition()
    rect.width = 20
    rect.height = 20
    return rect
end


function Bullet:shootToFish()

    local scheduler = require("framework.scheduler");
    self.updateBulletScheduler = scheduler.scheduleGlobal(function()
        self:update()
    end, 0.3)

end

function Bullet:hitFish()

    if self.updateBulletScheduler then
        scheduler.unscheduleGlobal(self.updateBulletScheduler);
    end

end

function Bullet:update(dt)

    local valid = self.gameLayer:checkFishValid(self.lockFish);

    if valid then
        self:stopAllActions();
        local target = cc.p(self.lockFish:getPositionX(),self.lockFish:getPositionY());
        local realTarget = self:getParent():convertToNodeSpace(target);
        self:shootToPos(realTarget);
    else
        self:hitFish();
    end

    -- local ptFrom = cc.p(self:getPositionX(),self:getPositionY());
    -- local realTarget = cc.p(self.lockFish:getPositionX(),self.lockFish:getPositionY());

    -- local ccpDistance = math.sqrt( (ptFrom.x-realTarget.x)*(ptFrom.x-realTarget.x) + (ptFrom.y-realTarget.y)*(ptFrom.y-realTarget.y) );
    -- local speed = self.speed;
    -- local moveSec = ccpDistance / speed;

    -- local sequence = transition.sequence(
    --     {
    --         cc.MoveTo:create(moveSec, realTarget)
    --     }
    -- )
    -- self:runAction(sequence);


end


return Bullet;
