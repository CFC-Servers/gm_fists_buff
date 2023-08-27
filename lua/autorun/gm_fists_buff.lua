if SERVER then
    include( "gm_fists_buff/sv_fists_buff.lua" )
end

hook.Add( "PreRegisterSWEP", "fistsBuffCatChange", function( tbl, class )
    if class ~= "weapon_fists" then return end
    tbl.Category = "CFC"
end )
