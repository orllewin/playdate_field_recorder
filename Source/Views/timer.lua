import 'Coracle/math'

class('TimerView').extends(playdate.graphics.sprite)

-- Draws audio data
function TimerView:init(x, y)
	TimerView.super.init(self)
	
	self.seconds = 0
	
	self:initialiseImage()
	self:moveTo(x + 80, y)
	self:add()	
end

function TimerView:initialiseImage()
	local image = playdate.graphics.image.new(80, 36)
	playdate.graphics.pushContext(image)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
		playdate.graphics.drawText(self:getLabel(), 0, 0)
	playdate.graphics.popContext()
	
	local scaled = playdate.graphics.image.new(160, 72)
	playdate.graphics.pushContext(scaled)
		local s = image:scaledImage(2)
		s:drawFaded(0, 0, 0.25, playdate.graphics.image.kDitherTypeDiagonalLine)
	playdate.graphics.popContext()
	
	self:setImage(scaled)
end

function TimerView:getLabel()
	local minutes  = math.floor(math.fmod(self.seconds, 3600) / 60)
	local seconds = math.floor(math.fmod(self.seconds, 60))
	return "" .. string.format("%02d", minutes) .. ":" .. string.format("%02d", seconds)
end

function TimerView:setSeconds(seconds)
	if(seconds ~= self.seconds)then
		self.seconds = seconds
		if(seconds == 0)then
			self:initialiseImage()
		else
			local image = playdate.graphics.image.new(80, 36)
			playdate.graphics.pushContext(image)
			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
			playdate.graphics.drawText(self:getLabel(), 0, 0)
			playdate.graphics.popContext()
			self:setImage(image:scaledImage(2))
		end
	end
end