local GameResultLayer = class("GameResultLayer", function() return display.newLayer(); end );

function GameResultLayer:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    -- 蒙板
    local maskLayer = ccui.ImageView:create("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    self:addChild(maskLayer)
    local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
    maskImg:setPosition(cc.p(757, winSize.height / 2));
    maskLayer:addChild(maskImg)

    self:createUI()
end

function GameResultLayer:createUI()
    -- 统一ui
    local resultTxtLayout = ccui.Layout:create()
    resultTxtLayout:setContentSize(cc.size(270,76))
    resultTxtLayout:setName("ResultTxtLayout")
    resultTxtLayout:setPosition(cc.p(660,280))
    self:addChild(resultTxtLayout)
    --背景光效
    local resultWinEffect = ccui.ImageView:create()
    resultWinEffect:setName("ResultWinEffect")
    resultWinEffect:loadTexture("landlordVideo/gr_bg_effect.png")
    resultWinEffect:setAnchorPoint(cc.p(0.5,0))
    resultWinEffect:setPosition(cc.p(135,0))
    resultTxtLayout:addChild(resultWinEffect)
    --输赢金币背景
    local resultTxtBg = ccui.ImageView:create("landlordVideo/gr_bg.png")
    resultTxtBg:setScale9Enabled(true)
    resultTxtBg:setCapInsets(cc.rect(50,35,1,1))
    resultTxtBg:setContentSize(cc.size(270,76))
    resultTxtBg:setPosition(cc.p(135,38))
    resultTxtLayout:addChild(resultTxtBg)
    --文字
    local bigGoldImg = ccui.ImageView:create()
    bigGoldImg:loadTexture("common/gold.png")
    bigGoldImg:setPosition(cc.p(50,35))
    resultTxtLayout:addChild(bigGoldImg)
    local resultScoreLabel = display.newBMFontLabel({
        text = "2.9万",
        font = "fonts/jinbiSZ.fnt",
        x = 90,
        y = 35,
    })
    resultScoreLabel:setAnchorPoint(cc.p(0,0.5))
    resultScoreLabel:setName("ResultScoreLabel")
    resultTxtLayout:addChild(resultScoreLabel)
    local resultWinText = ccui.ImageView:create()
    resultWinText:setName("ResultWinText")
    resultWinText:loadTexture("landlordVideo/gr_draw.png")
    resultWinText:setPosition(cc.p(135,140))
    resultTxtLayout:addChild(resultWinText)
    --粒子特效
    local particle = cc.ParticleSystemQuad:create("effect/shipinwin_lizi.plist")
    particle:setPosition(cc.p(135,38))
    resultTxtLayout:addChild(particle)
    --动画
    local armature = self:getResultArmature(1)
    if armature then
        armature:setPosition(cc.p(930,290))
        self:addChild(armature)
        armature:getAnimation():playWithIndex(0)
    end
end

function GameResultLayer:showGameResult(curGameResult,curUserScore)
    self:show()
    local txtPos = {
        {x=785,y=280},
        {x=660,y=280},
        {x=550,y=280}
    }
    local armaturePos = {
        {x=665,y=290},
        {x=930,y=290},
        {x=930,y=290}
    }
    local winTxtImg = {
        "landlordVideo/gr_lord_win.png",
        "landlordVideo/gr_draw.png",
        "landlordVideo/gr_farmer_win.png"
    }
    local resultTxtLayout = self:getChildByName("ResultTxtLayout")
    resultTxtLayout:setPosition(cc.p(txtPos[curGameResult+1].x,txtPos[curGameResult+1].y))

    local resultScoreLabel = resultTxtLayout:getChildByName("ResultScoreLabel")
    local resultWinEffect = resultTxtLayout:getChildByName("ResultWinEffect")
    local resultScoreValue = ""
    if curUserScore >= 0 then
        resultScoreLabel:setBMFontFilePath("fonts/jinbiSZ.fnt")
        resultScoreValue = "+"..FormatDigitToString(curUserScore, 1)
        resultWinEffect:setVisible(false)
        if curUserScore ~= 0 then
            resultWinEffect:setVisible(true)
            SoundManager.playSound("sound/Hundred_Earn.mp3")
        end
    else
        resultScoreLabel:setBMFontFilePath("fonts/SBshuzi.fnt")
        resultScoreValue = FormatDigitToString(curUserScore, 1)
        SoundManager.playSound("sound/Hundred_Lost.mp3")
        resultWinEffect:setVisible(false)
    end
    resultScoreLabel:setString(resultScoreValue)

    local resultWinText = resultTxtLayout:getChildByName("ResultWinText")
    resultWinText:loadTexture(winTxtImg[curGameResult+1])

    local tempArmature = self:getChildByName("ResultArmature")
    if tempArmature ~= nil then
        tempArmature:removeFromParent()
        tempArmature = nil
    end
    local armature = self:getResultArmature(curGameResult)
    if armature then
        armature:setName("ResultArmature")
        armature:setPosition(cc.p(armaturePos[curGameResult+1].x,armaturePos[curGameResult+1].y))
        self:addChild(armature)
        armature:getAnimation():playWithIndex(0)
    end
end

function GameResultLayer:getResultArmature(curGameResult)
    local name = nil
    if curGameResult == 0 then --地主
        name = "dizhu_shengli"
    elseif curGameResult == 2 then --农民
        name = "nongmin_shengli"
    end
    if name == nil then
        return nil
    end

    local filePath = "effect/"..name..".ExportJson"
    local imagePath = "effect/"..name.."0.png"
    local plistPath = "effect/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end

function GameResultLayer:hideGameResult()
    self:hide()
end

return GameResultLayer
