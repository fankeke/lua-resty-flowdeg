
local degrade = require "flowdeg.lib.degrade"
local utils   = require "flowdeg.lib.utils"
local config  = require "flowdeg.lib.config"

--local ddtab   = require "utils.ddlog".ddtab
--local dd   	  = require "utils.ddlog".dd

local raw_uri = utils.raw_uri
local deg_switch = config.degrade.degrade_switch

if degrade.deg_data[deg_switch] ~= "on" then
	ngx.log(ngx.INFO,"flowdegrade switch not on")
	return
end

local host = ngx.var.host
local uri  = raw_uri()

if not host or not uri then
	ngx.log(ngx.ERR,"not found host or uri")
	return
end

degrade.flow_degrade(host,uri)


