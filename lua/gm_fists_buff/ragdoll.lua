local ragdoll = {
    ragdoll = function() end,
    unragdoll = function() end,
}

hook.Add( "Think", "CFC_BonePunch_GetULXRagdoll", function()
    hook.Remove( "Think", "CFC_BonePunch_GetULXRagdoll" )
    local name, func

    name, func = debug.getupvalue( ulx.ragdoll, 1 )
    assert( name == "ragdollPlayer" )
    ragdoll.ragdoll = func

    name, func = debug.getupvalue( ulx.ragdoll, 2 )
    assert( name == "unragdollPlayer" )
    ragdoll.unragdoll = func
end )

return ragdoll
