class ClassicPawn_ZedStalker_Default extends KFPawn_ZedStalker implements(KFZEDInterface);

`define OVERRIDEHEADEXPLODEFUNC true
`define PLAYENTRANCESOUND true
`include(ClassicMonster.uci);

simulated function PlayHeadAsplode()
{
	local KFGoreManager GoreManager;
	local name BoneName;
    
	if( bIsCloaking )
		SetCloaked(false);
	bCanCloak = false;
    
	if (IsAliveAndWell())
		return;

	if( HitZones[HZI_Head].bPlayedInjury )
		return;

	if ( (bTearOff || bPlayedDeath) && TimeOfDeath > 0 && `TimeSince(TimeOfDeath) > 0.75 )
		return;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager != none && GoreManager.AllowHeadless() )
	{
		if( !bIsGoreMesh && !bDisableHeadless )
		{
			SwitchToGoreMesh();
		}
	}

	if( bIsGoreMesh && GoreManager != none )
	{
        BoneName = HitZones[HZI_Head].BoneName;
		GoreManager.CrushBone( self, BoneName );
        SoundGroupArch.PlayHeadPopSounds( self, mesh.GetBoneLocation(BoneName) );
		HitZones[HZI_Head].bPlayedInjury = true;
	}

	SpawnHeadShotEffect(KFPlayerReplicationInfo(HitFxInfo.DamagerPRI));
}

DefaultProperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_Stalker_Archetype'
    
    ElitePawnClass.Empty
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_EMP_Default')
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_Laser_Default')
    ElitePawnClass.Add(class'ClassicPawn_ZedDAR_Rocket_Default')
}
