Class UIR_WeeklyInfo extends KFGUI_Frame;

var KFGUI_TextField WeeklyDescription;
var KFGUI_Image WeeklyImage;

var KFWeeklyOutbreakInformation WeeklyInfo;

function InitMenu()
{
    local int i, ItemIndex;
    local OnlineSubsystem OnlineSub;
    local ItemProperties RewardItem;
    
    Super.InitMenu();
    
    OnlineSub = Class'GameEngine'.static.GetOnlineSubsystem();
    
    WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetCurrentWeeklyOutbreakInfo();
    WeeklyInfo.RewardIDs = class'KFOnlineStatsWrite'.static.GetWeeklyOutbreakRewards();
    
    FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
    
    WindowTitle = WeeklyInfo.FriendlyName;
    
    WeeklyDescription = KFGUI_TextField(FindComponentID('WeeklyDescription'));
    if(WeeklyInfo.DescriptionStrings.Length > 0)
        WeeklyDescription.SetText(WeeklyInfo.DescriptionStrings[0]$"<LINEBREAK>"$WeeklyInfo.DescriptionStrings[1]);
    
	for( i=0; i<WeeklyInfo.RewardIDs.Length; i++)
	{
        ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition',WeeklyInfo.RewardIDs[i]);
        if( ItemIndex != INDEX_NONE )
        {
            RewardItem = OnlineSub.ItemPropertiesList[ItemIndex];
            WeeklyDescription.AddText("<LINEBREAK>"$class'KFMission_LocalizedStrings'.default.RewardString @ ":#{FFFF00}" @ RewardItem.Name);
            break;
        }
	}
    
    WeeklyImage = KFGUI_Image(FindComponentID('WeeklyImage'));
    WeeklyImage.Image = Texture2D(DynamicLoadObject(WeeklyInfo.IconPath, class'Texture2D'));
}

defaultproperties
{
    bHeaderCenter=true
    bUseAnimation=true
    
    Begin Object Class=KFGUI_Image Name=WeeklyImage
        ID="WeeklyImage"
        XSize=0.75
        YSize=0.75
        YPosition=0.125
        bForceUniformSize=true
    End Object
    Components.Add(WeeklyImage)
    
    Begin Object Class=KFGUI_TextField Name=WeeklyDescription
        YPosition=0.25
        XPosition=0.25
        FontScale=0.95
        LineSplitter="<LINEBREAK>"
        ID="WeeklyDescription"
    End Object
    Components.Add(WeeklyDescription)
}