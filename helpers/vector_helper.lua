--[[
	Description: This file is part of vector_helper
	Author: Lyu
	Discord: lyu07
]]

local MT = {_VERSION = 'vector_helper.lua v2023.06.13'}
MT.__index = MT

local function check(value)
	local result = {}
	
	if getmetatable(value) == MT then
		setmetatable(result, MT)
	end

	for k, v in pairs(value) do
		if type(v) == 'table' then
			result[k] = check(v)
		else
			result[k] = v
		end
	end

	return result
end

function vector(...)
	local object = {}

	for _, v in ipairs({...}) do
		if type(v) == 'table' then
			for _, value in ipairs(check(v)) do
				object[#object + 1] = value
			end
		else
			object[#object + 1] = v
		end
	end

	setmetatable(object, MT)
	return object
end

function MT:front()
	return self[1]
end

function MT:back()
	return self[#self]
end

function MT:at(index)
	return self[index]
end

function MT:empty()
	return #self == 0
end

function MT:size()
	return #self
end

function MT:clear()
	for i = 1, #self do
		self[i] = nil
	end
end

function MT:add(element)
	self[#self + 1] = element
end

function MT:insert(index, element)
	table.insert(self, index, element)
end

function MT:remove(element)
	for i = 1, #self do
		if self[i] == element then
			table.remove(self, i)
			break
		end
	end
end

function MT:removeLast()
	self[#self] = nil
end

function MT:removeFirst()
	self:remove(self[1])
end

function MT:removeAt(index)
	self:remove(self[index])
end

function MT:rand()
	return self[math.random(#self)]
end

function MT:shuffle()
	local random = math.random

	for i = #self, 2, -1 do
		local j = random(i)
		self[i], self[j] = self[j], self[i]
	end
	return self
end

MT.emplace = MT.add
MT.get = MT.at
MT.reset = MT.clear
