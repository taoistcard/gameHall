--
-- Author: zx
-- Date: 2015-04-14 14:59:40
--
local EffectFactory = class("EffectFactory")

function EffectFactory:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function EffectFactory:getInstance()
	if not self._EffectFactory then
		self._EffectFactory = EffectFactory.new()
		self:cacheFrames();
	end
	return self._EffectFactory;
end

function EffectFactory:cacheFrames()

    if cc.FileUtils:getInstance():isFileExist("effect/effect.plist") then
 		display.addSpriteFrames("effect/effect.plist", "effect/effect.png")
    end
    if cc.FileUtils:getInstance():isFileExist("effect/spring.plist") then
 		display.addSpriteFrames("effect/spring.plist", "effect/spring.png")
    end
    if cc.FileUtils:getInstance():isFileExist("effect/cardType.plist") then
 		display.addSpriteFrames("effect/cardType.plist", "effect/cardType.png")
    end
    if cc.FileUtils:getInstance():isFileExist("effect/zhaocaimao.plist") then
 		display.addSpriteFrames("effect/zhaocaimao.plist", "effect/zhaocaimao.png")
    end
    if cc.FileUtils:getInstance():isFileExist("effect/result.plist") then
 		display.addSpriteFrames("effect/result.plist", "effect/result.png")
    end
    if cc.FileUtils:getInstance():isFileExist("effect/liquan_drop0.plist") then
 		display.addSpriteFrames("effect/liquan_drop0.plist", "effect/liquan_drop0.png")
    end
    if cc.FileUtils:getInstance():isFileExist("effect/liquan-tx.plist") then
 		display.addSpriteFrames("effect/liquan-tx.plist", "effect/liquan-tx.png")
    end

end

function EffectFactory:getEffectByName(name, _interval, _begin, _end)
	_begin = _begin or 1
	_end = _end or 6
	_interval = _interval or 0.1
	local frames = display.newFrames(name .. "%d.png", _begin, _end)
	return display.newAnimation(frames, _interval)
end

function EffectFactory:getAnimationSuccess()
	display.addSpriteFrames("effect/result.plist", "effect/result.png")
	local frames = display.newFrames("animationSuccess%d.png", 1, 3)
	return display.newAnimation(frames, 0.1)
end
function EffectFactory:getAnimationFailure()
	display.addSpriteFrames("effect/result.plist", "effect/result.png")
	local frames = display.newFrames("animationFailure%d.png", 1, 6)
	return display.newAnimation(frames, 0.1)
end


function EffectFactory:getAnimationByName(name)
	if name == "bianshen" then
		return self:getAnimation1()

	elseif name == "paixing" then
		return self:getAnimation2()
	elseif name == "smoke" then
		return self:getAnimationSmoke()
	elseif name == "bomb" then
		return self:getAnimationBomb()
	elseif name == "rocket" then
		return self:getAnimationRocket()
	elseif name == "airplane" then
		return self:getAnimationAirplane()
	elseif name == "wing" then
		return self:getAnimationWing()
	elseif name == "liandui" then
		return self:getAnimationLiandui()
	elseif name == "shunzi" then
		return self:getAnimationShunzi()		
	elseif name == "wangzha" then
		return self:getAnimation3()

	elseif name == "zhadan" then
		return self:getAnimation4()

	elseif name == "btn_effect" then
		return self:getAnimation5()

	elseif name == "jingbao" then
		return self:getAnimation6()

	elseif name == "tuoguan" then
		return self:getAnimation7()
	end
end

function EffectFactory:getAnimationSpring()
	display.addSpriteFrames("effect/spring.plist", "effect/spring.png")
	local frames = display.newFrames("spring%d.png", 1, 8)
	return display.newAnimation(frames, 0.8/8)
end
function EffectFactory:getAnimationSmoke()
	local frames = display.newFrames("smoke%d.png", 1, 4)
	return display.newAnimation(frames, 0.1)
end
function EffectFactory:getAnimationBomb()
	display.addSpriteFrames("effect/cardType.plist", "effect/cardType.png")
	local frames = display.newFrames("bomb%d.png", 1, 7)
	return display.newAnimation(frames, 0.8/7)
end
function EffectFactory:getAnimationRocket()
	display.addSpriteFrames("effect/cardType.plist", "effect/cardType.png")	
	local frames = display.newFrames("rocket%d.png", 1, 11)
	return display.newAnimation(frames, 1.0/11)
end
function EffectFactory:getAnimationAirplane()
	display.addSpriteFrames("effect/cardType.plist", "effect/cardType.png")	
	local frames = display.newFrames("airplane%d.png", 1, 2)
	return display.newAnimation(frames, 0.8/2)
end
function EffectFactory:getAnimationWing()
	display.addSpriteFrames("effect/cardType.plist", "effect/cardType.png")	
	local frames = display.newFrames("wing%d.png", 1, 2)
	return display.newAnimation(frames, 0.8/2)
end
function EffectFactory:getAnimationLiandui()
	display.addSpriteFrames("effect/cardType.plist", "effect/cardType.png")	
	local frames = display.newFrames("liandui%d.png", 1, 6)
	return display.newAnimation(frames, 0.8/6)
end
function EffectFactory:getAnimationShunzi()
	display.addSpriteFrames("effect/cardType.plist", "effect/cardType.png")	
	local frames = display.newFrames("shunzi%d.png", 1, 7)
	return display.newAnimation(frames, 0.8/7)
end
function EffectFactory:getAnimationTask()
	display.addSpriteFrames("effect/task.plist", "effect/task.png")
	local frames = display.newFrames("rw-icon-tx%d.png", 1, 12)
	return display.newAnimation(frames, 0.1)
end
function EffectFactory:getAnimationAddGold()
	display.addSpriteFrames("effect/addGold.plist","effect/addGold.png")
	local frames = display.newFrames("addGold%d.png", 1, 3)
	return display.newAnimation(frames, 0.1)
end
function EffectFactory:getAnimation1()
	local frameName = "Animation_RocketCloud1.png"
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
	if not frame then
		display.addSpriteFrames("effect/effect.plist", "effect/effect.png")
		print("display.newFrames() - invalid frame, name %s", tostring(frameName))
		-- return nil
	end
	local frames = display.newFrames("Animation_RocketCloud%d.png", 1, 9)
	return display.newAnimation(frames, 0.1)
end

function EffectFactory:getAnimation2()
	local frameName = "px1.png"
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
	if not frame then
		display.addSpriteFrames("effect/effect.plist", "effect/effect.png")
		print("display.newFrames() - invalid frame, name %s", tostring(frameName))
		-- return nil
	end
	local frames = display.newFrames("px%d.png", 1, 9)
	return display.newAnimation(frames, 0.1)
end

function EffectFactory:getAnimation3()
	local frameName = "wz1.png"
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
	if not frame then
		display.addSpriteFrames("effect/effect.plist", "effect/effect.png")
		print("display.newFrames() - invalid frame, name %s", tostring(frameName))
	end
	local frames = display.newFrames("wz%d.png", 1, 11)
	return display.newAnimation(frames, 0.1)
end

function EffectFactory:getAnimation4()
	local frameName = "zd1.png"
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
	if not frame then
		display.addSpriteFrames("effect/effect.plist", "effect/effect.png")
		print("display.newFrames() - invalid frame, name %s", tostring(frameName))
	end
	local frames = display.newFrames("zd%d.png", 1, 8)
	return display.newAnimation(frames, 0.1)
end

function EffectFactory:getAnimation5()
	local frameName = "btn_effect1.png"
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
	if not frame then
		display.addSpriteFrames("effect/effect.plist", "effect/effect.png")
		print("display.newFrames() - invalid frame, name %s", tostring(frameName))
	end
	local frames = display.newFrames("btn_effect%d.png", 1, 14)
	return display.newAnimation(frames, 0.1)
end

function EffectFactory:getAnimation6()
	local frameName = "jbd1.png"
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
	if not frame then
		display.addSpriteFrames("effect/effect.plist", "effect/effect.png")
		print("display.newFrames() - invalid frame, name %s", tostring(frameName))
	end
	local frames = display.newFrames("jbd%d.png", 1, 2)
	return display.newAnimation(frames, 0.2)
end

function EffectFactory:getAnimation7()
	local frameName = "tuoguan1.png"
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
	if not frame then
		display.addSpriteFrames("effect/effect.plist", "effect/effect.png")
		print("display.newFrames() - invalid frame, name %s", tostring(frameName))
	end
	local frames = display.newFrames("tuoguan%d.png", 1, 3)
	table.insert(frames, frames[1])
	return display.newAnimation(frames, 0.2)
end
function EffectFactory:getMarryButtonAnimation()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo("effect/ddz_jiehunqulou0.png","effect/ddz_jiehunqulou0.plist","effect/ddz_jiehunqulou.ExportJson")
	local armature = ccs.Armature:create("ddz_jiehunqulou")
	armature:getAnimation():playWithIndex(0)
	return armature;
end
function EffectFactory:getJieHunAnimation()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo("effect/jiehun_aixin0.png","effect/jiehun_aixin0.plist","effect/jiehun_aixin.ExportJson")
	local armature = ccs.Armature:create("jiehun_aixin")
	armature:getAnimation():playWithIndex(0)
	return armature;
end
--@param type  0别人  1自己
function EffectFactory:getJieSuanAnimation(type)
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo("effect/sanren_jiesuan0.png","effect/sanren_jiesuan0.plist","effect/sanren_jiesuan.ExportJson")
	local armature = ccs.Armature:create("sanren_jiesuan")
	armature:getAnimation():playWithIndex(type)
	return armature;
end
function EffectFactory:getCouponLightAnimation()
	display.addSpriteFrames("effect/liquan-tx.plist", "effect/liquan-tx.png")
	local frames = display.newFrames("liquan-tx%d.png", 1, 6)
	return display.newAnimation(frames, 0.2)
end
function EffectFactory:getShouChongLiBaoAnimation()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo("effect/shouchonglibao0.png","effect/shouchonglibao0.plist","effect/shouchonglibao.ExportJson")
	local armature = ccs.Armature:create("shouchonglibao")
	armature:getAnimation():playWithIndex(0)
	return armature;
end
function EffectFactory:getXinShouLiBaoAnimation()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo("effect/xinshoulibao0.png","effect/xinshoulibao0.plist","effect/xinshoulibao.ExportJson")
	local armature = ccs.Armature:create("xinshoulibao")
	armature:getAnimation():playWithIndex(0)
	return armature;
end
function EffectFactory:getCouponEffect()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:removeArmatureFileInfo("effect/liquan_drop.ExportJson")
	manager:addArmatureFileInfo("effect/liquan_drop.ExportJson")
	local armature = ccs.Armature:create("liquan_drop")
	armature:getAnimation():playWithIndex(0)
	return armature;
end

function EffectFactory:getBeanAnimation()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:removeArmatureFileInfo("effect/dou_texiao.ExportJson")
	manager:addArmatureFileInfo("effect/dou_texiao.ExportJson")
	local armature = ccs.Armature:create("dou_texiao")
	armature:getAnimation():playWithIndex(0)
	return armature;
end

function EffectFactory:getGoldAnimation()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:removeArmatureFileInfo("effect/jinbi_texiao.ExportJson")
	manager:addArmatureFileInfo("effect/jinbi_texiao.ExportJson")
	local armature = ccs.Armature:create("jinbi_texiao")
	armature:getAnimation():playWithIndex(0)
	return armature;
end

function EffectFactory:getCommodityAnimation()
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:removeArmatureFileInfo("effect/shangpin_texiao.ExportJson")
	manager:addArmatureFileInfo("effect/shangpin_texiao.ExportJson")
	local armature = ccs.Armature:create("shangpin_texiao")
	local count = armature:getAnimation():getMovementCount();
	local start = math.random(0,count-1);
	armature:getAnimation():playWithIndex(start);
	return armature;
end

function EffectFactory:getGameIconAnimation(index)

	local filenames = {"errenchang","qiangdizhu","meinvhudong"};

	local filename = filenames[index];

	local manager = ccs.ArmatureDataManager:getInstance();
	manager:removeArmatureFileInfo("effect/"..filename..".ExportJson");
	manager:addArmatureFileInfo("effect/"..filename..".ExportJson");
	local armature = ccs.Armature:create(filename);
	armature:getAnimation():playWithIndex(0);
	return armature;
end

function EffectFactory:getGiftArmature(giftIndex)
	local name = customGift[giftIndex].giftPrefix

	local filePath = "cocosAnimate/"..name.."/"..name..".ExportJson"
    local imagePath = "cocosAnimate/"..name.."/"..name.."0.png"
    local plistPath = "cocosAnimate/"..name.."/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
	return armature;
end

function EffectFactory:shakeScreen(time)

    local scheduler = require("framework.scheduler")
    local runningScene = display.getRunningScene();
    local x,y = runningScene:getPosition()
    local v = 0
    local shakeHandle = nil
    local function tickRefresh(dt)
        
        local vv = math.pow(-1, v)*2;
        runningScene:setPosition(x+vv, y+vv)
        v = v+1
        
        time = time - dt
        if time <= 0 then
            scheduler.unscheduleGlobal(shakeHandle)
            runningScene:setPosition(x, y)
        end
    end 

    shakeHandle = scheduler.scheduleGlobal(tickRefresh, 0.02) -- 间隔一定时间调用
end

function EffectFactory:getVipAnchorMMArmature()
	local name = "zhubo_mm"

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

function EffectFactory:getVipJiesuanArmature()
	local name = "vip_jiesuan"

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

function EffectFactory:getHallBgArmature()
	local name = "ddz_dating"

	local filePath = "effect/ddz_dating/"..name..".ExportJson"
	local imagePath = "effect/ddz_dating/"..name.."0.png"
	local plistPath = "effect/ddz_dating/"..name.."0.plist"

	local manager = ccs.ArmatureDataManager:getInstance()
	if manager:getAnimationData(name) == nil then
		manager:addArmatureFileInfo(imagePath, plistPath, filePath)
	end
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;

end
-----------------------炸金花------------------------------------------------------------------------------------------------------------------------------
--@param type  0别人  1自己
function EffectFactory:getCompareCardAnimation(type)
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo("effect/compareCard/eff_vs0.png","effect/compareCard/eff_vs0.plist","effect/compareCard/eff_vs.ExportJson")
	local armature = ccs.Armature:create("eff_vs")
	armature:getAnimation():playWithIndex(type)
	return armature;
end
--typeindex:0  typeindex:1
function EffectFactory:getGirlsArmature(name, typeindex)
	--local name = "ani_girl_1"
	typeindex = typeindex or 0

	local filePath = "effect/girl/"..name..".ExportJson"
	local imagePath = "effect/girl/"..name.."0.png"
	local plistPath = "effect/girl/"..name.."0.plist"

	local manager = ccs.ArmatureDataManager:getInstance()
	if manager:getAnimationData(name) == nil then
		manager:addArmatureFileInfo(imagePath, plistPath, filePath)
	end
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(typeindex)
	return armature;
end
function EffectFactory:getGirlInGameArmature(name)
	local filePath = "effect/"..name.."/"..name..".ExportJson"
	local imagePath = "effect/"..name.."/"..name.."0.png"
	local plistPath = "effect/"..name.."/"..name.."0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
end
function EffectFactory:getShowCardArmature()
	local name = "jinhua_kaipai"
	local filePath = "effect/"..name.."/"..name..".ExportJson"
	local imagePath = "effect/"..name.."/"..name.."0.png"
	local plistPath = "effect/"..name.."/"..name.."0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
end
function EffectFactory:getCompareFailureArmature()
	local name = "eff_shibai"
	local filePath = "effect/"..name.."/"..name..".ExportJson"
	local imagePath = "effect/"..name.."/"..name.."0.png"
	local plistPath = "effect/"..name.."/"..name.."0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
end
--生成一个反复发光的星星
 function EffectFactory:createOneBreathStar(pox, poy, scale, randarr)
 	local star = cc.Sprite:create("hall/login/light1.png");
    star:align(display.CENTER, pox, poy);
    if scale then star:setScale(scale) end
    local action = cc.RepeatForever:create(cc.Sequence:create(
                                            cc.FadeOut:create(randarr[1]),
                                            cc.FadeIn:create(randarr[2]),
                                            cc.DelayTime:create(randarr[3])))
    star:runAction(action)
    return star
 end
 --商城动画一
 function EffectFactory:createShopTitleEffect()
 	local name = "ani_store"
	local filePath = "hall/shop/ani_store.ExportJson"
	local imagePath = "hall/shop/ani_store0.png"
	local plistPath = "hall/shop/ani_store0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
 end

 --商城筹码动画
 function EffectFactory:ceateChouMaEffect(index)
 	if index == nil or index > 3 then index = 0 end
 	local name = "eff_chouma"
	local filePath = "hall/shop/eff_chouma.ExportJson"
	local imagePath = "hall/shop/eff_chouma0.png"
	local plistPath = "hall/shop/eff_chouma0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(index)
	return armature;
 end
   --比赛场弹窗，跑马灯
 function EffectFactory:getPaoMaDeng()
 	local name = "eff_tanchuang_deng"
	local filePath = "effect/eff_tanchuang_deng/eff_tanchuang_deng.ExportJson"
	local imagePath = "effect/eff_tanchuang_deng/eff_tanchuang_deng0.png"
	local plistPath = "effect/eff_tanchuang_deng/eff_tanchuang_deng0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
 end
  function EffectFactory:getChangeCell1()
 	local name = "eff_tanchuang_zhu"
	local filePath = "effect/eff_tanchuang_zhu/eff_tanchuang_zhu.ExportJson"
	local imagePath = "effect/eff_tanchuang_zhu/eff_tanchuang_zhu0.png"
	local plistPath = "effect/eff_tanchuang_zhu/eff_tanchuang_zhu0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
 end
  function EffectFactory:getChangeCell2()
 	local name = "eff_zhu_guang"
	local filePath = "effect/eff_zhu_guang/eff_zhu_guang.ExportJson"
	local imagePath = "effect/eff_zhu_guang/eff_zhu_guang0.png"
	local plistPath = "effect/eff_zhu_guang/eff_zhu_guang0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
 end

function EffectFactory:getChouMaAnimation()
 	local name = "eff_baochouma"
	local filePath = "effect/eff_chouma/eff_baochouma.ExportJson"
	local imagePath = "effect/eff_chouma/eff_baochouma0.png"
	local plistPath = "effect/eff_chouma/eff_baochouma0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
end

function EffectFactory:getPaoMaDengXiaoAni()
 	local name = "eff_paomadeng_xiao"
	local filePath = "effect/eff_paomadeng_xiao/eff_paomadeng_xiao.ExportJson"
	local imagePath = "effect/eff_paomadeng_xiao/eff_paomadeng_xiao0.png"
	local plistPath = "effect/eff_paomadeng_xiao/eff_paomadeng_xiao0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(0)
	return armature;
end
function EffectFactory:getStartBet(index)
 	local name = "eff_kaishixiazhu"
	local filePath = "effect/eff_kaishixiazhu/eff_kaishixiazhu.ExportJson"
	local imagePath = "effect/eff_kaishixiazhu/eff_kaishixiazhu0.png"
	local plistPath = "effect/eff_kaishixiazhu/eff_kaishixiazhu0.plist"
	local manager = ccs.ArmatureDataManager:getInstance()
	manager:addArmatureFileInfo(imagePath,plistPath,filePath)
	local armature = ccs.Armature:create(name)
	armature:getAnimation():playWithIndex(index)
	return armature;
end
return EffectFactory
