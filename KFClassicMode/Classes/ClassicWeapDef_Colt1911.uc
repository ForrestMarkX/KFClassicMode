class ClassicWeapDef_Colt1911 extends KFWeapDef_Colt1911;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "M1911";
    case "ITEMCATEGORY":
        return class'KFWeapDef_Colt1911'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "Match grade 45 caliber pistol. Good balance between power, ammo count and rate of fire.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_Colt1911"
    BuyPrice=350
    AmmoPricePerMag=16
    EffectiveRange=60
}
