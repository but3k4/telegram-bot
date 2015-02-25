
local f = io.open('./data/lala.json', "r+")
if f == nil then
  f = io.open('./data/lala.json', "w+")
  f:write("{}") -- Write empty table
  f:close()
  _lala = {}
else
  local c = f:read "*a"
  f:close()
  _lala = json:decode(c)
end
 
function get_lala()
  print(_lala[1])
  lala = _lala[math.random(1,#_lala)]
  print(lala)
  return lala
end
 
function run(msg, matches)
  return get_lala()
end
 
return {
    description = "",
    usage = "",
    patterns = {
       	"(.*)lala(.*)",
        "(.*)Lala(.*)",
        "(.*)LALA(.*)"
    }, 

    run = run
}
