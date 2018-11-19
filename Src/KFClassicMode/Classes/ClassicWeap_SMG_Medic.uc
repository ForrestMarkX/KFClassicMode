class ClassicWeap_SMG_Medic extends KFWeap_SMG_Medic;

simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
    return Super(KFWeapon).SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
}

function CheckTargetLock();

defaultproperties
{
    AssociatedPerkClasses(1)=class'KFPerk_FieldMedic'
}
