
local M = {}

function M.get_base_card(type_list, card_list)
	local cards = {}
	type_list = type_list or {1, 2, 3}
	card_list = card_list or {}
	for k, v in ipairs(type_list) do
		local interval = card_list[k] or ((v == 4) and {1, 5} or {1, 9})
		local tmp_cards = {}
		for i = interval[1], interval[2] do
			table.insert(tmp_cards, i + v * 10)
		end
		for i = 1, 4 do
			for _, v in ipairs(tmp_cards) do
				table.insert(cards, v)
			end
		end
	end
	return cards
end

-- 洗牌，分两步: 全部随机，交叉随机
function M.rand_cards(base_cards)
	local function rand_cards1(a)
		math.randomseed(tostring(os.time()):reverse():sub(1,6))
		for i = #a, 1, -1 do
			local j = math.random(1, i)
			a[i], a[j] = a[j], a[i]
		end
	end
	local function rand_cards2(a, n)
		if n <= 1 then
	        return a
	    end
	    rand_cards2(a, n-1)
	    local rand = math.random(1,n)
	    a[n], a[rand] = a[rand], a[n]
	end
	local a = table.clone(base_cards)
	rand_cards1(a)
	math.randomseed(tostring(os.time()):reverse():sub(1,6))
	rand_cards2(a, #a)
	return a
end

function M.hand_cards(raw_cards, num)
	local cards = {}
	for i = 1, num do
		table.insert(cards, raw_cards[i])
	end
	return cards
end

function M.stack_cards(cards)
	local stack_cards = {}
	for _, card in ipairs(cards or {}) do
		stack_cards[card] = (stack_cards[card] or 0) +1
	end
	return stack_cards
end

function M.class_type(cards)
	local class = {}
	for _, card in ipairs(cards or {}) do
		local _type = math.floor(card / 10)
		class[_type] = class[_type] or {}
		table.insert(class[_type], card)
	end
	return class
end

function M.sub_stack(stack_cards, card)
	if stack_cards[card] then
		stack_cards[card] = stack_cards[card] - 1
	end
	if stack_cards[card] == 0 then
		stack_cards[card] = nil
	end
end

function M.print_cards(cards)
	local s = "AI cards = "
	for _, v in ipairs(cards) do
		s = s .. " " .. v
	end
	print(s)
end

return M