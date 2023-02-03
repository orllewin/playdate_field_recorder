import 'Coracle/math'

class('Recorder').extends()

local MAX_RECORD_TIME = 60 * 10 -- 10 Minutes

function Recorder:init(format)
	Recorder.super.init(self)
	
	self.format = format
	self.levelsListener = nil
	self.listening = false
	self.recording = false
	self.isListening = false
	self.audLevel = 0.5
	self.audAverage = 0.0
	self.audFrame = 0
	self.audScale = 0
	self.audMax = 0
	self.recordStart = -1
	self.recordBuffer = playdate.sound.sample.new(MAX_RECORD_TIME, format)
end

function Recorder:changeFormat(format)
	self.format = format
	self.recordBuffer = playdate.sound.sample.new(MAX_RECORD_TIME, format)
end

function Recorder:getFormatLabel()
	if self.format == playdate.sound.kFormat16bitMono then
		return "16bit Mono" 
	elseif self.format == playdate.sound.kFormat16bitStereo then
		return "16bit Stereo" 
	elseif self.format == playdate.sound.kFormat8bitMono then
		return "8bit Mono" 
	elseif self.format == playdate.sound.kFormat8bitStereo then
		return "8bit Stereo"
	else
		return "" .. self.format
	end
end

function Recorder:startListening(levelsListener)
	self.levelsListener = levelsListener
	playdate.sound.micinput.startListening()
	self.listening = true
end

function Recorder:stopListening()
	playdate.sound.micinput.stopListening()
	self.listening = false
end

function Recorder:startRecording(elapsedListener)
	assert(self.listening, "You need to start listening before you can record")
	self.elapsedListener = elapsedListener
	
	local seconds, ms = playdate.getSecondsSinceEpoch()
	self.recordStart = seconds
	self.recording = true
	
	playdate.sound.micinput.recordToSample(self.recordBuffer, function(sample)
		print("Recording complete...")
		self.recording = false
	end)
end

function Recorder:stopRecording()
	playdate.sound.micinput.stopRecording()
	self.recording = false
end

function Recorder:isRecording()
	return self.recording
end

function Recorder:update()
	self.audLevel = playdate.sound.micinput.getLevel()
	if(self.audLevel > self.audMax) then self.audMax = self.audLevel end
	self.audFrame += 1
	self.audMax = math.max(self.audMax-(self.audMax/250), 0.0)
	
	self.audAverage = self.audAverage * (self.audFrame -1)/self.audFrame + self.audLevel / self.audFrame
	
	--self.audAverage = self.audAverage + (self.audLevel - self.audAverage)/self.audFrame
	--self.audAverage = self.audAverage + (self.audLevel - self.audAverage) / math.min(self.audFrame, 100)
	
	if self.levelsListener ~= nil then 
		self.levelsListener(self.audLevel, self.audMax, self.audAverage)
	end
	
	if self.elapsedListener ~= nil then
		if self.recording then
			local seconds, ms = playdate.getSecondsSinceEpoch()
			self.elapsedListener(seconds - self.recordStart)
		else
			self.elapsedListener(0)
		end
	end
end

function Recorder:generateFilename()
	local now = playdate.getTime()
	local wavFilename = "" .. now["year"] .. "-" .. now["month"] .. "-" .. now["day"] .. "-" .. now["hour"] .. now["minute"] .. now["second"] .. ".wav"
	return wavFilename
end

function Recorder:saveWav(filname)
	if self:isRecording()then print("Error: can't save while recording") end
	self.recordBuffer:save(filname)
end
