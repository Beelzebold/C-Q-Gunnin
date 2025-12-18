--I assume that you're here to learn how to cheese your save file. Go nuts, just don't touch the stats or you might end up bricking your save file.

stats = {kills = 0,blood = 0,damage = 0,screenendless = 1}

function updateSave()
	local savestr = string.char(maxmap)..string.char(apluses[1]*1+apluses[2]*2+apluses[3]*4+apluses[4]*8+apluses[5]*16+apluses[6]*32+apluses[7]*64+apluses[8]*128)
	local kills = intToBytes(stats.kills)
	local blood = intToBytes(stats.blood)
	local damage = intToBytes(stats.damage)
	local endless = intToBytes(math.min(stats.screenendless,255))
	savestr = savestr..string.char(#kills+6)
	savestr = savestr..string.char(#kills+#blood+6)
	savestr = savestr..string.char(#kills+#blood+#damage+6)
	for _,v in ipairs(kills) do
		savestr = savestr..v
		end
	for _,v in ipairs(blood) do
		savestr = savestr..v
		end
	for _,v in ipairs(damage) do
		savestr = savestr..v
		end
	for _,v in ipairs(endless) do
		savestr = savestr..v
		end
	savestr = savestr .. string.char(ngmaxmap)
	local savef = love.filesystem.newFile("cqgsave.cqs")
	love.filesystem.write("cqgsave.cqs",savestr)
	end
function loadSave()
	local savestr = love.filesystem.read("cqgsave.cqs")
	maxmap = string.byte(savestr,1)
	for i=1,8 do
		apluses[i]=math.min(bit.band(string.byte(savestr,2),2^(i-1)),1)
		end
	
	stats.kills = 0
	for i=6,string.byte(savestr,3)-1 do
		local place = i-6 --0=1s, 1=256s, 3=65ks, etc
		stats.kills = stats.kills + (string.byte(savestr,i)*(2^(place*8)))
		end
	stats.blood = 0
	for i=string.byte(savestr,3),string.byte(savestr,4)-1 do
		local place = i-string.byte(savestr,3) --0=1s, 1=256s, 3=65ks, etc
		stats.blood = stats.blood + (string.byte(savestr,i)*(2^(place*8)))
		end
	stats.damage = 0
	for i=string.byte(savestr,4),string.byte(savestr,5)-1 do
		local place = i-string.byte(savestr,4) --0=1s, 1=256s, 3=65ks, etc
		stats.damage = stats.damage + (string.byte(savestr,i)*(2^(place*8)))
		end
	stats.screenendless = string.byte(savestr,string.byte(savestr,5))
	
	if string.len(savestr) <= string.byte(savestr,5) then
		ngmaxmap = 1
		else
		ngmaxmap = string.byte(savestr,string.byte(savestr,5)+1)
		end
	
	print("loaded save")
	print("STATS")
	print("levels unlocked:  "..maxmap)
	print("enemies killed:   "..stats.kills)
	print("blood spilled:    "..stats.blood.." liters")
	print("damage dealt:     "..stats.damage)
	print("endless streak:   "..stats.screenendless)
	print("ng+ progress:     "..ngmaxmap)
	print("A+ grades:")
	for i=1,8 do
		if apluses[i]>0 then print("MAP "..i) end
		end
	end

function intToBytes(num)
	if num==0 then return {string.char(0)} end
	
	num = math.floor(num+0.5)
	local bytes = {}
	
	while num > 0 do
		local byte = num % 256
		table.insert(bytes,string.char(byte))
		num = math.floor(num / 256)
		end
	
	return bytes
	end