print("into session_store")

local redis = require("redis_instanse")

local ngx_ssl_session = require "ngx.ssl.session" 

local session, err = ngx_ssl_session.get_serialized_session() 
if err then 
    ngx.log(ngx.ERR, "failed to retrieve new SSL session: ", err) 
    return 
end 

local key, err = ngx_ssl_session.get_session_id() 
if not key then 
    ngx.log(ngx.ERR, "failed to get SSL session ID: ", key) 
    return 
end 

local shm_store = ngx.shared.ssl_sessions 

local ok, err = shm_store:set(key, session) 
if not ok then 
    ngx.log(ngx.ERR, "failed to set SSL session to shm: ", err) 
end 

local function async_store_handler(premature, key, session, ttl) 
    -- TODO
    -- local ok, err = my_store_to_memcached(key, session, ttl) 
    -- if not ok then 
    --     ngx.log(ngx.ERR, "failed to store the SSL session to ", 
    --             "memcached: ", err) 
    --    return 
    -- end 
	
	ngx.log(ngx.DEBUG, "store-------------key: ", key) 
	cache = redis:get_redis()
	cache:set(key,session)
	ngx.log(ngx.DEBUG, "store-------------value: ", cache:get(key))
	cache:set_keepalive(3000, 3)
	
end 

local ttl = 30000
local ok, err = ngx.timer.at(0, async_store_handler, key, session, ttl) 
if not ok then 
    ngx.log(ngx.ERR, "failed to create a 0-delay timer: ", err) 
    return 
end 