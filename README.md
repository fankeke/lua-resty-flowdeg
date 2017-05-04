flowdegrade for ngx_lua or OpenResty
====================================

## degrade your flow in Ngx_lua or OpenResty on the fly

## Brife Intro 

This repos is used to DENY or PASS request according to given percent.
For example, If request's percent has been set to 90,then 90% of this request will be deny by Nginx.


eg:
```
server_name/location 		precent
---------------------		-------	
servername1/location1		90
servername2/location2		80
servername3/location3/loc1	100
```

According to above chart, request `servername1/location1` will be droped 90% of it's traffic,and all request prefix with `servername1/location1/*` will has the same effect. 


## simple arch 

  there are two part of this repos: admin and proxy

  admin:  set/get/del degrade policy from/to redis    

  proxy:  pull degrade policy from redis to nginx worker 


## depoly

for proxy node
* nginx.conf 

```
init_worker_by_lua_file "/path/to/flowdeg/init_worker/init_worker.lua"  
access_by_lua_file     "/path/to/flowdeg/access_lua/online_access.lua";
```

for admin node
```
http {
	server {
		server_name "your.admin.com";
		location /deg_admin {
			content_by_lua_file "/path/to/flowdeg/src/admin.lua";
		}
	}
}
```

* NTOTICE!!!
 redis ip should be changed accordingly in file    `/path/to/flowdeg/lib/config.lua`


## API for admin

 a  set degrade policy

    curl "your.admin.com/deg_admin?action=set" -d '{"host":"server1","uri":"/test1","percent":"80"}' 


 b  del policy

    curl "your.adim.com/deg_admin?action=del" -d '{"host":"server1","uri":"test1"}'


