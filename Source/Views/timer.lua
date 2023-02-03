import 'Coracle/math'

class('TimerView').extends(playdate.graphics.sprite)

-- Draws audio data
function TimerView:init(x, y)
	TimerView.super.init(self)
	
	self.seconds = 0
	
	local image = playdate.graphics.image.new(80, 36)
	playdate.graphics.pushContext(image)
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
	playdate.graphics.drawText(self:getLabel(), 0, 0)
	playdate.graphics.popContext()
	self:setImage(image:scaledImage(2))
	self:moveTo(x + 80, y)
	self:add()	
end

function TimerView:getLabel()
	local minutes  = math.floor(math.fmod(self.seconds, 3600) / 60)
	local seconds = math.floor(math.fmod(self.seconds, 60))
	return "" .. string.format("%02d", minutes) .. ":" .. string.format("%02d", seconds)
	
end

function TimerView:setSeconds(seconds)
	if(seconds ~= self.seconds)then
		self.seconds = seconds
		local image = playdate.graphics.image.new(80, 36)
		playdate.graphics.pushContext(image)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
		playdate.graphics.drawText(self:getLabel(), 0, 0)
		playdate.graphics.popContext()
		self:setImage(image:scaledImage(2))
		self:update()
	end
end