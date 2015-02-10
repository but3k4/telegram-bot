
local http = require("socket.http")
local string = require("string")
local ltn12 = require ("ltn12")
local funcs = (loadfile "./libs/functions.lua")()

local function edbot(msg)
    local params = {
        ['server'] = '0.0.0.0:8085',
        ['charset_post'] = "utf-8",
        ['charset'] = 'utf-8',
        ['pure'] = 1,
        ['js'] = 0,
        ['tst'] = 1,
        ['msg'] = tostring(msg),
    }
    
    local data = funcs.encode_table(params)
    local response = {}

    r, c, h = http.request ({
        method = "POST",
        url = "http://www.ed.conpet.gov.br/mod_perl/bot_gateway.cgi",
        headers = {
            ["content-type"] = "application/x-www-form-urlencoded",
            ["content-length"] = string.len(data),
        },
        source = ltn12.source.string(data),
        sink = ltn12.sink.table(response)
    })
    
    if response[1] ~= nil then
        return tostring(response[1]):gsub('<[^<>]*>', ''):gsub('\n', ''):gsub('<a href="#', '')
    end
end

function run(msg, matches)
    return edbot(matches[1])
end

return {
    description = "Edbot plugin", 
    usage = "Me explica: subject or math expression.",
    patterns = {
        "^[Mm]e explica: (.*)$",
    }, 
    run = run 
}
