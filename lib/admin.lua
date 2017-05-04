
local redis  = require "flowdeg.lib.resty.redis"
local config = require "flowdeg.lib.config"


local _M = {}

--TODO implement fetch redis instance
local fetch_redis = function()

end

--TODO return more clear msg to user
_M.update_degrade = function(host,uri,percent)
	local red = redis:new()
	local red_conf = config.redis

	red:set_timeout(red_conf.timeout or 1000)
	local ok, err = red:connect(red_conf.ip, red_conf.port)
	if not ok then
		ngx.log(ngx.ERR,"faild to connect redis: ",err)
		return ngx.exit(403)
	end

	local deg_key = host .. config.degrade.degrade_concat_sign .. uri
	local ok, err = red:set(deg_key, percent)
	if not ok then
		ngx.log(ngx.ERR,"faild to set redis: ",err)
		return ngx.exit(403)
	end

	return ngx.say("success")
end


_M.delete_degrade = function(host,uri)
	local red = redis:new()
	local red_conf = config.redis

	red:set_timeout(red_conf.timeout or 1000)
	local ok, err = red:connect(red_conf.ip, red_conf.port)
	if not ok then
		ngx.log(ngx.ERR,"faild to connect redis: ",err)
		return ngx.exit(403)
	end

	local deg_key = host .. config.degrade.degrade_concat_sign .. uri
	local ok, err = red:del(deg_key, percent)
	if not ok then
		ngx.log(ngx.ERR,"faild to del redis: ",err)
		return ngx.exit(403)
	end

	return ngx.say("success")

end


return _M
