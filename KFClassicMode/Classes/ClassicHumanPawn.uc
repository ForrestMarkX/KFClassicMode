Class ClassicHumanPawn extends KFPawn_Human;

var AudioComponent TraderDialogCueComp;
var SoundCue TraderComBeep;
var AkEvent CurrentTraderVoice;
var float CurrentTraderVoiceDuration;
var class<KFClassicTraderDialog> TraderDialogClass;
var class<KFTraderVoiceGroupBase> CurrentVoiceClass;

var float BaseMeleeIncrease;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

	if( WorldInfo.NetMode==NM_Client )
	{
		SetTimer(0.1,true,'GetTraderCom');
	}
}

simulated function GetTraderCom()
{
	local KFGameReplicationInfo GRI;
	local KFTraderDialogManager DialogManager;
	
	TraderComBeep = default.TraderComBeep;
	if( TraderComBeep != None )
	{
		ClearTimer('GetTraderCom');
	}
	
	GRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( GRI != None )
	{
		DialogManager = GRI.TraderDialogManager;
		if( DialogManager != None && DialogManager.TraderVoiceGroupClass == None )
		{
			DialogManager.TraderVoiceGroupClass = class'KFGameContent.KFTraderVoiceGroup_Default';
		}
	}
	
	CurrentVoiceClass = GetTraderVoiceGroupClass();
}

function UpdateGroundSpeed()
{
	Super.UpdateGroundSpeed();
	
	if( KFWeapon(Weapon) != None && KFWeapon(Weapon).IsMeleeWeapon() )
	{
		GroundSpeed += (default.GroundSpeed * BaseMeleeIncrease);
	}
}

simulated event Rotator GetBaseAimRotation()
{
	if( PlayerController(Controller).PlayerCamera.CameraStyle == 'ThirdPerson' )
		return Rotation;
	return Super.GetBaseAimRotation();
}

simulated function class<KFTraderVoiceGroupBase> GetTraderVoiceGroupClass()
{
	local KFGameReplicationInfo KFGRI;
	
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None && KFGRI.TraderDialogManager != None )
	{
		return KFGRI.TraderDialogManager.TraderVoiceGroupClass;
	}
	
	return class'KFTraderVoiceGroup_Default';
}

function PlayTraderDialog( AkEvent DialogEvent )
{
	local AudioComponent WalkieBeep;
	local bool bRadio;
	local KFGameEngine Engine;
	
	Engine = KFGameEngine(class'Engine'.static.GetEngine());
    if( bDisableTraderDialog || DialogEvent == None || Engine.DialogVolumeMultiplier <= 0.f || Engine.MasterVolumeMultiplier <= 0.f )
    {
        return;
    }
	
	if( CurrentVoiceClass == None )
	{
		CurrentVoiceClass = GetTraderVoiceGroupClass();
	}
    
    if( CurrentVoiceClass == None || class<KFTraderVoiceGroup_Default>(CurrentVoiceClass) == None )
    {
        CurrentTraderVoice = DialogEvent;
        CurrentTraderVoiceDuration = DialogEvent.Duration;
        
		Super.PlayTraderDialog(DialogEvent);
		
		if( InStr(string(DialogEvent.Class.Name), "SHOP") == INDEX_NONE )
		{
			KFHUDInterface(PlayerController(Controller).myHUD).bDrawingPortrait = true;
		}
		
        return;
    }
	
    if( TraderDialogCueComp == None )
	{
        return;
	}
	
	if( TraderDialogCueComp.SoundCue != None )
	{
		TraderDialogCueComp.SoundCue = None;
	}

	bRadio = TraderDialogClass.static.GetReplacment(self, DialogEvent, TraderDialogCueComp.SoundCue);
	if( TraderDialogCueComp.SoundCue == None )
	{
		return;
	}
		
	TraderDialogCueComp.SoundCue.bPitchShiftWithTimeDilation = false;
	TraderDialogCueComp.VolumeMultiplier = (Engine.DialogVolumeMultiplier/100.f) * (Engine.MasterVolumeMultiplier/100.f);
    CurrentTraderVoiceDuration = TraderDialogCueComp.SoundCue.Duration + (bRadio ? TraderComBeep.Duration : 0.f);
	
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
			
			KFHUDInterface(PlayerController(Controller).myHUD).bDrawingPortrait = true;
		}
	}
	else
	{
		PlayTraderVoice(TraderDialogCueComp);
	}
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
	{
		KFGRI.TraderDialogManager.EndOfDialogTimer();
	}
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

simulated function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local ClassicPlayerController C;
	local class<Pawn> KillerPawn;
	local PlayerReplicationInfo KillerPRI;

	if( WorldInfo.NetMode!=NM_Client && PlayerReplicationInfo!=None )
	{
		if( Killer==None || Killer==Controller )
		{
			KillerPRI = PlayerReplicationInfo;
			KillerPawn = None;
		}
		else
		{
			KillerPRI = Killer.PlayerReplicationInfo;
			if( KillerPRI==None || KillerPRI.Team!=PlayerReplicationInfo.Team )
			{
				KillerPawn = Killer.Pawn!=None ? Killer.Pawn.Class : None;
				if( PlayerController(Killer)==None ) // If was killed by a monster, don't broadcast PRI along with it.
					KillerPRI = None;
			}
			else KillerPawn = None;
		}
		foreach WorldInfo.AllControllers(class'ClassicPlayerController',C)
			C.ClientKillMessage(damageType,PlayerReplicationInfo,KillerPRI,KillerPawn);
	}
	return Super.Died(Killer, DamageType, HitLocation);
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
			{
				WeaponAttachmentChanged(true);
			}
		}
		if( WorldInfo.NetMode != NM_DedicatedServer )
		{
			// Attach/Reattach flashlight components when mesh is set
			if ( Flashlight == None && FlashLightTemplate != None )
			{
				Flashlight = new(self) Class'KFFlashlightAttachment' (FlashLightTemplate);
			}
			if ( FlashLight != None )
			{
				Flashlight.AttachFlashlight(Mesh);
			}
		}
		if( CharacterArch != none )
		{
			if( CharacterArch.VoiceGroupArchName != "" )
				VoiceGroupArch = class<KFPawnVoiceGroup>(class'ClassicCharacterInfo'.Static.SafeLoadObject(CharacterArch.VoiceGroupArchName, class'Class'));
		}
	}
}

function AddDefaultInventory()
{
    local KFPerk MyPerk;

    MyPerk = GetPerk();

	if( MyPerk != none )
	{
        MyPerk.AddDefaultInventory(self);
    }
	
	Super(KFPawn).AddDefaultInventory();
}

function SetSprinting(bool bNewSprintStatus);

defaultproperties
{
	Begin Object Class=KFFlashlightAttachment name=Flashlight_1
        LightConeMesh=StaticMesh'wep_flashlights_mesh.WEP_3P_Lightcone'
    End Object
	FlashLightTemplate=Flashlight_1
	
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
	
	DefaultInventory.Empty
	DefaultInventory.Add(class'ClassicWeap_Pistol_9mm')
	DefaultInventory.Add(class'ClassicWeap_Healer_Syringe')
	DefaultInventory.Add(class'KFWeap_Welder')
	DefaultInventory.Add(class'KFInventory_Money')
	
	TraderDialogClass=class'KFClassicTraderDialog'
	InventoryManagerClass=class'ClassicInventoryManager'
	
	bAllowSprinting=false
	BaseMeleeIncrease=0.2f
}