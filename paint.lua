local tove = require 'tove'
local wobble = require 'wobble'


local graphics = tove.newGraphics()
graphics:setDisplay('mesh', 1024)
local flipbook
local wobbleEnabled = true

local currPath
local currSubpath


local lineWidth = 5
local lineColor = { 0, 0, 0, 1 }


local fillEnabled = true
local fillColor = { 1, 1, 1, 1 }


local tool = 'freehand lines'
local tools = {
    'freehand lines',
    'drag lines',
}

local TOUCH_SLOP = 120

local isTouching = false

function love.draw()
    love.graphics.clear(0.54, 0.64, 0.80)

    local tx, ty = love.mouse.getPosition()
    ty = ty - TOUCH_SLOP

    if flipbook then
        flipbook.t = (8 * love.timer.getTime()) % flipbook._duration
        flipbook:draw()
    else
        if isTouching and currSubpath then
            local clone = graphics:clone()
            local lastPath = clone.paths[clone.paths.count]
            local lastSubpath = lastPath.subpaths[lastPath.subpaths.count]
            lastSubpath:lineTo(tx, ty)
            clone:draw()
        else
            graphics:draw()
        end
    end

    if isTouching then
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle('fill', tx, ty, 5)
    end
end


function love.touchpressed(touchId, x, y, dx, dy)
    isTouching = true

    y = y - TOUCH_SLOP

    flipbook = nil
end

function love.touchmoved(touchId, x, y, dx, dy)
    y = y - TOUCH_SLOP

    if not currSubpath then
        if dx == 0 and dy == 0 then
            return
        end

        currSubpath = tove.newSubpath()

        currPath = tove.newPath()
        currPath:addSubpath(currSubpath)
        graphics:addPath(currPath)

        currPath:setLineColor(unpack(lineColor))
        currPath:setLineWidth(lineWidth)

        currSubpath:moveTo(x - dx, y - dy)
    end

    if tool == 'freehand lines' then
        local numPoints = currSubpath.points.count

        local lastPoint = currSubpath.points[numPoints]

        local place = numPoints < 2

        -- Place if at least 30px from last point
        local dispX, dispY = x - lastPoint.x, y - lastPoint.y
        local dispLen = math.sqrt(dispX * dispX + dispY * dispY)
        if dispLen > 30 then
            place = true
        end

        -- Previous segment
        local lastCurve = currSubpath.points.count > 2 and currSubpath.curves[currSubpath.curves.count]
        local lastCurveDX, lastCurveDY
        if lastCurve then
            lastCurveDX, lastCurveDY = lastCurve.x - lastCurve.x0, lastCurve.y - lastCurve.y0
        end

        -- Not already placing and it's a corner? Place at corner
        local cornerX, cornerY
        if not place and lastCurve then
            local lastCurveLen = math.sqrt(lastCurveDX * lastCurveDX + lastCurveDY * lastCurveDY)
            local dot = (dx * lastCurveDX + dy * lastCurveDY) / (math.sqrt(dx * dx + dy * dy) * lastCurveLen)
            if dot < 0.8 then
                cornerX, cornerY = x - dx, y - dy
            end
        end

        if cornerX and cornerY then
            currSubpath:lineTo(cornerX, cornerY)
            currSubpath:lineTo(x, y)
            graphics:clean(0.2)
        elseif place then
            currSubpath:lineTo(x, y)
            graphics:clean(0.2)
        end
    end
end

function love.touchreleased(touchId, x, y, dx, dy)
    isTouching = false

    y = y - TOUCH_SLOP

    if fillEnabled then
        currPath:setFillColor(unpack(fillColor))
        currSubpath.isClosed = true
    else
        currSubpath.isClosed = false
    end

    local numCurves = currSubpath.curves.count
    if numCurves < 3 then
    else
        for i = 1, numCurves do
        end
    end
    
    currSubpath = nil
    currPath = nil

    if wobbleEnabled then
        flipbook = wobble(graphics)
    end
end


local ui = castle.ui

function castle.uiupdate()
    tool = ui.dropdown('tool', tool, tools)

    ui.box('line box', { flexDirection = 'row' }, function()
        ui.box('line width box', { flex = 1 }, function()
            lineWidth = ui.slider('line width', lineWidth, 1, 30)
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

    if ui.button('clear') then
        graphics:clear()
        flipbook = nil
    end
end
