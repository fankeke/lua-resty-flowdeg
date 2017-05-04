
local _M = {}

_M.raw_uri = function()
	local raw_uri = ngx.var.request_uri
	return raw_uri:gsub("?.*","")
end


_M.string_split = function(input,sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}; i = 1

	for str in string.gmatch(input,"([^" .. sep .. "]+)") do
		t[i] = str
		i = i+1
	end

	return t
end


return _M
