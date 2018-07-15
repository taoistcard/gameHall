--
-- Author: <zhaxun>
-- Date: 2015-05-21 14:43:15
--
--[[
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",
]]
local cardInfo = {
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",  [0x0E] = "小王",  [0x0F] = "大王",
}

local CardInfo = {
	0x03,0x13,0x23,0x33,
	0x04,0x14,0x24,0x34,
	0x05,0x15,0x25,0x35,
	0x06,0x16,0x26,0x36,
	0x07,0x17,0x27,0x37,
	0x08,0x18,0x28,0x38,
	0x09,0x19,0x29,0x39,
	0x0A,0x1A,0x2A,0x3A,
	0x0B,0x1B,0x2B,0x3B,
	0x0C,0x1C,0x2C,0x3C,
	0x0D,0x1D,0x2D,0x3D,
	0x01,0x11,0x21,0x31,
	0x02,0x12,0x22,0x32,
	0x0E,0x4E,
	0x0F,0x4F,
}

local CardIndex = {}

SORT_TYPE = {
	ST_DESC = 1,	--降序
	ST_ASC = 2,		--升序
	ST_CUSTOM = 3, 	--自定义
}

CARDS_TYPE = {
	CT_0 = 0,--无效
	CT_1 = 1,--单张
	CT_2 = 2,--一对
	CT_3 = 3,--三张
	CT_4 = 4,--四炸
	CT_5 = 5,--王炸

	CT_1S = 6,--单顺
	CT_2S = 7,--双顺
	CT_3S = 8,--三顺

	CT_3S1 = 9,--三带一
	CT_3S2 = 10,--三带一对
	CT_3S3 = 11,--飞机
	CT_4S1 = 12,--四带2张
	CT_4S2 = 13, --／四带2对
	CT_3S4 = 14 --飞机翅膀
}


GameLogic = {};
local isDebug = false

function GameLogic.debug2(handCards, indexes, desc)

	if isDebug and indexes then
		print("_________________" .. desc .. "______________________")
		for k,v in ipairs(indexes) do
			print("_______________index =" .. k .."________________________")
			for _k,_v in ipairs(v) do
				print(cardInfo[handCards[_v]])
			end
		end
		print("_______________________________________")
	end
end

function GameLogic.debug(cards, desc)
	if isDebug then
		print("_________________" .. desc .. "______________________")
		for k,v in ipairs(cards) do
			print(cardInfo[v])
		end
		print("_______________________________________")
	end
end

function GameLogic.init()
	for k,v in ipairs(CardInfo) do
		CardIndex[v] = k;
	end
end

function GameLogic.tableContainValue(t,v)
	for _k,_v in ipairs(t) do
		if _v == v then
			return true
		end
	end
	return false
end

function GameLogic.tableContainKey(t,k)
	for _k,_v in ipairs(t) do
		if _k == k then
			return true
		end
	end
	return false
end

function GameLogic.mergeTable(src,dest)
	for k,v in ipairs(dest) do
		table.insert(src,v)
	end
end

--根据类型排序（从小打大）
function GameLogic.sortCardsByType(cards)
	local sortCards={}
	local cardAnlyse = require("business.CardAnalysisInfo").new(cards)
	--GameLogic.sortAnlyse(cardAnlyse. SORT_TYPE.ST_ASC)
	for i = 1, 4 do
		for j = #cardAnlyse.cardInfo[i], 1, -1 do
			for k,v in ipairs(cards) do
				if v % 0x10 == cardAnlyse.cardInfo[i][j] then
					table.insert(sortCards, v)
				end
			end
		end
	end
	GameLogic.debug(sortCards, "排序结果")
	for k,v in ipairs(cards) do
		cards[k] = sortCards[k]
	end

end

--排序
function GameLogic.sortCards(cards, type)
	local temp = {}
	for k,v in ipairs(cards) do
		table.insert(temp, CardIndex[v])
	end

	if type == SORT_TYPE.ST_DESC or type == nil then
		table.sort(temp, function(a,b) return a>b end)--从大到小排序

	elseif type == SORT_TYPE.ST_ASC then
		table.sort(temp)--从小到大排序

	else

	end

	for k,v in ipairs(temp) do
		cards[k] = CardInfo[tonumber(v)]
	end
end

function GameLogic.sortAnlyse(cardAnlyse, type)
	for k,v in ipairs(cardAnlyse) do
		GameLogic.sortCards(v, type)
	end
end

--判断牌型
function GameLogic.analysebCardData(cards)
	GameLogic.sortCards(cards)
	local cardAnlyse = require("business.CardAnalysisInfo").new(cards)
	local cardType = CARDS_TYPE.CT_0

	if #cardAnlyse.cardInfo[4] == 1 then
		if #cardAnlyse.cardInfo[1] == 0 and #cardAnlyse.cardInfo[2] == 2 and #cardAnlyse.cardInfo[3] == 0 then
			cardType = CARDS_TYPE.CT_4S2
		elseif #cardAnlyse.cardInfo[1] + #cardAnlyse.cardInfo[2]*2 == 2 and #cardAnlyse.cardInfo[3] == 0 then
			cardType = CARDS_TYPE.CT_4S1
		elseif #cardAnlyse.cardInfo[1] == 0 and #cardAnlyse.cardInfo[2] == 0 and #cardAnlyse.cardInfo[3] == 0 then
			cardType = CARDS_TYPE.CT_4
		end
	
	elseif #cardAnlyse.cardInfo[3] >= 1 then
		local n = #cardAnlyse.cardInfo[3]

		if #cardAnlyse.cardInfo[1] == 0 and #cardAnlyse.cardInfo[2] == 0 and #cardAnlyse.cardInfo[4] == 0 then
			if n == 1 then--三张
				cardType = CARDS_TYPE.CT_3
			
			elseif n >= 2 and GameLogic.isLine(cardAnlyse.cardInfo[3]) then--3顺
				cardType = CARDS_TYPE.CT_3S
			end

		elseif #cardAnlyse.cardInfo[1] == n and #cardAnlyse.cardInfo[2] == 0 and #cardAnlyse.cardInfo[4] == 0 then
			if n == 1 then--三带一
				-- print("三带一")
				cardType = CARDS_TYPE.CT_3S1
			
			elseif n >= 2 and GameLogic.isLine(cardAnlyse.cardInfo[3]) then--飞机
				-- print("n >= 2,三带一",CARDS_TYPE.CT_3S3)
				cardType = CARDS_TYPE.CT_3S3
			end

		elseif #cardAnlyse.cardInfo[1] == 0 and #cardAnlyse.cardInfo[2] == n and #cardAnlyse.cardInfo[4] == 0 then
			if n == 1 then--三带一对
				-- print("三带一对")
				cardType = CARDS_TYPE.CT_3S2

			elseif n >= 2 and GameLogic.isLine(cardAnlyse.cardInfo[3]) then--飞机

				cardType = CARDS_TYPE.CT_3S3

			end

		elseif #cardAnlyse.cardInfo[1] + #cardAnlyse.cardInfo[2]*2 == n and #cardAnlyse.cardInfo[4] == 0 then

			if n >= 2  and GameLogic.isLine(cardAnlyse.cardInfo[3])then

				cardType = CARDS_TYPE.CT_3S3
			end

		end
	
	elseif #cardAnlyse.cardInfo[2] >= 1 then
		local n = #cardAnlyse.cardInfo[2]
		if #cardAnlyse.cardInfo[1] == 0 and #cardAnlyse.cardInfo[3] == 0 and #cardAnlyse.cardInfo[4] == 0 then
			if n == 1 then--一对
				cardType = CARDS_TYPE.CT_2

			elseif n >= 3 and GameLogic.isLine(cardAnlyse.cardInfo[2]) then--连队
				cardType = CARDS_TYPE.CT_2S
			end
		end

	elseif #cardAnlyse.cardInfo[1] >= 1 then
		local n = #cardAnlyse.cardInfo[1]
		if #cardAnlyse.cardInfo[2] == 0 and #cardAnlyse.cardInfo[3] == 0 and #cardAnlyse.cardInfo[4] == 0 then
			if n == 1 then
				cardType = CARDS_TYPE.CT_1

			elseif n == 2 and cardAnlyse.cardInfo[1][1] == 0x0E and cardAnlyse.cardInfo[1][2] == 0x0F then
				cardType = CARDS_TYPE.CT_5--王炸
			
			elseif n == 2 and cardAnlyse.cardInfo[1][2] == 0x0E and cardAnlyse.cardInfo[1][1] == 0x0F then
				cardType = CARDS_TYPE.CT_5--王炸

			elseif n >= 5 and GameLogic.isLine(cardAnlyse.cardInfo[1]) then--顺子
				cardType = CARDS_TYPE.CT_1S
			end
		end
	end

	return cardType, cardAnlyse;

end


--从handCards中取比card大的所有牌，按从小到大排序、同类型优先（比如cardType＝1时单张优先匹配，然后时2张）
--@param	card:上家出的牌	
--@param	handCards:手牌	
--@param	cardType:牌型
--@return	1:符合条件的卡牌索引(不分花色)
function GameLogic.getLargeCards(cardAnlyse, card, cardType)
	local retCards = {}
	for i=cardType, 4 do
		local total = #cardAnlyse.cardInfo[i]
		for j=total, 1, -1 do
			if GameLogic.compareCard(card, cardAnlyse.cardInfo[i][j]) then
				table.insert(retCards, cardAnlyse.cardInfo[i][j])
			end
		end
	end

	return retCards
end

--从handCards中找出满足条件的卡牌（单张、2张、3张、四张）
--@param	cardAnlyse:手牌
--@param	cardType:牌型
--@return	1:符合条件的卡牌(不分花色),从大到小排列
function GameLogic.getCardsByType(cardAnlyse, cardType)
	local retCards = {}
	for i=cardType, 4 do
		local total = #cardAnlyse.cardInfo[i]
		for j=total, 1, -1 do
			table.insert(retCards, cardAnlyse.cardInfo[i][j])
		end
	end

	GameLogic.sortCards(retCards)
	return retCards
end

--从handCards中找出满足条件的卡牌（单张、2张、3张、四张）
--@param	cardAnlyse:手牌
--@param	cards:排除集合
--@paarm 	cardType:类型（单张、2张、3张、四张）
--@return	1:符合条件的卡牌
function GameLogic.getCardExcludeCards(cardAnlyse, cards, cardType)
	local retCards = {}
	local findCards = {}
	for i = cardType, 4 do
		local total = #cardAnlyse.cardInfo[i]
		for j=total, 1, -1 do
			table.insert(findCards, cardAnlyse.cardInfo[i][j])
		end
	end

	for k,v in ipairs(cards) do
		for _k,_v in ipairs(findCards) do
			if v ~= _v then
				retCards[k] = _v
				break
			end
		end
	end

	return retCards
end

--从handCards中找出满足条件的卡牌（单张、2张、3张、四张）
--@param	cardAnlyse:手牌
--@param	cards:排除集合
--@param 	cardType:类型（单张、2张、3张、四张）
--@param 	count:数量
--@return	1:符合条件的卡牌索引
function GameLogic.mergeTakeCards(handCards, excludeIndexes, cardType, count)
	
	for key, value in ipairs(excludeIndexes) do

		local cards = {}
		for k,v in ipairs(handCards) do
			if not GameLogic.tableContainValue(value,k) then
				table.insert(cards, v)
			end
		end

		GameLogic.debug(cards, "筛选后的卡牌")
		--过滤后查找带牌
		local isFind, takeCards = GameLogic.getTakeCards(cards, cardType, count)
		if not isFind then
			excludeIndexes = 0

		else

			local indexes = GameLogic.getIndexesByCards(handCards,takeCards)
			GameLogic.mergeTable(value, indexes)
		end
	end

	for i = #excludeIndexes, 1, -1 do
		if excludeIndexes[i] == 0 then
			table.remove(excludeIndexes, i)
		end
	end
	--return excludeIndexes
end

function GameLogic.getTakeCards(handCards, cardType, count)
	GameLogic.sortCards(handCards, SORT_TYPE.ST_ASC)

	local cards = {}
	local n = cardType
	local m = count
	local temp = {}
	for k,v in ipairs(handCards) do
		
		if #temp == 0 then
			table.insert(temp, v)
			n = n -1

		else
			--判断是否相同
			if temp[1]%0x10 == v%0x10 then
				table.insert(temp,v)
				n = n-1

			else
				n = cardType
				temp = {}
				table.insert(temp,v)
				n = n-1
			end
		end

		if n == 0 then
			for _k,_v in ipairs(temp) do
				table.insert(cards, _v)
			end
			m = m -1
			if m == 0 then
				return true, cards;
			end
			n = cardType
			temp = {}
		end
	end


	return false,cards;
end

--从cards中找到所有比line大的line列表
function GameLogic.getLargeLine(cardAnlyse, line, _type)
	local cards = GameLogic.getCardsByType(cardAnlyse, _type)
	GameLogic.sortCards(cards)

	local retCards = {}
	for i = #cards - #line + 1, 1, -1 do
		local temp = {}
		for j = i, i + #line - 1, 1  do
			table.insert(temp, cards[j])
		end

		GameLogic.debug(line, "line")
		GameLogic.debug(temp, "temp")

		if GameLogic.compareLine(line, temp) then
			table.insert(retCards, temp)
		end
	end
	return retCards
end

--将line表转为手牌index表
function GameLogic.getLineIndexByCards(handCards, cards, cardType)

	local cardIndex = {}
	for k,v in ipairs(cards) do

		local n = cardType
		for _k, _v in ipairs(handCards) do
	        if v == _v%0x10 then
	            table.insert(cardIndex, _k)
	            n = n - 1
	            if n == 0 then
	            	break
	            end
	        end
    	end
	end

	return cardIndex
end

--将line表转为手牌index表
function GameLogic.getLineIndexByCardsTable(handCards, cards, cardType)

	local cardIndex = {}
	for k,v in ipairs(cards) do

		local idx = {}		
		for _,card in ipairs(v) do
			local n = cardType

			for _k, _v in ipairs(handCards) do

		        if card == handCards[_k]%0x10 then
		            table.insert(idx, _k)
		            n = n - 1
		            if n == 0 then
		            	break
		            end
		        end
	    	end
    	end
    	table.insert(cardIndex, idx)
	end

	return cardIndex
end

--将卡牌表转为手牌index表
function GameLogic.getIndexesByCards(handCards, cards)
	local cardIndex = {}
	for k,v in ipairs(cards) do
		for _k, _v in ipairs(handCards) do
	        if v == _v then
	            table.insert(cardIndex, _k)
	        end
    	end
	end

	return cardIndex
end

--将卡牌表转为手牌index表
function GameLogic.getCardIndexByCards(handCards, cards, cardType)
	local cardIndex = {}
	for k,v in ipairs(cards) do
		local n = cardType
		local idx = {}
		for _k, _v in ipairs(handCards) do

	        if v == _v%0x10 then
	            table.insert(idx, _k)
	            n = n - 1
	            if n == 0 then
	            	table.insert(cardIndex, idx)
	            	break
	            end
	        end
    	end
	end

	return cardIndex
end


function GameLogic.getBoomIndexByCards(handCards, cards, cardType)
	--local cards = {}
	GameLogic.sortCards(cards, SORT_TYPE.ST_ASC)

	local cardIndex = {}
	for k,v in ipairs(cards) do
		local n = cardType
		local idx = {}
		for _k, _v in ipairs(handCards) do

	        if cards[k] == handCards[_k]%0x10 then
	            table.insert(idx, _k)
	            n = n - 1
	            if n == 0 then
	            	table.insert(cardIndex, idx)
	            	break
	            end
	        end
    	end
	end
	return cardIndex
end

function GameLogic.getKingBoomIndex(handCards)
	if #handCards > 2 and handCards[1] == 0x4F and handCards[2] == 0x4E then
		return {1,2}
	end
	return nil
end

--根据上家选牌
--@param	preCards:上家出的牌	
--@param	handCards:手牌	
--@return	1:true/false 2:符合条件的卡牌索引
function GameLogic.tishi(handCards, preCards)
	GameLogic.sortCards(handCards)
	
	GameLogic.debug(handCards, "手牌")
	GameLogic.debug(preCards, "上家牌")

	local preType, preCardAnlyse = GameLogic.analysebCardData(preCards)
	--dump(preCardAnlyse, "preCardAnlyse")
	local cardAnlyse = require("business.CardAnalysisInfo").new(handCards)
	-- dump(cardAnlyse, "tishi手牌信息")
	--GameLogic.sortAnlyse(cardAnlyse, SORT_TYPE.ST_ASC)

	local retCards = {}

	if preType == CARDS_TYPE.CT_0 then
		return false, retCards;

	elseif preType == CARDS_TYPE.CT_5 then
		return false, retCards;
		
	elseif #handCards >= #preCards then--从handCards中筛选
		if preType == CARDS_TYPE.CT_1 or preType == CARDS_TYPE.CT_2 or preType == CARDS_TYPE.CT_3 then
			-- dump(cardAnlyse, "手牌信息")
			local cards = GameLogic.getLargeCards(cardAnlyse, preCards[1], preType)
			-- dump(cards, "选牌－－－－－－－－cards")
			retCards = GameLogic.getCardIndexByCards(handCards, cards, preType)
			-- dump(retCards, "选牌－－－－－－－－index")

		elseif preType == CARDS_TYPE.CT_4 then--四炸
			local cards = GameLogic.getLargeCards(cardAnlyse, preCardAnlyse.cardInfo[4][1], preType)
			retCards = GameLogic.getBoomIndexByCards(handCards, cards, preType)
			

		elseif preType == CARDS_TYPE.CT_1S or preType == CARDS_TYPE.CT_2S or preType == CARDS_TYPE.CT_3S then
			local _type = preType - CARDS_TYPE.CT_1S + 1
			-- local cards = GameLogic.getCardsByType(cardAnlyse, _type)
			-- --dump(cards, "所有牌：")
			-- cards = GameLogic.getLargeLine(cards, preCardAnlyse.cardInfo[_type], _type)
			-- --dump(cards, "所有符合条件的顺子牌：")
			--dump(cards, "所有牌：")
			local cards = GameLogic.getLargeLine(cardAnlyse, preCardAnlyse.cardInfo[_type], _type)
			retCards = GameLogic.getLineIndexByCardsTable(handCards, cards, _type)
			

		elseif preType == CARDS_TYPE.CT_3S1 then--三带一
			--三张
			local _type = 3
			local cards3 = GameLogic.getLargeCards(cardAnlyse, preCardAnlyse.cardInfo[_type][1], _type)
			retCards = GameLogic.getCardIndexByCards(handCards, cards3, _type)
			
			--单张
			local cards1 =	GameLogic.getCardExcludeCards(cardAnlyse, cards3, 1)
			local indexes = GameLogic.getCardIndexByCards(handCards, cards1, 1)
			
			--合并
			GameLogic.mergeIndexes(retCards, indexes)
			
		elseif preType == CARDS_TYPE.CT_3S2 then--三带一对
			--遍历所有的三个，然后再找一个最小的对子
			--三张
			local _type = 3
			local cards3 = GameLogic.getLargeCards(cardAnlyse, preCardAnlyse.cardInfo[_type][1], _type)
			retCards = GameLogic.getCardIndexByCards(handCards, cards3, _type)
			
			--两张
			local cards2 =	GameLogic.getCardExcludeCards(cardAnlyse, cards3, 2)
			local indexes = GameLogic.getCardIndexByCards(handCards, cards2, 2)
			
			--合并
			GameLogic.mergeIndexes(retCards, indexes)


		elseif preType == CARDS_TYPE.CT_3S3 then--飞机

			local _type = 3
			-- local cards = GameLogic.getCardsByType(cardAnlyse, _type)
			-- --dump(cards, "所有牌：")
			-- cards = GameLogic.getLargeLine(cards, preCardAnlyse.cardInfo[_type], _type)
			local cards = GameLogic.getLargeLine(cardAnlyse, preCardAnlyse.cardInfo[_type], _type)

			dump(cards, "所有符合条件的顺子牌：")
			retCards = GameLogic.getLineIndexByCardsTable(handCards, cards, _type)

			--找带牌、合并有效结果
			if #preCardAnlyse.cardInfo[1] + #preCardAnlyse.cardInfo[2]*2 == #preCardAnlyse.cardInfo[3] then
				GameLogic.mergeTakeCards(handCards, retCards, 1, #preCardAnlyse.cardInfo[3])

			else
				GameLogic.mergeTakeCards(handCards, retCards, 2, #preCardAnlyse.cardInfo[3])
			end

		elseif preType == CARDS_TYPE.CT_4S1 then--四带2张
			--遍历所有的四个，然后再找两个最小单张／一对
			--四张
			local _type = 4
			local cards4 = GameLogic.getLargeCards(cardAnlyse, preCardAnlyse.cardInfo[_type][1], _type)
			retCards = GameLogic.getCardIndexByCards(handCards, cards4, _type)

			--找带牌、合并有效结果
			GameLogic.mergeTakeCards(handCards, retCards, 1, 2)
			

		elseif preType == CARDS_TYPE.CT_4S2 then --／四带2对
			--遍历所有的四个，然后再找两个最小单张／一对
			--四张
			local _type = 4
			local cards4 = GameLogic.getLargeCards(cardAnlyse, preCardAnlyse.cardInfo[_type][1], _type)
			retCards = GameLogic.getCardIndexByCards(handCards, cards4, _type)

			--找带牌、合并有效结果
			GameLogic.mergeTakeCards(handCards, retCards, 2, 2)
			
		end
	end
	
	if preType ~= CARDS_TYPE.CT_4 then
		--炸弹
		local boom = GameLogic.getBoomIndexByCards(handCards, cardAnlyse.cardInfo[4], CARDS_TYPE.CT_4)
		for k,v in ipairs(boom) do
			table.insert(retCards, v)
		end
	end
	--王炸
	local kingIndex = GameLogic.getKingBoomIndex(handCards)
	if kingIndex then
		table.insert(retCards, kingIndex)
	end


	GameLogic.debug2(handCards, retCards, "提示结果")

	return #retCards > 0 or false, retCards;
end

--根据上家选牌
--@param	preCards:上家出的牌	
--@param	selCards:选中牌	
--@param	handCards:手牌	
--@return	1:符合条件的卡牌索引
function GameLogic.autoTiShi(handCards, preCards, selCards)
	print("GameLogic.autoTiShi")
	GameLogic.debug(handCards, "手牌信息")
	GameLogic.debug(preCards, "上家出牌信息")
	GameLogic.debug(selCards, "选牌信息")
	local preType, preCardAnlyse = GameLogic.analysebCardData(preCards)
	local retCards = nil

	--选中牌有效，直接返回
	if GameLogic.checkOutCards(preCards, selCards) then
		return retCards
	end

	if preType == CARDS_TYPE.CT_0 then
		return retCards

	elseif selCards ~= nil then--从selCards中筛选
		local ret, indexes = GameLogic.tishi(selCards, preCards)

		if ret and #indexes > 0 then
			local cards = {}
			for k,v in ipairs(indexes[1]) do
				table.insert(cards, selCards[v])
			end

			retCards = GameLogic.getIndexesByCards(handCards, cards)
		end
	end

	GameLogic.debug2(handCards, retCards, "提示结果")

	return retCards
end

--自动选牌,根据选中的牌自动补全（补全顺子）
--@param	selCards:自己选中的牌
--@param	handCards:手牌
--@return	1:符合条件的卡牌索引
function GameLogic.autoCompleteCards(selCards, handCards)
	local retCards = nil
	
	if #selCards > 5 then
		local cardAnlyse = require("business.CardAnalysisInfo").new(selCards)	
		local single = #cardAnlyse.cardInfo[1]
		local double = #cardAnlyse.cardInfo[2]
		local triple = #cardAnlyse.cardInfo[3]
		local total = single + double + triple
 		
 		if single >= double and single >= triple and total >= 5 then
 			local cards = GameLogic.getCardsByType(cardAnlyse, 1)
			GameLogic.sortCards(cards)
			if GameLogic.isLine(cards) then
				--只能选择selCards中的扑克
				retCards = GameLogic.getLineIndexByCards(selCards, cards, 1)
			end

 		elseif double >= single and double >= triple and total >= 3 then
 			local cards = GameLogic.getCardsByType(cardAnlyse, 2)
			GameLogic.sortCards(cards)
			if GameLogic.isLine(cards) then
				retCards = GameLogic.getLineIndexByCards(selCards, cards, 2)
			end

 		end
	end

	if retCards then
		local cards = {}
		for k,v in ipairs(retCards) do
			table.insert(cards, selCards[v])
		end
		retCards = GameLogic.getIndexesByCards(handCards, cards)
	end

	return retCards
end

--检测出牌
--@param	selCards:自己选中的牌
--@param	preCards:手牌	
--@return	1:true/false
function GameLogic.checkOutCards(preCards, selCards)

	-- print("###########GameLogic.检测出牌 START########")
	-- for k,v in ipairs(preCards) do
 --        print("上家出牌信息：",cardInfo[v])
 --    end
 --    for k,v in ipairs(selCards) do
 --        print("出牌信息：",cardInfo[v])
 --    end

 --    print("##########GameLogic.检测出牌 END################")

	local preType, preCardAnlyse = GameLogic.analysebCardData(preCards)
	local myType, myCardAnlyse = GameLogic.analysebCardData(selCards)

	if preType == myType and preType ~= CARDS_TYPE.CT_0 then--比较牌型
		
		if #preCards ~= #selCards then--同一类型牌，数量不同直接返回
	    	return false
		    
		elseif preType == CARDS_TYPE.CT_1 and GameLogic.compareCard(preCardAnlyse.cardInfo[1][1], myCardAnlyse.cardInfo[1][1]) then--单张
			return true
		elseif preType == CARDS_TYPE.CT_2 and GameLogic.compareCard(preCardAnlyse.cardInfo[2][1], myCardAnlyse.cardInfo[2][1]) then--一对
			return true
		elseif preType == CARDS_TYPE.CT_3 and GameLogic.compareCard(preCardAnlyse.cardInfo[3][1], myCardAnlyse.cardInfo[3][1]) then--三张
			return true
		elseif preType == CARDS_TYPE.CT_4 and GameLogic.compareCard(preCardAnlyse.cardInfo[4][1], myCardAnlyse.cardInfo[4][1]) then--四炸
			return true
		elseif preType == CARDS_TYPE.CT_1S and GameLogic.compareCard(preCardAnlyse.cardInfo[1][1], myCardAnlyse.cardInfo[1][1]) then--单顺
			return true
		elseif preType == CARDS_TYPE.CT_2S and GameLogic.compareCard(preCardAnlyse.cardInfo[2][1], myCardAnlyse.cardInfo[2][1]) then--双顺
			return true
		elseif preType == CARDS_TYPE.CT_3S and GameLogic.compareCard(preCardAnlyse.cardInfo[3][1], myCardAnlyse.cardInfo[3][1]) then--三顺
			return true
		elseif preType == CARDS_TYPE.CT_3S1 and GameLogic.compareCard(preCardAnlyse.cardInfo[3][1], myCardAnlyse.cardInfo[3][1]) then--三带一
			return true
		elseif preType == CARDS_TYPE.CT_3S2 and GameLogic.compareCard(preCardAnlyse.cardInfo[3][1], myCardAnlyse.cardInfo[3][1]) then--三带一对
			return true
		elseif preType == CARDS_TYPE.CT_3S3 and GameLogic.compareCard(preCardAnlyse.cardInfo[3][1], myCardAnlyse.cardInfo[3][1]) then--飞机
			return true
		elseif preType == CARDS_TYPE.CT_4S1 and GameLogic.compareCard(preCardAnlyse.cardInfo[4][1], myCardAnlyse.cardInfo[4][1]) then--四带2张
			return true
		elseif preType == CARDS_TYPE.CT_4S2 and GameLogic.compareCard(preCardAnlyse.cardInfo[4][1], myCardAnlyse.cardInfo[4][1]) then --／四带2对
			return true
		end

	elseif preType ~= CARDS_TYPE.CT_5 and myType == CARDS_TYPE.CT_4 then--炸弹
		return true

	elseif myType == CARDS_TYPE.CT_5 then
		return true

	end
	 	
	return false 
end

--比较两张牌的大小
--param1: smallCard 传入较小的牌
--param2: largeCard 传入较大的牌
--return: 返回true／false
function GameLogic.compareCard(smallCard, largeCard)
	--没有比较花色
	if CardIndex[largeCard] > CardIndex[smallCard] then
		return true
	end
		
	return false
end

--比较两个line的大小
--param1: smallLine 传入较小的line（传入参数预先按从大到小排好序）
--param2: largeLine 传入较大的line（传入参数预先按从大到小排好序）
--return: 返回true／false
function GameLogic.compareLine(smallLine, largeLine)
	if GameLogic.isLine(smallLine) and GameLogic.isLine(largeLine) then
		local count1 = #smallLine
		local count2 = #largeLine
		if count1 == count2 and CardIndex[largeLine[1]] > CardIndex[smallLine[1]] then
			return true
		end
	end
	return false
end

--顺子判断 
function GameLogic.isLine(_cards)
	--3-A
	local cards = {}
	for _,v in ipairs(_cards) do
		table.insert(cards, v%0x10)
	end

	local n = #cards
	if n < 2 then
		return false
	end

	for k,v in ipairs(cards) do
		if v == 0x02 or v == 0x0E or v == 0x0F then			
			return false;
		end
	end

	if cards[1] == 0x01 and cards[2] == 0x0D and cards[2] - cards[n] == n-2 then
		return true

	elseif cards[1] ~= 0x01 and cards[1] - cards[n] == n-1 then
		return true
	end

	return false;
end

function GameLogic.mergeIndexes(retCards, indexes)
	for k,v in ipairs(retCards) do
		for _k,_v in ipairs(indexes[k]) do
			table.insert(v, _v)
		end
	end
end

---------------------------------------------------------------------------------------------------
GameLogic.init();
