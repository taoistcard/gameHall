--=======================================
--descrip:ThunderFile下载单个文件
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

-----------------------------------------------------------------------------
local ThunderFile = class("ThunderFile");

function ThunderFile:setDelegate(delegate)

    self.delegate = delegate;

end

function ThunderFile:ctor(param)

    --format all path
    local path = cc.FileUtils:getInstance():fullPathForFilename("scripts/main.lua");
    --print("path:",path)
    local resPath = string.sub(path, 1, string.len(path) - 16)
    --print("resPath:",resPath)
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    --print("writable path:",writablePath)
    self.installPath = resPath.."res/";
    self.downloadPath = writablePath.."upd/";
    self.downloadFile = param.file
    self.requestFlistUrl = param.url
    self.downloadMd5 = param.md5

    print(self.requestFlistUrl,"self.requestFlistUrl");
    
end


function ThunderFile:startUpdate()

    local md5 = nil
    if is_file_exists(self.downloadPath..self.downloadFile) then -- for android can read
        md5 = cc.Crypto:MD5File(self.downloadPath..self.downloadFile)
    end

    if md5 == nil or md5 ~= self.downloadMd5 then
        self:requestFile();
    end

end

function ThunderFile:stopUpdate()

end
function ThunderFile:requestFile()
    print("ThunderFile:requestFile()!!!!")
    local url = self.requestFlistUrl;

    local request = cc.HTTPRequest:createWithUrl(

        function(event)
            if event.name == "progress" then
                self:onRequestFileProgess(event);
            
            else-- event.name ~= "progress" then
                print("==============", event.name)
                self:onRequestFileFinished(event)
            end
        end,
        url,
        cc.kCCHTTPRequestMethodGET
    )

    request:setTimeout(300)

    request:start();
    self:onRequestFileStart()
end

function ThunderFile:onRequestFileStart()

    if self.delegate.onFileDownloadStart then
        self.delegate:onFileDownloadStart();
    end

end

function ThunderFile:onRequestFileProgess(event)

    if self.delegate.onFileDownloadProgess then
        self.delegate:onFileDownloadProgess(event.dltotal ,event.total);
    end

end

function ThunderFile:onRequestFileFinished(event)

    if event.name == "progress" then
        self:onRequestFileProgess(event);
        return;
    end

    local ok = (event.name == "completed")
    local request = event.request
    if not ok then
        --request failed. --print error code and error msg
        print("onRequestFileFinished",event.name,request:getErrorCode())
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
                                self:onRequestFileFinished(event);
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

    self:onSingleFileDownloaded(data);

  

end

function ThunderFile:onSingleFileDownloaded(data)

    --print("get~~~~~~~~~~~~~~~~~~")
    local tempName = string.gsub(self.downloadFile, "/", "")
    local tempPath = self.downloadPath .. "temp." .. tempName;
    --print(tempPath)

    write_file(tempPath,data)
    local ok = true --cc.Crypto:MD5File(tempPath) == self.downloadMd5

    --print(CCCrypto:MD5File(tempPath),info.md5)
    -- if ok ~= true then
    --     --print(CCCrypto:MD5File(tempPath),info.md5)
    -- end


    os.remove(tempPath);

    if ok == true then

        local resPath = self.downloadPath .. self.downloadFile;
        print("onSingleFileDownloaded=============" ..resPath)
        write_file(resPath,data);

    end

    --complete
    self:onPatchFinished(0);


end

function ThunderFile:onPatchFinished()
    --go to start
    self:downloadFinish(0);
end

function ThunderFile:startForError(code)

    self:downloadFinish(code);

end

function ThunderFile:downloadFinish(errorCode)

    if self.delegate.onFileDownloadFinish then
        self.delegate:onFileDownloadFinish(errorCode);
    end

end

return ThunderFile;