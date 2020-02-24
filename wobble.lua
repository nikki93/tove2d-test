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

local function copyCurve(dest, src)
    dest.x0, dest.y0 = src.x0, src.y0
    dest.cp1x, dest.cp1y = src.cp1x, src.cp1y
    dest.cp2x, dest.cp2y = src.cp2x, src.cp2y
    dest.x, dest.y = src.x, src.y
end

local function wobbleCurve(dest, src, seed)
    dest.x0, dest.y0 = wobblePoint(src.x0, src.y0, seed)
    dest.cp1x, dest.cp1y = wobblePoint(src.cp1x, src.cp1y, seed)
    dest.cp2x, dest.cp2y = wobblePoint(src.cp2x, src.cp2y, seed)
    dest.x, dest.y = wobblePoint(src.x, src.y, seed)
end

local function wobbleDrawing(drawing)
    local frames = {}
    local display = drawing:getDisplay()
    for f = 1, FRAMES do
        local clone = drawing:clone()
        for i = 1, clone.paths.count do
            local path = clone.paths[i]
            local origPath = drawing.paths[i]
            for j = 1, path.subpaths.count do
                local subpath = path.subpaths[j]
                local origSubpath = origPath.subpaths[j]
                subpath:warp(function(x, y, c)
                    local newX, newY = wobblePoint(x, y, f * FRAMES + j)
                    return newX, newY, c
                end)
                if not subpath.isClosed then -- Need to fix ends if not closed
                    local numCurves = subpath.curves.count
                    if display ~= 'texture' then
                        copyCurve(subpath.curves[1], origSubpath.curves[1])
                        copyCurve(subpath.curves[numCurves - 1], origSubpath.curves[numCurves - 1])
                    end
                    copyCurve(subpath.curves[numCurves], origSubpath.curves[numCurves])
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

return wobbleDrawing
