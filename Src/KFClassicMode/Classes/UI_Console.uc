Class UI_Console extends Console;

var transient Console OriginalConsole;
var transient UI_ConsoleMenu ConsoleMenu;

function ConsoleCommand(string Command)
{
    local string S, OrgS;
    
    S = "\n>>>" @ Command @ "<<<";
    OutputText(S);
    
    OriginalConsole.ConsoleCommand(Command);
    
    OrgS = OriginalConsole.ScrollBack[OriginalConsole.SBHead];
    if( InStr(OrgS, Command) == INDEX_NONE )
        OutputText(OrgS);
}

function OutputText(coerce string Text)
{
    if( ConsoleMenu == None )
    {
        OriginalConsole.OutputText(Text);
        return;
    }
    
    if( Text == "" )
        return;
        
    ConsoleMenu.AddText(Text$"<LINEBREAK>");
}

function bool InputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
{
	local PlayerController PC;

	if ( Event == IE_Pressed )
	{
        if( bCaptureKeyInput )
        {
            if( Key == 'Up' )
            {
                if ( OriginalConsole.HistoryBot >= 0 )
                {
                    if (OriginalConsole.HistoryCur == OriginalConsole.HistoryBot)
                        OriginalConsole.HistoryCur = OriginalConsole.HistoryTop;
                    else
                    {
                        OriginalConsole.HistoryCur--;
                        if (OriginalConsole.HistoryCur<0)
                            OriginalConsole.HistoryCur = OriginalConsole.MaxHistory-1;
                    }

                    ConsoleMenu.ChatBoxEdit.SetText(OriginalConsole.History[OriginalConsole.HistoryCur], true);
                    ConsoleMenu.ChatBoxEdit.bAllSelected = false;
                }
                return true;
            }
            else if( Key == 'Down' )
            {
                if ( OriginalConsole.HistoryBot >= 0 )
                {
                    if (OriginalConsole.HistoryCur == OriginalConsole.HistoryTop)
                        OriginalConsole.HistoryCur = OriginalConsole.HistoryBot;
                    else
                        OriginalConsole.HistoryCur = (OriginalConsole.HistoryCur+1) % OriginalConsole.MaxHistory;

                    ConsoleMenu.ChatBoxEdit.SetText(OriginalConsole.History[OriginalConsole.HistoryCur], true);
                    ConsoleMenu.ChatBoxEdit.bAllSelected = false;
                }
                return true;
            }
        }
    
		if(Key == 'F10')
		{
			foreach class'Engine'.static.GetCurrentWorldInfo().LocalPlayerControllers(class'PlayerController', PC)
			{
				PC.ForceDisconnect();
			}
		}

		if ( Key == ConsoleKey )
		{
            bCaptureKeyInput = true;
            class'KF2GUIController'.static.GetGUIController(GamePlayers[0].Actor).OpenMenu(class'UI_ConsoleMenu');
			return true;
		}
	}

	return false;
}

function bool InputChar( int ControllerId, string Unicode )
{
    return false;
}

defaultproperties
{
}