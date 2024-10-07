objs = {}

classes = {
	{dmg=2,range=5,atkcost=5,movecost=3},--pistol
	{dmg=6,range=6,atkcost=6,movecost=5},--rifle
	{dmg=20,range=9,atkcost=20,movecost=5},--sniper
	{dmg=6,range=6,atkcost=4,movecost=6},--machinegun
	{dmg=3,range=6,atkcost=2,movecost=3},--smg
	{dmg=14,range=5,atkcost=5,movecost=3},--shotgun
}

function makeObj(class,team,ox,oy)
	local o = {hp=20,actpts=20,pox=ox,poy=oy}
	if class==6 then o.hp=40 end
	o.class=class
	o.team=team
	o.dmg=classes[class].dmg
	o.range=classes[class].range
	o.atkcost=classes[class].atkcost
	o.movecost=classes[class].movecost
	
	o.exp=0
	o.lvl=1
	
	o.id=#objs+1
	table.insert(objs,o)
	end

function objAt(ox,oy)
	for i=1,#objs do
		if objs[i].pox==ox and objs[i].poy==oy then
			return i
			end
		end
	return 0
	end

function killObj(obj,killer)
	killer.exp=killer.exp+(obj.class*2+3)
	if killer.exp>killer.lvl*6+5 and killer.lvl<5 then
		music.victory:play()
		
		killer.exp=killer.exp-(killer.lvl*6+6)
		killer.lvl=killer.lvl+1
		if killer.lvl%2==0 and killer.class<3 then killer.dmg=killer.dmg+1 end
		if killer.class>2 then killer.hp=math.min(killer.hp+10,(killer.class==6) and 40 or 20) end
		end
	
	sfx.death:play()
	print("killed obj#"..obj.id)
	spilledblood[currentteam]=spilledblood[currentteam]+1250
	score[currentteam]=score[currentteam]+obj.class*3
	score[obj.team]=score[obj.team]-4+obj.class*2
	table.remove(objs,obj.id)
	selectedpiece=0
	for i=1,#objs do
		if objs[i].id>obj.id then
			objs[i].id=objs[i].id-1
			end
		end
	local t=countTeamPieces()
	if t[obj.team]==0 then
		gameover(currentteam)
		end
	end

function checkObjLOS(from,to)
	local dx,dy
	dx=to.pox-from.pox
	dy=to.poy-from.poy
	local ox,oy
	ox=from.pox+0.5
	oy=from.poy+0.5
	--we will do 10 checks along this line because that is the maximum attack range
	dx=dx/10
	dy=dy/10
	print("LOS check:")
	for i=1,10 do
		local tile = level[(math.floor(ox+dx*i)+1)+math.floor(oy+dy*i)*16]
		--print("tile at "..math.floor(ox+dx*i)..","..math.floor(oy+dy*i).." is "..tile)
		--if the tile at this location is a wall then it blocks LOS and we should return false
		if tile==3 then print("blocked!");return false end
		end
	print("unblocked!")
	return true
	end

function countTeamPieces()
	local t = {0,0}
	for i=1,#objs do
		t[objs[i].team]=t[objs[i].team]+1
		end
	return t
	end