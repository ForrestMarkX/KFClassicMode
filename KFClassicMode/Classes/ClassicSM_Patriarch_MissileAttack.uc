class ClassicSM_Patriarch_MissileAttack extends KFSM_Patriarch_MissileAttack;

function FireMissiles()
{
	local KFProj_Missile_Patriarch Missile;
	local Array<KFProj_Missile_Patriarch> FiredMissiles;
	local vector SpawnLoc, TargetLoc, AimDir;
	local rotator SpawnRot;
	local float CurlForceMultiplier;

	CurlForceMultiplier = 1.f + fRand()*0.1;
	
	MyPatPawn.Mesh.GetSocketWorldLocationAndRotation( Name( BaseSocketName$String(1) ), SpawnLoc, SpawnRot );
	Missile = MyPatPawn.Spawn( MissileClass, MyPatPawn,, SpawnLoc, SpawnRot,, true );
	
	GetAimDirAndTargetLoc( 1, SpawnLoc, SpawnRot, AimDir, TargetLoc );

	Missile.bCurl = 1;
	Missile.StartCurlTimer();

	Missile.InitEx( AimDir, CurlForceMultiplier, TargetLoc, InitialMissileSpeed, SeekDelay, SeekForce, GravForce, DistToApplyGravitySQ );
	FiredMissiles[FiredMissiles.Length] = Missile;
}

defaultproperties
{
   	bMissileFlocking=false
}