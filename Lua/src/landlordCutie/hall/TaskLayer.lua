local TaskLayer = class( "TaskLayer", function() return display.newLayer() end)

_taskLayer = nil
function TaskLayer:ctor()
    self:setNodeEventEnabled(true)

    self.taskIDArray = {20,30,3,4}
	self:createUI()
end
function TaskLayer:getInstance()
    if _taskLayer == nil then
        _taskLayer = TaskLayer:new()
    else
        -- print("1111self",tostring(self))
        local hasquerytask = RunTimeData:getHasQureyTask()
        if hasquerytask ~= RunTimeData:getCurGameID() then
            -- print("查询任务次数！！！！！！")
            -- self.handler = GameCenter:addEventListener(GameCenterEvent.EVENT_QUERYTASKCOUNT, handler(self, self.refreshTaskList))
            -- GameCenter:queryTaskCount()
            MissionInfo:sendQueryUserDrawedCountList()
        end
    end
    return _taskLayer
end
function TaskLayer:onQuit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function TaskLayer:onEnter()
    print("=======TaskLayer:onEnter")
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MissionInfo, "missionInfo", handler(self, self.refreshTaskList));
    
    local hasquerytask = RunTimeData:getHasQureyTask()
    if hasquerytask ~= RunTimeData:getCurGameID() then
        MissionInfo:sendQueryUserDrawedCountList()
    end
end

function TaskLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function TaskLayer:createUI()
    local contentSize = self:getContentSize()


    -- 蒙板
    -- local maskLayer = ccui.ImageView:create()
    -- maskLayer:loadTexture("common/black.png")
    -- maskLayer:setContentSize(contentSize);
    -- maskLayer:setScale9Enabled(true)
    -- maskLayer:setCapInsets(cc.rect(4,4,1,1))
    -- maskLayer:setPosition(cc.p(contentSize.width/2, display.cy));
    -- maskLayer:setTouchEnabled(true)
    -- self:addChild(maskLayer)


    local bankConainer = ccui.ImageView:create("common/pop_bg.png");
    bankConainer:setScale9Enabled(true);
    bankConainer:setContentSize(cc.size(674, 508));
    bankConainer:setPosition(cc.p(591,305));
    self:addChild(bankConainer);

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(590,360));
    panel:setPosition(592, 308)
    self:addChild(panel)

    local pop_title = ccui.ImageView:create("common/pop_title.png");
    pop_title:setPosition(cc.p(389,520));
    self:addChild(pop_title);

    local roomword = display.newTTFLabel({text = "任务列表",
                                size = 24,
                                color = cc.c3b(255,233,110),
                                font = FONT_ART_TEXT,
                            })
                :addTo(self)
    roomword:setPosition(389, 542)
    roomword:setTextColor(cc.c4b(251,248,142,255))
    roomword:enableOutline(cc.c4b(137,0,167,200), 2)

--  listview
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(590,360))
    self.listView:setAnchorPoint(cc.p(0.5,0.5))
    self.listView:setPosition(593+10,306-10)
    self:addChild(self.listView)

    self:createTaskList()

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(894,528));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
               self:hide() 
                -- self:onQuit()
                -- self:removeFromParent();
            end
        end
    )
end
function TaskLayer:createTaskList()
	local colorArray = {cc.c4b(131,66,21,255),cc.c4b(150,250,9,255),cc.c4b(254,254,254,255),cc.c4b(132,37,37,255)}
	local couponList = RunTimeData:getCouponConfig()
    local currentCountComb = RunTimeData:getTaskCount(20)%10
    print("currentCountComb====",currentCountComb)
    local completeCountComb = 0
    local lianshengList = RunTimeData.lianshengConfig
	for i=1,4 do
        local taskId = self.taskIDArray[i]
		local couponItem = couponList[taskId]
        if taskId>10 and taskId <= 20 then
            local currentCount = RunTimeData:getTaskCount(20)
            for j,w in ipairs(lianshengList) do
                -- print(j,w)
                if (currentCount%10) < w.completeCount then
                    couponItem = lianshengList[j]
                    completeCountComb = RunTimeData.lianshengConfig[j].completeCount
                    break;
                elseif (currentCount%10) == w.completeCount then
                    couponItem = lianshengList[j]
                    -- print(j,"count",couponItem.count,"completeCount",couponItem.completeCount)
                    if (j+1) <= #lianshengList then
                        j = j+1
                    end
                    couponItem = lianshengList[j]
                    completeCountComb = RunTimeData.lianshengConfig[j].completeCount
                    break;
                else
                    couponItem = lianshengList[j]
                    completeCountComb = 999
                end
            end
        end
        local bangItemLayer = ccui.ImageView:create("common/list_item.png")
        -- bangItemLayer:loadTexture("common/list_item.png")
        bangItemLayer:setScale9Enabled(true)
        bangItemLayer:setContentSize(cc.size(568,84))
        -- bangItemLayer:setCapInsets(cc.rect(50,40,10,10))
        bangItemLayer:ignoreAnchorPointForPosition(true)
        -- bangItemLayer:setAnchorPoint(0.5,0.5)
        bangItemLayer:setName("ListItem")
        bangItemLayer:setTag(i)

        -- 
        local itemName = ccui.Text:create(couponItem.description,FONT_ART_TEXT,21)
        itemName:setTextColor(colorArray[1])
        itemName:setAnchorPoint(cc.p(0,0.5))
        itemName:setPosition(cc.p(18,62))
        bangItemLayer:addChild(itemName)
        itemName:setName("ItemName")
        if taskId>10 and taskId <= 20 then
            itemName:setString("连胜"..completeCountComb.."局")
        end

        -- 
        local itemScore = ccui.Text:create("可获得：",FONT_ART_TEXT,21)
        itemScore:setTextColor(colorArray[2])
        itemScore:setAnchorPoint(cc.p(0,0.5))
        itemScore:setPosition(cc.p(18,29))
        bangItemLayer:addChild(itemScore)
        itemScore:setName("ItemScore")

        local icon = ccui.ImageView:create("common/gold.png")
        bangItemLayer:addChild(icon)
        icon:setPosition(129, 29)
        if couponItem.kind == 2 then
        	icon:loadTexture("liquan/lq_icon0.png")
        end
        icon:setScale(0.7)

        local counts = ccui.Text:create(couponItem.count,FONT_ART_TEXT,21)
        counts:setTextColor(colorArray[3])
        counts:setAnchorPoint(cc.p(0,0.5))
        counts:setPosition(cc.p(167,32))
        bangItemLayer:addChild(counts)
        counts:setName("counts")

        local zs1 = ccui.ImageView:create("hall/task/love.png")
        zs1:setPosition(419, 50)
        bangItemLayer:addChild(zs1)
        zs1:setRotation(180)

        local zs2 = ccui.ImageView:create("hall/task/love.png")
        zs2:setPosition(511, 45)
        bangItemLayer:addChild(zs2)
        
        local taskCount = RunTimeData:getTaskCount(taskId)

        if taskId<=10 then
            if taskCount == 0 then
                local weiwancheng = ccui.ImageView:create("hall/task/taskCount0.png")
                weiwancheng:setPosition(450, 45)
                bangItemLayer:addChild(weiwancheng)
            else
                local wancheng = ccui.ImageView:create("hall/task/taskCount1.png")
                wancheng:setPosition(450, 45)
                bangItemLayer:addChild(wancheng)
                local tt = ccui.Text:create("",FONT_ART_TEXT,24)
                tt:setPosition(450, 45)
                tt:setFontSize(24)
                tt:setColor(cc.c3b(230,7,7))
                tt:setString("完成"..taskCount.."次")
                tt:setRotation(345)
                bangItemLayer:addChild(tt)
            end
        elseif taskId>10 and taskId <= 20 then

                local tt = ccui.Text:create("",FONT_ART_TEXT,24)
                tt:setPosition(450, 45)
                tt:setFontSize(24)
                tt:setColor(cc.c3b(230,7,7))
                tt:setString(currentCountComb.."/"..completeCountComb)             
                bangItemLayer:addChild(tt)
        elseif taskId == 30 then
                local currentCount = RunTimeData:getTaskCount(30)
                local completeCount = 10            
                local tt = ccui.Text:create("",FONT_ART_TEXT,24)
                tt:setPosition(450, 45)
                tt:setFontSize(24)
                tt:setColor(cc.c3b(230,7,7))
                tt:setString(currentCount.."/"..completeCount)            
                bangItemLayer:addChild(tt)
        end

           
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(bangItemLayer:getContentSize())
        custom_item:addChild(bangItemLayer)
        custom_item:setTag(i)
        
        self.listView:pushBackCustomItem(custom_item)
	end
end
function TaskLayer:refreshTaskList()
    -- local items_count = table.getn(self.listView:getItems())
    -- for i = 1, items_count do

    -- end
    -- print("self",tostring(self))
    -- Hall.showTips("refreshTaskList", 1)
    print("=========TaskLayer:refreshTaskList")
    self:removeAllChildren()
    self:createUI()
end
return TaskLayer