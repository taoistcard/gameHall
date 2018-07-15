local FansRankItemLayer = class("FansRankItemLayer", function() return display.newLayer(); end );

function FansRankItemLayer:ctor()
    self:setContentSize(cc.size(530,135))
    self:createUI()
end

function FansRankItemLayer:createUI()
    local fansRankItemBg = ccui.ImageView:create("landlordVideo/fansRank/fansRankItemBg.png")
    fansRankItemBg:setScale9Enabled(true)
    fansRankItemBg:setContentSize(cc.size(540,126))
    fansRankItemBg:setPosition(cc.p(265,68))
    self:addChild(fansRankItemBg)
    --1，2，3图片
    local rankImg = ccui.ImageView:create("landlordVideo/fansRank/fansRank_top1.png")
    rankImg:setPosition(cc.p(80,63))
    fansRankItemBg:addChild(rankImg)
    self.rankImg = rankImg
    --4及其以后文字
    local rankTxt = ccui.Text:create("11",FONT_ART_TEXT,32)
    rankTxt:setPosition(cc.p(80,63))
    fansRankItemBg:addChild(rankTxt)
    self.rankTxt = rankTxt
    --头像
    local headBorder = ccui.ImageView:create("landlordVideo/selfhead_border.png")
    headBorder:setScale9Enabled(true)
    headBorder:setContentSize(cc.size(96,96))
    headBorder:setCapInsets(cc.rect(19,20,1,1))
    headBorder:setPosition(cc.p(170,60))
    fansRankItemBg:addChild(headBorder)
    --头像👦
    local headView = require("commonView.GameHeadView").new(1);
    headView:addTo(headBorder)
    headView:setPosition(cc.p(44,52))
    self.headImage = headView
    -- local headImage = ccui.ImageView:create("head/default.png")
    -- headImage:setScale(0.66)
    -- headImage:setPosition(cc.p(44,52))
    -- headBorder:addChild(headImage)
    -- self.headImage = headImage
    -- local vipImage = ccui.ImageView:create()
    -- vipImage:setPosition(cc.p(90,100))
    -- headBorder:addChild(vipImage)
    -- self.vipImage = vipImage
    --昵称
    self.nickNameLabel = ccui.Text:create()
    self.nickNameLabel:setString("百人斗地主")
    self.nickNameLabel:setFontSize(22)
    self.nickNameLabel:setColor(cc.c4b(255,237,86,255))
    self.nickNameLabel:enableOutline(cc.c4b(7,1,3,255), 2)
    self.nickNameLabel:setAnchorPoint(cc.p(0,0.5))
    self.nickNameLabel:setPosition(cc.p(230,85))
    fansRankItemBg:addChild(self.nickNameLabel)
    --金币
    local goldImage = ccui.ImageView:create()
    goldImage:loadTexture("common/gold.png")
    goldImage:setPosition(cc.p(225,45))
    goldImage:setScale(0.6)
    goldImage:setAnchorPoint(cc.p(0,0.5))
    fansRankItemBg:addChild(goldImage)
    self.goldLabel = ccui.Text:create()
    self.goldLabel:setString("9999.9万")
    self.goldLabel:setFontSize(22)
    self.goldLabel:setColor(cc.c3b(253,253,253))
    self.goldLabel:enableOutline(cc.c4b(0,4,8,255), 2)
    self.goldLabel:setAnchorPoint(cc.p(0,0.5))
    self.goldLabel:setPosition(cc.p(260,45))
    fansRankItemBg:addChild(self.goldLabel)
    --魅力值

    self.loveLabel = ccui.Text:create()
    self.loveLabel:setString("9999.9万")
    self.loveLabel:setFontSize(22)
    self.loveLabel:setColor(cc.c3b(0,255,0))
    self.loveLabel:enableOutline(cc.c4b(0,4,8,255), 2)
    self.loveLabel:setPosition(cc.p(440,65))
    fansRankItemBg:addChild(self.loveLabel)
end

--     required int32              dwUserID        = 1;
--     required int32              wFaceID         = 2;
--     required int32              cbMemberOrder       = 3;
--     required int64              dwScore         = 4;    
--     required string             szNickName      = 5;
--     required int64              dwPositiveLoveLiness    = 6;        //赠送好道具的魅力分
--     required int64              dwNegativeLoveLiness    = 7;        //赠送差道具的魅力分
--     required int64              dwAtLastLoveLiness  = 8;        //赠送好道具的魅力分 - 赠送差道具的魅力分
--     required int64              dwVIPTotalPropertyScore = 9;        //累积分
--     required string             szTokenID       = 10;
--     required string             szUesrHeadFileName  = 11;
function FansRankItemLayer:updateRankItem(rankItem,index)
    self.rankTxt:setVisible(false)
    self.rankImg:setVisible(false)
    if index <= 3 then
    	self.rankImg:setVisible(true)
    	self.rankImg:loadTexture("landlordVideo/fansRank/fansRank_top"..index..".png")
    else
        self.rankTxt:setVisible(true)
    	self.rankTxt:setString(index)
    end
    print("updateRankItem:",rankItem.wFaceID, rankItem.szTokenID, rankItem.szUesrHeadFileName)
    self.headImage:setNewHead(rankItem.wFaceID, rankItem.szTokenID, rankItem.szUesrHeadFileName)
    --VIP
    self.headImage:setVipHead(rankItem.cbMemberOrder, 1)

    self.nickNameLabel:setString(FormotGameNickName(rankItem.szNickName,6))
    self.goldLabel:setString(FormatDigitToString(rankItem.dwScore, 1))
    self.loveLabel:setString(rankItem.dwAtLastLoveLiness)
end

return FansRankItemLayer
