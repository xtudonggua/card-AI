
local M = require "majiang.shunzi"

function M.kezi_remove(info)
	for card, num in pairs(info.remain or {}) do
		if num >= 3 then
			info.kezi = info.kezi or {}
			AI.majiang.sub_stack(info.remain, card)
			AI.majiang.sub_stack(info.remain, card)
			AI.majiang.sub_stack(info.remain, card)
			table.insert(info.kezi, card)
		end
	end
end

return M