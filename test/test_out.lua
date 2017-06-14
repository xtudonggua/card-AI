
package.path = "../?.lua"

require "utils.string"
require "utils.dump"
require "utils.table"

require "AI_INIT"

local filename = ...
local _file
print("filename = ",	filename)
if filename then
	os.execute ("rm " .. filename)
	_file = io.open(filename, "a+")
end

function sleep(n)
   local t0 = os.clock()
   while os.clock() - t0 <= n do end
end

for i = 1, 1 do
	local base_cards = AI.majiang.get_base_card({1, 2, 3, 4}, {{1,7}, {2,7}, {2, 7}, {5, 5}})
	local rand_cards = AI.majiang.rand_cards(base_cards)
	local cards = AI.majiang.hand_cards(rand_cards, 14)
	-- local cards = {12,13,15,18,19,22,23,25}
	-- local cards = {11, 12, 13, 14, 15}
	-- local cards = {12, 12, 13, 14, 16}
	-- local cards = {12, 13, 14, 15, 16}
	-- local cards = {14, 14, 15, 15, 16, 17, 18, 19}
	-- local cards = {11, 11, 11, 12, 13, 13, 15, 16}
	-- local cards = {11, 11, 13, 17, 19}
	-- local cards = {11, 11, 13, 17, 19, 21, 21, 23, 33,34, 35, 36}
	-- local cards = {14, 12, 13, 14, 15}
	-- local cards = {15, 16, 13, 14, 15}
	-- local cards = {12, 13, 15, 15, 16, 16, 17, 17, 17, 18, 19}
	-- local cards = {11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 19}
	-- local cards = {12,13,14,14,15,22,25,26,27,29,29}
	-- local cards = {13, 12, 23, 24, 32, 32, 38, 38}
	-- local cards = {13, 15, 23, 25, 38, 39}
	-- local cards = {11,12,14,16,16,17,22,23,24,25,26,32,34,34}
	-- local cards = {13, 14, 16, 26, 28}
	-- local cards = {17, 18, 23, 25, 35, 36, 41, 41}
	-- local cards = {11, 12, 14, 15, 17}
	-- local cards = {11,11,12,15,17,22,22,23,25,27,35,35,36,37}
	-- local cards = {11, 11, 12, 13, 14, 15, 15, 16}

	local params = {
		laizi_cards = {[45] = true},
		river_cards = {[16] = 4}
	}
	local worst_card = AI.majiang.out_consider_river(cards, params)
	print("out = ",  worst_card or "HU")
	if filename then
		table.sort(cards)
		local s = i .. ":	AI cards = "
		for _, v in ipairs(cards) do
			s = s .. " " .. v
		end
		_file:write(s .. "\n")
		_file:write("out = " .. (worst_card or "HU") .. "\n")
	end
	if filename then
		sleep(1)
	end
end
