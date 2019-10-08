Class ClassicHumanPawn extends KFPawn_Human;

var AudioComponent TraderDialogCueComp;
var SoundCue TraderComBeep;
var AkEvent CurrentTraderVoice;
var class<KFClassicTraderDialog> TraderDialogClass;
var class<KFTraderVoiceGroupBase> CurrentVoiceClass;

var byte RepRegenHP;
var float BaseMeleeIncrease;

replication
{
    if( true )
        RepRegenHP;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    if( WorldInfo.NetMode==NM_Client )
        SetTimer(0.1,true,'GetTraderCom');
}

simulated function GetTraderCom()
{
    local KFGameReplicationInfo GRI;
    local KFTraderDialogManager DialogManager;
    
    TraderComBeep = default.TraderComBeep;
    if( TraderComBeep != None )
        ClearTimer('GetTraderCom');
    
    GRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( GRI != None )
    {
        DialogManager = GRI.TraderDialogManager;
        if( DialogManager != None && DialogManager.TraderVoiceGroupClass == None )
            DialogManager.TraderVoiceGroupClass = class'KFGameContent.KFTraderVoiceGroup_Default';
    }
    
    CurrentVoiceClass = GetTraderVoiceGroupClass();
}

function UpdateGroundSpeed()
{
    local ClassicPlayerController CPC;
    
    Super.UpdateGroundSpeed();
    
    CPC = ClassicPlayerController(Controller);
    if( CPC != None )
    {
        if( CPC.bEnableTraderSpeed && KFGameReplicationInfo(WorldInfo.GRI).bTraderIsOpen )
        {
            GroundSpeed += (default.GroundSpeed * 0.5f);
            SprintSpeed += (default.SprintSpeed * 0.5f);
        }
            
        if( CPC.bDisableGameplayChanges )
            return;
    }
    
    if( KFWeapon(Weapon) != None && KFWeapon(Weapon).IsMeleeWeapon() )
        GroundSpeed += (default.GroundSpeed * BaseMeleeIncrease);
}

simulated function class<KFTraderVoiceGroupBase> GetTraderVoiceGroupClass()
{
    local KFGameReplicationInfo KFGRI;
    
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( KFGRI != None && KFGRI.TraderDialogManager != None )
        return KFGRI.TraderDialogManager.TraderVoiceGroupClass;
    
    return class'KFTraderVoiceGroup_Default';
}

function PlayTraderDialog( AkEvent DialogEvent )
{
    local AudioComponent WalkieBeep;
    local bool bRadio;
    local KFGameEngine Engine;
    local KFHUDInterface HUDInterface;
    
    Engine = KFGameEngine(class'Engine'.static.GetEngine());
    if( bDisableTraderDialog || DialogEvent == None || Engine.DialogVolumeMultiplier <= 0.f || Engine.MasterVolumeMultiplier <= 0.f )
        return;
    
    if( ClassicPlayerController(Controller).bDisableClassicTrader )
    {
        Super.PlayTraderDialog(DialogEvent);
        return;
    }
    
    if( CurrentVoiceClass == None )
        CurrentVoiceClass = GetTraderVoiceGroupClass();
    
    HUDInterface = KFHUDInterface(PlayerController(Controller).myHUD);
    
    if( CurrentVoiceClass == None || class<KFTraderVoiceGroup_Default>(CurrentVoiceClass) == None )
    {
        CurrentTraderVoice = DialogEvent;
        
        Super.PlayTraderDialog(DialogEvent);
        
        if( InStr(string(DialogEvent.Class.Name), "SHOP") == INDEX_NONE )
        {
            HUDInterface.PortraitTime = WorldInfo.TimeSeconds + DialogEvent.Duration;
            HUDInterface.bDrawingPortrait = true;
        }
        
        return;
    }
    
    if( TraderDialogCueComp == None )
        return;
    
    if( TraderDialogCueComp.SoundCue != None )
        TraderDialogCueComp.SoundCue = None;

    bRadio = TraderDialogClass.static.GetReplacment(self, DialogEvent, TraderDialogCueComp.SoundCue);
    if( TraderDialogCueComp.SoundCue == None )
        return;
        
    TraderDialogCueComp.SoundCue.bPitchShiftWithTimeDilation = false;
    TraderDialogCueComp.VolumeMultiplier = (Engine.DialogVolumeMultiplier/100.f) * (Engine.MasterVolumeMultiplier/100.f);
    
    if( bRadio )
    {
        WalkieBeep = CreateAudioComponent(TraderComBeep, true);
        if( WalkieBeep != None )
        {
            WalkieBeep.SoundCue.bPitchShiftWithTimeDilation = false;

            WalkieBeep.VolumeMultiplier = (Engine.DialogVolumeMultiplier/100.f) * (Engine.MasterVolumeMultiplier/100.f);
            WalkieBeep.OcclusionCheckInterval = 0.f;
            WalkieBeep.bAutoDestroy = true;
            WalkieBeep.OnAudioFinished = PlayTraderVoice;
            
            HUDInterface.PortraitTime = WorldInfo.TimeSeconds + (TraderDialogCueComp.SoundCue.Duration + (bRadio ? TraderComBeep.Duration : 0.f));
            HUDInterface.bDrawingPortrait = true;
        }
    }
    else PlayTraderVoice(TraderDialogCueComp);
}

function PlayTraderVoice(AudioComponent AC)
{
    if( TraderDialogCueComp == None || TraderDialogCueComp.SoundCue == None )
        return;
        
    TraderDialogCueComp.Play();
}

function EndTraderDialog(AudioComponent AC)
{
    local KFGameReplicationInfo KFGRI;
    
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( KFGRI != None && KFGRI.TraderDialogManager != None )
        KFGRI.TraderDialogManager.EndOfDialogTimer();
}

function StopTraderDialog()
{
    if( class<KFTraderVoiceGroup_Default>(CurrentVoiceClass) == None )
    {
        Super.StopTraderDialog();
        return;
    }
    
    if( TraderDialogCueComp == None || TraderDialogCueComp.SoundCue == None )
        return;

    TraderDialogCueComp.Stop();
}

simulated function bool Died(Controller Killer, class<DamageType> DmgType, vector HitLocation)
{
    local ClassicPlayerController C;
    local PlayerReplicationInfo KillerPRI;

    if( WorldInfo.NetMode!=NM_Client && PlayerReplicationInfo!=None )
    {
        if( Killer==None || Killer==Controller )
            KillerPRI = PlayerReplicationInfo;
        else
        {
            KillerPRI = Killer.PlayerReplicationInfo;
            if( KillerPRI==None || KillerPRI.Team!=PlayerReplicationInfo.Team )
            {
                if( PlayerController(Killer)==None ) // If was killed by a monster, don't broadcast PRI along with it.
                    KillerPRI = None;
            }
        }
        foreach WorldInfo.AllControllers(class'ClassicPlayerController',C)
        {
            if( C.bClientHidePlayerDeaths )
                continue;
            C.ClientKillMessage(DmgType, self.Class, Killer, PlayerReplicationInfo, KillerPRI);
        }
    }
    return Super.Died(Killer, DmgType, HitLocation);
}

simulated function KFCharacterInfoBase GetCharacterInfo()
{
    if( ClassicPlayerReplicationInfo(PlayerReplicationInfo)!=None )
        return ClassicPlayerReplicationInfo(PlayerReplicationInfo).GetSelectedArch();
    return Super.GetCharacterInfo();
}

simulated function SetCharacterArch(KFCharacterInfoBase Info, optional bool bForce )
{
    local KFPlayerReplicationInfo KFPRI;

    KFPRI = KFPlayerReplicationInfo( PlayerReplicationInfo );
    if (Info != CharacterArch || bForce)
    {
        // Set Family Info
        CharacterArch = Info;
        CharacterArch.SetCharacterFromArch( self, KFPRI );
        class'ClassicCharacterInfo'.Static.SetCharacterMeshFromArch( KFCharacterInfo_Human(CharacterArch), self, KFPRI );
        class'ClassicCharacterInfo'.Static.SetFirstPersonArmsFromArch( KFCharacterInfo_Human(CharacterArch), self, KFPRI );

        SetCharacterAnimationInfo();

        // Sounds
        SoundGroupArch = Info.SoundGroupArch;

        if (WorldInfo.NetMode != NM_DedicatedServer)
        {
            // refresh weapon attachment (attachment bone may have changed)
            if (WeaponAttachmentTemplate != None)
                WeaponAttachmentChanged(true);
            
            // Attach/Reattach flashlight components when mesh is set
            if ( Flashlight == None && FlashLightTemplate != None )
            {
                Flashlight = new(self) Class'KFFlashlightAttachment' (FlashLightTemplate);
                Flashlight.AttachFlashlight(Mesh);
            }
            else if ( FlashLight != None )
                Flashlight.Reattach();
        }
        if( CharacterArch != none )
        {
            if( CharacterArch.VoiceGroupArchName != "" )
                VoiceGroupArch = class<KFPawnVoiceGroup>(class'ClassicCharacterInfo'.Static.SafeLoadObject(CharacterArch.VoiceGroupArchName, class'Class'));
        }
    }
}

function SacrificeExplode()
{
    local KFExplosionActorReplicated ExploActor;
    local GameExplosion ExplosionTemplate;
    local ClassicPerk_Demolitionist_Default DemoPerk;

    if ( Role < ROLE_Authority )
        return;

    DemoPerk = ClassicPerk_Demolitionist_Default(GetPerk());

    // explode using the given template
    ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location,,, true);
    if( ExploActor != None )
    {
        ExploActor.InstigatorController = Controller;
        ExploActor.Instigator = self;

        ExplosionTemplate = class'KFPerk_Demolitionist'.static.GetSacrificeExplosionTemplate();
        ExplosionTemplate.bIgnoreInstigator = true;
        ExploActor.Explode( ExplosionTemplate );

        if( DemoPerk != none )
            DemoPerk.NotifyPerkSacrificeExploded();
    }
}

function GiveHealthOverTime()
{
    RepRegenHP = HealthToRegen;
    Super.GiveHealthOverTime();
}

function SetSprinting(bool bNewSprintStatus)
{
    if( ClassicPlayerController(Controller) != None && ClassicPlayerController(Controller).bDisableGameplayChanges )
        Super.SetSprinting(bNewSprintStatus);
}

simulated function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
    if( PlayerController(Controller) != None && !PlayerController(Controller).UsingFirstPersonCamera() )
    {
        return GetBaseAimRotation();
    }
    
    return Super.GetAdjustedAimFor(W, StartFireLoc);
}

defaultproperties
{
    Begin Object Name=SpecialMoveHandler_0
        SpecialMoveClasses(SM_Emote)=class'KFClassicMode.ClassicSM_Player_Emote'
    End Object
    
    Begin Object Class=AudioComponent Name=TraderDialogCue1
        bAutoPlay=false
        bShouldRemainActiveIfDropped=true
        bIsUISound=true
        OcclusionCheckInterval=0.f
        OnAudioFinished=EndTraderDialog
    End Object
    TraderDialogCueComp=TraderDialogCue1
    Components.Add(TraderDialogCue1)
    
    TraderDialogClass=class'KFClassicTraderDialog'
    InventoryManagerClass=class'ClassicInventoryManager'
    
    BaseMeleeIncrease=0.2f
}