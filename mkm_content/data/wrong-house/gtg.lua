local deathTimer = 0
local dead
function onBeatHit()
	if not dead then
		math.randomseed(math.random() * math.random())
		deathTimer = math.random(1, 1000)
	
		if deathTimer == 181 then
			gtg()
		end
	end
end

function onUpdatePost()
	if getProperty('dad.animation.curAnim.name') == "gtg" and getProperty('dad.animation.curAnim.finished') and getProperty('dad.visible') then
		setProperty('dad.visible', false)
	end
end

function onTimerCompleted(t)
	if t == 'fail' then
		doTweenX('icon death part 1', 'iconP2.scale', 0.8, 0.5, 'quartOut')
		doTweenY('icon death part 2', 'iconP2.scale', 0.8, 0.5, 'quartOut')
		doTweenAlpha('icon death part 3', 'iconP2', 0, 0.5, 'quartOut')
		--doTweenX('icon death part what in the world', 'iconP2', getProperty('iconP2.x') - 10, 0.5, 'quartOut') --i think getProperty is broken
	elseif t == 'failsafe' then
		setProperty('dad.visible', false)
	end
end

function gtg()
	--debugPrint('dying')
	playSound('wrong-house/oh gtg')
	setProperty('dad.stunned', true)
	objectPlayAnimation('dad', 'gtg')
	setProperty('dad.offset.x', -25)
	setProperty('dad.offset.y', 0)
	runTimer('fail', 0.6)
	runTimer('failsafe', 3)
	--triggerEvent('Play Animation', 'gtg', 'dad')
	--setProperty('dad.animation.curAnim.name', 'gtg') --why exactly do i have to do this??????
	setProperty('whatInTheWorldLua', true) --lua why can't you set the volume of vocalsLeft without dying
	for i = 0, getProperty('notes.length') - 1, 1 do 
		if not getPropertyFromGroup('notes',i,'mustPress') then
			setPropertyFromGroup('notes',i,'ignoreNote',true)
		end
	end
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if not getPropertyFromGroup('unspawnNotes',i,'mustPress') then
			setPropertyFromGroup('unspawnNotes',i,'ignoreNote',true)
		end
	end
	dead = true
end