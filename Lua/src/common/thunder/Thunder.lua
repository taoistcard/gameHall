--=======================================
--descrip:Thunder
--
--        .==.        .==.
--       //`^\\      //^`\\
--      // ^ ^\(\__/)/^ ^^\\
--     //^ ^^ ^/6  6\ ^^ ^ \\
--    //^ ^^ ^/( .. )\^ ^ ^ \\
--   // ^^ ^/\| v""v |/\^ ^ ^\\
--  // ^^/\/ /  `~~`  \ \/\^ ^\\
--  -------------------------------------
--  design by Dragon
-- created:   2014-12-4

--need set delegate and realize


require("lfs")
require("framework.init")
require("thunder.ThunderTools")

MAIN_FILENAME = "flist.txt";
FILE_TPYE = { LCHR = 0, FLIST = 1, RES = 2 }
-----------------------------------------------------------------------------
local Thunder = class("Thunder");

function Thunder:setDelegate(delegate)

    self.delegate = delegate;

end

function Thunder:ctor(requestFlistUrl, subPath)

    subPath = subPath or "";
    --format all path
    local path = cc.FileUtils:getInstance():fullPathForFilename("scripts/main.lua");
    --print("path:",path)
    local resPath = string.sub(path, 1, string.len(path) - 16)
    --print("resPath:",resPath)
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    --print("writable path:",writablePath)

    self.downloadPath = writablePath.."upd/"..subPath;
    self.installPath = resPath.."res/"..subPath;

    local version = self:getVersion();
    self.requestFlistUrl = string.format(requestFlistUrl,version);
    -- print(self.requestFlistUrl,"self.requestFlistUrl");
    
end

function Thunder:getVersion()

    --check update folder
    local flist = nil;

    local fileName = self.downloadPath..MAIN_FILENAME;

    if is_file_exists(fileName) then
        local flistStr = cc.FileUtils:getInstance():getStringFromFile(fileName)
        flist = lua_do_string(flistStr)

    end

    if flist == nil then

        --read flist in install folder
        fileName = self.installPath..MAIN_FILENAME;

        if is_file_exists(fileName) then
            local flistStr = cc.FileUtils:getInstance():getStringFromFile(fileName)
            flist = lua_do_string(flistStr)

        end

    end

    if flist == nil then

        return "0";

    end

    return flist.version;
    
end

function Thunder:startUpdate()

    -- if device.platform == "ios" then
    --     if network.isLocalWiFiAvailable() then
    --         self:requestOList();
    --     end
    -- elseif device.platform == "android" then
    --     if AndroidLogic.isWifiConnected() == 1 then
    --         self:requestOList();
    --     end
    -- end

    self:requestFileList();

end

function Thunder:stopUpdate()
    self.needCancel = true
end

function Thunder:requestFileList()

    local url = self.requestFlistUrl;
    print("url",url)
    local request = cc.HTTPRequest:createWithUrl(

        function(event)

            if event.name ~= "progress" then
                self:onRequestInfoFinished(event)
            end
        end,
        url,
        cc.kCCHTTPRequestMethodGET
    )

    --request:setTimeout(3)

    request:start();

end


function Thunder:onRequestInfoFinished(event)
    if self.needCancel == true then
        self:downloadFinish(-1)
    end

    if event.name == "progress" then
        return;
    end

    local ok = (event.name == "completed")
    local request = event.request
    if not ok then
        --print("request failed. --print error code and error msg")
        self:startForError(request:getErrorCode());
        return;
    end

    local code = request:getResponseStatusCode()
    if code ~= 200 then
        --print("request finished but not return 200. means failed.")
        self:startForError(code);
        return;
    end

    local responseString = request:getResponseString();
    --print("responseString:"..responseString)

    local result = json.decode(responseString);
    if result and result.isSuccess then

        for k,v in pairs(result.data) do
            --print(k,v);
            if string.find(k, "flist") ~= nil then

                local url = v.url;
                --print(url)

                self:requestFile(url, FILE_TPYE.FLIST, 0);

            end

        end

    else
        self:downloadFinish(0);
    end


end


function Thunder:requestFile(url,type,index)
    --print("~~~~~~~~~~~~~~~~~~~~",url);
    local request = cc.HTTPRequest:createWithUrl(
        function(event)

                self:onRequestFileFinished(event,type,index);

        end,
        url,
        cc.kCCHTTPRequestMethodGET
    )

    request:setTimeout(300);

    request:start();

end

function Thunder:onRequestFileStart(index, total)

    if self.delegate.onDownloadStart then
        self.delegate:onDownloadStart(index, total);
    end

end

function Thunder:onRequestFileProgess(event,index)

    if self.delegate.onDownloadProgess then
        self.delegate:onDownloadProgess(event.dltotal ,event.total);
    end

end

function Thunder:onRequestFileFinished(event,type,index)
    if self.needCancel == true then
        self:downloadFinish(-1)
    end

    if event.name == "progress" then
        if type ~= FILE_TPYE.FLIST then
            self:onRequestFileProgess(event, index);
        end
        return;
    end

    local ok = (event.name == "completed")
    local request = event.request
    if not ok then
        --request failed. --print error code and error msg
        self:startForError(request:getErrorCode());
        return;
    end

    local code = request:getResponseStatusCode()
    --print("http code",code)
    if code ~= 200 then
        --request finished but not return 200. means failed.

        if code == 302 then

            local headers = request:getResponseHeadersString();
            local lines = stringSplit(headers, "\r\n");

            for i,line in ipairs(lines) do
                
                if string.find(line, "Location:") then

                    local redirection = string.sub(editbox:getText(), 9);
                    --print(redirection);
                    local request = cc.HTTPRequest:createWithUrl(
                        function(event)
                            if event.name ~= "progress" then
                                self:onRequestFileFinished(event,type,index);
                            end
                        end,
                        redirection,
                        cc.kHTTPRequestMethodGET
                    )

                    request:start();
                    --print("start new");

                    break;

                end

            end

            return;

        else

            self:startForError(code);
            return;

        end

    end

    -- --request successed. echo content return from server.
    local response = request:getResponseString();
    --print("response:"..response)
    local data = request:getResponseData();

    if type == FILE_TPYE.LCHR then

        --igone

    elseif type == FILE_TPYE.FLIST then

        self:onFileListDownloaded(data);

    else

        self:onSingleFileDownloaded(index,data);

    end

end

function Thunder:onFileListDownloaded(data)

    --print("flist download successed.")

    self.newList = lua_do_string(data)
    write_flist(self.downloadPath.."Downloaded-"..MAIN_FILENAME, self.newList)
    if self.newList == nil then

        --print("bad file")
        self:startForError("bad file list");
        return;

    end

    local installList;

    if is_file_exists(self.installPath..MAIN_FILENAME) then

        --read flist in install folder 
        local flistStr = cc.FileUtils:getInstance():getStringFromFile(self.installPath..MAIN_FILENAME)--"res/"
        installList = lua_do_string(flistStr)

    elseif is_file_exists(self.downloadPath..MAIN_FILENAME) then -- for android can read
        
        --read flist in upd folder
        local flistStr = cc.FileUtils:getInstance():getStringFromFile(self.downloadPath..MAIN_FILENAME)--"upd/"
        installList = lua_do_string(flistStr)

    end

    local updlist = nil;
    --for no filst 
    if installList ~= nil then
        
        --check core version
        --print(self.newList.core , installList.core);
        if self.newList.core < installList.core then
          
            if device.platform == "ios" then
                updateWithAppstore();
            elseif  device.platform == "android" then
                AndroidLogic.checkverion()
            end
            return;
        end

        --check update folder
        fileName = self.downloadPath..MAIN_FILENAME
        
        if is_file_exists(fileName) then
            local fileString = cc.FileUtils:getInstance():getStringFromFile(fileName)
            updlist = lua_do_string(fileString)
        end

        -- 如果服务器上的大版本资源比我自己现在的还旧，就不覆盖了。
        if updlist == nil or updlist.pack == nil or updlist.pack < installList.pack then
            clean_dir(self.downloadPath)
            write_flist(self.downloadPath..MAIN_FILENAME,installList)
            updlist = installList
        end

        --check if there is need to update
        --print(self.newList.version , updlist.version);
        if self.newList.version <= updlist.version then
            --print("this is the latest version here.")
            self:onPatchFinished();
            return;
        end

    else

        updlist = {};
        updlist.files = {};

    end

    --compare newlist to updlist,then we can get a flist to be updated.
    local filemap = {}
    for _,v in ipairs(updlist.files) do
        --print(v.file,v.md5)
        filemap[v.file] = {name = v.file,md5 = v.md5};
    end

    for i, v in ipairs(self.newList.files) do

        local needDownload = false;
        if ( not is_file_exists(self.installPath..v.file) ) and ( not is_file_exists(self.downloadPath..v.file) ) then
            --if a file is not in res/upd folder. we think it must to be updated.
            needDownload = true;

        elseif ( is_file_exists(self.downloadPath..v.file) ) then

            --if a file is not in last flist or the md5 is different. we think it must to be updated.
            local t = filemap[v.file];

            if t == nil or t.md5 ~= v.md5 then

                --further more,we need to check the md5 of local file.
                local md5 = cc.Crypto:MD5File(self.downloadPath..v.file)

                if md5 ~= v.md5 then
                    needDownload = true;
                end

            end

        elseif ( is_file_exists(self.installPath..v.file) ) then

            local md5 = cc.Crypto:MD5File(self.installPath..v.file);
            if md5 ~= v.md5 then
                needDownload = true;
            end

        else --can't run in this case

            needDownload = true;

        end

        if needDownload then

            self.downloadList = self.downloadList or {}
            table.insert(self.downloadList, v);

        end

        -- if ( not is_file_exists(self.installPath..v.file) ) and ( not is_file_exists(self.downloadPath..v.file) ) then

        --     self.downloadList = self.downloadList or {}
        --     table.insert(self.downloadList, v);

        -- else

        --     --if a file is not in last flist or the md5 is different. we think it must to be updated.
        --     local t = filemap[v.file];

        --     if t == nil or t.md5 ~= v.md5 then

        --         --further more,we need to check the md5 of local file.
        --         local md5 = cc.Crypto:MD5File(self.downloadPath..v.file)

        --         if md5 ~= v.md5 then

        --             self.downloadList = self.downloadList or {}
        --             table.insert(self.downloadList, v);

        --         end
        --     end

        -- end
        
    end

    --skip
    if self.downloadList and #self.downloadList > 0 then
        for i,v in ipairs(self.downloadList) do
            if v.file == "launcher.bin" then
                table.remove(self.downloadList,i);
                break;
            end
        end
    end


    --now we do update.
    if self.downloadList ~= nil and #self.downloadList > 0 then
        --print("start~~~~~~~~~~~~~~~~~~")
        self:requestDownloadList(1);
    else
        --print("no file need update")
        self:onPatchFinished();

    end

end

function Thunder:requestDownloadList(index)
    
    local url = self.newList.url .. self.downloadList[index].file
    self:requestFile(url,FILE_TPYE.RES,index);

    self:onRequestFileStart(index, #self.downloadList);

end

function Thunder:onSingleFileDownloaded(index,data)

    --print("get~~~~~~~~~~~~~~~~~~")
    local info = self.downloadList[index];
    local tempName = string.gsub(info.file, "/", "")
    local tempPath = self.downloadPath .. "temp." .. tempName;
    --print(tempPath)

    write_file(tempPath,data)
    local ok = cc.Crypto:MD5File(tempPath) == info.md5

    --print(CCCrypto:MD5File(tempPath),info.md5)
    -- if ok ~= true then
    --     --print(CCCrypto:MD5File(tempPath),info.md5)
    -- end


    os.remove(tempPath);

    if ok == true then

        local resPath = self.downloadPath .. info.file;
        --print("onSingleFileDownloaded=============" ..resPath)
        write_file(resPath,data);

    end

    --complete
    if index == #self.downloadList then

        self:onPatchFinished();
        return;

    end

    if self.needCancel == true then
        self:downloadFinish(-1);

    else
        --next
        index = index+1;

        self:requestDownloadList(index);
    end

end

function Thunder:onPatchFinished()
    --print("onPatchFinished")
    --update flist
    write_flist(self.downloadPath..MAIN_FILENAME,self.newList)
    --go to start
    --更新成功
    self:downloadFinish(0);
end

function Thunder:startForError(code)

    self:downloadFinish(code);

end

function Thunder:downloadFinish(errorCode)

    if self.delegate.onDownloadFinish then
        self.delegate:onDownloadFinish(errorCode);
    end

end

return Thunder;