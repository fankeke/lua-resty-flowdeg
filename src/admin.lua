
local admin = require "flowdeg.lib.admin"
local cjson = require "cjson.safe"

--local ddtab = require "utils.ddlog".ddtab
--local dd = require "utils.ddlog".dd

local read_body     = ngx.req.read_body
local get_body_data = ngx.req.get_body_data 

local args = ngx.req.get_uri_args()

local action = args.action
if not args or not action then
	ngx.status = ngx.HTTP_FORBIDDEN
	return ngx.exit(ngx.status)
end

read_body()
local body = get_body_data()
if not body then
	ngx.status = ngx.HTTP_FORBIDDEN
	return ngx.exit(ngx.status)
end

body = cjson.decode(body)
local host = body.host
local uri = body.uri

if not host or not uri then
	ngx.status = ngx.HTTP_FORBIDDEN
	return ngx.exit(ngx.status)
end

if action == "del" then
	return admin.delete_degrade(host,uri)
end
	
if action == "set" or action == "update" then
	local percent = tonumber(body.percent)
	if not percent or percent < 0 or percent > 100 then
		ngx.status = ngx.HTTP_FORBIDDEN
		return ngx.exit(ngx.status)
	end

	return admin.update_degrade(host,uri,percent)
end


--other action not support for now
ngx.status = ngx.HTTP_FORBIDDEN
return ngx.exit(ngx.status)



--local deg_action={}
--deg_action.set=policy.set
--deg_action.del=policy.del
--deg_action.get=policy.get
--deg_action.switch=policy.switch



