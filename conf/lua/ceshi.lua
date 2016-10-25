local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(3000) -- 1 sec
print("connect redis start")	

local ok, err = red:connect("10.171.122.122", 6379)
print("connect redis end")
if not ok then
	ngx.say("failed to connect: ", err)
	return
end

ok, err = red:set("dog", "an animal")
if not ok then
	ngx.say("failed to set dog: ", err)
	return
end