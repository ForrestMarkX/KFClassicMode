class ClassicWeapDef_Deagle extends KFWeapDef_Deagle;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Handcannon";
    }
    
    return class'KFWeapDef_Deagle'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_Deagle"
    BuyPrice=500
    AmmoPricePerMag=15
    EffectiveRange=60
}
