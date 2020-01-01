class KFGameInfo_LegacyEntry extends KFGameInfo_Entry;

var class<MusicGRI> MusicReplicationInfoClass;
var MusicGRI MusicReplicationInfo;

event InitGame( string Options, out string ErrorMessage )
{
    local string InOpt, LeftOpt;
    local int pos;
    
	InOpt = ParseOption( Options, "Mutator");
	if ( InOpt != "" )
	{
		`log("Mutators"@InOpt);
		while ( InOpt != "" )
		{
			pos = InStr(InOpt,",");
			if ( pos > 0 )
			{
				LeftOpt = Left(InOpt, pos);
				InOpt = Right(InOpt, Len(InOpt) - pos - 1);
			}
			else
			{
				LeftOpt = InOpt;
				InOpt = "";
			}
	    	AddMutator(LeftOpt, true);
		}
	}
    
	if (BaseMutator != none)
	{
		BaseMutator.InitMutator(Options, ErrorMessage);
	}
    
    Super.InitGame(Options, ErrorMessage);
}

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