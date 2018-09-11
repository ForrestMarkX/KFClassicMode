class ClassicWeapDef_M14EBR extends KFWeapDef_M14EBR;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "M14EBR";
    case "ITEMCATEGORY":
        return class'KFWeapDef_M14EBR'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "Updated M14 Enhanced Battle Rifle - Semi Auto variant. Equipped with a laser sight.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Rifle_M14EBR"
    BuyPrice=2500
    AmmoPricePerMag=15
    EffectiveRange=95
}
