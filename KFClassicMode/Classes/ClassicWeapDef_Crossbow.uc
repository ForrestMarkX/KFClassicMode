class ClassicWeapDef_Crossbow extends KFWeapDef_Crossbow;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Crossbow";
    case "ITEMCATEGORY":
        return class'KFWeapDef_Crossbow'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "Recreational hunting weapon, equipped with powerful scope and firing trigger. Exceptional headshot damage.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Bow_Crossbow"
    BuyPrice=800
    AmmoPricePerMag=20
    EffectiveRange=100
}
