
function run(msg, matches)
  return matches[1]
end

return {
    description = "echoes the msg", 
    usage = "!fala [whatever]",
    patterns = {"^!fala (.*)$"}, 
    run = run 
}

