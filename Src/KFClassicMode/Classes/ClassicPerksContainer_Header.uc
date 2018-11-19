class ClassicPerksContainer_Header extends KFGFxPerksContainer_Header;

function UpdatePerkHeader( class<KFPerk> PerkClass)
{    
    local GFxObject PerkDataProvider, PerkIconObject;
    local ClassicPlayerController KFPC;
    local ClassicPerk_Base Perk;
    local string S;
    
    KFPC = ClassicPlayerController(GetPC());
    if( KFPC.PerkManager != None )
    {
        Perk = KFPC.PerkManager.FindPerk(PerkClass);
        if( Perk != None )
        {
            if( Perk.GetLevel() == Perk.MaximumLevel )
                S = string(Perk.CurrentEXP);
            else S = Perk.CurrentEXP$"/"$Perk.NextLevelEXP;

            PerkDataProvider = CreateObject( "Object" );

            PerkIconObject = CreateObject( "Object" );
            PerkIconObject.SetString( "perkIcon", "img://"$PathName(Perk.static.GetCurrentPerkIcon(Perk.GetLevel())) );

            PerkDataProvider.SetObject( "perkData", PerkIconObject );
            PerkDataProvider.SetString( "perkTitle", Perk.static.GetPerkName() );
            PerkDataProvider.SetString( "perkLevel", LevelString@Perk.GetLevel() );
            PerkDataProvider.SetString( "xpString",  S );
            PerkDataProvider.SetFloat( "xpPercent", Perk.GetProgressPercent() );
            SetObject( "perkData", PerkDataProvider );
        }
    }
}

defaultproperties
{
}