SoundManager = {}

function SoundManager.loadConfig()
    --初始化音乐开启
    SoundManager.bOpenMusic = cc.UserDefault:getInstance():getIntegerForKey("Music",1);--背景音乐
    SoundManager.bOpenSound = cc.UserDefault:getInstance():getIntegerForKey("Sound",1);--音效
    audio.setMusicVolume(0.3)
    audio.setSoundsVolume(1.0)
end


function SoundManager.saveMusicSwitch(isMusicOpen)
    SoundManager.bOpenMusic = isMusicOpen
    cc.UserDefault:getInstance():setIntegerForKey("Music", isMusicOpen)
end

function SoundManager.saveSoundSwitch(isSoundOpen)
    SoundManager.bOpenSound = isSoundOpen
    cc.UserDefault:getInstance():setIntegerForKey("Sound", isSoundOpen)
end

function SoundManager.isMusicOpen()
    return SoundManager.bOpenMusic
end

function SoundManager.isSoundOpen()
    return SoundManager.bOpenSound
end

function SoundManager.setSoundVolume(v)
    audio.setSoundsVolume(v);
end

function SoundManager.playSound(fileName,loop)
    loop = loop or false
    if SoundManager.bOpenSound == 1 then
        SoundManager.lastSound = audio.playSound(fileName,loop);
    end
end

function SoundManager.stopLastSound()

    if SoundManager.lastSound ~= nil then
        audio.stopSound(SoundManager.lastSound);
        SoundManager.lastSound = nil;
    end

end

function SoundManager.setMusicVolume(v)
    audio.setMusicVolume(v);
end

function SoundManager.playMusic(fileName,loop)
    loop = loop or false
    if SoundManager.bOpenMusic == 1 then
        audio.playMusic(fileName,loop);
    end
end

function SoundManager.stopMusic()
    if SoundManager.bOpenMusic == 1 then
        audio.stopMusic();
    end
end
--大厅背景音效
function SoundManager.playMusicInHall()
    if SoundManager.bOpenMusic == 1 then
        local fileName = "sound/hallbgm.mp3";--"sound/play3_normal" .. math.random(1,3) .. ".mp3"
        audio.playMusic(fileName,true);
    end
end
--三人场背景音效
function SoundManager.playMusicInPlay3()
    if SoundManager.bOpenMusic == 1 then
        local fileName = "sound/gamebgm.mp3";--"sound/play3_normal" .. math.random(1,3) .. ".mp3"
        audio.playMusic(fileName,true);
    end
end
-------------炸金花音效start----------------
function SoundManager.playSendCard()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/SEND_CARD.wav"
        audio.playSound(file)
    end
end
function SoundManager.playAddScore()
    if SoundManager.bOpenSound == 1 then
        -- local file = "sound/ADD_SCORE.wav"
        local file = "sound/poker-chips.mp3"
        audio.playSound(file)
    end
end
function SoundManager.playGameStart()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/GAME_START.wav"
        audio.playSound(file)
    end
end
function SoundManager.playGameEnd()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/GAME_END.wav"
        audio.playSound(file)
    end
end
function SoundManager.playCompareCard()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/COMPARE_CARD.wav"
        audio.playSound(file)
    end
end
function SoundManager.playCenterSendCard()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/CENTER_SEND_CARD.wav"
        -- local file = "sound/CENTER_SEND_CARD.mp3"
        audio.playSound(file)
    end
end
function SoundManager.playGiveUP()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/GIVE_UP.wav"
        audio.playSound(file)
    end
end
function SoundManager.playGameWin()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/GAME_WIN.wav"
        audio.playSound(file)
    end
end
function SoundManager.playGameLost()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/GAME_LOST.wav"
        audio.playSound(file)
    end
end
function SoundManager.playGameWarn()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/GAME_WARN.wav"
        audio.playSound(file)
    end
end
function SoundManager.playBaoZha()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/baozha.aac"
        audio.playSound(file)
    end
end
function SoundManager.playLight()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/light.aac"
        audio.playSound(file)
    end
end
--金花游戏中背景音乐
function SoundManager.play3CardBackGround()
    if SoundManager.bOpenMusic == 1 then
        -- local file = "sound/cc3card_background_music.aac"
        local file = "sound/3cardGameBg.mp3"
        audio.playMusic(file,true)
    end
end
--金花大厅背景音乐
function SoundManager.play3CardHallBackGround()
    print("SoundManager.bOpenSound",SoundManager.bOpenSound)
    if SoundManager.bOpenMusic == 1 then
        local file = "sound/3cardHallBg.mp3"
        audio.playMusic(file,true)
    end
end
function SoundManager.playOnMyTurn()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/onMyTurn.mp3"
        audio.playSound(file)
    end
end
function SoundManager.playShowCards()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/showCards.mp3"
        audio.playSound(file)
    end
end
function SoundManager.playGetChip()
    if SoundManager.bOpenSound == 1 then
        local file = "sound/ADD_SCORE.wav"
        audio.playSound(file)
    end
end
function SoundManager.playSendProperty(giftIndex)
    if SoundManager.bOpenSound == 1 then
        if giftIndex then
            local file = nil
            if giftIndex == 100 then--鸡蛋
                file = "sound/property/egg.mp3"
            elseif giftIndex == 103 then--飞刀
                file = "sound/property/knife.mp3"
            elseif giftIndex == 104 then--炸弹
                file = "sound/property/booom.mp3"
            elseif giftIndex == 106 then--玫瑰
                file = "sound/property/flower.mp3"
            elseif giftIndex == 110 then--名表
                file = "sound/property/flower.mp3"
            elseif giftIndex == 205 then--汽车
                file = "sound/property/car.mp3"
            end
            audio.playSound(file)
        end
    end
end
-------------炸金花音效end----------------

function SoundManager.playEfectBaoJing(sex, num)
    if SoundManager.bOpenSound == 1 then
        local file = "sound"
        if sex == 1 then
            file = file .. "/man/Man_"
        else
            file = file .. "/woman/Woman_"
        end
        file = file .. "baojing" .. num .. ".mp3"
        print("playEfectBaoJing!!file ＝ ", file)

        audio.playSound(file)
    end
end
--叫地主音效
--@para sex 性别
--@para kind 0不叫，1叫
function SoundManager.playEffectJDZ(sex,kind)   
    if SoundManager.bOpenSound == 1 then
        local file = "sound"
        if sex == 1 then
            file = file .. "/man/Man_"
        else
            file = file .. "/woman/Woman_"
        end
        if kind == 0 then
            file = file .. "NoOrder.mp3"
        elseif kind == 1 then
            file = file .. "Order.mp3"
        else
            -- file = file .. "NoOrder.mp3"
        end
        
        print("playEffectJDZ!!file ＝ ", file,"kind",kind)

        audio.playSound(file)
    end
end
--抢地主音效
--@para sex 性别
--@para kind 0不抢，1，2，3抢
function SoundManager.playEffectQDZ(sex,kind)
    if SoundManager.bOpenSound == 1 then
        local file = "sound"
        if sex == 1 then
            file = file .. "/man/Man_"
        else
            file = file .. "/woman/Woman_"
        end
        if kind == 0 then
            file = file .. "NoRob.mp3"
        elseif kind == 1 then
            file = file .. "Rob" .. kind .. ".mp3"
        elseif kind == 2 then
            file = file .. "Rob" .. kind .. ".mp3"
        elseif kind == 3 then
            file = file .. "Rob" .. kind .. ".mp3"
        else
            -- file = file .. "NoRob.mp3"
        end
        print("playEffectQDZ!!file ＝ ", file,"kind",kind)

        audio.playSound(file)
    end
end
function SoundManager.playEffectByName(name, sex)
    if SoundManager.bOpenSound == 1 then
        local file = "sound"
        if sex == 1 then
            file = file .. "/man/Man_"
        else
            file = file .. "/woman/Woman_"
        end

        if name == "pass" then
            file = file .. "buyao" .. math.random(1,4) .. ".mp3"

        elseif name == "0fen" then
            file = file .. "score0.mp3"

        elseif name == "1fen" then
            file = file .. "score1.mp3"

        elseif name == "2fen" then
            file = file .. "score2.mp3"

        elseif name == "3fen" then
            file = file .. "score3.mp3"
        end
        audio.playSound(file)
    end
end

function SoundManager.playSoundByType(cardType, num, sex)
    if SoundManager.bOpenSound == 1 then

        local file = "sound"
        if sex == 1 then
            file = file .. "/man/Man_"
        else
            file = file .. "/woman/Woman_"
        end

        if cardType == CARDS_TYPE.CT_1 then--单张
            file = file .. num .. ".mp3"

        elseif cardType == CARDS_TYPE.CT_2 then --一对
            file = file .. "dui" .. num .. ".mp3"

        elseif cardType == CARDS_TYPE.CT_3 then --三张
            file = file .. "tuple" .. num .. ".mp3"

        elseif cardType == CARDS_TYPE.CT_4 then --四炸
            file = file .. "zhadan.mp3"

        elseif cardType == CARDS_TYPE.CT_5 then --王炸
            file = file .. "wangzha.mp3"

        elseif cardType == CARDS_TYPE.CT_1S then--单顺
            file = file .. "shunzi.mp3"

        elseif cardType == CARDS_TYPE.CT_2S then--双顺
            file = file .. "liandui.mp3"

        elseif cardType == CARDS_TYPE.CT_3S then--三顺

        elseif cardType == CARDS_TYPE.CT_3S1 then--三带一
            file = file .. "sandaiyi.mp3"

        elseif cardType == CARDS_TYPE.CT_3S2 then--三带一对
            file = file .. "sandaiyidui.mp3"

        elseif cardType == CARDS_TYPE.CT_3S3 then--飞机
            file = file .. "feiji.mp3"

        elseif cardType == CARDS_TYPE.CT_4S1 then--四带2张
            file = file .. "sidaier.mp3"

        elseif cardType == CARDS_TYPE.CT_4S2 then--四带2对
            file = file .. "sidailiangdui.mp3"
            
        end

        print("!!!!!!!!!!!!!file ＝ ", file)
        audio.playSound(file)

    end

end