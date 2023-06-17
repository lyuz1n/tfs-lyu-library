--[[
	Description: This file is part of timer_helper
	Author: Lyu
	Discord: lyu7
]]

local TimerType = {COUNTDOWN = 0, PERIODIC = 1}
local TimerState = {CREATED = 0, STARTED = 1, FINISHED = 2, CANCELED = 3}

if not Timer then
	Timer = {
		_VERSION = 'timer_helper.lua v2023.05.07',
	
		countdowns = {},
		periodics = {}
	}
end

local function isEventMethod(name, method)
	if method then
		if type(method) ~= 'function' then
			error(('[Error - Timer:countdown] argument %s must be a function'):format(name))
		end
		return true
	end
	return false
end

local Countdown = {}
Countdown.__index = Countdown

local function CountdownMethod(self, object)
	local duration = object.duration
	if duration == nil or duration:seconds() <= 0 then
		error '[Error - Timer:countdown] argument duration must be a duration'
	end

	object.state = TimerState.CREATED
	object.type = TimerType.COUNTDOWN
	setmetatable(object, Countdown)

	if object.autoStart then
		if type(object.autoStart) ~= 'boolean' then
			error '[Error - Timer:countdown] argument autoStart must be a boolean'
		end
		object:start()
	end

	return object
end

local function getTimerList(timer)
	local list = nil
	
	if timer.type == TimerType.COUNTDOWN then
		list = Timer.countdowns
	elseif timer.type == TimerType.PERIODIC then
		list = Timer.periodics
	end

	return list
end

local function register(timer)
	local list = getTimerList(timer)
	if list then
		list[#list + 1] = timer
	end
end

local function unregister(timer)
	local list = getTimerList(timer)
	if list then
		for index, it in ipairs(list) do
			if it == timer then
				table.remove(list, index)
				break
			end
		end
	end
end

function Countdown:start()
	if self.state ~= TimerState.CREATED then
		return
	end

	self.state = TimerState.STARTED
	self.initialSeconds = self:getDuration():seconds()
	register(self)

	if isEventMethod('onStart', self.onStart) then
		self:onStart()
	end
	
	local function tick()
		if self.state == TimerState.CANCELED or self.state == TimerState.FINISHED then
			return
		end

		local duration = self:getDuration()
		if duration:seconds() > 0 then
			if isEventMethod('onTick', self.onTick) then
				self:onTick()
			end

			duration:sub(1000)
			addEvent(tick, 1000)
		else
			self.state = TimerState.FINISHED
			unregister(self)

			if isEventMethod('onFinish', self.onFinish) then
				self:onFinish()
			end
		end
	end

	tick()
end

function Countdown:cancel()
	if self.state == TimerState.CANCELED or self.state == TimerState.FINISHED then
		return
	end

	self.state = TimerState.CANCELED
	unregister(self)

	if isEventMethod('onCancel', self.onCancel) then
		self:onCancel()
	end
end

function Countdown:getDuration()
	return self.duration
end

local Periodic = {}
Periodic.__index = Periodic

local function PeriodicMethod(self, object)
	local duration = object.duration
	if duration == nil or duration:milliseconds() < 0 then
		error '[Error - Timer:periodic] argument duration must be a duration'
	end

	object.duration = Duration {milliseconds = duration:milliseconds()}
	if object.onTick == nil or type(object.onTick) ~= 'function' then
		error '[Error - Timer:periodic] argument onTick must be a function'
	end

	if object.duration:milliseconds() < 100 then
		object.duration = Duration {milliseconds = 100}
	end

	object.tick = 0
	object.type = TimerType.PERIODIC

	setmetatable(object, Periodic)
	register(object)

	local function tick()
		object.eventId = addEvent(tick, duration:milliseconds())
		object.tick = object.tick + 1
		object:onTick()
	end

	tick()
	return object
end

function Periodic:cancel()
	if self.eventId then
		stopEvent(self.eventId)
		self.eventId = nil
		unregister(self)

		if isEventMethod('onCancel', self.onCancel) then
			self:onCancel()
		end
	end
end

function Periodic:isActive()
	return self.eventId ~= nil
end

Timer.countdown = CountdownMethod
Timer.periodic = PeriodicMethod
