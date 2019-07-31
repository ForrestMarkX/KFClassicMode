Class UIR_MapsList extends UIR_GameTypesList;

function AddListItems()
{
    class'KFGFxMenu_StartGame'.static.GetMapList(Options);
}

function SelectItem(int Index, bool bRight, int MouseX, int MouseY)
{
    Super.SelectItem(Index, bRight, MouseX, MouseY);
    
    if( MenuInterface(Owner.HUDOwner) != None )
        UIP_GameInfo(ParentComponent).MapImage.Image = MenuInterface(Owner.HUDOwner).GetMapImage(Options[SelectedIndex]);
}

function ChangeSavedOption()
{
    InfoMenu.SelectedMap = Options[SelectedIndex];
}

function string TranslateOptionsIntoURL()
{
    if( SelectedIndex == -1 )
        return "KF-BioticsLab";
    return Options[SelectedIndex];
}

defaultproperties
{
}