Class UIR_GameTypesList extends KFGUI_Frame;

var array<string> Options;
var KFGUI_List GamesList;
var int SelectedIndex;
var UIP_GameInfo InfoMenu;

function InitMenu()
{
    Super.InitMenu();
    
    FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
    GamesList = KFGUI_List(FindComponentID('GamesList'));
    GamesList.OnDrawItem = DrawOptions;
    GamesList.OnClickedItem = SelectItem;
    GamesList.ScrollBar.YSize = 1.f;
    
    AddListItems();
    GamesList.ChangeListSize(Options.Length);
}

function AddListItems()
{
    Options = class'KFCommon_LocalizedStrings'.static.GetGameModeStringsArray();
    Options.AddItem(class'KFCommon_LocalizedStrings'.default.CustomString);
}

function SelectItem(int Index, bool bRight, int MouseX, int MouseY)
{
    if( Index == INDEX_NONE )
        Index = 0;
        
    PlayMenuSound(MN_ClickButton);
    SelectedIndex = Index;
    ChangeSavedOption();
    InfoMenu.SaveConfig();
}

function ChangeSavedOption()
{
    InfoMenu.SelectedMode = SelectedIndex;
}

function DrawOptions( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local float FontScalar, XL, YL;
    local string S;
    
    if( SelectedIndex == Index )
        bFocus = true;
        
    Owner.CurrentStyle.DrawRoundedBoxOutlined(1, 0.f, YOffset, Width, Height, bFocus ? MakeColor(0, 0, 0, 195) : MakeColor(15, 15, 15, 195), bFocus ? MakeColor(90, 0, 0, 195) : MakeColor(195, 0, 0, 195));
    
    S = Options[Index];
    
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
    FontScalar *= 1.125f;
    
    C.TextSize(S, XL, YL, FontScalar, FontScalar);
    C.SetPos((Width/2) - (XL/2), YOffset + (Height/2) - (YL/2));
    
    if( bFocus )
        C.SetDrawColor(255, 0, 0, 255);
    else C.SetDrawColor(255, 255, 255, 255);
    
    C.DrawText(S,,FontScalar,FontScalar);
}

function string TranslateOptionsIntoURL()
{
    return class'KFGameInfo'.static.GetGameModeClassFromNum(SelectedIndex);
}

defaultproperties
{
    SelectedIndex=-1
    bUseAnimation=true
    
    EdgeSize(0)=10
    EdgeSize(2)=0
    
    Begin Object Class=KFGUI_List Name=GamesList
        ID="GamesList"
        ListItemsPerPage=16
        bClickable=true
    End Object
    Components.Add(GamesList)
}