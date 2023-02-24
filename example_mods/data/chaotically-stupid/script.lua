function onGenerateStaticArrows(player, maxPlayer)
	if player == maxPlayer then
		triggerEvent('Key Count Swap',4)
	end
end

function onChartAccessed() 
	loadSong('Extra Screwed')
	return Function_Stop
end

function onUpdatePost(e)
	local ratingpercent = rating * 100
	if ratingpercent >= 100 then 
		setRatingName('got daem osu plaeyr without the play')
	elseif ratingpercent >= 90 then 
		setRatingName('WTF STOP HACKING YOU BLUE HAIR WEEB')
	elseif ratingpercent >= 75 then 
		setRatingName(':peter_trol: :gun-1: :sad_sping_bing:')
	elseif ratingpercent >= 60 then 
		setRatingName('Negative Social Credit')
	elseif ratingpercent >= 45 then 
		setRatingName('Spongebob\'s "3yr Old Daughter" Message')
	elseif ratingpercent >= 30 then 
		setRatingName('League Of Legends Player')
	elseif ratingpercent >= 15 then 
		setRatingName('Absolute Lack Of Women')
	else
		setRatingName('@39.4578258, -88.4980073')
	end
	setProperty('botplayTxt.text', 'GOOFY CRY BABY')
end

function onSongStart()
	-- set it to the original time, as shown at https://www.youtube.com/watch?v=lUypgXETSd8
	setDisplayLength(2, 26)
end

local goneBack = false
function onBeatHit()
	-- now show the fans that the real remix was the friends we made along the way
	if curBeat >= 338 and not goneBack then
		goneBack = true
		tweenDisplayLength(-1, -1, 0.75, 'cubeInOut')
	end
end