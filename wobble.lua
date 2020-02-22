local tove = require 'tove'

local AMOUNT = 1.8
local NOISE_SCALE = 0.08
local FRAMES = 3
local TWEEN = 1
local SPEED = 10
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
        for i = 1, clone.paths.count do
            local path = clone.paths[i]
            local origPath = drawing.paths[i]
            for j = 1, path.subpaths.count do
                local subpath = path.subpaths[j]
                local origSubpath = origPath.subpaths[j]
                subpath:warp(function(x, y, c)
                    local newX, newY = wobblePoint(x, y, f)
                    return newX, newY, c
                end)
                --subpath.isClosed = origSubpath.isClosed
                --local numCurves = subpath.curves.count
                --for k = 1, numCurves do
                --    local seed = FRAMES * f + j
                --    local curve = subpath.curves[k]
                --    curve.cp1x, curve.cp1y = wobblePoint(curve.cp1x, curve.cp1y, seed)
                --    curve.cp2x, curve.cp2y = wobblePoint(curve.cp2x, curve.cp2y, seed)
                --    curve.x0, curve.y0 = wobblePoint(curve.x0, curve.y0, seed)
                --    curve.x, curve.y = wobblePoint(curve.x, curve.y, seed)
                --end
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

return wobbleDrawing
