graphics = {
	dirt = love.graphics.newImage("graphics/dirt2.png"),
	floor = love.graphics.newImage("graphics/floor.png"),
	brick = love.graphics.newImage("graphics/greybrick.png"),
	water = love.graphics.newImage("graphics/water.png"),
	
	dirt2 = love.graphics.newImage("graphics/dirt.png"),
	floor2 = love.graphics.newImage("graphics/floor2.png"),
	brick2 = love.graphics.newImage("graphics/greybrick2.png"),
	water2 = love.graphics.newImage("graphics/water2.png"),
	
	waterbig = love.graphics.newImage("graphics/waterbig.png"),
	
	cursor1 = love.graphics.newImage("graphics/cursor1.png"),
	cursor2 = love.graphics.newImage("graphics/cursor2.png"),
	cursor3 = love.graphics.newImage("graphics/cursor3.png"),
	cursor4 = love.graphics.newImage("graphics/cursor4.png"),
	cursor5 = love.graphics.newImage("graphics/cursor5.png"),
	
	troop1 = love.graphics.newImage("graphics/troop1.png"),
	troop2 = love.graphics.newImage("graphics/troop2.png"),
	
	gun11 = love.graphics.newImage("graphics/gun11.png"),
	gun21 = love.graphics.newImage("graphics/gun21.png"),
	gun31 = love.graphics.newImage("graphics/gun31.png"),
	gun41 = love.graphics.newImage("graphics/gun41.png"),
	gun51 = love.graphics.newImage("graphics/gun51.png"),
	gun61 = love.graphics.newImage("graphics/gun61.png"),
	gun12 = love.graphics.newImage("graphics/gun12.png"),
	gun22 = love.graphics.newImage("graphics/gun22.png"),
	gun32 = love.graphics.newImage("graphics/gun32.png"),
	gun42 = love.graphics.newImage("graphics/gun42.png"),
	gun52 = love.graphics.newImage("graphics/gun52.png"),
	gun62 = love.graphics.newImage("graphics/gun62.png"),
	
	arrowr = love.graphics.newImage("graphics/arrowr.png"),
	arrowl = love.graphics.newImage("graphics/arrowl.png"),
}
sfx = {
	nuhuh = love.audio.newSource("sfx/incorrectbuzzer.wav","static"),
	pistol = love.audio.newSource("sfx/gun2.wav","static"),
	rifle = love.audio.newSource("sfx/gun1.wav","static"),
	sniper = love.audio.newSource("sfx/gun3.wav","static"),
	death = love.audio.newSource("sfx/die.wav","static"),
	footsteps = love.audio.newSource("sfx/footsteps.wav","static"),
}
music = {
	battle1 = love.audio.newSource("music/battle1sync.wav","stream"),
	battle2 = love.audio.newSource("music/battle2sync.wav","stream"),
	battle3 = love.audio.newSource("music/battle3sync.wav","stream"),
	battle4 = love.audio.newSource("music/battle4sync.wav","stream"),
	battle5 = love.audio.newSource("music/battle5sync.wav","stream"),
	
	results = love.audio.newSource("music/results.wav","stream"),
	helpme = love.audio.newSource("music/helpme.wav","stream"),
	menu = love.audio.newSource("music/mapsel.wav","stream"),
	title = love.audio.newSource("music/title.wav","stream"),
	
	victory = love.audio.newSource("music/victory.wav","static"),
}

function updateVol()
	for k,v in pairs(music) do
		v:setVolume(config.mus/20)
		end
	for k,v in pairs(sfx) do
		v:setVolume(config.sfx/20)
		end
	music.victory:setVolume(config.sfx/20)
	sfx.death:setVolume(0.4*(config.sfx/20))
	sfx.footsteps:setVolume(0.3*(config.sfx/20))
	end