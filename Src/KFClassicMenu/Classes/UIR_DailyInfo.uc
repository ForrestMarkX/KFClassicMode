class UIR_DailyInfo extends KFGUI_FloatingWindow;

var KFGUI_TextField DailyDescription;
var KFGUI_List DailyList;

var KFPlayerController PC;
var array<Texture2D> DailyIcons;

var int Reward;
var string CompletedString, RewardString;

function InitMenu()
{
    local int i;
    
    Super.InitMenu();
    
    PC = KFPlayerController(GetPlayer());
    WindowTitle = class'KFGFxDailyObjectivesContainer'.default.TitleString;
    
    DailyDescription = KFGUI_TextField(FindComponentID('DailyDescription'));
    DailyDescription.SetText(class'KFGFxDailyObjectivesContainer'.default.OverviewString);
    
    DailyList = KFGUI_List(FindComponentID('DailyList'));
    DailyList.OnDrawItem = DrawDailyEntry;
    DailyList.ChangeListSize(class'KFGFxDailyObjectivesContainer'.default.NUM_OF_DAILIES);
    
    for( i=0; i<class'KFGFxDailyObjectivesContainer'.default.NUM_OF_DAILIES; i++ )
    {
        DailyIcons.AddItem(Texture2D(DynamicLoadObject(Mid(class'KFGFxDailyObjectivesContainer'.static.GetIconForObjective(PC.GetDailyObjective(i)), Len("img://")), class'Texture2D')));
    }
	
	CompletedString = Localize("BanImporter", "msgStatusDone", "WebAdmin");
    Reward = class'KFOnlineStatsWrite'.static.GetDailyEventReward();
    RewardString = class'KFMission_LocalizedStrings'.default.RewardString;
}

function DrawDailyEntry( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local DailyEventInformation EventInfo;
    local bool bIsCompleted, bIsProgress;
    local string Title, Description, Progress;
    local Texture2D Icon;
    local float IconH, XS, YS, TextX, TextY, FontScalar, ProgressMult, ProgressX, ProgressY, ProgressW, ProgressH, RewardX, RewardY, RewardW, RewardH, BorderSize;
    
    YOffset *= 1.05;
    BorderSize = Height*0.05;
    
    Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, 0.f, YOffset, Width, BorderSize, MakeColor(35, 35, 35, 255));
    
    YOffset += BorderSize;
    Height -= BorderSize;
    
    EventInfo = PC.GetDailyObjective(Index);
    bIsCompleted = PC.IsDailyObjectiveComplete(Index);
    bIsProgress = class'KFGFxDailyObjectivesContainer'.static.IsProgressObjective(EventInfo);
    
    Title = class'KFGFxDailyObjectivesContainer'.static.FormTitleForObjective(EventInfo);
    Description = class'KFGFxDailyObjectivesContainer'.static.FormDescriptionForObjective(EventInfo);
    Icon = DailyIcons[Index];
    
    IconH = Height;
    
    Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, 0.f, YOffset, Owner.HUDOwner.ScaledBorderSize*2, IconH, Owner.HUDOwner.DefaultHudOutlineColor, true, false, true, false);
    Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, IconH+(Owner.HUDOwner.ScaledBorderSize*2), YOffset, Owner.HUDOwner.ScaledBorderSize*2, IconH, Owner.HUDOwner.DefaultHudOutlineColor, false, true, false, true);
    
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(Owner.HUDOwner.ScaledBorderSize*2, YOffset);
    C.DrawRect(IconH, IconH, Icon);
    
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
    C.TextSize(Description, XS, YS, FontScalar, FontScalar);
    
    TextX = IconH+(Owner.HUDOwner.ScaledBorderSize*6);
    TextY = YOffset + (Height/2) - (YS/2.5);
    
    C.SetPos(TextX, TextY);
    C.DrawText(Description,, FontScalar, FontScalar);
    
    TextY = YOffset + (Height/2) - (YS/0.75);
    
    C.SetPos(TextX, TextY);
    C.DrawText(Title,, FontScalar, FontScalar);
    
    if( bIsProgress )
    {
        Progress = PC.GetCurrentDailyValue(Index)$"/"$PC.GetMaxDailyValue(Index);
        ProgressMult = FClamp(Float(PC.GetCurrentDailyValue(Index)) / Float(PC.GetMaxDailyValue(Index)), 0, 1);
        C.TextSize(Progress, XS, YS, FontScalar, FontScalar);
        
        ProgressW = Width * 0.25f;
        ProgressH = YS * 1.125f;
        
        ProgressX = Width - ProgressW - (Owner.HUDOwner.ScaledBorderSize*2);
        ProgressY = YOffset + (Owner.HUDOwner.ScaledBorderSize*2);
        
        Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, ProgressX-(Owner.HUDOwner.ScaledBorderSize*2), ProgressY, Owner.HUDOwner.ScaledBorderSize*2, ProgressH, MakeColor(195, 195, 195, 255), true, false, true, false);
        Owner.CurrentStyle.DrawRoundedBoxEx(Owner.HUDOwner.ScaledBorderSize*2, ProgressX+ProgressW, ProgressY, Owner.HUDOwner.ScaledBorderSize*2, ProgressH, MakeColor(195, 195, 195, 255), false, true, false, true);
        
        C.DrawColor = Owner.HUDOwner.DefaultHudOutlineColor;
        C.SetPos(ProgressX, ProgressY);
        Owner.CurrentStyle.DrawWhiteBox(ProgressW*ProgressMult, ProgressH);
        
        C.SetDrawColor(255, 255, 255, 255);
        C.SetPos(ProgressX + (ProgressW/2) - (XS/2), ProgressY + (ProgressH/2) - (YS/2));
        C.DrawText(Progress,, FontScalar, FontScalar);
    }
    
    C.TextSize(Reward, XS, YS, FontScalar, FontScalar);
    
    RewardW = Width * 0.275f;
    RewardH = YS * 1.25f;
    
    RewardX = Width - RewardW;
    RewardY = YOffset + Height - RewardH;
    
    Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, RewardX+RewardH-(Owner.HUDOwner.ScaledBorderSize*4), RewardY, RewardW-RewardH+(Owner.HUDOwner.ScaledBorderSize*4), RewardH, MakeColor(15, 15, 15, 255));
    Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, RewardX, RewardY, RewardH, RewardH, MakeColor(50, 50, 50, 255));
    
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(RewardX + (RewardH/2) - ((RewardH*0.75f)/2), RewardY + (RewardH/2) - ((RewardH*0.75f)/2));
    C.DrawRect(RewardH*0.75f, RewardH*0.75f, Texture2D'UI_HUD.InGameHUD_SWF_I123');
    
    C.SetDrawColor(34, 177, 76, 255);
    C.SetPos(RewardX+RewardH+(Owner.HUDOwner.ScaledBorderSize*4), RewardY + (RewardH/2) - (YS/2));
    C.DrawText(Reward,, FontScalar, FontScalar);
    
    C.TextSize(RewardString, XS, YS, FontScalar, FontScalar);
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(RewardX-XS-(Owner.HUDOwner.ScaledBorderSize*2), RewardY + (RewardH/2) - (YS/2));
    C.DrawText(RewardString,, FontScalar, FontScalar);
	
    if( bIsCompleted )
    {
        Owner.CurrentStyle.DrawRoundedBox(Owner.HUDOwner.ScaledBorderSize*2, -Owner.HUDOwner.ScaledBorderSize, YOffset, Width+Owner.HUDOwner.ScaledBorderSize, Height, MakeColor(8, 8, 8, 190));
		
		C.TextSize(CompletedString, XS, YS, FontScalar, FontScalar);
        TextY = YOffset + (Height - YS);
        
        C.SetDrawColor(0, 255, 0, 255);
        C.SetPos(TextX, TextY);
        C.DrawText(CompletedString,, FontScalar, FontScalar);
    }
}

function ButtonClicked( KFGUI_Button Sender )
{
    switch( Sender.ID )
    {
    case 'Close':
        DoClose();
        break;
    }
}

defaultproperties
{
    bAlwaysTop=true
    
    XSize=0.3
    YSize=0.5
    XPosition=0.35
    YPosition=0.25
    
    Begin Object Class=KFGUI_TextField Name=DailyDescription
        XSize=0.98
        YSize=0.25
        YPosition=0.1
        XPosition=0.01
        ID="DailyDescription"
    End Object
    Components.Add(DailyDescription)
    
    Begin Object Class=KFGUI_List Name=DailyList
        XSize=0.95
        YSize=0.5
        YPosition=0.35
        XPosition=0.025
        ID="DailyList"
        bClickable=false
        ListItemsPerPage=3
    End Object
    Components.Add(DailyList)
    
    Begin Object class=KFGUI_Button Name=Close
        ID="Close"
        YPosition=0.89
        XPosition=0.375
        XSize=0.25
        YSize=0.05
        FontScale=1.25
        ButtonText="Close"
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object
    Components.Add(Close)   
}