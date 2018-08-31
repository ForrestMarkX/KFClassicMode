class ClassicWeap_Edged_Zweihander extends KFWeap_Edged_Zweihander;

simulated function SetMeleeParticleTrails()
{
	WhiteTrailParticle = (WorldInfo.TimeDilation < 1.0 ? default.RedTrailParticle : default.WhiteTrailParticle);
}

simulated state MeleeHeavyAttacking
{
	simulated function BeginState( Name PreviousStateName )
	{
		SetMeleeParticleTrails();
		Super.BeginState(PreviousStateName);
	}
	
	simulated function EndState( Name NextStateName )
	{
		Super.EndState(NextStateName);
		PlayMeleeSettleAnim();
		if( PendingFire(DEFAULT_FIREMODE) && PendingFire(HEAVY_ATK_FIREMODE) )
		{
			ClearPendingFire(HEAVY_ATK_FIREMODE);
		}
	}
	
	simulated function name GetMeleeAnimName( KFPawn.EPawnOctant AtkDir, KFMeleeHelperWeapon.EMeleeAttackType AtkType )
	{
		UpdateWeaponAttachmentAnimRate(GetThirdPersonAnimRate());
		KFPawn(Instigator).WeaponStateChanged(GetWeaponStateId());
		return Super.GetMeleeAnimName(AtkDir, AtkType);
	}

	simulated function bool ShouldContinueMelee( optional int ChainCount )
	{
		if ( PendingFire(DEFAULT_FIREMODE) )
		{
			return false;
		}

		if ( !ShouldRefire() )
		{
			return false;
		}
		SetMeleeParticleTrails();
		return (ChainCount + 1) < MaxChainAtkCount;
	}
}

defaultproperties
{
	Begin Object Name=MeleeHelper_0
		MaxHitRange=110
	End Object
	
	FireInterval(DEFAULT_FIREMODE)=+1.05
	InstantHitDamage(DEFAULT_FIREMODE)=210
	
	FireInterval(HEAVY_ATK_FIREMODE)=+1.25
	InstantHitDamage(HEAVY_ATK_FIREMODE)=320
	
	FireInterval(BLOCK_FIREMODE)=+1.0

	// Inventory
	GroupPriority=115
	InventorySize=6
	
	ParryStrength=4
	
	MaxChainAtkCount=100
}
