Class UIR_PerkEffectContainer extends KFGUI_Frame;

var KFGUI_TextField EffectList;
var ClassicPerk_Base CurrentSelectedPerk;
var byte CurrentPerkLevel;

function InitMenu()
{
    EffectList = KFGUI_TextField(FindComponentID('Info'));
    Super.InitMenu();
}

function ShowMenu()
{
    Super.ShowMenu();
    
    SetTimer(0.1,true);
    Timer();
}

function Timer()
{
    local UIP_PerkSelection SelectionParent;
    local byte CurrentVetLevel;
    local string S;
    
    SelectionParent = UIP_PerkSelection(ParentComponent);
    if( SelectionParent == None || (CurrentSelectedPerk == SelectionParent.SelectedPerk && CurrentPerkLevel == SelectionParent.SelectedPerk.GetLevel()) )
        return;
        
    CurrentSelectedPerk = SelectionParent.SelectedPerk;
    CurrentVetLevel = CurrentSelectedPerk.GetLevel();
    CurrentPerkLevel = CurrentVetLevel;
    
    S = CurrentSelectedPerk.GetCustomLevelInfo(CurrentVetLevel);
    
    if( CurrentVetLevel < CurrentSelectedPerk.MaximumLevel )
    {
        S = S $ "|| --- Next Level Effects --- ||" $ CurrentSelectedPerk.GetCustomLevelInfo(CurrentVetLevel+1);
    }
        
    EffectList.SetText(S);
}

defaultproperties
{
    Begin Object Class=KFGUI_TextScroll Name=EffectList
        ID="Info"
        ScrollSpeed=0.025
    End Object
    
    Components.Add(EffectList)
}