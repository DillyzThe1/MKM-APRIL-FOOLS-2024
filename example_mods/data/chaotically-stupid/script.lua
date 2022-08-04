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