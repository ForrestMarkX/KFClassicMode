class ClassicWeapDef_AbominationAxe extends KFWeaponDefinition
    abstract;

static function string GetItemLocalization( string KeyName )
{
    return class'KFWeapDef_AbominationAxe'.Static.GetItemLocalization(KeyName);
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Edged_AbominationAxe"
    
    BuyPrice=3000
    ImagePath="WEP_UI_KrampusAxe_TEX.UI_WeaponSelect_KrampusAxe"
    
    EffectiveRange=5
}
