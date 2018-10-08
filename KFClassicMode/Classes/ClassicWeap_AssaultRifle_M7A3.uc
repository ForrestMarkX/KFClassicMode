class ClassicWeap_AssaultRifle_M7A3 extends KFWeap_AssaultRifle_MedicRifleGrenadeLauncher;

defaultproperties
{
    // Healing charge
    HealAmount=30
    
    // Ammo
    MagazineCapacity[0]=15
    SpareAmmoCapacity[0]=300
    InitialSpareMags[0]=10
    
    InitialSpareMags[1]=3
    MagazineCapacity[1]=1
    SpareAmmoCapacity[1]=9
    AmmoPickupScale[1]=2.0
    
    //Recoil
    RecoilRate=0.085
    
    // Inventory
    InventorySize=6
    GroupPriority=100

    // DEFAULT_FIREMODE
    FireInterval(DEFAULT_FIREMODE)=+0.166
    InstantHitDamage(DEFAULT_FIREMODE)=70.0

    // ALTFIRE_FIREMODE
    FireInterval(ALTFIRE_FIREMODE)=+0.5f
    
    AssociatedPerkClasses(1)=class'KFPerk_FieldMedic'
}
