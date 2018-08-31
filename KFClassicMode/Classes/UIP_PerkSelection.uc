Class UIP_PerkSelection extends KFGUI_MultiComponent;

var UIR_PerkInfoContainer PerkInfoBox;
var UIR_PerkEffectContainer PerkEffectList;
var UIR_LevelRequirementsList NextLevelRequirementList;
var ClassicPerk_Base SelectedPerk;
var ClassicPlayerController PC;

function InitMenu()
{
    PerkInfoBox = UIR_PerkInfoContainer(FindComponentID('PerksBox'));
    PerkEffectList = UIR_PerkEffectContainer(FindComponentID('PerkEffects'));
    NextLevelRequirementList = UIR_LevelRequirementsList(FindComponentID('NextLevelRequirements'));
	
	PC = ClassicPlayerController(GetPlayer());
	PC.PerkSelectionBox = Self;
	
	SetTimer(0.1, true);
    
    Super.InitMenu();
}

function Timer()
{
	if( !bTextureInit )
	{
		GetStyleTextures();
		return;
	}
	
	SetTimer(0.f);
}

function GetStyleTextures()
{
	if( !Owner.bFinishedReplication )
	{
		return;
	}
	
	PerkInfoBox.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
	PerkEffectList.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
	NextLevelRequirementList.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
	
	bTextureInit = true;
}

defaultproperties
{
    Begin Object Class=UIR_PerkInfoContainer Name=PerksContainer
        ID="PerksBox"
        XPosition=0
        YPosition=0
        XSize=0.465
        YSize=1.08
		WindowTitle="Select Perk"
    End Object  
    
    Begin Object Class=UIR_PerkEffectContainer Name=PerkEffectsList
        ID="PerkEffects"
        XPosition=0.49
        YPosition=0
        XSize=0.48
        YSize=0.53
		WindowTitle="Perk Effects"
    End Object
    
    Begin Object Class=UIR_LevelRequirementsList Name=NextLevelRequirementsList
        ID="NextLevelRequirements"
        XPosition=0.49
        YPosition=0.55
        XSize=0.48
        YSize=0.53
		WindowTitle="Next Level Requirements"
    End Object
	
    Components.Add(PerksContainer)
    Components.Add(PerkEffectsList)
    Components.Add(NextLevelRequirementsList)
}