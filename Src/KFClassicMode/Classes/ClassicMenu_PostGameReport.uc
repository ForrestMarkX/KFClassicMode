class ClassicMenu_PostGameReport extends KFGFxMenu_PostGameReport;

function SetPlayerInfo()
{
    local GFxObject TextObject;
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(GetPC());

    TextObject = CreateObject("Object");
    if(KFPC.PlayerReplicationInfo.GetTeamNum() != 255)
    {
        TextObject.SetString("playerName", KFPC.PlayerReplicationInfo.PlayerName);
        TextObject.SetString("perkIcon", "img://"$PathName(ClassicPerk_Base(KFPC.CurrentPerk).static.GetCurrentPerkIcon(KFPC.GetLevel())));
        TextObject.SetString("perkName", ClassicPerk_Base(KFPC.CurrentPerk).static.GetPerkName());
        TextObject.SetInt("perkLevel", KFPC.GetLevel());
    }
    else
    {
        TextObject.SetString("playerName", KFPC.PlayerReplicationInfo.PlayerName);
        TextObject.SetString("perkIcon", "img://"$PathName(class'KFGFxWidget_PartyInGame_Versus'.default.ZedIConTexture));
        TextObject.SetString("perkName", class'KFCommon_LocalizedStrings'.default.ZedString);
        TextObject.SetInt("perkLevel", 0);
    }

    SetObject("playerInfo", TextObject);
}

defaultproperties
{
    SubWidgetBindings.Remove((WidgetName="playerXPContainer",WidgetClass=class'KFGFxPostGameContainer_PlayerXP'))
    SubWidgetBindings.Add((WidgetName="playerXPContainer",WidgetClass=class'ClassicPostGameContainer_PlayerXP'))
}