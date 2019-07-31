Class UIR_DifficultyList extends UIR_GameTypesList;

function InitMenu()
{
    Super.InitMenu();
    GamesList.ListItemsPerPage = 8;
}

function AddListItems()
{
    Options = class'KFCommon_LocalizedStrings'.static.GetDifficultyStringsArray();
}

function ChangeSavedOption()
{
    InfoMenu.SelectedDif = SelectedIndex;
}

function string TranslateOptionsIntoURL()
{
    return string(class'KFGameDifficultyInfo'.static.GetDifficultyValue(SelectedIndex));
}

defaultproperties
{
}