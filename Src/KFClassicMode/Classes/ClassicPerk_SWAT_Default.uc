class ClassicPerk_SWAT_Default extends ClassicPerk_Base;

var const PerkSkill BulletResistance,MagSize,WeaponSwitchSpeed;

var int BumpDamageAmount;
var class<DamageType> BumpDamageType;
var float BumpMomentum;
var float SWATEnforcerZedTimeSpeedScale;
var float LastBumpTime;
var array<Actor> CurrentBumpedActors;
var float BumpCooldown;

function bool CanNotBeGrabbed()
{
    return IsHeavyArmorActive();
}

simulated function bool IsHeavyArmorActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool IsSpecialAmmunitionActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.5f);
}

simulated function bool IsTacticalMovementActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.25f);
}

function bool IsBodyArmorActive()
{
    return CurrentVetLevel >= int(MaximumLevel * 0.25f);
}

simulated function bool IsRapidAssaultActive()
{
    return CurrentVetLevel == MaximumLevel;
}

function bool IsSWATEnforcerActive()
{
    return CurrentVetLevel == MaximumLevel;
}

simulated function bool HasHeavyArmor()
{
    return IsHeavyArmorActive();
}

simulated function bool GetIsUberAmmoActive( KFWeapon KFW )
{
    return IsRapidAssaultActive() && (Is9mm(KFW) || IsWeaponOnPerk( KFW,, self.class ));
}

simulated function bool ShouldKnockDownOnBump()
{
    return IsSWATEnforcerActive() && WorldInfo.TimeDilation < 1.f;
}

simulated function OnBump(Actor BumpedActor, KFPawn_Human BumpInstigator, vector BumpedVelocity, rotator BumpedRotation)
{
    local KFPawn_Monster KFPM;
    local bool CanBump;

    if (ShouldKnockDownOnBump() && Normal(BumpedVelocity) dot Vector(BumpedRotation) > 0.7f)
    {
        KFPM = KFPawn_Monster(BumpedActor);
        if (KFPM != none)
        {
            if (`TimeSince(LastBumpTime) > BumpCooldown)
            {
                CurrentBumpedActors.length = 0;
                CurrentBumpedActors.AddItem(BumpedActor);
                CanBump = true;
            }
            else if (CurrentBumpedActors.Find(BumpedActor) == INDEX_NONE)
            {
                CurrentBumpedActors.AddItem(BumpedActor);
                CanBump = true;
            }

            LastBumpTime = WorldInfo.TimeSeconds;

            if (CanBump)
            {
                if (KFPM.CanDoSpecialMove(SM_Knockdown))
                {
                    KFPM.TakeDamage(BumpDamageAmount, BumpInstigator.Controller, BumpInstigator.Location, Normal(vector(BumpedRotation)) * BumpMomentum, BumpDamageType);
                    KFPM.Knockdown(BumpedVelocity * 3, vect(1, 1, 1), KFPM.Location, 1000, 100);
                }
                else if (KFPM.IsHeadless())
                {
                    KFPM.TakeDamage(KFPM.HealthMax, BumpInstigator.Controller, BumpInstigator.Location, Normal(vector(BumpedRotation)) * BumpMomentum, BumpDamageType);
                }
                else if (KFPM.CanDoSpecialMove(SM_Stumble))
                {
                    KFPM.TakeDamage(BumpDamageAmount, BumpInstigator.Controller, BumpInstigator.Location, Normal(vector(BumpedRotation)) * BumpMomentum, BumpDamageType);
                    KFPM.DoSpecialMove(SM_Stumble, , , class'KFSM_Stumble'.static.PackRandomSMFlags(KFPM));
                }
                else
                {
                    KFPM.TakeDamage(BumpDamageAmount, BumpInstigator.Controller, BumpInstigator.Location, Normal(vector(BumpedRotation)) * BumpMomentum, BumpDamageType);
                }
            }
        }
    }
}

simulated function float GetZedTimeModifier( KFWeapon W )
{
    local name StateName;

    StateName = W.GetStateName();
    if( IsRapidAssaultActive() && (Is9mm(W) || IsWeaponOnPerk( W,, self.class )) )
    {
        if( ZedTimeModifyingStates.Find( StateName ) != INDEX_NONE )
        {
            return 0.51f;
        }
    }

    return 0.f;
}

function ModifyArmor( out byte MaxArmor )
{
    local float TempArmor;

    if( IsBodyArmorActive() )
    {
        TempArmor = MaxArmor;
        TempArmor += TempArmor * 0.5f;
        MaxArmor = Round( TempArmor );
    }
}

static simulated function bool Is9mm( KFWeapon KFW )
{
    return KFW != none && KFW.default.bIsBackupWeapon && !KFW.IsMeleeWeapon();
}

simulated event float GetIronSightSpeedModifier( KFWeapon KFW )
{
    if( IsTacticalMovementActive() && (Is9mm( KFW ) || IsWeaponOnPerk( KFW,, self.class )) )
    {
        return 2.5f;
    }

    return 1.f;
}

function float GetStumblePowerModifier( optional KFPawn KFP, optional class<KFDamageType> DamageType, optional out float CooldownModifier, optional byte BodyPart )
{
    local KFWeapon KFW;
    local float StumbleModifier;

    StumbleModifier = 0.f;

    KFW = GetOwnerWeapon();
    if( IsSpecialAmmunitionActive() && (Is9mm(KFW) || IsWeaponOnPerk( KFW,, self.class )) )
    {
        StumbleModifier += 2.f;
    }

    if( IsRapidAssaultActive() )
    {
        StumbleModifier += 1.f;
    }

    return StumbleModifier;
}

simulated function int GetArmorDamageAmount( int AbsorbedAmt )
{
    if( HasHeavyArmor() )
    {
        return Max(Round(AbsorbedAmt * 0.65f), 1);
    }

    return AbsorbedAmt;
}

function ApplySkillsToPawn()
{
    Super.ApplySkillsToPawn();

    if( OwnerPawn != none )
    {
        OwnerPawn.bMovesFastInZedTime = IsSWATEnforcerActive();
    }
}

function SetPlayerDefaults( Pawn PlayerPawn )
{
    local float NewArmor;

    Super.SetPlayerDefaults( PlayerPawn );

    if( OwnerPawn.Role == ROLE_Authority )
    {
        if( IsHeavyArmorActive() )
        {
            NewArmor += OwnerPawn.default.MaxArmor * 0.5f;
        }

        if( IsBodyArmorActive() )
        {
            NewArmor += OwnerPawn.default.MaxArmor * 0.5f;
        }

        OwnerPawn.AddArmor(Round(NewArmor));
    }
}

function ModifyDamageTaken( out int InDamage, optional class<DamageType> DamageType, optional Controller InstigatedBy )
{
    local float TempDamage;

    Super.ModifyDamageTaken(InDamage, DamageType, InstigatedBy);
    if( InDamage <= 0 )
        return;

    TempDamage = InDamage;

    if( ClassIsChildOf(DamageType, class'KFDT_Ballistic') && TempDamage > 0 )
    {
        TempDamage -= InDamage * GetPassiveValue(BulletResistance, CurrentVetLevel);
    }

    InDamage = Round(TempDamage);
}

simulated function ModifyWeaponSwitchTime( out float ModifiedSwitchTime )
{
    ModifiedSwitchTime *= 1.f - GetPassiveValue(WeaponSwitchSpeed, CurrentVetLevel);
}

simulated function ModifyMagSizeAndNumber( KFWeapon KFW, out int MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
    local float TempCapacity;

    TempCapacity = MagazineCapacity;

    if( !bSecondary && !Is9mm( KFW ) && IsWeaponOnPerk( KFW, WeaponPerkClass, self.class ) && (KFW == none || !KFW.bNoMagazine) )
    {
        TempCapacity += MagazineCapacity * GetPassiveValue(MagSize, CurrentVetLevel);
    }

    MagazineCapacity = Round(TempCapacity);
}

simulated function float GetCostScaling(byte Level, optional STraderItem TraderItem, optional KFWeapon Weapon)
{
    return 1.f;
}

simulated function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local class<KFWeaponDefinition> SpawnDef;

    S = default.CustomLevelInfo;

    ReplaceText(S,"%d",GetPercentStr(default.WeaponDamage, Level));
    ReplaceText(S,"%s",GetPercentStr(default.BulletResistance, Level));
    ReplaceText(S,"%b",GetPercentStr(default.MagSize, Level));
    ReplaceText(S,"%m",GetPercentStr(default.WeaponSwitchSpeed, Level));
    
    if( IsTacticalMovementActive() )
    {
        S = S $ "|Can move faster using ironsights";
    }
    
    if( IsBodyArmorActive() )
    {
        S = S $ "|Increased armor amount by 50% and spawn with 50 armor";
    }
    
    if( IsHeavyArmorActive() )
    {
        S = S $ "|Start with 50 more armor and armor absorbs all damage";
    }
    
    if( IsSpecialAmmunitionActive() )
    {
        S = S $ "|100% increase in stumble power";
    }    
    
    if( IsRapidAssaultActive() )
    {
        S = S $ "|Gain infinite ammo during ZED Time and shot almost in realtime";
    }    
    
    if( IsSWATEnforcerActive() )
    {
        S = S $ "|Move in realtime during ZED Time aswell as knocking down ZEDs";
    }
    
    SpawnDef = GetWeaponDef(Level);
    if( SpawnDef != None )
    {
        S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName();
    }

    return S;
}

simulated function GetPerkIcons(ObjectReferencer RepInfo)
{
    local int i;
    
    for (i = 0; i < OnHUDIcons.Length; i++)
    {
        OnHUDIcons[i].PerkIcon = Texture2D(RepInfo.ReferencedObjects[164]);
        OnHUDIcons[i].StarIcon = Texture2D(RepInfo.ReferencedObjects[28]);
    }
}

DefaultProperties
{
    BasePerk=class'KFPerk_SWAT'
    
    PrimaryWeaponDef=class'KFWeapDef_MP7'
    
    SecondaryWeaponPaths.Empty
    SecondaryWeaponPaths.Add(class'KFWeapDef_9mm')
    
    KnifeWeaponDef=class'KFweapDef_Knife_SWAT'
    GrenadeWeaponDef=class'KFWeapDef_Grenade_SWAT'
    
    BumpDamageAmount=450
    BumpDamageType=class'KFDT_SWATBatteringRam'
    BumpMomentum=1.f
    BumpCooldown = 0.1f
    
    AutoBuyLoadOutPath=(class'KFWeapDef_MP7', class'KFWeapDef_MP5RAS', class'KFWeapDef_P90', class'KFWeapDef_Kriss')
    
    EXPActions(0)="Dealing SWAT weapon damage"
    EXPActions(1)="Killing Zeds with a SWAT weapon"
    
    ZedTimeModifyingStates(0)="WeaponFiring"
       ZedTimeModifyingStates(1)="WeaponBurstFiring"
       ZedTimeModifyingStates(2)="WeaponSingleFiring"
    
    WeaponDamage=(Name="Weapon Damage",Increment=0.01f,Rank=0,StartingValue=1.f,MaxValue=1.25) //1.25
    BulletResistance=(Name="Bullet Resistance",Increment=0.01,Rank=0,StartingValue=0.05,MaxValue=0.3f)
    MagSize=(Name="Increased Mag Size",Increment=0.04,Rank=0,StartingValue=0.f,MaxValue=1.f)
    WeaponSwitchSpeed=(Name="Weapon Switch Speed",Increment=0.01,Rank=0,StartingValue=0.f,MaxValue=0.25)
    
    CustomLevelInfo="%d increase in SMG weapon damage|%s resistence to bullets|%b increased mag size for SMGs|%m faster weapon switch speed with SMGs"
}