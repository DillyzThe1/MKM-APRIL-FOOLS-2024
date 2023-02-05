function onCreatePost()
	setProperty('gf.visible',false)
	setProperty('gf.active',false)
	
	setTextFont('timeTxt','minecraft.ttf')
	setTextSize('timeTxt',24)
	
	setTextFont('scoreTxt','minecraft.ttf')
	setTextSize('scoreTxt',16)
end

function onUpdatePost(e)
	local ratingpercent = rating * 100
	if ratingpercent >= 100 then 
		setRatingName('Netherite')
	elseif ratingpercent >= 90 then 
		setRatingName('Diamond')
	elseif ratingpercent >= 75 then 
		setRatingName('Gold')
	elseif ratingpercent >= 60 then 
		setRatingName('Iron')
	elseif ratingpercent >= 45 then 
		setRatingName('Stone')
	elseif ratingpercent >= 30 then 
		setRatingName('Wood')
	elseif ratingpercent >= 15 then 
		setRatingName('Leather')
	else
		setRatingName('Wurst Client')
	end
end