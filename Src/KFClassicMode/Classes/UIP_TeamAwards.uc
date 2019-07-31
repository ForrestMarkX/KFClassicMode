Class UIP_TeamAwards extends KFGUI_MultiComponent;

var KFGUI_List AwardsList,BestWeaponsList;
var array<Texture2D> AwardIcons;
var array<Texture2D> WeaponIcons;
var array<AARAward> CurrentAwards;
var array<WeaponDamage> TopWeaponList;
var EphemeralMatchStats StatCollector;
var int BorderSize;
var KFPlayerReplicationInfo KFPRI;

function InitMenu()
{
    Super.InitMenu();
    
    AwardsList = KFGUI_List(FindComponentID('AwardList'));
    AwardsList.OnDrawItem = DrawAwardEntry;    
    
    BestWeaponsList = KFGUI_List(FindComponentID('BestWeaponsList'));
    BestWeaponsList.OnDrawItem = DrawWeaponEntry;
    
    StatCollector = KFPlayerController(GetPlayer()).MatchStats;
    
    BorderSize = Owner.CurrentStyle.ScreenScale(3);
    KFPRI = KFPlayerReplicationInfo(GetPlayer().PlayerReplicationInfo);
}

function ShowMenu()
{
    local int i;
    
    Super.ShowMenu();
    
    if( StatCollector != None )
    {
        TopWeaponList.Length = 0;
        CurrentAwards.Length = 0;
        
        StatCollector.GetTopWeapons(12, TopWeaponList);
        BestWeaponsList.ChangeListSize(TopWeaponList.Length);
        
        for( i=0; i<TopWeaponList.Length; i++ )
        {
            WeaponIcons.AddItem(Texture2D(DynamicLoadObject(TopWeaponList[i].WeaponDef.static.GetImagePath(), class'Texture2D')));
        }

        for( i=0; i<StatCollector.TeamAwardList.Length; i++ )
        {
            if( StatCollector.TeamAwardList[i].PRI != None && StatCollector.TeamAwardList[i].DisplayValue > 0  )
            {
                CurrentAwards.AddItem(StatCollector.TeamAwardList[i]);
                AwardIcons.AddItem(Texture2D(DynamicLoadObject(string(StatCollector.TeamAwardList[i].IconPath), class'Texture2D')));
            }
        }
        
        AwardsList.ChangeListSize(CurrentAwards.Length);
    }
}

function DrawMenu()
{
    local float BoxH,OriginalFontScalar,FontScalar,TextXOffset,TextYOffset,StatsXPos,StatsYPos,XL,YL,StatsX,StatsY,StatsSpaceXL,StatsSpaceYL,RowTopYPos,ValueXPos;
    local string S;
    
    Super.DrawMenu();
    
    BoxH = CompPos[3] * 0.15;
    Owner.CurrentStyle.DrawRoundedBoxOutlined(BorderSize, 0, 0, CompPos[2], BoxH, class'KFHUDInterface'.default.DefaultHudMainColor, MakeColor(185, 185, 185, 195));
    
    Canvas.Font = Owner.CurrentStyle.PickFont(OriginalFontScalar);
    FontScalar = OriginalFontScalar + 0.125;
    
    Canvas.TextSize("A", StatsSpaceXL, StatsSpaceYL, FontScalar, FontScalar);
    
    S = class'KFGFxMenu_PostGameReport'.default.PlayerStatsString;
    Canvas.TextSize(S, StatsX, StatsY, FontScalar, FontScalar);
    
    StatsXPos = (CompPos[2] / 2) - (StatsX / 2);
    StatsYPos = BorderSize;
    
    Canvas.SetDrawColor(255,255,255,255);
    Canvas.SetPos(StatsXPos, StatsYPos);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    FontScalar = OriginalFontScalar;
    S = class'KFGFxPostGameContainer_PlayerStats'.default.TotalDoshEarnedString;
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    
    TextYOffset = StatsYPos + StatsY;
    TextXOffset = BorderSize * 2;
    
    RowTopYPos = TextYOffset;
    
    Canvas.SetDrawColor(255,255,255,255);
    Canvas.SetPos(TextXOffset, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    S = class'KFScoreBoard'.static.GetNiceSize(Max(StatCollector.TotalDoshEarned, 0));
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    S @= " " $ class'KFGFxPostGameContainer_PlayerStats'.default.TotalKillsString;
    
    ValueXPos = StatsXPos + (StatsX / 2) - XL;
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    TextYOffset += YL;
    
    S = class'KFGFxPostGameContainer_PlayerStats'.default.LargeZedKillsString;
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    
    Canvas.SetDrawColor(255,255,255,255);
    Canvas.SetPos(TextXOffset, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    S = string(StatCollector.TotalLargeZedKills);
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    S @= " " $ class'KFGFxPostGameContainer_PlayerStats'.default.AssistsString;
    
    ValueXPos = StatsXPos + (StatsX / 2) - XL;
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    TextYOffset += YL;
    
    S = class'KFGFxPostGameContainer_PlayerStats'.default.HeadShotsString;
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    
    Canvas.SetDrawColor(255,255,255,255);
    Canvas.SetPos(TextXOffset, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    S = string(StatCollector.TotalHeadShots);
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    S @= " " $ class'KFGFxPostGameContainer_PlayerStats'.default.TotalDamageDealtString;
    
    ValueXPos = StatsXPos + (StatsX / 2) - XL;
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    TextYOffset = RowTopYPos;
    
    S = string(KFPRI.Kills);
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    
    ValueXPos = CompPos[2] - XL - (BorderSize * 2);
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    TextYOffset += YL;
    
    S = string(KFPRI.Assists);
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    
    ValueXPos = CompPos[2] - XL - (BorderSize * 2);
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
    
    TextYOffset += YL;
    
    S = class'KFScoreBoard'.static.GetNiceSize(StatCollector.TotalDamageDealt);
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    
    ValueXPos = CompPos[2] - XL - (BorderSize * 2);
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, FontScalar, FontScalar);
}

function DrawAwardEntry( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local AARAward AwardEntry;
    local float FontScalar,OriginalFontScalar,BoxW,BoxH,InfoW,InfoH,XL,YL,TextXOffset,TextYOffset,AvatarXPos,AvatarYPos,AvatarH,AvatarW;
    local Color BorderColor;
    local string S;
    local PlayerReplicationInfo PRI;
    
    YOffset *= 1.05;
    AwardEntry = CurrentAwards[Index];
    PRI = AwardEntry.PRI;
    
    BorderColor = MakeColor(179, 132, 24, 255);
    
    BoxW = Width * 0.25;
    BoxH = Height;
    
    Owner.CurrentStyle.DrawRoundedBoxOutlined(BorderSize, 0, YOffset, BoxW, BoxH, class'KFHUDInterface'.default.DefaultHudMainColor, BorderColor);
    
    C.SetDrawColor(255,255,255,255);
    C.SetPos((BoxW/2) - ((Height - (BorderSize*4))/2), YOffset + (BorderSize*2));
    C.DrawTile(AwardIcons[Index], Height - (BorderSize*4), Height - (BorderSize*4), 0, 0, AwardIcons[Index].SizeX, AwardIcons[Index].SizeY);
    
    InfoH = Height * 0.85;
    InfoW = Width - BoxW;
    
    Owner.CurrentStyle.DrawRoundedBoxOutlinedEx(BorderSize, BoxW-BorderSize, YOffset + (Height/2) - (InfoH/2), InfoW, InfoH, class'KFHUDInterface'.default.DefaultHudMainColor, BorderColor, false, true, false, true);
    
    C.Font = Owner.CurrentStyle.PickFont(OriginalFontScalar);
    FontScalar = OriginalFontScalar + 0.15;
    
    C.TextSize("ABC", XL, YL, FontScalar, FontScalar);
    
    TextXOffset = BoxW + (XL/2) - BorderSize;
    TextYOffset = YOffset + (Height * 0.25) - (YL / 2) + (BorderSize * 2);
    
    C.SetDrawColor(255,215,0,255);
    C.SetPos(TextXOffset, TextYOffset);
    C.DrawText(Localize("EphemeralMatchStats", AwardEntry.TitleIdentifier, "KFGame"),, FontScalar, FontScalar);
    
    TextYOffset += YL - BorderSize;
    
    C.TextSize("ABC", XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    C.SetDrawColor(255,255,255,255);
    C.SetPos(TextXOffset, TextYOffset);
    if( Len(PRI.PlayerName) > 25 )
        S = Left(PRI.PlayerName, 25);
    else S = PRI.PlayerName;
    C.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    TextYOffset += YL - BorderSize;
    
    S = class'KFScoreBoard'.static.GetNiceSize(AwardEntry.DisplayValue);
    
    C.SetDrawColor(255,255,255,255);
    C.SetPos(TextXOffset, TextYOffset);
    C.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    C.TextSize(S @ "", XL, YL, OriginalFontScalar, OriginalFontScalar);
    TextXOffset += XL;
    
    C.SetDrawColor(255,255,255,255);
    C.SetPos(TextXOffset, TextYOffset);
    C.DrawText(Localize("EphemeralMatchStats", AwardEntry.ValueIdentifier, "KFGame"),, OriginalFontScalar, OriginalFontScalar);
    
    if( PRI.Avatar != None )
    {
        if( PRI.Avatar == class'KFScoreBoard'.default.DefaultAvatar )
            class'KFScoreBoard'.static.CheckAvatar(KFPlayerReplicationInfo(PRI), KFPlayerController(GetPlayer()));
            
        AvatarW = (InfoH - (BorderSize * 2)) * 0.5;
        AvatarH = AvatarW;
        
        AvatarXPos = InfoW + (BoxW / 2) - (AvatarW / 2);
        AvatarYPos = YOffset + (Height / 2) - (AvatarH / 2);
    
        C.SetDrawColor(255,255,255,255);
        C.SetPos(AvatarXPos, AvatarYPos);
        C.DrawRect(AvatarW, AvatarH, PRI.Avatar);
        
        C.DrawColor = BorderColor;
        Owner.CurrentStyle.DrawBoxHollow(AvatarXPos, AvatarYPos, AvatarW, AvatarH, 1);
    } 
    else
    {
        if( !PRI.bBot )
            class'KFScoreBoard'.static.CheckAvatar(KFPlayerReplicationInfo(PRI), KFPlayerController(GetPlayer()));
    }
}

function DrawWeaponEntry( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local WeaponDamage WepEntry;
    local Texture2D WeaponIcon;
    local float RatioDiff, RatioH, RatioW, IconH, IconBoxW, MainBoxH, TextXOffset, TextYOffset, ValueXPos, OriginalFontScalar, FontScalar, XL, YL;
    local class<KFWeaponDefinition> WepDef;
    local Color MainColor;
    local string S;
    local bool bKnife;
    
    YOffset *= 1.05;
    WepEntry = TopWeaponList[Index];
    
    MainColor = MakeColor(179, 132, 24, 255);
    IconBoxW = Width * 0.275;
    MainBoxH = Height * 0.875;
    
    Owner.CurrentStyle.DrawRoundedBoxOutlinedEx(BorderSize, IconBoxW-BorderSize, YOffset + (Height / 2) - (MainBoxH / 2), Width-IconBoxW, MainBoxH, class'KFHUDInterface'.default.DefaultHudMainColor, MainColor, false, true, false, true);
    Owner.CurrentStyle.DrawRoundedBoxOutlined(BorderSize, 0, YOffset, IconBoxW, Height, class'KFHUDInterface'.default.DefaultHudMainColor, MainColor);
    
    WeaponIcon = WeaponIcons[Index];
    if( WeaponIcon != None )
    {
        IconH = Height * 0.75;
        
        RatioH = WeaponIcon.GetSurfaceHeight() / IconH;
        RatioW = WeaponIcon.GetSurfaceWidth() / RatioH;
        
        if( RatioW > IconBoxW )
        {
            RatioDiff = IconBoxW/RatioW;
            
            RatioW *= RatioDiff;
            IconH *= RatioDiff;
        }
        
        IconH -= BorderSize * 2;
        RatioW -= BorderSize * 2;
        
        C.SetDrawColor(255,255,255,255);
        C.SetPos((IconBoxW / 2) - (RatioW / 2), YOffset + (Height / 2) - (IconH / 2));
        C.DrawRect(RatioW, IconH, WeaponIcon);
    }
    
    WepDef = WepEntry.WeaponDef;
    bKnife = WepDef == class'KFweapDef_Knife_Base';
    
    C.Font = Owner.CurrentStyle.PickFont(OriginalFontScalar);
    FontScalar = OriginalFontScalar + 0.2;
    
    S = bKnife ? class'KFGFxPostGameContainer_PlayerStats'.default.KnifeString : WepDef.static.GetItemName();
    C.TextSize(S, XL, YL, FontScalar, FontScalar);
    
    TextXOffset = IconBoxW + (BorderSize * 4);
    TextYOffset = YOffset + (MainBoxH * 0.25) - (YL / 2);
    
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(TextXOffset, TextYOffset);
    C.DrawText(S,, FontScalar, FontScalar);
    
    TextYOffset += YL;
    
    S = class'KFGFxPostGameContainer_PlayerStats'.default.DamageDealtString;
    C.TextSize(S, XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(TextXOffset, TextYOffset);
    C.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    S = class'KFScoreBoard'.static.GetNiceSize(WepEntry.DamageAmount);
    Canvas.TextSize(S, XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    ValueXPos = Width - XL - (BorderSize * 4);
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    TextYOffset += YL;
    
    S = class'KFGFxPostGameContainer_PlayerStats'.default.HeadShotsString;
    C.TextSize(S, XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(TextXOffset, TextYOffset);
    C.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    S = string(WepEntry.HeadShots);
    Canvas.TextSize(S, XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    ValueXPos = Width - XL - (BorderSize * 4);
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    TextYOffset += YL;
    
    S = class'KFGFxPostGameContainer_PlayerStats'.default.LargeZedKillsString;
    C.TextSize(S, XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(TextXOffset, TextYOffset);
    C.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
    
    S = string(WepEntry.LargeZedKills);
    Canvas.TextSize(S, XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    ValueXPos = Width - XL - (BorderSize * 4);
    
    Canvas.SetPos(ValueXPos, TextYOffset);
    Canvas.DrawText(S,, OriginalFontScalar, OriginalFontScalar);
}

defaultproperties
{
    Begin Object Class=KFGUI_List Name=AwardsList
        ID="AwardList"
        XPosition=0.015
        YPosition=0.155
        XSize=0.45
        YSize=0.755
        ListItemsPerPage=5
    End Object
    Components.Add(AwardsList)
    
    Begin Object Class=KFGUI_List Name=BestWeaponsList
        ID="BestWeaponsList"
        XPosition=0.475
        YPosition=0.155
        XSize=0.515
        YSize=0.755
        ListItemsPerPage=4
    End Object
    Components.Add(BestWeaponsList)
}