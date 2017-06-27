
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

local all_cards = AI.majiang.get_base_card({1}, {{1, 9}, {3, 9}, {4, 6}}, 1)
for i = 1, loop do
	local base_cards = AI.majiang.get_base_card({1}, {{1, 9}, {3, 9}, {4, 6}})
	local rand_cards = AI.majiang.rand_cards(base_cards)
	local cards = AI.majiang.hand_cards(rand_cards, 7)
	-- local cards = {12, 13, 13, 14, 15, 27, 27, 28, 29, 29}
	-- local cards = {12, 13, 16, 15, 32, 32, 33}
	-- local cards = {13, 15, 16, 17, 22, 22, 23, 31, 35, 39}
	-- local cards = {12, 13, 14, 15}	-- todo
	-- local cards = {12, 12, 13, 15, 16, 17, 18}
	-- local cards = {12, 12, 13, 14, 14, 18, 19}
	-- local cards = {11, 12, 14, 15, 15, 16, 18}
	-- local cards = {11, 13, 15, 15, 16, 18, 19}
	-- local cards = {11, 12, 15, 16, 16, 18, 19}
	-- local cards = {12, 12, 13, 15, 16, 18, 19}
	-- local cards = {12, 12, 13, 14, 15, 17, 19}
	local cards = {11, 12, 13, 13, 14, 15, 16}
	
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

	local all_cards = {11}
	local stack_cards = AI.majiang.stack_cards(cards)
	for _, card in ipairs(all_cards) do
		if (stack_cards[card - 2] and stack_cards[card - 1]) or (stack_cards[card - 1] and stack_cards[card + 1])
			or (stack_cards[card + 1] and stack_cards[card + 2]) then
			local result, chi_cards = AI.majiang.chi(cards, card)
			print("CHI = ",	card,	result,	 result and (chi_cards[1] .. "	" .. chi_cards[2]) or "")
			if filename then
				_file:write("CHI = " .. card .. " " .. tostring(result) .. " " ..
					(result and (chi_cards[1] .. "	" .. chi_cards[2]) or "") .. "\n")
			end
		end
	end
	
	if filename then
		sleep(1)
	end
end
