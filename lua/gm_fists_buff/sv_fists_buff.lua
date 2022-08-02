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
    local boneCount = subject:GetBoneCount()
    local ones = Vector( 1, 1, 1 )

    for i = 1, boneCount do
        local current = ply:GetManipulateBoneScale( i )

        if current ~= ones then
            subject:ManipulateBoneScale( i, current )
        end
    end
end

local function resetBones( ply )
    local boneCount = ply:GetBoneCount()
    local ones = Vector( 1, 1, 1 )

    for i = 1, boneCount do
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

local function tryKnockout( ply, attacker )
    if chance( 5 ) then
        ragdollPlayer( ply )

        local messageTemplate = table.Random( knockoutTemplates )
        ulx.fancyLogAdmin( attacker, messageTemplate, { ply } )

        ply.ragdolledHealth = ply:Health()

        timer.Simple( 0, function()
            local ragdoll = ply.ragdoll
            syncBoneScale( ragdoll, ply )
        end )

        timer.Simple( 5, function()
            if not ply.ragdoll then return end
            unragdollPlayer( ply )
            timer.Simple( 0, function()
                ply:SetHealth( ply.ragdolledHealth )
                ply.ragdolledHealth = nil
            end )
        end )
    end
end

local function tryBreakBone( bone, ply )
    if chance( 33 ) then
        ply:ManipulateBoneJiggle( bone, 1 )

        ply:EmitSound( "physics/body/body_medium_break" .. math.random( 2, 4 ) .. ".wav", 130, 100, 1, CHAN_STATIC )
        timer.Simple( 0.5, function()
            ply:EmitSound( "vo/npc/male01/pain0" .. math.random( 7, 9 ) .. ".wav", 130, 100, 1, CHAN_STATIC )
        end )
    end
end

local function tryDisarm( ply )
    if chance( 75 ) then
        ply:DropWeapon()
        ply.DisarmedAt = CurTime()
    end
end

hook.Add( "PlayerCanPickupWeapon", "CFC_BonePunch_CanPickupDisarmed", function( ply, wep )
    if ply.DisarmedAt and ply.DisarmedAt > CurTime() - 1 then
        return false
    end
end )

hook.Add( "EntityTakeDamage", "CFC_BonePunch_TakeDamage", function( ent, dmginfo )
    local inflictor = dmginfo:GetInflictor()
    if inflictor:GetClass() == "weapon_fists" then
        dmginfo:ScaleDamage( 1.85 )
        dmginfo:SetDamageForce( dmginfo:GetDamageForce() * 15 )
    end

    local ragdolledPly = ent.ragdolledPly
    if not ragdolledPly then return end

    local attacker = dmginfo:GetAttacker()
    if not attacker:IsPlayer() then return end

    ragdolledPly.ragdolledHealth = ragdolledPly.ragdolledHealth - dmginfo:GetDamage()
    if ragdolledPly.ragdolledHealth <= 0 then
        ragdolledPly.ragdolledHealth = nil
        unragdollPlayer( ragdolledPly )
        ragdolledPly:Kill()
    end
end )

hook.Add( "PostEntityTakeDamage", "CFC_BonePunch", function( ent, dmg, took )
    if not took then return end
    if not ent:IsValid() then return end
    if not ent:IsPlayer() then return end

    local attacker = dmg:GetAttacker()
    local inflictor = dmg:GetInflictor()
    if inflictor:GetClass() ~= "weapon_fists" then return end

    local tr = util.TraceLine({
        start = attacker:EyePos(),
        endpos = attacker:EyePos() + attacker:GetAimVector() * 1000,
        collisiongroup = COLLISION_GROUP_PLAYER,
        mask = MASK_SHOT_HULL
    })

    local closestBone = ent:TranslatePhysBoneToBone( tr.PhysicsBone )
    local cloestBonePos = ent:GetBonePosition( closestBone )

    timer.Simple( 0, function()
        local boneName = ent:GetBoneName( closestBone )

        if isHead[boneName] then
            tryKnockout( ent, attacker )
        end

        if handBones[boneName] then
            tryDisarm( ent )
        end

        local hitNormal = tr.HitNormal

        local currentScale = ent:GetManipulateBoneScale( closestBone )

        local factor = 0.5
        local modified = currentScale * ( Vector( 1, 1, 1 ) - hitNormal * factor )
        ent:ManipulateBoneScale( closestBone, modified )

        tryBreakBone( closestBone, ent )
    end )
end )
