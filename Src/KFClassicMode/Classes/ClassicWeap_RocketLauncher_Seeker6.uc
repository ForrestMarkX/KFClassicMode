class ClassicWeap_RocketLauncher_Seeker6 extends KFWeap_RocketLauncher_Seeker6;

var protected const array<vector2D> PelletSpread;

simulated function AltFireMode()
{
    // LocalPlayer Only
    if ( !Instigator.IsLocallyControlled()  )
    {
        return;
    }

    StartFire(ALTFIRE_FIREMODE);
}

simulated function name GetReloadAnimName( bool bTacticalReload )
{
    return bTacticalReload ? 'Reload_Empty_Elite' : 'Reload_Empty';
}

simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
    local int i;
    local rotator AimRot;

    AimRot = rotator(AimDir);
    for (i = 0; i < GetNumProjectilesToFire(CurrentFireMode); i++)
    {
        Super.SpawnProjectile(KFProjClass, RealStartLoc, vector(AddMultiShotSpread(AimRot, Spread[CurrentFireMode], i)));
    }

    return None;
}

static function rotator AddMultiShotSpread( rotator BaseAim, float CurrentSpread, byte PelletNum )
{
	local vector X, Y, Z;
	local float RandY, RandZ;

	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		RandY = default.PelletSpread[PelletNum].Y * RandRange( 0.5f, 1.5f );
		RandZ = default.PelletSpread[PelletNum].X * RandRange( 0.5f, 1.5f );
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}
}

function HandleWeaponShotTaken( byte FireMode )
{
    if( KFPlayer != None )
    {
        KFPlayer.AddShotsFired(GetNumProjectilesToFire( FireMode ));
    }
}

simulated function byte GetNumProjectilesToFire(byte FireModeNum)
{    
    if( FireModeNum == ALTFIRE_FIREMODE )
        return AmmoCount[DEFAULT_FIREMODE];
        
    return 1;
}

simulated function ConsumeAmmo( byte FireModeNum )
{
    local byte AmmoType;
    local byte ACost;
    local KFPerk InstigatorPerk;
    
    if( bInfiniteAmmo )
    {
        return;
    }

    AmmoType = GetAmmoType(FireModeNum);

    InstigatorPerk = GetPerk();
    if( InstigatorPerk != none && InstigatorPerk.GetIsUberAmmoActive( self ) )
    {
        return;
    }

    if ( Role == ROLE_Authority || bAllowClientAmmoTracking )
    {
        if (MagazineCapacity[AmmoType] > 0 && AmmoCount[AmmoType] > 0)
        {
            if( FireModeNum == ALTFIRE_FIREMODE )
            {
                ACost = AmmoCount[DEFAULT_FIREMODE];
            }
            else
            {
                ACost = AmmoCost[FireModeNum];
            }
            
            AmmoCount[AmmoType] = Max(AmmoCount[AmmoType] - ACost, 0);
        }
    }
}

simulated event bool HasAmmo( byte FireModeNum, optional int Amount )
{
    local KFPerk InstigatorPerk;
    
    // we can always do a melee attack
    if( FireModeNum == BASH_FIREMODE )
    {
        return TRUE;
    }
    else if ( FireModeNum == RELOAD_FIREMODE )
    {
        return CanReload();
    }
    else if ( FireModeNum == GRENADE_FIREMODE )
    {
        if( KFInventoryManager(InvManager) != none )
        {
            return KFInventoryManager(InvManager).HasGrenadeAmmo(Amount);
        }
    }

    InstigatorPerk = GetPerk();
    if( InstigatorPerk != none && InstigatorPerk.GetIsUberAmmoActive( self ) )
    {
        return true;
    }

    // If passed in ammo isn't set, use default ammo cost.
    if( Amount == 0 )
    {
        if( FireModeNum == ALTFIRE_FIREMODE )
        {
            Amount = AmmoCount[DEFAULT_FIREMODE];
        }
        else
        {
            Amount = AmmoCost[FireModeNum];
        }
    }

    return AmmoCount[GetAmmoType(FireModeNum)] >= Amount;
}

defaultproperties
{
    // Inventory
    InventorySize=7
    GroupPriority=182

    // Ammo
    SpareAmmoCapacity[0]=90
    InitialSpareMags[0]=7
    AmmoPickupScale[0]=1.0

    // DEFAULT_FIREMODE
    WeaponProjectiles(DEFAULT_FIREMODE)=class'ClassicProj_Rocket_Seeker6'
    FireInterval(DEFAULT_FIREMODE)=+0.33
    InstantHitDamage(DEFAULT_FIREMODE)=75.0
    Spread(DEFAULT_FIREMODE)=0.015

    // ALT_FIREMODE
    FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'UI_FireModes_TEX.UI_FireModeSelect_Rocket'
    FiringStatesArray(ALTFIRE_FIREMODE)=WeaponFiring
    WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
    WeaponProjectiles(ALTFIRE_FIREMODE)=class'ClassicProj_Rocket_Seeker6'
    FireInterval(ALTFIRE_FIREMODE)=+0.35
    InstantHitDamage(ALTFIRE_FIREMODE)=120.0 //100.00
    InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_Seeker6Impact'
    Spread(ALTFIRE_FIREMODE)=0.05
    FireOffset=(X=20,Y=4.0,Z=-3)
    
    PelletSpread(0)=(X=0.f,Y=0.f)
    PelletSpread(1)=(X=0.5f,Y=0.f)             //0deg 
    PelletSpread(2)=(X=0.3214,Y=0.3830)     //60deg
    PelletSpread(3)=(X=-0.25,Y=0.4330)        //120deg
    PelletSpread(4)=(X=-0.5f,Y=0.f)            //180deg
    PelletSpread(5)=(X=-0.25f,Y=-0.4330)    //240deg
    PelletSpread(6)=(X=0.25,Y=-0.4330)        //300deg
}
