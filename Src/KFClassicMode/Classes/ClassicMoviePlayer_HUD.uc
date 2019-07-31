class ClassicMoviePlayer_HUD extends KFGFxMoviePlayer_HUD;

function Init(optional LocalPlayer LocPlay)
{
    KFPC = KFPlayerController(GetPC());
    KFPC.SetGFxHUD(self);
    
    Super(GFxMoviePlayer).Init(LocPlay);
}

function ShowKickVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
    KFHUDInterface(KFPC.myHUD).ShowVoteUI(PRI, VoteDuration, bShowChoices, VT_TYPE_KICK);
}

simulated function HideKickVote()
{
    KFHUDInterface(KFPC.myHUD).HideVoteUI();
}

function UpdateKickVoteCount(byte YesVotes, byte NoVotes)
{
    KFHUDInterface(KFPC.myHUD).UpdateVoteCount(YesVotes, NoVotes);
}

function ShowNonCriticalMessage(string LocalizedMessage)
{
    KFHUDInterface(KFPC.myHUD).ShowNonCriticalMessage(LocalizedMessage);
}

function UpdateRhythmCounterWidget(int value, int max)
{
    KFHUDInterface(KFPC.myHUD).UpdateRhythmCounter(value, max);
}

DefaultProperties
{
    MovieInfo=None
    WidgetBindings.Empty
}