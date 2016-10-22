local Map = require("map")

function love.load()
	map = Map.new()
	tag = 0     --0:normal  1:win  -1:gameover
	source = love.audio.newSource("tkh.mp3")
	love.audio.play(source)
end

function love.draw()
	if tag == 0 then
		map:draw()
	elseif tag == -1 then
		map:gameover()
	elseif tag == 1 then
		map:win()
	end
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end

function love.mousepressed(x, y, button, istouch)
	local tempPos = map:getBlock(x, y)
	local i = tempPos[1]
	local j = tempPos[2]
	if tag == 0 then
		if button == 1 then
			map:open(i, j)
		elseif button == 2 then
			map:mark(i, j)
		end
	else
		if button == 1 then
			map:restart(x, y)
		end
	end
end


