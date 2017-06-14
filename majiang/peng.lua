
local M = require "majiang.out"

local function peng(raw_cards, card)
	local raw_info = AI.majiang.shunzi_remove_exclude_duizi(raw_cards)
	for _, v in ipairs(raw_info) do
		for _, vv in pairs(v) do
			AI.majiang.kezi_remove(vv)
		end
	end
	local raw_best, raw_relation = AI.majiang.select_combine_exclude_duizi(raw_info)
	-- dump(raw_best, "raw_best")
	-- dump(raw_relation, "raw_relation")
	-- more duizi can peng!
	if #raw_relation.relation_AA > 1 then
		for _, v in ipairs(raw_relation.relation_AA) do
			if v == card then
				return true
			end
		end
	end
	-- {11,12,13,13},{12,13,13,14},{17,17,18,19},{15,16,17,17}
	if #raw_relation.relation_AA == 0 and #raw_relation.relation_AB == 0 and #raw_relation.relation_AC == 0 and
		#raw_relation.single_A == 1 and raw_relation.single_A[1] == card then
		for _, v in ipairs(raw_best.path or {}) do
			if (v == card - 2 and math.floor(v % 10) == 1) or v == card - 1 or (v == card and math.floor(v % 10) == 7) then
				return true
			end
		end
		return false
	end
	-- reextract relation after remove {card, card}, then recover relation_AA
	if raw_best.remain[card] == 2 then
		AI.majiang.sub_stack(raw_best.remain, card)
		AI.majiang.sub_stack(raw_best.remain, card)
		raw_relation = AI.majiang.extract_one_relation(raw_best)
		table.insert(raw_relation.relation_AA, card)
		-- dump(raw_best, "raw_best")
		-- dump(raw_relation, "raw_relation")
	end
	-- compare relation between pre and post peng
	local cards = table.clone(raw_cards)
	table.removebyvalue(cards, card)
	table.removebyvalue(cards, card)
	AI.majiang.print_cards(cards)
	-- contain duizi
	local ret, info = AI.majiang.shunzi_remove_contain_duizi(cards)
	if ret then
		for _, v in ipairs(info) do
			for _, vv in pairs(v) do
				AI.majiang.kezi_remove(vv)
			end
		end
		local best, relation = AI.majiang.select_combine_contain_duizi(info)
		-- dump(best, "best111")
		-- dump(relation, "relation111")
		local raw_data = {
			info = raw_best,
			relation = raw_relation,
			len = #raw_cards,
		}
		local data = {
			info = best,
			relation = relation,
			len = #cards,
		}
		local result = AI.majiang.compare_best_combine4(data, raw_data, true)
		if result then return true end
	end
	-- exclude duizi
	local info = AI.majiang.shunzi_remove_exclude_duizi(cards)
	for _, v in ipairs(info) do
		for _, vv in pairs(v) do
			AI.majiang.kezi_remove(vv)
		end
	end
	local best, relation = AI.majiang.select_combine_exclude_duizi(info)
	-- dump(best, "best222")
	-- dump(relation, "relation222")
	local raw_data = {
		info = raw_best,
		relation = raw_relation,
		len = #raw_cards,
	}
	local data = {
		info = best,
		relation = relation,
		len = #cards,
	}
	local result = AI.majiang.compare_best_combine1(data, raw_data, true)
	-- print("result = ",	result)
	if result then return true end
	return false
end

function M.peng(cards, card)
	table.sort(cards)
	AI.majiang.print_cards(cards)
	return peng(cards, card)
end

function M.peng_consider_laizi(raw_cards, card, params)
	local laizi_cards = params.laizi_cards or {}
	if laizi_cards[card] then return false end
	local cards = table.clone(raw_cards)
	table.sort(cards)
	AI.majiang.print_cards(cards)
	for i = #cards, 1, -1 do
		if laizi_cards[cards[i]] then
			table.remove(cards, i)
		end
	end
	return peng(cards, card)
end

function M.peng_consider_river(raw_cards, card, params)
	AI.majiang.river_cards = params.river_cards or {}
	return M.peng_consider_laizi(raw_cards, card, params)
end

return M