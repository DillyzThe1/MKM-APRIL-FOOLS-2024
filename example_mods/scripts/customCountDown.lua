local prefix = 'default'
local volume = 0.6

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
	--elseif dadName == 'square' then
		--prefix = 'square' LATER
		--volume = 2
	elseif dadName == 'uncle-fred' then
		prefix = 'fred'
		volume = 2
	end
	
	if string.lower(songName) == 'no shrooms' or string.lower(songName) == 'hell shrooms' then 
		prefix = 'mc'
		volume = 2
	end
	
	setProperty("introSoundsSuffix", "-" .. prefix)
	setProperty("introSoundsVolume", volume)
end