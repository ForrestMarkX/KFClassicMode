class ClassicWeapDef_FlareGun extends KFWeapDef_FlareGun;

static function string GetItemLocalization( string KeyName )
{
    switch( Caps(KeyName) )
    {
    case "ITEMNAME":
        return "Flare Revolver";
    case "ITEMCATEGORY":
        return class'KFWeapDef_FlareGun'.Static.GetItemLocalization(KeyName);
    case "ITEMDESCRIPTION":
        return "Flare Revolver. A classic wild west revolver modified to shoot fireballs!";
    }
}

DefaultProperties
{
    WeaponClassPath="KFClassicMode.ClassicWeap_Pistol_Flare"
    BuyPrice=500
    AmmoPricePerMag=13
    EffectiveRange=65
}
