--=======================================
-- Game Development With Lua
-- by Dragon
-- (c) copyright 2014
-- All Rights Reserved.
--=======================================
-- filename:  DateModel.lua
-- author:    zhaxun
-- created:   2014-5-20
-- descrip:   In game play screen and interfaces
--=======================================

local DateModel = class( "DateModel" )

function DateModel:ctor()

    self._invalide = false
    self.banker = -1;
    self.robTimes = 0
    self.farmerFirst = 0
    self.isFarmer = true--默认是农民，（显示地主角标的处理）
    self.selectRoomInfo = nil
    self.dipaiType = -1
    self.dipaiPlus = -1
    self.rocket = false
    self.difen = 0
    self.bombCount = 0
    self.robPlus = 1
    self.spring = false
end

--更新卡牌信息
function DateModel:refreshCards(mycards, nextcards, precards)
    self._invalide = true

    if mycards then
        self.cards = mycards
    end

    if nextCards then
        self.nextCards = nextcards
    end

    if preCards then
        self.preCards = nextcards
    end
end
function DateModel:setSelectRoomInfo(kindID,section,roomIndex)
    self.selectRoomInfo = {kindID,section,roomIndex}
end
-- 设置地主
function DateModel:setBanker(nBanker)
	self.banker = nBanker

end
function DateModel:setRocket(isRocket)
    self.rocket = isRocket
end
function DateModel:getRocket()
    return self.rocket
end
function DateModel:refreshDiPai(dipai)
    self.dipai = dipai
end
--@para robTimes 抢地主次数
function DateModel:setRobTimes( robTimes )
    self.robTimes = robTimes
end
--@para farmerFirst 1让先0不让
function DateModel:setFarmerFirst(farmerFirst)
    self.farmerFirst = farmerFirst
end
--底牌类型
function DateModel:setDipaiType( dipaiType )
    self.dipaiType = dipaiType
end
function DateModel:getDipaiType()
    return self.dipaiType
end
--底牌倍数
function DateModel:setDipaiPlus( dipaiPlus )
    self.dipaiPlus = dipaiPlus
end
function DateModel:getDipaiPlus()
    return self.dipaiPlus
end
--设置底分
function DateModel:setDiFen(difen)
    self.difen = difen
end
function DateModel:getDiFen()
    return self.difen
end
--炸弹次数（不包过王炸）
function DateModel:setBombCount(count)
    self.bombCount = count
end
function DateModel:getBombCount()
    return self.bombCount;
end
--抢地主次数的倍数
function DateModel:setRobPlus(plus)
    self.robPlus = plus
end
function DateModel:getRobPlus()
    return self.robPlus
end
--春天
function DateModel:setSpring(isSpring)
    self.spring = isSpring
end
function DateModel:getSpring()
    return self.spring
end
function DateModel:setIsFarmer( isFarmer )
    print("isFarmer,",isFarmer==true)
    self.isFarmer = isFarmer
end
function DateModel:reset()
	self._invalide= false
	self.cards = nil
    self.dipai = nil
    self.banker = -1;
    self.isTuoGuan = nil
    self.playerName = nil
    self.nextCards = nil
    self.preCards = nil
    self.robTimes = nil
    self.farmerFirst = nil
    self.isFarmer = nil
    self.selectRoomInfo = nil
    self.rocket = false
    self.difen = 0
    self.bombCount = 0
    self.robPlus = 1
    self.spring = false
end

function DateModel:cachePlayerInfo()
    self.playerName = {}

    
    for i=1,2 do
        local userInfo = DataManager:getUserInfoInMyTableByChairID(i)
        self.playerName[i]= userInfo.nickName
    end
end

function DateModel:tuoGuan(bTG)
    self.isTuoGuan = bTG
end

function DateModel:checkTuoGuan(chairID)
    return self.isTuoGuan and self.isTuoGuan[chairID] == 1 
end

function DateModel:isValide()
    return  self._invalide
end

function DateModel:createTestData()
    
    self._invalide = true
    local dipai = {}
    local cards = {}
    for i=1,3 do
        local ncards={}
        for i=1,17 do
            local kind = math.random(0,3);
            local num = math.random(1,13);
            table.insert(ncards,kind*0x10+num)
        end
        cards[i] = ncards

        local kind = math.random(0,3);
        local num = math.random(1,13);
        table.insert(dipai,kind*0x10+num)
    end
    cards[4] = dipai
    self.cards = cards
    self.banker = 1
    
end

return DateModel