local prefix = 'default'
local volume = 1

function onCreatePost()
	if dadName == 'toad-new' or dadName == 'toad' or dadName == 'gmod toad' or dadName == 'hs toad' or dadName == 'hs toad' 
		or dadName == 'irregular-toad' or dadName == 'toad-mc' or dadName == 'toad-nes'  or dadName == 'toad-old' or dadName == "tokia" then
		prefix = 'toad'
		volume = 2
	elseif dadName == 'impostor' or dadName == 'impostor top 10' then
		prefix = 'eggToaster'
		volume = 2
	elseif dadName == 'normal luigi' then
		prefix = 'luigi'
		volume = 2
	elseif dadName == 'square' then
		--prefix = 'square' LATER
		volume = 2
	elseif dadName == 'uncle-fred' then
		prefix = 'fred'
		volume = 2
	end
	
	if string.lower(songName) == 'no shrooms' or string.lower(songName) == 'hell shrooms' then 
		prefix = 'mc'
		volume = 2
	end
end

function onCountdownTick(counter)
	if counter == 0 then
		playSound('intro3-' ..prefix, volume, 'intro3')
	elseif counter == 1 then
		--if dadName == 'funny-man' then
		--	setProperty('countdownReady.visible', false)
		--end
		
		playSound('intro2-' ..prefix, volume, 'intro2')
	elseif counter == 2 then
		--if dadName == 'funny-man' then
		--	setProperty('countdownSet.visible', false)
		--end
	
		playSound('intro1-' ..prefix, volume, 'intro1')
	end
	
	if counter == 3 then
		--if dadName == 'funny-man' then
		--	setProperty('countdownGo.visible', false)
		--end
	
		playSound('introGo-' ..prefix, volume, 'introGo')
	end
end