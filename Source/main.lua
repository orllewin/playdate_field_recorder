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

if playdate.isSimulator then
	playdate.sound.setOutputsActive(true, true)
else
	playdate.sound.setOutputsActive(false, true)
end

local recordingIndicator = playdate.graphics.image.new("Images/recording_indicator")
local batteryIcon = playdate.graphics.image.new("Images/battery")
invertDisplay()

local bigFont = playdate.graphics.font.new("Fonts/Roobert-24-Medium")
playdate.graphics.setFont(bigFont)

local smallerFont = playdate.graphics.font.new("Fonts/Roobert-11-Medium")

local timer = TimerView(10, 40)
local waveform = Waveform(10, 180, 380, 105)
local batteryIndicator = BatteryIndicator(348, 124, smallerFont)
local recordingIndicator = RecordingIndicator(355, 37, smallerFont)
local formatLabel = Label(10, 117, "16bit Mono", smallerFont)
local toast = Toast(7, 75, smallerFont)

function levelsListener(audLevel, audMax, audAverage)
	waveform:updateLevels(audLevel, audMax, audAverage)
end

function recordingElapsedListener(active, elapsed)
	timer:setSeconds(elapsed)
	recordingIndicator:setActive(active)
end

local recorder = Recorder(playdate.sound.kFormat16bitMono)
recorder:startListening(levelsListener)

local menu = playdate.getSystemMenu()
menu:addOptionsMenuItem("", {"8bit Mono", "8bit Stereo", "16bit Mono", "16bit Stereo"}, "16bit Mono", function(option)
	if(recorder:isRecording()) then showToast("Can't change format while recording") end
	if option == "8bit Mono" then
		recorder:changeFormat(playdate.sound.kFormat8bitMono)
	elseif option == "8bit Stereo" then
		recorder:changeFormat(playdate.sound.kFormat8bitStereo)
	elseif option == "16bit Mono" then
		recorder:changeFormat(playdate.sound.kFormat16bitMono)
	elseif option ==  "16bit Stereo" then
		recorder:changeFormat(playdate.sound.kFormat16bitStereo)	
	end
	formatLabel:setText(recorder:getFormatLabel())
end)

function playdate.update()
	recorder:update()
	playdate.graphics.sprite.update()	
	playdate.timer.updateTimers()
end

function playdate.BButtonDown()
	if(recorder:isNotRecording())then recorder:startRecording(recordingElapsedListener) end
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
