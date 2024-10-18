--CQGunnin
--top down gridbased turnbased strategy game with lots of cqc and guns

configversion = 1
gameversion = "1.0.0"

gamestate = 0
STATE_TITLE = 0
STATE_MAPSEL = 1
STATE_CUSTOM = 2
STATE_GAME = 3
STATE_POST = 4
STATE_OPTS = 5
STATE_GAMEOPT = 6
STATE_STATS = 7

cursorx = 5
cursory = 5
--floats of 0..1, representing the position of the mouse cursor *on the canvas*
mousex = 0
mousey = 0

framecounter = 0
realframecounter = 0

turncounter = 0
currentteam = 1
winningteam = 1

selectedpiece = 0

menu = false
menuframes = 0
menuselect = 1
helpmenu = false
helpscreen = false
helppage = 1
optmenu = false
optscreen = false
fadeframes = 0
fade = 0
exiting = false
loadinglevel = false
endlv = false
custommenu = false

apluses = {0,0,0,0,0,0,0,0}
maxmaxmap = 8
maxendlessmaps = 12

endlessscreen = 1
endlesstimer = 601

skillnames = {"easy","medium","normal"}
controlnames = {"mouse","touch"}

--debug
drawpathmap = false

score = {0,0}
spilledblood = {0,0}
pkills = 0
pdmg = 0
pdeaths = 0

levelnum = 0

require("assets")
require("level")
require("input")
require("objects")
require("aiscripts")

require("helptext")

require("gamesave")

local json = require("json")

function saveConfig()
	love.filesystem.write("cqgcfg.json",json.encode(config))
	
	updateVol()
	end

function love.load(args)
	print("CQGunnin v"..gameversion)
	for _,v in ipairs(args) do
		local vfilename = v:match("[^/\\]+$") --make sure we just have the filename, not the full path.
		if love.filesystem.getInfo(vfilename,"file") then
			love.filedropped(love.filesystem.newFile(vfilename))
			gamestate=STATE_CUSTOM
			end
		local argfunctions = {
			["-pathmap"] = function()
				drawpathmap=true
				end,
			["-clearcfg"] = function()
				local configf=love.filesystem.newFile("cqgcfg.json")
				config = {sfx = 5,mus = 5,ai_skill = 3,ai_speed = 1,showrange = false,control = 1,version = configversion}
				love.filesystem.write("cqgcfg.json",json.encode(config))
				end,
		}
		if argfunctions[v]~=nil then
			argfunctions[v]()
			end
		end
	--framerate limiting
	min_dt = 1/60
	next_time = love.timer.getTime()
	
	if love.filesystem.getInfo("cqgcfg.json")==nil then
		local configf=love.filesystem.newFile("cqgcfg.json")
		print("init cfg file")
		end
	local configdat=love.filesystem.read("cqgcfg.json")
	print("get cfg file")
	
	if configdat then
		config = json.decode(configdat)
		if config.mousecontrol==nil then
			config.mousecontrol = true
			end
		if config.version~=configversion then
			config = {sfx = 5,mus = 5,ai_skill = 3,ai_speed = 1,showrange = false,control = 1,version = configversion}
			love.filesystem.write("cqgcfg.json",json.encode(config))
			end
		else
		config = {sfx = 5,mus = 5,ai_skill = 3,ai_speed = 1,showrange = false,control = 1,version = configversion}
		love.filesystem.write("cqgcfg.json",json.encode(config))
		end
	
	screenCa = love.graphics.newCanvas(300,224)
	screenCa:setFilter("nearest")
	
	font = love.graphics.newFont("font/7x7-pixel-font.ttf",8,"mono")
	love.graphics.setFont(font)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(2)
	
	screenShader = love.graphics.newShader("palettequantize.gl")
	love.graphics.setShader(screenShader)
	
	loadMapFile("maps/courtyard.cqg",1)
	loadMapFile("maps/waterways.cqg",2)
	loadMapFile("maps/river blitz.cqg",3)
	loadMapFile("maps/river blitz2.cqg",103)
	loadMapFile("maps/city boys.cqg",4)
	loadMapFile("maps/city boys2.cqg",104)
	loadMapFile("maps/city boys3.cqg",204)
	loadMapFile("maps/marshlands.cqg",5)
	loadMapFile("maps/marshlands2.cqg",105)
	loadMapFile("maps/marshlands3.cqg",205)
	loadMapFile("maps/bunker seige.cqg",6)
	loadMapFile("maps/bunker seige2.cqg",106)
	loadMapFile("maps/bunker seige3.cqg",206)
	loadMapFile("maps/bunker seige4.cqg",306)
	loadMapFile("maps/big trouble.cqg",7)
	loadMapFile("maps/big trouble2.cqg",107)
	loadMapFile("maps/big trouble3.cqg",207)
	loadMapFile("maps/showdown.cqg",8)
	loadMapFile("maps/showdown2.cqg",108)
	loadMapFile("maps/showdown3.cqg",208)
	loadMapFile("maps/street-sweep.cqg",9)
	loadMapFile("maps/street-sweep2.cqg",109)
	loadMapFile("maps/street-sweep3.cqg",209)
	loadMapFile("maps/street-sweep4.cqg",309)
	maxmap=1
	
	if love.filesystem.getInfo("cqgsave.cqs","file") then
		loadSave()
		end
	if apluses[1]>0 and apluses[2]>0 and apluses[3]>0 and apluses[4]>0 and apluses[5]>0 and apluses[6]>0 and apluses[7]>0 and apluses[8]>0 then
		maxmap=9
		end
	
	local scale = love.graphics.getHeight()/224
	xofs = (love.graphics.getWidth()-(300*scale))/2
	
	love.keyboard.setKeyRepeat(true)
	
	updateVol()
	end

function love.update(dt)
	--framerate limiting
	next_time = next_time + min_dt
	
	framecounter = (framecounter+(dt*60))%256
	realframecounter = (realframecounter+1)%256
	
	local aitics = math.floor(32/config.ai_speed)
	if gamestate==STATE_GAME and currentteam==2 and realframecounter%aitics==0 then
		aistate = AITurn()
		end
	
	if levelnum==-6 and currentteam==1 then
		endlesstimer=endlesstimer-dt
		if endlesstimer<0 then
			gameover(2)
			end
		end
	
	if framecounter%32<1 and (gamestate==STATE_GAME or gamestate==STATE_GAMEOPT) and (not helpscreen) then music["battle"..mapstats[levelnum].music]:play() end
	if framecounter%16<1 and helpscreen and gamestate==STATE_GAME then music.helpme:play() end
	if framecounter%16<1 and gamestate==STATE_POST then music.results:play() end
	if framecounter%16<1 and gamestate==STATE_MAPSEL or gamestate==STATE_CUSTOM then music.menu:play() end
	if (gamestate==STATE_TITLE or gamestate==STATE_OPTS or gamestate==STATE_STATS) then music.title:play() end
	if (menu) then
		menuframes=menuframes+dt*60
		else
		menuframes=0
		if gamestate~=STATE_MAPSEL and gamestate~=STATE_TITLE and gamestate~=STATE_OPTS and gamestate~=STATE_GAMEOPT then
			menuselect=1
			end
		end
	fadeframes=fadeframes+fade
	if fadeframes>60 then
		for k in pairs(music) do
		music[k]:stop()
		end
		fade=fade*-1
		helpscreen=helpmenu
		helppage=1
		optscreen=optmenu
		
		local t=countTeamPieces()
		if (t[1]==0 or t[2]==0 or (levelnum==-6 and endlesstimer<0)) and gamestate==STATE_GAME then
			if winningteam==2 or (mapstats[levelnum].nextmap<1 and levelnum~=-6) then
				--win bonus
				score[winningteam]=score[winningteam]+60
				--perfect bonus
				if pdeaths<1 then score[winningteam]=math.floor(score[winningteam]*1.3+10) end
				
				--add player stats
				stats.blood = stats.blood + math.floor(spilledblood[1]/1000+0.5)
				stats.damage = stats.damage + pdmg
				stats.kills = stats.kills + pkills
				if levelnum~=-6 then
					--you have to at least get a C to unlock the next map
					local grade = math.ceil((score[currentteam]/mapstats[levelnum%100].par)*5-1)
					if winningteam==1 and grade>2 then
						if levelnum%100==maxmap then maxmap=math.min(maxmap+1,maxmaxmap) end
						end
					
					--A+ update
					if levelnum%100<9 then
						if grade>5 then apluses[levelnum%100]=1 end
						end
					end
				
				updateSave()
				
				if apluses[1]>0 and apluses[2]>0 and apluses[3]>0 and apluses[4]>0 and apluses[5]>0 and apluses[6]>0 and apluses[7]>0 and apluses[8]>0 then
					maxmap=9
					end
				
				gamestate=STATE_POST
				else
				nextLevel(mapstats[levelnum].nextmap)
				end
			end
		
		if endlv==true then
			endlv=false
			gamestate=STATE_MAPSEL
			end
		if custommenu==true then
			custommenu=false
			gamestate=STATE_CUSTOM
			end
		if loadinglevel==true then
			loadinglevel=false
			gamestate=STATE_GAME
			menuselect = 1
			end
		if exiting==true then gamestate=STATE_TITLE;exiting=false;menuselect=1 end
		end
	if fadeframes<0 then fade=0 end
	end

function love.draw()
--	print("draw")
--	aiticked = false
	
	screenCa:renderTo(nikodraw)
	
	local scale = love.graphics.getHeight()/224
	xofs = (love.graphics.getWidth()-(300*scale))/2
	
	love.graphics.setShader(screenShader)
	love.graphics.clear(0.05,0.05,0.05)
	local brightness = math.floor((45-fadeframes)/9)/5
	love.graphics.setColor(brightness,brightness,brightness,1)
	love.graphics.draw(screenCa,xofs,0,0,scale,scale)
	love.graphics.setColor(1,1,1)
	love.graphics.setShader()
	
	--also fade music with the screen
	for k in pairs(music) do
		music[k]:setVolume(brightness*(config.mus/20))
		end
	music.victory:setVolume(config.sfx/20)
	
	--framerate limiting
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
		end
	love.timer.sleep(next_time - cur_time)
	end

function nikodraw()
	love.graphics.clear(0,0,0)
	
	if gamestate==STATE_TITLE then
		love.graphics.clear(0,0,0)
		--the scrolling water
		love.graphics.setColor(1,1,1)
		love.graphics.draw(graphics.waterbig,(-24)+(framecounter/2)%16,0)
		--nameplate
		love.graphics.setColor(0.3,0.2,0)
		love.graphics.rectangle("fill",8*20,8*3,8*14,8*5)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",8*21,8*4,8*12,8*3)
		love.graphics.setColor(1,1,1,1)
		monoprint("C-Q-GUNNIN",8*22,8*5)
		love.graphics.setColor({0.1764705882352941,0.5490196078431373,0.1607843137254902,1})
		love.graphics.rectangle("line",4+8*20,4+8*3,8*13,8*4)
		--the window
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",8*3,8*3,8*14,16*11)
		love.graphics.setColor(1,1,1)
		monoprint("by beelzebold",8*3,8*22)
		monoprint("aka kiwi",8*6,8*23)
		monoprint("v"..gameversion,8*3,8*24)
		--the text
		local menutext = {"missions","custom map","endless","options","stats","exit"}
		local seletext = {"MISSIONS","CUSTOM MAP","ENDLESS","OPTIONS","STATS","EXIT?"}
		for i=1,6 do
			if i~=menuselect then
				monoprint(menutext[i],8*5,8*3+16*i)
				end
			if i==menuselect and framecounter%32<16 then
				monoprint(seletext[i],8*5,8*3+16*i)
				end
			end
		end
	if gamestate==STATE_OPTS or gamestate==STATE_GAMEOPT then
		love.graphics.clear(0,0,0)
		--the scrolling water
		love.graphics.setColor(1,1,1)
		if gamestate==STATE_OPTS then
			love.graphics.draw(graphics.waterbig,(-24)+(framecounter/2)%16,0)
			end
		--the window
		love.graphics.setColor(0.3,0.2,0)
		love.graphics.rectangle("fill",8*2,8*2,224,176)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",8*3,8*3,224-16,176-16)
		love.graphics.setColor(1,1,1,1)
		love.graphics.rectangle("line",4+8*2,4+8*2,216,168)
		--the text
		local menutext = {"mus","sfx","AI skill","AI speed","show range"}
		local seletext = {"MUS","SFX","AI SKILL","AI SPEED","SHOW RANGE"}
		local textbool = {[true]="on",[false]="off"}
		local values = {config.mus,config.sfx,skillnames[config.ai_skill],config.ai_speed,textbool[config.showrange]}
		for i=1,4 do
			monoprint(""..values[i],8*17,8*3+16*i)
			if i~=menuselect then
				monoprint(menutext[i],8*5,8*3+16*i)
				end
			if i==menuselect and framecounter%32<16 then
				monoprint(seletext[i],8*5,8*3+16*i)
				end
			end
		monoprintlines("use the ARROW KEYS to\nnavigate this menu!",8*5,8*14)
		end
	if gamestate==STATE_STATS then
		love.graphics.clear(0,0,0)
		love.graphics.setColor(1,1,1)
		--the window
		love.graphics.setColor(0.3,0.2,0)
		love.graphics.rectangle("fill",8*2,8*2,224,176)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",8*3,8*3,224-16,176-16)
		love.graphics.setColor(1,1,1,1)
		love.graphics.rectangle("line",4+8*2,4+8*2,216,168)
		--the text
		monoprint("ENEMIES killed",8*4,8*4)
		monoprint(""..stats.kills,8*5,8*5)
		monoprint("BLOOD spilled",8*4,8*7)
		monoprint(""..stats.blood.." L",8*5,8*8)
		monoprint("DAMAGE dealt",8*4,8*10)
		monoprint(""..stats.damage,8*5,8*11)
		monoprint("ENDLESS best",8*4,8*13)
		monoprint(""..stats.screenendless,8*5,8*14)
		
		monoprint("COMPLETION",8*6,8*17)
		local apluscount = 0
		for i=1,8 do
			apluscount=apluscount+apluses[i]
			end
		--maxmap goes to 9 but starts at 1 so subtract 1, apluscount goes to 8, each one is worth 100/16 percent points
		monoprint(""..math.ceil(((maxmap-1)+apluscount)*(100/16)) .."%",8*7,8*18)
		end
	
	if gamestate==STATE_MAPSEL then
		--map select background
		love.graphics.clear(0,0,0)
		--the scrolling water
		love.graphics.setColor(1,1,1)
		love.graphics.draw(graphics.waterbig,(-24)+(framecounter/4)%16,0)
		--the window
		love.graphics.setColor(0.3,0.2,0)
		love.graphics.rectangle("fill",22+8*2,8*2,224,176)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",22+8*3,8*3,224-16,8)
		love.graphics.rectangle("fill",22+8*3,8*5,224-16,176-32)
		love.graphics.setColor(1,1,1,1)
		love.graphics.rectangle("line",26+8*2,4+8*2,216,168)
		love.graphics.line(26+8*2+1,4+8*4,216+26+8*2-1,4+8*4)
		
		--arrows
		if menuselect<maxmap then
			love.graphics.draw(graphics.arrowr,(framecounter%64<32) and 270 or 271,96)
			end
		if menuselect>1 then
			love.graphics.draw(graphics.arrowl,(framecounter%64<32) and 14 or 13,96)
			end
		
		--the text
		monoprint(mapstats[menuselect].name,46,8*3)
		monoprint("map "..menuselect,46+(8*20),8*3)
		
		monoprint("par score",46+(8*11),8*6)
		monoprint(""..mapstats[menuselect].par,46+(8*12),8*7)
		
		if menuselect<9 then
			love.graphics.setColor(0.3,0.15,0.15,1)
			if apluses[menuselect]>0 then
				love.graphics.setColor(0,1,0,1)
				end
			monoprint("A+",46+(8*11),8*9)
			love.graphics.setColor(1,1,1)
			end
		
		monoprintlines(mapdesc[menuselect],46,8*12)
		
		--draw the map preview
		local tilegraphics = {"dirt","floor","brick","water"}
		for i=1,(16*12) do
			local x=(i-1)%16
			local y=math.floor((i-1)/16)
			local tgraph = tilegraphics[maps[menuselect][i] ]
			love.graphics.draw(graphics[tgraph],x*4+62,y*4+44,0,0.25,0.25)
			end
		end
	
	if gamestate==STATE_CUSTOM then
		--map select background
		love.graphics.clear(0,0,0)
		--the scrolling water
		love.graphics.setColor(1,1,1)
		love.graphics.draw(graphics.waterbig,(-24)+(framecounter/4)%16,0)
		--the window
		love.graphics.setColor(0.3,0.2,0)
		love.graphics.rectangle("fill",22+8*2,8*2,224,176)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",22+8*3,8*3,224-16,8)
		love.graphics.rectangle("fill",22+8*3,8*5,224-16,176-32)
		love.graphics.setColor(1,1,1,1)
		love.graphics.rectangle("line",26+8*2,4+8*2,216,168)
		love.graphics.line(26+8*2+1,4+8*4,216+26+8*2-1,4+8*4)
		
		--the text
		if #maps[-1]==(16*12) then
			monoprint(mapstats[-1].name,46,8*3)
			
			monoprint("par score",46+(8*11),8*6)
			monoprint(""..mapstats[-1].par,46+(8*12),8*7)
			
			--draw the map preview
			local tilegraphics = {"dirt","floor","brick","water"}
			for i=1,(16*12) do
				local x=(i-1)%16
				local y=math.floor((i-1)/16)
				local tgraph = tilegraphics[maps[-1][i] ]
				love.graphics.draw(graphics[tgraph],x*4+62,y*4+44,0,0.25,0.25)
				end
			else
			monoprintlines("please drag and drop a\n.cqg level file.",46,8*6)
			end
		end
	
	if gamestate==STATE_POST then
		--results screen background
		local teamcol = {{0.1764705882352941,0.5490196078431373,0.1607843137254902,1},{0.1607843137254902,0.4509803921568627,0.6117647058823529,1}}
		love.graphics.clear(0,0,0)
		--the scrolling water
		love.graphics.setColor(0.6,0.6,0.6)
		love.graphics.draw(graphics.waterbig,(-24)+(framecounter/4)%16,0)
		--the window
		love.graphics.setColor(0.3,0.2,0)
		love.graphics.rectangle("fill",22+8*2,8*2,224,176)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",22+8*3,8*3,224-16,8)
		love.graphics.rectangle("fill",22+8*3,8*5,224-16,176-32)
		love.graphics.setColor(teamcol[winningteam])
		love.graphics.rectangle("line",26+8*2,4+8*2,216,168)
		love.graphics.line(26+8*2+1,4+8*4,216+26+8*2-1,4+8*4)
		love.graphics.setColor(1,1,1)
		
		--the text
		monoprint(mapstats[levelnum].name,46,8*3)
		
		monoprint("turns:          "..turncounter,46,8*5)
		monoprint("blood spilled:  "..math.floor(spilledblood[currentteam]/100)/10 .."L",46,8*6)
		
		monoprint("final score:    "..score[currentteam],46,8*8)
		if levelnum~=-6 then
			monoprint("par score:      "..mapstats[levelnum%100].par,46,8*9)
			
			local lettergrades = {"F","D","C","B","A","A+","S","S+"}
			local grade = math.ceil((score[currentteam]/mapstats[levelnum%100].par)*5-1)
			grade = math.max(math.min(grade,8),1)
			monoprint("GRADE "..lettergrades[grade],46,8*10)
			end
		
		if winningteam~=1 then
			love.graphics.setColor(1,0,0,1)
			monoprint("FAIL",46,8*12)
			love.graphics.setColor(1,1,1)
			else
			if pdeaths<1 then
				love.graphics.setColor(0,1,0,1)
				monoprint("PERFECT",46,8*12)
				love.graphics.setColor(1,1,1)
				end
			end
		end
	
	if gamestate==STATE_GAME then
		--draw the map
		local tilegraphics = {"dirt","floor","brick","water"}
		local tilerng = love.math.newRandomGenerator(mapstats[levelnum].par*level[20]*level[40])
		for i=1,(16*12) do
			local x=(i-1)%16
			local y=math.floor((i-1)/16)
			local tgraph = tilegraphics[level[i] ]
			love.graphics.draw(graphics[tgraph],x*16+22,y*16)
			if drawpathmap==true then
				local pmapcol = {[true]={0.25,1,0.25,1},[false]={1,0.25,0.25,1}}
				love.graphics.setColor(pmapcol[pathmap[x+1][y+1]])
				love.graphics.setLineWidth(1)
				love.graphics.rectangle("line",x*16+23,y*16+1,15,15)
				love.graphics.setColor(1,1,1,1)
				love.graphics.setLineWidth(2)
				end
			end
		
		--draw the pieces
		for i=1,#objs do
			if objs[i].actpts<math.min(objs[i].movecost,objs[i].atkcost) or objs[i].team~=currentteam then
				love.graphics.setColor(0.5,0.5,0.5,1)
				end
			love.graphics.draw(graphics["troop"..objs[i].team],objs[i].pox*16+22,objs[i].poy*16)
			local gunframe = (math.floor(framecounter%64/32)+objs[i].team)%2+1
			local gunx = 4-(objs[i].team-1)*8
			if (not menu) then
				love.graphics.draw(graphics["gun"..objs[i].class..objs[i].team],objs[i].pox*16+22+gunx,objs[i].poy*16+6+gunframe)
				end
			love.graphics.setColor(1,1,1)
			
			if i==selectedpiece then
				if (not menu) then
					love.graphics.draw(graphics.cursor3,objs[i].pox*16+22,objs[i].poy*16)
					end
				end
			end
		for i=1,#objs do
			--draw move range
			if i==selectedpiece or (objs[i].pox==cursorx and objs[i].poy==cursory) then
				local teamcol = {{0.1764705882352941,0.5490196078431373,0.1607843137254902,1},{0.1607843137254902,0.4509803921568627,0.6117647058823529,1}}
				love.graphics.setColor(teamcol[objs[i].team])
				love.graphics.setLineWidth(1)
				local moverange = math.floor(objs[i].actpts/objs[i].movecost)+1
				for n=1,moverange do
					--left
					love.graphics.line((objs[i].pox-(moverange-n))*16+22+1,(objs[i].poy+(n-1))*16,(objs[i].pox-(moverange-n))*16+22+1,(objs[i].poy+n)*16)
					love.graphics.line((objs[i].pox-(moverange-n))*16+22+1,(objs[i].poy+n)*16,(objs[i].pox+1-(moverange-n))*16+22,(objs[i].poy+n)*16)
					--right
					love.graphics.line((objs[i].pox+(moverange-n))*16+22+16,(objs[i].poy-(n-1))*16+16,(objs[i].pox+(moverange-n))*16+22+16,(objs[i].poy-n)*16+16)
					love.graphics.line((objs[i].pox+(moverange-n))*16+22+16,(objs[i].poy-n)*16+17,(objs[i].pox-1+(moverange-n))*16+22+16,(objs[i].poy-n)*16+16)
					--up
					love.graphics.line((objs[i].pox-(n-1))*16+22,(objs[i].poy-(moverange-n))*16+1,(objs[i].pox-(n-2))*16+22,(objs[i].poy-(moverange-n))*16+1)
					love.graphics.line((objs[i].pox-(n-1))*16+23,(objs[i].poy-(moverange-n))*16+1,(objs[i].pox-(n-1))*16+23,(objs[i].poy-(moverange-(n+1)))*16)
					--down
					love.graphics.line((objs[i].pox+n)*16+22,(objs[i].poy+(moverange-(n-1)))*16,(objs[i].pox+(n-1))*16+22,(objs[i].poy+(moverange-(n-1)))*16)
					love.graphics.line((objs[i].pox+n)*16+22,(objs[i].poy+(moverange-(n-1)))*16,(objs[i].pox+n)*16+22,(objs[i].poy+(moverange-n))*16)
					end
				love.graphics.setColor(1,1,1)
				love.graphics.setLineWidth(2)
				end
			end
		if framecounter%64<32 then
			for i=1,#objs do
				--draw attack range
				if i==selectedpiece or (objs[i].pox==cursorx and objs[i].poy==cursory) then
					love.graphics.setColor(1,0.25,0.25,1)
					love.graphics.setLineWidth(1)
					for n=1,objs[i].range do
						--left
						love.graphics.line((objs[i].pox-(objs[i].range-n))*16+22+1,(objs[i].poy+(n-1))*16,(objs[i].pox-(objs[i].range-n))*16+22+1,(objs[i].poy+n)*16)
						love.graphics.line((objs[i].pox-(objs[i].range-n))*16+22+1,(objs[i].poy+n)*16,(objs[i].pox+1-(objs[i].range-n))*16+22,(objs[i].poy+n)*16)
						--right
						love.graphics.line((objs[i].pox+(objs[i].range-n))*16+22+16,(objs[i].poy-(n-1))*16+16,(objs[i].pox+(objs[i].range-n))*16+22+16,(objs[i].poy-n)*16+16)
						love.graphics.line((objs[i].pox+(objs[i].range-n))*16+22+16,(objs[i].poy-n)*16+17,(objs[i].pox-1+(objs[i].range-n))*16+22+16,(objs[i].poy-n)*16+16)
						--up
						love.graphics.line((objs[i].pox-(n-1))*16+22,(objs[i].poy-(objs[i].range-n))*16+1,(objs[i].pox-(n-2))*16+22,(objs[i].poy-(objs[i].range-n))*16+1)
						love.graphics.line((objs[i].pox-(n-1))*16+23,(objs[i].poy-(objs[i].range-n))*16+1,(objs[i].pox-(n-1))*16+23,(objs[i].poy-(objs[i].range-(n+1)))*16)
						--down
						love.graphics.line((objs[i].pox+n)*16+22,(objs[i].poy+(objs[i].range-(n-1)))*16,(objs[i].pox+(n-1))*16+22,(objs[i].poy+(objs[i].range-(n-1)))*16)
						love.graphics.line((objs[i].pox+n)*16+22,(objs[i].poy+(objs[i].range-(n-1)))*16,(objs[i].pox+n)*16+22,(objs[i].poy+(objs[i].range-n))*16)
						end
					love.graphics.setColor(1,1,1)
					love.graphics.setLineWidth(2)
					end
				end
			end
		
		--draw the cursor
		local cursorframe = math.floor(framecounter%64/32)+1
		if (not menu) then
			love.graphics.draw(graphics["cursor"..cursorframe],(cursorx*16)+22,cursory*16)
			end
		--black borders
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",22,192,256,32)
		love.graphics.rectangle("fill",0,0,22,224)
		love.graphics.rectangle("fill",256+22,0,22,224)
		
		--draw the teamcolored outline on the statbar
		--these numbers may seem oddly specific but they should be at least close enough to the exact same color as the troops themselves
		local teamcol = {{0.1764705882352941,0.5490196078431373,0.1607843137254902,1},{0.1607843137254902,0.4509803921568627,0.6117647058823529,1}}
		love.graphics.setColor(teamcol[currentteam])
		love.graphics.rectangle("line",23,193,254,30)
		love.graphics.setColor(1,1,1)
		
		--draw the highlighted piece's stats
		if objAt(cursorx,cursory)>0 then
			o=objs[objAt(cursorx,cursory)]
			
			local classnames = {"scout","rifleman","marksman","support","raider","warlord"}
			
			monoprint(classnames[o.class],30,192)
			monoprint("HP "..o.hp,38,200)
			monoprint("AP "..o.actpts,38,208)
			monoprint("L"..o.lvl.." ",38,216)
			if o.lvl<5 then
				monoprint(o.exp.."/"..o.lvl*6+6,38+(8*3),216)
				else
				monoprint(""..o.exp+84,38+(8*3),216)--84 here is the total amt of EXP to reach L5
				end
			monoprint("atkrange "..o.range-1,30+(8*9),192)
			monoprint("atk  dmg "..o.dmg,30+(8*9),200)
			monoprint("atk cost "..o.atkcost,30+(8*9),208)
			monoprint("movecost "..o.movecost,30+(8*9),216)
			
			--draw the highlighted piece's possible attacks
			for i=1,#objs do
				e=objs[i]
				if math.abs(o.pox-e.pox)+math.abs(o.poy-e.poy)<o.range and o.actpts>o.atkcost-1 and o.team~=e.team then
					love.graphics.draw(graphics["cursor"..cursorframe+3],e.pox*16+22,e.poy*16)
					end
				end
			end
		monoprint("score",30+(8*21),200)
		monoprint(""..score[currentteam],30+(8*27),200)
		monoprint("turn",30+(8*22),208)
		monoprint(""..turncounter,30+(8*27),208)
		if levelnum==-6 then
			monoprint("screen",30+(8*20),216)
			monoprint(""..endlessscreen,30+(8*27),216)
			monoprint("timer",30+(8*21),192)
			if endlesstimer<90 and framecounter%64<8 then love.graphics.setColor(1,0,0,1) end
			monoprint(""..timerText(endlesstimer),30+(8*26),192)
			end
		
		--draw the menu
		if menuframes>0 then
			love.graphics.setColor(0,0,0,1)
			love.graphics.rectangle("fill",8*3+22,8*3,8*14,16*math.min(9,math.ceil(menuframes/3)))
			love.graphics.setColor(1,1,1)
			--menu text
			if menuframes>30 then
				local menutext = {"help","end turn","options","retreat","back"}
				local seletext = {"HELP","END TURN","OPTIONS","END GAME?","BACK"}
				for i=1,5 do
					if i~=menuselect then
						monoprint(menutext[i],8*5+22,8*3+16*i)
						end
					--yk I wasn't gonna make the selection flash but I feel like it'll just make it just that little bit less bland and static
					if i==menuselect and framecounter%32<16 then
						monoprint(seletext[i],8*5+22,8*3+16*i)
						end
					end
				end
			end
		
		--draw the help screen
		if (helpscreen) then
			love.graphics.clear(0,0,0)
			love.graphics.setColor(0.3,0.2,0)
			love.graphics.rectangle("fill",22+8*2,8*2,224,176)
			love.graphics.setColor(0,0,0,1)
			love.graphics.rectangle("fill",22+8*3,8*3,224-16,8)
			love.graphics.rectangle("fill",22+8*3,8*5,224-16,176-32)
			love.graphics.setColor(teamcol[currentteam])
			love.graphics.rectangle("line",26+8*2,4+8*2,216,168)
			love.graphics.line(26+8*2+1,4+8*4,216+26+8*2-1,4+8*4)
			love.graphics.setColor(1,1,1)
			
			--actually draw the text
			monoprint(helptitles[helppage],46,8*3)
			monoprint("HELP",46+176,8*5)
			monoprint("pg "..helppage,46+(168),8*3)
			monoprint("UP",46+176+8*5,8*3)
			monoprint("prev",46+176+8*5,8*4)
			monoprint("DN",46+176+8*5,8*21)
			monoprint("next",46+176+8*5,8*22)
			monoprintlines(helppages[helppage],46,8*5)
			end
		end
	end

function timerText(timet)
	timet=math.max(timet,0)
	local strmins = ""..math.floor(timet/60)
	local strsec = ""..math.floor(timet%60)
	if timet%60<10 then strsec="0"..strsec end
	if timet/60<10 then strmins=" "..strmins end
	return strmins..":"..strsec
	end

function monoprint(text,x,y)
	-- Draw each character at fixed intervals
	--danke, chatgpt
	for i = 1, #text do
		local char = text:sub(i, i)
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(0,0,0,1)
		if char~=" " then
			love.graphics.rectangle("fill",x + (i - 1) * 8, y,8,8)
			end
		love.graphics.setColor(r,g,b,1)
		love.graphics.print(char, x + (i - 1) * 8, y)
		end
	end
function monoprintlines(text,x,y)
	-- Split text into lines
	local lines = {}
	for line in text:gmatch("[^\n]+") do
		table.insert(lines, line)
		end
	
	-- Draw each line
	for i, line in ipairs(lines) do
		-- Draw each character at fixed intervals
		for j = 1, #line do
			local char = line:sub(j, j)
			love.graphics.setColor(0,0,0,1)
			if char~=" " then
				love.graphics.rectangle("fill",x + (j - 1) * 8, y + (i - 1) * 8,8,8)
				end
			love.graphics.setColor(1,1,1)
			love.graphics.print(char, x + (j - 1) * 8, y + (i - 1) * 8)
			end
		end
	end


function nextturn()
	score[1]=score[1]-2
	score[2]=score[2]-2
	selectedpiece=0
	menu=false
	currentteam=currentteam+1
	if currentteam>2 then
		currentteam=1
		turncounter=turncounter+1
		end
	for i=1,#objs do
		if objs[i]~=nil and objs[i].hp~=nil then
			objs[i].oldpos = nil --reset this for the ai :3
			objs[i].notargets = nil
			
			objs[i].actpts=20
			if objs[i].class<3 then objs[i].actpts=10+((objs[i].lvl-1)*3)+math.ceil(objs[i].hp/2) end
			if objs[i].hp<15 then
				if objs[i].team~=currentteam then
					spilledblood[currentteam]=spilledblood[currentteam]+math.floor(40-objs[i].hp*2)
					end
				end
			end
		end
	end
function exitgame()
	fade = 0.5
	exiting = true
	end
function gameover(team)
	fade=0.5
	currentteam=1
	winningteam=team
	--score[team]=score[team]+60-turncounter*5
	end