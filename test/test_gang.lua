
package.path = "../?.lua"

require "utils.string"
require "utils.dump"
require "utils.table"

require "AI_INIT"

local filename = ...
local _file
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
	local base_cards = AI.majiang.get_base_card({1}, {{1, 7}, {3, 9}, {4, 6}})
	local rand_cards = AI.majiang.rand_cards(base_cards)
	local cards = AI.majiang.hand_cards(rand_cards, 10)
	-- local cards = {11,11,11,12,13,14,14,15,16,17}
	local cards = {14, 14, 14, 16}

	local params = {
		-- laizi_cards = {[15] = true},
		river_cards = {[15] = 4},
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
		if v == 3 then
			-- local card = 15
			local result = AI.majiang.gang_consider_river(cards, card, params)
			print("GANG = ",	card,	result)
			if filename then
				_file:write("GANG = " .. card .. tostring(result) .. "\n")
			end
			-- break
		end
	end

	if filename then
		sleep(1)
	end
end
