function love.keypressed(key,scancode,isrepeat)
	if gamestate==STATE_GAME and currentteam==2 then
		--aistate = AITurn()
		return
		end
	
	if gamestate==STATE_GAME then
		local t=countTeamPieces()
		if t[1]==0 then
			gameover(2)
			end
		if t[2]==0 then
			gameover(1)
			end
		if (not menu) then
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
				selectedpiece=0
				end
			--we both know the zpress code looks awful, just shut up about it please
			if key=="z" and isrepeat==false and currentteam==1 then
				zpress(cursorx,cursory)
				end
			else --menu code
			if key=="down" then
				if (helpscreen) then
					helppage=helppage+1
					if helppage>#helptitles then helppage=#helptitles end
					else
					menuselect=menuselect+1
					if menuselect>4 then menuselect=4 end
					end
				end
			if key=="up" then
				if (helpscreen) then
					helppage=helppage-1
					if helppage<1 then helppage=1 end
					else
					menuselect=menuselect-1
					if menuselect<1 then menuselect=1 end
					end
				end
			if key=="z" and isrepeat==false then
				local menufunctions = {
					function()
						helpmenu=(not helpmenu)
						fade=1
						end,
					function()
						nextturn()
						end,
					function()
						gamestate=STATE_GAMEOPT
						end,
					function()
						exitgame()
						end
				}
				menufunctions[menuselect]()
				end
			if key=="x" then
				if (helpscreen) then
					helpmenu=(not helpmenu)
					fade=1
					else
					menu=(not menu)
					end
				end
			end
		
		if key=="return" and isrepeat==false then
			--open the menu
			menu=(not menu)
			end
		end
	
	if gamestate==STATE_MAPSEL then
		if key=="right" then
			menuselect=menuselect+1
			if menuselect>maxmap then menuselect=maxmap end
			end
		if key=="left" then
			menuselect=menuselect-1
			if menuselect<1 then menuselect=1 end
			end
		
		if key=="z" then
			initLevel(menuselect)
			end
		if key=="x" then
			fade=1
			exiting=true
			end
		end
	if gamestate==STATE_CUSTOM then
		if key=="z" then
			if #maps[-1]==(16*12) then
				initLevel(-1)
				else
				sfx.nuhuh:stop();sfx.nuhuh:play()
				end
			end
		if key=="x" then
			fade=1
			exiting=true
			end
		end
	if gamestate==STATE_POST then
		if key=="z" or key=="x" or key=="return" then
			menuselect=1
			fade=1
			endlv=true
			end
		end
	
	if gamestate==STATE_OPTS or gamestate==STATE_GAMEOPT then
		if key=="down" then
			menuselect=menuselect+1
			if menuselect>4 then menuselect=4 end
			end
		if key=="up" then
			menuselect=menuselect-1
			if menuselect<1 then menuselect=1 end
			end
		
		if key=="right" then
			local menufunctions = {
				function()--mus
					config.mus = math.min(config.mus+1,20)
					end,
				function()--sfx
					config.sfx = math.min(config.sfx+1,20)
					end,
				function()--ai_skill
					config.ai_skill = math.min(config.ai_skill+1,3)
					end,
				function()--ai_speed
					config.ai_speed = math.min(config.ai_speed+1,4)
					end,
				function()--showrange
					config.showrange = true
					end
			}
			menufunctions[menuselect]()
			end
		if key=="left" then
			local menufunctions = {
				function()--mus
					config.mus = math.max(config.mus-1,0)
					end,
				function()--sfx
					config.sfx = math.max(config.sfx-1,0)
					end,
				function()--ai_skill
					config.ai_skill = math.max(config.ai_skill-1,1)
					end,
				function()--ai_speed
					config.ai_speed = math.max(config.ai_speed-1,1)
					end,
				function()--showrange
					config.showrange = false
					end
			}
			menufunctions[menuselect]()
			end
		if key=="x" then
			saveConfig()
			if gamestate==STATE_OPTS then
				gamestate=STATE_TITLE
				else
				gamestate=STATE_GAME
				end
			menuselect=1
			end
		end
	if gamestate==STATE_TITLE then
		if key=="down" then
			menuselect=menuselect+1
			if menuselect>5 then menuselect=5 end
			end
		if key=="up" then
			menuselect=menuselect-1
			if menuselect<1 then menuselect=1 end
			end
		if key=="z" and isrepeat==false then
			local menufunctions = {
				function()--missions
					endlv=true
					fade=1
					end,
				function()--custom level
					custommenu=true
					fade=1
					end,
				function()--endless
					
					end,
				function()--optmenu
					gamestate=STATE_OPTS
					menuselect=1
					end,
				function()
					love.event.quit()
					end
			}
			menufunctions[menuselect]()
			end
		end
	end

function zpress(px,py)
	cursorx=px
	cursory=py
	
	if selectedpiece==0 then
		--select a piece
		o=objAt(px,py)
		if o>0 then
			o=objs[o]
			if o.team==currentteam then
				selectedpiece=o.id
				print("selected obj#"..selectedpiece)
				end
			end
		else
		--clicked on another piece
		o=objAt(px,py)
		if o>0 then
			e=objs[o]
			if e.team==currentteam then
				--deselect (clicked on a friendly)
				o=objs[selectedpiece]
				selectedpiece=e.id
				if math.abs(o.pox-px)+math.abs(o.poy-py)<2 then
					sfx.nuhuh:stop()
					sfx.nuhuh:play()
					end
				print("invalid move (clicked on a friendly)")
				else
				--attack!
				o=objs[selectedpiece]
				local los = checkObjLOS(o,e)
				print("has LOS:");print(los)
				if (not los) then print("invalid move (line of sight blocked)");sfx.nuhuh:stop();sfx.nuhuh:play() end
				if o.actpts>o.atkcost-1 and math.abs(o.pox-e.pox)+math.abs(o.poy-e.poy)<o.range and (los) then
					--here the attack was successful
					local atksfx = {"pistol","rifle","sniper","rifle","pistol","sniper"}
					sfx[atksfx[o.class]]:stop()
					sfx[atksfx[o.class]]:play()
					
					o.actpts=o.actpts-o.atkcost
					e.hp=math.max(0,e.hp-o.dmg)
					spilledblood[currentteam]=spilledblood[currentteam]+(o.dmg*80)
					score[currentteam]=score[currentteam]+(o.dmg*2)
					score[e.team]=score[e.team]-math.floor(o.dmg*1.5)
					spilledblood[currentteam]=spilledblood[currentteam]+15
					if love.math.random(0,3)<1 then
						e.hp=math.max(0,e.hp-math.floor(o.dmg*0.5))
						spilledblood[currentteam]=spilledblood[currentteam]+(o.dmg*60)
						score[currentteam]=score[currentteam]+math.floor(o.dmg*1.5)
						spilledblood[currentteam]=spilledblood[currentteam]+13
						end
					if e.hp<1 then
						killObj(e,o)
						end
					end
				end
			else
			o=objs[selectedpiece]
			--clicked on a tile
			print("tile clicked is id"..level[(px+1)+py*16])
			if level[(px+1)+py*16]>2 then
				--clicked on a wall/water
				if math.abs(o.pox-px)+math.abs(o.poy-py)>1 then
					selectedpiece=0
					else
					sfx.nuhuh:play()
					end
				print("invalid move (clicked on a wall)")
				else
				if math.abs(o.pox-px)+math.abs(o.poy-py)>1 then
					--tile is not adjacent
					selectedpiece=0
					print("invalid move (clicked on a faraway tile)")
					else
					if o.actpts>o.movecost-1 then
						--move
						sfx.footsteps:stop()
						sfx.footsteps:play()
						o.pox=px
						o.poy=py
						o.actpts=o.actpts-o.movecost
						end
					end
				end
			end
		end
	generatePathMap()
	local t=countTeamPieces()
	if t[1]==0 then
		gameover(2)
		end
	if t[2]==0 then
		gameover(1)
		end
	end