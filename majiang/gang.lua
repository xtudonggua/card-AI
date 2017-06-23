
local M = require "majiang.peng"

local function gang(raw_cards, card)
	-- {12, 12, 12, 13}
	if #raw_cards == 4 then
		local tmp_card = 0
		for _, v in ipairs(raw_cards) do
			if v ~= card then
				tmp_card = v
				break
			end
		end
		return AI.majiang.calc_card_relation(card, tmp_card) == "A"
	end
	-- first remove contain duizi
	local result, info = AI.majiang.shunzi_remove_contain_duizi(raw_cards)
	if result then
		-- remove kezi
		for _, v in ipairs(info) do
			for _, vv in pairs(v) do
				AI.majiang.kezi_remove(vv)
			end
		end
		local best, relation = AI.majiang.select_combine_contain_duizi(info)
		for _, v in ipairs(best.kezi or {}) do
			if v == card then
				return true
			end
		end
	end
	-- then remove exclude duizi
	local info = AI.majiang.shunzi_remove_exclude_duizi(raw_cards)
	for _, v in ipairs(info) do
		for _, vv in pairs(v) do
			AI.majiang.kezi_remove(vv)
		end
	end
	local best, relation = AI.majiang.select_combine_exclude_duizi(info)
	for _, v in ipairs(best.kezi or {}) do
		if v == card then
			return true
		end
	end
	return false
end

function M.gang(cards, card)
	table.sort(cards)
	AI.majiang.print_cards(cards)
	return gang(cards, card)
end

function M.gang_consider_laizi(raw_cards, card, params)
	local laizi_cards = params.laizi_cards or {}
	if laizi_cards[card] then return false end
	local cards = table.clone(raw_cards)
	table.sort(cards)
	for i = #cards, 1, -1 do
		if laizi_cards[card] then
			table.remove(cards, i)
		end
	end
	return gang(cards, card)
end

function M.gang_consider_river(raw_cards, card, params)
	AI.majiang.river_cards = params.river_cards or {}
	return M.gang_consider_laizi(raw_cards, card, params)
end

return M