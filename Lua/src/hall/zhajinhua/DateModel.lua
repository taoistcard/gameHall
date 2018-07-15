---@运行时，某个游戏的数据
local DateModel = class( "DateModel" )
_runtimeGameData = nil
function DateModel:ctor()
	self.tableID = 65535--从0开始算（新主站从1开始）
	self.chairID = 65535--从0开始算（新主站从1开始）
	self.isLookCard = 0--0未看1已看
	self.isDropped = false--是否弃牌
	self.maxScore = 0--最大下注
	self.cellScore = 0--单元下注
	self.originCellScore = 0--原始单元积分（变更底注前的）
	self.currentTimes = 0--当前倍数
	self.bankerUser = 0
	self.userMaxScore = 0--用户当局 所能下的最大筹码
	self.lookOn = 0--是否旁观
	self.tableGoldUIArrayValue = {0,0,0,0,0}--桌上玩家下注数目
	self.tableGoldTotalValue = 0 --桌上总注
	self.xuePin = false --血拼到底
	self.gameStart = false --游戏开始
	self.autoFollow = false--自动跟注
	self.autoDrop = false--自动放弃
	self.isMyTurn = false--我的回合
	self.compareToMe = {}--跟我比牌的人
	self.operateButtonStatus = {0,0,0,0,0}--游戏操作按钮状态0不可操作，1可操作（依次顺序 弃牌，看牌，比牌，加满，跟注）
	self.compareDelayTime = 0 --用户比牌播动画 延迟血拼到底
	self.lookCardStatus = {0,0,0,0,0}--看牌状态 0未看1已看
	self.playStatus = {0,0,0,0,0}--游戏状态0弃牌或者未开始游戏，1游戏中可以操作的
	self.allowLookFromServer = 0--服务端回过来的，是否允许旁观  0不允许1允许
	self.quQianNum = 0--游戏中取钱的数目
	self.startButtonClicked = false--是否点过开始按钮
	self.isCompeteRoom = false --是否是比赛场
	self.isSignUp = false --是否报名
	self.currentRound = 0--当前第几手
	self.currentMatchServerID = 0--当前比赛场ServerID
	----------百人场--------
	self.selectedChip = 0
	---------游戏配置选项-------------
	self.autoSitDown = false--自动坐下
	self.tiShiPaiXing = true--牌型提示
	self.allowLookOne = false --是否允许旁观
	self.listenChat = true --聊天屏蔽

end
function DateModel:getInstance()
    if _runtimeGameData == nil then
        _runtimeGameData = DateModel:new()

        local autoSitDown = cc.UserDefault:getInstance():getBoolForKey("autoSitDown", false)
	    local tiShiPaiXing = cc.UserDefault:getInstance():getBoolForKey("tiShiPaiXing", true)
	    local allowLookOne = cc.UserDefault:getInstance():getBoolForKey("allowLookOne", false)
	    local listenChat = cc.UserDefault:getInstance():getBoolForKey("listenChat", true)

	    _runtimeGameData.autoSitDown = autoSitDown
	    _runtimeGameData.tiShiPaiXing = tiShiPaiXing
	    _runtimeGameData.allowLookOne = allowLookOne
	    _runtimeGameData.listenChat = listenChat

    end
    return _runtimeGameData
end
function DateModel:setCurrentMatchServerID(value)
	self.currentMatchServerID = value
end
function DateModel:getCurrentMatchServerID()
	return self.currentMatchServerID
end
function DateModel:setCurrentRound(value)
	self.currentRound = value
end
function DateModel:getCurrentRound()
	return self.currentRound
end
function DateModel:setIsCompeteRoom(value)
	self.isCompeteRoom = value
end
function DateModel:getIsCompeteRoom()
	return self.isCompeteRoom
end
function DateModel:setStartButtonClicked(value)
	print("setStartButtonClicked",value)
	self.startButtonClicked = value
end
function DateModel:getStartButtonClicked()
	return self.startButtonClicked
end
function DateModel:setQuQianNum(num)
	self.quQianNum = num
end
function DateModel:getQuQianNUm()
	return self.quQianNum
end
function DateModel:setAllowLookFromServer(value)
	self.allowLookFromServer = value
end
function DateModel:getAllowLookFromServer()
	return self.allowLookFromServer
end
function DateModel:setLookCardStatus(index,value)
	self.lookCardStatus[index] = value
end
function DateModel:getLookCardStatus(index)
	return self.lookCardStatus[index]
end
function DateModel:setPlayStatus(index,value)
	self.playStatus[index] = value
end
function DateModel:getPlayStatus(index)
	return self.playStatus[index]
end
function DateModel:setIsDropped(value)
	self.isDropped = value
end
function DateModel:getIsDropped()
	return self.isDropped
end
function DateModel:setCompareDelayTime( time )
	self.compareDelayTime = time
end
function DateModel:getComparteDelayTime()
	return self.compareDelayTime
end
function DateModel:setOperateButtonStatus(buttonType,status)
	self.operateButtonStatus[buttonType] = status
end
function DateModel:getOperateButtonStatus(buttonType)
	return self.operateButtonStatus[buttonType]
end
function DateModel:setCompareToMe(compareArray)
	self.compareToMe = compareArray
end
function DateModel:getCompareToMe()
	return self.compareToMe
end
function DateModel:setMyTurn(isMyTurn)
	self.isMyTurn = isMyTurn
end
function DateModel:getMyTurn()
	return self.isMyTurn
end
function DateModel:setAutoFollow(autoFollow)
	self.autoFollow = autoFollow
end
function DateModel:getAutoFollow()
	return self.autoFollow
end
function DateModel:setAutoDrop(autoDrop)
	self.autoDrop = autoDrop
end
function DateModel:getAutoDrop()
	return self.autoDrop
end
function DateModel:setGameStart(gameStart)
	self.gameStart = gameStart
end
function DateModel:getGameStart()
	return self.gameStart;
end
function DateModel:setXuePin(xuepin)
	self.xuepin = xuepin
end
function DateModel:getXuePin()
	return self.xuepin
end
function DateModel:setTableGoldTotalValue(totalValue)
	self.tableGoldTotalValue = totalValue
end
function DateModel:getTableGoldTotalValue()
	return self.tableGoldTotalValue
end
function DateModel:setTableGoldPlayerValue(index,value)
	self.tableGoldUIArrayValue[index] = value
end
function DateModel:getTableGoldPlayerValue(index)
	return self.tableGoldUIArrayValue[index]
end
function DateModel:setLookOn(lookOn)
	self.lookOn = lookOn
end
function DateModel:getLookOn()
	return self.lookOn
end
function DateModel:setTableID(tableid)
	self.tableID = tableid
end
--从0开始算
function DateModel:getTableID()
	return self.tableID
end
function DateModel:setChairID(chairid)
	self.chairID = chairid
end
--从0开始算
function DateModel:getChairID()
	return self.chairID
end
function DateModel:setLookCard(isLookCard)
	self.isLookCard = isLookCard
end
function DateModel:getLookCard()
	return self.isLookCard
end
function DateModel:setMaxScore(maxscore)
	self.maxScore = maxscore
end
function DateModel:getMaxScore()
	return self.maxScore
end
function DateModel:setOriginCellScore(cellscore)
	self.originCellScore = cellscore
end
function DateModel:getOriginCellScore()
	return self.originCellScore
end
function DateModel:setCellScore(cellscore)
	self.cellScore = cellscore
end
function DateModel:getCellScore()
	return self.cellScore
end
function DateModel:setCurrentTimes(currentTimes)
	self.currentTimes = currentTimes
end
function DateModel:getCurrentTimes()
	return self.currentTimes
end
function DateModel:setBankerUser(bankerUser)
	self.bankerUser = bankerUser
end
function DateModel:getBankerUser()
	return self.bankerUser
end
function DateModel:setUserMaxScore(userMaxScore)
	self.userMaxScore = userMaxScore
end
function DateModel:getUserMaxScore()
	return self.userMaxScore
end
function DateModel:setAutoSitDown(autoSitDown)
	self.autoSitDown = autoSitDown
	cc.UserDefault:getInstance():setBoolForKey("autoSitDown", autoSitDown)
end
function DateModel:getAutoSitDown()
	return self.autoSitDown
end
function DateModel:setTiShiPaiXing(tiShiPaiXing)
	self.tiShiPaiXing = tiShiPaiXing
	cc.UserDefault:getInstance():setBoolForKey("tiShiPaiXing", tiShiPaiXing)
end
function DateModel:getTiShiPaiXing()
	return self.tiShiPaiXing
end
function DateModel:setAllowLookOne(allowLookOne)
	self.allowLookOne = allowLookOne
	cc.UserDefault:getInstance():setBoolForKey("allowLookOne", allowLookOne)
end
function DateModel:getAllowLookOne()
	return self.allowLookOne
end
function DateModel:setListenChat(listenChat)
	self.listenChat = listenChat
	cc.UserDefault:getInstance():setBoolForKey("listenChat", listenChat)
end
function DateModel:getListenChat()
	return self.listenChat
end
-----百人场-------
function DateModel:setSelectedChip(selectedChip)
	self.selectedChip = selectedChip
end
function DateModel:getSelectedChip()
	return self.selectedChip
end
return DateModel