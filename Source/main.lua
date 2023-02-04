import 'Coracle/coracle'
import 'Coracle/Audio/recorder'
import 'CoreLibs/sprites'
import 'Views/waveform'
import 'Views/timer'
import 'Views/battery_indicator'
import 'CoreLibs/timer'

playdate.display.setRefreshRate(25)

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

local toastMessage = ""
local showToast = false
local toastTimer = nil
local toastYAnchor = 138


function levelsListener(audLevel, audMax, audAverage)
	waveform:updateLevels(audLevel, audMax, audAverage)
end

function recordingElapsedListener(elapsed)
	timer:setSeconds(elapsed)
end

local recorder = Recorder(playdate.sound.kFormat16bitMono)
recorder:startListening(levelsListener)

local menu = playdate.getSystemMenu()
menu:addOptionsMenuItem("", {"8bit Mono", "8bit Stereo", "16bit Mono", "16bit Stereo"}, "16bit Mono", function(option)
	print("option .. " .. option)
	if(recorder:isRecording()) then recorder:stopRecording() end
	if option == "8bit Mono" then
		recorder:changeFormat(playdate.sound.kFormat8bitMono)
	elseif option == "8bit Stereo" then
		recorder:changeFormat(playdate.sound.kFormat8bitStereo)
	elseif option == "16bit Mono" then
		recorder:changeFormat(playdate.sound.kFormat16bitMono)
	elseif option ==  "16bit Stereo" then
		recorder:changeFormat(playdate.sound.kFormat16bitStereo)	
	end
end)

function playdate.update()
	recorder:update()
	playdate.graphics.sprite.update()
	
	playdate.graphics.setFont(smallerFont)
	text(recorder:getFormatLabel(), 10, 105)
	playdate.graphics.setFont(bigFont)
	if(recorder:isRecording())then
		recordingIndicator:draw(312, 10)
	else
		recordingIndicator:drawFaded(312, 10, 0.25, playdate.graphics.image.kDitherTypeDiagonalLine)
	end
	
	if showToast then
			playdate.graphics.setFont(smallerFont)
			text(toastMessage, 7, 63)
	end
	
	playdate.timer.updateTimers()
	
end

function playdate.BButtonDown()
	if(recorder:isRecording())then
		return--do nothing
	else
		recorder:startRecording(recordingElapsedListener)
	end
end

function playdate.AButtonDown()
	if(recorder:isRecording())then
		recorder:stopRecording()
		local filname = recorder:generateFilename()
		recorder:saveWav(filname)
		toast("" .. filname .. " saved")
	end
end

function toast(message)
	toastMessage = message
	print("TOAST: " .. message)
	local function toastCallback()
			showToast = false
	end
	showToast = true
	toastTimer = playdate.timer.new(2500, toastCallback)
end
