class ClassicWeapDef_DragonsBreath extends KFWeapDef_DragonsBreath;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_DragonsBreath'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Shotgun_DragonsBreath"
    BuyPrice=1250
    AmmoPricePerMag=20
    EffectiveRange=15
}
