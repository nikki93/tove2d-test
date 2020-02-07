local tove = require 'tove'

local PATHS = {
    '0207_ball_2_des2-01.svg',
    'brick-01.svg',
    'door-01.svg',
    'dove-01.svg',
    'pufferfish-01.svg',
    '0207_circle_8points.svg',
    '0207_square_8points.svg',
    '0207_circle1-01.svg',
    '0207_square.svg',
}

local PATH = PATHS[1]
local AMOUNT = 2.85
local FRAMES = 10
local TWEEN = 2
local SPEED = 8
local POINTS = false

local function loadDrawing(path)
    local drawing = tove.newGraphics(love.filesystem.newFileData(path):getString(), 400)
    drawing:setResolution(2)
    --drawing:setUsage('points', 'dynamic')
    --drawing:setDisplay('mesh', 1024)
    return drawing
end

local function wobbleDrawing(drawing, amount)
    amount = amount or 3
    local frames = {}
    for f = 1, FRAMES do
        local clone = drawing:clone()
        for i = 1, clone.paths.count do
            local path = clone.paths[i]
            for j = 1, path.subpaths.count do
                local subpath = path.subpaths[j]
                local numCurves = subpath.curves.count
                for k = 1, numCurves do
                    local curve = subpath.curves[k]
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

local flipbook

local function createFlipbook()
    network.async(function()
        flipbook = wobbleDrawing(loadDrawing(PATH), AMOUNT)
    end)
end

createFlipbook()

function love.draw()
    local W, H = love.graphics.getDimensions()

    love.graphics.clear(0.54, 0.64, 0.80)

    if flipbook then
        love.graphics.push('all')

        local t = love.timer.getTime()

        flipbook.t = (SPEED * t) % flipbook._duration

        flipbook:draw(0.5 * W, 0.5 * H, 0, 0.6, 0.6)

        love.graphics.pop('all')
    end

    love.graphics.print('fps: ' .. love.timer.getFPS(), 20, 20)
end

local nextReload = 0

function love.update(dt)
    if nextReload > 0 then
        nextReload = nextReload - dt
        if nextReload <= 0 then
            nextReload = 0
            createFlipbook()
        end
    end
end

local ui = castle.ui

function castle.uiupdate()
    --for i = 1, #PATHS do
    --    ui.image(PATHS[i], { width = 150, height = 150 })
    --end

    ui.dropdown('file', PATH, PATHS, {
        onChange = function(newPath)
            PATH = newPath
            createFlipbook()
        end,
    })

    ui.slider('amount', AMOUNT, 0.1, 6, {
        step = 0.02,
        onChange = function(newAmount)
            AMOUNT = newAmount
            nextReload = 0.25
        end,
    })

    ui.slider('frames', FRAMES, 2, 24, {
        onChange = function(newFrames)
            FRAMES = newFrames
            nextReload = 0.25
        end,
    })

    ui.slider('tween', TWEEN, 1, 4, {
        onChange = function(newTween)
            TWEEN = newTween
            nextReload = 0.25
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
            createFlipbook()
        end,
    })
end

