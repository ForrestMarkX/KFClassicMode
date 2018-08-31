Class MS_PC extends KFPlayerController;

var MS_PendingData TravelData;
var byte ConnectionCounter;
var bool bConnectionFailed;

simulated event ReceivedPlayer();
simulated function ReceivedGameClass(class<GameInfo> GameClass);

simulated function HandleNetworkError( bool bConnectionLost )
{
	ConsoleCommand("Disconnect");
}

event PlayerTick( float DeltaTime )
{
	if( ConnectionCounter<3 && ++ConnectionCounter==3 )
	{
		if( TravelData.PendingURL!="" )
		{
			MS_HUD(myHUD).ShowProgressMsg("Connecting to "$TravelData.PendingURL);
			ConsoleCommand("Open "$TravelData.PendingURL);
		}

		// Reset all cached data.
		TravelData.Reset();
	}
	PlayerInput.PlayerInput(DeltaTime);
}

final function AbortConnection()
{
	if( bConnectionFailed )
		HandleNetworkError(false);
	else
	{
		ShowConnectionProgressPopup(PMT_ConnectionFailure,"Connection aborted","User aborted connection...",true);
		ConsoleCommand("Cancel");
	}
}

reliable client event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  );

reliable client event bool ShowConnectionProgressPopup( EProgressMessageType ProgressType, string ProgressTitle, string ProgressDescription, bool SuppressPasswordRetry = false)
{
	if( bConnectionFailed )
		return false;
	switch(ProgressType)
	{
	case PMT_ConnectionFailure:
	case PMT_PeerConnectionFailure:
		bConnectionFailed = true;
		MS_HUD(myHUD).ShowProgressMsg("Connection Error: "$ProgressTitle$"|"$ProgressDescription$"|Disconnecting...",true);
		SetTimer(4,false,'HandleNetworkError');
		return true;
	case PMT_DownloadProgress:
	case PMT_AdminMessage:
		MS_HUD(myHUD).ShowProgressMsg(ProgressTitle$"|"$ProgressDescription);
		return true;
	}
	return false;
}

auto state PlayerWaiting
{
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon, SwitchToBestWeapon;

	reliable server function ServerChangeTeam( int N );

	reliable server function ServerRestartPlayer();

	function PlayerMove(float DeltaTime)
	{
	}
}

defaultproperties
{
	InputClass=class'MS_Input'
	
	Begin Object Class=MS_PendingData Name=UserPendingData
	End Object
	TravelData=UserPendingData
}