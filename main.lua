local tove = require 'tove'

local function loadDrawing(path)
    local drawing = tove.newGraphics(love.filesystem.newFileData(path):getString(), 100)
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
for i = 1, 18 do
    blocks[i] = {
        x = 200 + 400 * math.random(),
        phase1 = 2 * math.pi * math.random(),
        phase2 = 2 * math.pi * math.random(),
        rate1 = 0.08 + 0.8 * (2 * math.random() - 1),
        rate2 = 0.08 + 0.8 * (2 * math.random() - 1),
        scale = 0.2 + 0.8 * math.random(),
    }
end

local scribbles = setmetatable({}, { __mode = 'k' })

local function scribbleDrawing(drawing)
    scribbles[drawing] = scribbles[drawing] or {}
    local s = scribbles[drawing]
    for i = 1, drawing.paths.count do
        for j = 1, drawing.paths[i].subpaths.count do
            for k = 1, drawing.paths[i].subpaths[j].curves.count do
                local curve = drawing.paths[i].subpaths[j].curves[k]
                local cs = s[i .. '-' .. j .. '-' .. k]
                if not cs then
                    cs = {
                        cp1x = curve.cp1x,
                        cp1y = curve.cp1y,
                        cp2x = curve.cp2x,
                        cp2y = curve.cp2y,
                    }
                    s[i .. '-' .. j .. '-' .. k] = cs
                end
                curve.cp1x = 0.75 * (curve.cp1x + 1.8 * (2 * math.random() - 1)) + 0.25 * cs.cp1x
                curve.cp1y = 0.75 * (curve.cp1y + 1.8 * (2 * math.random() - 1)) + 0.25 * cs.cp1y
                curve.cp2x = 0.75 * (curve.cp2x + 1.8 * (2 * math.random() - 1)) + 0.25 * cs.cp2x
                curve.cp2y = 0.75 * (curve.cp2y + 1.8 * (2 * math.random() - 1)) + 0.25 * cs.cp2y
            end
        end
    end
end

function love.draw()
    love.graphics.push('all')

    scribbleDrawing(drawing1)
    local t = love.timer.getTime()
    for _, block in ipairs(blocks) do
        love.graphics.push()
        love.graphics.translate(block.x, 0.5 * 450 * (math.sin(block.phase1 + block.rate1 * t) + 1))
        love.graphics.rotate(block.phase2 + block.rate2 * t)
        love.graphics.scale(block.scale)
        drawing1:draw()
        love.graphics.pop()
    end
    drawing1:draw(0.25 * 800, 0.25 * 450)
    scribbleDrawing(drawing2)
    drawing2:draw(0.75 * 800, 0.25 * 450)
    scribbleDrawing(drawing3)
    drawing3:draw(0.25 * 800, 0.75 * 450)
    scribbleDrawing(drawing4)
    drawing4:draw(0.75 * 800, 0.75 * 450)

    love.graphics.pop('all')

    love.graphics.print('fps: ' .. love.timer.getFPS(), 20, 20)
end

