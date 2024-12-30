file.CreateDir("homigrad/sdata")

function SData_Get(name)
	return file.Read("homigrad/sdata/" .. name .. ".txt", "DATA") or ""
end

function SData_Set(name, value)
	return file.Write("homigrad/sdata/" .. name .. ".txt", value) or ""
end