
local M = require "majiang.gang"

local function chi(cards, card)
	local raw_cards = {}
	-- only consider one class
	for _, v in ipairs(cards or {}) do
		if math.floor(v / 10) == math.floor(card / 10) then
			table.insert(raw_cards, v)
		end
	end
	local raw_stack_cards = AI.majiang.stack_cards(raw_cards)
	local t = {}	-- {{card1, card2}, ...}
	if card % 10 <= 5 then
		if raw_stack_cards[card - 2] and raw_stack_cards[card - 1] then
			table.insert(t, {card - 2, card - 1})
		end
		if raw_stack_cards[card - 1] and raw_stack_cards[card + 1] then
			table.insert(t, {card - 1, card + 1})
		end
		if raw_stack_cards[card + 1] and raw_stack_cards[card + 2] then
			table.insert(t, {card + 1, card + 2})
		end
	else
		if raw_stack_cards[card + 1] and raw_stack_cards[card + 2] then
			table.insert(t, {card + 1, card + 2})
		end
		if raw_stack_cards[card - 1] and raw_stack_cards[card + 1] then
			table.insert(t, {card - 1, card + 1})
		end
		if raw_stack_cards[card - 2] and raw_stack_cards[card - 1] then
			table.insert(t, {card - 2, card - 1})
		end
	end
	if #t == 0 then return false end
	-- calc raw_best, raw_relation
	local raw_info = AI.majiang.shunzi_remove_exclude_duizi(raw_cards)
	for _, v in ipairs(raw_info) do
		for _, vv in pairs(v) do
			AI.majiang.kezi_remove(vv)
		end
	end
	local raw_best, raw_relation = AI.majiang.select_combine_exclude_duizi(raw_info)
	-- dump(raw_best, "raw_best")
	-- dump(raw_relation, "raw_relation")
	
	-- if remain has card by chi, then return true
	local tmp = {}
	for _, v in ipairs(t) do
		if raw_best.remain[v[1]] and raw_best.remain[v[2]] then
			table.insert(tmp, v)
		end
	end
	-- dump(tmp, "tmp")
	if #tmp == 1 then return true, tmp[1] end
	if #tmp > 1 then
		local idx, relation = 0, {}
		for i, v in ipairs(tmp) do
			local tmp_best = table.clone(raw_best)
			for _, vv in ipairs(v) do
				tmp_best.remain[vv] = tmp_best.remain[vv] - 1
				if tmp_best.remain[vv] == 0 then
					tmp_best.remain[vv] = nil
				end
			end
			local tmp_relation = AI.majiang.extract_one_relation(tmp_best)
			if idx == 0 then
				idx, relation = i, tmp_relation
			elseif AI.majiang.select_best_relation(relation, tmp_relation, false, false, true, true) == -1 then
				idx, relation = i, tmp_relation
			end
		end
		return true, tmp[idx]
	end
	-- consider contain duizi
	local result, raw_info2 = AI.majiang.shunzi_remove_contain_duizi(raw_cards)
	if not result then return false end
	for _, v in ipairs(raw_info2) do
		for _, vv in pairs(v) do
			AI.majiang.kezi_remove(vv)
		end
	end
	local raw_best2, raw_relation2 = AI.majiang.select_combine_contain_duizi(raw_info2)
	for _, v in ipairs(t) do
		local tmp_cards = table.clone(raw_cards)
		table.removebyvalue(tmp_cards, v[1])
		table.removebyvalue(tmp_cards, v[2])
		AI.majiang.print_cards(tmp_cards)
		local tmp_result, tmp_info = AI.majiang.shunzi_remove_contain_duizi(tmp_cards)
		if tmp_result then
			for _, v in ipairs(tmp_info) do
				for _, vv in pairs(v) do
					AI.majiang.kezi_remove(vv)
				end
			end
			local tmp_best, tmp_relation = AI.majiang.select_combine_contain_duizi(tmp_info)
			-- dump(tmp_best, "tmp_best")
			-- dump(tmp_relation, "tmp_relation")
			local ret = AI.majiang.compare_relation_by_chi(tmp_relation, raw_relation2, true)
			if ret then return true, v end
		end
	end
	-- if remain has not card by chi
	for _, v in ipairs(t) do
		local tmp_cards = table.clone(raw_cards)
		table.removebyvalue(tmp_cards, v[1])
		table.removebyvalue(tmp_cards, v[2])
		AI.majiang.print_cards(tmp_cards)
		local tmp_info = AI.majiang.shunzi_remove_exclude_duizi(tmp_cards)
		for _, v in ipairs(tmp_info) do
			for _, vv in pairs(v) do
				AI.majiang.kezi_remove(vv)
			end
		end
		local tmp_best, tmp_relation = AI.majiang.select_combine_exclude_duizi(tmp_info)
		-- dump(tmp_relation, "tmp_relation111")
		local result = AI.majiang.compare_relation_by_chi(tmp_relation, raw_relation)
		if result then return true, v end
	end

	return false
end

function M.chi(raw_cards, card)
	table.sort(raw_cards)
	AI.majiang.print_cards(raw_cards)
	return chi(raw_cards, card)
end

return M