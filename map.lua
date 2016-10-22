local Map = {}
Map.__index = Map

function Map.new()
	local self = setmetatable({}, Map)

	self.width = 30
	self.height = 16
	self.minesNum = 10
	self.blockSize = 15
	self.gapSize = 3
	self.edgeSize = 5
	self.button_x = 273
	self.button_y = 167
	self.button_a = 53
	self.button_b = 23
	self.n = 0
	self.timeStart = love.timer.getTime()
	self.timeEnd = self.timeStart

	self.block = {}
	for y = 1, self.height do
		row = {}
		table.insert(self.block, row)
		for x = 1, self.width do
			table.insert(row, 0)
		end
	end

	self.state = {}  -- 0 : close 1 : open 2 : marked
	for y = 1, self.height do
		row = {}
		table.insert(self.state, row)
		for x = 1, self.width do
			table.insert(row, 0)
		end
	end

	self.initMine(self)
	self.initBlock(self)

	return self
end

function Map.initMine(self)
	local count = 0
	for i = 1, self.width do
		for j = 1, self.height do
			self.block[j][i] = 0
			self.state[j][i] = 0
		end
	end

	self.n = 0
	self.timeStart = love.timer.getTime()
	self.timeEnd = self.timeStart

	while(count < self.minesNum) do
		local i = love.math.random(self.height)
		local j = love.math.random(self.width)
		if self.block[i][j] == 0 then
			self.block[i][j] = -1
			count = count + 1
		end
	end
end

function Map.initBlock(self)
	for i = 1, self.width do
		for j = 1, self.height do
			if self.block[j][i] == -1 then
				for t1 = -1, 1 do
					for t2 = -1, 1 do
						if t1 ~= 0 or t2 ~= 0 then
							if i+t1 >= 1 and i+t1 <= self.width and j+t2 >= 1 and j+t2 <= self.height and self.block[j+t2][i+t1] ~= -1 then
								self.block[j+t2][i+t1] = self.block[j+t2][i+t1] + 1
							end
						end
					end
				end
			end
		end
	end

end

function Map.draw(self)
	for i = 1, self.width do
		for j = 1, self.height do
			local x = self.edgeSize + (i - 1) * (self.blockSize + self.gapSize)
			local y = self.edgeSize + (j - 1) * (self.blockSize + self.gapSize)
			if self.state[j][i] == 0 then
				love.graphics.rectangle("fill", x, y, self.blockSize, self.blockSize)
			elseif self.state[j][i] == 1 then
				local num = tostring(self.block[j][i])
				love.graphics.printf(num, x, y, self.blockSize + self.gapSize / 2,"center")
			elseif self.state[j][i] == 2 then
				love.graphics.rectangle("fill", x, y, self.blockSize, self.blockSize)
				love.graphics.printf({{0,0,0,255},"@"}, x, y, self.blockSize + self.gapSize / 2,"center")
			end
		end
	end
	love.graphics.printf("Time : "..string.format("%.1f",love.timer.getTime() - self.timeStart).."s",20,330,300,"left",0,1.2,1.2,0,0,0,0)
end

function Map.getBlock(self, x, y)
	local ans = {}
	local i = math.ceil((x - self.edgeSize) / (self.blockSize + self.gapSize))
	local j = math.ceil((y - self.edgeSize) / (self.blockSize + self.gapSize))
	table.insert(ans, i)
	table.insert(ans, j)
	return ans
end

function Map.open(self, i, j)
	if self.state[j][i] == 0 then
		self.n = self.n + 1
		self.state[j][i] = 1
		if self.block[j][i] == -1 then
			self:gameover()
		elseif self.block[j][i] == 0 then
			for t1 = -1, 1 do
				for t2 = -1, 1 do
					if t1 ~= 0 or t2 ~= 0 then
						if i+t1 >= 1 and i+t1 <= self.width and j+t2 >= 1 and j+t2 <= self.height and self.block[j+t2][i+t1] ~= -1 then
							self:open(i+t1, j+t2)
						end
					end
				end
			end
		end
	end
	if self:isWin() then
		self.timeEnd = love.timer.getTime()
		self:win()
	end
end

function Map.mark(self, i, j)
	if self.state[j][i] == 0 then
		self.state[j][i] = 2
	elseif self.state[j][i] == 2 then
		self.state[j][i] = 0
	end
end

function Map.win(self)
	tag = 1
	love.graphics.setColor(255, 0, 0)
	love.graphics.printf(" YOU WIN ", 130, 70, 100,"center",0,3,3,0,0,0,0)
	love.graphics.setColor(18,33,126)
	love.graphics.ellipse("fill", self.button_x, self.button_y, self.button_a, self.button_b)
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf("RESTART", 200, 157, 100,"center",0,1.5,1.5,0,0,0,0)
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf("Time : "..string.format("%.1f",self.timeEnd - self.timeStart).."s",220,230,100,"center",0,1.2,1.2,0,0,0,0)

end

function Map.isWin(self)
	if self.n == self.width * self.height - self.minesNum then
		return true
	else
		return false
	end
end

function Map.gameover(self)
	tag = -1
	love.graphics.setColor(255, 0, 0)
	love.graphics.printf("GAMEOVER!", 130, 70, 100,"center",0,3,3,0,0,0,0)
	love.graphics.setColor(18,33,126)
	love.graphics.ellipse("fill", self.button_x, self.button_y, self.button_a, self.button_b)
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf("RESTART", 200, 157, 100,"center",0,1.5,1.5,0,0,0,0)
end

function Map.restart(self, x, y)
	local c = math.sqrt(self.button_a * self.button_a - self.button_b * self.button_b)
	local dis1 = math.sqrt((x-self.button_x-c) * (x-self.button_x-c) + (y-self.button_y) * (y-self.button_y))
	local dis2 = math.sqrt((x-self.button_x+c) * (x-self.button_x+c) + (y-self.button_y) * (y-self.button_y))
	if dis1 + dis2 < 2 * self.button_a then
		self:initMine()
		self:initBlock()
		tag = 0
	end
	love.audio.rewind(source)
end

return Map
