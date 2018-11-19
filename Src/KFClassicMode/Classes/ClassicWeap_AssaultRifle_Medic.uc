class ClassicWeap_AssaultRifle_Medic extends KFWeap_AssaultRifle_Medic;

simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
    return Super(KFWeapon).SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
}

function CheckTargetLock();

defaultproperties
{
       AssociatedPerkClasses(1)=class'KFPerk_FieldMedic'
}
