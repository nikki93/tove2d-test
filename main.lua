local tove = require 'tove'

local function loadDrawing(path)
    local drawing = tove.newGraphics(love.filesystem.newFileData(path):getString(), 400)
    drawing:setResolution(2)
    --drawing:setUsage('points', 'dynamic')
    --drawing:setDisplay('mesh', 1024)
    return drawing
end

local drawing1 = loadDrawing('basketball-layered.svg')
local drawing2 = loadDrawing('cart-2.svg')
local drawing3 = loadDrawing('hole-2.svg')
local drawing4 = loadDrawing('soccer_goal-2.svg')

--local blocks = {}
--for i = 1, 20 do
--    blocks[i] = {
--        x = 200 + 400 * math.random(),
--        phase1 = 2 * math.pi * math.random(),
--        phase2 = 2 * math.pi * math.random(),
--        rate1 = 0.08 + 0.8 * (2 * math.random() - 1),
--        rate2 = 0.08 + 0.8 * (2 * math.random() - 1),
--        scale = 0.2 + 0.8 * math.random(),
--    }
--end
--
local AMOUNT = 3
local FRAMES = 20
local TWEEN = 2
local SPEED = 8
local POINTS = false

local function wobbleDrawing(drawing, amount)
    amount = amount or 3
    local frames = {}
    for f = 1, FRAMES do
        local clone = drawing:clone()
        for i = 1, clone.paths.count do
            for j = 1, clone.paths[i].subpaths.count do
                for k = 1, clone.paths[i].subpaths[j].curves.count do
                    local curve = clone.paths[i].subpaths[j].curves[k]
                    curve.cp1x = curve.cp1x + amount * (2 * math.random() - 1)
                    curve.cp1y = curve.cp1y + amount * (2 * math.random() - 1)
                    curve.cp2x = curve.cp2x + amount * (2 * math.random() - 1)
                    curve.cp2y = curve.cp2y + amount * (2 * math.random() - 1)
                    if POINTS then
                        curve.x0 = curve.x0 + amount * (2 * math.random() - 1)
                        curve.y0 = curve.y0 + amount * (2 * math.random() - 1)
                        curve.x = curve.x + amount * (2 * math.random() - 1)
                        curve.y = curve.y + amount * (2 * math.random() - 1)
                    end
                end
            end
        end
        table.insert(frames, clone)
    end
    local tween = tove.newTween(frames[1])
    for i = 2, #frames do
        tween = tween:to(frames[i], 1)
    end
    tween = tween:to(frames[1], 1)
    return tove.newFlipbook(TWEEN, tween)
end

local flipbook1, flipbook2, flipbook3, flipbook4, flipbook5

local function createFlipbooks()
    flipbook1 = wobbleDrawing(drawing1, 2 * AMOUNT)
    flipbook2 = wobbleDrawing(drawing2, 2 * AMOUNT)
    flipbook3 = wobbleDrawing(drawing3, 2 * AMOUNT)
    flipbook4 = wobbleDrawing(drawing4, 2 * AMOUNT)

    flipbook5 = wobbleDrawing(drawing1, AMOUNT)
end

createFlipbooks()

function love.draw()
    love.graphics.clear(0, 0.49, 0.204)

    love.graphics.push('all')

    local t = love.timer.getTime()

    flipbook1.t = (SPEED * t) % flipbook1._duration
    flipbook2.t = (SPEED * t) % flipbook2._duration
    flipbook3.t = (SPEED * t) % flipbook3._duration
    flipbook4.t = (SPEED * t) % flipbook4._duration

    flipbook5.t = (SPEED * t) % flipbook5._duration

    --for _, block in ipairs(blocks) do
    --    love.graphics.push()
    --    love.graphics.translate(block.x, 0.5 * 450 * (math.sin(block.phase1 + block.rate1 * t) + 1))
    --    love.graphics.rotate(block.phase2 + block.rate2 * t)
    --    love.graphics.scale(block.scale)
    --    flipbook1:draw()
    --    love.graphics.pop()
    --end

    local W, H = love.graphics.getDimensions()

    flipbook5:draw(0.5 * W, 0.5 * H, 0, 0.6, 0.6)

    flipbook1:draw(0.25 * W, 0.25 * H, 0, 0.25, 0.25)
    flipbook2:draw(0.75 * W, 0.25 * H, 0, 0.25, 0.25)
    flipbook3:draw(0.25 * W, 0.75 * H, 0, 0.25, 0.25)
    flipbook4:draw(0.75 * W, 0.75 * H, 0, 0.25, 0.25)

    love.graphics.pop('all')

    love.graphics.print('fps: ' .. love.timer.getFPS(), 20, 20)
end

local nextReload = 0

function love.update(dt)
    if nextReload > 0 then
        nextReload = nextReload - dt
        if nextReload <= 0 then
            nextReload = 0
            createFlipbooks()
        end
    end
end

local ui = castle.ui

function castle.uiupdate()
    ui.slider('amount', AMOUNT, 0.2, 8, {
        step = 0.1,
        onChange = function(newAmount)
            AMOUNT = newAmount
            nextReload = 0.15
        end,
    })

    ui.slider('frames', FRAMES, 2, 24, {
        onChange = function(newFrames)
            FRAMES = newFrames
            nextReload = 0.15
        end,
    })

    ui.slider('tween', TWEEN, 1, 4, {
        onChange = function(newTween)
            TWEEN = newTween
            nextReload = 0.15
        end,
    })

    ui.slider('speed', SPEED, 0.1, 40, {
        step = 0.1,
        onChange = function(newSpeed)
            SPEED = newSpeed
        end,
    })

    ui.toggle('control points only', 'control points and vertices', POINTS, {
        onToggle = function(newPoints)
            POINTS = newPoints
            createFlipbooks()
        end,
    })
end

