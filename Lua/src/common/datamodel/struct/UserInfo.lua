local UserInfo = class("UserInfo")
    --用户信息的数据结构,变量名字对应protocol.gameServer.gameServer.login.s2c_pb.UserInfo()，不要改
function UserInfo:ctor()
    self.gameID=0                         --//游戏 I D
    self.userID=0                         --//用户 I D
    self.platformID=0
    self.faceID=0                         --//头像索引
    self.nickName=""                       --//用户昵称
    self.gender=0                         --//用户性别
    self.memberOrder=0                       --//会员等级
    self.masterOrder=0                       --//管理等级
    self.tableID=0                           --//桌子索引
    self.chairID=0                           --//椅子索引
    self.userStatus=0                     --//用户状态

    self.score=0                           --//用户分数
    self.insure=0                         --//用户银行

    self.medal=0                           --//用户奖牌
    self.experience=0                     --//经验数值
    self.loveLiness=0                     --//用户魅力
    self.gift=0                         --//礼券数
    self.present=0                           --//优优奖牌

    self.grade=0                           --//用户成绩
    
    self.winCount=0                     --//胜利盘数
    self.lostCount=0                       --//失败盘数
    self.drawCount=0                       --//和局盘数
    self.fleeCount=0                       --//逃跑盘数

    self.signature=""                      --//个性签名
    self.platformFace=""
    self.scoreInGame = 0                  --游戏中人身上的钱（游戏中临时变量）

    self.highestScore = 0
end
--游戏房间登录，用户信息赋值
function UserInfo:dataUserInfo(data)
    for k,v in pairs(self) do
        -- print("dataUserInfo",k,data[k])
        if data[k] then
            
            self[k] = data[k] or self[k]
        else
            -- if k~= "class" then
            --     v = 0
            -- end   
        end
        
    end
end
--游戏房间登录，用户分数赋值
function UserInfo:dataUserScoreInfo(data)
    for k,v in pairs(self) do
        -- print("dataUserScoreInfo",k,v)
        if data[k] then
            
            self[k] = data[k]
        else
            -- if k~= "class" then
            --     v = 0
            -- end   
        end
        
    end
end
--大厅登录，用户信息赋值
function UserInfo:dataLogin(data)
    for k,v in pairs(self) do
        -- print("before ==dataLogin",k,v)
        if data[k] then
            -- v = data[k]--这种写法，不能修改值
            self[k] = data[k]--这种写法，可以能修改值（不明所以）
        else
            -- if k~= "class" then
            --     v = 0
            -- end            
        end
        -- print("dataLogin",k,v)
    end
    -- print("self.userID=",self.userID,"self.nickName",self.nickName)
end
return UserInfo