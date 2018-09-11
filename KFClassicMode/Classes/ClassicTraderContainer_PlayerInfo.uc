class ClassicTraderContainer_PlayerInfo extends KFGFxTraderContainer_PlayerInfo;

function SetPerkInfo()
{
    local KFPerk CurrentPerk;
    local KFPlayerController KFPC;
    local GFxObject PerkIconObject;

    KFPC = KFPlayerController(GetPC());
    if (KFPC != none)
    {
        CurrentPerk = KFPC.CurrentPerk;
         SetString("perkName", ClassicPerk_Base(CurrentPerk).static.GetPerkName());
         SetInt("perkLevel", CurrentPerk.GetLevel());
         SetInt("xpBarValue", ClassicPerk_Base(CurrentPerk).GetProgressPercent() * 100);

        PerkIconObject = CreateObject("Object");
        PerkIconObject.SetString("perkIcon", "img://"$PathName(ClassicPerk_Base(CurrentPerk).static.GetCurrentPerkIcon(CurrentPerk.GetLevel())));

        SetObject("perkImageSource", PerkIconObject);
    }
}

function SetPerkList()
{
    local GFxObject PerkObject;
    local GFxObject DataProvider;
    local ClassicPlayerController KFPC;
    local byte i;
    local ClassicPerk_Base Perk;

    KFPC = ClassicPlayerController(GetPC());
    if (KFPC != none)
    {
        DataProvider = CreateArray();

        for (i = 0; i < KFPC.PerkList.Length; i++)
        {
            Perk = KFPC.PerkManager.FindPerk(KFPC.PerkList[i].PerkClass);
            
            if( Perk != None )
            {
                PerkObject = CreateObject( "Object" );
                PerkObject.SetString("name", Perk.static.GetPerkName());
                PerkObject.SetString("perkIconSource",  "img://"$PathName(Perk.static.GetCurrentPerkIcon(Perk.GetLevel())));
                PerkObject.SetInt("level", Perk.GetLevel());
                PerkObject.SetInt("perkXP", Perk.GetProgressPercent() * 100);

                DataProvider.SetElementObject(i, PerkObject);
            }
        }

        SetObject("perkList", DataProvider);
    }
}