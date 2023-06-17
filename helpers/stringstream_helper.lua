--[[
	Description: This file is part of stringstream_helper
	Author: Lyu
	Discord: lyu1
]]

local MT = {_VERSION = 'stringstream_helper.lua v2023.05.09'}
MT.__index = MT

function stringstream()
	local object = {}

	setmetatable(object, MT)
	return object
end

function MT:append(string, ...)
	self[#self + 1] = string:format(...)
end

function MT:concat()
	return table.concat(self)
end

function MT:clear()
	for key in pairs(self) do
		self[key] = nil
	end
end

MT.str = MT.concat
