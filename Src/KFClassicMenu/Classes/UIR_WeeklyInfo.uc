Class UIR_WeeklyInfo extends KFGUI_Frame;

var KFGUI_TextField WeeklyDescription;
var KFGUI_Image WeeklyImage;

var KFWeeklyOutbreakInformation WeeklyInfo;

function InitMenu()
{
    Super.InitMenu();
    
    WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetCurrentWeeklyOutbreakInfo();
    FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
    
    WindowTitle = WeeklyInfo.FriendlyName;
    
    WeeklyDescription = KFGUI_TextField(FindComponentID('WeeklyDescription'));
	if(WeeklyInfo.DescriptionStrings.Length > 0)
        WeeklyDescription.SetText(WeeklyInfo.DescriptionStrings[0]$"|"$WeeklyInfo.DescriptionStrings[1]);
    
    WeeklyImage = KFGUI_Image(FindComponentID('WeeklyImage'));
    WeeklyImage.Image = Texture2D(DynamicLoadObject(WeeklyInfo.IconPath, class'Texture2D'));
}

defaultproperties
{
    bHeaderCenter=true
    bUseAnimation=true
    
    Begin Object Class=KFGUI_Image Name=WeeklyImage
        ID="WeeklyImage"
        YPosition=0.05
        XPosition=0.025
        bForceUniformSize=true
    End Object
    Components.Add(WeeklyImage)
    
    Begin Object Class=KFGUI_TextField Name=WeeklyDescription
        XSize=0.75
        YSize=0.85
        YPosition=0.25
        XPosition=0.375
        ID="WeeklyDescription"
    End Object
    Components.Add(WeeklyDescription)
}