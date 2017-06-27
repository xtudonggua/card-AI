
package.path = "../?.lua"

require "utils.string"
require "utils.dump"
require "utils.table"

require "AI_INIT"

local filename = ...
local _file
-- print("filename = ",	filename)
if filename then
	os.execute ("rm " .. filename)
	_file = io.open(filename, "a+")
end

function sleep(n)
   local t0 = os.clock()
   while os.clock() - t0 <= n do end
end

local loop = filename and 100 or 1
for i = 1, loop do
	local base_cards = AI.majiang.get_base_card({1, 2}, {{1, 7}, {3, 9}, {4, 6}})
	local rand_cards = AI.majiang.rand_cards(base_cards)
	local cards = AI.majiang.hand_cards(rand_cards, 10)
	-- local cards = {12, 13, 14, 14, 15, 16, 22, 23,24, 24}
	-- local cards = {11, 11, 22, 32}
	-- local cards = {11,15,15,15,17,22,24,24,26,33,35,45,45}
	-- local cards = {11, 11, 12, 13, 14, 15, 15, 16, 28, 28}
	-- local cards = {12, 13, 16, 14, 14, 15, 28}
	-- local cards = {17, 16, 15, 15}	-- todo
	-- local cards = {16, 16, 18, 18}	-- todo
	-- local cards = {12,14,16,17,17,18,18}
	-- local cards = {13,13,14,14,15,16,17,18,18,19}
	-- local cards = {11,13,13,14,15,16,17,17,18,18}
	-- local cards = {11,13,14,14,15,16,18,19,22,22}
	-- local cards = {13, 13, 15, 15, 16, 17, 17}
	-- local cards = {12,13,13,16,16,16,17}
	-- local cards = {12,12,13,15,16,16,17}
	-- local cards = {11, 14, 15, 15, 16, 16, 17}
	-- local cards = {13, 15, 19, 19}
	-- local cards = {12,12,13,14,15,16,17,17,26,27}
	-- local cards = {17,17,15,16}
	-- local cards = {12,12,13,14,14,14,15,15,16,17}
	
	local params = {
		-- laizi_cards = {[15] = true},
		river_cards = {},
	}
	
	if filename then
		table.sort(cards)
		local s = i .. ":	AI cards = "
		for _, v in ipairs(cards) do
			s = s .. " " .. v
		end
		_file:write(s .. "\n")
	end

	local stack_cards = AI.majiang.stack_cards(cards)
	for card, v in pairs(stack_cards) do
		if v >= 2 then
			-- local card = 15
			-- local result = AI.majiang.peng(cards, card)
			local result = AI.majiang.peng_consider_river(cards, card, params)
			params.river_cards[card] = 4
			print("PENG = ",	card,	result)
			if filename then
				_file:write("PENG = " .. card .. tostring(result) .. "\n")
			end
			-- break
		end
	end

	-- if filename then
	-- 	table.sort(cards)
	-- 	local s = i .. ":	AI cards = "
	-- 	for _, v in ipairs(cards) do
	-- 		s = s .. " " .. v
	-- 	end
	-- 	_file:write(s .. "\n")
	-- end
	if filename then
		sleep(1)
	end
end
