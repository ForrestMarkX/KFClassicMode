class ClassicGameConductor extends KFGameConductor;

function HandleZedKill( float ZedVisibleTimeAlive );
function NotifyHumanTeamPlayerDeath();
function NotifySoloPlayerSurrounded();
function ResetWaveStats();
function UpdateAveragePerkRank();
function HandlePlayerChangedTeam();
function TimerUpdate();
function UpdatePlayersStatus();
function UpdatePlayersAggregateSkill();
function UpdatePlayerAccuracyStats();
function UpdateZedLifespanStats();

function float GetParZedLifeSpan()
{
    return ParZedLifeSpan[GameDifficulty];
}

function UpdateOverallStatus();
function UpdateOverallAttackCoolDowns(KFAIController KFAIC);
function EvaluateSpawnRateModification();
function EvaluateAIMovementSpeedModification();

defaultproperties
{
}