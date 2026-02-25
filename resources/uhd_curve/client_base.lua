-- ===================================================
-- HUD CURVE FINAL (METABOLISM LINKED STABLE)
-- ===================================================

print("^2HUD CURVE LINKED STARTED^0")

local ICON_SIZE = 0.028
local RADIUS = 0.075

-- ตำแหน่ง radar rdr2 ปกติ
local CENTER_X = 0.15
local CENTER_Y = 0.85

local HUD = {
    {type="brain", texture="brain", angle=-60},
    {type="food",  icon="F", angle=-25},
    {type="water", icon="W", angle=10},
    {type="temp",  icon="T", angle=45},
}

local pulse = 0

-- ===============================
-- TEXT SAFE (REDM)
-- ===============================
local function DrawTxt(str,x,y,a)
    SetTextScale(0.28,0.28)
    SetTextColor(255,255,255,a or 255)
    SetTextCentre(true)
    DisplayText(CreateVarString(10,"LITERAL_STRING",str),x,y)
end

-- ===============================
-- SAFE META READ (กัน nil export)
-- ===============================
local function GetMetaSafe()

    local meta = {food=0,water=0,temp=0,stress=0}

    local ok,data = pcall(function()
        return exports.metabolism_pro:GetMeta()
    end)

    if ok and data then
        meta = data
    end

    return meta
end

-- ===============================
-- MAIN LOOP
-- ===============================
CreateThread(function()

    while true do
        Wait(0)

        pulse = pulse + 0.05
        if pulse > 6.28 then pulse = 0 end

        local meta = GetMetaSafe()

        local cx,cy = CENTER_X,CENTER_Y

        for _,v in ipairs(HUD) do

            local rad = math.rad(v.angle)
            local x = cx + math.cos(rad)*RADIUS
            local y = cy + math.sin(rad)*RADIUS

            local value = 0

            if v.type=="brain" then value = meta.stress end
            if v.type=="food"  then value = meta.food end
            if v.type=="water" then value = meta.water end
            if v.type=="temp"  then value = meta.temp end

            local alpha = 220

            -- ⭐ กระพริบเฉพาะ brain ตอน 80+
            if v.type=="brain" and value >= 80 then
                alpha = 150 + math.floor(math.sin(GetGameTimer()*0.01)*100)
            end

            local scale = ICON_SIZE

            -- ⭐ brain pulse
            if v.type=="brain" then
                scale = ICON_SIZE + math.sin(pulse)*0.002
            end

            local r,g,b = 255,255,255

            -- temp สีร้อน/หนาว
            if v.type=="temp" then
                if meta.temp >= 35 then r,g,b = 255,80,80 end
                if meta.temp <= -5 then r,g,b = 80,180,255 end
            end

            -- 🧠 brain texture (PNG)
            if v.texture then
                DrawSprite("hud_curve","brain",x,y,scale,scale,0,r,g,b,alpha)
            else
                DrawTxt(v.icon,x,y,alpha)
            end

        end
    end
end)