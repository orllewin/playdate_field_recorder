import 'Coracle/coracle'
import 'Coracle/Audio/recorder'
import 'CoreLibs/sprites'
import 'Views/waveform'
import 'Views/timer'
import 'Views/battery_indicator'
import 'Views/recording_indicator'
import 'Views/label'
import 'Views/toast'
import 'CoreLibs/timer'

playdate.display.setRefreshRate(20)

--3.5mm jack state: are headphones in, and do they have a mic
local headphones, externalMic = playdate.sound.getHeadphoneState(function()
	local h, m = playdate.sound.getHeadphoneState()
	headphones = h
	externalMic = m
	micLabel:setText(getMicrophoneLabel())
end)

function getMicrophoneLabel()
	if(externalMic)then
		return "external mic."
	else
		return "internal mic."
	end
end

local recordingIndicator = playdate.graphics.image.new("Images/recording_indicator")
local batteryIcon = playdate.graphics.image.new("Images/battery")
invertDisplay()

local bigFont = playdate.graphics.font.new("Fonts/Roobert-24-Medium")
playdate.graphics.setFont(bigFont)

local smallerFont = playdate.graphics.font.new("Fonts/Roobert-11-Medium")

local timer = TimerView(10, 43)
local waveform = Waveform(10, 180, 380, 105)
local batteryIndicator = BatteryIndicator(348, 25, smallerFont)
local recordingIndicator = RecordingIndicator(355, 115, smallerFont)
local formatLabel = Label(10, 85, "16bit mono", smallerFont)
local micLabel = Label(10, 110, getMicrophoneLabel(), smallerFont)
local toast = Toast(220, smallerFont)

function levelsListener(audLevel, audMax, audAverage)
	waveform:updateLevels(audLevel, audMax, audAverage)
end

function recordingListener(active, elapsed)
	timer:setSeconds(elapsed)
	recordingIndicator:setActive(active)
end

local recorder = Recorder(playdate.sound.kFormat16bitMono)
recorder:startListening(levelsListener)

local menu = playdate.getSystemMenu()
menu:addOptionsMenuItem("", {"8bit mono", "8bit stereo", "16bit mono", "16bit stereo"}, "16bit mono", function(option)
	if(recorder:isRecording()) then showToast("Can't change format while recording") return end
	recorder:changeFormatFromLabel(option)
	formatLabel:setText(recorder:getFormatLabel())
end)

function playdate.update()
	recorder:update()
	playdate.graphics.sprite.update()	
	playdate.timer.updateTimers()
end

function playdate.BButtonDown()
	if(recorder:isNotRecording())then recorder:startRecording(recordingListener) end
end

function playdate.AButtonDown()
	if(recorder:isRecording())then
		recorder:stopRecording()
		local filename = recorder:generateFilename()
		recorder:saveWav(filename)
		showToast(filename .. " saved")
	end
end

function showToast(message) toast:setText(message) end
