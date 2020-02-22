local tove = require 'tove'
local wobble = require 'wobble'


local graphics = tove.newGraphics()
graphics:setDisplay('mesh', 1024)
local flipbook
local wobbleEnabled = true

local currPath
local currSubpath


local lineWidth = 10
local lineColor = { 0, 0, 0, 1 }


local fillEnabled = true
local fillColor = { 1, 1, 1, 1 }


local tool = 'freehand lines'
local tools = {
    'freehand lines',
    'drag lines',
}

local DEFAULT_TOUCH_SLOP = 120
local touchSlop = DEFAULT_TOUCH_SLOP

local isTouching = false
local touchX, touchY

function love.draw()
    love.graphics.clear(0.54, 0.64, 0.80)

    if flipbook then
        flipbook.t = (8 * love.timer.getTime()) % flipbook._duration
        flipbook:draw()
    else
        if isTouching and currSubpath then
            local clone = graphics:clone()
            local lastPath = clone.paths[clone.paths.count]
            local lastSubpath = lastPath.subpaths[lastPath.subpaths.count]
            lastSubpath:lineTo(touchX, touchY)
            clone:draw()
        else
            graphics:draw()
        end
    end

    if isTouching then
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle('fill', touchX, touchY, 5)
    end
end


function love.touchpressed(touchId, x, y, dx, dy)
    isTouching = true

    y = y - touchSlop
    touchX, touchY = x, y

    flipbook = nil
end

function love.touchmoved(touchId, x, y, dx, dy)
    y = y - touchSlop
    touchX, touchY = x, y

    if not currSubpath then
        if dx == 0 and dy == 0 then
            return
        end

        currSubpath = tove.newSubpath()

        currPath = tove.newPath()
        currPath:addSubpath(currSubpath)
        graphics:addPath(currPath)

        currPath:setLineColor(unpack(lineColor))
        currPath:setLineWidth(math.max(2, lineWidth))
        currPath:setMiterLimit(1)

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

    if currPath and currSubpath then
        y = y - touchSlop

        if fillEnabled then
            currPath:setFillColor(unpack(fillColor))
            currSubpath.isClosed = true
        else
            currSubpath:lineTo(x, y)
            graphics:clean(0.2)
            currSubpath.isClosed = false
        end

        local numCurves = currSubpath.curves.count
        if numCurves >= 3 then
            for i = 1, numCurves do
                local p0 = currSubpath.curves[i]
                local p1 = currSubpath.curves[i == numCurves and 1 or (i + 1)]

                local v1x, v1y = p0.x - p0.cp2x, p0.y - p0.cp2y
                local v1l = math.sqrt(v1x * v1x + v1y * v1y)
                v1x, v1y = v1x / v1l, v1y / v1l
                local v2x, v2y = p1.cp1x - p1.x0, p1.cp1y - p1.y0
                local v2l = math.sqrt(v2x * v2x + v2y * v2y)
                v2x, v2y = v2x / v2l, v2y / v2l

                if v1x * v2x + v1y * v2y > 0.3 then
                    local hx, hy = 0.5 * (v1x + v2x), 0.5 * (v1y + v2y)
                    p0.cp2x, p0.cp2y = p0.x - v1l * hx, p0.y - v1l * hy
                    p1.cp1x, p1.cp1y = p1.x0 + v2l * hx, p1.y0 + v2l * hy
                end
            end
        end
        
        currPath:setLineWidth(lineWidth)

        graphics:clean(0.2)

        currSubpath = nil
        currPath = nil
    end

    if wobbleEnabled then
        flipbook = wobble(graphics)
    end
end


local ui = castle.ui

function castle.uiupdate()
    tool = ui.dropdown('tool', tool, tools)

    ui.box('line box', { flexDirection = 'row' }, function()
        ui.box('line width box', { flex = 1 }, function()
            lineWidth = ui.slider('line width', lineWidth, 0, 30)
        end)

        lineColor[1], lineColor[2], lineColor[3] = ui.colorPicker(
            'line color', lineColor[1], lineColor[2], lineColor[3], 1, { enableAlpha = false })

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

    ui.toggle('touch slop off', 'touch slop on', touchSlop == DEFAULT_TOUCH_SLOP, {
        onToggle = function(newTouchSlopEnabled)
            if newTouchSlopEnabled then
                touchSlop = DEFAULT_TOUCH_SLOP
            else
                touchSlop = 0
            end
        end
    })

    if ui.button('clear') then
        graphics:clear()
        flipbook = nil
    end
end
