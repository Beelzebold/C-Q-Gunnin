--this handles the AI statemachine logic. first select which piece to move, then select which piece we want to target, then
--move there and shoot them.
-- //TODO: add logic to make enemies refrain from moving in scenarios where such a thing is a bit more tactically wise.
--ie; snipers should try to keep away from any enemy's range at all costs; support gunners should not attempt to pursue targets
--that are out of LOS and instead should try and wait for the enemy (unless they try taking potshots at the support gunner)
--I think raiders should just have zero self preservation though

local Vector = require( "luafinding/vector" )
local Luafinding = require("luafinding/luafinding")

aistate = 0
AI_SELECTING = 0
AI_TARGETFIND = 1
AI_MOVING = 2
AI_ATTACK = 3

aitarget = nil

aiticked = false

function AITurn()
	local aistates={"AI_SELECTING","AI_TARGETFIND","AI_MOVING","AI_ATTACK"}
	print("AI ticked state "..aistates[aistate+1])
	
	if aistate==AI_SELECTING then
		--choose the piece with the lowest movecost and highest AP
		local bestpiece = nil
		local bestscore = math.huge
		for i=1,#objs do
			local objscore = objs[i].movecost-objs[i].actpts
			if objs[i].actpts>objs[i].movecost-1 and objscore<bestscore and objs[i].team==currentteam and objs[i].notargets==nil then
				bestscore=objscore
				bestpiece=i
				end
			end
		if bestpiece==nil then
			menu=true
			if menuframes>45 then
				nextturn()
				menu=false
				end
			return AI_SELECTING
			end
		local classnames = {"scout","rifleman","marksman","support","raider","warlord"}
		print("selected piece "..bestpiece.." ("..classnames[objs[bestpiece].class]..")")
		zpress(objs[bestpiece].pox,objs[bestpiece].poy)
		if objs[bestpiece].oldpos==nil then
			objs[bestpiece].oldpos = Vector(objs[selectedpiece].pox+1,objs[selectedpiece].poy+1)
			end
		return AI_TARGETFIND
		end
	if aistate==AI_TARGETFIND then
		--nearest piece with lowest hp, highest class, and highest lvl
		local bestpiece = nil
		local bestscore = math.huge
		for i=1,#objs do
			local objdist = math.abs(objs[i].pox-objs[selectedpiece].pox)+math.abs(objs[i].poy-objs[selectedpiece].poy)
			ignoredpiece1 = selectedpiece
			ignoredpiece2 = i
			generatePathMap()
			local path = Luafinding( Vector(objs[selectedpiece].pox+1,objs[selectedpiece].poy+1), Vector(objs[i].pox+1,objs[i].poy+1), pathmap):GetPath()
			if path~=nil then objdist = #path-1 end
			
			local objscore = ((objs[i].hp+objdist*8)-(objs[i].class*4)-(objs[i].lvl*6)) + love.math.random(1,3)
			
			print("check obj "..i.."!")
			if path~=nil then print("path!=nil") end
			if objdist<objs[selectedpiece].range then print("objdist within range") end
			local los = checkObjLOS(objs[selectedpiece],objs[i])
			
			if objscore<bestscore and objs[i].team~=currentteam and (path~=nil or (objdist<objs[selectedpiece].range and los==true)) then
				--on hard, don't target anyone outside of LOS with support gunners
				if objs[selectedpiece].class~=4 or config.ai_skill<3 or checkObjLOS(objs[selectedpiece],objs[i])==true then
					bestscore=objscore
					bestpiece=i
					end
				end
			end
		aitarget=bestpiece
		if bestpiece==nil then
			local t=countTeamPieces()
			if t[1]==0 then
				gameover(2)
				end
			if t[2]==0 then
				gameover(1)
				end
			objs[selectedpiece].notargets = true
			print("!no available targets!")
			aitarget=nil
			selectedpiece=0
			return AI_SELECTING
			end
		print("!target: "..aitarget.."!")
		return AI_MOVING
		end
	if aistate==AI_MOVING then
		local m_atk = 0
		local m_run = 1
		local modes={"m_atk","m_run"}
		local mode = m_atk
		if selectedpiece==0 then print("!no selected piece!");return AI_SELECTING end
		if aitarget==nil then print("!no target!");return AI_TARGETFIND end
		
		local objdist = math.abs(objs[aitarget].pox-objs[selectedpiece].pox)+math.abs(objs[aitarget].poy-objs[selectedpiece].poy)
		local los = checkObjLOS(objs[selectedpiece],objs[aitarget])
		--if we can't attack and are in or near range of the target, try to back up
		if objs[selectedpiece].actpts < objs[selectedpiece].atkcost and
			objdist <= objs[aitarget].range and los then
			if config.ai_skill>1 and love.math.random()<0.8 then--on easy, enemy pieces will sometimes stupidly be left hanging in attack range
				mode=m_run
				else
				--on easy rather than pushing or retreating when out of attacks it'll just leave the piece there
				objs[selectedpiece].notargets = true
				aitarget=nil
				selectedpiece=0
				return AI_SELECTING
				end
			end
		print("AI movemode: "..modes[mode+1])
		
		if mode==m_atk then
			print("distance to target: "..objdist.." (atk range "..objs[selectedpiece].range..")")
			local los = checkObjLOS(objs[selectedpiece],objs[aitarget])
			--if we're close enough and in LOS, ATTAAAACK
			if objdist<objs[selectedpiece].range and (los) and objs[selectedpiece].actpts>=objs[selectedpiece].atkcost then print("!in attacking range!");return AI_ATTACK end
			end
		
		--got tired :(
		if objs[selectedpiece].actpts < objs[selectedpiece].movecost then
			return AI_SELECTING
			end
		
		--if we're near the edge of the target's range but don't have the AP to get in atkrange and fire, simply wait a turn on hard
		--or flee on medium
		if objdist<objs[aitarget].range+math.floor(20/objs[aitarget].movecost)-love.math.random(1,2) and
			objs[selectedpiece].actpts<((objdist-objs[selectedpiece].range)*objs[selectedpiece].movecost)+objs[selectedpiece].atkcost then
			if config.ai_skill==3 then
				--put down the piece there
				objs[selectedpiece].notargets = true
				aitarget=nil
				selectedpiece=0
				return AI_SELECTING
				
				else if config.ai_skill==2 then
					--on med flee
					mode=m_run
					end
				end
			end
		
		if mode==m_atk then
			--m_atk
			ignoredpiece1 = selectedpiece
			ignoredpiece2 = aitarget
			generatePathMap()
			local path = Luafinding( Vector(objs[selectedpiece].pox+1,objs[selectedpiece].poy+1), Vector(objs[aitarget].pox+1,objs[aitarget].poy+1), pathmap):GetPath()
			
			if path==nil then
				print("!no path to target "..aitarget.."!")
				aitarget=nil
				selectedpiece=0
				return AI_SELECTING
				end
			print("path length: "..#path)
			print("nextpos: "..path[2].x-1 ..", "..path[2].y-1)
			zpress(path[2].x-1,path[2].y-1)
			else
			--m_run
			ignoredpiece1 = selectedpiece
			generatePathMap()
			local path = Luafinding( Vector(objs[selectedpiece].pox+1,objs[selectedpiece].poy+1), objs[selectedpiece].oldpos, pathmap):GetPath()
			
			if path==nil then
				print("!no path to oldpos! (how the fuck did you do this!)")
				objs[selectedpiece].notargets = true
				aitarget=nil
				selectedpiece=0
				return AI_SELECTING
				end
			if #path==1 then
				--if we're already at oldpos then we probably can't move this piece anymore. set their notarget flag so we don't get stuck in a loop
				print("!already there!")
				objs[selectedpiece].notargets = true
				aitarget=nil
				selectedpiece=0
				return AI_SELECTING
				end
			print("path length: "..#path)
			print("nextpos: "..path[2].x-1 ..", "..path[2].y-1)
			zpress(path[2].x-1,path[2].y-1)
			end
		return AI_MOVING
		end
	if aistate==AI_ATTACK then
		--if our target is dead or we're just out of time for shooting, just go back to the SELECTING state. if we still have some AP we can
		--use this piece again
		if objs[aitarget]==nil or objs[selectedpiece]==nil or objs[selectedpiece].actpts < objs[selectedpiece].atkcost then
			print("!attacking end!")
			aitarget=nil
			selectedpiece=0
			return AI_SELECTING
			end
		local killed = false
		if objs[aitarget].hp <= objs[selectedpiece].dmg then killed = true end
		zpress(objs[aitarget].pox,objs[aitarget].poy)
		print("attack successful")
		if killed==true then
			print("!attacking end!")
			aitarget=nil
			selectedpiece=0
			return AI_SELECTING
			end
		return AI_ATTACK
		end
	end