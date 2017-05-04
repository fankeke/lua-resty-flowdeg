
local config   = require "flowdeg.lib.config" 
local redis    = require "flowdeg.lib.resty.redis"
local utils    = require "flowdeg.lib.utils"

--local dd    = require "utils.ddlog".dd
--local ddtab = require "utils.ddlog".ddtab

local _M={
	_VERSION="0.01"
}

local deg_data = {}
_M.deg_data = deg_data


local degrade_sync_handler
degrade_sync_handler = function(premature)

	if premature then	
		ngx.log(ngx.INFO,"worker is existing...")
		return
	end

	local delay = config.degrade.degrade_delay or 5

	local ok,err = ngx.timer.at(delay, degrade_sync_handler)
	if not ok then
		ngx.log(ngx.ERR,"faild to create time in diversion sync handler:",err)
		return
	end


	local red_conf = config.redis
	local red = redis:new()

	red:set_timeout(red_conf.timeout or 1000)

	local ok, err = red:connect(red_conf.ip,red_conf.port)
	if not ok then
		ngx.log(ngx.ERR,"faild to connect redis: ",err)
		return
	end

	local deg_keys, err = red:keys('*')
	if not deg_keys then
		ngx.log(ngx.ERR,"degrade syn file `keys` command: ",err)
		return										--save the last time data
	end

	-- avoid yielding in cosocket process,store new data in tmp
	local tmp_degrade_data = {}

	for i = 1,#deg_keys do
		local value,err = red:get(deg_keys[i])
		if not value then
			ngx.log(ngx.ERR,"degrade sync `get` command:",err,"key:",key)
			return    
		end

		ngx.log(ngx.DEBUG,"key:",deg_keys[i],"value:",value)

		tmp_degrade_data[deg_keys[i]] = value 	
	end
	
	--TODO set_keepalive


	--Don't worry race condition because there is no yeilding opreation
	for k,v in pairs (deg_data) do --TODO find grace way to clear ...
		deg_data[k] = nil
	end
	for k,v in pairs(tmp_degrade_data) do
		deg_data[k] = v
	end

end


_M.create_degrade_sync = function()

	--all worker do update timer
	local delay = config.degrade.degrade_delay or 5 
	local ok,err = ngx.timer.at(delay, degrade_sync_handler)
	if not ok then
		ngx.log(ngx.ERR,"faild to create degrade timer: ",err)
		return
	end
	ngx.log(ngx.INFO,"success create diversion timer ok")

end


local flowdeg_fetch_percent = function(host,uri)

	local concat_sign = config.degrade.degrade_concat_sign
	local deg_key, percent

	deg_key = host .. concat_sign .. "/" 
	percent = deg_data[deg_key]
	if percent then
		return percent
	end

	deg_key = host .. concat_sign  --remote last "/"

	local deg_keys = utils.string_split(uri,"/")
	for _, value in ipairs(deg_keys) do
		deg_key = deg_key .. "/" .. value

		ngx.log(ngx.DEBUG,"deg_key: ",deg_key)

		percent = deg_data[deg_key]
		if percent then
			return percent
		end
	end

	return nil
end


_M.flow_degrade = function(host,uri)

	local percent = flowdeg_fetch_percent(host,uri)

	if not percent then
		ngx.log(ngx.DEBUG,"not find percent,passed")
		return
	end

	percent = tonumber(percent) 
	math.randomseed(ngx.time())
	local random = math.random(100)

	if random <= percent then
		--TODO more clear response
		return ngx.exit(403)
	end

end

	
return _M


