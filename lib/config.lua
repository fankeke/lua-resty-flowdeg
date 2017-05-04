
local _M  = {}

_M.degrade = {
	--admin to turn on/off degrade
	degrade_switch = "degrade_switch",

	--timer execute peroid
	degrade_delay = 3,

	--conat sign between host and uri
	degrade_concat_sign = ":",
}

_M.redis = {
	ip = "127.0.0.1",
	port = 6379,

}


return _M
