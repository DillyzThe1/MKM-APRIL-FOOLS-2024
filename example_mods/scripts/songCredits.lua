local creditedPeople = ''

local creditsMatch = {
	{'tutorial', 'Composed By KawaiSprite, Edited by DillyzThe1'},
	{'house', 'Composed By DillyzThe1'},
	{'house skill issue', 'Composed By DillyzThe1'},
	{'no shrooms', 'Composed By DillyzThe1'},
	{'no shrooms skill issue', 'Composed By DillyzThe1'},
	{'chaotically stupid', 'Composed By That1LazerBoi & DillyzThe1'},
	{'chaotically stupid skill issue', 'Composed By That1LazerBoi & DillyzThe1'},
	{'bup', 'Composed By That1LazerBoi & DillyzThe1'},
	{'bup skill issue', 'Composed By That1LazerBoi & DillyzThe1'},
	{'extra screwed', 'Composed By DillyzThe1'},
	{'extra screwed skill issue', 'Composed By DillyzThe1'},
	{'welcom toad', 'Original Song By Novatos Team'},
	{'welcom toad skill issue', 'Original Song By Novatos Team, Cover by DillyzThe1'},
	{'academic failure', 'Composed by Zarzok'},
	{'square', 'Composed by DillyzThe1'},
	{'shroomus toodus', 'Original versions by Adam McHummus & Ethan The Doodler, Remixed by DillyzThe1'},
	{'karrd kollision', 'Composed by DillyzThe1'},
	{'hell shrooms', 'Composed by DillyzThe1'},
	{'wrong house', 'Composed by Impostor5875'},
	{'normalized', 'Composed by DillyzThe1'}
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