--[[
	Description: This file is part of duration_helper
	Author: Lyu
	Discord: lyu07
]]

local ERROR_ARGUMENTS_REQUIRED = 'arguments days, hours, minutes, seconds or milliseconds is required'
local ERROR_ARGUMENTS_MUST_BE_NUMBERS = 'arguments must be numbers'

local langs = {
	['en'] = {week = 'week', day = 'day', hour = 'hour', minute = 'minute', second = 'second', _and = 'and'},
	['pt'] = {week = 'semana', day = 'dia', hour = 'hora', minute = 'minuto', second = 'segundo', _and = 'e'},
	['es'] = {week = 'semana', day = 'día', hour = 'hora', minute = 'minuto', second = 'segundo', _and = 'y'},
	['de'] = {week = 'woche', day = 'tage', hour = 'stunden', minute = 'minuten', second = 'sekunden', _and = 'und'},
	['pl'] = {week = 'tydzie?', day = 'dni', hour = 'godziny', minute = 'minuty', second = 'sekund', _and = 'i'}
}

local MT = {_VERSION = 'duration_helper.lua v2023.05.09'}
MT.__index = MT

function Duration(args)
	if args == nil or type(args) ~= 'table' then
		error(ERROR_ARGUMENTS_REQUIRED)
	end

	local data = {
		[24 * 60 * 60 * 1000] = args.days,
		[60 * 60 * 1000] = args.hours,
		[60000] = args.minutes,
		[1000] = args.seconds,
		[1] = args.milliseconds
	}

	local hasData = false
	local milliseconds = 0

	for multiplier, duration in pairs(data) do
		if type(duration) ~= 'number' then
			error(ERROR_ARGUMENTS_MUST_BE_NUMBERS)
		end

		duration = math.floor(duration)
		milliseconds = milliseconds + duration * multiplier
		hasData = true
	end

	if milliseconds < 0 then
		milliseconds = 0
	end

	if not hasData then
		error(ERROR_ARGUMENTS_REQUIRED)
	end

	local object = {_ms = milliseconds}
	setmetatable(object, MT)

	return object
end

function MT:string(lang)
	lang = langs[lang or 'en']
	if not lang then
		lang = langs['en']
	end

	local seconds = self:seconds()
	if seconds <= 0 then
		return ('0 %ss'):format(lang.second)
	end

	local data = {
		{arg = lang.week, value = seconds / 60 / 60 / 24 / 7},
		{arg = lang.day, value = seconds / 60 / 60 / 24 % 7},
		{arg = lang.hour, value = seconds / 60 / 60 % 24},
		{arg = lang.minute, value = seconds / 60 % 60},
		{arg = lang.second, value = seconds % 60}
	}
	
	local result = {}
	for _, duration in pairs(data) do
		local value = math.floor(duration.value)

		if value > 0 then
			local separator = #result == 0 and '' or ', '
			local plural = value == 1 and '' or 's'

			local str = ('%s%d %s%s'):format(separator, value, duration.arg, plural)
			result[#result + 1] = str
		end
	end
	
	if #result > 1 then
		result[#result] = result[#result]:gsub(',', (' %s'):format(lang._and))
	end
	return table.concat(result, '')
end

function MT:milliseconds()
	return math.floor(self._ms)
end

function MT:seconds()
	return math.floor(self._ms / 1000)
end

function MT:minutes()
	return math.floor(self._ms / 60 / 1000)
end

function MT:hours()
	return math.floor(self._ms / 60 / 60 / 1000)
end

function MT:days()
	return math.floor(self._ms / 24 / 60 / 60 / 1000)
end

function MT:add(ms)
	self._ms = math.max(
		0,
		math.floor(self._ms + ms)
	)
end

function MT:sub(ms)
	self:add(-ms)
end
