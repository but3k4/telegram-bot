
function run(msg, matches)
  return "Chupa minha bengala, " .. matches[1]
end

return {
    description = "Says to someone sucks your dick in portuguese.", 
    usage = "chupa [name]",
    patterns = {
    	"^chupa (.*)$",
    	"^Chupa (.*)$"
    }, 
    run = run 
}

