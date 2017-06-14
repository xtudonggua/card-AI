
function string.split(str, delimiter)
	str = tostring(str)
	delimiter = tostring(delimiter)
	if (delimiter == '') then return false end
	local pos, arr = 1, {}
	for st, sp in function () return string.find(str, delimiter, pos, 1, true) end do
		-- print("st, sp", st, sp)
		table.insert(arr, string.sub(str, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(str, pos))
	return arr
end

function string.trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end