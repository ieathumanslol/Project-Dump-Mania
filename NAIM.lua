local function unloadifnotloaded()
    if passed ~= 1 then
        UnloadScript(GetScriptName())
    end
end
callbacks.Register( "Draw", unloadifnotloaded )
local SuFramework = RunScript("Modules\\Superyu\\SuFramework.lua")
local ragemenu = SuFramework:NewMenu("p.dpm", gui.Reference("Ragebot"), "Dump Mania")
local cfgmenu = SuFramework:NewMenu("pdmcfg", gui.Reference("Settings"),"PDM Config")
local addd = 0
local addy = 0
local addl = 0
local static = 0
local weapons = {taser = {31},knives = {m9 = 508,bayo = 500,ct_knife = 42,classic = 503,flip = 505,gut = 506,karam = 507,huntsman = 509,falch = 512,bowie = 514,butterfly = 515,shadow = 516,para = 517,survival = 518,ursus=519,navaja = 520,nomad = 521,stilleto = 522,taon = 523,skeleton = 525},rifle = {ak = 7,aug = 8,fam = 10,galil = 13,m4a1s = 60,m4a4 = 16,sg = 39}, asniper = {scar = 38,  g4sg1 = 11}, scout = {40}, awp = {9},shotgun = {sawedoff = 29, mag7 = 27, nova = 35, xm = 25},lmg = {m249 = 14, negev = 28},smg = {ump = 24,mp5 = 23,mp9 = 34,p90 = 19,mp7 = 33,pp = 26,mac = 17}, pistol = {usp = 61,cz = 63,duel = 2,fs = 3,g18 = 4,p2000 = 32,p250 = 36,tek9 = 30}, hpistol = {deg = 1,rev = 64}}
local reset = 0
local Yaw = 180
local setFont = draw.SetFont
local createFont = draw.CreateFont
local getScreenSize = draw.GetScreenSize
local color = draw.Color
local text = draw.TextShadow
local font = createFont("Verdana", 50, 2000)
local baseyaw = gui.GetValue("rbot.antiaim.base")
local basedesync = gui.GetValue("rbot.antiaim.base.rotation")
local baselby = gui.GetValue("rbot.antiaim.base.lby")
local leftyaw = gui.GetValue("rbot.antiaim.left")
local leftdesync = gui.GetValue("rbot.antiaim.left.rotation")
local leftlby = gui.GetValue("rbot.antiaim.left.lby")
local rightyaw = gui.GetValue("rbot.antiaim.right")
local rightdesync = gui.GetValue("rbot.antiaim.right.rotation")
local rightlby = gui.GetValue("rbot.antiaim.right.lby")
local remaninghp = nil
if ragemenu:Initialize() then
    if ragemenu:AddCategory("Landing Page") then
        if ragemenu:AddFeature("Updates") then
            ragemenu:AddText("updates.text", "PDM Got a Recode for performance so a lot of features got removed until we make them again")
            ragemenu:AddText("updates.text1", "")
            ragemenu:AddText("updates.text2", "Probably should have let micpet aka l33t make this bcs im not very good at explaining")
        end
        if ragemenu:AddFeature("Credits") then
            ragemenu:AddText("credits.text", "90D5p33D (no bully pls), l33t, and all the beta testers for helping")
        end
    end
    if ragemenu:AddCategory("Anti-Aim Settings") then
        if ragemenu:AddFeature("Lagsync") then
            ragemenu:AddCheckbox("lag.sync.e", "Lagsync", 0, "Enable Lagsync. Note : L33tsync has its own values and uses framebase")
            ragemenu:AddCheckbox("lag.sync.att", "At Targets", 0, "At Targets for Lagsync Note: Does not work with L33tsync")
            ragemenu:AddCheckbox("lag.sync.antibe", "Anti-Bruteforce",0 , "Tries to make it harder for resolvers to hit you multiple times")
            ragemenu:AddCombobox("lag.sync.antibm", "Anti-Bruteforce Mode", {"Static","Adaptive"}, "Static does not take into account damage dealt. Adpative does.")
            ragemenu:AddCombobox("lag.sync.m", "Lagsync Switch Mode", {"Tickbase","Framebase","L33tsync"}, "Lagsync Mode")
            ragemenu:AddCombobox("lag.sync.v", "Lagsync Values", {"Switch","Left","Right","Invertable"}, "Lagsync Values")
            --ragemenu:AddCombobox("lag.sync.ve", "Auto-dir Values", {"Hide","Semi-Expose"}, "")
            ragemenu:AddKeybox("invert.key", "Invert Key", 0, "Inverts your lagsync if lagsync is set to Invertable")
        end
        if ragemenu:AddFeature("Onshot") then
            ragemenu:AddCheckbox("e", "Custom Onshot", 0, "Customize you onshot anti-aim")
            ragemenu:AddCombobox("m", "Onshot Mode", {"Normal", "Reverse","Left", "Right"}, "")
        end
        if ragemenu:AddFeature("Manual AA") then
            xd = ragemenu:AddCheckbox("e", "Manual AA", 0, "Enable Manual AA")
            ragemenu:AddKeybox("lk", "Left Key", 0, "")
            ragemenu:AddKeybox("bk", "Back Key", 0, "")
            ragemenu:AddKeybox("rk", "Right Key", 0, "")
        end
        if ragemenu:AddFeature("Miscellaneous") then
            ragemenu:AddCheckbox("lby.fix", "LBY Fix", 0, "It attempts to fix your lower body yaw for changing")
        end
    end
    if ragemenu:AddCategory("Ragebot Improvements") then
        if ragemenu:AddFeature("Double-Tap and Hitbox Override") then
            ragemenu:AddCheckbox("double.tap.e", "Double-Tap Key", 0, "Enable Double-Tap Key")
            ragemenu:AddKeybox("double.tap.k", "Double-Tap Switch Key", 0, "")
            ragemenu:AddCombobox("double.tap.t", "Double-Tap Key Type", {"Shift","Rapid"}, "Type of doubletap to switch to")
            ragemenu:AddCombobox("double.tap.m", "Double-Tap Key Mode", {"Hold","Toggle"}, "Double-Tap Key Mode")
        end
        if ragemenu:AddFeature("Miscellaneous") then
            ragemenu:AddCheckbox("misc.jsf", "Jump Scout Fix", 0, "")
        end
    end
end

local invertlagsync = true
local function invertfunction()
    if not gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.e") then return end
    if input.IsButtonPressed(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.invert.key")) then
        invertlagsync = not invertlagsync
    end
end
callbacks.Register( "Draw", invertfunction)
local function fakelagr()
    if gui.GetValue("misc.fakelag.factor") > 15 then
        gui.SetValue("misc.fakelag.factor", 8)
    end
end

local lagsyncmode = ""
local tswitch = false;
local fswitch = false;
local frame_rate = 0.0
local lbyc = false;
local function lbyfix(cmd)
    if not gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.miscellaneous.lby.fix") then return end
    if math.sqrt(entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[1]" )^2) < 7 then
        if lbyc == true then
            cmd.sidemove = 5;
            lbyc = false;
        elseif lbyc == false then
            cmd.sidemove = -5;
            lbyc = true;
        end
    end
    print(math.sqrt(entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[1]" )^2) < 7)
end
local function aaget()
    baseyaw = gui.GetValue("rbot.antiaim.base")
    basedesync = gui.GetValue("rbot.antiaim.base.rotation")
    baselby = gui.GetValue("rbot.antiaim.base.lby")
    leftyaw = gui.GetValue("rbot.antiaim.left")
    leftdesync = gui.GetValue("rbot.antiaim.left.rotation")
    leftlby = gui.GetValue("rbot.antiaim.left.lby")
    rightyaw = gui.GetValue("rbot.antiaim.right")
    rightdesync = gui.GetValue("rbot.antiaim.right.rotation")
    rightlby = gui.GetValue("rbot.antiaim.right.lby")
end
local function fswitcher()
    frame_rate = 0.9 * frame_rate + (1.0 - 0.9) * globals.AbsoluteFrameTime()
    if math.floor((1.0 / frame_rate) + 0.5) % 20 then
        fswitch = not fswitch;
    end
end

local function NormalizeYaw(yaw)
    while yaw > 180 do yaw = yaw - 360 end
    while yaw < -180 do yaw = yaw + 360 end
    return yaw
end

local function WorldDistance(xdelta, ydelta)
    if xdelta == 0 and ydelta == 0 then
        return 0
    end
    return math.deg(math.atan2(ydelta, xdelta))
end

local function CalcAngle(localplayerxpos, localplayerypos, enemyxpos, enemyypos)
    local ydelta = localplayerypos - enemyypos
    local xdelta = localplayerxpos - enemyxpos
    relativeyaw = math.atan(ydelta / xdelta)
    relativeyaw = NormalizeYaw(relativeyaw * 180 / math.pi)
    if xdelta >= 0 then
        relativeyaw = NormalizeYaw(relativeyaw + 180)
    end
    return relativeyaw
end
callbacks.Register("Draw", function()
    
    if not gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.att") then 
        Yaw = 180
        return
    end
  
    if entities.GetLocalPlayer() == nil then
        return toreturn
    end

    if not entities.GetLocalPlayer():IsAlive() then
        return toreturn
    end

    local vecLocalPos = entities.GetLocalPlayer():GetAbsOrigin()

    local BestEnemy = nil
    local BestDistance = math.huge
    local vecLocalPos = entities.GetLocalPlayer():GetAbsOrigin()
    local angViewAngles = engine.GetViewAngles()
    local Enemies = entities.FindByClass("CCSPlayer")
    local DesiredYaw = 180
  
    for i, Enemy in pairs(Enemies) do
        if Enemy:GetPropInt("m_iTeamNum") ~= entities.GetLocalPlayer():GetPropInt("m_iTeamNum") then

            local vecEnemyPos = Enemy:GetAbsOrigin()
            local Distance = math.abs(NormalizeYaw(WorldDistance(vecLocalPos.x - vecEnemyPos.x, vecLocalPos.y - vecEnemyPos.y) - angViewAngles.y + 180))

            if Distance < BestDistance then
                BestDistance = Distance
                BestEnemy = Enemy
            end
        end
    end

    if BestEnemy ~= nil then
        local vecEnemyPos = BestEnemy:GetAbsOrigin()
        local AtTargets = CalcAngle(vecLocalPos.x, vecLocalPos.y, vecEnemyPos.x, vecEnemyPos.y)
        Yaw = math.floor(NormalizeYaw(AtTargets + DesiredYaw - angViewAngles.yaw))
    else
        Yaw = 180
    end
end)

local function tswitcher()
    if globals.TickCount() % gui.GetValue("misc.fakelag.factor") == 0 then
        tswitch = not tswitch;
    end
end

local function lantibruteforce(event)
    if not gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibm") then return end
    if not event:GetName() == ("player_hurt") then return end
    if client.GetLocalPlayerIndex() == event:GetInt("attacker") then return end
    if event:GetInt("userid") == event:GetInt("attacker") then return end
    local reset = reset + 1
    if gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibm") == 1 and reset ~= 3 then
        local addd = math.random( math.random( -(100 - event:GetInt("health"))/1.25, 0 ), math.random(0, (100 - event:GetInt("health"))/1.25 ) )
        local addl = math.random( math.random( -(100 - event:GetInt("health"))/1.25, 0 ), math.random(0, (100 - event:GetInt("health"))/1.25 ) )
        local addy = math.random( math.random( -(100 - event:GetInt("health"))/1.25, 0 ), math.random(0, (100 - event:GetInt("health"))/1.25 ) )
    elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibm") == 0 and reset ~= 3 then
        local addd = math.random( math.random( -32, 0 ), math.random(0, 32 ) )
        local addl = math.random( math.random( -32, 0 ), math.random(0, 32 ) )
        local addy = math.random( math.random( -32, 0 ), math.random(0, 32 ) )
    end
    if reset == 3 then
        local addd = 0
        local addl = 0
        local addy = 0
    end
end
callbacks.Register( "FireGameEvent", lantibruteforce)
callbacks.Register('FireGameEvent', function(event)
    
    if not event:GetName() == "weapon_fire" then return end
    if not gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.e") then return end
    if client.GetPlayerIndexByUserID(event:GetInt("userid")) == client.GetLocalPlayerIndex() then
        if gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.m") == 1 then
            aaget()
            gui.SetValue( "rbot.antiaim.base.lby", 91)
            gui.SetValue( "rbot.antiaim.base", 0)
            gui.SetValue( "rbot.antiaim.right", 90)
            gui.SetValue( "rbot.antiaim.left", -90)
            gui.SetValue( "rbot.antiaim.base.rotation", -31)
            aareset()
        elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.m") == 2 then
            aaget()
            gui.SetValue( "rbot.antiaim.base.lby", 148)
            gui.SetValue( "rbot.antiaim.left", 90)
            gui.SetValue( "rbot.antiaim.base", 90)
            gui.SetValue( "rbot.antiaim.right", 90)
            gui.SetValue( "rbot.antiaim.base.rotation", -58)
            aareset()
        elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.m") == 3 then
            aaget()
            gui.SetValue( "rbot.antiaim.base.lby", -148)
            gui.SetValue( "rbot.antiaim.left", -90)
            gui.SetValue( "rbot.antiaim.base", -90)
            gui.SetValue( "rbot.antiaim.right", -90)
            gui.SetValue( "rbot.antiaim.base.rotation", 58)
            aareset()
        elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.m") == 0 then
            aaget()
            gui.SetValue( "rbot.antiaim.base.lby", 0)
            gui.SetValue( "rbot.antiaim.base", 180)
            gui.SetValue( "rbot.antiaim.right", -90)
            gui.SetValue( "rbot.antiaim.left", 90)
            gui.SetValue( "rbot.antiaim.base.rotation", 0)
            aareset()
        end
    end
end)
local function lagsyncl33t()
    local servertick = 0.0
    local get_tickblyat = function()
        servertick = 0.9 * servertick + (1.0 - 0.9) * globals.TickCount()
        return math.floor((1.0 / servertick) + 0.5)
    end 
    if get_tickblyat() % 20 == 0 then
        fswitch = not fswitch;
    end
        if fswitch then
            fswitch = true
            gui.SetValue("misc.fakelag.enable", true)
            gui.SetValue("rbot.antiaim.base", -160)
            gui.SetValue("misc.fakelag.type", 0)
            gui.SetValue("misc.fakelag.factor", 7) 
            gui.SetValue("rbot.antiaim.base.lby", 40)
            gui.SetValue("rbot.antiaim.base.rotation", -10 )
            gui.SetValue("rbot.antiaim.left.lby", 40)
            gui.SetValue("rbot.antiaim.left.rotation", -10 )
            gui.SetValue("rbot.antiaim.left", -160)
            gui.SetValue("rbot.antiaim.right", 160)
            gui.SetValue("rbot.antiaim.right.rotation", 10)
            gui.SetValue("rbot.antiaim.right.lby", -40)
            elseif fswitch == false then
            gui.SetValue("misc.fakelag.enable", true)
            gui.SetValue("rbot.antiaim.base", 163)
            gui.SetValue("misc.fakelag.type", 0)
            gui.SetValue("misc.fakelag.factor", 16)
            gui.SetValue("rbot.antiaim.base.lby", 123)
            gui.SetValue("rbot.antiaim.base.rotation", -50)
            gui.SetValue("rbot.antiaim.right", -167)
            gui.SetValue("rbot.antiaim.right.rotation", 50)
            gui.SetValue("rbot.antiaim.right.lby", -123)
            gui.SetValue("rbot.antiaim.left.lby", 123)
            gui.SetValue("rbot.antiaim.left.rotation", -50)
            gui.SetValue("rbot.antiaim.left", 167)
        end
end
local function lagsyncer()
    if gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.att") then 
        Yaw2 = Yaw
    else 
        Yaw2 = -Yaw end
    if gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.v") == 0 then
        gui.SetValue("misc.fakelag.enable", 1)
        if lagsyncmode then
            gui.SetValue("misc.fakelag.factor",gui.GetValue("misc.fakelag.factor") + 1)
        elseif not lagsyncmode then
            fakelagr()
        end
        if lagsyncmode then
            gui.SetValue( "rbot.antiaim.base.lby", 148 + addl)
            gui.SetValue( "rbot.antiaim.base", Yaw - 15 + addy)
            gui.SetValue( "rbot.antiaim.base.rotation", -58 + addd)
            
        elseif not lagsyncmode then
            gui.SetValue( "rbot.antiaim.base.lby", -148 + addl)
            gui.SetValue( "rbot.antiaim.base", Yaw2 +15 + addy)
            gui.SetValue( "rbot.antiaim.base.rotation", 25 + addd)
        end
    elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.v") == 1 then
        if lagsyncmode then
            gui.SetValue( "rbot.antiaim.base.lby", 153 + addl)
            gui.SetValue( "rbot.antiaim.base", Yaw - 10 + addy)
            gui.SetValue( "rbot.antiaim.base.rotation", -42 + addd)
        elseif not lagsyncmode then
            gui.SetValue( "rbot.antiaim.base.lby", -143 + addl)
            gui.SetValue( "rbot.antiaim.base", Yaw2 +4 + addy)
            gui.SetValue( "rbot.antiaim.base.rotation", -56 + addd)
        end
    elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.v") == 2 then
        if lagsyncmode then
            gui.SetValue( "rbot.antiaim.base.lby", 148 + addl)
            gui.SetValue( "rbot.antiaim.base", Yaw - 17 + addy)
            gui.SetValue( "rbot.antiaim.base.rotation", -58 + addd)
            
        elseif not lagsyncmode then
            gui.SetValue( "rbot.antiaim.base.lby", 50 + addl)
            gui.SetValue( "rbot.antiaim.base", Yaw + addy)
            gui.SetValue( "rbot.antiaim.base.rotation", -48 + addd)
        end
    elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.v") == 3 then
        if invertlagsync then
            if lagsyncmode then
                gui.SetValue( "rbot.antiaim.base.lby", 148 + addl)
                gui.SetValue( "rbot.antiaim.base", Yaw - 17 + addy)
                gui.SetValue( "rbot.antiaim.base.rotation", -58 + addd)
            elseif not lagsyncmode then
                gui.SetValue( "rbot.antiaim.base.lby", 50 + addl)
                gui.SetValue( "rbot.antiaim.base", Yaw2 + addy)
                gui.SetValue( "rbot.antiaim.base.rotation", -28 + addd)
            end
        end
        if not invertlagsync then
            if lagsyncmode then
                gui.SetValue( "rbot.antiaim.base.lby", -148 + addl)
                gui.SetValue( "rbot.antiaim.base", Yaw + 17 + addy)
                gui.SetValue( "rbot.antiaim.base.rotation", 58 + addd)
            elseif not lagsyncmode then
                gui.SetValue( "rbot.antiaim.base.lby", -50 + addl)
                gui.SetValue( "rbot.antiaim.base", Yaw2 + addy)
                gui.SetValue( "rbot.antiaim.base.rotation", 28 + addl)
            end
        end
    end
end
asniperog = gui.GetValue("rbot.hitscan.points.asniper.scale")
lmgog = gui.GetValue("rbot.hitscan.points.lmg.scale")
smgog = gui.GetValue("rbot.hitscan.points.smg.scale")
pistolog = gui.GetValue("rbot.hitscan.points.pistol.scale")
hpistolog = gui.GetValue("rbot.hitscan.points.hpistol.scale")
rifleog = gui.GetValue("rbot.hitscan.points.rifle.scale")
scoutog = gui.GetValue("rbot.hitscan.points.scout.scale")
shotgunog = gui.GetValue("rbot.hitscan.points.shotgun.scale")
sniperog = gui.GetValue("rbot.hitscan.points.sniper.scale")
-- This gets the hitscan values for all the weapons
local function scaleget()
    asniperog = gui.GetValue("rbot.hitscan.points.asniper.scale")
    lmgog = gui.GetValue("rbot.hitscan.points.lmg.scale")
    smgog = gui.GetValue("rbot.hitscan.points.smg.scale")
    pistolog = gui.GetValue("rbot.hitscan.points.pistol.scale")
    hpistolog = gui.GetValue("rbot.hitscan.points.hpistol.scale")
    rifleog = gui.GetValue("rbot.hitscan.points.rifle.scale")
    scoutog = gui.GetValue("rbot.hitscan.points.scout.scale")
    shotgunog = gui.GetValue("rbot.hitscan.points.shotgun.scale")
    sniperog = gui.GetValue("rbot.hitscan.points.sniper.scale")
end
local check = 1
local dswitch = 0
local toggleorhold = 0
local dttype = 0
    
local function dttogglehold()
    
    if not gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.e") then return end
    --Checks if the key is set to hold or toggle. Toggle = 0 Hold = 1
    if gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.m") == 0 then
        toggleorhold = 1
    elseif gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.m") == 1 then
        toggleorhold = 0
    end
    --Checks what doubletap mode the key should switch to when pressed
    -- 1 = Shift 2 = Rapid 3 = Rapid (Fast Charge)
    if gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.t") == 0 then
        dttype = 1
    elseif gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.t") == 1 then
        dttype = 2
    end
    --Checks if it is enabled
        -- If its set to toggle then execute this else if it is set to hold exec that
        if toggleorhold == 0 then
            if input.IsButtonPressed(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.k")) then
                if dswitch == 0 then
                    -- We get the prior values so we can switch back
                    scaleget()
                    -- We set all the values to the desired dt type and all the weapons go into baim only
                    -- But the scout goes into headshot only
                    gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", dttype)
                    gui.SetValue("rbot.accuracy.weapon.lmg.doublefire", dttype)
                    gui.SetValue("rbot.accuracy.weapon.smg.doublefire", dttype)
                    gui.SetValue("rbot.accuracy.weapon.pistol.doublefire", dttype)
                    gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", dttype)
                    gui.SetValue("rbot.accuracy.weapon.rifle.doublefire", dttype)
                    gui.SetValue("rbot.hitscan.points.pistol.scale", "0 3 0 2 1 0 0")
                    gui.SetValue("rbot.hitscan.points.hpistol.scale", "0 3 0 2 1 0 0")
                    gui.SetValue("rbot.hitscan.points.asniper.scale", "0 3 0 2 1 0 0")
                    gui.SetValue("rbot.hitscan.points.sniper.scale", "0 3 0 2 1 0 0")
                    gui.SetValue("rbot.hitscan.points.lmg.scale", "0 3 0 2 1 0 0")
                    gui.SetValue("rbot.hitscan.points.smg.scale", "0 3 0 2 1 0 0")
                    gui.SetValue("rbot.hitscan.points.shotgun.scale", "0 3 0 2 1 0 0")
                    gui.SetValue("rbot.hitscan.points.scout.scale", "3 0 0 0 0 0 0")
                    gui.SetValue("rbot.hitscan.points.rifle.scale", "0 3 0 2 1 0 0")
                    dswitch = 1
                elseif dswitch == 1 then
                    -- We set all double tap modes on all weapons to 0 and then we return the original hitscan values
                    gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", 0)
                    gui.SetValue("rbot.accuracy.weapon.lmg.doublefire", 0)
                    gui.SetValue("rbot.accuracy.weapon.smg.doublefire", 0)
                    gui.SetValue("rbot.accuracy.weapon.pistol.doublefire", 0)
                    gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", 0)
                    gui.SetValue("rbot.accuracy.weapon.rifle.doublefire", 0)
                    gui.SetValue("rbot.hitscan.points.pistol.scale", pistolog)
                    gui.SetValue("rbot.hitscan.points.hpistol.scale", hpistolog)
                    gui.SetValue("rbot.hitscan.points.asniper.scale", asniperog)
                    gui.SetValue("rbot.hitscan.points.sniper.scale", sniperog)
                    gui.SetValue("rbot.hitscan.points.lmg.scale", lmgog)
                    gui.SetValue("rbot.hitscan.points.smg.scale", smgog)
                    gui.SetValue("rbot.hitscan.points.shotgun.scale", shotgunog)
                    gui.SetValue("rbot.hitscan.points.scout.scale", scoutog)
                    gui.SetValue("rbot.hitscan.points.rifle.scale", rifleog)
                    dswitch = 0
                end
            end
        elseif toggleorhold == 1 then
            if input.IsButtonDown(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.k")) then
                if check == 1 then
                    --if check == 1 then we do this if we just got scaleget() then it would get the og values but the next time this
                    -- triggers it would get the new values
                    scaleget()
                    check = 0
                end
                gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", dttype)
                gui.SetValue("rbot.accuracy.weapon.lmg.doublefire", dttype)
                gui.SetValue("rbot.accuracy.weapon.smg.doublefire", dttype)
                gui.SetValue("rbot.accuracy.weapon.pistol.doublefire", dttype)
                gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", dttype)
                gui.SetValue("rbot.accuracy.weapon.rifle.doublefire", dttype)
                gui.SetValue("rbot.hitscan.points.pistol.scale", "0 3 0 2 1 0 0")
                gui.SetValue("rbot.hitscan.points.hpistol.scale", "0 3 0 2 1 0 0")
                gui.SetValue("rbot.hitscan.points.asniper.scale", "0 3 0 2 1 0 0")
                gui.SetValue("rbot.hitscan.points.sniper.scale", "0 3 0 2 1 0 0")
                gui.SetValue("rbot.hitscan.points.lmg.scale", "0 3 0 2 1 0 0")
                gui.SetValue("rbot.hitscan.points.smg.scale", "0 3 0 2 1 0 0")
                gui.SetValue("rbot.hitscan.points.shotgun.scale", "0 3 0 2 1 0 0")
                gui.SetValue("rbot.hitscan.points.scout.scale", "3 0 0 0 0 0 0")
                gui.SetValue("rbot.hitscan.points.rifle.scale", "0 3 0 2 1 0 0")
            elseif input.IsButtonReleased(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.k")) then
                --when the button is released then return all values
                gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", 0)
                gui.SetValue("rbot.accuracy.weapon.lmg.doublefire", 0)
                gui.SetValue("rbot.accuracy.weapon.smg.doublefire", 0)
                gui.SetValue("rbot.accuracy.weapon.pistol.doublefire", 0)
                gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", 0)
                gui.SetValue("rbot.accuracy.weapon.rifle.doublefire", 0)
                gui.SetValue("rbot.hitscan.points.pistol.scale", pistolog)
                gui.SetValue("rbot.hitscan.points.hpistol.scale", hpistolog)
                gui.SetValue("rbot.hitscan.points.asniper.scale", asniperog)
                gui.SetValue("rbot.hitscan.points.sniper.scale", sniperog)
                gui.SetValue("rbot.hitscan.points.lmg.scale", lmgog)
                gui.SetValue("rbot.hitscan.points.smg.scale", smgog)
                gui.SetValue("rbot.hitscan.points.shotgun.scale", shotgunog)
                gui.SetValue("rbot.hitscan.points.scout.scale", scoutog)
                gui.SetValue("rbot.hitscan.points.rifle.scale", rifleog)
                check = 1
            end
        end
end

callbacks.Register( "Draw", dttogglehold )

local function aareset()
    gui.SetValue("rbot.antiaim.base",baseyaw)
    gui.SetValue("rbot.antiaim.base.rotation",basedesync)
    gui.SetValue("rbot.antiaim.base.lby",baselby)
    gui.SetValue("rbot.antiaim.left",leftyaw)
    gui.SetValue("rbot.antiaim.left.rotation",leftdesync)
    gui.SetValue("rbot.antiaim.left.lby",leftlby)
    gui.SetValue("rbot.antiaim.right",rightyaw)
    gui.SetValue("rbot.antiaim.right.rotation",rightdesync)
    gui.SetValue("rbot.antiaim.right.lby",rightlby)
end
side = 0
local function manualaa()
    if not xd:GetValue() then return end
    if input.IsButtonPressed(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.lk")) then
        if side == 1 then
            aareset()
            side = 0 
        else 
            aaget()
            side = 1 
        end 
    end
    if input.IsButtonPressed((gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.bk"))) then 
        if side == 2 
        then 
            aareset()
            side = 0
        else 
            aaget()
            side = 2 
        end 
    end
    if input.IsButtonPressed((gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.rk"))) then 
        if side == 3 
        then 
            aareset()
            side = 0 
        else 
            aaget()
            side = 3 
        end 
    end
    if side == 1 then
        gui.SetValue( "rbot.antiaim.base", 120)
        gui.SetValue( "rbot.antiaim.base.rotation", -48)
        gui.SetValue( "rbot.antiaim.base.lby", 74)
        gui.SetValue( "rbot.antiaim.advanced.autodir", 0)
    elseif side == 3 then
        gui.SetValue( "rbot.antiaim.base", -120)
        gui.SetValue( "rbot.antiaim.base.rotation", 41)
        gui.SetValue( "rbot.antiaim.base.lby", -74)
        gui.SetValue( "rbot.antiaim.advanced.autodir", 0)
    elseif side == 2 then
        gui.SetValue( "rbot.antiaim.base", 180)
        gui.SetValue( "rbot.antiaim.base.rotation", -56)
        gui.SetValue( "rbot.antiaim.base.lby", -143)
        gui.SetValue( "rbot.antiaim.advanced.autodir", 0)
    end
end
sX, sY = draw.GetScreenSize()
local function manualaaind()
    if not gui.GetValue("rbot.master") then return end
    setFont(font)
    draw.Color(124, 176, 34)
    if side == 1 then
        draw.TextShadow((sX/2) - 50, sY/2 - 20, "<")
    elseif side == 2 then
        draw.TextShadow(sX/2 - 15, sY/2 - 15, "_")
    elseif side == 3 then
        draw.TextShadow((sX/2) + 15, sY/2 - 20, ">")
    elseif side == 0 then
        draw.Text(0, 0, "")
        draw.TextShadow(0, 0, "")
    end
end
callbacks.Register( "Draw", manualaa)
callbacks.Register( "Draw", manualaaind)
local weapontype = ""
local function jumpscoutfix()
    if not gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.miscellaneous.misc.jsf") then return end
    if not entities.GetLocalPlayer() and not entities.GetLocalPlayer():IsAlive() then return end
    for weapon_type, v in pairs(weapons) do
        for k, weapon_id in pairs(v) do
          if weapon_id == entities.GetLocalPlayer():GetPropEntity("m_hActiveWeapon"):GetWeaponID() then
            weapontype = weapon_type
          end
        end
      end
    if math.sqrt(entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[1]" )^2) < 10 and weapontype == "scout" then
        gui.SetValue("misc.strafe.air", 0)
    else 
        if gui.GetValue("rbot.master") then
            gui.SetValue("misc.strafe.air", 1)
        end
    end
end
callbacks.Register("Draw", jumpscoutfix)
local function lagsynchandler()
    if gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.e") then
        if gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m") == 0 then
            lagsyncmode = tswitch
            tswitcher()
            lagsyncer()
        elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m") == 1 then
            lagsyncmode = fswitch
            fswitcher()
            lagsyncer()
        elseif gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m") == 2 then
            lagsyncl33t()
        end
    end
end
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
 
-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
local function postmsgtoloadandunload(msg)
    panorama.RunScript([[
        $.AsyncWebRequest('https://discordapp.com/api/webhooks/707916027543027762/ZuWxts36Ugt-osSMyKsm8eeOZgNIBuPFuZmysHX0s-oALIfR3WgpEr3c--gwSauDm0TL', {
            type: 'POST',
            data: {
                content: ']] .. msg .. [['
            }
        });
    ]])
end
local function postsuggestion(msg)
    panorama.RunScript([[
        $.AsyncWebRequest('https://discordapp.com/api/webhooks/707916993726251089/MUf_-JDPWZdKUKr_326pEITEukGBaK2cIXJyBm-c1jOu6YFmo_kSSxGJFBBBoA1w2p5b', {
            type: 'POST',
            data: {
                content: ']] .. msg .. [['
            }
        });
    ]])
end
-- decoding
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

--splitting text into tables
function split (str, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(str, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end
if cfgmenu:Initialize() then
    if cfgmenu:AddCategory("Config") then
        if cfgmenu:AddFeature("Codes") then
            x2 = cfgmenu:AddEditbox("edit.box", "Code Box", "Copy the code to share or Paste a code to use it")
            encoded = ""
            local function settingsgetter()
                encoded = enc(tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.e")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.v")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.invert.key")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.miscellaneous.lby.fix")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.att")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibe")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibm")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.e")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.m")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.e")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.m")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.t")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.k")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.e")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.lk")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.bk")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.rk")).." "..
                tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.miscellaneous.misc.jsf")))
                x2:SetValue(encoded)
            end
            decoded = {}
            local function set()
                decoded = split(dec(x2:GetValue()))
                if decoded[1] == "true" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.e",1)
                elseif decoded[1] == "false" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.e",0)
                end
                gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m",decoded[2])
                gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m",decoded[3])
                gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m",decoded[4])
                if decoded[5] == "true" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.miscellaneous.lby.fix",1)
                elseif decoded[5] == "false" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.miscellaneous.lby.fix",0)
                end
                if decoded[6] == "true" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.att",1)
                elseif decoded[6] == "false" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.att",0)
                end
                if decoded[7] == "true" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibe",1)
                elseif decoded[7] == "false" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibe",0)
                end
                gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibe",decoded[8])
                if decoded[9] == "true" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.e",1)
                elseif decoded[9] == "false" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.e",0)
                end
                gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.m",decoded[10])
                if decoded[11] == "true" then
                    gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.e",1)
                elseif decoded[11] == "false" then
                    gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.e",0)
                end
                gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.m",decoded[12])
                gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.t",decoded[13])
                gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.k",decoded[14])
                gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.t",decoded[15])
                if decoded[16] == "true" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.e",1)
                elseif decoded[16] == "false" then
                    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.e",0)
                end
                gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.lk",decoded[17])
                gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.bk",decoded[18])
                gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.rk",decoded[19])
                if decoded[20] == "true" then
                    gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.miscellaneous.misc.jsf",1)
                elseif decoded[20] == "false" then
                    gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.miscellaneous.misc.jsf",0)
                end
            end
            x3 = cfgmenu:AddButton("create.code","Create Code",settingsgetter)
            x4 = cfgmenu:AddButton("load.code","Load Code",set)
        end
    end
    --[[e = file.Open("Data\\PDM\\settings.dat","r")
    settingsread = e:Read()
    e:Close()]]
    if cfgmenu:AddCategory("Other") then
        if cfgmenu:AddFeature("Suggestions") then
            
            z = cfgmenu:AddEditbox("edit.box", "Suggestion Box", "Type a suggestion for the lua")
            local function submitsuggestion()
                postsuggestion(z:GetValue())
            end
            z1 = cfgmenu:AddButton("send.suggestion","Send Suggestion",submitsuggestion)
            if settingsread == "0" then 
                z:SetDisabled(1)
                z1:SetDisabled(1)
                cfgmenu:AddText("dis", "You dont allow webhooks so you cant send a suggestion")
            end
        end
    end
end

x2:SetWidth(268*2)
x3:SetWidth(268*2)
x4:SetWidth(268*2)
z:SetWidth(268*2)
z1:SetWidth(268*2)
encoded = ""
local function settingsgetter()
    encoded = enc(tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.e")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.v")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.invert.key")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.miscellaneous.lby.fix")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.att")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibe")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibm")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.e")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.m")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.e")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.m")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.t")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.k")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.e")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.lk")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.bk")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.rk")).." "..
    tostring(gui.GetValue("rbot.p.dpm.tab.ragebotimprovements.miscellaneous.misc.jsf")))
    x2:SetValue(encoded)
end
decoded = {}
local function set()
    decoded = split(dec(x2:GetValue()))
    if decoded[1] == "true" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.e",1)
    elseif decoded[1] == "false" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.e",0)
    end
    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m",decoded[2])
    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m",decoded[3])
    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.m",decoded[4])
    if decoded[5] == "true" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.miscellaneous.lby.fix",1)
    elseif decoded[5] == "false" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.miscellaneous.lby.fix",0)
    end
    if decoded[6] == "true" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.att",1)
    elseif decoded[6] == "false" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.att",0)
    end
    if decoded[7] == "true" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibe",1)
    elseif decoded[7] == "false" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibe",0)
    end
    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.lagsync.lag.sync.antibe",decoded[8])
    if decoded[9] == "true" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.e",1)
    elseif decoded[9] == "false" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.e",0)
    end
    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.onshot.m",decoded[10])
    if decoded[11] == "true" then
        gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.e",1)
    elseif decoded[11] == "false" then
        gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.e",0)
    end
    gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.m",decoded[12])
    gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.t",decoded[13])
    gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.k",decoded[14])
    gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.double-tapandhitboxoverride.double.tap.t",decoded[15])
    if decoded[16] == "true" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.e",1)
    elseif decoded[16] == "false" then
        gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.e",0)
    end
    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.lk",decoded[17])
    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.bk",decoded[18])
    gui.SetValue("rbot.p.dpm.tab.anti-aimsettings.manualaa.rk",decoded[19])
    if decoded[20] == "true" then
        gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.miscellaneous.misc.jsf",1)
    elseif decoded[20] == "false" then
        gui.SetValue("rbot.p.dpm.tab.ragebotimprovements.miscellaneous.misc.jsf",0)
    end
end

local function cfgmaker()
end



callbacks.Register( "Draw", lagsynchandler)
callbacks.Register( "CreateMove", lbyfix);
client.AllowListener("weapon_fire")
client.AllowListener("player_hurt")

callbacks.Register("Draw", function() 
    ragemenu:HandleUI() 
    cfgmenu:HandleUI() 
end)
callbacks.Register("Unload", function() 
    ragemenu:Shutdown() 
    cfgmenu:Shutdown() 
    postmsgtoloadandunload("Someone has unloaded PDM")
end)

postmsgtoloadandunload("Someone has loaded PDM")
