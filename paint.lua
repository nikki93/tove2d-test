local tove = require 'tove'
local wobble = require 'wobble'


local graphics = tove.newGraphics()
graphics:setDisplay('mesh', 'rigid', 4)
local flipbook
local wobbleEnabled = true

local currPath
local currSubpath


local lineWidth = 0
local lineColor = { 0, 0, 0, 1 }


local fillEnabled = true
local fillColor = { 1, 1, 1, 1 }


local curveEnabled = true


function love.draw()
    love.graphics.clear(0.54, 0.64, 0.80)

    if flipbook then
        flipbook.t = (8 * love.timer.getTime()) % flipbook._duration
        flipbook:draw()
    else
        graphics:draw()
    end
end


function love.touchpressed(touchId, x, y, dx, dy)
    flipbook = nil

    currSubpath = tove.newSubpath()

    currPath = tove.newPath()
    currPath:addSubpath(currSubpath)
    graphics:addPath(currPath)

    currPath:setLineColor(unpack(lineColor))
    currPath:setLineWidth(lineWidth)

    if fillEnabled then
        currPath:setFillColor(unpack(fillColor))
        currSubpath.isClosed = true
    else
        currSubpath.isClosed = false
    end
    
    currSubpath:moveTo(x, y)
end

function love.touchmoved(touchId, x, y, dx, dy)
    local lastPoint = currSubpath.points[currSubpath.points.count]
    local dispX, dispY = x - lastPoint.x, y - lastPoint.y
    local dispLen = math.sqrt(dispX * dispX + dispY * dispY)

    local lastLastPoint
    local lastDispX, lastDispY
    local lastDispLen
    local cosAngle
    if currSubpath.points.count >= 2 then
        lastLastPoint = currSubpath.points[currSubpath.points.count - 1]
        lastDispX, lastDispY = lastPoint.x - lastLastPoint.x, lastPoint.y - lastLastPoint.y
        lastDispLen = math.sqrt(lastDispX * lastDispX + lastDispY * lastDispY)
        cosAngle = (dispX * lastDispX + dispY * lastDispY) / (dispLen * lastDispLen)
    end

    if (lastLastPoint and cosAngle < 0.8) or dispLen > 30 then
        if curveEnabled and lastLastPoint then
            local hx, hy = 0.25 * (lastDispX + dispX), 0.25 * (lastDispY + dispY)
            local lastCurve = currSubpath.curves[currSubpath.curves.count]
            lastCurve.cp2x, lastCurve.cp2y = lastPoint.x - hx, lastPoint.y - hy
            currSubpath:curveTo(lastPoint.x + hx, lastPoint.y + hy, x, y, x, y)
        else
            currSubpath:lineTo(x, y)
        end
    end
end

function love.touchreleased(touchId, x, y, dx, dy)
    love.touchmoved(touchId, x, y, dx, dy)

    currSubpath = nil
    currPath = nil

    if wobbleEnabled then
        flipbook = wobble(graphics)
    end
end


local ui = castle.ui

function castle.uiupdate()
    ui.box('line box', { flexDirection = 'row' }, function()
        ui.box('line width box', { flex = 1 }, function()
            lineWidth = ui.slider('line width', lineWidth, 0, 30)
        end)

        lineColor[1], lineColor[2], lineColor[3] = ui.colorPicker(
            'line color', lineColor[1], lineColor[2], lineColor[3], 1, { enableAlpha = false })
    end)

    ui.box('fill box', { flexDirection = 'row' }, function()
        fillEnabled = ui.toggle('fill off', 'fill on', fillEnabled)
        if fillEnabled then
            fillColor[1], fillColor[2], fillColor[3] = ui.colorPicker(
                'fill color', fillColor[1], fillColor[2], fillColor[3], 1, { enableAlpha = false })
        end
    end)

    ui.toggle('wobble off', 'wobble on', wobbleEnabled, {
        onToggle = function(newWobbleEnabled)
            wobbleEnabled = newWobbleEnabled
            if wobbleEnabled then
                flipbook = wobble(graphics)
            else
                flipbook = nil
            end
        end
    })

    curveEnabled = ui.toggle('curve off', 'curve on', curveEnabled)

    if ui.button('clear') then
        graphics:clear()
        flipbook = nil
    end
end
