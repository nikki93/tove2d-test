local tove = require 'tove'

local AMOUNT = 4.2
local NOISE_SCALE = 0.08
local FRAMES = 3
local TWEEN = 1
local SPEED = 8
local POINTS = false

local function wobblePoint(x, y, seed)
    seed = seed * 100
    local dx1 = AMOUNT * (2 * love.math.noise(NOISE_SCALE * x, NOISE_SCALE * y, 1, seed) - 1)
    local dy1 = AMOUNT * (2 * love.math.noise(NOISE_SCALE * x, NOISE_SCALE * y, 10, seed) - 1)
    local dx2 = AMOUNT * AMOUNT * (2 * love.math.noise(NOISE_SCALE * NOISE_SCALE * x, NOISE_SCALE * NOISE_SCALE * y, 100, seed) - 1)
    local dy2 = AMOUNT * AMOUNT * (2 * love.math.noise(NOISE_SCALE * NOISE_SCALE * x, NOISE_SCALE * NOISE_SCALE * y, 1000, seed) - 1)
    return x + dx1 + dx2, y + dy1 + dy2
end

local function wobbleDrawing(drawing)
    local frames = {}
    for f = 1, FRAMES do
        local clone = drawing:clone()
        clone:warp(function(x, y, c)
            local newX, newY = wobblePoint(x, y, f)
            return newX, newY, c
        end)
        table.insert(frames, clone)
    end
    local tween = tove.newTween(frames[1])
    for i = 2, #frames do
        tween = tween:to(frames[i], 1)
    end
    tween = tween:to(frames[1], 1)
    return tove.newFlipbook(TWEEN, tween)
end

return wobbleDrawing
