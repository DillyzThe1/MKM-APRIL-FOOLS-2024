function onCreatePost()
	setProperty('gf.visible', false)
	setProperty('gf.active', false)
	
	local bgScale = 0.75
	
	makeLuaSprite('skybox', 'bgs/final sweat/skybox', -1066 * bgScale, -600 * bgScale)
	setScrollFactor('skybox', 0.15, 0.45)
	scaleObject('skybox', bgScale, bgScale, true)
	addLuaSprite('skybox')
	
	makeLuaSprite('train', 'bgs/final sweat/thomas', -900, -500)
	addLuaSprite('train')
end