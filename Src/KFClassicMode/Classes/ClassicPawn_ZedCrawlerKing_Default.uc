class ClassicPawn_ZedCrawlerKing_Default extends KFPawn_ZedCrawlerKing implements(KFZEDInterface);

`define PLAYENTRANCESOUND true
`define OVERRIDEHEADEXPLODEFUNC true
`include(ClassicMonster.uci);

simulated function PlayHeadAsplode()
{
	local KFGoreManager GoreManager;
	local name BoneName;
    
    CancelExplosion();
    
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

defaultproperties
{
    MonsterArchPath=""
    CharacterMonsterArch=KFCharacterInfo_Monster'ZED_ARCH.ZED_CrawlerKing_Archetype'
}