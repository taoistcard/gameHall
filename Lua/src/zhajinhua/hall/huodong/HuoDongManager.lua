
local HuoDongManager = class( "HuoDongManager" )
_huoDongManagerInstance = nil

function HuoDongManager:ctor()
	self.huoDongConfig = {}
end

function HuoDongManager:getInstance()
    if _huoDongManagerInstance == nil then
        _huoDongManagerInstance = HuoDongManager:new()

    end
    return _huoDongManagerInstance
end

--请求活动配置信息 FIERSTLOADURL_STRING
function HuoDongManager:requestFromServerHuoDongConfig(userId)
	-- local url = "http://112.124.2.126/api/kd_loadapi.php?act=get&uid="..userId
	local url = "http://42.121.109.138/api/kd_loadapi.php?act=get&uid="..userId
	local request = cc.HTTPRequest:createWithUrl(
        function(event)
            local ok = (event.name == "completed")
		    if ok then
		        local request = event.request
			    local response = request:getResponseString()
			    --print("huodong-response:",response);
			    if response ~= "null" then
			        self.huoDongConfig = json.decode(response)
			        for k, v in pairs(self.huoDongConfig.ljinfo) do --print("--------k-----------", k)
			        	for k2, va in pairs(v) do
			        		-- print("------------k2--------", k2, va)
			        	end
			        end
			    end
            else
            	--print("----event.name----", event.name)
            end
        end,
        url,
        cc.kCCHTTPRequestMethodGET
    )

    request:setTimeout(300);

    request:start();
end

--请求累积充值信息 Leiji_Load_URL
function HuoDongManager:requestLeiJiChongZhiInfo(userId, listener)
	self.leijiInfoListener = listener
	-- local url = "http://112.124.2.126/api/kd_leijiapi.php?act=load&uid="..userId
	local url = "http://42.121.109.138/api/kd_leijiapi.php?act=load&uid="..userId
	local request = cc.HTTPRequest:createWithUrl(
        function(event)
            local ok = (event.name == "completed")
		    if ok then
		        local request = event.request
			    local response = request:getResponseString()
			    --print("leiji-response:",response);
			    if response ~= "null" then
			        self.leijiInfo = json.decode(response)
			        for k, v in pairs(self.leijiInfo) do
		        		--print("------k-------v------", k, v)
		        	end

			        if self.leijiInfoListener then
			        	self.leijiInfoListener()
			        end
			    else
			    	self.leijiInfo = nil
			        if self.leijiInfoListener then
			        	self.leijiInfoListener()
			        end
			    end
            else
            	--print("----event.name----", event.name)
            end
        end,
        url,
        cc.kCCHTTPRequestMethodGET
    )

    request:setTimeout(300);

    request:start();
end

--请求获取累积充值奖励 Leiji_Get_URL
function HuoDongManager:requestGetReward(userId, tag, listener)
	self.requestgetleijiInfoListener = listener
	-- local url = "http://112.124.2.126/api/kd_leijiapi.php?act=get&uid="..userId.."&type="..tag
	local url = "http://42.121.109.138/api/kd_leijiapi.php?act=get&uid="..userId.."&type="..tag
	local request = cc.HTTPRequest:createWithUrl(
        function(event)
            local ok = (event.name == "completed")
		    if ok then
		        local request = event.request
			    local response = request:getResponseString()
			    print("response:",response);
			    if response ~= "null" then
			        local result = json.decode(response)
			        if self.requestgetleijiInfoListener then
			        	self.requestgetleijiInfoListener(result)
			        end
			    else
			        if self.requestgetleijiInfoListener then
			        	self.requestgetleijiInfoListener()
			        end
			    end

			    
            else
            	--print("----event.name----", event.name)
            end
        end,
        url,
        cc.kCCHTTPRequestMethodGET
    )

    request:setTimeout(300);

    request:start();
end

--获得累积充值项
function HuoDongManager:getLeiJiChongZhiItems()
	return self.huoDongConfig.ljinfo
end

--获得我的累积充值信息
function HuoDongManager:getMyLeiJiChongZhiInfo()
	return self.leijiInfo
end

--获得可以点亮的icon的index array
function HuoDongManager:getLightLingQuBtnArray()
	local arr = {}
	for ind, conf in ipairs(self.huoDongConfig.ljinfo) do
		if self.leijiInfo.amount >= conf.amount then
			if self.leijiInfo.valuelist[tostring(conf.key)] == 0 then
				arr[#arr+1] = ind
			end
		end
	end
	return arr
end

--获取已经领取过的index array
function HuoDongManager:getAlreadyLingQuBtnArray()
	local arr = {}
	for ind, conf in ipairs(self.huoDongConfig.ljinfo) do
		if self.leijiInfo.amount >= conf.amount then
			if self.leijiInfo.valuelist[tostring(conf.key)] > 0 then
				arr[#arr+1] = ind
			end
		end
	end
	return arr
end

return HuoDongManager
