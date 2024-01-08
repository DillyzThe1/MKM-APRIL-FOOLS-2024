function onCreatePost()
	makeLuaSprite('screenshot', nil, 0, 0)

	makeLuaSprite('freezeOverlay',nil,0,0)
	makeGraphic('freezeOverlay',1280,720,'FFFFFF')
	setObjectCamera('freezeOverlay','other')
	addLuaSprite('freezeOverlay',true)
	setProperty('freezeOverlay.alpha',0)
end

function onEvent(n,v1,v2)
	if n == 'Game Freeze' then 
		if string.lower(v1) == 'true' then
			cancelTween('hudbgout')
			--setProperty('camHUD.bgColor.alpha',0.5)
			--setProperty('camHUD.bgColor',0xFFFFFFFF)

			makeGraphicFromScreenshot('screenshot')
			setObjectCamera('screenshot', 'other')
			addLuaSprite('screenshot', true)
			screenCenter('screenshot')

			setProperty('freezeOverlay.alpha',0.25)
			setWindowTitle('\': Mushroom Kingdom Madness (Not Responding)')
		else 
			removeLuaSprite('screenshot', false)

			doTweenAlpha('hudbgout','freezeOverlay',0,1,'cubeInOut')
			--setProperty('camHUD.bgColor.alpha',0)
			--setProperty('camHUD.bgColor',0x00FFFFFF)
			--doTweenColor('hudbgout','camHUD.bgColor',0x00FFFFFF,1,'cubeInOut')
			setWindowTitle('default')

			setProperty('gf.animation.curAnim.curFrame',0)
			setProperty('dad.animation.curAnim.curFrame',0)
			setProperty('pico.animation.curAnim.curFrame',0)
			setProperty('boyfriend.animation.curAnim.curFrame',0)
		end
	end
end