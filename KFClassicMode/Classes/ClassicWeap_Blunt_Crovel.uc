class ClassicWeap_Blunt_Crovel extends KFWeap_Blunt_Crovel;

simulated state MeleeHeavyAttacking
{
	simulated function EndState( Name NextStateName )
	{
		Super.EndState(NextStateName);
		PlayMeleeSettleAnim();
		
		if( PendingFire(DEFAULT_FIREMODE) && PendingFire(HEAVY_ATK_FIREMODE) )
		{
			ClearPendingFire(HEAVY_ATK_FIREMODE);
		}
	}
	
	simulated function name GetMeleeAnimName( EPawnOctant AtkDir, EMeleeAttackType AtkType )
	{
		UpdateWeaponAttachmentAnimRate( GetThirdPersonAnimRate() );
		KFPawn(Instigator).WeaponStateChanged( GetWeaponStateId() );
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
		return (ChainCount + 1) < MaxChainAtkCount;
	}
}

defaultproperties
{
	Begin Object Name=MeleeHelper_0
		MaxHitRange=80
	End Object

    // Inventory
	GroupPriority=50
	InventorySize=1
	
	InstantHitDamage(DEFAULT_FIREMODE)=70
	FireInterval(DEFAULT_FIREMODE)=+0.71
	
	InstantHitDamage(HEAVY_ATK_FIREMODE)=130
	FireInterval(HEAVY_ATK_FIREMODE)=+1.1
	
	FireInterval(BLOCK_FIREMODE)=+1.0
	
	ParryStrength=2
	BlockDamageMitigation=0.7
	
	MaxChainAtkCount=100
}
