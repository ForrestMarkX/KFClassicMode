class ClassicWeapDef_Kriss extends KFWeapDef_Kriss;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Schneidzekk";
    case "ITEMDESCRIPTION":
        return "The 'Zekk has a very high rate of fire and is equipped with the attachment for the Horzine medical darts.";
    }
    
    return class'KFWeapDef_Kriss'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_SMG_Kriss"
    BuyPrice=2750
    AmmoPricePerMag=10
    EffectiveRange=40
}
