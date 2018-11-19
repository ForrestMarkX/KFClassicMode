class ClassicWeapDef_Seeker6 extends KFWeapDef_Seeker6;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMDESCRIPTION":
        return "An advanced Horzine mini missile launcher. Fire one, or all six, lock on and let 'em rip!";
    }
    
    return class'KFWeapDef_Seeker6'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_RocketLauncher_Seeker6"
    BuyPrice=2250
    AmmoPricePerMag=15
    EffectiveRange=95
}
