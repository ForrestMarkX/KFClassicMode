class ClassicWeapDef_DragonsBreath extends KFWeapDef_DragonsBreath;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Trenchgun";
    case "ITEMCATEGORY":
        return class'KFWeapDef_DragonsBreath'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "A WWII era trench shotgun. Oh, this one has been filled with dragon's breath flame rounds.";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_DragonsBreath"
    BuyPrice=1250
    AmmoPricePerMag=20
    EffectiveRange=15
}
