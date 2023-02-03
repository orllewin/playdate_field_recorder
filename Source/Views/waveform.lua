import 'Coracle/math'

class('Waveform').extends(playdate.graphics.sprite)

local barWidth = 1

-- Draws audio data
function Waveform:init(x, y, width, height)
	Waveform.super.init(self)
	
	self.width = width
	self.height = height
	self.frame = 0
	self.prevHeight = 0
	
	self.waveformImage = playdate.graphics.image.new(width, height)
	self:setImage(self.waveformImage)
	self:moveTo(x + width/2, y)
	self:add()
	
	local focusedImage = playdate.graphics.image.new(width, height)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(1, 1, width-2, height -2, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(x + width/2, y)
	self.focusedSprite:add()
end

function Waveform:updateLevels(audLevel, audMax, audAverage)
	playdate.graphics.pushContext(self.waveformImage)
	
	self.waveformImage:draw(-3, 0)
	
	playdate.graphics.setDitherPattern(0.9, playdate.graphics.image.kDitherTypeBayer8x8)
	if(audLevel < 0.001)then
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(self.width- barWidth, 0, barWidth, self.height)
		local by = (self.height - self.prevHeight)/2
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(self.width-barWidth, by, barWidth, self.prevHeight)
		self.prevHeight = math.max(1, self.prevHeight-(self.height/20))
	else
		local barHeight = map(audLevel, 0, audMax, 0, self.height)
		self.prevHeight = barHeight
		local by = (self.height - barHeight)/2
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(self.width-barWidth, by, barWidth, barHeight)
	end
	playdate.graphics.popContext()
end