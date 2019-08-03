class KFGameInfo_LegacyEntry extends KFGameInfo_Entry;

var class<MusicGRI> MusicReplicationInfoClass;
var MusicGRI MusicReplicationInfo;

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    return Default.class;
}

simulated function ForceMenuMusicTrack()
{
    MusicReplicationInfo = Spawn(MusicReplicationInfoClass);
}

defaultproperties
{
    MusicReplicationInfoClass=class'MusicGRI_Menu'
    KFGFxManagerClass=class'MenuMoviePlayer_Manager'
    HUDType=class'MenuInterface'
    DefaultPawnClass=class'MenuPawn'
    PlayerControllerClass=class'MenuPlayerController'
    PlayerReplicationInfoClass=class'MenuReplicationInfo'
}