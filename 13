--[[
  Shared Information + Config layout (from basefentilayout.txt).
  Load options (first match wins in game scripts):
    • getgenv().FENTI_INFOCONFIG_APPLY = function(opts) ... end  (preloaded apply)
    • getgenv().FENTI_INFOCONFIG_SOURCE = [[ entire contents of this file ]]  (paste when readfile fails)
    • getgenv().FENTI_INFOCONFIG_URL = "https://.../fenti_InfoConfig_shared.lua"
    • readfile("fenti_InfoConfig_shared.lua") from executor workspace
--]]

return function(opts)
    assert(type(opts) == "table", "fenti_InfoConfig_shared: opts table required")
    assert(opts.Window and opts.Library and opts.Tabs, "fenti_InfoConfig_shared: opts.Window, opts.Library, opts.Tabs required")
    assert(opts.Tabs.Information and opts.Tabs.Config, "fenti_InfoConfig_shared: Tabs.Information and Tabs.Config required")

    local Window = opts.Window
    local Library = opts.Library
    local ThemeManager = opts.ThemeManager
    local SaveManager = opts.SaveManager
    local Tabs = opts.Tabs

    local Options = Library.Options
    local Toggles = Library.Toggles

    local DISCORD_WEBHOOK_URL = opts.DISCORD_WEBHOOK_URL
        or "https://discord.com/api/webhooks/1505301322755346623/uTWZXEpndZRd-TLzgmKl6liIX3CFAGIBWpldvWs5gitTtHt7Xk7nrT6LL5mqTbl3dl6B"
    local WEBHOOK_URL = DISCORD_WEBHOOK_URL
    local DISCORD_LINK = opts.DISCORD_LINK or "https://discord.gg/XXXXXXX"
    local TELEGRAM_LINK = opts.TELEGRAM_LINK or "https://t.me/XXXXXXX"
    local ICON_ASSET_ID = opts.ICON_ASSET_ID or "rbxassetid://119322103775095"
    local LUARMOR_PROJECT_ID_FREE = opts.LUARMOR_PROJECT_ID_FREE or "299b0d4640fb71dc5c7bda45dcc097f6"
    local LUARMOR_PROJECT_ID_PAID = opts.LUARMOR_PROJECT_ID_PAID or "96bf9f10ae76b538fb8aa5c368129d41"
    local LUARMOR_FREE_PUBLIC = opts.LUARMOR_FREE_PUBLIC == true
    local LUARMOR_SCRIPT_ID = opts.LUARMOR_SCRIPT_ID or ""
    local SCRIPT_HUB = opts.SCRIPT_HUB or { "AOTR scripts", "Bizarre Lineage", "fentibw", "fentiprem" }
    local saveFolder = opts.saveFolder or "fenti"
    local themeFolder = opts.themeFolder or "fenti"
    local extraIgnoreIndexes = opts.extraIgnoreIndexes or {}
    local beforeUnload = opts.beforeUnload


-- ================================================

-- Wrap text in a hex colour
local function c(text, hex)
    return ('<font color="%s">%s</font>'):format(hex, tostring(text or ""))
end
-- Bold
local function b(text) return "<b>" .. tostring(text or "") .. "</b>" end
-- Dim grey for label keys
local function dim(text) return c(text, "#787878") end
-- Bright white for values
local function bright(text) return c(b(text), "#ffffff") end

-- Enable RichText on a label returned by AddLabel and return it
local function RL(labelObj)
    if labelObj and labelObj.Label then
        labelObj.Label.RichText = true
    end
    return labelObj
end

-- Shortcut: add a RichText label to a groupbox
local function RTLabel(groupbox, text, doesWrap)
    return RL(groupbox:AddLabel(text, doesWrap ~= false))
end

-- Colour palette
local K = {
    Green    = "#5dde7a",   -- free / working / yes
    Peach    = "#ffb49a",   -- premium tier
    Gold     = "#ffd04e",   -- expiry / highlights
    Lavender = "#c4b0ff",   -- luarmor / executor
    Sky      = "#6ec8ff",   -- game name
    Red      = "#ff5c5c",   -- risky / bug
    Muted    = "#787878",   -- secondary / dim keys
    White    = "#ffffff",   -- bold values
}

-- ================================================
--  TITLE ANIMATION
-- ================================================

local BaseName    = "fenti"
local GlitchChars = { "@", "/", "£", "$", "#", "!", "&", "%" }
local TitleActive = true

local function RandChar()
    return GlitchChars[math.random(1, #GlitchChars)]
end

local function BuildTitle(revealed)
    local t = {}
    for i = 1, #BaseName do
        t[i] = (i <= revealed) and BaseName:sub(i, i) or RandChar()
    end
    return table.concat(t)
end

local function BuildTitleEncode(keepTo)
    local t = {}
    for i = 1, #BaseName do
        t[i] = (i < keepTo) and BaseName:sub(i, i) or RandChar()
    end
    return table.concat(t)
end

-- ================================================
--  EXECUTOR DETECTION  (name only, no version)
-- ================================================

local function GetExecutor()
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name then
            return tostring(name):match("^([^%s%(]+)") or tostring(name)
        end
    end
    if syn and syn.request then
        return "Synapse X"
    end
    if KRNL_LOADED then
        return "KRNL"
    end
    local g = getgenv and getgenv()
    if type(g) == "table" then
        if g.is_sirhurt_closure then
            return "Sirhurt"
        end
        if g.Fluxus then
            return "Fluxus"
        end
        if g.DELTA_LOADED then
            return "Delta"
        end
        if g.solara then
            return "Solara"
        end
        if g.wave then
            return "Wave"
        end
        if g.hydrogen then
            return "Hydrogen"
        end
        if g.macsploit then
            return "MacSploit"
        end
    end
    return "Unknown"
end
-- ================================================
--  LUARMOR RUNTIME (official variable names)
--  https://docs.luarmor.net/luarmor-user-manual-and-f.a.q
--  LRM_IsUserPremium, LRM_LinkedDiscordID, LRM_SecondsLeft, etc.
-- ================================================

-- Luarmor often injects LRM_* via getgenv() __index; rawget() misses those.
local function lrmVar(name)
    local g = getgenv and getgenv() or nil
    if g then
        local ok, v = pcall(function()
            return g[name]
        end)
        if ok then
            if v ~= nil then
                return v
            end
        end
        local r = rawget(g, name)
        if r ~= nil then
            return r
        end
    end
    local okg, gv = pcall(function()
        return _G[name]
    end)
    if okg then
        return gv
    end
    return rawget(_G, name)
end

local function getScriptKey()
    local g = getgenv and getgenv()
    if g then
        local k = g.script_key
        if type(k) == "string" and k ~= "" then
            return k
        end
    end
    if type(_G.script_key) == "string" and _G.script_key ~= "" then
        return _G.script_key
    end
    local ok, k2 = pcall(function()
        return script_key
    end)
    if ok and type(k2) == "string" and k2 ~= "" then
        return k2
    end
    return nil
end

local function formatExpiry()
    local legacy = lrmVar("LUARMOR_KEY_EXPIRY")
    if type(legacy) == "string" and legacy ~= "" then
        return legacy
    end
    local s = lrmVar("LRM_SecondsLeft")
    if s == nil then
        return "N/A"
    end
    if type(s) ~= "number" then
        return tostring(s)
    end
    if s ~= s or s == math.huge or s > 1e20 then
        return "No expiry set"
    end
    if s <= 0 then
        return "Expired"
    end
    local d = math.floor(s / 86400)
    local h = math.floor((s % 86400) / 3600)
    local m = math.floor((s % 3600) / 60)
    if d > 0 then
        return string.format("%dd %dh left", d, h)
    end
    if h > 0 then
        return string.format("%dh %dm left", h, m)
    end
    return string.format("%dm left", m)
end

local function formatAuthExpireUnix(authExpire)
    if authExpire == nil then
        return nil
    end
    if type(authExpire) ~= "number" then
        return tostring(authExpire)
    end
    if authExpire <= 0 or authExpire == -1 then
        return "Lifetime"
    end
    local left = authExpire - os.time()
    if left <= 0 then
        return "Expired"
    end
    local d = math.floor(left / 86400)
    local h = math.floor((left % 86400) / 3600)
    local m = math.floor((left % 3600) / 60)
    if d > 0 then
        return string.format("%dd %dh left", d, h)
    end
    if h > 0 then
        return string.format("%dh %dm left", h, m)
    end
    return string.format("%dm left", m)
end

local premiumLrm = lrmVar("LRM_IsUserPremium")
local premiumLegacy = lrmVar("LUARMOR_PREMIUM")
local isPremium = (premiumLrm == true)
    or (premiumLrm == 1)
    or (typeof(premiumLegacy) == "boolean" and premiumLegacy == true)

local discordLrm = lrmVar("LRM_LinkedDiscordID")
local discordLegacy = lrmVar("LUARMOR_DISCORD_USER")
local discordUser = discordLrm
if discordUser == nil and discordLegacy ~= nil then
    discordUser = discordLegacy
end

local keyExpiry = formatExpiry()
local luarmorKey = lrmVar("LUARMOR_KEY")
if type(luarmorKey) ~= "string" or luarmorKey == "" then
    luarmorKey = getScriptKey()
end

local isLinked = false
if discordUser ~= nil then
    local ds = tostring(discordUser)
    isLinked = ds ~= "" and ds ~= "0" and ds ~= "nil"
end

-- Optional: Luarmor SDK key check (skipped when LUARMOR_FREE_PUBLIC or no script_key).
local luarmorApiHint = nil
do
    if LUARMOR_FREE_PUBLIC then
        -- Free/public build: users have no key; rely on LRM_IsUserPremium etc. only.
    else
    local sid = LUARMOR_SCRIPT_ID
    if type(sid) == "string" then
        sid = sid:gsub("%s+", "")
    end
    if sid and sid ~= "" then
        local sk = getScriptKey()
        if sk then
            local okLib, lib = pcall(function()
                return loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
            end)
            if okLib and type(lib) == "table" then
                lib.script_id = sid
                local okChk, status = pcall(function()
                    return lib.check_key(sk)
                end)
                if okChk and type(status) == "table" and status.code then
                    if status.code == "KEY_VALID" and type(status.data) == "table" then
                        isPremium = true
                        local ae = status.data.auth_expire
                        local fe = formatAuthExpireUnix(ae)
                        if fe then
                            keyExpiry = fe
                        end
                    else
                        luarmorApiHint = tostring(status.code)
                            .. (status.message and (": " .. tostring(status.message)) or "")
                    end
                end
            end
        end
    end
    end
end
-- ================================================
--  SERVICES & LOCALS
-- ================================================

local Players       = game:GetService("Players")
local MarketService = game:GetService("MarketplaceService")
local HttpService   = game:GetService("HttpService")
local RunService    = game:GetService("RunService")
local LocalPlayer   = Players.LocalPlayer

local PlaceId    = game.PlaceId
local PlaceName  = "Unknown"
pcall(function()
    PlaceName = MarketService:GetProductInfo(PlaceId).Name
end)
local executorName = GetExecutor()

-- Elapsed time since this script started (Info tab → Game Info → Session time).
local fentiSessionStart = tick()

local function formatSessionElapsed(sec)
    sec = math.floor(math.max(0, sec))
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    if h > 0 then
        return string.format("%dh %02dm %02ds", h, m, s)
    end
    if m > 0 then
        return string.format("%dm %02ds", m, s)
    end
    return string.format("%ds", s)
end

-- Client scripts cannot use HttpService:PostAsync (server-only). Use executor HTTP, then Luarmor, then HttpService.
local function postJsonWebhook(url, jsonBody)
    local headers = {
        ["Content-Type"] = "application/json",
        ["User-Agent"]  = "Mozilla/5.0 (compatible; fenti)",
    }
    if syn and syn.request then
        local r = syn.request({
            Url     = url,
            Method  = "POST",
            Headers = headers,
            Body    = jsonBody,
        })
        local sc = r.StatusCode or r.status
        if sc and sc >= 200 and sc < 300 then
            return true
        end
        if r.Success == true then
            return true
        end
        return false, "syn.request HTTP " .. tostring(sc)
    end
    local g = getgenv and getgenv() or {}
    local req = g.http_request or g.request or rawget(g, "http_request")
    if type(req) ~= "function" then
        req = http_request or request
    end
    if type(req) == "function" then
        local ok, res = pcall(req, {
            Url     = url,
            Method  = "POST",
            Headers = headers,
            Body    = jsonBody,
        })
        if not ok then
            return false, tostring(res)
        end
        if type(res) == "table" then
            local sc = res.StatusCode or res.statusCode or res.code
            if sc and sc >= 200 and sc < 300 then
                return true
            end
            if res.Success == true or res.success == true then
                return true
            end
        end
        return true
    end
    return pcall(function()
        HttpService:PostAsync(url, jsonBody, Enum.HttpContentType.ApplicationJson)
    end)
end

local function copyToClipboard(text)
    local ok = pcall(function()
        if type(setclipboard) == "function" then
            setclipboard(text)
            return
        end
        if type(toclipboard) == "function" then
            toclipboard(text)
            return
        end
        local g = getgenv and getgenv() or {}
        if type(g.setclipboard) == "function" then
            g.setclipboard(text)
            return
        end
        error("no clipboard")
    end)
    return ok
end

local function getTeleportJoinSnippet(placeIdNum, jobIdStr)
    return string.format(
        'game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s", game.Players.LocalPlayer)',
        tostring(placeIdNum),
        jobIdStr
    )
end

local function tryGetLocationLine()
    local function parseGeoJson(body)
        if type(body) ~= "string" then
            return "Unknown"
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(body)
        end)
        if not ok or type(data) ~= "table" or data.status ~= "success" then
            return "Unknown"
        end
        local p = {}
        if type(data.city) == "string" and data.city ~= "" then
            table.insert(p, data.city)
        end
        if type(data.regionName) == "string" and data.regionName ~= "" then
            table.insert(p, data.regionName)
        end
        if type(data.country) == "string" and data.country ~= "" then
            table.insert(p, data.country)
        end
        if #p == 0 then
            return "Unknown"
        end
        return table.concat(p, ", ")
    end

    local url = "http://ip-api.com/json/?fields=status,message,city,regionName,country"
    local g = getgenv and getgenv() or {}

    if syn and syn.request then
        local ok, r = pcall(function()
            return syn.request({ Url = url, Method = "GET" })
        end)
        if ok and type(r) == "table" and type(r.Body) == "string" then
            local line = parseGeoJson(r.Body)
            if line ~= "Unknown" then
                return line
            end
        end
    end

    local req = g.http_request or g.request or http_request or request
    if type(req) == "function" then
        local ok, r = pcall(req, { Url = url, Method = "GET" })
        if ok and type(r) == "table" and type(r.Body) == "string" then
            return parseGeoJson(r.Body)
        end
    end

    return "Unknown"
end

-- Webhook protection (LRM_SEND_WEBHOOK / LRM_SANITIZE):
-- https://docs.luarmor.net/webhook-protection — first arg must be the same valid
-- Discord webhook URL string as DISCORD_WEBHOOK_URL (literal required by Luarmor).
local function sendWebhookFeedback(kind, inputText)
    if kind ~= "bug" and kind ~= "feat" then
        return false, "invalid kind"
    end

    local jobStr = tostring(game.JobId)
    local placeNameSafe = PlaceName or "Unknown"
    local locationLine = tryGetLocationLine()

    if LRM_SEND_WEBHOOK and LRM_SANITIZE then
        return pcall(function()
            if kind == "bug" then
                LRM_SEND_WEBHOOK(
                    WEBHOOK_URL,
                    {
                        username = "fenti | Bug Reports",
                        embeds     = {{
                            title       = "Bug Report",
                            description = LRM_SANITIZE(inputText, "[\\s\\S]{1,4000}"),
                            color       = 0xFF5C5C,
                            fields      = {
                                {
                                    name   = "Player",
                                    value  = LRM_SANITIZE(LocalPlayer.Name, "[a-zA-Z0-9_ ]{1,32}")
                                        .. " · "
                                        .. LRM_SANITIZE(tostring(LocalPlayer.UserId), "[0-9]{1,18}")
                                        .. "\n<@%DISCORD_ID%>",
                                    inline = false,
                                },
                                {
                                    name   = "Session",
                                    value  = LRM_SANITIZE(placeNameSafe, "[^\\n\\r]{1,100}")
                                        .. "\nPlace "
                                        .. LRM_SANITIZE(tostring(PlaceId), "[0-9]{1,15}")
                                        .. " · Job "
                                        .. LRM_SANITIZE(jobStr, "[a-fA-F0-9\\-]{8,80}"),
                                    inline = false,
                                },
                                {
                                    name   = "Client",
                                    value  = LRM_SANITIZE(executorName, "[^\\n\\r]{1,64}")
                                        .. "\n:flag_%COUNTRY_CODE%:",
                                    inline = false,
                                },
                                {
                                    name   = "Location",
                                    value  = LRM_SANITIZE(locationLine, "[^\\n\\r]{1,120}"),
                                    inline = false,
                                },
                                {
                                    name   = "Key note",
                                    value  = "%USER_NOTE%",
                                    inline = false,
                                },
                            },
                        }},
                    })
            else
                LRM_SEND_WEBHOOK(
                    WEBHOOK_URL,
                    {
                        username = "fenti | Suggestions",
                        embeds     = {{
                            title       = "Feature Suggestion",
                            description = LRM_SANITIZE(inputText, "[\\s\\S]{1,4000}"),
                            color       = 0xB09DFF,
                            fields      = {
                                {
                                    name   = "Player",
                                    value  = LRM_SANITIZE(LocalPlayer.Name, "[a-zA-Z0-9_ ]{1,32}")
                                        .. " · "
                                        .. LRM_SANITIZE(tostring(LocalPlayer.UserId), "[0-9]{1,18}")
                                        .. "\n<@%DISCORD_ID%>",
                                    inline = false,
                                },
                                {
                                    name   = "Session",
                                    value  = LRM_SANITIZE(placeNameSafe, "[^\\n\\r]{1,100}")
                                        .. "\nPlace "
                                        .. LRM_SANITIZE(tostring(PlaceId), "[0-9]{1,15}")
                                        .. " · Job "
                                        .. LRM_SANITIZE(jobStr, "[a-fA-F0-9\\-]{8,80}"),
                                    inline = false,
                                },
                                {
                                    name   = "Client",
                                    value  = LRM_SANITIZE(executorName, "[^\\n\\r]{1,64}")
                                        .. "\n:flag_%COUNTRY_CODE%:",
                                    inline = false,
                                },
                                {
                                    name   = "Location",
                                    value  = LRM_SANITIZE(locationLine, "[^\\n\\r]{1,120}"),
                                    inline = false,
                                },
                            },
                        }},
                    })
            end
        end)
    end

    if not WEBHOOK_URL or type(WEBHOOK_URL) ~= "string" or WEBHOOK_URL:match("^%s*$") then
        return false, "Set DISCORD_WEBHOOK_URL (and matching LRM_SEND_WEBHOOK literals) at the top of the script."
    end

    local ts = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
    local sessionVal = placeNameSafe .. "\nPlace " .. tostring(PlaceId) .. " · Job " .. jobStr

    local body
    if kind == "bug" then
        body = HttpService:JSONEncode({
            username = "fenti | Bug Reports",
            embeds   = {{
                title       = "Bug Report",
                description = inputText,
                color       = 0xFF5C5C,
                fields      = {
                    {
                        name   = "Player",
                        value  = LocalPlayer.Name .. " · " .. tostring(LocalPlayer.UserId),
                        inline = false,
                    },
                    {
                        name   = "Session",
                        value  = sessionVal,
                        inline = false,
                    },
                    {
                        name   = "Executor",
                        value  = executorName,
                        inline = true,
                    },
                    {
                        name   = "Location",
                        value  = locationLine,
                        inline = false,
                    },
                    {
                        name   = "Time (UTC)",
                        value  = ts,
                        inline = true,
                    },
                },
                footer      = { text = "fenti" },
            }},
        })
    else
        body = HttpService:JSONEncode({
            username = "fenti | Suggestions",
            embeds   = {{
                title       = "Feature Suggestion",
                description = inputText,
                color       = 0xB09DFF,
                fields      = {
                    {
                        name   = "Player",
                        value  = LocalPlayer.Name .. " · " .. tostring(LocalPlayer.UserId),
                        inline = false,
                    },
                    {
                        name   = "Session",
                        value  = sessionVal,
                        inline = false,
                    },
                    {
                        name   = "Executor",
                        value  = executorName,
                        inline = true,
                    },
                    {
                        name   = "Location",
                        value  = locationLine,
                        inline = false,
                    },
                    {
                        name   = "Time (UTC)",
                        value  = ts,
                        inline = true,
                    },
                },
                footer      = { text = "fenti" },
            }},
        })
    end

    return postJsonWebhook(WEBHOOK_URL, body)
end


local Ti = opts.Tabs.Information
local UserBox = Ti:AddLeftGroupbox("Account", "user")

-- User tier (Free/Premium). Key expiry lives under Luarmor when premium + key (see below).
if isPremium then
    RTLabel(UserBox, c(b("User"), K.White) .. " - " .. c(b("Premium"), K.Peach))
    RTLabel(UserBox, c(b("Status"), K.White) .. " - " .. c(b("Working"), K.Green))
    if not (isLinked or luarmorKey) then
        RTLabel(UserBox, c(b("Expires"), K.White) .. " - " .. c(b(keyExpiry), K.Gold))
    end
else
    RTLabel(UserBox, c(b("User"), K.White) .. " - " .. c(b("Free"), K.Green))
    RTLabel(UserBox, c(b("Status"), K.White) .. " - " .. c(b("Working"), K.Green))
end

UserBox:AddDivider()

-- Executor
RTLabel(UserBox, c(b("Executor"), K.White) .. " - " .. c(b(executorName), K.Lavender))

if isLinked or luarmorKey or LUARMOR_FREE_PUBLIC then
    UserBox:AddDivider()
    RTLabel(UserBox, c(b("Luarmor"), K.Lavender))
    if LUARMOR_FREE_PUBLIC and not luarmorKey then
        RTLabel(UserBox, dim("No script key · free / public build"))
    end
    if isPremium then
        RTLabel(UserBox, c(b("Key lifetime"), K.White) .. " - " .. c(b(keyExpiry), K.Gold))
    end
    do
        local did = discordUser and tostring(discordUser) or ""
        if did ~= "" and did ~= "0" then
            RTLabel(UserBox, c(b("Discord user"), K.White) .. " - " .. c(b(did), K.Lavender))
        end
    end
end

if luarmorApiHint and luarmorApiHint ~= "" then
    RTLabel(UserBox, dim("Luarmor API: " .. luarmorApiHint))
end

-- Game Info
local GameBox = Ti:AddLeftGroupbox("Game Info", "gamepad-2")
RTLabel(GameBox, c(b(PlaceName), K.Sky))
RTLabel(GameBox, c(b("Place ID"), K.White) .. " - " .. c(b(tostring(PlaceId)), K.Sky))
local sessionTimeLabel = RTLabel(GameBox,
    c(b("Session time"), K.White) .. " - " .. c(b("0s"), K.Gold)
)
RTLabel(GameBox, c(b("Server"), K.White) .. " - " .. c(tostring(game.JobId):sub(1, 14) .. "...", K.Muted))

task.spawn(function()
    while true do
        local elapsed = tick() - fentiSessionStart
        sessionTimeLabel:SetText(
            c(b("Session time"), K.White) .. " - " .. c(b(formatSessionElapsed(elapsed)), K.Gold)
        )
        task.wait(1)
    end
end)

GameBox:AddDivider()

local fullJobId = tostring(game.JobId)
local joinSnippet = getTeleportJoinSnippet(PlaceId, fullJobId)
GameBox:AddButton({
    Text = "Copy join script (Job ID)",
    Func = function()
        local ok = copyToClipboard(joinSnippet)
        Library:Notify({
            Title       = "fenti",
            Description = ok and "Teleport snippet copied — paste into executor." or "Clipboard API unavailable.",
            Time        = 3,
        })
    end,
})

-- Spinning icon viewport
local IconBox = Ti:AddLeftGroupbox("fenti", "image")

local VpContainer = Instance.new("Frame")
VpContainer.Size = UDim2.new(1, 0, 0, 130)
VpContainer.BackgroundTransparency = 1

local VpFrame = Instance.new("ViewportFrame")
VpFrame.Size                   = UDim2.new(1, 0, 1, 0)
VpFrame.BackgroundTransparency = 1
VpFrame.LightColor             = Color3.fromRGB(255, 255, 255)
VpFrame.LightDirection         = Vector3.new(-1, -2, -3)
VpFrame.Ambient                = Color3.fromRGB(210, 210, 210)
VpFrame.Parent                 = VpContainer

local VpCamera = Instance.new("Camera")
VpCamera.CFrame       = CFrame.new(Vector3.new(0, 0, 3.2), Vector3.new(0, 0, 0))
VpCamera.Parent       = VpFrame
VpFrame.CurrentCamera = VpCamera

local SpinPart = Instance.new("Part")
SpinPart.Size       = Vector3.new(3.5, 3.5, 0.05)
SpinPart.Anchored   = true
SpinPart.CastShadow = false
SpinPart.Material   = Enum.Material.SmoothPlastic
SpinPart.Color      = Color3.fromRGB(255, 255, 255)
SpinPart.CFrame     = CFrame.new(0, 0, 0)
SpinPart.Parent     = VpFrame

local function AddDecal(face)
    local d = Instance.new("Decal")
    d.Texture = ICON_ASSET_ID
    d.Face    = face
    d.Parent  = SpinPart
end
AddDecal(Enum.NormalId.Front)
AddDecal(Enum.NormalId.Back)

IconBox:AddUIPassthrough("iconViewport", {
    Instance = VpContainer,
    Height   = 135,
    Visible  = true,
})

local spinAngle = 0
RunService.Heartbeat:Connect(function(dt)
    spinAngle = spinAngle + dt * 55
    SpinPart.CFrame = CFrame.Angles(0, math.rad(spinAngle), 0)
end)

-- ================================================
--  INFO TAB - RIGHT
-- ================================================

-- Script hub lineup
local ScriptsHubBox = Ti:AddRightGroupbox("Scripts", "package")
RTLabel(ScriptsHubBox, dim("Included in this hub"))
for _, scriptName in ipairs(SCRIPT_HUB) do
    RTLabel(ScriptsHubBox, c(b(scriptName), K.Sky))
end

-- Features
local FeaturesBox = Ti:AddRightGroupbox("Features", "list")
RTLabel(FeaturesBox, c(b("ESP"), K.Peach) .. dim(" / ") .. c(b("Wallhack"), K.Peach))
RTLabel(FeaturesBox, c(b("Aimbot"), K.Peach) .. dim(" / ") .. c(b("Silent Aim"), K.Peach))
RTLabel(FeaturesBox, c(b("Speed"), K.Lavender) .. dim(" / ") .. c(b("Fly"), K.Lavender))
RTLabel(FeaturesBox, c(b("Auto Farm"), K.Lavender))
RTLabel(FeaturesBox, c(b("Misc Utilities"), K.Sky))

-- Socials
local SocialsBox = Ti:AddRightGroupbox("Socials", "link")

SocialsBox:AddButton({
    Text = "Discord",
    Func = function()
        setclipboard(DISCORD_LINK)
        Library:Notify({ Title = "fenti", Description = "Discord link copied to clipboard!", Time = 3 })
    end,
})

SocialsBox:AddButton({
    Text = "Telegram",
    Func = function()
        setclipboard(TELEGRAM_LINK)
        Library:Notify({ Title = "fenti", Description = "Telegram link copied to clipboard!", Time = 3 })
    end,
})

-- ================================================
--  SUGGESTIONS (dialog popup)
-- ================================================

local SuggestBox = Ti:AddRightGroupbox("Suggestions", "message-square-plus")
RTLabel(SuggestBox, dim("Send feedback directly to the devs."))
SuggestBox:AddDivider()

-- Two separate buttons for Bug and Feature so headers are clear
SuggestBox:AddButton({
    Text = "Report a Bug",
    Func = function()
        local inputText  = ""
        local BugDialog
        BugDialog = Window:AddDialog("BugDialog", {
            Title               = "Report a Bug",
            Description         = "Describe the bug and how to reproduce it.",
            AutoDismiss         = false,
            OutsideClickDismiss = true,
            FooterButtons = {
                Cancel = {
                    Title    = "Cancel",
                    Variant  = "Ghost",
                    Order    = 1,
                    Callback = function() BugDialog:Dismiss() end,
                },
                Send = {
                    Title    = "Send Report",
                    Variant  = "Primary",
                    Order    = 2,
                    Callback = function()
                        if inputText == "" then
                            Library:Notify({
                                Title       = "fenti",
                                Description = "Please describe the bug first.",
                                Time        = 3,
                            })
                            return
                        end

                        local ok, err = sendWebhookFeedback("bug", inputText)

                        BugDialog:Dismiss()

                        if ok then
                            Library:Notify({ Title = "fenti", Description = "Bug report sent. Thanks!", Time = 4 })
                        else
                            Library:Notify({ Title = "fenti", Description = "Send failed: " .. tostring(err), Time = 5 })
                        end
                    end,
                },
            },
        })

        BugDialog:AddInput("BugText", {
            Default     = "",
            Placeholder = "Describe the bug and steps to reproduce...",
            Numeric     = false,
            Finished    = false,
            Text        = "Bug details",
            Callback    = function(v) inputText = v end,
        })
    end,
})

SuggestBox:AddButton({
    Text = "Suggest a Feature",
    Func = function()
        local inputText = ""
        local FeatDialog
        FeatDialog = Window:AddDialog("FeatDialog", {
            Title               = "Suggest a Feature",
            Description         = "Tell us what you would like to see added.",
            AutoDismiss         = false,
            OutsideClickDismiss = true,
            FooterButtons = {
                Cancel = {
                    Title    = "Cancel",
                    Variant  = "Ghost",
                    Order    = 1,
                    Callback = function() FeatDialog:Dismiss() end,
                },
                Send = {
                    Title    = "Send Suggestion",
                    Variant  = "Primary",
                    Order    = 2,
                    Callback = function()
                        if inputText == "" then
                            Library:Notify({
                                Title       = "fenti",
                                Description = "Please write your suggestion first.",
                                Time        = 3,
                            })
                            return
                        end

                        local ok, err = sendWebhookFeedback("feat", inputText)

                        FeatDialog:Dismiss()

                        if ok then
                            Library:Notify({ Title = "fenti", Description = "Suggestion sent. Thanks!", Time = 4 })
                        else
                            Library:Notify({ Title = "fenti", Description = "Send failed: " .. tostring(err), Time = 5 })
                        end
                    end,
                },
            },
        })

        FeatDialog:AddInput("FeatText", {
            Default     = "",
            Placeholder = "Describe the feature you want...",
            Numeric     = false,
            Finished    = false,
            Text        = "Feature details",
            Callback    = function(v) inputText = v end,
        })
    end,
})

-- ================================================
--  CONFIG TAB - LEFT  (Optimization)
-- ================================================

local OptLeft  = Tabs.Config:AddLeftGroupbox("Optimization", "cpu")
local OptRight = Tabs.Config:AddRightGroupbox("Menu", "wrench")

RTLabel(OptLeft, dim("Performance tweaks"))
OptLeft:AddDivider()

OptLeft:AddToggle("DisableShadows", {
    Text     = "Disable Shadows",
    Default  = false,
    Tooltip  = "Removes dynamic shadows for better FPS",
    Callback = function(val)
        game:GetService("Lighting").GlobalShadows = not val
    end,
})

OptLeft:AddToggle("DisableTextures", {
    Text     = "Disable Textures",
    Default  = false,
    Tooltip  = "Removes textures to boost FPS",
    Callback = function(val)
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                v.Transparency = val and 1 or 0
            end
        end
    end,
})

OptLeft:AddToggle("LowGfx", {
    Text     = "Low Graphics",
    Default  = false,
    Tooltip  = "Forces lowest graphics quality",
    Callback = function(val)
        settings().Rendering.QualityLevel =
            val and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
    end,
})

OptLeft:AddDivider()

OptLeft:AddButton({
    Text  = "Unload fenti",
    Risky = true,
    Func  = function()
        if beforeUnload then pcall(beforeUnload) end
        TitleActive = false
        Library:Notify({ Title = "fenti", Description = "Unloading...", Time = 3 })
        task.wait(1)
        Library:Unload()
    end,
})

-- ================================================
--  CONFIG TAB - RIGHT  (Menu)
-- ================================================

RTLabel(OptRight, dim("Appearance & keybinds"))
OptRight:AddDivider()

OptRight:AddToggle("ShowCustomCursor", {
    Text     = "Custom Cursor",
    Default  = false,
    Callback = function(val)
        Library.ShowCustomCursor = val
    end,
})

OptRight:AddDropdown("NotificationSide", {
    Values   = { "Left", "Right" },
    Default  = "Right",
    Text     = "Notification Side",
    Callback = function(val)
        Library:SetNotifySide(val)
    end,
})

OptRight:AddDivider()
OptRight:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI    = true,
    Text    = "Menu Keybind",
})

Library.ToggleKeybind = Options.MenuKeybind

-- ================================================
--  ADDONS
-- ================================================

-- theme/save applied after layout (see footer)

    if ThemeManager and SaveManager and Tabs.Config then
        ThemeManager:SetLibrary(Library)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        local ignore = { "MenuKeybind" }
        for _, k in ipairs(extraIgnoreIndexes) do
            table.insert(ignore, k)
        end
        SaveManager:SetIgnoreIndexes(ignore)
        ThemeManager:SetFolder(themeFolder)
        SaveManager:SetFolder(saveFolder)
        ThemeManager:ApplyToTab(Tabs.Config)
        SaveManager:BuildConfigSection(Tabs.Config)
        ThemeManager:ApplyTheme("Jester")
        SaveManager:LoadAutoloadConfig()
        local themeList = ThemeManager.Library.Options and ThemeManager.Library.Options.ThemeManager_ThemeList
        if themeList then
            pcall(function()
                themeList:SetValue("Jester")
            end)
        end
    elseif not ThemeManager or not SaveManager then
        warn("[fenti_InfoConfig_shared] ThemeManager or SaveManager missing — theme/save not wired.")
    end
end
