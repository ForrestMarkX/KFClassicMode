class MusicGRI extends ReplicationInfo;

var MusicTrackStruct CurrentMusicTrack;
var AudioComponent MusicCompCue;
var KFGameReplicationInfo GRI;
var bool bWaveIsActive, bInitialBossMusicTrackCreated;
var byte UpdateCounter, TimerCount;
var KFMusicTrackInfo CurrentTrackInfo;
var SoundCue BossMusic;
var KFMusicTrackInfo_Custom BossTrack, MenuTrack;

var string WaveMusic, TraderMusic;
var string SummerWaveMusic, SummerTraderMusic;
var string XmasWaveMusic, XmasTraderMusic;

var KFGameEngine Engine;
var float CurrentMusicMultiplier, CurrentMasterMultiplier;
var KFMapInfo KFMI;

var array<KFMusicTrackInfo> OriginalActionMusicTracks, OriginalAmbientMusicTracks, ClassicActionMusicTracks, ClassicAmbientMusicTracks;

simulated static final function MusicGRI FindMusicGRI( WorldInfo Level )
{
    local MusicGRI H;
    
    foreach Level.DynamicActors(class'MusicGRI',H)
    {
        if( H != None )
            return H;
    }
    
    return None;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    Engine = KFGameEngine(class'Engine'.static.GetEngine());
    SetupMusicInfo();
}

simulated function SetupMusicInfo()
{
    local KFMusicTrackInfo_Custom Track;
    local KFEventHelper EventHelper;
    local EEventTypes EventType;
    local bool bNoClassicMusic;
    local ClientPerkRepLink RepLink;
    
    if( WorldInfo.NetMode == NM_DedicatedServer )
        return;
    
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
    
    bNoClassicMusic = ClassicPlayerController(GetALocalPlayerController()).bDisableClassicMusic;
    
    EventType = EventHelper.GetEventType();
        
    OriginalActionMusicTracks = KFMI.ActionMusicTracks;
    OriginalAmbientMusicTracks = KFMI.AmbientMusicTracks;
        
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
   
    ClassicActionMusicTracks = KFMI.ActionMusicTracks;
    ClassicAmbientMusicTracks = KFMI.AmbientMusicTracks;
    
    if( bNoClassicMusic )
    {
        KFMI.ActionMusicTracks = OriginalActionMusicTracks;
        KFMI.AmbientMusicTracks = OriginalAmbientMusicTracks;
        
        if( GRI != None )
            GRI.PlayNewMusicTrack(false, !GRI.bWaveIsActive);
        
        return;
    }
    
    RepLink = class'ClientPerkRepLink'.static.FindContentRep(WorldInfo);
    if( RepLink != None && BossTrack == None )
    {
        BossTrack = New(None) class'KFMusicTrackInfo_Custom';
        BossTrack.StandardSong = BossMusic != None ? BossMusic : SoundCue(RepLink.ObjRef.ReferencedObjects[101]);
        BossTrack.InstrumentalSong = BossMusic != None ? BossMusic : SoundCue(RepLink.ObjRef.ReferencedObjects[101]);
        BossTrack.bLoop = true;
    }
    
    ForceStartMusic();
}

simulated function string LoadMusicType(EEventTypes EventType, string Type)
{
    switch( EventType )
    {
        case EV_SUMMER:
            return Type ~= "Wave" ? SummerWaveMusic : SummerTraderMusic;
        case EV_WINTER:
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
    
    CurrentTrackInfo = NextMusicTrackInfo;
    CustomInfo = KFMusicTrackInfo_Custom(NextMusicTrackInfo);
    if( CustomInfo == None )
        return;
    
    CurrentTrack = SoundCue(CustomInfo.StandardSong);

    CurrentTrack.SoundClass = 'Music';
    Music.TheSoundCue = CurrentTrack;
    Music.FadeInTime = CustomInfo.FadeInTime;
    Music.FadeOutTime = 2.f;

    PlaySoundTrack(Music);
    
    if( GRI != None )
    {
        GRI.CurrentMusicTrackInfo = CustomInfo;
        GRI.bPendingMusicTrackChange = false;
        GRI.MusicComp = None;
    }
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
        
        CurrentMusicMultiplier = Engine.MusicVolumeMultiplier;
        CurrentMasterMultiplier = Engine.MasterVolumeMultiplier;
        
        SetTimer((A.SoundCue.Duration - (Music.FadeOutTime + Music.FadeInTime)) * 0.95, false, nameof(SelectNewTrack));
    }

    MusicCompCue = A;
    CurrentMusicTrack = Music;
}

simulated function PlayNewMusicTrack( optional bool bGameStateChanged, optional bool bForceAmbient )
{
    local KFMusicTrackInfo      NextMusicTrackInfo;
    local bool                  bLoop;
    local bool                  bPlayActionTrack;
    
    if ( class'KFGameEngine'.static.CheckNoMusic() )
        return;
        
    if ( class'WorldInfo'.static.IsMenuLevel() )
    {
        UpdateMusicTrack(MenuTrack);
        return;
    }

    //Required or else on servers the first waves action music never starts
    bPlayActionTrack = (!bForceAmbient && bWaveIsActive) || (GRI != None && GRI.IsBossWave());
    
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

    if( GRI != None && GRI.IsBossWave() && !bForceAmbient )
        NextMusicTrackInfo = BossTrack;
    else if( bLoop )
        NextMusicTrackInfo = CurrentTrackInfo;
    else
    {
        if ( KFMI != none )
            NextMusicTrackInfo = KFMI.GetNextMusicTrackByGameIntensity(bPlayActionTrack, GRI != None ? GRI.MusicIntensity : 255);
        else NextMusicTrackInfo = class'KFMapInfo'.static.StaticGetRandomTrack(bPlayActionTrack);
    }
    
    UpdateMusicTrack(NextMusicTrackInfo);
}

simulated function Tick(float DT)
{
    if( WorldInfo.NetMode == NM_DedicatedServer )
        return;
        
    if( MusicCompCue != None )
    {
        if( !MusicCompCue.IsPlaying() )
            SelectNewTrack();
           
        if( CurrentMusicMultiplier != Engine.MusicVolumeMultiplier || CurrentMasterMultiplier != Engine.MasterVolumeMultiplier )
        {
            CurrentMusicMultiplier = Engine.MusicVolumeMultiplier;
            CurrentMasterMultiplier = Engine.MasterVolumeMultiplier;
        
            MusicCompCue.VolumeMultiplier = (CurrentMusicMultiplier/100.f) * (CurrentMasterMultiplier/100.f);
        }
    }
    
    if( WorldInfo.NetMode == NM_DedicatedServer || (ClassicPlayerController(GetALocalPlayerController()).bDisableClassicMusic && !class'WorldInfo'.static.IsMenuLevel()) )
        return;

    GRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( GRI == None )
        return;
        
    GRI.bPendingMusicTrackChange = false;
    
    if( GRI.MusicComp != None )
    {
        GRI.MusicComp.StopEvents();
        GRI.MusicComp = None;
    }
    
    if( GRI.CurrentMusicTrackInfo != None )
    {
        GRI.CurrentMusicTrackInfo = None;
        GRI.ReplicatedMusicTrackInfo = None;
    }
    
    if( bWaveIsActive != GRI.bWaveIsActive )
    {
        CurrentTrackInfo = None;
        bWaveIsActive = GRI.bWaveIsActive;
        PlayNewMusicTrack( true, !bWaveIsActive );
        return;
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

reliable client function ForceBossMusic(KFPawn_Monster Pawn)
{
    if( ClassicPlayerController(GetALocalPlayerController()).bDisableClassicMusic )
    {
        if( Pawn.IsA('KFPawn_ZedHans') )
            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss1]);
        else if( Pawn.IsA('KFPawn_ZedPatriarch') )
            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss2]);
        else if( Pawn.IsA('KFPawn_ZedMatriarch') )
            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss3]);
        else if( Pawn.IsA('KFPawn_ZedFleshpoundKing') )
            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss4]);
        else if( Pawn.IsA('KFPawn_ZedBloatKing') )
            GRI.ForceNewMusicTrack(class'KFGameInfo'.default.ForcedMusicTracks[EFM_Boss5]);
    }
    else UpdateMusicTrack(BossTrack);
}

defaultproperties
{
    bAlwaysTick=true
    
    BossMusic=SoundCue'KFClassicMode_Assets.Music.RandomBossMusic'
    
    WaveMusic="KFClassicMusic.RandomWaveMusic"
    TraderMusic="KFClassicMusic.RandomTraderMusic"
    
    SummerWaveMusic="KFClassicMusic.RandomSummerWaveMusic"
    SummerTraderMusic="KFClassicMusic.RandomSummerTraderMusic"
    
    XmasWaveMusic="KFClassicMusic.RandomXmasWaveMusic"
    XmasTraderMusic="KFClassicMusic.RandomXmasTraderMusic"
}