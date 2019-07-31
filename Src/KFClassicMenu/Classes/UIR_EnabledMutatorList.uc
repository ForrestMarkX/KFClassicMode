Class UIR_EnabledMutatorList extends UIR_MutatorList;

var UIR_MutatorList MainMutatorsFrame;

function DoubleClickedItem(int Index, bool bRight, int MouseX, int MouseY)
{
    local int i;
    
    for(i=0; i<GamePage.SavedMutators.Length; i++)
    {
        if( Mutators[Index].Summary.ClassName ~= GamePage.SavedMutators[i] )
        {
            GamePage.SavedMutators.Remove(i, 1);
            GamePage.SaveConfig();
        }
    }
    
    SelectedIndex = -1;
    PlayMenuSound(MN_DropdownChange);
    MainMutatorsFrame.AddMutator(Mutators[Index].Summary);
    RemoveMutator(Mutators[Index].Summary);
}

function FindMutators();

defaultproperties
{
}