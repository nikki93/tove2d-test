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
    'test.svg',
}

local SCALE = 0.6

local PATH = PATHS[1]
local AMOUNT = 2.85
local FRAMES = 10
local TWEEN = 2
local SPEED = 8
local POINTS = false

local function loadDrawing(path)
    local drawing = tove.newGraphics(love.filesystem.newFileData(path):getString(), 400)
    --drawing:setUsage('points', 'dynamic')
    drawing:setDisplay('mesh', 1024)
    return drawing
end

local function wobblePoint(x, y, amount, seed)
    local dx = amount * (2 * love.math.noise(x, y, 1, seed) - 1)
    local dy = amount * (2 * love.math.noise(x, y, 2, seed) - 1)
    return x + dx, y + dy
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
                    local seed = FRAMES * f + j
                    local curve = subpath.curves[k]
                    curve.cp1x, curve.cp1y = wobblePoint(curve.cp1x, curve.cp1y, amount, seed)
                    curve.cp2x, curve.cp2y = wobblePoint(curve.cp2x, curve.cp2y, amount, seed)
                    if POINTS then
                        curve.x0, curve.y0 = wobblePoint(curve.x0, curve.y0, amount, seed)
                        curve.x, curve.y = wobblePoint(curve.x, curve.y, amount, seed)
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
    return tove.newFlipbook(TWEEN, tween, 'mesh', 1024)
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

        flipbook:draw(0.5 * W, 0.5 * H, 0, SCALE, SCALE)

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

    SCALE = ui.slider('scale', SCALE, 0.2, 4, { step = 0.01 })

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

