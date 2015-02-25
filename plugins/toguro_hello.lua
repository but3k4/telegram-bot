
local f = io.open('./data/toguro.json', "r+")
if f == nil then
  f = io.open('./data/toguro.json', "w+")
  f:write("{}") -- Write empty table
  f:close()
  _hello = {}
else
  local c = f:read "*a"
  f:close()
  _hello = json:decode(c)
end
 
function get_hello()
  print(_hello[1])
  hello = _hello[math.random(1,#_hello)]
  print(hello)
  return hello
end
 
function run(msg, matches)
  return get_hello()
end
 
return {
    description = "",
    usage = "",
    patterns = {
       	"(.*)Toguro(.*)",
        "(.*)toguro(.*)",
        "(.*)togurera(.*)",
	"(.*)togurão(.*)"
    }, 

    run = run
}
