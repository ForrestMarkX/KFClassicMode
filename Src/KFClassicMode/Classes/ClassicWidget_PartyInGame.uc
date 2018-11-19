class ClassicWidget_PartyInGame extends KFGFxWidget_PartyInGame_Versus;

// Check which aspect of the slot has changed and update it
function GFxObject RefreshSlot( int SlotIndex, KFPlayerReplicationInfo KFPRI )
{
       local byte CurrentTeamIndex;
    local string PlayerName;    
    local UniqueNetId AdminId;
    local bool bIsLeader;
    local bool bIsMyPlayer;
    local PlayerController PC;
    local GFxObject PlayerInfoObject, PerkIconObject;

    CurrentTeamIndex = KFPRI.GetTeamNum();
    PlayerInfoObject = CreateObject("Object");

    PC = GetPC();

    if(OnlineLobby != none)
    {
        OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);
    }
    
    //leader
    bIsLeader = (KFPRI.UniqueId == AdminId && KFPRI.UniqueId != ZeroUniqueId);
    PlayerInfoObject.SetBool("bLeader", bIsLeader);
    //my player
    bIsMyPlayer = PC.PlayerReplicationInfo.UniqueId == KFPRI.UniqueId;
    MemberSlots[SlotIndex].PlayerUID = KFPRI.UniqueId;
    MemberSlots[SlotIndex].PRI = KFPRI;
    MemberSlots[SlotIndex].PerkClass = KFPRI.CurrentPerkClass;
    MemberSlots[SlotIndex].PerkLevel = String(KFPRI.GetActivePerkLevel());
    PlayerInfoObject.SetBool("myPlayer", bIsMyPlayer);

    //perk info
    if(MemberSlots[SlotIndex].PerkClass != none)
    {
        PerkIconObject = CreateObject("Object");
        if( CurrentTeamIndex == 255 ) //zed team
           {
            PerkIconObject.SetString("perkIcon", "img://"$PathName(ZedIConTexture));
               MemberSlots[SlotIndex].PerkClass = class'KFPerk_Monster';
           }
           else//human team
           {
            PlayerInfoObject.SetString("perkLevel", MemberSlots[SlotIndex].PerkLevel @MemberSlots[SlotIndex].PerkClass.default.PerkName); //separate from icon

            PerkIconObject = CreateObject("Object");
            PerkIconObject.SetString("perkIcon", "img://"$PathName(class<ClassicPerk_Base>(MemberSlots[SlotIndex].PerkClass).static.GetCurrentPerkIcon(byte(MemberSlots[SlotIndex].PerkLevel))));
           }
        PlayerInfoObject.SetObject("perkImageSource", PerkIconObject);
    }

    //perk info
    if(!bIsMyPlayer)
    {
        PlayerInfoObject.SetBool("muted", PC.IsPlayerMuted(KFPRI.UniqueId));    
    }
    
    // E3 build force update of player name
    if( class'WorldInfo'.static.IsE3Build() )
    {
        // Update this slots player name
        PlayerName = KFPRI.PlayerName;
    }
    else
    {
        PlayerName = KFPRI.PlayerName;
    }
    PlayerInfoObject.SetString("playerName", PlayerName);
    //player icon
    if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) )
    {
        PlayerInfoObject.SetString("profileImageSource", "img://"$KFPC.GetPS4Avatar(PlayerName));
    }
    else
    {
        PlayerInfoObject.SetString("profileImageSource", "img://"$KFPC.GetSteamAvatar(KFPRI.UniqueId));
    }    
    if(KFGRI != none)
    {
        PlayerInfoObject.SetBool( "ready", KFPRI.bReadyToPlay );
    }

    return PlayerInfoObject;    
}

DefaultProperties
{
}