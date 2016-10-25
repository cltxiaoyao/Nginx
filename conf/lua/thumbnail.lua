
ngx.log(ngx.DEBUG, "ENTER")
local redis = require("redis_instanse")
local cache = redis:get_redis()
local key = "test"
local value = "ces bes ces bes ces bes"
cache:set(key,value)
ngx.log(ngx.DEBUG, "store-------------value: ", cache:get(key))
cache:set_keepalive(3000, 3)










