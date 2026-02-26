-- =========================================
-- 🧠 METABOLISM PRO - FINAL REDM FIXED
-- =========================================

print("^2METABO FINAL START^0")

local stress      = 79.0
local drunkState  = 0
local isDead      = false
local pulse       = 0.0

-- =========================================
-- SYNC HUD
-- =========================================
local function SyncStress()
    TriggerEvent("hud_curve:updateStress", stress)
end

-- =========================================
-- CLEAR EFFECT (FIXED - ไม่ freeze แล้ว)
-- =========================================
local function ClearDrunk()
    ClearTimecycleModifier()
    AnimpostfxStopAll()
    StopGameplayCamShaking(true)
    drunkState = 0
end

-- =========================================
-- FORCE START
-- =========================================
CreateThread(function()
    Wait(4000)
    stress = 79.0
    SyncStress()
    print("^5METABO READY | START 79^0")
end)

-- =========================================
-- STRESS SYSTEM
-- =========================================
CreateThread(function()
    while true do
        Wait(500)

        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then goto skip end

        local speed = GetEntitySpeed(ped)

        -- ยิงปืน (RedM control)
        if IsPedArmed(ped,6) and IsControlPressed(0,0x07CE1E61) then
            stress = stress + 0.45
        end

        if IsPedSprinting(ped) then
            stress = stress + 0.08
        end

        -- ยืนนิ่งต่ำกว่า 80 ลด
        if stress < 80 and speed < 0.1 then
            stress = stress - 0.10
        end

        stress = stress - 0.03

        if stress > 100 then stress = 100 end
        if stress < 0 then stress = 0 end

        SyncStress()

        ::skip::
    end
end)

-- =========================================
-- 🎬 CONTINUOUS DRUNK + AUTO RESET ON REVIVE
-- =========================================
CreateThread(function()

    local state = 0
    local wasDead = false

    while true do
        Wait(200)

        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then goto continue end

        -- =========================
        -- ตรวจจับ revive
        -- =========================
        if IsEntityDead(ped) then
            wasDead = true
            goto continue
        end

        if wasDead and not IsEntityDead(ped) then
            -- เพิ่งถูกชุบ
            stress = 0
            SyncStress()
            ClearDrunk()
            state = 0
            wasDead = false
        end

        -- =========================
        -- ต่ำกว่า 80 ล้าง effect
        -- =========================
        if stress < 80 then
            if state ~= 0 then
                ClearDrunk()
                state = 0
            end
            goto continue
        end

        -- =========================
        -- 80 - 89
        -- =========================
        if stress >= 80 and state == 0 then
            state = 1
            SetTimecycleModifier("PlayerDrunk01")
            SetTimecycleModifierStrength(0.25)
            AnimpostfxPlay("PlayerDrunk01",0,true)
            ShakeGameplayCam("DRUNK_SHAKE",0.05)
        end

        -- =========================
        -- 90 - 99 (ไม่ ClearDrunk แล้ว)
        -- =========================
        if stress >= 90 and state == 1 then
            state = 2
            SetTimecycleModifierStrength(0.40)
            AnimpostfxPlay("MP_DeathFailOut",0,true)
            ShakeGameplayCam("DRUNK_SHAKE",0.15)
        end

        -- =========================
        -- 100 = ตาย
        -- =========================
        if stress >= 100 then
            SetEntityHealth(ped, 0)
        end

        ::continue::
    end
end)