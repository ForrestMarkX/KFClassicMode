class MusicGRI extends Info;

var MusicTrackStruct CurrentMusicTrack;
var AudioComponent MusicCompCue;
var KFGameReplicationInfo GRI;
var bool bWaveIsActive, bInitialBossMusicTrackCreated;
var byte UpdateCounter, TimerCount;
var KFMusicTrackInfo CurrentTrackInfo;
var SoundCue BossMusic;
var KFMusicTrackInfo_Custom BossTrack;

var string WaveMusic, TraderMusic;
var string SummerWaveMusic, SummerTraderMusic;
var string XmasWaveMusic, XmasTraderMusic;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetupMusicInfo();
}

simulated function SetupMusicInfo()
{
    local KFMusicTrackInfo_Custom Track;
	local KFMapInfo KFMI;
	local KFEventHelper EventHelper;
	local EEventTypes EventType;
	
	EventHelper = class'KFEventHelper'.static.FindEventHelper(WorldInfo);
	if( EventHelper == None || EventHelper.GetEventType() == EV_NONE )
	{
		SetTimer(0.01, false, nameOf(SetupMusicInfo));
		return;
	}
	
    KFMI = KFMapInfo(WorldInfo.GetMapInfo());
    if( KFMI == None )
	{
		SetTimer(0.01, false, nameOf(SetupMusicInfo));
		return;
	}
	
	EventType = EventHelper.GetEventType();
        
    KFMI.ActionMusicTracks.Length = 0;
    KFMI.AmbientMusicTracks.Length = 0;
    
	Track = new(None) class'KFMusicTrackInfo_Custom';
	Track.FadeInTime = 5.f;
	Track.bIsAkEvent = false;
	Track.StandardSong = SoundCue(DynamicLoadObject(LoadMusicType(EventType, "Wave"), class'SoundCue'));;
	
	Track.InstrumentalTrack = AkEvent'WW_MACT_Default.Stop_MACT_Z_ActionFall';
	Track.StandardTrack = AkEvent'WW_MACT_Default.Stop_MACT_Z_ActionFall';
	
	KFMI.ActionMusicTracks.AddItem(Track);
    
	Track = new(None) class'KFMusicTrackInfo_Custom';
	Track.FadeInTime = 5.f;
	Track.bIsAkEvent = false;
	Track.StandardSong = SoundCue(DynamicLoadObject(LoadMusicType(EventType, "Trader"), class'SoundCue'));
	
	Track.InstrumentalTrack = AkEvent'WW_MACT_Default.Stop_MACT_Z_ActionFall';
	Track.StandardTrack = AkEvent'WW_MACT_Default.Stop_MACT_Z_ActionFall';
	
	KFMI.AmbientMusicTracks.AddItem(Track);

    KFMI.ShuffledActionMusicTrackIdxes.Length = 0;
    KFMI.CurrShuffledActionMusicTrackIdx = 0;
	
    KFMI.ShuffledAmbientMusicTrackIdxes.Length = 0;
    KFMI.CurrShuffledAmbientMusicTrackIdx = 0;
	
	ForceStartMusic();
}

simulated function string LoadMusicType(EEventTypes EventType, string Type)
{
	switch( EventType )
    {
		case EV_SUMMER:
			return Type ~= "Wave" ? SummerWaveMusic : SummerTraderMusic;
		case EV_XMAS:
			return Type ~= "Wave" ? XmasWaveMusic : XmasTraderMusic;
		default:
			return Type ~= "Wave" ? WaveMusic : TraderMusic;
    }
}

simulated function UpdateMusicTrack( KFMusicTrackInfo NextMusicTrackInfo )
{
	local KFMusicTrackInfo_Custom CustomInfo;
	local SoundCue CurrentTrack;
	local MusicTrackStruct Music;
	
	ForceStopMusic(CurrentMusicTrack.FadeOutTime);
	if( GRI.IsBossWave() )
	{
		NextMusicTrackInfo = BossTrack;
	}
	
	CurrentTrackInfo = NextMusicTrackInfo;
	CustomInfo = KFMusicTrackInfo_Custom(NextMusicTrackInfo);
	if( CustomInfo == None )
		return;
	
	CurrentTrack = SoundCue(CustomInfo.StandardSong);
	
	GRI.CurrentMusicTrackInfo = CustomInfo;
	
	CurrentTrack.SoundClass = 'Music';
	Music.TheSoundCue = CurrentTrack;
	Music.FadeInTime = CustomInfo.FadeInTime;
	Music.FadeOutTime = 2.f;

	PlaySoundTrack(Music);
	GRI.bPendingMusicTrackChange = false;
	GRI.MusicComp = None;
}

simulated function ForceStopMusic(optional float FadeOutTime=1.0f)
{
	ClearTimer('SelectNewTrack');
	
	if( MusicCompCue!=None )
	{
		MusicCompCue.FadeOut(FadeOutTime,0.0);
		MusicCompCue = None;
	}
}

simulated function PlaySoundTrack(MusicTrackStruct Music)
{
	local AudioComponent A;
	local KFGameEngine Engine;
	
	Engine = KFGameEngine(class'Engine'.static.GetEngine());
	
	A = WorldInfo.CreateAudioComponent(Music.TheSoundCue,false,false,false,,false);
	if( A!=None )
	{
		A.SoundCue.bPitchShiftWithTimeDilation = false;
		
		A.OcclusionCheckInterval = 0.f;
		A.bAutoDestroy = true;
		A.bShouldRemainActiveIfDropped = true;
		A.bAutoPlay = Music.bAutoPlay;
		A.bIgnoreForFlushing = Music.bPersistentAcrossLevels;
		A.VolumeMultiplier = (Engine.MusicVolumeMultiplier/100.f) * (Engine.MasterVolumeMultiplier/100.f);
		A.FadeIn( Music.FadeInTime, Music.FadeInVolumeLevel );
		
		SetTimer((A.SoundCue.Duration - (Music.FadeOutTime + Music.FadeInTime)) * 0.95, false, nameof(SelectNewTrack));
	}

	MusicCompCue = A;
	CurrentMusicTrack = Music;
}

simulated function PlayNewMusicTrack( optional bool bGameStateChanged, optional bool bForceAmbient )
{
    local KFMapInfo             KFMI;
    local KFMusicTrackInfo      NextMusicTrackInfo;
    local bool                  bLoop;
	local bool					bPlayActionTrack;
	
    if ( class'KFGameEngine'.static.CheckNoMusic() )
        return;

	//Required or else on servers the first waves action music never starts
	bPlayActionTrack = (!bForceAmbient && bWaveIsActive);
	
    if( bGameStateChanged )
    {
        if( bPlayActionTrack )
        {
            if( class'KFGameInfo'.default.ActionMusicDelay > 0 )
            {
                SetTimer( class'KFGameInfo'.default.ActionMusicDelay, false, nameof(PlayNewMusicTrack) );
                return;
            }
        }
    }
    else if( CurrentTrackInfo != none )
        bLoop = CurrentTrackInfo.bLoop;

    if( bLoop )
        NextMusicTrackInfo = CurrentTrackInfo;
    else
    {
        KFMI = KFMapInfo(WorldInfo.GetMapInfo());
        if ( KFMI != none )
            NextMusicTrackInfo = KFMI.GetNextMusicTrackByGameIntensity(bPlayActionTrack, GRI.MusicIntensity);
        else NextMusicTrackInfo = class'KFMapInfo'.static.StaticGetRandomTrack(bPlayActionTrack);
    }
	
	UpdateMusicTrack(NextMusicTrackInfo);
}

simulated function Tick(float DT)
{
	if( WorldInfo.NetMode == NM_DedicatedServer )
		return;
		
	GRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( GRI == None )
		return;
		
	// I hate this so much but it's the only way to stop the original GRI from spamming songs
	if( MusicCompCue != None )
	{
		GRI.bPendingMusicTrackChange = false;
		
		if( GRI.MusicComp != None && GRI.MusicComp.IsPlaying() )
		{
			GRI.MusicComp.StopEvents();
			GRI.MusicComp = None;
		}
		
		if( !MusicCompCue.IsPlaying() )
		{
			SelectNewTrack();
		}
	}
	
	if( GRI.IsBossWave() && !bInitialBossMusicTrackCreated )
	{
		BossTrack = New(KFMapInfo(WorldInfo.GetMapInfo())) class'KFMusicTrackInfo_Custom';
		BossTrack.StandardSong = BossMusic;
		BossTrack.InstrumentalSong = BossMusic;
		BossTrack.bLoop = true;
		
		UpdateMusicTrack(BossTrack);
		
		bInitialBossMusicTrackCreated = true;
	}
	else if( bWaveIsActive != GRI.bWaveIsActive && !GRI.IsBossWave() )
	{
		bWaveIsActive = GRI.bWaveIsActive;
		PlayNewMusicTrack( true, false );
	}
}

simulated function SelectNewTrack()
{
	PlayNewMusicTrack( false, !bWaveIsActive );
}

simulated function ForceStartMusic()
{	
	if( GRI == None )
	{
		SetTimer(0.1f, false, nameOf(ForceStartMusic));
		return;
	}
	
	PlayNewMusicTrack(false, !bWaveIsActive);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	bAlwaysTick=true
	
	bStatic=False
	bNoDelete=False

	Components.Remove(Sprite)
	
    WaveMusic="KFClassicMusic.RandomWaveMusic"
    TraderMusic="KFClassicMusic.RandomTraderMusic"
    
    SummerWaveMusic="KFClassicMusic.RandomSummerWaveMusic"
    SummerTraderMusic="KFClassicMusic.RandomSummerTraderMusic"
    
    XmasWaveMusic="KFClassicMusic.RandomXmasWaveMusic"
    XmasTraderMusic="KFClassicMusic.RandomXmasTraderMusic"
}