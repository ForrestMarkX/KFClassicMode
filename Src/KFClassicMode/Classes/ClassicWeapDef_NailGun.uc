class ClassicWeapDef_Nailgun extends KFWeapDef_Nailgun;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Vlad the Impaler";
    }
    
    return class'KFWeapDef_Nailgun'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_Nailgun"
    BuyPrice=1500
    AmmoPricePerMag=30
    EffectiveRange=25
}
