local creditedPeople = ''
local dillyzStupid = false

local creditsMatch = {
	{'academic failure', 'Composed by Zarzok'},
	{'bup', 'Composed By That1LazerBoi & DillyzThe1, Remixed by Zarzok'},
	{'chaotically stupid', 'Composed By That1LazerBoi & DillyzThe1'},
	{'extra screwed', 'Composed By DillyzThe1'},
	{'hell shrooms', 'Composed by DillyzThe1'},
	{'house', 'Composed By DillyzThe1'},
	{'incorrect residence', 'this song had me in tears (and it\'s by dillyz)'},
	{'karrd kollision', 'Composed by DillyzThe1'},
	{'normalized', 'Composed by DillyzThe1'},
	{'no shrooms', 'Composed By DillyzThe1'},
	{'shroomus toodus', 'Original versions by Adam McHummus & Ethan The Doodler, Remixed by DillyzThe1'},
	{'square', 'Composed by DillyzThe1 & Impostor5875'},
	{'top 10 great amazing super duper wonderful outstanding saster level music that ever has been heard', 'Composed by DillyzThe1'},
	{'tutorial', 'Composed By KawaiSprite, Edited by DillyzThe1'},
	{'welcom toad', 'Original Song By Novatos Team, Cover by DillyzThe1'},
	{'wrong house', 'Composed by Impostor5875'},
	{'yeah', 'Composed by DillyzThe1'},
	{'no way', 'Composed by That1LazerBoi'},
	{'bup blaster', 'Guys? I have a theory.'},
	{'final sweat', 'Composed by That1LazerBoi, Impostor5875, & Zarzok'},
	{'square vs toad', 'Composed by Impostor5875 & DillyzThe1'}
}

function onCreatePost()
	for i = 1, table.maxn(creditsMatch), 1 do
		local creditsTable = creditsMatch[i]
		if creditsTable[1] == string.lower(songName) then 
			creditedPeople = creditsTable[2]
		end
	end

	makeLuaText('creditsTxt',creditedPeople, 0, getPropertyFromClass('flixel.FlxG','width')/2,getProperty('healthBarBG.y') + 56)
	setTextSize('creditsTxt',16)
	setTextBorder('creditsTxt',1.25,'0xFF000000')
	--setTextAlignment('creditsTxt','center')
	addLuaText('creditsTxt')
	
	setProperty('creditsTxt.x',getPropertyFromClass('flixel.FlxG','width')/2 - getTextWidth('creditsTxt')/2)
	
	if getProperty('curStage') == 'minecraft' then 
		setTextFont('creditsTxt','minecraft')
	end
end

function onEvent(ev, v1, v2)
	if ev == 'Change Credits' then 
		setProperty('creditsTxt.text',v1)
		setProperty('creditsTxt.x',getPropertyFromClass('flixel.FlxG','width')/2 - getTextWidth('creditsTxt')/2)
	elseif ev == 'Credits Tween X' then
		dillyzStupid = true
		debugPrint('i fucking hate my life oh my god')
		doTweenX('epicCreditsTween', 'creditsTxt', tonumber(v1), tonumber(v2), 'cubeInOut')
	end 
end

function onUpdatePost()
	if not dillyzStupid == true then
		if string.lower(difficultyName) == "alpha" then 
			setProperty('creditsTxt.x',getPropertyFromClass('flixel.FlxG','width') - getTextWidth('creditsTxt') - 10)
		else
			setProperty('creditsTxt.x',getPropertyFromClass('flixel.FlxG','width')/2 - getTextWidth('creditsTxt')/2)
		end
	end
end