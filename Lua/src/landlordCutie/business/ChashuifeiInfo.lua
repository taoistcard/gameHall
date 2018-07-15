local ChashuifeiInfo = class("ChashuifeiInfo")
_ChashuifeiInfo = nil


function ChashuifeiInfo:ctor()
	self.csfInfo = {
		[202]={120,120,400,2000},
		[200]={120,120,400,2000},
		[203]={2000,20000,200000,2000000},
	}
end

function ChashuifeiInfo:getInstance()
	-- body
	if _ChashuifeiInfo == nil then
		_ChashuifeiInfo = ChashuifeiInfo:new()

	end
	return _ChashuifeiInfo
end

function ChashuifeiInfo:getChashuifeiByGameIdAndIndex( gameId,roomIndex )
	if gameId == nil or roomIndex == nil then
		return 0
	end
    if self.csfInfo[gameId] == nil or self.csfInfo[gameId][roomIndex] == nil then
		return 0
	end
    return self.csfInfo[gameId][roomIndex]
end
return ChashuifeiInfo