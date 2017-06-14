
local M = require "majiang.shunzi"

-- don't consider hupai, so judge hupai before use this
local function out(cards)
	-- remove shunzi
	local info1 = AI.majiang.shunzi_remove_exclude_duizi(cards)
	for _, v in ipairs(info1) do
		for _, vv in pairs(v) do
			AI.majiang.kezi_remove(vv)
		end
	end
	-- dump(info1, "info1")
	local best1, relation1 = AI.majiang.select_combine_exclude_duizi(info1)
	-- dump(best1, "best1")
	-- dump(relation1, "relation1")
	local best, relation = best1, relation1

	local result, info2 = AI.majiang.shunzi_remove_contain_duizi(cards)
	if result then
		-- remove kezi
		for _, v in ipairs(info2) do
			for _, vv in pairs(v) do
				AI.majiang.kezi_remove(vv)
			end
		end
		local best2, relation2 = AI.majiang.select_combine_contain_duizi(info2)
		-- dump(best2, "best2")
		-- dump(relation2, "relation2")
		local data1 = {
			info = best1,
			relation = relation1,
			len = #cards,
		}
		local data2 = {
			info = best2,
			relation = relation2,
			len = #cards,
		}
		local result = AI.majiang.compare_best_combine3(data1, data2)
		if not result then
			best, relation = best2, relation2
		end
	else
		-- print("no duizi !!!!")
	end

	-- dump(best, "best")
	-- dump(relation, "relation")
	return AI.majiang.evaluate_worst_card(best, relation)
end

function M.out(cards)
	table.sort(cards)
	AI.majiang.print_cards(cards)
	return out(cards)
end

function M.out_consider_laizi(raw_cards, params)
	local laizi_cards = params.laizi_cards or {}
	local cards = table.clone(raw_cards)
	table.sort(cards)
	AI.majiang.print_cards(cards)
	for i = #cards, 1, -1 do
		if laizi_cards[cards[i]] then
			table.remove(cards, i)
		end
	end
	return out(cards)
end

--[[ params:
	river_cards = {[11]=1,[12]=2,...}
]]
function M.out_consider_river(raw_cards, params)
	AI.majiang.river_cards = params.river_cards or {}
	return M.out_consider_laizi(raw_cards, params)
end

return M