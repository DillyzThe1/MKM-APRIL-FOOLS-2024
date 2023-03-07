--function onCreate()
--	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
--		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'BF & GF Duo Note' then 
--			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)
--			setPropertyFromGroup('unspawnNotes',i,'noMissAnimation',true)
--		end
--	end
--end

function goodNoteHit(id,data,nt,sus)
	if nt == 'BF & GF Duo Note' then 
		playAnim('gf',getProperty('singAnimations')[data + 1] .. 'miss',true)
		setProperty('gf.holdTimer',0)
	end
end

function noteMiss(id,data,nt,sus)
	if nt == 'BF & GF Duo Note' then 
		playAnim('gf',getProperty('singAnimations')[data + 1] .. 'miss',true)
		setProperty('gf.holdTimer',0)
	end
end