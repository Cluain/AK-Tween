----------------------------------------------------------------------------
--PROJECT: AKTWEEN v0.4
--AUTHOR: ARDENTKID (OMID AHOURAI)
--http://www.ardentkid.com
--
--THIS LIBRARY IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
--
--Easing functions adapted from Robert Penner's AS3 tweening equations.
----------------------------------------------------------------------------
--
--TODO (AS OF 11/14/2012):
--
--ADD IN-OUT-QUAD EASING
--ADD DELAY PARAMETERS
--ADD BOUNCING/ REFLECT
--ADD TWEEN LOOPING
--ADD PROPER DESTROY FUNCTIONS
--alpha={start, finish}
--xScale={start, finish}
--yScale={start, finish}
----------------------------------------------------------------------------

local AKtween={
    pauseAll = false,
    registered = {},
    unregister = {}
}

local function calcArr(arr, accumulative, time, to, totFrames, step, ease, from, nonZero)
    local ct = #arr
    local startArr
    if (ct>0) then startArr,from = ct,arr[ct] else startArr,from = 0,from or 0 end
    local pos = 0
    local delta = to - from

    if (accumulative) then
        if (ease == 'outQuad') then
            for i=1,totFrames do
                pos = pos + step
                local index = i +startArr
                local ratio = -pos*(pos-2)
                local result = from + (ratio * delta)
                if (nonZero) then if (result == 0) then result = 0.001 end end
                arr[index] = result
            end
        elseif (ease == 'inQuad') then
            for i=1,totFrames do
                pos = pos + step
                local index = i +startArr
                local ratio = pos*pos
                local result = from + (ratio * delta)
                if (nonZero) then if (result == 0) then result = 0.001 end end
                arr[index] = result
            end
        elseif ((ease == 'linear') or (not ease)) then
            for i=1,totFrames do
                pos = pos + step
                local index = i +startArr
                local result = from + (pos * delta)
                if (nonZero) then if (result == 0) then result = 0.001 end end
                arr[index] = result
            end
        end
    else
        local sign
        if (delta > 0) then sign = 1 else sign = -1 end
        if (ease == 'outQuad') then
            for i=1,totFrames do
                pos = pos + step
                local index = i +startArr
                local ratio = -2*(pos -1)
                arr[index] = -ratio *2.5
            end
        elseif (ease == 'inQuad') then
            for i=1,totFrames do
                pos = pos + step * sign
                local index = i +startArr
                local ratio = 2*pos
                arr[index] = ratio *2.5
            end
        elseif ((ease == 'linear') or (not ease)) then
            local val = step * delta
            for i=1,totFrames do
                local index = i +startArr
                arr[index] = val
            end
        end
    end

end

local function tweenCalc(config, arr, fCheck)
    if (not arr) then arr = {} end
    -- if (not arr) then arr = {} end

    local time = config.time or 1000
    local ease = config.ease
    local totFrames = 0.06 * time
    local step = 1/totFrames
    local delay
    local finishCheck = fCheck or {x = 0, y = 0, rotation = 0}
    if (config.delay) then
        delay = 0.06*config.delay
    end


    local x = config.x
    if (x) then
        local xArr = arr.x or {}
        if (delay) then
            local idx = #xArr + 1
            for i = 1, delay do
                xArr[idx] = 0
                idx = idx + 1
            end
        end
        finishCheck.x = finishCheck.x + x
        calcArr(xArr, false, time, x, totFrames, step, ease)
        arr.x = xArr
    end

    local y = config.y
    if (y) then
        local yArr = arr.y or {}
        if (delay) then
            local idx = #yArr + 1
            for i = 1, delay do
                yArr[idx] = 0
                idx = idx + 1
            end
        end
        finishCheck.y = finishCheck.y + y
        calcArr(yArr, false, time, y, totFrames, step, ease)
        arr.y = yArr
    end

    local rotation = config.rotation
    if (rotation) then
        local rotArr = arr.rotation or {}
        if (delay) then
            local idx = #rotArr + 1
            for i = 1, delay do
                rotArr[idx] = 0
                idx = idx + 1
            end
        end
        finishCheck.rotation = finishCheck.rotation + rotation
        calcArr(rotArr, false, time, rotation, totFrames, step, ease)
        arr.rotation = rotArr
    end

    local xScale = config.xScale
    if (xScale) then
        local from, to
        local xSclArr = arr.xScale or {}
        if (type(xScale) == "table") then
            from = xScale.from
            to = xScale.to
        else
            from = 1
            to = xScale
        end
        if (delay) then
            local idx = #xSclArr + 1
            for i = 1, delay do
                xSclArr[idx] = from
                idx = idx + 1
            end
        end
        calcArr(xSclArr, true, time, to, totFrames, step, ease, from, true)
        arr.xScale = xSclArr
    end

    local yScale = config.yScale
    if (yScale) then
        local from, to
        local ySclArr = arr.yScale or {}
        if (type(yScale) == "table") then
            from = yScale.from
            to = yScale.to
        else
            from = 1
            to = yScale
        end
        if (delay) then
            local idx = #ySclArr + 1
            for i = 1, delay do
                ySclArr[idx] = from
                idx = idx + 1
            end
        end
        calcArr(ySclArr, true, time, to, totFrames, step, ease, from, true)
        arr.yScale = ySclArr
    end

    local alpha = config.alpha
    if (alpha) then
        local from, to
        local alphaArr = arr.alpha or {}
        if (type(alpha) == "table") then
            from = alpha.from
            to = alpha.to
        else
            from = 1
            to = alpha
        end
        if (delay) then
            local idx = #alphaArr + 1
            for i = 1, delay do
                alphaArr[idx] = from
                idx = idx + 1
            end
        end
        calcArr(alphaArr, true, time, to, totFrames, step, ease, from)
        arr.alpha = alphaArr
    end

    local xTot, yTot, rotTot, xSclTot, ySclTot, aTot
    for k,v in pairs(arr) do
        local tot = #v
        if (tot > totFrames) then totFrames = tot end
    end

    -- anim.totFrames = totFrames
    -- anim.arr = arr

    local onComplete = config.onComplete
    if (onComplete) then arr, totFrames, finishCheck = tweenCalc(onComplete, arr, finishCheck) end

    return arr, totFrames, finishCheck
end


function AKtween:enterFrame(event)
    if (not self.pauseAll) then
        local registered = self.registered
        local unregister = self.unregister

        for i=1,#registered do
            local obj = registered[i]
            local curTween = obj.curTween
            if (curTween) then
                local tot = obj.tweenTot
                local ct = obj.tweenCount

                if (ct == 1) then
                    obj.tweenCheck = {}
                    for k,v in pairs(curTween) do
                        obj.tweenCheck[k] = obj[k]
                    end
                end

                for k,v in pairs(curTween) do
                    local value = v[ct]
                    if (value) then
                        if (k == 'x') then obj:translate(value,0)
                        elseif (k == 'y') then obj:translate(0,value)
                        elseif (k == 'rotation') then obj:rotate(value)
                        else obj[k] = value end
                    end
                end
                ct = ct +1
                if (ct > tot) then
                    if (obj.tweenRepeat) then ct = 1
                    else table.insert(unregister, obj) end
                    for k,v in pairs(curTween) do
                        local value = obj.tweenFinishedCheck[k]
                        if (value) then
                            if (obj.tweenCheck[k] + value ~= obj[k]) then
                                obj[k] = obj.tweenCheck[k] + value
                            end
                        end
                    end
                end
                obj.tweenCount = ct
            end
        end

        for i=1,#unregister do
            local obj = unregister[i]
            obj:finishTween()
        end
    end
end

function AKtween:newTween(config)
    local tween = {}
    tween.apply = self.apply
    tween.append = self.append
    tween:append(config)
    return tween
end

function AKtween:append(config)
    if (config) then
        local values, totFrames, finishCheck = tweenCalc(config, self.values, self.finishCheck)
        self.values, self.totFrames, self.finishCheck = values, totFrames, finishCheck
    else print('AKtween: Tween configuration failed.') end
end

function AKtween:apply(obj, name)
    obj.curTween = nil
    local anims = obj.anims or {}
    local anim = anims[name] or {}
    anim.values = self.values
    anim.totFrames = self.totFrames
    anim.finishCheck = self.finishCheck
    anims[name] = anim
    obj.anims = anims
    obj.playTween = AKtween.playTween
    obj.finishTween = AKtween.finishTween
end

function AKtween:playTween(name, config)
    local anim = self.anims[name]
    if (anim) then
        self.curTween = anim.values
        self.tweenFinishedCheck = anim.finishCheck
        self.tweenCount = 1
        self.tweenTot = anim.totFrames
        if (config) then
            self.tweenRepeat = config.repeats
            self.onComplete = config.onComplete
        else
            self.tweenRepeat = nil
            self.onComplete = nil
        end
        table.insert(AKtween.registered, self)
    else print('AKtween: object tween '..name..' does not exist') end
end

function AKtween:finishTween()
    self.curTween = nil
    self.tweenCount = 1
    table.remove(AKtween.registered, table.indexOf(AKtween.registered, self))
    table.remove(AKtween.unregister, table.indexOf(AKtween.unregister, self))
    if (self.onComplete) then self.onComplete() end
end

Runtime:addEventListener('enterFrame', AKtween)

return AKtween
