--
-- Author: <zhaxun>
-- Date: 2015-05-25 10:33:26
--
local CardAnalysisInfo = class("CardAnalysisInfo")

function CardAnalysisInfo:ctor(cards)
	self.cards = {}
	for k,v in ipairs(cards) do
		self.cards[k] = cards[k]%0x10
	end
	--table.sort(self.cards )--从小到大排序
	
	self.cardInfo = {	[1]={}, --单张
						[2]={}, --一对
						[3]={}, --三张
						[4]={} };--四张

	self:analysis();

end

function CardAnalysisInfo:analysis()
	local j = 1;
	for i = 1, #self.cards do
		if i + 1 <= #self.cards then	
			if self.cards[i] == self.cards[i+1] then
				j = j + 1
			
			else
				table.insert(self.cardInfo[j], self.cards[i])
				j = 1
			end
		else
			table.insert(self.cardInfo[j], self.cards[i])
		end
	end

end

return CardAnalysisInfo