--level is 16x12
--pieces are id,team,x,y
--1=dirt 2=floor 3=wall 4=water
--1=pistol 2=rifle 3=sniper 4=machinegun etc

level = {}
pathmap = {{}}--2d array of bools; used for pathfinding
maps = {
	[-6]={},--blank slot for a chosen endless level
	[-1]={},--blank slot for a loaded custom level
} 
mappieces = {
	[-6]={},--blank slot for a chosen endless level
	[-1]={},--blank slot for a loaded custom level
}
mapstats = {
	[-6]={nextmap=-6},--blank slot for a chosen endless level (choose random song on run start)
	[-1]={music=1},--blank slot for a loaded custom level
	{--courtyard
		nextmap=0,
		music=1,
	},
	{--waterways
		nextmap=0,
		music=3,
	},
	{--river blitz
		nextmap=103,
		music=2,
	},
	[103]={--river blitz 2
		nextmap=0,
		music=2,
	},
	{--city boys
		nextmap=104,
		music=4,
	},
	[104]={--city boys 2
		nextmap=204,
		music=4,
	},
	[204]={--city boys 3
		nextmap=0,
		music=4,
	},
	{--marshland
		nextmap=105,
		music=1,
	},
	[105]={--marshland 2
		nextmap=205,
		music=1,
	},
	[205]={--marshland 3
		nextmap=0,
		music=1,
	},
	{--bunker seige
		nextmap=106,
		music=5,
	},
	[106]={--bunker seige 2
		nextmap=206,
		music=5,
	},
	[206]={--bunker seige 3
		nextmap=306,
		music=5,
	},
	[306]={--bunker seige 4
		nextmap=0,
		music=5,
	},
	{--big trouble
		nextmap=107,
		music=3,
	},
	[107]={--big trouble 2
		nextmap=207,
		music=3,
	},
	[207]={--big trouble 3
		nextmap=0,
		music=3,
	},
	{--showdown
		nextmap=108,
		music=4,
	},
	[108]={--showdown 2
		nextmap=208,
		music=4,
	},
	[208]={--showdown 3
		nextmap=0,
		music=4,
	},
	{--streetsweep
		nextmap=109,
		music=5,
	},
	[109]={--streetsweep 2
		nextmap=209,
		music=5,
	},
	[209]={--streetsweep 3
		nextmap=309,
		music=5,
	},
	[309]={--streetsweep 4
		nextmap=0,
		music=5,
	},
	
	--NEW GAME PLUS!!!
	[1001]={--courtyard+
		nextmap=1101,
		music=1,
	},
	[1101]={--courtyard+ 2
		nextmap=0,
		music=1,
	},
	[1002]={--waterways+
		nextmap=1102,
		music=3,
	},
	[1102]={--waterways+ 2
		nextmap=0,
		music=3,
	},
	[1003]={--river blitz+
		nextmap=1103,
		music=2,
	},
	[1103]={--river blitz+ 2
		nextmap=0,
		music=2,
	},
	[1004]={--city boys
		nextmap=1104,
		music=4,
	},
	[1104]={--city boys 2
		nextmap=1204,
		music=4,
	},
	[1204]={--city boys 3
		nextmap=0,
		music=4,
	},
}

mapdesc = {
	"some scouts were spotted\nhere. just take care\nof them, quick job.",
	"the enemies are storing\nweapons and ammo here.\nclear the place out best\nyou can.",
	"this fortified post would\nprove invaluable to us.\nempty the place of enemies\nbefore they can block\nus out.",
	"the city here is very\ndangerous, but we could\nreally use the factories\nand fuel for sure.",
	"the marsh here has little\ncover and is hard to move\nin, but that's exactly\nwhy our enemy's boys\nare hiding here.",
	"it's time to reclaim our\nbunker here. an enemy\nleader is holed up deep\ninside, but security is\nvery tight.",
	"with such a large blow\ndealt to them recently,\nthe enemies are beginning\nto get desperate.\ndefend our honor here.",
	"this is  it, supposedly\ntheir final base of\noperations within our\nterritory.\ngood luck, soldiers!",
	"time for the BONUS level!\n \ngive em hell, alright?",
}
ignoredpiece1 = 0
ignoredpiece2 = 0
function generatePathMap()
	
	for x=1,16 do
		pathmap[x] = {}
		for y=1,12 do
			local thistile = false
			if level[x+(y-1)*16] < 3 then thistile = true end
			pathmap[x][y] = thistile
			
			local oat = objAt(x-1,y-1)
			if oat>0 and oat~=ignoredpiece1 and oat~=ignoredpiece2 then pathmap[x][y] = false end
			end
		end
	
	ignoredpiece1 = 0
	ignoredpiece2 = 0
	end

function initLevel(lev)
	endlessscreen = 1
	endlesstimer = 602
	if lev==-6 then
		--in endless mode:
		loadMapFile("endlessmaps/endless"..love.math.random(1,maxendlessmaps)..".cqg",-6)
		mapstats[-6].music = love.math.random(1,5)
		end
	
	fade = 1
	loadinglevel = true
	
	score = {0,0}
	spilledblood = {0,0}
	pkills = 0
	pdmg = 0
	pdeaths = 0
	turncounter = 0
	currentteam = 1
	
--	gamestate=STATE_GAME
	
	objs = {}
	levelnum = lev
	level = maps[lev]
	for i=1,#mappieces[lev] do
		makeObj(mappieces[lev][i][1],mappieces[lev][i][2],mappieces[lev][i][3],mappieces[lev][i][4])
		end
	generatePathMap()
	end
function nextLevel(lev)
	if levelnum==-6 then
		--in endless mode:
		endlessscreen=endlessscreen+1
		if endlessscreen>stats.screenendless then stats.screenendless=endlessscreen end
		endlesstimer=endlesstimer+90
		if endlessscreen%2==1 then
			local t=countTeamPieces()
			if t[1]<6 then
				makeObj(love.math.random(1,4),1,-1,1)
				end
			end
		loadMapFile("endlessmaps/endless"..love.math.random(1,maxendlessmaps)..".cqg",-6)
		end
	
	score[1]=score[1]+20-turncounter
	
	currentteam = 1
	
	local oldobjs = {}
	for i=1,#objs do
		if objs[i]~=nil then
			if objs[i].team==1 and objs[i].hp>0 then
				table.insert(oldobjs,objs[i])
				end
			end
		end
	objs = {}
	levelnum = lev
	level = maps[lev]
	
	table.sort(mappieces[lev],function(a,b) return a[2]<b[2] end)
	
	local currentoldobj = 1
	for i=1,#mappieces[lev] do
		if mappieces[lev][i][2]~=1 then
			makeObj(mappieces[lev][i][1],mappieces[lev][i][2],mappieces[lev][i][3],mappieces[lev][i][4])
			else
			if oldobjs[currentoldobj]~=nil then
				oldobjs[currentoldobj].pox=mappieces[lev][i][3]
				oldobjs[currentoldobj].poy=mappieces[lev][i][4]
				oldobjs[currentoldobj].hp=math.min(oldobjs[currentoldobj].hp+5,(oldobjs[currentoldobj].class==6) and 40 or 20)
				oldobjs[currentoldobj].actpts=10+math.ceil(oldobjs[currentoldobj].hp/2)
				if oldobjs[currentoldobj].hp>0 then
					table.insert(objs,oldobjs[currentoldobj])
					end
				currentoldobj=currentoldobj+1
				end
			end
		end
	generatePathMap()
	end

function love.filedropped(file)
	file:open("r")
	local filestr = file:read()
	for i=1,(16*12) do
		maps[-1][i] = string.byte(filestr,i)
		end
	local o = {}
	mappieces[-1] = {}
	for i=205,#filestr do
		if i%4~=0 then
			o[i%4] = string.byte(filestr,i+1)
			else
			o[4] = string.byte(filestr,i+1)
			table.insert(mappieces[-1],o)
			o = {}
			end
		end
	
	local chars = {" ","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","-","?","!"}
	mapstats[-1].name=""
	for i=1,12 do
		local char=chars[string.byte(filestr,i+192)]
		if i==1 or string.byte(filestr,i+191)==1 then char=string.upper(char) end
		mapstats[-1].name = mapstats[-1].name..char
		end
	mapstats[-1].par = string.byte(filestr,205)*100
	
	file:close()
	mapstats[-1].nextmap = 0
	
--	initLevel(-1)
	end
--.CQG LEVEL FILE FORMAT
--bytes 1..192 are dedicated to tile data. 1 = dirt, 2 = floor, then wall, then water.
--bytes 193..204 are dedicated to the name as an index to the below defined chars table.
--byte 205 is reserved for the par score of the level, in multiples of 50.
--anything beyond this is left for pieces placed on the map
--pieces are defined as follows: CLASS, TEAM, XPOS, YPOS
function loadMapFile(filename,num)
	local file = love.filesystem.newFile(filename)
	file:open("r")
	local filestr = file:read()
	maps[num] = {}
	for i=1,(16*12) do
		maps[num][i] = string.byte(filestr,i)
		end
	local o = {}
	mappieces[num] = {}
	for i=205,#filestr do
		if i%4~=0 then
			o[i%4] = string.byte(filestr,i+1)
			else
			o[4] = string.byte(filestr,i+1)
			table.insert(mappieces[num],o)
			o = {}
			end
		end
	
	local chars = {" ","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","-","?","!"}
	if mapstats[num]==nil then mapstats[num] = {} end
	mapstats[num].name=""
	for i=1,12 do
		local char=chars[string.byte(filestr,i+192)]
		if i==1 or string.byte(filestr,i+191)==1 then char=string.upper(char) end
		mapstats[num].name = mapstats[num].name..char
		end
	mapstats[num].par = string.byte(filestr,205)*50
	
	file:close()
	end


--endless levels need to be made entirely with "ENDLESS" pieces
--there need to be six green ones, and 12 blue ones.
--green ones are placed in order of which piece should spawn there.
--blue ones are placed in order of how late they should wait to spawn their piece.
--ie earlier in a run, blue pieces with lower numbers will be placed, later more and more start to spawn in the other places up to 12
function loadEndlessMap(filename)
	local file = love.filesystem.newFile(filename)
	file:open("r")
	local filestr = file:read()
	maps[-6] = {}
	for i=1,(16*12) do
		maps[-6][i] = string.byte(filestr,i)
		end
	local o = {}
	mappieces[-6] = {}
	for i=205,#filestr do
		if i%4~=0 then
			o[i%4] = string.byte(filestr,i+1)
			else
			o[4] = string.byte(filestr,i+1)
			table.insert(mappieces[-6],o)
			o = {}
			end
		end
	
	if mapstats[-6]==nil then mapstats[-6] = {} end
	mapstats[-6].name="Endless"
	
	file:close()
	end