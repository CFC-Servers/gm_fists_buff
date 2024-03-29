local IsValid = IsValid

local knockoutTemplates = {
    "#A knocked out #T!",
    "#A knocked #T out!",
    "#A knocked #T out cold!",
    "#A K/O'd #T!"
}

local ragdoll = include( "ragdoll.lua" )
local bones = include( "bones.lua" )
local isHead = bones.head
local handBones = bones.hands

local function syncBoneScale( subject, ply )
    local boneCount = subject:GetBoneCount() - 1
    local ones = Vector( 1, 1, 1 )

    for i = 0, boneCount do
        local current = ply:GetManipulateBoneScale( i )

        if current ~= ones then
            subject:ManipulateBoneScale( i, current )
        end
    end
end

local function resetBones( ply )
    local boneCount = ply:GetBoneCount() - 1
    local ones = Vector( 1, 1, 1 )

    for i = 0, boneCount do
        ply:ManipulateBoneScale( i, ones )
        ply:ManipulateBoneJiggle( i, 0 )
    end
end

hook.Add( "PostPlayerDeath", "CFC_BonePunch_PlayerSpawn", function( ply )
    -- TODO: Make sure we only undo the bones we changed
    ply.resetBones = true
end )

hook.Add( "PlayerSpawn", "CFC_BonePunch_ResetBones", function( ply )
    if not ply.resetBones then return end
    resetBones( ply )
    ply.resetBones = nil
end )

local function chance( percent )
    return math.Rand( 0, 100 ) <= percent
end

local function absVector( vec )
    local x = math.abs( vec.x )
    local y = math.abs( vec.y )
    local z = math.abs( vec.z )
    return Vector( x, y, z )
end

local function clampVector( vec )
    local x = math.max( 0, vec.x )
    local y = math.max( 0, vec.y )
    local z = math.max( 0, vec.z )
    return Vector( x, y, z )
end

local function tryKnockout( ply, attacker )
    if chance( 10 ) then
        ragdoll.ragdoll( ply )

        local messageTemplate = table.Random( knockoutTemplates )
        ulx.fancyLogAdmin( attacker, messageTemplate, { ply } )

        ply.ragdolledHealth = ply:Health()

        timer.Simple( 0, function()
            local plyRagdoll = ply.ragdoll
            if not IsValid( plyRagdoll ) then return end
            syncBoneScale( plyRagdoll, ply )
        end )

        timer.Simple( 5, function()
            if not ply.ragdoll then return end
            ragdoll.unragdoll( ply )
            timer.Simple( 0, function()
                ply:SetHealth( ply.ragdolledHealth )
                ply.ragdolledHealth = nil
            end )
        end )
    end
end

local function tryBreakBone( bone, ply )
    if chance( 75 ) then
        ply:ManipulateBoneJiggle( bone, 1 )

        local breakPitch = math.random( 95, 105 )
        ply:EmitSound( "physics/body/body_medium_break" .. math.random( 2, 4 ) .. ".wav", 90, breakPitch, 1, CHAN_STATIC )

        local delay = math.Rand( 0.35, 0.7 )
        timer.Simple( delay, function()
            local screamPitch = math.random( 95, 105 )
            ply:EmitSound( "vo/npc/male01/pain0" .. math.random( 7, 9 ) .. ".wav", 90, screamPitch, 1, CHAN_STATIC )
        end )
    end
end

local function tryDisarm( ply )
    if chance( 75 ) then
        local activeWeapon = ply:GetActiveWeapon()
        if not IsValid( activeWeapon ) then return end

        if activeWeapon:GetClass() == "weapon_fists" then
            return
        end

        ply:DropWeapon()
        ply.DisarmedAt = CurTime()
    end
end

local function scaleFistsDamage( dmginfo )
    dmginfo:ScaleDamage( 1.85 )
    dmginfo:AddDamage( 12 )

    local force = dmginfo:GetDamageForce() + Vector( 0, 0, 650 )
    dmginfo:SetDamageForce( force * 15 )
end

hook.Add( "PlayerCanPickupWeapon", "CFC_BonePunch_CanPickupDisarmed", function( ply )
    if ply.DisarmedAt and ply.DisarmedAt > CurTime() - 1 then
        return false
    end
end )

hook.Add( "EntityTakeDamage", "CFC_BonePunch_TakeDamage", function( ent, dmginfo )
    local inflictor = dmginfo:GetInflictor()
    if not IsValid( inflictor ) then return end
    if inflictor:GetClass() == "weapon_fists" then
        scaleFistsDamage( dmginfo )
    end

    local ragdolledPly = ent.ragdolledPly
    if not ragdolledPly then return end

    local attacker = dmginfo:GetAttacker()
    if not attacker:IsPlayer() then return end

    if not ragdolledPly.ragdolledHealth then return end

    ragdolledPly.ragdolledHealth = ragdolledPly.ragdolledHealth - dmginfo:GetDamage()

    if ragdolledPly.ragdolledHealth <= 0 then
        ragdolledPly.ragdolledHealth = nil
        ragdoll.unragdoll( ragdolledPly )

        ragdolledPly:SetHealth( 0 )
        ragdolledPly:TakeDamageInfo( dmginfo )
    end
end )

hook.Add( "PostEntityTakeDamage", "CFC_BonePunch", function( ent, dmg, took )
    if not took then return end
    if not ent:IsValid() then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end

    local attacker = dmg:GetAttacker()
    local inflictor = dmg:GetInflictor()
    if inflictor:GetClass() ~= "weapon_fists" then return end

    -- ACF Compatability
    local eyePos = attacker:EyePos()
    local disp = attacker:GetEyeTrace().Normal

    local tr = ( util.LegacyTraceLine or util.TraceLine )( {
        start = eyePos + disp * 10,
        endpos = eyePos + disp * 750,
    } )

    local closestBone = ent:GetHitBoxBone( tr.HitBox, 0 )
    if not closestBone then return end
    local boneName = ent:GetBoneName( closestBone )

    if isHead[boneName] then
        tryKnockout( ent, attacker )
    end

    if handBones[boneName] then
        tryDisarm( ent )
    end

    local hitNormal = tr.HitNormal

    local currentScale = ent:GetManipulateBoneScale( closestBone )
    local modified = clampVector( currentScale - absVector( hitNormal * 0.3 ) )

    ent:ManipulateBoneScale( closestBone, modified )
    tryBreakBone( closestBone, ent )
end )
