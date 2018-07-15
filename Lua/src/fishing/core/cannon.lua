-----------------------------------------------------------------------------
-- local Cannon = class("Cannon");
local Cannon = class( "Cannon", function() return display.newSprite("blank.png"); end )

function Cannon:ctor(container, database, seat, player)

    self.container = container;
    self.database = database;
    self.seat = seat;
    self.player = player;

    --炮台类型:和玩家vip绑定
    self.paoOption = self.player.userInfo.memberOrder+1

    --炮台等级(1.2.3.4)
    self.paoLevel = 1

    self:setDefaultData();
    self:createDefaultCannon();

end

function Cannon:setDefaultData()

    self.rotation = 0;
    self.lockfish = false;
    self.inCooldown = false;
    self.cooldownTime = 0.2;

end

function Cannon:createDefaultCannon()

    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    sharedSpriteFrameCache:addSpriteFrames("pao-zd.plist");

    local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."-l"..self.paoLevel..".png");
    local cannon = cc.Sprite:createWithSpriteFrame(pFrame);
    self:addChild(cannon);
    self.model = cannon;

    self.paokou_ani = self:getPaoKouAnimation()
    if self.paokou_ani then
        self.paokou_ani:setPosition(cc.p(cannon:getContentSize().width/2,cannon:getContentSize().height+12))
        cannon:addChild(self.paokou_ani)
        self.paokou_ani:getAnimation():playWithIndex(0)
    end
end

function Cannon:getLockFishPos(fish)

    if fish and fish:getParent() then
        return fish:getParent():convertToWorldSpace(cc.p(fish:getPositionX(), fish:getPositionY()));
    end

end

function Cannon:setFast(fast)
    if fast then
        self.cooldownTime = 0.1;
    else
        self.cooldownTime = 0.2;
    end
end

function Cannon:setPaoLevel(level)

    if self.paoLevel ~= level then
        
        self.paoLevel = level
        local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
        sharedSpriteFrameCache:addSpriteFrames("pao-zd.plist");
        local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."-l"..self.paoLevel..".png")
        self.model:setSpriteFrame(pFrame)

        if self.paokou_ani then
            self.paokou_ani:setPosition(cc.p(self.model:getContentSize().width/2,self.model:getContentSize().height+12))
        end

    end

end

function Cannon:setPaoOption(level)

    if self.paoOption ~= level then
        
        self.paoOption = level
        local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
        sharedSpriteFrameCache:addSpriteFrames("pao-zd.plist");
        local pFrame = sharedSpriteFrameCache:getSpriteFrame("pao"..self.paoOption.."-l"..self.paoLevel..".png")
        self.model:setSpriteFrame(pFrame)

        if self.paokou_ani then
            self.paokou_ani:setPosition(cc.p(self.model:getContentSize().width/2,self.model:getContentSize().height+12))
        end

    end

end

function Cannon:rotationAndFire(targetPt, myFire, cost, bSetLockFishSlow, withOutCD)
    withOutCD = withOutCD or false;
    local isFreshCD=true;
    if not withOutCD then
        if self.player.mainPlayer == true then

            if self.inCooldown == true then
                return false;
            else 
                self.inCooldown = true;
            end

        end
    else
        if self.inCooldown then
            isFreshCD=false;
        end
        self.inCooldown = true;

    end

    self:rotationAndFireRoot(targetPt, myFire, cost, bSetLockFishSlow, isFreshCD);

end

function Cannon:rotationAndFireRoot(targetPt, myFire, cost, bSetLockFishSlow ,isFreshCD)

    -- if self.player.mainPlayer == true then

    --     if self.inCooldown == true then
    --         return false;
    --     else 
    --         self.inCooldown = true;
    --     end

    -- end

    local lockFish = self.player.lockFish;
    if lockFish then
        targetPt = self:getLockFishPos(lockFish);
    end

    local potion = self:getParent():convertToNodeSpace(targetPt);


    --取得炮台的位置，再与ptTo连线构造三角形，便于下一步从炮台出发的角度计算
    local pos = cc.p(self:getPositionX(), self:getPositionY());
    local ptFrom = pos
    -- if myFire == true then
    --     if self.seat > 2 and potion.y >= ptFrom.y then self.inCooldown = false return true
    --     elseif self.seat < 3 and potion.y <= ptFrom.y then self.inCooldown = false return true end
    -- end
    --计算预备要转到的角度值 atan2f函数 返回 弧度值
    local angle =  math.atan((potion.x-ptFrom.x)/(potion.y-ptFrom.y)) / math.pi * 180;    
    if potion.y < 0 then
        angle = angle + 180;
    end

    --存储炮台准备转向的角度值（方向）
    self.rotation = angle;
    --计算从当前炮台的角度转向指定的方向经过的绝对角度值
    local absf_rotation = math.abs(self.rotation - self.model:getRotation());
    --计算转向需要的时间预设0.2ms转1弧度
    local duration = absf_rotation / 180.0 * 0.2;

    local fireAction = transition.sequence(
        {
            cc.RotateTo:create(duration, self.rotation),
            cc.DelayTime:create(0.05),
            cc.CallFunc:create(
                function()
                    self.paokou_ani:getAnimation():playWithIndex(0);
                    self:doFire(myFire, lockFish, cost, bSetLockFishSlow);
                    self.model:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.1, 1.1),
                            cc.ScaleTo:create(0.1, 1.0)
                        ))
                end),
        }
    )
    if isFreshCD then
        local sequence = transition.sequence(
        {
            fireAction,
            cc.DelayTime:create(self.cooldownTime),
            cc.CallFunc:create(function() self:cooldown();end),
        })

        self.model:runAction(sequence);
    else
        self.model:runAction(fireAction);
    end

    self.direction = targetPt;

end

function Cannon:cooldown()
    self.inCooldown = false;
end

function Cannon:getCoolDownState()
    return self.inCooldown
end

function Cannon:doFire(myFire, lockFish, cost, bSetLockFishSlow)

    local bullet = require("core.bullet").new(self.database,self.paoOption,self.paoLevel,self.player.userInfo.memberOrder,bSetLockFishSlow);


    local valid = self.database.parent:checkFishValid(lockFish);

    if valid then
        bullet.lockFish = lockFish;
    end


    self.container:addChild(bullet);

    local pos = cc.p(self:getPositionX()+60,self:getPositionY());
    local absolutePos = self:convertToWorldSpace(pos)
    local relaPos = self:getParent():getParent():convertToNodeSpace(absolutePos);
    bullet:setPosition(relaPos);
    bullet:shootTo(self.direction);
    
    self.database[ tostring(bullet) ] = bullet;


    if myFire then
        self.database.parent.myBulletCount=self.database.parent.myBulletCount+1;--用于子弹射击限制

        bullet.myFire = true;

        local angle = self.rotation
        if FLIP_FISH then angle = angle + 180 end

        -- print("Fire.....子弹id....", bullet.id)

        local lockFishID = -1;
        if lockFish then
            lockFishID = lockFish:getFishID();
        end

        FishInfo:sendUserFireRequest(self:getFireGunLevel(cost), bullet.id, angle, cost, lockFishID);

        GLOBAL_BULLET_ID = GLOBAL_BULLET_ID + 1;

        if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
            audio.playSound("sound/cannon.mp3");
        end
        
    end

end

function Cannon:getFireGunLevel(gunNumber)
    local bullet_kinds = 0
    if(gunNumber< FishInfo.gameConfig.bulletMultipleMin*10) then
        bullet_kinds = 0
    elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*100 then
         bullet_kinds = 1
    elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*1000 then
         bullet_kinds = 2
    elseif gunNumber< FishInfo.gameConfig.bulletMultipleMin*10000 then
         bullet_kinds = 3
    end
    return bullet_kinds;
end

function Cannon:getPaoKouAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("eff_paokou") == nil then
        manager:addArmatureFileInfo("effect/pao_kou/eff_paokou0.png","effect/pao_kou/eff_paokou0.plist","effect/pao_kou/eff_paokou.ExportJson")
    end
    local armature = ccs.Armature:create("eff_paokou")
    return armature;
end

return Cannon;