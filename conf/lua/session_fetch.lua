print("into session_fetch")

local redis = require("redis_instanse")

local ngx_ssl_session = require "ngx.ssl.session" 
--print("ngx_ssl_session print begin ... ")
--print_lua_table(ngx_ssl_session,0)
--print("ngx_ssl_session print end")

local key, err = ngx_ssl_session.get_session_id() 
print("key" .. key)
if not key then 
   ngx.log(ngx.ERR, "failed to get SSL session ID: ", key) 
return 
end 

local shm_store = ngx.shared.ssl_sessions 
--print_lua_table(shm_store,0)

local session = shm_store:get(key) 
print("session" .. session)

if not session then 
   -- TODO 获取失败从memcache中查询           
   --session = my_fetch_from_memcached(key) 
	cache = redis:get_redis()
	session = cache:get(key)
	cache:set_keepalive(3000, 3)
end 

cache = redis:get_redis()
local session2 = cache:get(key)

if session == session2 then 
  print("----------is OK!")
end

if session then 
  print("if session == true" )        
  local ok, err = ngx_ssl_session.set_serialized_session(session) 
   if not ok then 
      ngx.log(ngx.ERR, "failed to set cached SSL session: ", err) 
      return 
   end 
 end 


---------------------------------------------------------
 function print_lua_table (lua_table, indent)
    if lua_table == nil or type(lua_table) ~= "table" then
        return
    end

    local function print_func(str)
        XLPrint("[Dongyuxxx] " .. tostring(str))
    end
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print_func(formatting)
            print_lua_table(v, indent + 1)
            print_func(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print_func(formatting..szValue..",")
        end
    end
end
