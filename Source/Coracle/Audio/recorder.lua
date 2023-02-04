import 'Coracle/math'
import 'Coracle/string_utils'

class('Recorder').extends()

local TWO_MINS = 60 * 2 -- 2 Minutes

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
	self.recordBuffer = playdate.sound.sample.new(TWO_MINS, format)
end

function Recorder:changeFormat(format)
	self.format = format
	if format == playdate.sound.kFormat16bitStereo then
		self.recordBuffer = playdate.sound.sample.new(TWO_MINS/2, format)
	elseif format == playdate.sound.kFormat16bitMono then
		self.recordBuffer = playdate.sound.sample.new(TWO_MINS, format)
	elseif format == playdate.sound.kFormat8bitMono then
		self.recordBuffer = playdate.sound.sample.new(TWO_MINS * 2, format)
	elseif format == playdate.sound.kFormat8bitStereo then
		self.recordBuffer = playdate.sound.sample.new(TWO_MINS, format)
	end
end

function Recorder:changeFormatFromLabel(label)
	if label == "8bit mono" then
		self:changeFormat(playdate.sound.kFormat8bitMono)
	elseif label == "8bit stereo" then
		self:changeFormat(playdate.sound.kFormat8bitStereo)
	elseif label == "16bit mono" then
		self:changeFormat(playdate.sound.kFormat16bitMono)
	elseif label ==  "16bit stereo" then
		self:changeFormat(playdate.sound.kFormat16bitStereo)	
	end
end

function Recorder:getFormatLabel()
	if self.format == playdate.sound.kFormat16bitMono then
		return "16bit mono" 
	elseif self.format == playdate.sound.kFormat16bitStereo then
		return "16bit stereo" 
	elseif self.format == playdate.sound.kFormat8bitMono then
		return "8bit mono" 
	elseif self.format == playdate.sound.kFormat8bitStereo then
		return "8bit stereo"
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

function Recorder:startRecording(recordingListener)
	assert(self.listening, "You need to start listening before you can record")
	self.recordingListener = recordingListener
	
	local seconds, ms = playdate.getSecondsSinceEpoch()
	self.recordStart = seconds
	self.recording = true
	
	playdate.sound.micinput.recordToSample(self.recordBuffer, function(sample)
		print("Recording complete...")
		self.recording = false
		if self.recordingListener ~= nil then self.recordingListener(false, 0) end
	end)
end

function Recorder:stopRecording()
	playdate.sound.micinput.stopRecording()
	self.recording = false
end

function Recorder:isRecording()
	return self.recording
end

function Recorder:isNotRecording()
	return self.recording ~= true
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
	
	if self.recordingListener ~= nil then
		if self.recording then
			local seconds, ms = playdate.getSecondsSinceEpoch()
			self.recordingListener(true, seconds - self.recordStart)
		else
			self.recordingListener(false, 0)
		end
	end
end

function Recorder:generateFilename()
	local now = playdate.getTime()
	local wavFilename = "" .. now["year"] .. "-" .. leftPad(now["month"]) .. "-" .. leftPad(now["day"]) .. "-" .. leftPad(now["hour"]) .. ":" .. leftPad(now["minute"]) .. ":" .. leftPad(now["second"]) .. ".wav"
	return wavFilename
end

function Recorder:saveWav(filname)
	if self:isRecording()then print("Error: can't save while recording") end
	self.recordBuffer:save(filname)
end

