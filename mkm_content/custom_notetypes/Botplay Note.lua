function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Botplay Note' then 
			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)
			setPropertyFromGroup('unspawnNotes',i,'noMissAnimation',true)
			setPropertyFromGroup('unspawnNotes',i,'visible',false)
			setPropertyFromGroup('unspawnNotes',i,'alpha',0)
			setPropertyFromGroup('unspawnNotes',i,'ignoreNote',getPropertyFromGroup('unspawnNotes',i,'mustPress'))
			setPropertyFromGroup('unspawnNotes',i,'wasGoodHit',getPropertyFromGroup('unspawnNotes',i,'mustPress'))
			setPropertyFromGroup('unspawnNotes',i,'noStrumAnim',true)
		end
	end
end

function opponentNoteHit(id,data,nt,sus)
	if nt == 'Botplay Note' then 
		playAnim('boyfriend',getProperty('singAnimations')[data + 1],true)
		setProperty('boyfriend.holdTimer',0)
		--callMethod('StrumPlayAnim',{true, data % getPropertyFromClass('PlayState','ogCount'), 0})
	end
end

function goodNoteHit(id,data,nt,sus)
	if nt == 'Botplay Note' then 
		playAnim('boyfriend',getProperty('singAnimations')[data + 1],true)
		setProperty('boyfriend.holdTimer',0)
		--callMethod('StrumPlayAnim',{true, data % getPropertyFromClass('PlayState','ogCount'), 0})
	end
end

function noteMiss(id,data,nt,sus)
	if nt == 'Botplay Note' then 
		playAnim('boyfriend',getProperty('singAnimations')[data + 1] .. 'miss',true)
		setProperty('boyfriend.holdTimer',0)
		--callMethod('StrumPlayAnim',{true, data % getPropertyFromClass('PlayState','ogCount'), 0})
	end
end