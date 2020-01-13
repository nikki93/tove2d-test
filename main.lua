local tove = require 'tove'

local gradient = tove.newLinearGradient(120, 130, 140, 160)
gradient:addColorStop(0, 0.8, 0.4, 0.6)
gradient:addColorStop(1, 0.6, 0.2, 0.6)
local myDrawing = tove.newGraphics()
myDrawing:moveTo(100, 100)
myDrawing:curveTo(120, 100, 210, 200, 200, 250)
myDrawing:lineTo(50, 220)
myDrawing:setFillColor(gradient)
myDrawing:fill()
myDrawing:setLineColor(0.2, 0.4, 0.6)
myDrawing:setLineWidth(10)
myDrawing:stroke()

local bigSvg = love.filesystem.newFileData('big.svg'):getString()
local bigSvgDrawing = tove.newGraphics(bigSvg, 'copy')

function love.draw()
    bigSvgDrawing:draw()

    love.graphics.print('fps: ' .. love.timer.getFPS(), 20, 20)
end

