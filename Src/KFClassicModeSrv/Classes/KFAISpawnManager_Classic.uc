class KFAISpawnManager_Classic extends KFAISpawnManager;

var KFAISpawnManager OriginalSpawnManager;
var ClassicMode ControllerMutator;

function Initialize()
{
    if( OriginalSpawnManager == None )
    {
        OriginalSpawnManager = new(Outer) SpawnManagerClasses[GameLength];
        OriginalSpawnManager.Initialize();
    }
    else OriginalSpawnManager.Initialize();
}

function Update()
{
    local array<class<KFPawn_Monster> > SpawnList;

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