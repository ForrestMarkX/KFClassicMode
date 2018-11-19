class ClassicWeap_HuskCannon extends KFWeap_HuskCannon;

defaultproperties
{
    // Inventory
    InventorySize=8
    GroupPriority=80
    
    //Gameplay Props
    //MaxChargeTime=3.0
    DmgIncreasePerCharge=1.0
    AOEIncreasePerCharge=0.4
    IncapIncreasePerCharge=0.24

    // Ammo
    MagazineCapacity[0]=25
    SpareAmmoCapacity[0]=150
    InitialSpareMags[0]=3
    AmmoPickupScale[0]=1.0

    // Recoil
    RecoilRate=0.05

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.75
    Spread(DEFAULT_FIREMODE) = 0.015
    Spread(ALTFIRE_FIREMODE) = 0.015
    
    AssociatedPerkClasses(1)= class'KFPerk_Firebug'
}