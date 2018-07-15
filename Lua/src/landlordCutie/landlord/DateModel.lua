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
--火箭
function DateModel:setRocket(isRocket)
    self.rocket = isRocket
end
function DateModel:getRocket()
    return self.rocket
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
-- 设置地主
function DateModel:setBanker(nBanker)
	self.banker = nBanker

end

function DateModel:refreshDiPai(dipai)
    self.dipai = dipai
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
    self.rocket = false
    self.difen = 0
    self.bombCount = 0
    self.robPlus = 1
    self.spring = false
end

function DateModel:cachePlayerInfo()
    self.playerName = {}

    
    for i=1,3 do
        local userInfo = DataManager:getUserInfoInMyTableByChairID(i)
        if userInfo then
            self.playerName[i]= userInfo.nickName
        else
            print("DateModel:cachePlayerInfo" .. "用户" .. i .."信息没有找到!")
        end
    end
end

function DateModel:tuoGuan(bTG)
    self.isTuoGuan = bTG
    print("托管信息：", bTG[1],bTG[2],bTG[3])
end

function DateModel:isValide()
    return  self._invalide
end

function DateModel:checkTuoGuan(chairID)
    return self.isTuoGuan and self.isTuoGuan[chairID] == 1 
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