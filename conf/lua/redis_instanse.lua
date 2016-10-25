
 ngx.log(ngx.DEBUG, "enter redis_redis_instanse.lua")
 local _M = {}
 
 
 --分割字符串
local function string_split(s, p)
    local rt= {}
    string.gsub(s, "[^"..p.."]+", function(w) table.insert(rt, w) end )
    return rt
end

--获取缓存链接实例
function _M.get_redis_instanse()
    -- body

    ngx.log(ngx.DEBUG,"enter get_redis_instanse ")         

    local redis_config_dict = ngx.shared.redis_config_dict
    local redis_server_info = redis_config_dict:get("redis_server_info")
    local redis_switch = redis_config_dict:get("redis_switch")
    local redis_timeout = redis_config_dict:get("redis_timeout")
    local redis_max_idle_timeout = redis_config_dict:get("redis_max_idle_timeout")
    local redis_pool_size = redis_config_dict:get("redis_pool_size")
    local redis_prefix = redis_config_dict:get("redis_prefix")
    local redis_separator = redis_config_dict:get("redis_separator")
    
    local redis = require "resty.redis"  
    local cache = redis.new()  
    --cache:set_timeout(redis_timeout) 
    --session缓存失效时间30s
    cache:set_timeout(30000) 

    local connect_sucess = "N"

    --判断redis链接信息是否满足要求
    if redis_server_info and #redis_server_info >0 then
        for i,redis_connect in pairs(string_split(redis_server_info,";")) do
            redis_connect=string.gsub(redis_connect,"\t", "")
            redis_connect=string.gsub(redis_connect," ", "")
            
            local l_redis_connect = string_split(redis_connect,":")
            local l_ip = l_redis_connect[1]
            local l_port = l_redis_connect[2]
            
            if l_ip and l_port then 
                --建立redis链接
                local ok, err = cache.connect(cache, l_ip, l_port)  
                if not ok then
                    ngx.log(ngx.WARN, "[LUA] failed to connect redis: ", err)
                end
                
                --[[
                --有redis密码配置的需要鉴权
                local l_password = l_redis_connect[3]
                if l_password then
                    --redis鉴权
                    local res, err = cache:auth(l_password)
                    if not res then
                        ngx.log(ngx.WARN, "[LUA] failed to authenticate: ", err)
                    end
                    
                    if ok and res then
                        connect_sucess = "Y";
                        ngx.log(ngx.DEBUG,"--------------------connected redis and authenticated:"..l_ip..":"..l_port)
                        break
                    end
                else
                    if ok then
                        connect_sucess = "Y";
                        ngx.log(ngx.DEBUG,"--------------------connected redis:"..l_ip..":"..l_port)
                        break
                    end
                end
                --]]
                --不需要鉴权
                if ok then
                    connect_sucess = "Y";
                    ngx.log(ngx.DEBUG,"--------------------connected redis:"..l_ip..":"..l_port)
                    break
                end
                
            else
               ngx.log(ngx.WARN, "[LUA] error input, redis_server_info must need ip and port. ") 
            end
        end
    else
        ngx.log(ngx.WARN, "[LUA] redis_server_info is unavailable. ")
    end

    --判断redis链接是否成功
    if connect_sucess == "Y" then
		 ngx.log(ngx.DEBUG,"redis connect success")
        return cache
    else
        cache:set_keepalive(redis_max_idle_timeout, redis_pool_size)
        return "false"  
    end
end
return _M










