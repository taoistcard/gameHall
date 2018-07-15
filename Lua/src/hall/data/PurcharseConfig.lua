PurcharseConfig = {}

PurcharseConfig.ch_Review =0 --"审核状态" 

PurcharseConfig.ch_Wechat =1 --"微信支付" 
PurcharseConfig.ch_Alipay =2 --"支付宝"
PurcharseConfig.ch_UnionPay =3 --"银联卡"
PurcharseConfig.ch_JD =4 --"京东支付"
PurcharseConfig.ch_Other =5 --"其他"
PurcharseConfig.ch_Apple =6 --"apple"
PurcharseConfig.ch_JCard =7 --"骏网卡"
PurcharseConfig.ch_DXCard =8 --"电信卡"

PurcharseConfig.package_Review =0 --"审核状态" 
PurcharseConfig.package_Common =1 --"系统充值" 
PurcharseConfig.package_Discount =2 --"优惠充值"


function PurcharseConfig:init()

    --计费点改造
    self.package = {
        [0] = {--apple review on
            productType = {"427","428","429","430","431"},
            productPrice = {12,50,98,298,488},
            productID = {"jieji_hall_12","jieji_hall_50","jieji_hall_98","jieji_hall_298","jieji_hall_488"}
        },
        [1] = {--wechat
            productType = {"439","440","441","442","443","444","437","438"},
            productPrice = {10,50,100,300,500,5000,1,12},
            productID = {"ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe"}
        },
        [2] = {--alipay
            productType = {"439","440","441","442","443","444","437","438"},
            productPrice = {10,50,100,300,500,5000,1,12},
            productID = {"ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe"}
        },
        [5] = {--web
            productType = {"439","440","441","442","443","444","437","438"},
            productPrice = {10,50,100,300,500,5000,1,12},
            productID = {"ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe"}

        },
        [6] = {--apple review off
            productType = {"432","433","434","435","436"},
            productPrice = {12,50,98,298,488},
            productID = {"jieji_hall_12","jieji_hall_50","jieji_hall_98","jieji_hall_298","jieji_hall_488"}
        },
        [7] = {--JCard
            productType = {"439","440","441","442","443","444","437","438"},
            productPrice = {10,50,100,300,500,5000,1,12},
            productID = {"ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe"}
        },
        [8] = {--DXCard
            productType = {"439","440","441","442","443","444","437","438"},
            productPrice = {10,50,100,300,500,5000,1,12},
            productID = {"ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe"}
        },
    }
    if APP_ID == 1005 then
        --计费点改造
        self.package[0] = {--apple review on
            productType = {"427","428","429","430","431"},
            productPrice = {12,50,98,298,488},
            productID = {"huanle_landpoker_006w","huanle_landpoker_25w","huanle_landpoker_050w","huanle_landpoker_149w","huanle_landpoker_248w"}
            }
        
        self.package[6] = {--apple
            productType = {"432","433","434","435","436","437","438"},
            productPrice = {12,50,98,298,488,6,1,12},
            productID = {"huanle_landpoker_006w","huanle_landpoker_25w","huanle_landpoker_050w","huanle_landpoker_149w","huanle_landpoker_248w","huanle_landpoker_06w","huanle_landpoker_10w","huanle_landpoker_006w"}
        }
    end
    if device.platform == "android" then

        self.package[1] = {--wechat
            productType = {"439","440","441","442","443","444","445","446"},
            productPrice = {10,50,100,300,500,5000,0.1,10},
            productID = {"ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe"}
        }
        self.package[2] = {--alipay
            productType = {"439","440","441","442","443","444","445","446"},
            productPrice = {10,50,100,300,500,5000,0.1,10},
            productID = {"ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe"}
        }
        self.package[5] = {--web
            productType = {"439","440","441","442","443","444","445","446"},
            productPrice = {10,50,100,300,500,5000,0.1,10},
            productID = {"ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe","ignoreMe"}

        }
    end
end

function PurcharseConfig:getPackage(packageType)
    return self.package[packageType]
end

function PurcharseConfig:getIndexByProduct(array, productType)
    for k,v in ipairs(array) do
        if v == productType then
            return k
        end
    end
    return -1
end

function PurcharseConfig:getIndexByPrice(priceArray, price)
    for k,v in ipairs(priceArray) do
        if v == price then
            return k
        end
    end
    return -1
end

function PurcharseConfig:getChargeArgsByProduct(channel, produectType)
    local cfg = self.package[channel]

    local args = {}
    if cfg then
        local index = self:getIndexByProduct(cfg.productType, produectType)
        if index ~= -1 then
            args.packageID = cfg.productType[index]
            args.productId = cfg.productID[index]
            args.productPrice = cfg.productPrice[index]
        end
    end
    return args
end

function PurcharseConfig:getChargeArgs(channel, price)
    local cfg = self.package[channel]

    local args = {}
    if cfg then
        local index = self:getIndexByPrice(cfg.productPrice, price)
        if index ~= -1 then
            args.packageID = cfg.productType[index]
            args.productId = cfg.productID[index]
            args.productPrice = cfg.productPrice[index]
        end
    end
    return args
end

function PurcharseConfig:getReviewCfg()
    return self.review
end

function PurcharseConfig:getReviewCfg()
    return self.common
end

function PurcharseConfig:getReviewCfg()
    return self.cmcc
end

PurcharseConfig:init()
