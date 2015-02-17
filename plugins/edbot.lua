
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

    local body = funcs.encode_table(params)
    local response = {}

    ok, code, headers, status = http.request ({
        method = "POST",
        url = "http://www.ed.conpet.gov.br/mod_perl/bot_gateway.cgi",
        headers = {
            ["content-type"] = "application/x-www-form-urlencoded",
            ["content-length"] = tostring(#body),
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response)
    })

    if code ~= 200 then
	return "Error: " .. status:gsub('HTTP/1.1', ''):gsub('^ ', '')
    end

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
