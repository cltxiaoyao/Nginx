ngx.log(ngx.DEBUG, "enter init ")

local _M = {}

--配置信息设置
local config = {}
--path（新环境修改）
config.path_nginx = "/home/besuser/tools/picserver/nginx"

--分割字符串
local function string_split(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end


--从文件读取key和value，放在dic中
local function file_analysis_kv(in_file, dict)
    local file = assert(io.open(in_file, "r"))
    local loop = 0
    while true do
        local line = file:read("*line")
        if line == nil or #line == 0  then break end
        if string.sub(line,1,1) ~= "#"  then 
            line=string.gsub(line,'\t', '')
            line=string.gsub(line,' ', '')
            local l_line = string_split(line,"=")
            local l_key = l_line[1]
            local l_value = l_line[2]
            if l_value == nil then
                ngx.log(ngx.WARN, '[LUA] error input, must be two values per line.')
            else
                local success, err, forcible = dict:set(l_key,l_value)
                if not success then
                    ngx.log(ngx.ERR, '[LUA] nginx dict set error, ', err)
                end
            end
        end    
    end
    file:close()
end


--从文件读取全部内容，放在dic中
local function file_analysis_all(in_file, dict, key)
    local file = assert(io.open(in_file, "r"))
    local l_value = file:read("*all")
    if l_value == nil or #l_value==0 then
        ngx.log(ngx.WARN, '[LUA] error input, must need one value at least.')
    else
        local success, err, forcible = dict:set(key,l_value)
        if not success then
            ngx.log(ngx.ERR, '[LUA] nginx dict set error, ', err)
        end
    end
    file:close()
end


--打开读取并返回文件全部内容
local function read_files( fileName )
    local f = assert(io.open(fileName,"r"))
	local content = f:read("*all")
    if content == nil or #content==0 then
        ngx.log(ngx.WARN, '[LUA] error input, must need one value at least.')
    end
	f:close()
	return content
end


--根据kv，放在dic中
local function analysis_kv(dict, key, value, timeout)
    local success, err, forcible = dict:set(key,value,timeout)
    if not success then
        ngx.log(ngx.ERR, '[LUA] nginx dict set error, ', err)
    end
end





function _M.init_redis_conf(path)
    ngx.shared.redis_config_dict:flush_all();

	--设置字典项：配置信息
	for i,v in pairs(config) do
		analysis_kv(ngx.shared.redis_config_dict, i, v, 0)
	end
	file_analysis_kv(path.."/conf/lua/config.ini" , ngx.shared.redis_config_dict)
end

ngx.log(ngx.DEBUG, "finished init ")

return _M
 



