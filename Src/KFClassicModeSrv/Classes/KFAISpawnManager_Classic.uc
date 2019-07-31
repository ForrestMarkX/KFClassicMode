class KFAISpawnManager_Classic extends KFAISpawnManager
    config(ClassicSpawns);

var KFAISpawnManager OriginalSpawnManager;
var ClassicMode ControllerMutator;

var config float ModifySpawnDistance<ClampMin=0.0 | ClampMax=10.0>;
var config float MinDistanceToPlayer,MaxDistanceToPlayer,SpawnDerateTime,UnTouchCoolDownTime;
var config bool SpawnOutOfSight;
var config int iVersionNumber;

function Initialize()
{
    if( OriginalSpawnManager == None )
    {
        OriginalSpawnManager = new(Outer) SpawnManagerClasses[GameLength];
        OriginalSpawnManager.Initialize();
    }
    else OriginalSpawnManager.Initialize();
    
    if( iVersionNumber <= 0 )
    {
        ModifySpawnDistance=10.f;
        MinDistanceToPlayer=650.f;
        MaxDistanceToPlayer=16000.f;
        SpawnDerateTime=5.f;
        UnTouchCoolDownTime=3.f;
        iVersionNumber++;
    }
    
    SaveConfig();
}

function Update()
{
    local array<class<KFPawn_Monster> > SpawnList;
    
    OriginalSpawnManager.bTemporarilyEndless = bTemporarilyEndless;

    if( IsWaveActive() )
    {
        OriginalSpawnManager.TotalWavesActiveTime += 1.0;
        OriginalSpawnManager.TimeUntilNextSpawn -= 1.f;

        if( OriginalSpawnManager.ShouldAddAI() )
        {
            SpawnList = OriginalSpawnManager.GetNextSpawnList();
            if( ControllerMutator != None )
                ControllerMutator.AdjustSpawnList(SpawnList);

            NumAISpawnsQueued += OriginalSpawnManager.SpawnSquad( SpawnList );
            OriginalSpawnManager.TimeUntilNextSpawn = OriginalSpawnManager.CalcNextGroupSpawnTime();
        }
    }
}

function RegisterSpawnVolumes()
{
    local KFSpawnVolume MySpawnVolume;

    SpawnVolumes.Remove(0, SpawnVolumes.Length);

    foreach AllActors(class'KFSpawnVolume', MySpawnVolume)
    {
        MySpawnVolume.DesirabilityMod = ModifySpawnDistance;
        MySpawnVolume.MinDistanceToPlayer = MinDistanceToPlayer;
        MySpawnVolume.MaxDistanceToPlayer = MaxDistanceToPlayer;
        MySpawnVolume.SpawnDerateTime = SpawnDerateTime;
        MySpawnVolume.UnTouchCoolDownTime = UnTouchCoolDownTime;
        MySpawnVolume.bOutOfSight = SpawnOutOfSight;

        // bDisabled flag used for debugging to isolate specific volumes
        if( !MySpawnVolume.bDisabled )
        {
            SpawnVolumes.AddItem(MySpawnVolume);
        }
    }
}

function SetupNextWave(byte NextWaveIndex, int TimeToNextWaveBuffer = 0)
{
    OriginalSpawnManager.SetupNextWave(NextWaveIndex, TimeToNextWaveBuffer);
    WaveTotalAI = OriginalSpawnManager.WaveTotalAI;
}

function bool IsFinishedSpawning()
{
    return OriginalSpawnManager.IsFinishedSpawning();
}

function int SpawnSquad( out array< class<KFPawn_Monster> > AIToSpawn, optional bool bSkipHumanZedSpawning=false )
{
    return OriginalSpawnManager.SpawnSquad(AIToSpawn, bSkipHumanZedSpawning);
}

function SummonBossMinions( array<KFAISpawnSquad> NewMinionSquad, int NewMaxBossMinions, optional bool bUseLivingPlayerScale = true )
{
    OriginalSpawnManager.SummonBossMinions(NewMinionSquad, NewMaxBossMinions, bUseLivingPlayerScale);
}

function StopSummoningBossMinions()
{
    OriginalSpawnManager.StopSummoningBossMinions();
}

function int GetAIAliveCount()
{
    return OriginalSpawnManager.GetAIAliveCount();
}

defaultproperties
{
    ForcedBossNum=1
}