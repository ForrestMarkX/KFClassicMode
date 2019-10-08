class ClassicCheatManager extends KFCheatManager;

exec function SpawnHumanPawn(optional bool bEnemy, optional bool bUseGodMode, optional int CharIndex)
{
    local KFAIController KFBot;
    local KFPlayerReplicationInfo KFPRI;
    local vector                    CamLoc;
    local rotator                    CamRot;
    Local KFPawn_Human KFPH;
    local Vector HitLocation, HitNormal;
    local Actor TraceOwner;
    
    GetPlayerViewPoint(CamLoc, CamRot);

    if( Pawn != none )
    {
        TraceOwner = Pawn;
    }
    else
    {
        TraceOwner = Outer;
    }

    TraceOwner.Trace( HitLocation, HitNormal, CamLoc + Vector(CamRot) * 250000, CamLoc, TRUE, vect(0,0,0) );

    HitLocation.Z += 100;

    KFPH = Spawn(class<KFPawn_Human>(WorldInfo.Game.DefaultPawnClass), , , HitLocation);
    KFPH.SetPhysics(PHYS_Falling);

    KFBot = Spawn(class'KFAIController');

    WorldInfo.Game.ChangeName(KFBot, "Braindead Human", false);

    if( !bEnemy )
    {
       KFGameInfo(WorldInfo.Game).SetTeam(KFBot, KFGameInfo(WorldInfo.Game).Teams[0]);
    }

    KFBot.Possess(KFPH, false);

    if( bUseGodMode )
    {
       KFBot.bGodMode = true;
    }

    KFPRI = KFPlayerReplicationInfo( KFBot.PlayerReplicationInfo );

    Spawn(class'ClassicPerk_Commando',KFBot);
    
    KFPRI.CurrentPerkClass = class'ClassicPerk_Commando';
    KFPRI.NetPerkIndex = 1;

    if( KFPRI != none )
    {
        KFPRI.PLayerHealthPercent = FloatToByte( float(KFPH.Health) / float(KFPH.HealthMax) );
        KFPRI.PLayerHealth = KFPH.Health;
    }

    KFPH.AddDefaultInventory();
}

defaultproperties
{
}

