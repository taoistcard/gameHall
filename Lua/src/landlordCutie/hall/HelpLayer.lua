local HelpLayer = class("HelpLayer",function () return display.newLayer() end)
function HelpLayer:ctor()
	self:createUI()
end

function HelpLayer:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    -- bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(1064,560));
    bgSprite:setPosition(cc.p(567,316));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(930,400));
    panel:setPosition(568, 304)
    self:addChild(panel)

    local tab2ren = ccui.Button:create("hall/help/tab2renNormal.png","hall/help/tab2renSelected.png");
    tab2ren:setPosition(cc.p(162,559))
    tab2ren:setPressedActionEnabled(true)
    tab2ren:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:tab2renClickHandler(sender);
                    end
                end
            )
    self:addChild(tab2ren)
    self.tab2ren = tab2ren
    self.tab2ren:setHighlighted(true)

    local tab3ren = ccui.Button:create("hall/help/tab3renNormal.png","hall/help/tab3renSelected.png");
    tab3ren:setPosition(cc.p(307,559))
    tab3ren:setPressedActionEnabled(true)
    tab3ren:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:tab3renClickHandler(sender);
                    end
                end
            )
    self:addChild(tab3ren)
    self.tab3ren = tab3ren

    local tabvip = ccui.Button:create("hall/help/tabvipNormal.png","hall/help/tabvipSelected.png");
    tabvip:setPosition(cc.p(452,559))
    tabvip:setPressedActionEnabled(true)
    tabvip:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:tabvipClickHandler(sender);
                    end
                end
            )
    self:addChild( tabvip)
    self.tabvip = tabvip

    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(880,360))
    self.listView:setPosition(130, 130)
    -- self.listView:setBackGroundColorType(1)
    -- self.listView:setBackGroundColor(cc.c3b(0,123,0))
    self:addChild(self.listView)

    -- local infoText = ccui.Text:create("","",24)
    -- infoText:setString("牌数：二人玩法，整副牌只有46张牌，牌库没有3和4，每人首发17张牌，废牌有9张，底牌有3张；\n叫牌规则：拿到“明牌”的叫牌，明牌即是牌上有一个标识绿点的牌；\n出牌规则：出牌规则同标准斗地主规则一致；\n翻倍规则：炸弹、春天、反春天均翻倍，底倍x2倍；抢地主1/2/3/4次，底分分别为x2/4/5/6倍；底牌牌型有单王或者对2的，底倍x2倍；底牌牌型是顺子、同花、三条或者全小（三张牌都<=9）的，底倍x3倍；底牌有双王，底倍x4倍；让先，底倍x3倍；\n抢地主规则：明牌叫牌（叫地主），底倍为1，抢地主1/2/3/4次，底倍分别x2/4/5/6倍\n让牌规则：让牌的意思是，当对方还有5张牌打完才会获胜时，由于你让牌对方3张，则此时对方只需要打掉2张牌即可获胜。叫到地主方，没有经过抢牌叫到地主着，选择让牌，会让对手3张牌；每抢地主1次，最终抢到地主放就会让对方1张牌，最多抢地主4次，让牌4张；\n底分规则：多人玩家的中携带金币（欢乐豆）最少玩家的50/1作为每局的底分，且底分是动态的；")
    -- -- infoText:setPosition(571, 305)
    -- infoText:setPosition(300, 100)
    -- infoText:setAnchorPoint(cc.p(0,1))
    -- infoText:setColor(cc.c3b(249,247,123))
    -- infoText:setTextAreaSize(cc.size(860,450))
    -- infoText:ignoreContentAdaptWithSize(false)
    -- infoText:setTextHorizontalAlignment(0)
    -- infoText:setTextVerticalAlignment(0)
    -- -- self:addChild(infoText)
    -- self.infoText = infoText

    -- local custom_item = ccui.Layout:create()
    -- custom_item:setTouchEnabled(true)
    -- -- custom_item:setAnchorPoint(cc.p(0,1))
    -- custom_item:setContentSize(cc.size(880,360))
    -- custom_item:addChild(infoText)
    
    -- self.listView:pushBackCustomItem(infoText)

    self:tab2renClickHandler()

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(1066,566));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeFromParent();

            end
        end
    )
end
function HelpLayer:tab2renClickHandler()
	self.tab2ren:setHighlighted(true)
	self.tab3ren:setHighlighted(false)
	self.tabvip:setHighlighted(false)

    self.listView:removeAllItems()
    local custom_itemY = 550
    local custom_itemX = 860
    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
    custom_item:setAnchorPoint(cc.p(0,1))
    custom_item:setPosition(300, 100)

    local titleArray = {"牌数：","叫牌规则：","出牌规则：","翻倍规则：","抢地主规则：","让牌规则：","底分规则："}
    local infoArray = {
        "二人玩法，整副牌只有46张牌，牌库没有3和4，每人首发17张牌，废牌有9张，底牌有3张；",
        "拿到“明牌”的叫牌，明牌即是牌上有一个标识绿点的牌；",
        "出牌规则同标准斗地主规则一致；",
        "1.炸弹、春天、反春天均翻倍，底倍x2倍；\n2.抢地主1/2/3/4次，底分分别为x2/4/5/6倍；\n3.底牌牌型有单王或者对2的，底倍x2倍；底牌牌型是顺子、同花、三条或者全小（三张牌都<=9）的，底倍x3倍；\n4.底牌有双王，底倍x4倍；让先，底倍x3倍；",
        "明牌叫牌（叫地主），底倍为1，抢地主1/2/3/4次，底倍分别x2/4/5/6倍",
        "让牌的意思是，当对方还有5张牌打完才会获胜时，由于你让牌对方3张，则此时对方只需要打掉2张牌即可获胜。叫到地主方，没有经过抢牌叫到地主着，选择让牌，会让对手3张牌；每抢地主1次，最终抢到地主放就会让对方1张牌，最多抢地主4次，让牌4张；",
        "多人玩家的中携带金币（欢乐豆）最少玩家的50/1作为每局的底分，且底分是动态的；",
    }
    local intervalI = {0,2,2,2,5,2,4}
    local length = #titleArray
    for i=1,length do
        local height = 0
        for j=1,i do
            height = height + intervalI[j]
        end
        self.title1 = ccui.Text:create(titleArray[i],FONT_ART_TEXT,26)
        self.title1:setAnchorPoint(cc.p(0,1))
        self.title1:setPosition(0, custom_itemY-height*30)
        self.title1:setColor(cc.c3b(255,228,0))
        custom_item:addChild(self.title1)
        height = height +1
        self.infoText = ccui.Text:create("","",20)
        self.infoText:setPosition(0, custom_itemY-height*30)
        self.infoText:setAnchorPoint(cc.p(0,1))
        self.infoText:setColor(cc.c3b(249,247,123))
        self.infoText:setString(infoArray[i])
        self.infoText:setTextAreaSize(cc.size(860,300))
        self.infoText:ignoreContentAdaptWithSize(false)
        self.infoText:setTextHorizontalAlignment(0)
        self.infoText:setTextVerticalAlignment(0)
        custom_item:addChild(self.infoText)
    end

    self.listView:pushBackCustomItem(custom_item)
end
function HelpLayer:tab3renClickHandler()
	self.tab2ren:setHighlighted(false)
	self.tab3ren:setHighlighted(true)
	self.tabvip:setHighlighted(false)

    self.listView:removeAllItems()
    local custom_itemY = 1080
    local custom_itemX = 860
    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
    custom_item:setAnchorPoint(cc.p(0,1))
    custom_item:setPosition(300, 100)
    -- custom_item:setBackGroundColorType(1)
    -- custom_item:setBackGroundColor(cc.c3b(100,123,100))

    local titleArray = {"牌数：","叫牌规则：","出牌规则：","抢地主规则：","翻倍规则：","底分规则：","斗地主的牌型："}
    local infoArray = {
        "整副牌有54张，包含大王、小王以及123456789各四张\n",
        "每局抓到有明牌标示牌的人开始叫地主，初始倍数为1\n",
        "地主先出牌，可以出一张牌或一组合法的牌型。按逆时针顺序，下一个玩家要么不出(Pass)，要么出张数和类型都相同但比上一组牌更大的牌。但有两种牌型例外——火箭能盖过任何牌型，炸弹能盖过除火箭和更大的炸弹外的任何牌型(下面会介绍)。出牌将这样沿着牌桌持续多轮，直到连续两个玩家不出为止。然后把这些出过的牌扣下去放在一边，并从上次出牌的人开始，领出任何一张或一组合法的牌型。\n",
        "第一个抓到明牌标识的人叫地主，可叫1/2/3分，如果直接叫3分，那其他玩法无需再叫，叫3分玩家直接是地主；如过第一个叫地主的人只叫1分或者2分，其他玩家可再叫3分抢地主；\n",
        "每局初始倍数为3，叫1分/2分/3分，倍数3倍/6倍/9倍；\n",
        "三人玩家的中携带金币（欢乐豆）最少玩家的50/1作为每局的底分，且底分是动态的；如若叫地主人叫了1分或者2分后，其他玩家不叫，那该玩家直接为地主；\n",
        
        }
    local paixing 
    local paixingInfo = {
        "(1) 单张：前面提到过，大小顺序从3(最小)到大王(最大)；\n",
        "(2) 一对：两张大小相同的牌，从3(最小)到2(最大)；\n",
        "(3) 三张：三张大小相同的牌；\n",
        "(4) 三张带一张：三张并带上任意一张牌，例如6-6-6-8，根据三张的大小来比较，例如9-9-9-3盖过8-8-8-A；\n",
        "(5) 三张带一对：三张并带上一对，类似扑克中的副路(Full House)，根据三张的大小比较，例如Q-Q-Q-6-6盖过10-10-10-K-K；\n",
        "(6) 顺子：至少5张连续大小(从3到A，2和王不能用)的牌，例如8-9-10-J-Q；\n",
        "(7) 连对：至少3个连续大小(从3到A，2和王不能用)的对子，例如10-10-J-J-Q-Q-K-K；\n",
        "(8) 三张的顺子：至少2个连续大小(从3到A)的三张，例如4-4-4-5-5-5；\n",
        "(9) 三张带一张的顺子：每个三张都带上额外的一个单张，例如7-7-7-8-8-8-3-6，尽管三张2不能用，但能够带上单张2和王；\n",
        "(10) 三张带一对的顺子：每个三张都带上额外的一对，只需要三张是连续的就行，例如8-8-8-9-9-9-4-4-J-J，尽管三张2不能用，但能够带上一对2【不能带一对王，因为两张王的大小不一样】，这里要注意，三张带上的单张和一对不能是混合的，例如3-3-3-4-4-4-6-7-7就是不合法的；\n",
        "(11) 炸弹：四张大小相同的牌，炸弹能盖过除火箭外的其他牌型，大的炸弹能盖过小的炸弹；\n",
        "(12) 火箭：一对王，这是最大的组合，能够盖过包括炸弹在内的任何牌型；\n",
        "(13) 四张套路(四带二)：有两种牌型，一个四张带上两个单张，例如6-6-6-6-8-9，或一个四张带上两对，例如J-J-J-J-9-9-Q-Q，四带二只根据四张的大小来比较，只能盖过比自己小的同样牌型的四带二【四张带二张和四张带二对属于不同的牌型，不能彼此盖过】，不能盖过其他牌型，四带二能被比自己小的炸弹盖过",
        }
    paixing = table.concat(paixingInfo,"")
    table.insert(infoArray,paixing)
    local intervalI = {0,2,2,5,3,2,3}
    local length = #titleArray
    for i=1,length do
        local height = 0
        for j=1,i do
            height = height + intervalI[j]
        end
        self.title1 = ccui.Text:create(titleArray[i],FONT_ART_TEXT,26)
        self.title1:setAnchorPoint(cc.p(0,1))
        self.title1:setPosition(0, custom_itemY-height*30)
        self.title1:setColor(cc.c3b(255,228,0))
        custom_item:addChild(self.title1)
        height = height +1
        self.infoText = ccui.Text:create("","",20)
        self.infoText:setPosition(0, custom_itemY-height*30)
        self.infoText:setAnchorPoint(cc.p(0,1))
        self.infoText:setColor(cc.c3b(249,247,123))
        self.infoText:setString(infoArray[i])
        self.infoText:setTextAreaSize(cc.size(860,500))
        self.infoText:ignoreContentAdaptWithSize(false)
        self.infoText:setTextHorizontalAlignment(0)
        self.infoText:setTextVerticalAlignment(0)
        custom_item:addChild(self.infoText)
    end
    self.listView:pushBackCustomItem(custom_item)


end
function HelpLayer:tabvipClickHandler()
	self.tab2ren:setHighlighted(false)
	self.tab3ren:setHighlighted(false)
	self.tabvip:setHighlighted(true)
    
    self.listView:removeAllItems()
    local custom_itemY = 305
    local custom_itemX = 860
    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
    custom_item:setAnchorPoint(cc.p(0,1))
    custom_item:setPosition(300, 100)
    -- custom_item:setBackGroundColorType(1)
    -- custom_item:setBackGroundColor(cc.c3b(100,123,100))
            

    local i = 0
    self.title1 = ccui.Text:create("玩法：",FONT_ART_TEXT,26)
    self.title1:setAnchorPoint(cc.p(0,1))
    self.title1:setPosition(0, custom_itemY-i*30)
    self.title1:setColor(cc.c3b(255,228,0))
    custom_item:addChild(self.title1)
    i = i +1
    self.infoText = ccui.Text:create("","",20)
    self.infoText:setPosition(0, custom_itemY-i*30)
    self.infoText:setAnchorPoint(cc.p(0,1))
    self.infoText:setColor(cc.c3b(249,247,123))
	self.infoText:setString("系统随机派发两张牌比大小，下注区域有地主、农民和平局三块区域，玩家可三方都下注，下注结束后，系统随机派发两张牌比大小，压中的区域获得翻倍奖励；在游戏的同时，还可和主播互动聊天、赠送主播玫瑰道具等；")
    self.infoText:setTextAreaSize(cc.size(860,305))
    self.infoText:ignoreContentAdaptWithSize(false)
    self.infoText:setTextHorizontalAlignment(0)
    self.infoText:setTextVerticalAlignment(0)
    custom_item:addChild(self.infoText)
    i = i +1+2

    self.title2 = ccui.Text:create("下注：",FONT_ART_TEXT,26)
    self.title2:setAnchorPoint(cc.p(0,1))
    self.title2:setPosition(0, custom_itemY-i*30)
    self.title2:setColor(cc.c3b(255,228,0))
    custom_item:addChild(self.title2)
    i = i +1

    self.infoText = ccui.Text:create("","",20)
    self.infoText:setPosition(0, custom_itemY-i*30)
    self.infoText:setAnchorPoint(cc.p(0,1))
    self.infoText:setColor(cc.c3b(249,247,123))
    self.infoText:setString("下注在地主或者农民区域，比牌时，平局，押注的金币，系统会退还给玩家；")
    self.infoText:setTextAreaSize(cc.size(860,305))
    self.infoText:ignoreContentAdaptWithSize(false)
    self.infoText:setTextHorizontalAlignment(0)
    self.infoText:setTextVerticalAlignment(0)
    custom_item:addChild(self.infoText)

    self.listView:pushBackCustomItem(custom_item)
end
return HelpLayer