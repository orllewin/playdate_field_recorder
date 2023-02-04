class('RecordingIndicator').extends(playdate.graphics.sprite)

function RecordingIndicator:init(x, y, font)
	RecordingIndicator.super.init(self)
	
	self.font = font
	self.active = true -- Will be mutated immediately
	self:setActive(false)
	self:moveTo(x, y)
	self:add()
end

function RecordingIndicator:setActive(active)
	if(active == self.active)then
		return-- Don't redraw if no change in state
	end
	
	self.active = active
	
	local image = playdate.graphics.image.new(80, 50)
	
	if(active) then
		playdate.graphics.pushContext(image)
				playdate.graphics.drawRoundRect(0, 0, 75, 30, 9)
				playdate.graphics.fillCircleAtPoint(15, 15, 8)
				self.font:drawText("REC.", 30, 5)
		playdate.graphics.popContext()
		self:setImage(image)
	else
		playdate.graphics.pushContext(image)
				playdate.graphics.drawRoundRect(0, 0, 75, 30, 9)
				playdate.graphics.fillCircleAtPoint(15, 15, 8)
				self.font:drawText("REC.", 30, 5)
		playdate.graphics.popContext()
		
		local muted = playdate.graphics.image.new(80, 50)
		playdate.graphics.pushContext(muted)
				image:drawFaded(0, 0, 0.5, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.popContext()
		self:setImage(muted)
	end
end