class ClassicWeapDef_M99 extends KFWeapDef_M99;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "M99 AMR";
    case "ITEMCATEGORY":
        return class'KFWeapDef_M99'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "M99 50 Caliber Single Shot Sniper Rifle - The ultimate in long range accuracy and knock down power.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Rifle_M99"
    BuyPrice=3500
    AmmoPricePerMag=250
    EffectiveRange=100
}
