local CustomProgressTimer = class("CustomProgressTimer",function()return ccui.Layout:create() end)
function CustomProgressTimer:ctor()
    self:setContentSize(cc.size(136,136))
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:createUI()
end
CustomProgressTimer.rNow = 0
CustomProgressTimer.gNow = 0
function CustomProgressTimer:createUI()
    local filePre = "customProgressTimer/"
    local pos = cc.p(136/2,136/2)
    local radius = 136/2
    local pi = 3.14159265358979323846264338327950288
    local boxWidth = radius*math.sin(pi/4)*2
    -- local deltaColor = (255*(leftTime)/maxTime)/(leftTime/intervalTime)
    -- print("boxWidth",boxWidth,"math.sin(3.14/4)",math.sin(3.14/4),"deltaColor",deltaColor,_rStart,_gStart)
    local box = ccui.Layout:create()
    box:setContentSize(cc.size(boxWidth,boxWidth))
    -- box:setBackGroundColorType(1)
    -- box:setBackGroundColor(cc.c3b(255,100,0))
    box:setAnchorPoint(cc.p(0.5,0.5))
    box:setPosition(pos)
    -- box:setRotation(-45+360*(maxTime-leftTime)/maxTime)
    self:addChild(box,1)
    self.box = box
    local texture2d = cc.Director:getInstance():getTextureCache():addImage(filePre.."lizi/lizi_guangdian.png");
    local light = cc.ParticleSystemQuad:create(filePre.."lizi/lizi_guangdian_1.plist");
    light:setTexture(texture2d);
    light:setPosition(boxWidth,boxWidth);
    light:stopSystem()
    self.light = light
    light:scale(1.5)
    box:addChild(light)



    
    self.pp = cc.Sprite:create(filePre.."baiyuan.png")
    -- self.pp:setColor(cc.c3b(_rStart, _gStart, 0))
    -- self.pp:setOpacity(255*70/100)

    local myProgressTimer = cc.ProgressTimer:create(self.pp)
    myProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)--PROGRESS_TIMER_TYPE_BAR
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    myProgressTimer:setMidpoint(cc.p(0.5, 0.5))
    -- myProgressTimer:setMidpoint(cc.p(0, 0))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    -- myProgressTimer:setReverseDirection(true)
    myProgressTimer:setPosition(pos)
    self:addChild(myProgressTimer)
    self.myProgressTimer = myProgressTimer
end
function CustomProgressTimer:updateColor(leftTime,intervalTime,maxTime,deltaColor)
    local _r = self.rNow+deltaColor
    local _g = self.gNow-deltaColor
    local _b = 0

    -- print("_rStart=",rNow,"gNow=",gNow,_r,_g)
    self.rNow = _r
    self.gNow = _g
    self.pp:setColor(cc.c3b(_r, _g, 0))
end
function CustomProgressTimer:test()
    -- body
    self.rNow = self.rNow+1
    print("rNow",self.rNow)
     self.light:resetSystem()
     self.light:stopSystem()
end
--停止所有动画和粒子效果
function CustomProgressTimer:stop()
    self:stopAllActions()
    self.box:stopAllActions()
    self.myProgressTimer:stopAllActions()
    self.light:resetSystem()
    self.light:stopSystem()
end
function CustomProgressTimer:showByLeftTime(lefttime,maxtime)
    self:stop()
    local filePre = ""
    local radius = 136/2
    local boxWidth = radius*math.sin(3.14/4)*2
    local maxTime = maxtime
    local leftTime = lefttime
    local intervalTime = 0.1
    local deltaColor = (255*(leftTime)/maxTime)/(leftTime/intervalTime)
    local  _rStart = 0+255*(maxTime-leftTime)/maxTime
    local  _gStart = 255-255*(maxTime-leftTime)/maxTime
    self.rNow = _rStart
    self.gNow = _gStart
    -- print("rNow",self.rNow,"gNow",self.gNow,"maxTime",maxTime,"leftTime",leftTime,"deltaColor",deltaColor)
    self.box:setRotation(-45+360*(maxTime-leftTime)/maxTime)
    local rotateBy = cc.RotateBy:create(leftTime, 360-360*(maxTime-leftTime)/maxTime)
    self.box:runAction(rotateBy)
    self.pp:setColor(cc.c3b(_rStart, _gStart, 0))
    -- self.pp:setOpacity(255*70/100)

    local seq = cc.Sequence:create({
        cc.DelayTime:create(intervalTime),
        cc.CallFunc:create(function ()
            self:updateColor(leftTime,intervalTime,maxTime,deltaColor)
        end)
    })
    local action = cc.Repeat:create(seq,leftTime/intervalTime)
    self:runAction(action)
    if self.light then
        self.light:setDuration(lefttime)
        self.light:resetSystem()
   end
    


    self.myProgressTimer:runAction(cc.ProgressFromTo:create(leftTime,100*(maxTime-leftTime)/maxTime,100))
end

return CustomProgressTimer