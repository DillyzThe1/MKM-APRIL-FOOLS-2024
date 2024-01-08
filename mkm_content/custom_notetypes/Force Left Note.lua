function opponentNoteHit(id,data,nt,sus)
	if nt == 'Force Left Note' then 
		playAnim('dad', getProperty('singAnimations')[data + 1], true)
		setProperty('dad.holdTimer', 0)
		--callMethod('StrumPlayAnim',{true, data % getPropertyFromClass('PlayState','ogCount'), 0})
	end
end

function goodNoteHit(id,data,nt,sus)
	if nt == 'Force Left Note' then 
		playAnim('dad', getProperty('singAnimations')[data + 1], true)
		setProperty('dad.holdTimer', 0)
		--callMethod('StrumPlayAnim',{true, data % getPropertyFromClass('PlayState','ogCount'), 0})
	end
end

function noteMiss(id,data,nt,sus)
	if nt == 'Force Left Note' then 
		playAnim('dad', getProperty('singAnimations')[data + 1] .. 'miss', true)
		setProperty('dad.holdTimer', 0)
		--callMethod('StrumPlayAnim',{true, data % getPropertyFromClass('PlayState','ogCount'), 0})
	end
end