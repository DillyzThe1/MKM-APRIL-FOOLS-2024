function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Pico Note' then 
			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)
			setPropertyFromGroup('unspawnNotes',i,'noMissAnimation',true)
		end
	end
end

--local lastNoteWasPico = false
--local singingAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singUP','singLEFT','singDOWN','singUP','singRIGHT']

--function goodNoteHit(id,data,nt,sus)
--	if nt == 'Pico Note' then 
--		playAnim('pico',getProperty('singAnimations')[data + 1],true)
--		lastNoteWasPico = true
--	end
--end

--function noteMiss(id,data,nt,sus)
--	if nt == 'Pico Note' then 
--		playAnim('pico',getProperty('singAnimations')[data + 1] .. 'miss',true)
--		lastNoteWasPico = true
--	end
--end