
function imdb(movie)
    local http = require("socket.http")
    http.TIMEOUT = 5

    movie = movie:gsub(' ', '+')
    url = "http://www.imdbapi.com/?t=" .. movie
    r, c, h = http.request(url)

    if c ~= 200 then
        return nil
    end

    if #r > 0 then
        r = json:decode(r)
        r['Url'] = "http://imdb.com/title/" .. r.imdbID
        t = ""
        for k, v in pairs(r) do t = t .. k .. ": " .. v .. ", " end
    end
    return t:sub(1, -3)
end

function run(msg, matches)
    return imdb(matches[1])
end

return {
    description = "Imdb plugin",
    usage = "!imdb [movie]",
    patterns = {"^!imdb (.*)"},
    run = run
}
