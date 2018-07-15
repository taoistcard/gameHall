gameCollision = {}
gameCollision.gridConfig = {
    width = 100,
    height = 100

}
gameCollision.grid = {}

function gameCollision.init()
	gameCollision.grid.fish = {}
	gameCollision.grid.bullet = {}

	gameCollision.col = 8
	gameCollision.width = CONFIG_SCREEN_WIDTH/gameCollision.col--  = 1136
	gameCollision.row = 6
	gameCollision.height = CONFIG_SCREEN_HEIGHT/gameCollision.row-- = 640

	for i=1,gameCollision.col do
		for j=1,gameCollision.row do
			local index = i+(j-1)*gameCollision.col
			gameCollision.grid[index] = {}
		end
	end
	
end

function gameCollision.clearGrid()
	for i=1,gameCollision.col do
		for j=1,gameCollision.row do
			local index = i+(j-1)*gameCollision.col
			gameCollision.grid[index].fishes = {}
			gameCollision.grid[index].bullets = {}
		end
	end
end

function gameCollision.calcIndex(sprite)
	local x,y = sprite:getPosition()
	
	local col = math.ceil(x/gameCollision.width)
	local row = math.ceil(y/gameCollision.height)

	return col+(row-1)*gameCollision.row
end

function gameCollision.splitGrid(_fishes, _bullets)
	gameCollision.clearGrid()

	for k,v in pairs(_fishes) do
		local index = gameCollision.calcIndex(v)
		if index > 0 and index <= gameCollision.col*gameCollision.row then
			table.insert(gameCollision.grid[index].fishes, v)
		end

	end

	for k,v in pairs(_bullets) do
		local index = gameCollision.calcIndex(v)
		if index > 0 and index <= gameCollision.col*gameCollision.row then
			table.insert(gameCollision.grid[index].bullets, v)
		end
	end
end

function gameCollision.checkCollision()

	for k,v in ipairs(gameCollision.grid) do
		for _k,bullet in ipairs(v.bullets) do
			for _kk, fish in ipairs(v.fishes) do
				if fish:isFishAlive() and isSpriteInterset(fish,bullet) then
					bullet:setMainTarget(fish);
					bullet:showNet();
				end
			end
		end
	end
end

gameCollision.init()