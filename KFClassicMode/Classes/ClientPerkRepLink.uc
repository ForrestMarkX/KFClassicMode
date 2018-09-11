Class ClientPerkRepLink extends ReplicationInfo
    transient;

var repnotify ObjectReferencer ObjRef;
var ObjectReferencer BaseRef;

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
    local int i;
    //local KFClassicTraderDialog DialogManager;
    local ClassicPerk_Berserker BerserkerPerk;
    local ClassicPerk_Commando CommandoPerk;
    local ClassicPerk_Demolitionist DemolitionistPerk;
    local ClassicPerk_Firebug FirebugPerk;
    local ClassicPerk_Medic MedicPerk;
    local ClassicPerk_Sharpshooter SharpshooterPerk;
    local ClassicPerk_Support SupportPerk;
    local KF2GUIController MyGUIController;
    local GUIStyleBase MyStyle;
    
    BerserkerPerk = ClassicPerk_Berserker(FindObject("KFClassicMode.Default__ClassicPerk_Berserker",class'ClassicPerk_Berserker'));
    if( BerserkerPerk != None )
    {
        for (i = 0; i < BerserkerPerk.OnHUDIcons.Length; i++)
        {
            BerserkerPerk.OnHUDIcons[i].PerkIcon = Texture2D(ObjRef.ReferencedObjects[59]);
            BerserkerPerk.OnHUDIcons[i].StarIcon = Texture2D(ObjRef.ReferencedObjects[28]);
        }
    }
    
    CommandoPerk = ClassicPerk_Commando(FindObject("KFClassicMode.Default__ClassicPerk_Commando",class'ClassicPerk_Commando'));
    if( CommandoPerk != None )
    {
        for (i = 0; i < CommandoPerk.OnHUDIcons.Length; i++)
        {
            CommandoPerk.OnHUDIcons[i].PerkIcon = Texture2D(ObjRef.ReferencedObjects[62]);
            CommandoPerk.OnHUDIcons[i].StarIcon = Texture2D(ObjRef.ReferencedObjects[28]);
        }
    }
    
    DemolitionistPerk = ClassicPerk_Demolitionist(FindObject("KFClassicMode.Default__ClassicPerk_Demolitionist",class'ClassicPerk_Demolitionist'));
    if( DemolitionistPerk != None )
    {
        for (i = 0; i < DemolitionistPerk.OnHUDIcons.Length; i++)
        {
            DemolitionistPerk.OnHUDIcons[i].PerkIcon = Texture2D(ObjRef.ReferencedObjects[63]);
            DemolitionistPerk.OnHUDIcons[i].StarIcon = Texture2D(ObjRef.ReferencedObjects[28]);
        }
    }
    
    FirebugPerk = ClassicPerk_Firebug(FindObject("KFClassicMode.Default__ClassicPerk_Firebug",class'ClassicPerk_Firebug'));
    if( FirebugPerk != None )
    {
        for (i = 0; i < FirebugPerk.OnHUDIcons.Length; i++)
        {
            FirebugPerk.OnHUDIcons[i].PerkIcon = Texture2D(ObjRef.ReferencedObjects[64]);
            FirebugPerk.OnHUDIcons[i].StarIcon = Texture2D(ObjRef.ReferencedObjects[28]);
        }
    }
    
    MedicPerk = ClassicPerk_Medic(FindObject("KFClassicMode.Default__ClassicPerk_Medic",class'ClassicPerk_Medic'));
    if( MedicPerk != None )
    {
        for (i = 0; i < MedicPerk.OnHUDIcons.Length; i++)
        {
            MedicPerk.OnHUDIcons[i].PerkIcon = Texture2D(ObjRef.ReferencedObjects[65]);
            MedicPerk.OnHUDIcons[i].StarIcon = Texture2D(ObjRef.ReferencedObjects[28]);
        }
    }
    
    SharpshooterPerk = ClassicPerk_Sharpshooter(FindObject("KFClassicMode.Default__ClassicPerk_Sharpshooter",class'ClassicPerk_Sharpshooter'));
    if( SharpshooterPerk != None )
    {
        for (i = 0; i < SharpshooterPerk.OnHUDIcons.Length; i++)
        {
            SharpshooterPerk.OnHUDIcons[i].PerkIcon = Texture2D(ObjRef.ReferencedObjects[66]);
            SharpshooterPerk.OnHUDIcons[i].StarIcon = Texture2D(ObjRef.ReferencedObjects[28]);
        }
    }
    
    SupportPerk = ClassicPerk_Support(FindObject("KFClassicMode.Default__ClassicPerk_Support",class'ClassicPerk_Support'));
    if( SupportPerk != None )
    {
        for (i = 0; i < SupportPerk.OnHUDIcons.Length; i++)
        {
            SupportPerk.OnHUDIcons[i].PerkIcon = Texture2D(ObjRef.ReferencedObjects[67]);
            SupportPerk.OnHUDIcons[i].StarIcon = Texture2D(ObjRef.ReferencedObjects[28]);
        }
    }
    
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
        MyStyle.MainFont = Font(ObjRef.ReferencedObjects[104]);
        
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
    
    KFPerk_Survivalist(FindObject("KFGame.Default__KFPerk_Survivalist",class'KFPerk_Survivalist')).PerkIcon = Texture2D(ObjRef.ReferencedObjects[102]);
    ClassicHumanPawn(FindObject("KFClassicMode.Default__ClassicHumanPawn",class'ClassicHumanPawn')).TraderComBeep = SoundCue(ObjRef.ReferencedObjects[100]);
    KFEmit_TraderPath(FindObject("KFGame.Default__KFEmit_TraderPath",class'KFEmit_TraderPath')).EmitterTemplate = ParticleSystem(ObjRef.ReferencedObjects[89]);
    KFWaitingMessage(FindObject("KFClassicMode.Default__KFWaitingMessage",class'KFWaitingMessage')).CurrentFont = Font(ObjRef.ReferencedObjects[43]);
    MusicGRI(FindObject("KFClassicMode.Default__MusicGRI",class'MusicGRI')).BossMusic = SoundCue(ObjRef.ReferencedObjects[101]);
    KFGFxObject_TraderItems(FindObject("KFGame.Default__KFGFxObject_TraderItems",class'KFGFxObject_TraderItems')).OffPerkIconPath = PathName(ObjRef.ReferencedObjects[102]);
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