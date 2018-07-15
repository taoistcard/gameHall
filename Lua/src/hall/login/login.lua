local LoginController = class("LoginController");

function LoginController:start()

    local loginBusiness = require("login.loginBusiness");
    self.business = loginBusiness;
    print("APP_ID",APP_ID)
    if APP_ID == 1038 then
    	local loginLayer = require("login.fishingLoginLayer").new(loginBusiness);
    	display.replaceScene(loginLayer:scene());
    elseif APP_ID == 1032 then
    	local loginLayer = require("login.zjhLoginLayer").new(loginBusiness);
    	display.replaceScene(loginLayer:scene());

    elseif APP_ID == 1005 then
        local loginScene = require("login.ddzLoginScene").new(loginBusiness);
        display.replaceScene(loginScene);
    end

end

function LoginController:ctor()


end

return LoginController;