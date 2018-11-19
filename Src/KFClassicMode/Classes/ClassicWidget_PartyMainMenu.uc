class ClassicWidget_PartyMainMenu extends KFGFxWidget_PartyMainMenu;

// Check which aspect of the slot has changed and update it
function GFxObject RefreshSlot(int SlotIndex, UniqueNetId PlayerUID)
{
    local string PlayerName,ReadablePlayerName;    
    local UniqueNetId AdminId;
    local bool bIsLeader;
    local bool bIsMyPlayer;
    local PlayerController PC;
    local GFxObject PlayerInfoObject;
    local KFPerk CurrentPerk;
    local string AvatarPath;


    PlayerInfoObject = CreateObject("Object");

    PC = GetPC();

    if(OnlineLobby != none)
    {
        OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);
    }
    
    //leader
    bIsLeader = (PlayerUID == AdminId && PlayerUID != ZeroUniqueId);
    PlayerInfoObject.SetBool("bLeader", bIsLeader);
    //my player
    bIsMyPlayer = OnlineLobby != none && OnlineLobby.GetMyId() == PlayerUID;
    PlayerInfoObject.SetBool("myPlayer", bIsMyPlayer);
    //perk info
    if(bIsMyPlayer)
    {
        CurrentPerk = KFPC.GetPerk();
        if (CurrentPerk != none)
        {            
            MemberSlots[SlotIndex].PerkClass = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo).CurrentPerkClass;
            
            PlayerInfoObject.SetString("perkLevel", CurrentPerk.GetLevel() @ClassicPerk_Base(CurrentPerk).static.GetPerkName() );
            PlayerInfoObject.SetString("perkIconPath", "img://"$PathName(ClassicPerk_Base(CurrentPerk).static.GetCurrentPerkIcon(CurrentPerk.GetLevel())));
        }
    }
    else
    {
        //muted
        PlayerInfoObject.SetBool("muted", PC.IsPlayerMuted(PlayerUID));
        //perk info
        if(MemberSlots[SlotIndex].PerkClass != none)
        {
            PlayerInfoObject.SetString("perkLevel", MemberSlots[SlotIndex].PerkLevel @MemberSlots[SlotIndex].PerkClass.default.PerkName);
            PlayerInfoObject.SetString("perkIconPath", "img://"$PathName(class<ClassicPerk_Base>(MemberSlots[SlotIndex].PerkClass).static.GetCurrentPerkIcon(byte(MemberSlots[SlotIndex].PerkLevel))));
        }
        
    }
    //player name 
    if(OnlineLobby != none)
    {
        PlayerName = OnlineLobby.GetFriendNickname(PlayerUID);
    }
    
    if (PlayerName == "")
    {
        ReadablePlayerName = PC.PlayerReplicationInfo.GetHumanReadableName();
        PlayerName = ReadablePlayerName == DefaultPlayerName ? DefaultPlayerName$SlotIndex : ReadablePlayerName;
    }
    PlayerInfoObject.SetString("playerName", PlayerName);
    //player icon

    if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) )
    {
        AvatarPath = KFPC.GetPS4Avatar(PlayerName);
    }
    else
    {
        AvatarPath = KFPC.GetSteamAvatar(PlayerUID);
    }    

    if(AvatarPath != "")
    {
        PlayerInfoObject.SetString("profileImageSource", "img://"$AvatarPath);
    }

    MemberSlots[SlotIndex].PlayerUID = PlayerUID;    

    return PlayerInfoObject;
}

defaultproperties
{
    
}