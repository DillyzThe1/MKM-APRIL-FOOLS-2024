local prefix = 'default'
local volume = 0.6

function onCreatePost()
	if string.lower(songName) == 'square' then 
		setProperty("introSoundsVolume", 0)
		return
	end
	
	local nameToCheck = dadName
	if isLeftMode then
		nameToCheck = boyfriendName
	end
	
	if nameToCheck == 'toad-new' or nameToCheck == 'toad' or nameToCheck == 'gmod toad' or nameToCheck == 'hs toad' or nameToCheck == 'hs toad' 
		or nameToCheck == 'irregular-toad' or nameToCheck == 'toad-mc' or nameToCheck == 'toad-nes'  or nameToCheck == 'toad-old' or nameToCheck == "tokia" then
		prefix = 'toad'
		volume = 2
	elseif nameToCheck == 'impostor'or nameToCheck == 'impostor-player' or nameToCheck == 'impostor top 10' then
		prefix = 'eggToaster'
		volume = 2
	elseif nameToCheck == 'normal luigi' then
		prefix = 'luigi'
		volume = 2
	elseif nameToCheck == 'square' or nameToCheck == 'square-angry' then
		prefix = 'square'
		volume = 2
	elseif nameToCheck == 'uncle-fred' then
		prefix = 'fred'
		volume = 2
	end
	
	if string.lower(songName) == 'brrrrr' or string.lower(songName) == 'hell shrooms' then 
		prefix = 'mc'
		volume = 2
	end
	
	setProperty("introSoundsSuffix", "-" .. prefix)
	setProperty("introSoundsVolume", volume)
end