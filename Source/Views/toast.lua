class('Toast').extends(playdate.graphics.sprite)

function Toast:init(x, y, font)
	Toast.super.init(self)
	
	self.font = font
	self.origX = x
	self.origY = y
	self.timer = playdate.timer.new(2500, function()
		self:setVisible(false)
		self.timer:reset()
		self.timer:pause()
	end)
	self.timer.discardOnCompletion = false
	self.timer:pause()
	self:add()
end

function Toast:setText(text)
	if(self.text == text)then return end
	self.text = text
	self:redraw()
end

function Toast:redraw()
	local fontFamily = {
		 [playdate.graphics.font.kVariantNormal] = self.font,
		[playdate.graphics.font.kVariantBold] = self.font,
		[playdate.graphics.font.kVariantItalic] = self.font
	}
	local width, height = playdate.graphics.getTextSize(self.text, fontFamily)
	local image = playdate.graphics.image.new(width, height)
	playdate.graphics.pushContext(image)
		self.font:drawText(self.text, 0, 0)
	playdate.graphics.popContext()
	self:moveTo(self.origX + width/2, self.origY)
	self:setImage(image)
	self:setVisible(true)
	self.timer:start()
end