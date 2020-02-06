local tove = require 'tove'

local function loadDrawing(path)
    local drawing = tove.newGraphics(love.filesystem.newFileData(path):getString(), 400)
    drawing:setResolution(2)
    --drawing:setUsage('points', 'dynamic')
    --drawing:setDisplay('mesh', 1024)
    return drawing
end

local drawing1 = loadDrawing('basketball-2.svg')
local drawing2 = loadDrawing('cart-2.svg')
local drawing3 = loadDrawing('hole-2.svg')
local drawing4 = loadDrawing('soccer_goal-2.svg')

local blocks = {}
for i = 1, 20 do
    blocks[i] = {
        x = 200 + 400 * math.random(),
        phase1 = 2 * math.pi * math.random(),
        phase2 = 2 * math.pi * math.random(),
        rate1 = 0.08 + 0.8 * (2 * math.random() - 1),
        rate2 = 0.08 + 0.8 * (2 * math.random() - 1),
        scale = 0.2 + 0.8 * math.random(),
    }
end

local function wobbleDrawing(drawing, amount)
    amount = amount or 3
    local frames = {}
    for f = 1, 20 do
        local clone = drawing:clone()
        for i = 1, clone.paths.count do
            for j = 1, clone.paths[i].subpaths.count do
                for k = 1, clone.paths[i].subpaths[j].curves.count do
                    local curve = clone.paths[i].subpaths[j].curves[k]
                    curve.cp1x = curve.cp1x + amount * (2 * math.random() - 1)
                    curve.cp1y = curve.cp1y + amount * (2 * math.random() - 1)
                    curve.cp2x = curve.cp2x + amount * (2 * math.random() - 1)
                    curve.cp2y = curve.cp2y + amount * (2 * math.random() - 1)
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
    return tove.newFlipbook(2, tween)
end

local flipbook1 = wobbleDrawing(drawing1, 6)
local flipbook2 = wobbleDrawing(drawing2, 6)
local flipbook3 = wobbleDrawing(drawing3, 6)
local flipbook4 = wobbleDrawing(drawing4, 6)

local flipbook5 = wobbleDrawing(drawing1, 3)

function love.draw()
    love.graphics.clear(0, 0.49, 0.204)

    love.graphics.push('all')

    local t = love.timer.getTime()

    flipbook1.t = (8 * t) % flipbook1._duration
    flipbook2.t = (8 * t) % flipbook2._duration
    flipbook3.t = (8 * t) % flipbook3._duration
    flipbook4.t = (8 * t) % flipbook4._duration

    flipbook5.t = (8 * t) % flipbook5._duration

    --for _, block in ipairs(blocks) do
    --    love.graphics.push()
    --    love.graphics.translate(block.x, 0.5 * 450 * (math.sin(block.phase1 + block.rate1 * t) + 1))
    --    love.graphics.rotate(block.phase2 + block.rate2 * t)
    --    love.graphics.scale(block.scale)
    --    flipbook1:draw()
    --    love.graphics.pop()
    --end

    flipbook5:draw(0.5 * 800, 0.5 * 450, 0, 0.6, 0.6)

    flipbook1:draw(0.25 * 800, 0.25 * 450, 0, 0.25, 0.25)
    flipbook2:draw(0.75 * 800, 0.25 * 450, 0, 0.25, 0.25)
    flipbook3:draw(0.25 * 800, 0.75 * 450, 0, 0.25, 0.25)
    flipbook4:draw(0.75 * 800, 0.75 * 450, 0, 0.25, 0.25)

    love.graphics.pop('all')

    love.graphics.print('fps: ' .. love.timer.getFPS(), 20, 20)
end

