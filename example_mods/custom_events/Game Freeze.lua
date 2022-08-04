function onCreatePost()
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
			fairlyOddParentsTonightAt6pmCST = false
			setProperty('freezeOverlay.alpha',0.25)
			setPropertyFromClass('lime.app.Application','current.window.title','Friday Night Funkin\': Psych Engine (Not Responding)')
		else 
			doTweenAlpha('hudbgout','freezeOverlay',0,1,'cubeInOut')
			--setProperty('camHUD.bgColor.alpha',0)
			--setProperty('camHUD.bgColor',0x00FFFFFF)
			--doTweenColor('hudbgout','camHUD.bgColor',0x00FFFFFF,1,'cubeInOut')
			fairlyOddParentsTonightAt6pmCST = true
			setPropertyFromClass('lime.app.Application','current.window.title','Friday Night Funkin\': Psych Engine')
		end
	setProperty('camGame.active',fairlyOddParentsTonightAt6pmCST)
	setProperty('gf.active',fairlyOddParentsTonightAt6pmCST)
	setProperty('dad.active',fairlyOddParentsTonightAt6pmCST)
	setProperty('pico.active',fairlyOddParentsTonightAt6pmCST)
	setProperty('boyfriend.active',fairlyOddParentsTonightAt6pmCST)
	setProperty('camGame.active',fairlyOddParentsTonightAt6pmCST)
	end
end

local fairlyOddParentsTonightAt6pmCST = true

function onUpdatePost(e)
	if not fairlyOddParentsTonightAt6pmCST then 
		setProperty('camGame.animation.curAnim.curFrame',0)
		setProperty('gf.animation.curAnim.curFrame',0)
		setProperty('dad.animation.curAnim.curFrame',0)
		setProperty('pico.animation.curAnim.curFrame',0)
		setProperty('boyfriend.animation.curAnim.curFrame',0)
	end
end