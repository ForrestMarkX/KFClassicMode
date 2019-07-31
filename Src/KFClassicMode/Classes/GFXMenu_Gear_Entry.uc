class GFXMenu_Gear_Entry extends KFGFxMenu_Gear;

function OnOpen()
{
	local PlayerController PC;

	PC = GetPC();
	if( PC == none )
	{
		return;
	}

	CheckForCustomizationPawn( PC );

	if ( class'WorldInfo'.static.IsMenuLevel() )
	{
		Manager.ManagerObject.SetBool("backgroundVisible", false);
	}
	else if ( PC.PlayerReplicationInfo.bReadyToPlay && PC.WorldInfo.GRI.bMatchHasBegun )
	{
		SetBool("characterButtonEnabled", false);
		return;
	}
	UpdateCharacterList();
	UpdateGear();
}

defaultproperties
{
}
