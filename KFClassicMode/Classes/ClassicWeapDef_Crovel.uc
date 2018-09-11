class ClassicWeapDef_Crovel extends KFWeapDef_Crovel;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Grovel";
    case "ITEMCATEGORY":
        return class'KFWeapDef_Crovel'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "A grovel - commonly used for hacking through brush, or the limbs of ZEDs.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Blunt_Crovel"
    BuyPrice=500
    EffectiveRange=3
}