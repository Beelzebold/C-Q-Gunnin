--cqgunnin level editor, nuff said

xofs = 0
menu = false
menuselect = 1
txtsel = 0
menuframes = 0
optmenu = false
cursorx = 4
cursory = 5
framecounter = 0

boolnum = { [true]=1, [false]=0 }
placementtype = false --false=tile true=object
placementteam = false --false=1 true=2
placementclass = 0 --also used for tile type

lvsettings = {{14,2,17,1,15,2,14,6,1,1,1,1},2}

level = {--default map
	3,3,3,3,4,4,4,4,4,4,4,4,3,3,3,3,
	3,2,2,2,1,1,1,1,1,1,1,1,2,2,2,3,
	3,2,2,3,1,1,1,1,1,1,1,1,3,2,2,3,
	3,2,2,2,1,1,1,1,1,1,1,1,2,2,2,3,
	3,2,3,3,3,1,1,4,4,1,1,3,3,3,2,3,
	3,2,2,2,4,1,1,4,4,1,1,4,2,2,2,3,
	3,2,2,2,4,1,1,4,4,1,1,4,2,2,2,3,
	3,2,3,3,3,1,1,4,4,1,1,3,3,3,2,3,
	3,2,2,2,1,1,1,1,1,1,1,1,2,2,2,3,
	3,2,2,3,1,1,1,1,1,1,1,1,3,2,2,3,
	3,2,2,2,1,1,1,1,1,1,1,1,2,2,2,3,
	3,3,3,3,4,4,4,4,4,4,4,4,3,3,3,3
}
objs = {--default pieces
	{2,1,4,3},
	{2,1,2,2},
	{1,2,13,9},
	{2,1,1,3},
	{1,2,14,8},
	{2,1,3,1},
	{1,2,12,10},
	{2,2,10,8},
}

require("assets")

function love.load()
	local dir = love.filesystem.getSourceBaseDirectory()
    local success = love.filesystem.mount(dir, "srcdir")
	
	screenCa = love.graphics.newCanvas(300,224)
	screenCa:setFilter("nearest")
	
	font = love.graphics.newFont("font/7x7-pixel-font.ttf",8,"mono")
	love.graphics.setFont(font)
	
	screenShader = love.graphics.newShader("palettequantize.gl")
	love.graphics.setShader(screenShader)
	
	local scale = love.graphics.getHeight()/224
	xofs = (love.graphics.getWidth()-(300*scale))/2
	
	love.keyboard.setKeyRepeat(true)
	end

function love.update(dt)
	framecounter = (framecounter+(dt*60))%256
	if (menu) or (optmenu) then
		menuframes=menuframes+1
		else
		menuframes=0
		menuselect=1
		end
	end

function love.draw()
	screenCa:renderTo(nikodraw)
	
	local scale = love.graphics.getHeight()/224
	xofs = (love.graphics.getWidth()-(300*scale))/2
	
	love.graphics.setShader(screenShader)
	love.graphics.clear(0.05,0.05,0.05)
	love.graphics.draw(screenCa,xofs,0,0,scale,scale)
	love.graphics.setShader()
	
	end
function nikodraw()
	love.graphics.clear(0,0,0)
	
	--draw the map
	local tilegraphics = {"dirt","floor","brick","water"}
	for i=1,(16*12) do
		local x=(i-1)%16
		local y=math.floor((i-1)/16)
		love.graphics.draw(graphics[tilegraphics[level[i] ] ],x*16+22,y*16)
		end
	
	--draw the pieces
	for i=1,#objs do
		love.graphics.draw(graphics["troop"..objs[i][2]],objs[i][3]*16+22,objs[i][4]*16)
		local gunx = 4-(objs[i][2]-1)*8
		love.graphics.draw(graphics["gun"..objs[i][1]..objs[i][2]],objs[i][3]*16+22+gunx,objs[i][4]*16+7)
		end
	
	--draw the cursor
	local cursorframe = math.floor(framecounter%64/32)+1
	if (not menu) then
		love.graphics.draw(graphics["cursor"..cursorframe],(cursorx*16)+22,cursory*16)
		end
	
	--draw the indicators
	love.graphics.rectangle("line",23,193,254,30)
	local typename = {"tile ","piece "}
	local teamname = {"green","blue"}
	local idnames = {
		{"dirt","floor","wall","water"},
		{"scout","rifle","sniper","support","smg","boss"}
	}
	monoprint("[A] type "..typename[boolnum[placementtype]+1],30,192)
	monoprint("[X]  "..typename[boolnum[placementtype]+1].."ID "..placementclass+1 .." ("..idnames[boolnum[placementtype]+1][placementclass+1]..")",30,200)
	if placementtype==true then
		monoprint("[S]  team "..teamname[boolnum[placementteam]+1],30,208)
		end
			
	--draw the menu
	if menuframes>0 and (menu) then
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",8*3+22,8*3,8*14,16*math.min(9,math.ceil(menuframes/3)))
		love.graphics.setColor(1,1,1)
		--menu text
		if menuframes>30 then
			local menutext = {"save level","settings","clear map","exit"}
			local seletext = {"SAVE LEVEL","SETTINGS","CLEAR MAP?","EXIT?"}
			for i=1,3 do
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
	--map settings menu
	if menuframes>0 and (optmenu) then
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",8*3+22,8*3,8*26,16*math.min(9,math.ceil(menuframes/3)))
		love.graphics.setColor(1,1,1)
		--menu text
		if menuframes>30 then
			local menutext = {"map name","par score"}
			local seletext = {"MAP NAME","PAR SCORE"}
			for i=1,2 do
				if i~=menuselect then
					monoprint(menutext[i],8*5+22,8*3+16*i)
					end
				if i==menuselect then
					monoprint(seletext[i],8*5+22,8*3+16*i)
					end
				end
			if txtsel>0 and framecounter%32>16 then
				love.graphics.print("_",8*(14+txtsel)+22,8*3+18)
				end
			nameprint(lvsettings[1],8*15+22,8*3+16)
			monoprint(""..lvsettings[2]*50,8*15+22,8*3+32)
			end
		end
	end

function love.keypressed(key,scancode,isrepeat)
	if (optmenu) then menu=false end
	
	if (not (menu or optmenu)) then
		if key=="right" then
			cursorx=cursorx+1
			end
		if key=="left" then
			cursorx=cursorx-1
			end
		if key=="down" then
			cursory=cursory+1
			end
		if key=="up" then
			cursory=cursory-1
			end
		if cursorx>15 then cursorx=15 end
		if cursorx<0 then cursorx=0 end
		if cursory>11 then cursory=11 end
		if cursory<0 then cursory=0 end
		
		if key=="x" then
			if placementtype==false then
				placementclass=(placementclass+1)%4
				else
				placementclass=(placementclass+1)%6
				end
			end
		if key=="s" then
			placementteam=(not placementteam)
			end
		if key=="a" then
			placementclass=math.min(placementclass,3)
			placementtype=(not placementtype)
			end
		if key=="z" then
			--place a tile/piece
			if placementtype==false then
				level[cursor2Map()]=placementclass+1
				else
				local obj=objAt(cursorx,cursory)
				if obj>0 then
					table.remove(objs,obj)
					end
				table.insert(objs,{placementclass+1,boolnum[placementteam]+1,cursorx,cursory})
				end
			end
		if (key=="delete" or key=="backspace") and placementtype==true then
			--delete a PIECE when in PIECE mode
			table.remove(objs,objAt(cursorx,cursory))
			end
		--if (yes menu) then
		else
		
		if (optmenu) then
			if key=="right" then
				if menuselect>1 then
					lvsettings[menuselect]=math.min(lvsettings[menuselect]+1,30)
					else
					if txtsel<12 then
						txtsel=txtsel+1
						end
					end
				end
			if key=="left" then
				if menuselect>1 then
					lvsettings[menuselect]=math.max(lvsettings[menuselect]-1,1)
					else
					if txtsel>0 then
						txtsel=txtsel-1
						end
					end
				end
			end
		
		if key=="down" then
			if not (optmenu and txtsel>0) then
				menuselect=menuselect+1
				if menuselect>3 then menuselect=3 end
				if (optmenu) and menuselect>2 then menuselect=2 end
				else
				lvsettings[1][txtsel]=(lvsettings[1][txtsel]%30)+1
				end
			end
		if key=="up" then
			if not (optmenu and txtsel>0) then
				menuselect=menuselect-1
				if menuselect<1 then menuselect=1 end
				else
				lvsettings[1][txtsel]=(lvsettings[1][txtsel]-2)%30+1
				end
			end
		if key=="z" and isrepeat==false then
			if (menu) then
				local menufunctions = {
					function()--save
						local chars = {" ","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","-","?","!"}
						local filesafechars = {" ","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","-"," "," "}
						local mapname = ""
						local filename = ""
						for i=1,#lvsettings[1] do
							mapname=mapname..chars[lvsettings[1][i]]
							filename=filename..filesafechars[lvsettings[1][i]]
							end
						local mapfile = love.filesystem.newFile(filename..".cqg")
						mapfile:open("w")
						
						local mapstr = ""
						--tiles
						for i=1,(16*12) do
							mapstr=mapstr..string.char(level[i])
							end
						--name
						for i=1,12 do
							mapstr=mapstr..string.char(lvsettings[1][i])
							end
						--par
						mapstr=mapstr..string.char(lvsettings[2])
						--pieces
						for i=1,#objs do
							for n=1,4 do
								mapstr=mapstr..string.char(objs[i][n])
								end
							end
						
						mapfile:write(mapstr)
						mapfile:close()
						
						menu=false
						end,
					function()--opt menu
						menu=false
						optmenu=true
						menuframes=0
						menuselect=1
						txtsel=0
						end,
					function()--clear
						for i=1,(16*12) do
							level[i]=math.min(placementclass,3)+1
							end
						objs = {}
						end,
					function()--BEGONE
						love.event.quit()
						end
				}
				menufunctions[menuselect]()
				end
			end
		if key=="x" then
			menu=false
			optmenu=false
			end
		end
	
	if key=="return" and isrepeat==false then
		--open the menu
		if (not optmenu) then menu=(not menu) end
		end
	end

function monoprint(text,x,y)
	-- Draw each character at fixed intervals
	--danke, chatgpt
	for i = 1, #text do
		local char = text:sub(i, i)
		love.graphics.setColor(0,0,0,1)
		if char~=" " then
			love.graphics.rectangle("fill",x + (i - 1) * 8, y,8,8)
			end
		love.graphics.setColor(1,1,1)
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
function nameprint(txttable,x,y)
	local chars = {" ","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","-","?","!"}
	for i = 1, #txttable do
		local char = chars[txttable[i]]
		love.graphics.setColor(0,0,0,1)
		if char~=" " then
			love.graphics.rectangle("fill",x + (i - 1) * 8, y,8,8)
			end
		love.graphics.setColor(1,1,1)
		if i==1 or txttable[i-1]==1 then char=string.upper(char) end
		love.graphics.print(char, x + (i - 1) * 8, y)
		end
	end
function objAt(ox,oy)
	for i=1,#objs do
		if objs[i][3]==ox and objs[i][4]==oy then
			return i
			end
		end
	return 0
	end
function cursor2Map()
	return (cursorx+1)+cursory*16
	end

function love.filedropped(file)
	file:open("r")
	local filestr = file:read()
	for i=1,(16*12) do
		level[i] = string.byte(filestr,i)
		end
	for i=1,12 do
		lvsettings[1][i] = string.byte(filestr,i+192)
		end
	lvsettings[2] = string.byte(filestr,205)
	local o = {}
	objs = {}
	for i=205,#filestr do
		if i%4~=0 then
			o[i%4] = string.byte(filestr,i+1)
			else
			o[4] = string.byte(filestr,i+1)
			table.insert(objs,o)
			o = {}
			end
		end
	file:close()
	end