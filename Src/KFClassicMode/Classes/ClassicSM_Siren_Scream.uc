class ClassicSM_Siren_Scream extends KFSM_Siren_Scream;

function ScreamExplosion()
{
    local KFGameInfo KFGI;
    
    if( !KFPOwner.IsCombatCapable() )
    {
        KFPOwner.EndSpecialMove();
        return;
    }
    
    KFGI = KFGameInfo(KFPOwner.WorldInfo.Game);
    if( KFGI == None || KFGI.DifficultyInfo == None )
    {
        Super.ScreamExplosion();
        return;
    }

    LastScreamTime = KFPOwner.WorldInfo.TimeSeconds;

    ExplosionTemplate.Damage = ScreamDamage * KFGI.DifficultyInfo.GetAIDamageModifier(MySirenPawn, KFGI.GameDifficulty, KFGI.bOnePlayerAtStart);
    ExplosionActor.Explode(ExplosionTemplate);        // go bewm

    ScreamCount++;
    if( ScreamCount >= DAMAGE_COUNT_PER_SCREAM )
    {
        bEndedNormally = true;
        KFPOwner.EndSpecialMove();
    }
}

DefaultProperties
{
    ScreamDamage=8
    
    Begin Object Name=ExploTemplate0
        MomentumTransferScale=-10000
    End Object
}