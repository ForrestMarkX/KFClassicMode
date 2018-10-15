class ClassicWeapDef_M99 extends KFWeapDef_M99;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "M99 AMR";
    }
    
    return class'KFWeapDef_M99'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Rifle_M99"
    BuyPrice=3500
    AmmoPricePerMag=250
    EffectiveRange=100
}
