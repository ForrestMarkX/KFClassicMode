class UIR_ConsoleAutoCompleteList extends KFGUI_RightClickMenu;

var KFGUI_Base BaseMenu;

function OpenMenu( KFGUI_Base Menu )
{
    Owner = Menu.Owner;
    BaseMenu = Menu;
    InitMenu();
    GetInputFocus();
    OldSizeX = 0;
}

function ComputePosition()
{
    XPosition = BaseMenu.XPosition;
    YPosition = BaseMenu.YPosition+BaseMenu.YSize;
}