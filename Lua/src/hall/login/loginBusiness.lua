local LoginBusiness = class("LoginBusiness");

require("gameConfig");

function LoginBusiness:ctor()

	print("--------------LoginBusiness--------------ctor")

end

function LoginBusiness:guestLogin()

    -- if XPLAYER == true then
    --     AccountInfo:sendSimulatorLoginRequest("45622") 
    -- end
    AccountType = 1
    sendRegisterFast()
end

return LoginBusiness;