class ClassicWeap_Rifle_CenterfireMB464 extends KFWeap_Rifle_CenterfireMB464;

defaultproperties
{
    // Inventory / Grouping
    InventorySize=6
    GroupPriority=155
    
       AssociatedPerkClasses(1)=class'KFPerk_Sharpshooter'
    
    // Ammo
    InitialSpareMags[0]=3

    // Recoil
    RecoilRate=0.12

    // DEFAULT_FIREMODE
    InstantHitDamage(DEFAULT_FIREMODE)=180
    FireInterval(DEFAULT_FIREMODE)=0.94
    Spread(DEFAULT_FIREMODE)=0.005
}
