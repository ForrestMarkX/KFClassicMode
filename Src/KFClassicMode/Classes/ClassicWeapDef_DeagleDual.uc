class ClassicWeapDef_DeagleDual extends KFWeapDef_DeagleDual;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Dual HCs";
    }
    
    return class'KFWeapDef_DeagleDual'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_DualDeagle"
    BuyPrice=1000
    AmmoPricePerMag=30
    EffectiveRange=60
}
