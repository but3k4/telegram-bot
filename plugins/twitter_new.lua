
local OAuth = require "OAuth"
local funcs = (loadfile "./libs/functions.lua")()
local infos = funcs.readfile('etc/twitter.conf')

function twitter_auth()
    local consumer_key = infos['consumer_key']
    local consumer_secret = infos['consumer_secret']
    local oauth_token = infos['oauth_token']
    local oauth_token_secret = infos['oauth_token_secret']
    
    local client = OAuth.new(consumer_key, consumer_secret, {
        RequestToken = "https://api.twitter.com/oauth/request_token", 
        AuthorizeUser = {"https://api.twitter.com/oauth/authorize", method = "GET"},
        AccessToken = "https://api.twitter.com/oauth/access_token"
    }, {
        OAuthToken = oauth_token,
        OAuthTokenSecret = oauth_token_secret
    })
    return client
end

function show_friends()
    local client = twitter_auth()
    local url = "https://api.twitter.com/1.1/friends/list.json"
    local r, h, s, b = client:PerformRequest("GET", url, { user_id = infos['twitter_name'], count = 200 })
    
    if r ~= 200 then
        print("Error: " .. s:gsub('HTTP/1.1', ''):gsub('^ ', ''))
        return nil
    end
    
    local result = json:decode(b)
    local friends = ""

    if type(result['users']) == 'table' and #result['users'] > 0 then
        for i = 1, #result['users'] do
            friends = friends .. ", " .. result['users'][i].screen_name
        end
        return "Following: " .. friends:sub(3)
    end
    return nil
end

function show_followers()
    local client = twitter_auth()
    local url = "https://api.twitter.com/1.1/followers/list.json"
    local r, h, s, b = client:PerformRequest("GET", url, { user_id = infos['twitter_name'] })
    
    if r ~= 200 then
        print("Error: " .. s:gsub('HTTP/1.1', ''):gsub('^ ', ''))
        return nil
    end
    
    local result = json:decode(b)
    local followers = ""

    if type(result['users']) == 'table' and #result['users'] > 0 then
        for i = 1, #result['users'] do
            followers = followers .. ", " .. result['users'][i].screen_name
        end
        return "Followers: " .. followers:sub(3)
    end
    return nil
end

function show_userinfo(user)
    local client = twitter_auth()
    local url = "https://api.twitter.com/1.1/users/show.json"
    local r, h, s, b = client:PerformRequest("GET", url, { screen_name = user })
    
    if r ~= 200 then
        print("Error: " .. s:gsub('HTTP/1.1', ''):gsub('^ ', ''))
        return nil
    end
    
    local result = json:decode(b)
    local infos = {}

    if type(result) == 'table' then
        infos['id'] = result.id
        infos['login'] = result.screen_name
        infos['name'] = result.name
        infos['location'] = result.location
        infos['account_date'] = result.created_at
        infos['following'] = result.following
    end
    return infos
end

function post_msg(text)
    local client = twitter_auth()
    local url = "https://api.twitter.com/1.1/statuses/update.json"
    local r, h, s, b = client:PerformRequest("POST", url, { status = text })
    
    if r ~= 200 then
        print("Error: " .. s:gsub('HTTP/1.1', ''):gsub('^ ', ''))
        return nil
    else
        return ("The message has been published successfully")
    end
    return nil
end

function follow(user)
    if show_userinfo(user).following ~= false then
        return ("I'm already following the user " .. user)
    end

    local client = twitter_auth()
    local url = "https://api.twitter.com/1.1/friendships/create.json"
    local r, h, s, b = client:PerformRequest("POST", url, { screen_name = user, follow = true })
    
    if r ~= 200 then
        print("Error: " .. s:gsub('HTTP/1.1', ''):gsub('^ ', ''))
        return nil
    end
    
    local result = json:decode(b)

    if type(result) == 'table' then
        if show_userinfo(user).following ~= false then
            return ("Now I'm following the user " .. result.screen_name)
	end
    end
    return nil
end

function unfollow(user)
    if show_userinfo(user).following ~= true then
        return ("I'm not following the user " .. user)
    end

    local client = twitter_auth()
    local url = "https://api.twitter.com/1.1/friendships/destroy.json"
    local r, h, s, b = client:PerformRequest("POST", url, { screen_name = user })
    
    if r ~= 200 then
        print("Error: " .. s:gsub('HTTP/1.1', ''):gsub('^ ', ''))
        return nil
    end
    
    local result = json:decode(b)

    if type(result) == 'table' then
        if show_userinfo(user).following ~= true then
            return "I'm not following the user " .. result.screen_name .. " anymore"
	end
    end
    return nil
end

function random_image(msg)
    local client = twitter_auth()
    local url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    local r, h, s, b = client:PerformRequest("GET", url, { user_id = infos['twitter_name'], include_entities = true })
    
    if r ~= 200 then
        print("Error: " .. s:gsub('HTTP/1.1', ''):gsub('^ ', ''))
        return nil
    end
    
    local result = json:decode(b)
    local images = {}

    for k, v in pairs(result) do
        if type(result[k].entities.media) == 'table' then
            table.insert(images, result[k].entities.media[1].media_url)
        end
    end
    
    if #images > 0 then
        math.randomseed(os.time())
        local receiver = get_receiver(msg)
        local url = images[math.random(#images)]
        local file_path = download_to_file(url)
        send_photo(receiver, file_path, ok_cb, false)
    end
    return nil
end

local function run(msg, matches)
    if matches[1] == "show" then
        if matches[2] == "friends" then
            return show_friends()
        elseif matches[2] == "followers" then
            return show_followers()
        elseif matches[2] == "image" then
            return random_image(msg)
        end
    elseif matches[1] == "follow" and is_sudo(msg) then
        return follow(matches[2])
    elseif matches[1] == "unfollow" and is_sudo(msg) then
        return unfollow(matches[2])
    elseif matches[1] == "send" and is_sudo(msg) then
        return post_msg(matches[2])
    elseif matches[1] == "info" then
        result = show_userinfo(matches[2])
        if type(result) == 'table' then
            text = ""
            for k, v in pairs(result) do
                text = text .. "" .. k .. ": " .. tostring(v) .. ", "
            end
            return text:sub(1, -3)
        end
    end
end

return {
    description = "Telegram twitter module", 
    usage = {
      "!twitter show [friends|followers|image]",
      "!twitter [follow|unfollow] [user]",
      "!twitter send [msg]",
      "!twitter info [user]" },
    patterns = {
      "^!twitter (%a+) (.*)$",
    }, 
    run = run 
}
