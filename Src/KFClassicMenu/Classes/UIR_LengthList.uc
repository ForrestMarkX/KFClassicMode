Class UIR_LengthList extends UIR_GameTypesList;

function InitMenu()
{
    Super.InitMenu();
    GamesList.ListItemsPerPage = 8;
}

function AddListItems()
{
    Options = class'KFCommon_LocalizedStrings'.static.GetLengthStringsArray();
}

function ChangeSavedOption()
{
    InfoMenu.SelectedLength = SelectedIndex;
}

function string TranslateOptionsIntoURL()
{
    return string(SelectedIndex);
}

defaultproperties
{
}