--功能:连接统一平台，获取活动json。根据json返回的数据，结合本地缓存的数据，在需要更新的情况下下载新的活动zip包。并解压缩到特定的目录下
--删除不再需要的活动zip。节省手机存储空间
--所有的zip文件被解压缩后会被放到可写目录下的activity/main/下。
--所有的zip文件会被放到activity/zip/下
--activity/main/下会用代码写一个common.js文件。记录一些基本参数给html使用

require("thunder.ThunderTools")
require("lfs")

--两个统一平台，炸金花在98pk.net  还有一个统一平台是game100.cn
local SERVICE_DOMAIN = "game100.cn"

local ActivityManager = class( "ActivityManager" )
_nativeWebActitivyManager = nil

local writablePath = cc.FileUtils:getInstance():getWritablePath()
local zipDicPath = writablePath.."activity/zip/"
local filePath = writablePath.."activity/main/"

function just_make_dir(path)
    if lfs.chdir(path) then
        return
    end
    local rt = string.split(path,"/")

    local tmp = "/"
    for i = 1,#rt do
        folder = rt[i]
        if folder ~= nil and folder ~= "" then
	        tmp = tmp..folder.."/"
	        if lfs.chdir(tmp) == nil then
	            lfs.mkdir(tmp)
	        end
	    end
    end
end

function ActivityManager:getInstance()
	if _nativeWebActitivyManager == nil then
		_nativeWebActitivyManager = ActivityManager:new()
	end
	return _nativeWebActitivyManager
end

--活动更新检查的频率是每小时检查一次，一个小时期间不检查更新，但是会继续上次没有完成的更新
function ActivityManager:ctor()
	--加载本地的缓存数据(上一次下载完成的活动配置json)
	local prehuodongJson = cc.UserDefault:getInstance():getStringForKey("nativeWebActivityPreConfig")
	if prehuodongJson == nil then self.preHuoDongConfig = nil
	else self.preHuoDongConfig = json.decode(prehuodongJson) end

	if cc.FileUtils:getInstance():isDirectoryExist(zipDicPath) == false then
		just_make_dir(zipDicPath)
	end

	if cc.FileUtils:getInstance():isDirectoryExist(filePath) == false then
		just_make_dir(filePath)
	end

end

--需要在登录后调用
function ActivityManager:saveCommonJs() print("----saveCommonJs----")
	if is_file_exists(filePath.."common.js") then
		cc.FileUtils:getInstance():removeFile(filePath.."common.js")
	end
	local ostype = device.platform
	if XPLAYER == true then ostype="ios" end
	local tokenId = DataManager:getMyUserInfo().tokenId
	if tokenId == nil then
		tokenId = 0
	end
	local str = "var uid="..DataManager:getMyUserID().."; var os='"..ostype.."'; var model='iPhone'; var source='"..APP_CHANNEL.."'; var ver='"..getAppVersion().."'; var kid=6; var uuid='"..GetDeviceID().."'; var sessionid='"..tokenId.."';"
	write_file(filePath.."common.js", str)
end

--调起webview
function ActivityManager:callActivityWebView() 
	--检查本地是否有缓存的活动数据，没有就用默认的空文件，有就显示缓存好的活动文件
	if is_file_exists(filePath.."index.html") then
		if is_file_exists(filePath.."common.js") == false then
			self:saveCommonJs()
		end

		local url = filePath .. "index.html";
		FreeChip(url)
	else print("----callActivityWebView--default--")
		local url = cc.FileUtils:getInstance():fullPathForFilename("res/webActivity/index.html");
		FreeChip(url)
	end
	
end

function ActivityManager:checkUpdate()
	--每小时检查一次更新
	local havetoupdate = (os.time() - cc.UserDefault:getInstance():getIntegerForKey("nativeWebActivityCheckTime", 10000)) > 3600
	--上次的更新是否完成
	local hadupdated = cc.UserDefault:getInstance():getBoolForKey("nativeWebActivityUpdated", true)
	--一小时内、上次更新完成。只有这一种组合情况不需要更新
	if hadupdated == true and havetoupdate == false then return end

	--开始检查更新，设置参数
	cc.UserDefault:getInstance():setBoolForKey("nativeWebActivityUpdated", false)

	--开始获取最新的更新json
	self:getUpdateJsonFromServer()
end

--获取活动json字符串 http://activity.game100.cn/activity/activityapi/index?appid=1000&os=ios
function ActivityManager:getUpdateJsonFromServer()
	local ostype = device.platform
	if XPLAYER == true then ostype="ios" end
	local url = "http://activity."..SERVICE_DOMAIN.."/activity/activityapi/index?appid="..APP_ID.."&os="..ostype
	print("----获取活动json字符串----", url)
	local request = cc.HTTPRequest:createWithUrl(
        function(event)
            local ok = (event.name == "completed")
		    if ok then
		        local request = event.request
			    local response = request:getResponseString()
			    if response ~= "null" then
			    	self.huoDongConfigString = response
			        self.huoDongConfig = json.decode(response)
			        print("----获取活动json字符串----", response)
			        if self.preHuoDongConfig == nil or (self.preHuoDongConfig.ver ~= self.huoDongConfig.ver and self.huoDongConfig.isSuccess == true) then
			        	self:prepareDownloadZipFiles()
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

--需要考虑的情况是，本地已经有一套缓存的活动文件，然后又有新的活动更新，在更新到一半的情况下，游戏被关闭或断网。下次游戏启动继续更新的需求,这种情况下，需要对比md5值，然后决定是否保留上次更新了的zip包
--开始下载zip文件
function ActivityManager:prepareDownloadZipFiles()
	local needdownload = false
	if self.huoDongConfig.filemd5 ~= nil then
		for filename, md5value in pairs(self.huoDongConfig.filemd5) do
			if is_file_exists(zipDicPath..filename..".zip") then
				local md5 = cc.Crypto:MD5File(zipDicPath..filename..".zip")
				if md5 ~= md5value then
					cc.FileUtils:getInstance():removeFile(zipDicPath..filename..".zip")
					needdownload = true
				end
			else
				needdownload = true
			end

			if needdownload == true then print("----开始下载----文件-----", filename)
				self:startDownloadZipFile(filename, md5value)
				break
			end
		end
	end

	if needdownload == false then print("----下载完成了----开始清理上次的活动缓存，解压")
		--保存活动更新的数据
		self:saveActivityUpdate()
	end
end

--开始下载一个zip文件
function ActivityManager:startDownloadZipFile(filename, md5value) 
	local url = "http://activity."..SERVICE_DOMAIN.."/activity/activityzip/index?appid="..APP_ID.."&file="..filename
	local request = cc.HTTPRequest:createWithUrl(
        function(event)
        	if event.name == "progress" then return; end
    
    		local ok = (event.name == "completed")
    		if not ok then self:prepareDownloadZipFiles() return end

    		local request = event.request
    		local code = request:getResponseStatusCode()
    		if code ~= 200 then self:prepareDownloadZipFiles() return end
            local data = request:getResponseData();
            local tempPath = zipDicPath .. "temp." .. filename;
            write_file(tempPath,data)
    		local ok = cc.Crypto:MD5File(tempPath) == md5value
			os.remove(tempPath);

			local resPath = zipDicPath .. filename ..".zip";

			if ok == true then
		        write_file(resPath, data);
		    end

		    self:prepareDownloadZipFiles()
        end,
        url,
        cc.kCCHTTPRequestMethodGET
    )

    request:setTimeout(300);

    request:start();
end

--保存活动更新的数据
function ActivityManager:saveActivityUpdate()
	if device.platform ~= "android" and device.platform ~= "ios" then return end
	clean_dir(filePath)

	for filename, md5value in pairs(self.huoDongConfig.filemd5) do
		if is_file_exists(zipDicPath..filename..".zip") then
			unZipFile(zipDicPath..filename..".zip", filePath)
		end
	end

	cc.UserDefault:getInstance():setBoolForKey("nativeWebActivityUpdated", true)
	cc.UserDefault:getInstance():setIntegerForKey("nativeWebActivityCheckTime", os.time())
	cc.UserDefault:getInstance():setStringForKey("nativeWebActivityPreConfig", self.huoDongConfigString)
	
	--不能清空，因为是增量更新,清空将重复下载
	--clean_dir(zipDicPath)
	if self.preHuoDongConfig ~= nil then
		for filename, md5value in pairs(self.preHuoDongConfig.filemd5) do
			local needtodelete = true
			for filename1, md5value1 in pairs(self.huoDongConfig.filemd5) do
				if filename == filename1 then --重名的zip包都已经在下载的时候被删除过了。本地存的都是新的。所以除了重名的，别的zip包都需要删除
					needtodelete = false
				end
			end
			if needtodelete == true then
				cc.FileUtils:getInstance():removeFile(zipDicPath..filename..".zip")
			end
		end
	end
end

return ActivityManager