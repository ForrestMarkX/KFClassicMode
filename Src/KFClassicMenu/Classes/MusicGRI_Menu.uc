class MusicGRI_Menu extends MusicGRI;

var SoundCue MenuMusic;

simulated function PostBeginPlay()
{
    Super(ReplicationInfo).PostBeginPlay();
    
    MenuTrack = New(None) class'KFMusicTrackInfo_Custom';
    MenuTrack.StandardSong = MenuMusic;
    MenuTrack.InstrumentalSong = MenuMusic;
    
    UpdateMusicTrack(MenuTrack);
    
    Engine = KFGameEngine(class'Engine'.static.GetEngine());
}

defaultproperties
{
    MenuMusic=SoundCue'KFClassicMenu_Assets.KF_Outbreak'
}