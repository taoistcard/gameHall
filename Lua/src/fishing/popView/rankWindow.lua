local RankWindow = class("RankWindow", require("show.popView_Hall.baseWindow") );

function RankWindow:ctor(mode)

    self.super.ctor(self,mode);

    local size = self:getContentSize();

    local title = display.newSprite("popView/titleRank.png", size.width/2, size.height/2+250);
    self:addChild(title);
    
    self:requestRankinfo();

end

function RankWindow:requestRankinfo()

    local waitlayer = require("popView.waitingWindow").new();
    waitlayer:showWaiting();
    waitlayer:timeoutDelegate(self);
    self:addChild(waitlayer);
    self.waitlayer = waitlayer;

    RankingInfo:sendScoreActivityRequest();

    self.bindid = BindTool.bind(RankingInfo, "wealthRankList", handler(self, self.refreshRanking));



end

function RankWindow:timeoutCallback()

    BindTool.unbind(self.bindid);

end

function RankWindow:refreshRanking()

    BindTool.unbind(self.bindid);
    self.waitlayer:dismiss();
    
    -- for k,v in pairs(RankingInfo.wealthRankList) do
    --     for kk,vv in pairs(v) do
    --         print(kk,vv)
    --     end
    -- end

    self:refreshRankingTable();

end

function RankWindow:refreshRankingTable()

    if self.rankContainer then
        self.rankContainer:removeFromParent();
        self.rankContainer = nil;
    end

    local rankContainer = display.newLayer();
    self.contentNode:addChild(rankContainer);
    self.rankContainer = rankContainer;

    local listView = ccui.ListView:create();
    listView:setDirection(ccui.ScrollViewDir.vertical);
    listView:setBounceEnabled(true);
    listView:setContentSize(cc.size(600,420));
    listView:setAnchorPoint(cc.p(0,0));
    listView:setPosition(cc.p(60,45));
    rankContainer:addChild(listView);


    -- local shape = display.newRect(cc.rect(60, 45, 600, 420),
    --     {fillColor = cc.c4f(1,0,0,1), borderColor = cc.c4f(0,1,0,1), borderWidth = 0});
    -- rankContainer:addChild(shape);




    for i, info in ipairs(RankingInfo.wealthRankList) do


        local item = ccui.Layout:create();
        item:setContentSize(cc.size(600,100));

        local insidebg = ccui.ImageView:create("common/ty_scale_bg_1.png");
        insidebg:setScale9Enabled(true);
        insidebg:setContentSize(cc.size(580,94));
        insidebg:setPosition(cc.p(300,47));
        item:addChild(insidebg);

        local rankLabel = display.newTTFLabel({text = i..".",
                                            size = 27,
                                            color = cc.c3b(240,240,50),
                                            font = "fonts/FZPTYJW.TTF",
                                            align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                        })
        rankLabel:enableOutline(cc.c4b(0,0,0,255*0.7),2);
        rankLabel:setPosition(cc.p(60,47));
        item:addChild(rankLabel);

        if i <= 3 then

            rankLabel:setVisible(false);
            local rankSp = ccui.ImageView:create("popView/rank"..i..".png");
            rankSp:setPosition(cc.p(60,47));
            item:addChild(rankSp);

        end

        local nickNameLabel = display.newTTFLabel({text = FormotGameNickName(info.nickName,6),
                                            size = 26,
                                            color = cc.c3b(240,240,50),
                                            font = "fonts/FZPTYJW.TTF",
                                            align = cc.ui.TEXT_ALIGN_LEFT -- 文字内部居中对齐
                                        })
        nickNameLabel:enableOutline(cc.c4b(0,0,0,255*0.7),2);
        nickNameLabel:align(display.LEFT_CENTER, 100, 47)
        item:addChild(nickNameLabel);

        local scoreSp = ccui.ImageView:create("common/ty_coin.png");
        scoreSp:setPosition(cc.p(330,47));
        item:addChild(scoreSp);

        local scoreLabel = display.newTTFLabel({text = info.score,
                                            size = 24,
                                            color = cc.c3b(240,240,50),
                                            font = "fonts/FZPTYJW.TTF",
                                            align = cc.ui.TEXT_ALIGN_LEFT -- 文字内部居中对齐
                                        })
        scoreLabel:enableOutline(cc.c4b(0,0,0,255*0.7),2);
        scoreLabel:align(display.LEFT_CENTER, 350, 47)
        item:addChild(scoreLabel);

        
        listView:pushBackCustomItem(item);

    end


end




return RankWindow;