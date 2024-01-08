Class ClientPerkRepLink extends ReplicationInfo
    transient;

var repnotify ObjectReferencer ObjRef;
var ObjectReferencer BaseRef;

var array<class<Mutator> > Mutators;
var int RepIndex;

replication
{
    if ( True )
        ObjRef;
}

simulated static final function ClientPerkRepLink FindContentRep( WorldInfo Level )
{
    local ClientPerkRepLink H;
    
    foreach Level.DynamicActors(class'ClientPerkRepLink',H)
        if( H.ObjRef!=None )
            return H;
    if( Level.NetMode!=NM_Client )
    {
        H = Level.Spawn(class'ClientPerkRepLink');
        return H;
    }
    return None;
}

function PostBeginPlay()
{
    ObjRef = BaseRef;
    if( ObjRef!=None )
        InitRep();
}

simulated function ReplicatedEvent( Name VarName )
{
    if( VarName == 'ObjRef' && ObjRef!=None )
    {
        InitRep();
    }
}

simulated final function InitRep()
{
    local KFHUDInterface myHUD;
    local KF2GUIController MyGUIController;
    local GUIStyleBase MyStyle;
    local MusicGRI MusicGRI;
    
    myHUD = KFHUDInterface(FindObject("KFClassicMode.Default__KFHUDInterface",class'KFHUDInterface'));
    if( myHUD != None )
    {
        myHUD.ProgressBarTex = Texture2D(ObjRef.ReferencedObjects[85]);
        
        myHUD.HealthIcon = Texture2D(ObjRef.ReferencedObjects[27]);
        myHUD.ArmorIcon = Texture2D(ObjRef.ReferencedObjects[31]);
        myHUD.WeightIcon = Texture2D(ObjRef.ReferencedObjects[34]);
        myHUD.GrenadesIcon = Texture2D(ObjRef.ReferencedObjects[23]);
        myHUD.DoshIcon = Texture2D(ObjRef.ReferencedObjects[30]);
        myHUD.BulletsIcon = Texture2D(ObjRef.ReferencedObjects[17]);
        myHUD.ClipsIcon = Texture2D(ObjRef.ReferencedObjects[11]);
        myHUD.BurstBulletIcon = Texture2D(ObjRef.ReferencedObjects[18]);
        myHUD.AutoTargetIcon = Texture2D(ObjRef.ReferencedObjects[13]);
        
        myHUD.ArrowIcon = Texture2D(ObjRef.ReferencedObjects[12]);
        myHUD.FlameIcon = Texture2D(ObjRef.ReferencedObjects[19]);
        myHUD.FlameTankIcon = Texture2D(ObjRef.ReferencedObjects[20]);
        myHUD.FlashlightIcon = Texture2D(ObjRef.ReferencedObjects[21]);
        myHUD.FlashlightOffIcon = Texture2D(ObjRef.ReferencedObjects[22]);
        myHUD.RocketIcon = Texture2D(ObjRef.ReferencedObjects[24]);
        myHUD.BoltIcon = Texture2D(ObjRef.ReferencedObjects[25]);
        myHUD.M79Icon = Texture2D(ObjRef.ReferencedObjects[26]);
        myHUD.PipebombIcon = Texture2D(ObjRef.ReferencedObjects[29]);
        myHUD.SingleBulletIcon = Texture2D(ObjRef.ReferencedObjects[32]);
        myHUD.SyringIcon = Texture2D(ObjRef.ReferencedObjects[33]);
        myHUD.SawbladeIcon = Texture2D(ObjRef.ReferencedObjects[78]);
        
        myHUD.TraderBox = Texture2D(ObjRef.ReferencedObjects[16]);
        
        myHUD.WaveCircle = Texture2D(ObjRef.ReferencedObjects[15]);
        myHUD.BioCircle = Texture2D(ObjRef.ReferencedObjects[14]);
        
        myHUD.DoorWelderBG = myHUD.TraderBox;
        myHUD.DoorWelderIcon = Texture2D(ObjRef.ReferencedObjects[88]);
        
        myHUD.InventoryBackgroundTexture = Texture2D(ObjRef.ReferencedObjects[113]);
        myHUD.SelectedInventoryBackgroundTexture = Texture2D(ObjRef.ReferencedObjects[114]);
        
        myHUD.TraderPortrait = Texture2D(ObjRef.ReferencedObjects[86]);
        myHUD.PatriarchPortrait = Texture2D(ObjRef.ReferencedObjects[58]);
        myHUD.LockheartPortrait = Texture2D(ObjRef.ReferencedObjects[70]);
        myHUD.UnknownPortrait = Texture2D(ObjRef.ReferencedObjects[56]);
        myHUD.TraderPortraitBox = Texture2D(ObjRef.ReferencedObjects[2]);
        
        myHUD.VictoryScreen = Texture2D(ObjRef.ReferencedObjects[115]);
        myHUD.DefeatScreen = Texture2D(ObjRef.ReferencedObjects[117]);
        myHUD.VictoryScreenOverlay = Texture2D(ObjRef.ReferencedObjects[116]);
        myHUD.DefeatScreenOverlay = Texture2D(ObjRef.ReferencedObjects[118]);
    }
    
    MyStyle = GUIStyleBase(FindObject("KFClassicMode.Default__GUIStyleBase",class'GUIStyleBase'));
    if( MyStyle != None )
    {
        MyStyle.MainFont = Font(ObjRef.ReferencedObjects[168]);
        MyStyle.InfiniteFont = Font(ObjRef.ReferencedObjects[155]);
        MyStyle.NameFont = Font(ObjRef.ReferencedObjects[104]);
        
        MyStyle.BorderTextures[`BOX_INNERBORDER] = Texture2D(ObjRef.ReferencedObjects[35]);
        MyStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT] = Texture2D(ObjRef.ReferencedObjects[36]);
        MyStyle.BorderTextures[`BOX_MEDIUM] = Texture2D(ObjRef.ReferencedObjects[46]);
        MyStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT] = Texture2D(ObjRef.ReferencedObjects[47]);
        MyStyle.BorderTextures[`BOX_MEDIUM_TRANSPARENT] = Texture2D(ObjRef.ReferencedObjects[48]);
        MyStyle.BorderTextures[`BOX_LARGE] = Texture2D(ObjRef.ReferencedObjects[79]);
        MyStyle.BorderTextures[`BOX_LARGE_SLIGHTTRANSPARENT] = Texture2D(ObjRef.ReferencedObjects[80]);
        MyStyle.BorderTextures[`BOX_LARGE_TRANSPARENT] = Texture2D(ObjRef.ReferencedObjects[81]);
        MyStyle.BorderTextures[`BOX_SMALL] = Texture2D(ObjRef.ReferencedObjects[82]);
        MyStyle.BorderTextures[`BOX_SMALL_SLIGHTTRANSPARENT] = Texture2D(ObjRef.ReferencedObjects[83]);
        MyStyle.BorderTextures[`BOX_SMALL_TRANSPARENT] = Texture2D(ObjRef.ReferencedObjects[84]);
        MyStyle.BorderTextures[`BOX_CORNER_8] = Texture2D(ObjRef.ReferencedObjects[160]);
        MyStyle.BorderTextures[`BOX_CORNER_16] = Texture2D(ObjRef.ReferencedObjects[156]);
        MyStyle.BorderTextures[`BOX_CORNER_32] = Texture2D(ObjRef.ReferencedObjects[157]);
        MyStyle.BorderTextures[`BOX_CORNER_64] = Texture2D(ObjRef.ReferencedObjects[159]);
        MyStyle.BorderTextures[`BOX_CORNER_512] = Texture2D(ObjRef.ReferencedObjects[158]);
        
        MyStyle.ArrowTextures[`ARROW_DOWN] = Texture2D(ObjRef.ReferencedObjects[10]);
        MyStyle.ArrowTextures[`ARROW_LEFT] = Texture2D(ObjRef.ReferencedObjects[45]);
        MyStyle.ArrowTextures[`ARROW_RIGHT] = Texture2D(ObjRef.ReferencedObjects[69]);
        MyStyle.ArrowTextures[`ARROW_UP] = Texture2D(ObjRef.ReferencedObjects[87]);
        
        MyStyle.ButtonTextures[`BUTTON_NORMAL] = Texture2D(ObjRef.ReferencedObjects[3]);
        MyStyle.ButtonTextures[`BUTTON_DISABLED] = Texture2D(ObjRef.ReferencedObjects[4]);
        MyStyle.ButtonTextures[`BUTTON_HIGHLIGHTED] = Texture2D(ObjRef.ReferencedObjects[5]);
        MyStyle.ButtonTextures[`BUTTON_PRESSED] = Texture2D(ObjRef.ReferencedObjects[6]);
        
        MyStyle.TabTextures[`TAB_TOP] = Texture2D(ObjRef.ReferencedObjects[76]);
        MyStyle.TabTextures[`TAB_BOTTOM] = Texture2D(ObjRef.ReferencedObjects[77]);
        
        MyStyle.ItemBoxTextures[`ITEMBOX_NORMAL] = Texture2D(ObjRef.ReferencedObjects[40]);
        MyStyle.ItemBoxTextures[`ITEMBOX_DISABLED] = Texture2D(ObjRef.ReferencedObjects[41]);
        MyStyle.ItemBoxTextures[`ITEMBOX_HIGHLIGHTED] = Texture2D(ObjRef.ReferencedObjects[42]);
        
        MyStyle.ItemBoxTextures[`ITEMBOX_BAR_NORMAL] = Texture2D(ObjRef.ReferencedObjects[37]);
        MyStyle.ItemBoxTextures[`ITEMBOX_BAR_DISABLED] = Texture2D(ObjRef.ReferencedObjects[38]);
        MyStyle.ItemBoxTextures[`ITEMBOX_BAR_HIGHLIGHTED] = Texture2D(ObjRef.ReferencedObjects[39]);
        
        MyStyle.CheckBoxTextures[`CHECKMARK_NORMAL] = Texture2D(ObjRef.ReferencedObjects[7]);
        MyStyle.CheckBoxTextures[`CHECKMARK_DISABLED] = Texture2D(ObjRef.ReferencedObjects[8]);
        MyStyle.CheckBoxTextures[`CHECKMARK_HIGHLIGHTED] = Texture2D(ObjRef.ReferencedObjects[9]);
        
        MyStyle.PerkBox[`PERK_BOX_SELECTED] = Texture2D(ObjRef.ReferencedObjects[60]);
        MyStyle.PerkBox[`PERK_BOX_UNSELECTED] = Texture2D(ObjRef.ReferencedObjects[61]);
        
        MyStyle.ScrollTexture = Texture2D(ObjRef.ReferencedObjects[71]);
        MyStyle.FavoriteIcon = Texture2D(ObjRef.ReferencedObjects[105]);
        MyStyle.BankNoteIcon = Texture2D(ObjRef.ReferencedObjects[106]);
        
        MyStyle.ProgressBarTextures[`PROGRESS_BAR_NORMAL] = Texture2D(ObjRef.ReferencedObjects[103]);
        MyStyle.ProgressBarTextures[`PROGRESS_BAR_SELECTED] = Texture2D(ObjRef.ReferencedObjects[68]);

        MyStyle.SliderTextures[`SLIDER_NORMAL] = Texture2D(ObjRef.ReferencedObjects[110]);
        MyStyle.SliderTextures[`SLIDER_GRIP] = Texture2D(ObjRef.ReferencedObjects[111]);
        MyStyle.SliderTextures[`SLIDER_DISABLED] = Texture2D(ObjRef.ReferencedObjects[112]);
        
        MyStyle.MenuDown = SoundCue(ObjRef.ReferencedObjects[49]);
        MyStyle.MenuDrag = SoundCue(ObjRef.ReferencedObjects[50]);
        MyStyle.MenuEdit = SoundCue(ObjRef.ReferencedObjects[51]);
        MyStyle.MenuFade = SoundCue(ObjRef.ReferencedObjects[52]);
        MyStyle.MenuClick = SoundCue(ObjRef.ReferencedObjects[53]);
        MyStyle.MenuHover = SoundCue(ObjRef.ReferencedObjects[54]);
        MyStyle.MenuUp = SoundCue(ObjRef.ReferencedObjects[55]);
    }
    
    MyGUIController = KF2GUIController(FindObject("KFClassicMode.Default__KF2GUIController",class'KF2GUIController'));
    if( MyGUIController != None )
    {
        MyGUIController.DefaultPens[`PEN_WHITE] = Texture2D(ObjRef.ReferencedObjects[108]);
        MyGUIController.DefaultPens[`PEN_BLACK] = Texture2D(ObjRef.ReferencedObjects[107]);
        MyGUIController.DefaultPens[`PEN_GRAY] = Texture2D(ObjRef.ReferencedObjects[109]);
    }
    
    /*
    DialogManager = KFClassicTraderDialog(FindObject("KFClassicMode.Default__KFClassicTraderDialog",class'KFClassicTraderDialog'));
    if( DialogManager != None )
    {
        for (i = 0; i < DialogManager.TraderVoices.Length; i++)
        {
            DialogManager.TraderVoices[i].Replacement = SoundCue(ObjRef.ReferencedObjects[90 + i]);
        }
    }
    */
    
    if( !class'WorldInfo'.static.IsMenuLevel() )
    {
        KFPerk_Survivalist(FindObject("KFGame.Default__KFPerk_Survivalist",class'KFPerk_Survivalist')).PerkIcon = Texture2D(ObjRef.ReferencedObjects[102]);
        KFEmit_TraderPath(FindObject("KFGame.Default__KFEmit_TraderPath",class'KFEmit_TraderPath')).EmitterTemplate = ParticleSystem(ObjRef.ReferencedObjects[89]);
        KFReplicatedShowPathActor(FindObject("KFGame.Default__KFReplicatedShowPathActor",class'KFReplicatedShowPathActor')).EmitterTemplate = ParticleSystem(ObjRef.ReferencedObjects[89]);
        KFGFxObject_TraderItems(FindObject("KFGame.Default__KFGFxObject_TraderItems",class'KFGFxObject_TraderItems')).OffPerkIconPath = PathName(ObjRef.ReferencedObjects[102]);
    }
    
    KFWaitingMessage(FindObject("KFClassicMode.Default__KFWaitingMessage",class'KFWaitingMessage')).CurrentFont = Font(ObjRef.ReferencedObjects[43]);
    ClassicHumanPawn(FindObject("KFClassicMode.Default__ClassicHumanPawn",class'ClassicHumanPawn')).TraderComBeep = SoundCue(ObjRef.ReferencedObjects[100]);
    
    HealProj(FindObject("KFClassicMode.Default__HealProj",class'HealProj')).ProjFlightTemplate = ParticleSystem(ObjRef.ReferencedObjects[165]);
    HealProj(FindObject("KFClassicMode.Default__HealProj",class'HealProj')).ProjFlightTemplateZedTime = ParticleSystem(ObjRef.ReferencedObjects[165]);
    SpectatorUFO(FindObject("KFClassicMode.Default__SpectatorUFO",class'SpectatorUFO')).StaticMeshComponent.SetStaticMesh(StaticMesh(ObjRef.ReferencedObjects[166]), true);
    SpectatorFlame(FindObject("KFClassicMode.Default__SpectatorFlame",class'SpectatorFlame')).EmitterTemplate = ParticleSystem(ObjRef.ReferencedObjects[167]);
   
    ClassicPawn_ZedBloat(FindObject("KFClassicMode.Default__ClassicPawn_ZedBloat",class'ClassicPawn_ZedBloat')).PawnAnimInfo = KFPawnAnimInfo(ObjRef.ReferencedObjects[123]);
    ClassicPawn_ZedClot_Alpha(FindObject("KFClassicMode.Default__ClassicPawn_ZedClot_Alpha",class'ClassicPawn_ZedClot_Alpha')).PawnAnimInfo = KFPawnAnimInfo(ObjRef.ReferencedObjects[122]);
    ClassicPawn_ZedCrawler(FindObject("KFClassicMode.Default__ClassicPawn_ZedCrawler",class'ClassicPawn_ZedCrawler')).PawnAnimInfo = KFPawnAnimInfo(ObjRef.ReferencedObjects[124]);
    ClassicPawn_ZedFleshpound(FindObject("KFClassicMode.Default__ClassicPawn_ZedFleshpound",class'ClassicPawn_ZedFleshpound')).PawnAnimInfo = KFPawnAnimInfo(ObjRef.ReferencedObjects[125]);
    ClassicPawn_ZedGorefast(FindObject("KFClassicMode.Default__ClassicPawn_ZedGorefast",class'ClassicPawn_ZedGorefast')).PawnAnimInfo = KFPawnAnimInfo(ObjRef.ReferencedObjects[126]);
    ClassicPawn_ZedPatriarch(FindObject("KFClassicMode.Default__ClassicPawn_ZedPatriarch",class'ClassicPawn_ZedPatriarch')).PawnAnimInfo = KFPawnAnimInfo(ObjRef.ReferencedObjects[127]);
    ClassicPawn_ZedScrake(FindObject("KFClassicMode.Default__ClassicPawn_ZedScrake",class'ClassicPawn_ZedScrake')).PawnAnimInfo = KFPawnAnimInfo(ObjRef.ReferencedObjects[128]);
    ClassicPawn_ZedStalker(FindObject("KFClassicMode.Default__ClassicPawn_ZedStalker",class'ClassicPawn_ZedStalker')).PawnAnimInfo = KFPawnAnimInfo(ObjRef.ReferencedObjects[129]);
    ClassicPawn_ZedHusk(FindObject("KFClassicMode.Default__ClassicPawn_ZedHusk",class'ClassicPawn_ZedHusk')).AnimTreeReplacment = AnimTree(ObjRef.ReferencedObjects[130]);
    
    MusicGRI = class'MusicGRI'.static.FindMusicGRI(WorldInfo);
    if( MusicGRI != None )
    {
        SetupMusicGRI();
    }
    else
    {
        SetTimer(15.f, false, 'SetupMusicGRI');
    }
    
    if( WorldInfo.NetMode != NM_Client )
        SetTimer(1.f, false, 'SearchForMutators');
}

// Automatically generate a KFMutatorSummary entry inside of KFGame.ini
final function SearchForMutators()
{
    local Mutator M;
    
    foreach DynamicActors(class'Mutator', M)
        Mutators.AddItem(M.Class);
        
    if( Mutators.Length > 0 )
        SetTimer(0.1f, true, 'ReplicateMutatorName');
}

final function ReplicateMutatorName()
{
    if( RepIndex >= Mutators.Length )
    {
        Mutators.Length = 0;
        ClearTimer('ReplicateMutatorName');
        return;
    }
    
    GenerateMutatorEntry(Mutators[RepIndex].Name, PathName(Mutators[RepIndex]));
    RepIndex++;
}

reliable client function GenerateMutatorEntry(name ClassName, string PathName)
{
    local KFMutatorSummary MutatorSummary;
    local array<string> Names;
    local int i;
    local bool bFoundConfig;
    
    GetPerObjectConfigSections(class'KFMutatorSummary', Names);
    for (i = 0; i < Names.Length; i++)
    {
        if( InStr(Names[i], string(ClassName)) != INDEX_NONE )
        {
            bFoundConfig = true;
            break;
        }
    }
    
    if( !bFoundConfig )
    {
        MutatorSummary = New(None, string(ClassName)) class'KFMutatorSummary';
        MutatorSummary.ClassName = PathName;
        MutatorSummary.SaveConfig();
    }
}

simulated final function SetupMusicGRI()
{
    local MusicGRI MusicGRI;
    
    MusicGRI = class'MusicGRI'.static.FindMusicGRI(WorldInfo);
    if( MusicGRI == None || MusicGRI.BossTrack != None )
        return;
        
    MusicGRI.BossMusic = SoundCue(ObjRef.ReferencedObjects[101]);
    
    MusicGRI.BossTrack = New(None) class'KFMusicTrackInfo_Custom';
    MusicGRI.BossTrack.StandardSong = MusicGRI.BossMusic;
    MusicGRI.BossTrack.InstrumentalSong = MusicGRI.BossMusic;
    MusicGRI.BossTrack.bLoop = true;
}

defaultproperties
{
    Components.Empty()
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
    bSkipActorPropertyReplication=True
    bOnlyDirtyReplication=True
    NetUpdateFrequency=4
    
    BaseRef=ObjectReferencer'KFClassicMode_Assets.ObjectRef.MainObj_List'
}