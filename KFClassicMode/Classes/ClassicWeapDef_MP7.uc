class ClassicWeapDef_MP7 extends KFWeapDef_MP7;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "MP7M";
    case "ITEMDESCRIPTION":
        return "Prototype sub machine gun. Modified to fire healing darts.";
    }
    
    return class'KFWeapDef_MP7'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_SMG_MP7"
    BuyPrice=825
    AmmoPricePerMag=10
    EffectiveRange=45
}
