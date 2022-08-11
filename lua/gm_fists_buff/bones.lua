local handBones = {
    -- Left Fingers
    ["ValveBiped.Bip01_L_Finger0"] = true,
    ["ValveBiped.Bip01_L_Finger01"] = true,
    ["ValveBiped.Bip01_L_Finger02"] = true,

    ["ValveBiped.Bip01_L_Finger1"] = true,
    ["ValveBiped.Bip01_L_Finger11"] = true,
    ["ValveBiped.Bip01_L_Finger12"] = true,

    ["ValveBiped.Bip01_L_Finger2"] = true,
    ["ValveBiped.Bip01_L_Finger21"] = true,
    ["ValveBiped.Bip01_L_Finger22"] = true,

    ["ValveBiped.Bip01_L_Finger3"] = true,
    ["ValveBiped.Bip01_L_Finger31"] = true,
    ["ValveBiped.Bip01_L_Finger32"] = true,

    ["ValveBiped.Bip01_L_Finger4"] = true,
    ["ValveBiped.Bip01_L_Finger41"] = true,
    ["ValveBiped.Bip01_L_Finger42"] = true,

    -- Right Fingers
    ["ValveBiped.Bip01_R_Finger0"] = true,
    ["ValveBiped.Bip01_R_Finger01"] = true,
    ["ValveBiped.Bip01_R_Finger02"] = true,

    ["ValveBiped.Bip01_R_Finger1"] = true,
    ["ValveBiped.Bip01_R_Finger11"] = true,
    ["ValveBiped.Bip01_R_Finger12"] = true,

    ["ValveBiped.Bip01_R_Finger2"] = true,
    ["ValveBiped.Bip01_R_Finger21"] = true,
    ["ValveBiped.Bip01_R_Finger22"] = true,

    ["ValveBiped.Bip01_R_Finger3"] = true,
    ["ValveBiped.Bip01_R_Finger31"] = true,
    ["ValveBiped.Bip01_R_Finger32"] = true,

    ["ValveBiped.Bip01_R_Finger4"] = true,
    ["ValveBiped.Bip01_R_Finger41"] = true,
    ["ValveBiped.Bip01_R_Finger42"] = true,

    -- Wrists
    ["ValveBiped.Bip01_L_Wrist"] = true,
    ["ValveBiped.Bip01_R_Wrist"] = true,

    -- Hands
    ["ValveBiped.Bip01_L_Hand"] = true,
    ["ValveBiped.Bip01_R_Hand"] = true,

    -- Whatever this is
    ["ValveBiped.Anim_Attachment_LH"] = true,
    ["ValveBiped.Anim_Attachment_RH"] = true,

    -- Forearms
    ["ValveBiped.Bip01_L_Forearm"] = true,
    ["ValveBiped.Bip01_R_Forearm"] = true,

    -- fuckin ulnas or whatever
    ["ValveBiped.Bip01_L_Ulna"] = true,
    ["ValveBiped.Bip01_R_Ulna"] = true,

    -- Elbows
    ["ValveBiped.Bip01_L_Elbow"] = true,
    ["ValveBiped.Bip01_R_Elbow"] = true,
}

local headBones = {
    ["ValveBiped.Bip01_Head1"] = true,
    ["ValveBiped.Bip01_Neck1"] = true,
    ["ValveBiped.Bip01_Spine"] = true,
    ["ValveBiped.Bip01_Spine1"] = true,
    ["ValveBiped.Bip01_Spine2"] = true
}

return {
    hands = handBones,
    head = headBones
}
