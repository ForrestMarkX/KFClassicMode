class UIR_LobbyPerkEffects extends KFGUI_Frame;

var KFGUI_TextScroll PerkEffectsScroll;
var ClassicPerk_Base CurrentSelectedPerk;
var byte CurrentPerkLevel;

function InitMenu()
{
	Super.InitMenu();
	PerkEffectsScroll = KFGUI_TextScroll(FindComponentID('PerkEffectsScroll'));
}

function ShowMenu()
{
	Super.ShowMenu();
	
	Timer();
	SetTimer(0.1,true);
}

function Timer()
{
	local ClassicPerk_Base CurrentPerk;
	local ClassicPlayerController PC;
	local string S;
	local byte CurrentVetLevel;
	
	PC = ClassicPlayerController(GetPlayer());
	if( PC == None )
		return;
		
	CurrentPerk = ClassicPerk_Base(PC.CurrentPerk);
	if( CurrentPerk == None || (CurrentSelectedPerk == CurrentPerk && CurrentPerkLevel == CurrentPerk.GetLevel()) )
		return;
		
	CurrentVetLevel = CurrentPerk.GetLevel();
	S = CurrentPerk.static.GetCustomLevelInfo(CurrentVetLevel);
	
	if( CurrentVetLevel < CurrentPerk.MaximumLevel )
	{
		S = S $ "|| --- Next Level Effects --- ||" $ CurrentPerk.static.GetCustomLevelInfo(CurrentVetLevel+1);
	}
		
	CurrentPerkLevel = CurrentVetLevel;
	CurrentSelectedPerk = CurrentPerk;
	PerkEffectsScroll.SetText(S);
}

defaultproperties
{
	Begin Object Class=KFGUI_TextScroll Name=PerkEffectsScroll
		ID="PerkEffectsScroll"
		ScrollSpeed=0.025
	End Object
	Components.Add(PerkEffectsScroll)
}