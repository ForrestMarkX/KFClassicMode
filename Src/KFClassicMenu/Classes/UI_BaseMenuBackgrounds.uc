Class UI_BaseMenuBackgrounds extends KFGUI_Page
    DependsOn(UI_MidGameMenu);

var MenuPlayerController PC;
var KFGUI_Frame MenuBar, PageBar;

var() array<FPageInfo> Pages;
var KFGUI_SwitchMenuBar PageSwitcher;

var transient int NumButtons;

function InitMenu()
{
    local KFGUI_Button B;
    local KFGUI_Base PageItem;
    local int i;
    
    Super.InitMenu();
    
    PC = MenuPlayerController(GetPlayer());
    
    PageSwitcher = KFGUI_SwitchMenuBar(FindComponentID('Pager'));
    
    MenuBar = KFGUI_Frame(FindComponentID('MenuBar'));
    MenuBar.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
    
    PageBar = KFGUI_Frame(FindComponentID('PageBar'));
    PageBar.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
    
    for( i=0; i<Pages.Length; ++i )
    {
        PageItem = PageSwitcher.AddPage(Pages[i].PageClass,Pages[i].Caption,Pages[i].Hint,B);
        SetupPageItem(PageItem);
    }
}

function SetupPageItem(KFGUI_Base P)
{
    P.InitMenu();
}

final function KFGUI_Button AddMenuButton( name ButtonID, string Text, optional string ToolTipStr )
{
    local KFGUI_Button B;
    
    B = new (Self) class'KFGUI_Button';
    B.ButtonText = Text;
    B.ToolTip = ToolTipStr;
    B.OnClickLeft = ButtonClicked;
    B.OnClickRight = ButtonClicked;
    B.ID = ButtonID;
    B.XPosition = 0.895-(NumButtons*0.1);
    B.XSize = 0.099;
    B.YPosition = 0.15;
    B.YSize = 0.75;
    
    ++NumButtons;
    
    MenuBar.AddComponent(B);
    return B;
}

function DrawMenu()
{
    Canvas.SetPos(0.f, 0.f);
    Canvas.SetDrawColor(0, 0, 0, 255);
    Owner.CurrentStyle.DrawWhiteBox(CompPos[2], CompPos[3]);
}

function UserPressedEsc()
{
    PC.OpenLobbyMenu();
    Super.UserPressedEsc();
}

function ButtonClicked( KFGUI_Button Sender );

defaultproperties
{
    bNoBackground=true
    
    Begin Object class=KFGUI_Image Name=BackgroundImage
        ID="BackgroundImage"
        YPosition=0
        XPosition=0
        XSize=1
        YSize=1
        bAlignCenter=true
        Image=Texture2D'KFClassicMenu_Assets.menuBackground'
    End Object
    Components.Add(BackgroundImage)
    
    Begin Object Class=KFGUI_Frame Name=PageBar
        ID="PageBar"
        bDrawHeader=true
        XPosition=0
        YPosition=0
        XSize=1
        YSize=0.04
        EdgeSize(0)=0.f
        EdgeSize(1)=0.f
        EdgeSize(2)=0.f
        EdgeSize(3)=0.f
    End Object
    Components.Add(PageBar)

    Begin Object Class=KFGUI_Frame Name=MenuBar
        ID="MenuBar"
        bDrawHeader=true
        XPosition=0
        YPosition=0.96
        XSize=1
        YSize=0.04
        EdgeSize(0)=0.f
        EdgeSize(1)=0.f
        EdgeSize(2)=0.f
        EdgeSize(3)=0.f
    End Object
    Components.Add(MenuBar)
    
    Begin Object Class=KFGUI_SwitchMenuBar Name=MultiPager
        ID="Pager"
        YPosition=0.0075
        YSize=0.95
        BorderWidth=0.03
        ButtonAxisSize=0.1
        PagePadding=1.25
    End Object
    Components.Add(MultiPager)
}