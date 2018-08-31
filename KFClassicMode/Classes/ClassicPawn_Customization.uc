class ClassicPawn_Customization extends KFPawn_Customization;

simulated function KFCharacterInfoBase GetCharacterInfo()
{
	if( ClassicPlayerReplicationInfo(PlayerReplicationInfo)!=None )
		return ClassicPlayerReplicationInfo(PlayerReplicationInfo).GetSelectedArch();
	return Super.GetCharacterInfo();
}

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
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
	}

	if( CharacterArch != none )
	{
		if( CharacterArch.VoiceGroupArchName != "" )
			VoiceGroupArch = class<KFPawnVoiceGroup>(class'ClassicCharacterInfo'.Static.SafeLoadObject(CharacterArch.VoiceGroupArchName, class'Class'));
	}
}

simulated function SetCharacterAnimationInfo()
{
	local KFCharacterInfo_Human CharInfoHuman;

	super(KFPawn).SetCharacterAnimationInfo();

	// Character Animation
	CharInfoHuman = KFCharacterInfo_Human( GetCharacterInfo() );
	if( CharInfoHuman != none )
	{
		if( CharInfoHuman.bIsFemale )
		{
			Mesh.AnimSets.AddItem(FemaleCustomizationAnimSet);
		}
		else
		{
			Mesh.AnimSets.AddItem(MaleCustomizationAnimSet);
		}
	}
	
	Mesh.UpdateAnimations();
	PlayRandomIdleAnimation(true);
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	// Destroy this pawn if player leaves.
	Destroy();
	return true;
}

simulated function PlayEmoteAnimation(optional bool bNewCharacter)
{
	local name AnimName;
	local float BlendInTime;

	AnimName = class'ClassicEmoteList'.static.GetUnlockedEmote( class'ClassicEmoteList'.static.GetEquippedEmoteId(ClassicPlayerController(Controller)), ClassicPlayerController(Controller) );	

	BlendInTime = (bNewCharacter) ? 0.f : 0.4;

	// Briefly turn off notify so that PlayCustomAnim won't call OnAnimEnd (e.g. character swap)
	BodyStanceNodes[EAS_FullBody].SetActorAnimEndNotification( FALSE );

	BodyStanceNodes[EAS_FullBody].PlayCustomAnim(AnimName, 1.f, BlendInTime, 0.4, false, true);
	BodyStanceNodes[EAS_FullBody].SetActorAnimEndNotification( TRUE );
}

defaultproperties
{
	bCollideActors=false
	bBlockActors=false
}