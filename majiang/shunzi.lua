
local M = require "majiang.common"

local function is_existed(value)
	return value and value > 0
end

local function no_feng(card)
	return math.floor(card / 10) < 4
end

local function less_eight(card)
	return card % 10 < 8
end

-- calc all shunzi
local function calc_all_shunzi(stack_cards)
	local shunzi = {}
	for card, _ in pairs(stack_cards or {}) do
		if less_eight(card) and no_feng(card) 
			and is_existed(stack_cards[card + 1]) and is_existed(stack_cards[card + 2]) then
			table.insert(shunzi, card)
		end
	end
	return shunzi
end

local function is_same_map(map1, map2)
	for k, v in pairs(map1) do
		if v ~= map2[k] then
			return false
		end
	end
	return true
end

local function core_remove(stack_cards, duizi)
	local result = {}
	local path = {}
	local function stack_remove(stack_cards)
		local all_shunzi = calc_all_shunzi(stack_cards)
		if #all_shunzi == 0 then
			if #path > 0 then
				local same = false
				for _, v in ipairs(result) do
					if is_same_map(v.remain, stack_cards) then
						same = true
						break
					end
				end
				if not same then
					table.insert(result, {path = table.clone(path), remain = stack_cards, duizi = duizi})
				end
			elseif duizi then
				table.insert(result, {duizi = duizi, remain = stack_cards})
			end
			return
		end
		for _, card in ipairs(all_shunzi) do
			local tmp_cards = table.clone(stack_cards)
			table.insert(path, card)
			AI.majiang.sub_stack(tmp_cards, card)
			AI.majiang.sub_stack(tmp_cards, card+1)
			AI.majiang.sub_stack(tmp_cards, card+2)
			stack_remove(tmp_cards)
			table.remove(path)
		end
	end
	stack_remove(stack_cards)
	return result
end

local function remove_compat_duizi(class_cards)
	local info = {}
	for _, cards in pairs(class_cards or {}) do
		local stack_cards = AI.majiang.stack_cards(cards)
		local result = core_remove(stack_cards)
		if next(result) then
			table.insert(info, result)
		else
			table.insert(info, {{remain = stack_cards}})
		end
	end
	return info
end

local function remove_except_duizi(cards)
	local info = {}
	local stack_cards = AI.majiang.stack_cards(cards)
	local flag = false
	for card, num in pairs(stack_cards) do
		local clone_stack_cards = table.clone(stack_cards)
		if num >= 2 then
			AI.majiang.sub_stack(clone_stack_cards, card)
			AI.majiang.sub_stack(clone_stack_cards, card)
			local result = core_remove(clone_stack_cards, card)
			if next(result) then
				table.insert(info, result)
				flag = true
			end
		end
	end
	-- if not flag then
	-- 	table.insert(info, {remain = stack_cards})
	-- end
	return flag, info
end

-- remove shunzi
function M.shunzi_remove_contain_duizi(cards)
	return remove_except_duizi(cards)
end

-- remove shunzi
function M.shunzi_remove_exclude_duizi(cards)
	local class_cards = AI.majiang.class_type(cards) 	-- classied: wan tong tiao feng
	return remove_compat_duizi(class_cards)
end

return M