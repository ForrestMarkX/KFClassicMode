class KFAISpawnManager_Endless_Classic extends KFAISpawnManager_Endless;

var ClassicMode ControllerMutator;

function Update()
{
    local array<class<KFPawn_Monster> > SpawnList;

    if( IsWaveActive() )
    {
        TotalWavesActiveTime += 1.0;
        TimeUntilNextSpawn -= 1.f;

        if( ShouldAddAI() )
        {
            SpawnList = GetNextSpawnList();
            if( ControllerMutator != None )
                ControllerMutator.AdjustSpawnList(SpawnList);

            NumAISpawnsQueued += SpawnSquad( SpawnList );
            TimeUntilNextSpawn = CalcNextGroupSpawnTime();
        }
    }
}

function RegisterSpawnVolumes()
{
    local KFSpawnVolume MySpawnVolume;

    SpawnVolumes.Remove(0, SpawnVolumes.Length);

    foreach AllActors(class'KFSpawnVolume', MySpawnVolume)
    {
        MySpawnVolume.DesirabilityMod = class'KFAISpawnManager_Classic'.default.ModifySpawnDistance;
        MySpawnVolume.MinDistanceToPlayer = class'KFAISpawnManager_Classic'.default.MinDistanceToPlayer;
        MySpawnVolume.MaxDistanceToPlayer = class'KFAISpawnManager_Classic'.default.MaxDistanceToPlayer;
        MySpawnVolume.SpawnDerateTime = class'KFAISpawnManager_Classic'.default.SpawnDerateTime;
        MySpawnVolume.UnTouchCoolDownTime = class'KFAISpawnManager_Classic'.default.UnTouchCoolDownTime;
        MySpawnVolume.bOutOfSight = class'KFAISpawnManager_Classic'.default.SpawnOutOfSight;

        // bDisabled flag used for debugging to isolate specific volumes
        if( !MySpawnVolume.bDisabled )
        {
            SpawnVolumes.AddItem(MySpawnVolume);
        }
    }
}

defaultproperties
{
}