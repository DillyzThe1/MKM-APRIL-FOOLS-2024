local lowTierGodSpeaking = false

function onCreatePost()
	addCharacterToList('bf-dead-alt','bf')
end

function onEvent(n,v1,v2) 
	if n == 'Toggle Friendly Reminder' then 
		if string.lower(v1) == 'true' or string.lower(v1) == 't' or v1 == '1' then 
			lowTierGodSpeaking = true
		elseif string.lower(v1) == 'false' or string.lower(v1) == 'f' or v1 == '0' then 
			lowTierGodSpeaking = false
		else 
			if lowTierGodSpeaking == true then 
				lowTierGodSpeaking = false 
			else 
				lowTierGodSpeaking = true
			end
		end
	end
end

function onGameOver() 
	if lowTierGodSpeaking == true then
		setPropertyFromClass('GameOverSubstate','characterName','bf-dead-alt')
		--setPropertyFromClass('GameOverSubstate','deathSoundName','fnf_loss_sfx')
		setPropertyFromClass('GameOverSubstate','loopSoundName','gameOverLTG')
		setPropertyFromClass('GameOverSubstate','endSoundName','gameOverLTGEnd')
	end
	return FunkinLua.Function_Continue
end