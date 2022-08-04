function onCreatePost()
	makeLuaText('closedCaptionText','',getPropertyFromClass('flixel.FlxG','width'),0,525)
	setTextAlignment('closedCaptionText','center')
	setTextSize('closedCaptionText',32)
	setTextBorder('closedCaptionText',0,'000000')
	addLuaText('closedCaptionText')
	setObjectCamera('closedCaptionText','other')
	makeLuaSprite('closedCaptionBG','',0,525)
	makeGraphic('closedCaptionBG',720,40,'000000')
	addLuaSprite('closedCaptionBG',false)
	setObjectCamera('closedCaptionBG','other')
	setProperty('closedCaptionBG.alpha',0.55)
	updateCaptionTextBG()
	setProperty('closedCaptionBG.visible',false)
end

function onEvent(n,v1,v2) 
	if n == 'Closed Captions' then 
		setProperty('closedCaptionText.text',v1)
		updateCaptionTextBG()
		
		setProperty('closedCaptionText.y',480)
		doTweenY('closedCaptionTextTweenY','closedCaptionText',525,0.5,'cubeOut')
		
		if v1 == '' or v1 == nil then
			setProperty('closedCaptionBG.visible',false)
		else 
			setProperty('closedCaptionBG.visible',true)
		end
	end
end

function updateCaptionTextBG()
	setGraphicSize('closedCaptionBG',getProperty('closedCaptionText.text.length')*20 + 16,40,true)
	setProperty('closedCaptionBG.x',getPropertyFromClass('flixel.FlxG','width')/2 - getProperty('closedCaptionBG.width')/2)
		
	local ogThing = getProperty('closedCaptionBG.scale.y')
	setProperty('closedCaptionBG.scale.y',ogThing * 1.15)
	doTweenY('closedCaptionBGTweenScaleY','closedCaptionBG.scale',ogThing,0.75,'cubeOut')
end