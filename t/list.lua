
local degrade  = require "flowdeg.lib.degrade"


if next(degrade.deg_data) == nil then
	ngx.say("empty data")
	return
end

for k,v in pairs(degrade.deg_data) do
	ngx.say(k,"\t",v)
end


