class ClassicWeap_Edged_Katana extends KFWeap_Edged_Katana;

simulated function SetMeleeParticleTrails()
{
    WhiteTrailParticle = (WorldInfo.TimeDilation < 1.f ? default.RedTrailParticle : default.WhiteTrailParticle);
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
        SetMeleeParticleTrails();
        return (ChainCount + 1) < MaxChainAtkCount;
    }
}

defaultproperties
{
    Begin Object Name=MeleeHelper_0
        MaxHitRange=95
    End Object
    
    FireInterval(DEFAULT_FIREMODE)=+0.67
    InstantHitDamage(DEFAULT_FIREMODE)=135
    
    FireInterval(HEAVY_ATK_FIREMODE)=+1.0
    InstantHitDamage(HEAVY_ATK_FIREMODE)=205
    
    FireInterval(BLOCK_FIREMODE)=+1.0

    // Inventory
    GroupPriority=110
    InventorySize=3
    
    ParryStrength=3
    
    MaxChainAtkCount=100
}
