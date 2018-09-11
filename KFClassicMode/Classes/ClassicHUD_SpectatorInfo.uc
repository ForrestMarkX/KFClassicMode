class ClassicHUD_SpectatorInfo extends KFGFxHUD_SpectatorInfo;

function UpdatePlayerInfo(optional bool bForceUpdate)
{
    local GFxObject TempObject, PerkIconObject;
    local byte CurrentPerkLevel;

    if(SpectatedKFPRI == none)
    {
        return;
    }

    CurrentPerkLevel = SpectatedKFPRI.GetActivePerkLevel();

    // Update the perk class.
    if( ( LastPerkClass != SpectatedKFPRI.CurrentPerkClass ) || ( LastPerkLevel != CurrentPerkLevel ) || bForceUpdate )
    {
        LastPerkLevel = CurrentPerkLevel;
        LastPerkClass = SpectatedKFPRI.CurrentPerkClass;
        TempObject = CreateObject("Object");
        if( TempObject != none )
        {
            TempObject.SetString("playerName", SpectatedKFPRI.PlayerName);
            TempObject.SetString("playerPerk", SpectatedKFPRI.CurrentPerkClass.default.LevelString @SpectatedKFPRI.GetActivePerkLevel() @class<ClassicPerk_Base>(SpectatedKFPRI.CurrentPerkClass).static.GetPerkName() );
            
            PerkIconObject = CreateObject("Object");
            PerkIconObject.SetString("perkIcon", "img://"$PathName(class<ClassicPerk_Base>(SpectatedKFPRI.CurrentPerkClass).static.GetCurrentPerkIcon(CurrentPerkLevel)));
            TempObject.SetObject("perkImageSource", PerkIconObject);
        
            SetObject("playerData", TempObject);
        }
    }
}

function TickHud(float DeltaTime);

DefaultProperties
{
}
