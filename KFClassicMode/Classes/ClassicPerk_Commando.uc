class ClassicPerk_Commando extends ClassicPerk_Base;

var const PerkSkill    CloakedEnemyDetection;
var    const PerkSkill CommandoDamage;
var    const PerkSkill ReloadSpeed;
var    const PerkSkill SpareAmmo;
var    const PerkSkill Recoil;
var    const PerkSkill MagCapacity;

var Texture2d WhiteMaterial;

simulated function DrawSpecialPerkHUD(Canvas C)
{
    local KFPawn_Monster KFPM;
    local vector ViewLocation, ViewDir;
    local float DetectionRangeSq, ThisDot;
    local float HealthBarLength, HealthbarHeight;

    if( CheckOwnerPawn() && CurrentVetLevel > 1 )
    {
        DetectionRangeSq = Square( GetPassiveValue(CloakedEnemyDetection, CurrentVetLevel) );

        HealthbarLength = FMin( 50.f * (float(C.SizeX) / 1024.f), 50.f );
        HealthbarHeight = FMin( 6.f * (float(C.SizeX) / 1024.f), 6.f );

        ViewLocation = OwnerPawn.GetPawnViewLocation();
        ViewDir = vector( OwnerPawn.GetViewRotation() );

        foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
        {
            if( !KFPM.CanShowHealth() || !KFPM.IsAliveAndWell() || `TimeSince(KFPM.Mesh.LastRenderTime) > 0.1f || VSizeSQ(KFPM.Location - OwnerPawn.Location) > DetectionRangeSq )
            {
                continue;
            }

            ThisDot = ViewDir dot Normal( KFPM.Location - OwnerPawn.Location );
            if( ThisDot > 0.f )
            {
                DrawZedHealthbar( C, KFPM, ViewLocation, HealthbarHeight, HealthbarLength );
            }
        }
    }
}

simulated function DrawZedHealthbar(Canvas C, KFPawn_Monster KFPM, vector CameraLocation, float HealthbarHeight, float HealthbarLength )
{
    local vector ScreenPos, TargetLocation;
    local float HealthScale;

    if( KFPM.bCrawler && KFPM.Floor.Z <=  -0.7f && KFPM.Physics == PHYS_Spider )
    {
        TargetLocation = KFPM.Location + vect(0,0,-1) * KFPM.GetCollisionHeight() * 1.2 * KFPM.CurrentBodyScale;
    }
    else
    {
        TargetLocation = KFPM.Location + vect(0,0,1) * KFPM.GetCollisionHeight() * 1.2 * KFPM.CurrentBodyScale;
    }

    ScreenPos = C.Project( TargetLocation );
    if( ScreenPos.X < 0 || ScreenPos.X > C.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > C.SizeY )
    {
        return;
    }

    if( `FastTracePhysX(TargetLocation, CameraLocation) )
    {
        HealthScale = FClamp( float(KFPM.Health) / float(KFPM.HealthMax), 0.f, 1.f );

        C.EnableStencilTest( true );
        C.SetDrawColor(0, 0, 0, 255);
        C.SetPos( ScreenPos.X - HealthBarLength * 0.5, ScreenPos.Y );
        C.DrawTile( WhiteMaterial, HealthbarLength, HealthbarHeight, 0, 0, 32, 32 );

        C.SetDrawColor( 237, 8, 0, 255 );
        C.SetPos( ScreenPos.X - HealthBarLength * 0.5 + 1.0, ScreenPos.Y + 1.0 );
        C.DrawTile( WhiteMaterial, (HealthBarLength - 2.0) * HealthScale, HealthbarHeight - 2.0, 0, 0, 32, 32 );
        C.EnableStencilTest( false );
    }
}

simulated function ModifyDamageGiven( out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx )
{
    local KFWeapon KFW;
    local float TempDamage;

    TempDamage = InDamage;

    if( DamageCauser != none )
    {
        KFW = GetWeaponFromDamageCauser( DamageCauser );
    }

    if( (KFW != none && IsWeaponOnPerk( KFW,, self.class )) || (DamageType != none && IsDamageTypeOnPerk( DamageType )) )
    {
        TempDamage += InDamage * GetPassiveValue( CommandoDamage, CurrentVetLevel );
    }

    InDamage = FCeil(TempDamage);
}

simulated function float GetReloadRateScale( KFWeapon KFW )
{
    if( IsWeaponOnPerk( KFW,, self.class ) )
    {
        return 1.f - GetPassiveValue( ReloadSpeed, CurrentVetLevel );
    }

    return 1.f;
}

simulated function ModifyRecoil( out float CurrentRecoilModifier, KFWeapon KFW )
{
    if( IsWeaponOnPerk( KFW,, self.class ) )
    {
        CurrentRecoilModifier -= CurrentRecoilModifier * GetPassiveValue( Recoil, CurrentVetLevel );
    }
}

simulated function ModifyMagSizeAndNumber( KFWeapon KFW, out byte MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
    local float TempCapacity;
    
    TempCapacity = MagazineCapacity;
    
    if( !bSecondary && IsWeaponOnPerk( KFW, WeaponPerkClass, self.class ) && (KFW == none || !KFW.bNoMagazine) )
    {
        TempCapacity += MagazineCapacity * GetPassiveValue( MagCapacity, CurrentVetLevel );
    }
    
    MagazineCapacity = Round(TempCapacity);
}

simulated function ModifyMaxSpareAmmoAmount( KFWeapon KFW, out int MaxSpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary=false )
{
    local float TempMaxSpareAmmoAmount;
    
    if( (IsWeaponOnPerk( KFW, TraderItem.AssociatedPerkClasses, self.class ) || IsBackupWeapon( KFW )) )
    {
        TempMaxSpareAmmoAmount = MaxSpareAmmo;
        TempMaxSpareAmmoAmount += MaxSpareAmmo * GetPassiveValue( SpareAmmo, CurrentVetLevel );
        MaxSpareAmmo = Round( TempMaxSpareAmmoAmount );
    }
}

simulated static function float GetZedTimeExtension( byte Level )
{
    if ( Level >= 3 )
    {
        return FClamp(FCeil(Level - 2.f), 1.f, 5.f);
    }

    return Super(KFPerk).GetZedTimeExtension(Level);
}

simulated static function class<KFWeaponDefinition> GetWeaponDef(int Level)
{
    if( Level == 5 )
    {
        return class'ClassicWeapDef_Bullpup';
    }
    else if( Level >= 6 )
    {
        return class'ClassicWeapDef_Ak12';
    }
    
    return None;
}

simulated function bool GetUsingTactialReload( KFWeapon KFW )
{
    return true;
}

simulated function float GetCloakDetectionRange()
{
    return GetPassiveValue( CloakedEnemyDetection, CurrentVetLevel );
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
    PassiveValues[0] = Round(GetPassiveValue( default.CloakedEnemyDetection, Level ) / 100) $ "m";
    PassiveValues[1] = Round(GetPassiveValue( default.CommandoDamage, Level ) * 100) $ "%";
    PassiveValues[2] = Round(GetPassiveValue( default.ReloadSpeed, Level ) * 100) $ "%";
    PassiveValues[3] = Round(GetPassiveValue( default.Recoil, Level ) * 100) $ "%";
    PassiveValues[4] = Round(GetPassiveValue( default.MagCapacity, Level ) * 100) $ "%";
    PassiveValues[5] = Round(GetPassiveValue( default.SpareAmmo, Level ) * 100) $ "%";

    Increments[0] = "[" @ Int(default.CloakedEnemyDetection.Increment / 100 )$"m /" @default.LevelString @"]";
    Increments[1] = "[" @ Left( string( default.CommandoDamage.Increment * 100 ), InStr(string(default.CommandoDamage.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[2] = "[" @ Left( string( default.ReloadSpeed.Increment * 100 ), InStr(string(default.ReloadSpeed.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[3] = "[" @ Left( string( default.Recoil.Increment * 100 ), InStr(string(default.Recoil.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[4] = "[" @ Left( string( default.MagCapacity.Increment * 100 ), InStr(string(default.MagCapacity.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
    Increments[5] = "[" @ Left( string( default.SpareAmmo.Increment * 100 ), InStr(string(default.SpareAmmo.Increment * 100), ".") + 2 )$"% /" @ default.LevelString @ "]";
}

simulated static function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local class<KFWeaponDefinition> SpawnDef;

    S = default.CustomLevelInfo;

    ReplaceText(S,"%d",GetPercentStr(default.CommandoDamage, Level));
    ReplaceText(S,"%s",GetPercentStr(default.ReloadSpeed, Level));
    ReplaceText(S,"%a",GetPercentStr(default.Recoil, Level));
    ReplaceText(S,"%m",GetPercentStr(default.MagCapacity, Level));
    ReplaceText(S,"%b",GetPercentStr(default.SpareAmmo, Level));
    ReplaceText(S,"%c",Round(GetPassiveValue( default.CloakedEnemyDetection, Level ) / 100) $ "m");
    ReplaceText(S,"%w",GetPercentStr(default.WeaponDiscount, Level));
    
    SpawnDef = GetWeaponDef(Level);
    if( SpawnDef != None )
    {
        S = S $ "|Spawn with a " $ SpawnDef.static.GetItemName();
    }
    
    S = S $ "|Up to " $ int(GetZedTimeExtension(Level)) $ " Zed-Time Extension(s)";

    return S;
}

DefaultProperties
{
    BasePerk=class'KFPerk_Commando'

    bCanSeeCloakedZeds=true
    
    EXPActions(0)="Dealing Commando weapon damage"
    EXPActions(1)="Killing Stalkers with Commando weapons"
    
    WhiteMaterial=Texture2D'EngineResources.WhiteSquareTexture'
    
    PassiveInfos(0)=(Title="Cloaked Enemy Detection Range")
    PassiveInfos(1)=(Title="Weapon Damage")
    PassiveInfos(2)=(Title="Reload Speed")
    PassiveInfos(3)=(Title="Weapon Recoil")
    PassiveInfos(4)=(Title="Mag Capacity")
    PassiveInfos(5)=(Title="Spare Ammo")
    
    CloakedEnemyDetection=(Name="Cloaked Enemy Detection Range",Increment=160.f,Rank=0,StartingValue=0.f,MaxValue=800.f)
    CommandoDamage=(Name="Weapon Damage",Increment=0.1f,Rank=0,StartingValue=0.05f,MaxValue=0.5f)
    ReloadSpeed=(Name="Reload Speed",Increment=0.025f,Rank=0,StartingValue=0.05f,MaxValue=0.5f)
    Recoil=(Name="Weapon Recoil",Increment=0.05f,Rank=0,StartingValue=0.05f,MaxValue=0.75f)
    MagCapacity=(Name="Mag Capacity",Increment=0.1f,Rank=0,StartingValue=0.f,MaxValue=0.25f)
    SpareAmmo=(Name="Spare Ammo",Increment=0.1f,Rank=0,StartingValue=0.f,MaxValue=0.25f)
    
    CustomLevelInfo="%d increase in assault rifle damage|%s faster reload speed with perked weapons|%a less recoil with perked weapons|%m more magazine capacity with perked weapons|Carry %b more ammo|Can see cloaked Stalkers at %c|%w discount on assault rifles"
}
