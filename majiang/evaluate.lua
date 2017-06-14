
local M = require "majiang.kezi"

local function is_AA(card1, card2)
	return card1 == card2
end

local function is_AB(card1, card2)
	if card1 > card2 then
		card1, card2 = card2, card1 	-- assure card2 > card1
	end
	if card1 < 41 and card1 == card2 - 1 then
		local mod1, mod2 = card1 % 10, card2 % 10
		if mod1 == 1 or mod2 == 9 then
			return false
		end
		-- consider river
		local river_cards = AI.majiang.river_cards or {}
		local remain = 8 - (river_cards[card1 - 1] or 0) - (river_cards[card2 + 1] or 0)
		return remain > 4
	end
	return false
end

local function is_AC(card1, card2)
	if card1 > card2 then
		card1, card2 = card2, card1		-- assure card2 > card1
	end
	if card1 >= 41 then return false end
	-- consider river
	local river_cards = AI.majiang.river_cards or {}
	if card2 - card1 == 1 then
		local mod1, mod2 = card1 % 10, card2 % 10
		if mod1 == 1 and (river_cards[card2 + 1] or 0) < 4 then
			return true
		end
		if mod2 == 9 and (river_cards[card1 - 1] or 0) < 4 then
			return true
		end
		local remain = 8 - (river_cards[card1 - 1] or 0) - (river_cards[card2 + 1] or 0)
		if remain <= 4 and remain > 0 then
			return true
		end
	end
	if card2 - card1 == 2 then
		if (river_cards[card1 + 1] or 0) < 4 then
			return true
		end
	end
	return false
end

local RELATION_TYPE = {
	["A"] = 1,
	["AC"] = 2,
	["AB"] = 3,
}

local function calc_relation_type(info, card)
	for _, v in ipairs(info.path or {}) do
		if is_AB(card, v) or is_AB(card, v+1) or is_AB(card, v+2) then
			return RELATION_TYPE.AB
		end
	end
	for _, v in ipairs(info.kezi or {}) do
		if is_AB(card, v) then
			return RELATION_TYPE.AB
		end
	end
	for _, v in ipairs(info.path or {}) do
		if is_AC(card, v) or is_AC(card, v+1) or is_AC(card, v+2) then
			return RELATION_TYPE.AC
		end
	end
	for _, v in ipairs(info.kezi or {}) do
		if is_AC(card, v) then
			return RELATION_TYPE.AC
		end
	end
	return RELATION_TYPE.A
end

-- return 0(=),1(>),-1(<) 
local function compare_worst(data, card1, card2)
	if card1 >= 41 and card2 >= 41 then return 0 end
	if card1 >= 41 and card2 < 41 then return 1 end
	if card1 < 41 and card2 >= 41 then return -1 end
	local relation1 = calc_relation_type(data or {}, card1)
	local relation2 = calc_relation_type(data or {}, card2)
	if relation1 ~= relation2 then
		return relation1 < relation2 and 1 or -1
	end
	local interval1, interval2 = math.abs(card1 % 10 - 5), math.abs(card2 % 10 - 5)
	return interval1 == interval2 and 0 or (interval1 > interval2 and 1 or -1)
end

-- combine path, kezi
local function select_worst_single_A(data, info)
	local tmp = {info[1]}
	local worst = info[1]
	for i = 2, #info do
		local bool = compare_worst(data, worst, info[i])
		if bool == 0 then
			table.insert(tmp, info[i])
		elseif bool == -1 then
			worst = info[i]
			tmp = {info[i]}
		end
	end
	return tmp[math.random(1, #tmp)]
end

-- todo consider B out
-- {13, 14, 16, 26, 28} out 16
local function select_worst_relation_AC(data, info, extra_AB)
	local tmp = {}
	for _, v in ipairs(extra_AB or {}) do
		tmp[v[1]] = true
		tmp[v[2]] = true
	end
	local tmp2 = {}		-- {12, 14, 16, 17} can't change 14 to single1
	for _, v in ipairs(info or {}) do
		if not tmp[v[2]] then
			tmp2[v[1]] = tmp2[v[1]] or {}
			table.insert(tmp2[v[1]], v[2])
		end
		if not tmp[v[1]] then
			tmp2[v[2]] = tmp2[v[2]] or {}
			table.insert(tmp2[v[2]], v[1])
		end
	end
	local single1 = {}	-- {16}
	local single2 = {}	-- {26, 28}
	local finish_flag = {}
	for _, v in ipairs(info or {}) do
		if tmp[v[1]] and tmp[v[2]] then
		elseif tmp[v[1]] and not tmp2[v[2]] then
			if not finish_flag[v[2]] then
				table.insert(single1, v[2])
				finish_flag[v[2]] = true
			end
		elseif tmp[v[2]] and not tmp2[v[1]] then
			if not finish_flag[v[1]] then
				table.insert(single1, v[1])
				finish_flag[v[1]] = true
			end
		elseif not tmp[v[1]] and not tmp[v[2]] then
			if not finish_flag[v[1]] then
				table.insert(single2, v[1])
				finish_flag[v[1]] = true
			end
			if not finish_flag[v[2]] then
				table.insert(single2, v[2])
				finish_flag[v[2]] = true
			end
		end
	end
	
	-- dump(single1, "single1")
	-- dump(single2, "single2")
	if #single1 > 0 then
		return select_worst_single_A(data, single1)
	end
	if #single2 > 0 then
		return select_worst_single_A(data, single2)
	end
end

-- todo consider A out
local function select_worst_relation_AA(data, info)
	local single = {}
	for _, v in ipairs(info or {}) do
		table.insert(single, v)
	end
	return select_worst_single_A(data, single)
end

-- todo consider A D out
local function select_worst_relation_AB(data, info)
	local single = {}
	for _, v in ipairs(info or {}) do
		table.insert(single, v[1])
		table.insert(single, v[2])
	end
	return select_worst_single_A(data, single)
end

-- todo consider river and hand cards
-- if B is over, change AC to single A and C
-- if A is over, change BC to AC; if A D is over, change BC to single B and C
function M.extract_one_relation(info)
	local single_A = {}
	local relation_AC = {}
	local relation_AB = {}
	local relation_AA = {}
	local finish_flag = {["A"] = {}, ["AC"] = {}, ["AB"] = {}, ["AA"] = {}}
	local remain = info.remain or {}
	for card1, num1 in pairs(remain) do
		local flag = false
		-- AA
		if num1 == 2 and not finish_flag["AA"][tostring(card1)] then
			table.insert(relation_AA, card1)
			finish_flag["AA"][tostring(card1)] = true
			flag = true
		end
		--  AB or AC
		for card2, num2 in pairs(remain) do
			if finish_flag["AB"][tostring(card1)..tostring(card2)] 
				or finish_flag["AC"][tostring(card1)..tostring(card2)] then
				flag = true
			elseif is_AB(card1, card2) then
				table.insert(relation_AB, {card1, card2})
				finish_flag["AB"][tostring(card1)..tostring(card2)] = true
				finish_flag["AB"][tostring(card2)..tostring(card1)] = true
				flag = true
			elseif is_AC(card1, card2) then
				table.insert(relation_AC, {card1, card2})
				finish_flag["AC"][tostring(card1)..tostring(card2)] = true
				finish_flag["AC"][tostring(card2)..tostring(card1)] = true
				flag = true
			end
		end
		if not flag then table.insert(single_A, card1) end
	end
	-- todo consider river and hand cards
	return {
		single_A = single_A,
		relation_AC = relation_AC,
		relation_AB = relation_AB,
		relation_AA = relation_AA,
	}
end

function M.evaluate_worst_card(data, relation)
	local single_A = relation.single_A or {}
	local relation_AC = relation.relation_AC or {}
	local relation_AB = relation.relation_AB or {}
	local relation_AA = relation.relation_AA or {}
	-- single A prior
	if #single_A > 0 then
		return select_worst_single_A(data, single_A)
	end
	-- relation_AC prior
	if #relation_AC > 0 then
		local card = select_worst_relation_AC(data, relation_AC, relation_AB)
		if card then
			return card
		end
	end
	-- relation_AA prior
	if #relation_AA > 0 then
		local card = select_worst_relation_AA(data, relation_AA)
		if card then
			return card
		end
	end
	-- relation_AB prior
	if #relation_AB > 0 then
		local card = select_worst_relation_AB(data, relation_AB)
		if card then
			return card
		end
	end
end

return M