/** Needs to be replaced because TWI force a localization string so lets change that to default to the key name if no localization exists **/
class ClassicHUD_PlayerMoveList extends KFGFxHUD_PlayerMoveList;

/** Called once when a new pawn is possessed */
function InitializeMoveList()
{
	local int i, j;
	local GFxObject MoveObject;
	local Array<SpecialMoveCooldownInfo> AttackArray;
	local KeyBind MyKeyBind;
	local int LookupIndex;
	local int ButtonPriority;
	local HUDMoveInfo SavedMoveInfo;
    local string BindName, MoveName;

	// No monster pawn, no moves
	if( MyKFPM == none )
	{
		return;
	}

	CurrentMoves.Remove(0, CurrentMoves.Length);
	AttackArray = MyKFPM.GetSpecialMoveCooldowns();
	
	//@TODO Find a better way to empty out the MoveListObjectArray (the method call here insures there are no phantom slots)
	MoveListObjectArray = CreateArray();
	
	for (i = 0; i < AttackArray.length; i++)
	{
		if( AttackArray[i].SMHandle != SM_None && AttackArray[i].bShowOnHud )
		{
			MoveObject = CreateObject("Object");

			//set icon
			if(AttackArray[i].SpecialMoveIcon != none)
			{
				MoveObject.SetString("image", "img://"$PathName(AttackArray[i].SpecialMoveIcon));
			}
			else
			{
				MoveObject.SetString("image", "img://"$PathName(ZedIconTexture));
			}
			
			//set key
			ButtonPriority = -1;
			bUsingGamepadControls = MyInput.bUsingGamepad;
			if ( bUsingGamepadControls )
			{
				// Find special move
				LookupIndex = MyKFPM.MoveListGamepadScheme.Find(AttackArray[i].SMHandle);
				if ( LookupIndex != INDEX_NONE )
				{
					MyInput.GetKeyBindFromCommand(MyKeyBind, GamepadMoveKeyBinds[LookupIndex], false);
					MoveObject.SetString("buttonString", MyInput.GetBindDisplayName(MyKeyBind) );
					ButtonPriority = GamepadKeyPriority.Find(MyKeyBind.Name);
				}
			}
			else
			{
				LookupIndex = AttackArray[i].SMHandle - SM_PlayerZedMove_LMB;
				if(LookupIndex >= 0 && LookupIndex < PlayerMoveKeyBinds.Length)
				{
					MyInput.GetKeyBindFromCommand(MyKeyBind, PlayerMoveKeyBinds[LookupIndex], false);
                    BindName = MyInput.GetBindDisplayName(MyKeyBind);
                    if (BindName ~= "None")
                    {
                        MyInput.GetKeyBindFromCommand(MyKeyBind, GetAlternateBindName(PlayerMoveKeyBinds[LookupIndex]), false);
                        BindName = MyInput.GetBindDisplayName(MyKeyBind);
                    }
					MoveObject.SetString("buttonString", BindName );
				}
			}
							
			if(AttackArray[i].NameLocalizationKey != "")
			{
				MoveName = Localize("ZedMoves", AttackArray[i].NameLocalizationKey, "KFGame");
				if( InStr(MoveName, "?INT?") != -1 )
					MoveName = AttackArray[i].NameLocalizationKey;
				
				MoveObject.SetString("moveName", MoveName);		
			}

			// clear charges in case index changed (e.g. controller/keyboard sort)
			if ( AttackArray[i].Charges == -1 )
			{
				MoveObject.SetString("count", "" );
			}

			// cache for UpdateMoveList
			SavedMoveInfo.GfxObj = MoveObject;
			SavedMoveInfo.AtkIndex = i;
			SavedMoveInfo.ButtonPriority = ButtonPriority;

			// insert into sorted list
			for (j = 0; j < CurrentMoves.length; j++)
			{
				if ( ButtonPriority < CurrentMoves[j].ButtonPriority )
				{
					CurrentMoves.InsertItem(j, SavedMoveInfo);
					break;
				}
			}

			// otherwise add to end
			if ( j == CurrentMoves.Length )
			{
				CurrentMoves.AddItem(SavedMoveInfo);
			}
		}
	}

	// finally (after sorting) assign the ObjectArray
	BuildObjectArray();
}

DefaultProperties
{
}