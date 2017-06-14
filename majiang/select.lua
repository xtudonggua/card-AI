
local M = require "majiang.evaluate"

local function select_more_kanzi(info1, info2)
	local num1 = #(info1.path or {}) + #(info1.kezi or {})
	local num2 = #(info2.path or {}) + #(info2.kezi or {})
	return num1 == num2 and 0 or (num1 > num2 and 1 or -1)
end

local function select_remain_has_AA(info1, info2)
	local remain1, remain2 = info1.remain or {}, info2.remain or {}
	-- AA prior
	local duizi1, duizi2 = false, false
	for _, v in pairs(remain1) do
		if v == 2 then
			duizi1 = true
			break
		end
	end
	for _, v in pairs(remain2) do
		if v == 2 then
			duizi2 = true
			break
		end
	end
	return duizi1 == duizi2 and 0 or (duizi1 and 1 or -1)
end

-- todo consider river, hand card
local function select_max_min_path(info, path)
	local max, min = 0, 0
	local max_path, min_path = 0, 1000
	for i = 1, #path do
		local idx = path[i][1]
		local cur_path = 0
		for _, v in ipairs(info[idx].path or {}) do
			cur_path = cur_path + v
		end
		if cur_path > max_path then max, max_path = idx, cur_path end
		if cur_path < min_path then min, min_path = idx, cur_path end
	end
	local max_card, min_card = 0, 100
	for _, v in ipairs(info[max].path or {}) do
		max_card = math.max(max_card, v)
	end
	for _, v in ipairs(info[min].path or {}) do
		min_card = math.min(min_card, v)
	end
	-- +2 means ABC C = A + 2
	local pos = (max_card % 10 + 2 - 5) < (5 - min_card % 10) and max or min
	local relation
	for _, v in ipairs(path) do
		if pos == v[1] then
			relation = v[2]
		end
	end
	return pos, relation
end

-- 
local function select_best_relation(relation1, relation2, duizi1, duizi2)
	local total1 = #relation1.relation_AB + #relation1.relation_AC + #relation1.single_A
	local total2 = #relation2.relation_AB + #relation2.relation_AC + #relation2.single_A
	if #relation1.relation_AA > 0 then
		if duizi1 then
			total1 = total1 + #relation1.relation_AA
		else
			total1 = total1 + #relation1.relation_AA - 1
		end
	end
	if #relation2.relation_AA > 0 then
		if duizi2 then
			total2 = total2 + #relation2.relation_AA
		else
			total2 = total2 + #relation2.relation_AA - 1
		end
	end
	if total1 == total2 then
		if #relation1.relation_AB ~= #relation2.relation_AB then
			return #relation1.relation_AB > #relation2.relation_AB and 1 or -1
		elseif #relation1.relation_AC ~= #relation2.relation_AC then
			return #relation1.relation_AC > #relation2.relation_AC and 1 or -1
		end
	else
		if #relation1.single_A ~= #relation2.single_A then
			return #relation1.single_A < #relation2.single_A and 1 or -1
		end
		if #relation1.relation_AC ~= #relation2.relation_AC then
			return #relation1.relation_AC < #relation2.relation_AC and 1 or -1
		end
		-- if #relation1.single_A < #relation2.single_A or #relation1.relation_AC < #relation2.relation_AC
		-- 	or #relation1.relation_AB < #relation2.relation_AB then
		-- 	return 1
		-- end
		-- if #relation1.single_A > #relation2.single_A or #relation1.relation_AC > #relation2.relation_AC
		-- 	or #relation1.relation_AB > #relation2.relation_AB then
		-- 	return -1
		-- end
	end
	return 0
end

local function merge_relation(best_list, relation_list)
	local best = {
		path = {},
		kezi = {},
		-- duizi = {},
		remain = {},
	}
	local relation = {
		single_A = {},
		relation_AC = {},
		relation_AA = {},
		relation_AB = {},
	}
	for k, v in ipairs(best_list) do
		for kk, vv in pairs(v) do
			if kk == "path" or kk == "kezi" then
				for kkk, vvv in ipairs(vv) do
					table.insert(best[kk], vvv)
				end
			elseif kk == "remain" then
				for kkk, vvv in pairs(vv) do
					best[kk][kkk] = vvv
				end
			end
		end
	end
	for k, v in ipairs(relation_list) do
		for kk, vv in pairs(v) do
			for kkk, vvv in ipairs(vv) do
				table.insert(relation[kk], vvv)
			end
		end
	end
	return best, relation
end

function M.select_combine_exclude_duizi(data)
	local function select_one_class(info)
		local best = 1
		local best_relation = AI.majiang.extract_one_relation(info[best])
		local result = {{best, best_relation}}
		for i = 2, #info do
			local bool1 = select_more_kanzi(info[best], info[i])
			local tmp_relation = AI.majiang.extract_one_relation(info[i])
			if bool1 == 0 then
				-- equal kanzi
				local bool2 = select_remain_has_AA(info[best], info[i])
				if bool2 == 0 then
					-- both has AA
					local bool3 = select_best_relation(best_relation, tmp_relation)
					if bool3 == 0 then
						table.insert(result, {i, tmp_relation})
					elseif bool3 == -1 then
						best = i
						best_relation = tmp_relation
						result = {{best, tmp_relation}}
					end
				elseif bool2 == -1 then
					best = i
					best_relation = tmp_relation
					result = {{best, tmp_relation}}
				end
			elseif bool1 == -1 then
				best = i
				best_relation = tmp_relation
				result = {{best, tmp_relation}}
			end
		end
		-- more best, select max or min path
		if #result > 1 then
			best, best_relation = select_max_min_path(info, result)
		end
		return best, best_relation
	end
	local best_list, relation_list = {}, {}
	for _, info in ipairs(data) do
		local idx, r = select_one_class(info)
		table.insert(best_list, info[idx])
		table.insert(relation_list, r)
	end

	local best, relation = merge_relation(best_list, relation_list)
	return best, relation
end

function M.select_combine_contain_duizi(data)
	local function select_one_duizi(info)
		local best_idx = 1
		local best_relation = AI.majiang.extract_one_relation(info[best_idx])
		local result = {{best_idx, best_relation}}
		for i = 2, #info do
			local tmp_relation = AI.majiang.extract_one_relation(info[i])
			local bool1 = select_more_kanzi(info[best_idx], info[i])
			if bool1 == 0 then
				-- equal kanzi
				local bool2 = select_best_relation(best_relation, tmp_relation)
				if bool2 == 0 then
					table.insert(result, {i, tmp_relation})
				elseif bool2 == -1 then
					best_idx = i
					best_relation = tmp_relation
					result = {{best_idx, tmp_relation}}
				end
			elseif bool1 == -1 then
				best_idx = i
				best_relation = tmp_relation
				result = {{best_idx, tmp_relation}}
			end
		end
		-- more best, select max or min path
		if #result > 1 then
			best_idx, best_relation = select_max_min_path(info, result)
		end
		return best_idx, best_relation
	end
	local best_list = {}
	local relation_list = {}
	for _, info in ipairs(data) do
		local idx, r = select_one_duizi(info)
		table.insert(best_list, info[idx])
		table.insert(relation_list, r)
	end
	-- select best duizi
	local best, relation = best_list[1], relation_list[1]
	for i = 2, #best_list do
		local bool1 = select_more_kanzi(best, best_list[i])
		if bool1 == 0 then
			local bool2 = select_best_relation(relation, relation_list[i], true, true)
			if bool2 == -1 then
				best = best_list[i]
				relation = relation_list[i]
			end
		elseif bool1 == -1 then
			best, relation = best_list[i], relation_list[i]
		end
	end
	return best, relation
end

local RELATION_TYPE = {
	A = 0, 
	AC = 1,
	AA = 2,
	AB = 3,
}

-- data1 split with no duizi
-- data2 split with no duizi
-- target min step to 4N + 1
function M.compare_best_combine1(data1, data2, need_out)
	local info1, relation1, len1 = data1.info, data1.relation, data1.len
	local info2, relation2, len2 = data2.info, data2.relation, data2.len
	local num1 = #(info1.path or {}) + #(info1.kezi or {}) + (#relation1.relation_AA > 0 and 1 or 0)
	local num2 = #(info2.path or {}) + #(info2.kezi or {}) + (#relation2.relation_AA > 0 and 1 or 0)
	local step1, step2 = math.ceil(len1 / 3), math.ceil(len2 / 3)
	local need1, need2 = step1 - num1, step2 - num2
	-- print("---->need = ",	need1,	need2)
	if need1 > need2 then
		return false
	elseif need1 < need2 then
		return true
	end
	-- special handle
	if need1 == 1 then
		if need_out then
			-- {15,16,19,19}, {12,13,13,16,16,16,17}, {11, 14, 15, 15, 16, 16, 17}
			if (#relation1.relation_AA > 0) then --and (#relation1.relation_AB > 0 or #relation1.relation_AC > 0) then
				local card = relation1.relation_AA[1]
				for _, v in ipairs(relation1.relation_AB or {}) do
					if v[1] ~= card and v[2] ~= card then
						return true
					end
				end
				for _, v in ipairs(relation1.relation_AC or {}) do
					if v[1] ~= card and v[2] ~= card then
						return true
					end
				end
			end
		end
		if #relation2.relation_AB > 0 or #relation2.relation_AC > 0 then
			return false
		end
	end
	local bool = select_best_relation(relation1, relation2, false, false)
	if need_out and bool ~= -1 then
		return true
	end
	if bool == 1 then
		return true
	end
	return false
end

-- data1 split with duizi
-- data2 split with duizi
-- target min step to 4N + 1
function M.compare_best_combine2(data1, data2, need_out)
	local info1, relation1, len1 = data1.info, data1.relation, data1.len
	local info2, relation2, len2 = data2.info, data2.relation, data2.len
	local num1 = #(info1.path or {}) + #(info1.kezi or {}) + 1
	local num2 = #(info2.path or {}) + #(info2.kezi or {}) + 1  -- +1 means has duizi
	local step1, step2 = math.ceil(len1 / 3), math.ceil(len2 / 3)
	local need1, need2 = step1 - num1, step2 - num2
	-- print("---->need = ",	need1,	need2)
	if need1 > need2 then
		return false
	elseif need1 < need2 then
		return true
	end
	-- special handle
	if need1 == 1 then
		if need_out then	-- todo
			if #relation1.relation_AB > 0 or #relation1.relation_AC > 0 then
				return true
			end
		end
		if #relation2.relation_AB > 0 or #relation2.relation_AC > 0 then
			return false
		end
	end
	local bool = select_best_relation(relation1, relation2, true, true)
	if need_out and bool ~= -1 then
		return true
	end
	if bool == 1 then
		return true
	end
	return false
end

-- data1 split with no duizi
-- data2 split with duizi
-- target min step to 4N + 1
function M.compare_best_combine3(data1, data2, need_out)
	local info1, relation1, len1 = data1.info, data1.relation, data1.len
	local info2, relation2, len2 = data2.info, data2.relation, data2.len
	local num1 = #(info1.path or {}) + #(info1.kezi or {}) + (#relation1.relation_AA > 0 and 1 or 0)
	local num2 = #(info2.path or {}) + #(info2.kezi or {}) + 1  -- +1 means has duizi
	local step1, step2 = math.ceil(len1 / 3), math.ceil(len2 / 3)
	local need1, need2 = step1 - num1, step2 - num2
	-- print("---->need = ",	need1,	need2)
	if need1 > need2 then
		return false
	elseif need1 < need2 then
		return true
	end
	-- special handle
	if need1 == 1 then
		if need_out then
			if (#relation1.relation_AA > 0) then --and (#relation1.relation_AB > 0 or #relation1.relation_AC > 0) then
				local card = relation1.relation_AA[1]
				for _, v in ipairs(relation1.relation_AB or {}) do
					if v[1] ~= card and v[2] ~= card then
						return true
					end
				end
				for _, v in ipairs(relation1.relation_AC or {}) do
					if v[1] ~= card and v[2] ~= card then
						return true
					end
				end
			end
		end
		if #relation2.relation_AB > 0 or #relation2.relation_AC > 0 then
			return false
		end
	end
	local bool = select_best_relation(relation1, relation2, false, true)
	if need_out and bool ~= -1 then
		return true
	end
	if bool == 1 then
		return true
	end
	return false
end

-- data1 split with duizi
-- data2 split with no duizi
-- target min step to 4N + 1
function M.compare_best_combine4(data1, data2, need_out)
	local info1, relation1, len1 = data1.info, data1.relation, data1.len
	local info2, relation2, len2 = data2.info, data2.relation, data2.len
	local num1 = #(info1.path or {}) + #(info1.kezi or {}) + 1  -- +1 means has duizi
	local num2 = #(info2.path or {}) + #(info2.kezi or {}) + (#relation2.relation_AA > 0 and 1 or 0)
	local step1, step2 = math.ceil(len1 / 3), math.ceil(len2 / 3)
	local need1, need2 = step1 - num1, step2 - num2
	-- print("---->need = ",	need1,	need2)
	if need1 > need2 then
		return false
	elseif need1 < need2 then
		return true
	end
	-- special handle
	if need1 == 1 then
		if need_out then	-- todo
			if #relation1.relation_AB > 0 or #relation1.relation_AC > 0 then
				return true
			end
		end
		if #relation2.relation_AB > 0 or #relation2.relation_AC > 0 then
			return false
		end
	end
	local bool = select_best_relation(relation1, relation2, true, false)
	if need_out and bool ~= -1 then
		return true
	end
	if bool == 1 then
		return true
	end
	return false
end

return M