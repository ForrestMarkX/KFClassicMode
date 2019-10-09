class UIR_SeasonalInfo extends UIR_DailyInfo;

var array<Texture2D> SeasonalIcons;
var KFGUI_List SeasonalList;
var class<KFGFxSpecialEventObjectivesContainer> CurrentSeasonal;
var KFGUI_Image SeasonalIcon;

function InitMenu()
{
    local int i;
    
    CurrentSeasonal = class'KFGFxMenu_StartGame'.static.GetSpecialEventClass(class'KFGameEngine'.static.GetSeasonalEventId());
    
    Super.InitMenu();
    
    SeasonalIcon = KFGUI_Image(FindComponentID('SeasonalIcon'));
    SeasonalIcon.Image = Texture2D(DynamicLoadObject(CurrentSeasonal.default.IconURL, class'Texture2D'));
    
    WindowTitle = CurrentSeasonal.default.CurrentSpecialEventString;
    DailyDescription.SetText(CurrentSeasonal.default.CurrentSpecialEventDescriptionString);
    
    SeasonalList = KFGUI_List(FindComponentID('SeasonalList'));
    SeasonalList.ListItemsPerPage = CurrentSeasonal.default.SpecialEventObjectiveInfoList.Length;
    SeasonalList.OnDrawItem = DrawSeasonalEntry;
    SeasonalList.ChangeListSize(CurrentSeasonal.default.SpecialEventObjectiveInfoList.Length);
    
    for( i=0; i<CurrentSeasonal.default.ObjectiveIconURLs.Length; i++ )
    {
        SeasonalIcons.AddItem(Texture2D(DynamicLoadObject(CurrentSeasonal.default.ObjectiveIconURLs[i], class'Texture2D')));
    }
}

function DrawSeasonalEntry( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local bool bIsCompleted, bIsProgress;
    local string Title, Description, ProgressString;
    local Texture2D Icon;
    local float IconH, XS, YS, TextX, TextY, FontScalar, DescScaler, ProgressMult, ProgressX, ProgressY, ProgressW, ProgressH, RewardX, RewardY, RewardW, RewardH, BorderSize;
    local int Progress, MaxProgress;
    
    YOffset *= 1.05;
    BorderSize = Height*0.05;
    
    Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, 0.f, YOffset, Width, BorderSize, MakeColor(35, 35, 35, 255));
    
    YOffset += BorderSize;
    Height -= BorderSize;
    
    bIsCompleted = PC.IsEventObjectiveComplete(Index);
    bIsProgress = CurrentSeasonal.default.UsesProgressList[Index];
    
    Title = CurrentSeasonal.default.SpecialEventObjectiveInfoList[Index].TitleString;
    Description = CurrentSeasonal.default.SpecialEventObjectiveInfoList[Index].DescriptionString;
    Icon = SeasonalIcons[Index];
    
    IconH = Height;
    
    Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, 0.f, YOffset, Owner.HUDOwner.ScaledBorderSize*2, IconH, Owner.HUDOwner.DefaultHudOutlineColor, true, false, true, false);
    Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, IconH+(Owner.HUDOwner.ScaledBorderSize*2), YOffset, Owner.HUDOwner.ScaledBorderSize*2, IconH, Owner.HUDOwner.DefaultHudOutlineColor, false, true, false, true);
    
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(Owner.HUDOwner.ScaledBorderSize*2, YOffset);
    C.DrawRect(IconH, IconH, Icon);
    
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
    DescScaler = FontScalar * 0.85;
    
    C.TextSize(Description, XS, YS, DescScaler, DescScaler);
    
    TextX = IconH+(Owner.HUDOwner.ScaledBorderSize*6);
    TextY = YOffset + (Height/2) - (YS/2.5);
    
    C.SetPos(TextX, TextY);
    C.DrawText(Description,, DescScaler, DescScaler);
    
    TextY = YOffset + (Height/2) - (YS/0.75);
    
    C.SetPos(TextX, TextY);
    C.DrawText(Title,, FontScalar, FontScalar);
    
    if( bIsProgress )
    {
        CurrentSeasonal.static.GetObjectiveProgressValues(Index, Progress, MaxProgress, ProgressMult);
        ProgressString = string(Progress);
        
        C.TextSize(ProgressString, XS, YS, FontScalar, FontScalar);
        
        ProgressW = Width * 0.25f;
        ProgressH = YS * 1.05f;
        
        ProgressX = Width - ProgressW - (Owner.HUDOwner.ScaledBorderSize*2);
        ProgressY = YOffset + Owner.HUDOwner.ScaledBorderSize;
        
        Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, ProgressX-(Owner.HUDOwner.ScaledBorderSize*2), ProgressY, Owner.HUDOwner.ScaledBorderSize*2, ProgressH, MakeColor(195, 195, 195, 255), true, false, true, false);
        Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, ProgressX+ProgressW, ProgressY, Owner.HUDOwner.ScaledBorderSize*2, ProgressH, MakeColor(195, 195, 195, 255), false, true, false, true);
        
        C.DrawColor = Owner.HUDOwner.DefaultHudOutlineColor;
        C.SetPos(ProgressX, ProgressY);
        Owner.CurrentStyle.DrawWhiteBox(ProgressW*ProgressMult, ProgressH);
        
        C.SetDrawColor(255, 255, 255, 255);
        C.SetPos(ProgressX + (ProgressW/2) - (XS/2), ProgressY + (ProgressH/2) - (YS/2));
        C.DrawText(ProgressString,, FontScalar, FontScalar);
    }
    
    FontScalar *= 0.95;
    
    C.TextSize(PC.GetSpecialEventRewardValue(), XS, YS, FontScalar, FontScalar);
    
    RewardW = Width * 0.275f;
    RewardH = YS * 1.05f;
    
    RewardX = Width - RewardW;
    RewardY = YOffset + Height - RewardH;
    
    Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, RewardX+RewardH-(Owner.HUDOwner.ScaledBorderSize*4), RewardY, RewardW-RewardH+(Owner.HUDOwner.ScaledBorderSize*4), RewardH, MakeColor(15, 15, 15, 255));
    Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, RewardX, RewardY, RewardH, RewardH, MakeColor(50, 50, 50, 255));
    
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(RewardX + (RewardH/2) - ((RewardH*0.75f)/2), RewardY + (RewardH/2) - ((RewardH*0.75f)/2));
    C.DrawRect(RewardH*0.75f, RewardH*0.75f, Texture2D'UI_HUD.InGameHUD_SWF_I117');
    
    C.SetDrawColor(34, 177, 76, 255);
    C.SetPos(RewardX+RewardH+(Owner.HUDOwner.ScaledBorderSize*4), RewardY + (RewardH/2) - (YS/2));
    C.DrawText(Reward,, FontScalar, FontScalar);
    
    C.TextSize(RewardString, XS, YS, FontScalar, FontScalar);
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(RewardX-XS-(Owner.HUDOwner.ScaledBorderSize*2), RewardY + (RewardH/2) - (YS/2));
    C.DrawText(RewardString,, FontScalar, FontScalar);
	
    if( bIsCompleted )
    {
        FontScalar *= 0.825;
        
        Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, -Owner.HUDOwner.ScaledBorderSize, YOffset, Width+Owner.HUDOwner.ScaledBorderSize, Height, MakeColor(8, 8, 8, 190));
		
		C.TextSize(CompletedString, XS, YS, FontScalar, FontScalar);
        TextY = YOffset + (Height/2) - (YS/2);
        TextX = (Owner.HUDOwner.ScaledBorderSize*2) + (IconH/2) - (XS/2);
        
        C.SetDrawColor(0, 255, 0, 255);
        C.SetPos(TextX, TextY);
        C.DrawText(CompletedString,, FontScalar, FontScalar);
    }
}

defaultproperties
{
    XSize=0.4
    XPosition=0.3
    
    YSize=0.675
    YPosition=0.125
    
    Begin Object Class=KFGUI_Image Name=SeasonalIcon
        XSize=0.98
        YSize=0.175
        XPosition=0.01
        YPosition=0.05
        bAlignCenter=true
        ID="SeasonalIcon"
    End Object
    Components.Add(SeasonalIcon)
    
    Begin Object Name=DailyList
        YSize=0.5
        YPosition=0.25
        ID="SeasonalList"
    End Object
}