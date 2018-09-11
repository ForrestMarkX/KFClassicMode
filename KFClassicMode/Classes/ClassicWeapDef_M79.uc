class ClassicWeapDef_M79 extends KFWeapDef_M79;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "M79";
    case "ITEMCATEGORY":
        return class'KFWeapDef_M79'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "A classic Vietnam era grenade launcher. Launches single high explosive grenades.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_GrenadeLauncher_M79"
    BuyPrice=1250
    AmmoPricePerMag=10
    EffectiveRange=75
}
