class UIR_TraderExitFrame extends KFGUI_Frame;

var KFGUI_Button AutoFill,Exit;
var UI_TraderMenu TraderMenu;

var int OldFillAmmoCost;

function InitMenu()
{
    Super.InitMenu();
    
    AutoFill = KFGUI_Button(FindComponentID('AutoFill'));
    AutoFill.GamepadButtonName = "XboxTypeS_Back";
    AutoFill.OnClickLeft = InternalOnClick;
    AutoFill.OnClickRight = InternalOnClick;
    
    Exit = KFGUI_Button(FindComponentID('Exit'));
    Exit.GamepadButtonName = "XboxTypeS_Start";
    Exit.OnClickLeft = InternalOnClick;
    Exit.OnClickRight = InternalOnClick;
    
    TraderMenu = UI_TraderMenu(ParentComponent);
}

function ShowMenu()
{
    Super.ShowMenu();
    SetTimer(0.25f, true, nameOf(Refresh));
}

function Refresh()
{
    local int FillCost;
    local KFAutoPurchaseHelper KFAPH;
    
    KFAPH = ClassicPlayerController(GetPlayer()).GetPurchaseHelper();
    FillCost = KFAPH.GetAutoFillCost();
    if( FillCost != OldFillAmmoCost )
    {
        if( FillCost == 0 )
        {
            AutoFill.ButtonText = TraderMenu.AutoFillString;
            AutoFill.bDisabled = true;
        }
        else
        {
            AutoFill.ButtonText = TraderMenu.AutoFillString @ "(£"$FillCost$")";
            AutoFill.bDisabled = false;
        }
        
        OldFillAmmoCost = FillCost;
    }
}

function InternalOnClick( KFGUI_Button Sender )
{
    local KFAutoPurchaseHelper KFAPH;
    
    KFAPH = ClassicPlayerController(GetPlayer()).GetPurchaseHelper();
    switch( Sender.ID )
    {
        case 'AutoFill':
            KFAPH.StartAutoFill();
            TraderMenu.Inv.Refresh(true);
            break;
        case 'Exit':
            TraderMenu.DoClose();
            break;
    }
}

function bool ReceievedControllerInput(int ControllerId, name Key, EInputEvent Event)
{
    switch(Key)
    {
        case 'XboxTypeS_Back':
            if( Event == IE_Pressed )
            {
                if (KFPlayerController(GetPlayer()) != None && KFPlayerController(GetPlayer()).MyGFxHUD != None)
                {
                    KFPlayerController(GetPlayer()).MyGFxHUD.PlaySoundFromTheme('TRADER_MAGFILL_BUTTON_CLICK', 'UI');
                }
                
                AutoFill.HandleMouseClick(false);
            }
            break;
        case 'XboxTypeS_Start':
            if( Event == IE_Pressed )
            {
                if (KFPlayerController(GetPlayer()) != None && KFPlayerController(GetPlayer()).MyGFxHUD != None)
                {
                    KFPlayerController(GetPlayer()).MyGFxHUD.PlaySoundFromTheme('TRADER_EXIT_BUTTON_CLICK', 'UI');
                }
                
                DoClose();
            }
            break;
    }
    
    return Super.ReceievedControllerInput(ControllerId, Key, Event);
}

defaultproperties
{
    HeaderSize(0)=0.f
    HeaderSize(1)=0.f
    EdgeSize(0)=0.f
    EdgeSize(1)=0.f
    EdgeSize(2)=0.f
    EdgeSize(3)=0.f
        
    /* Fill Ammo Button */
    Begin Object class=KFGUI_Button Name=AutoFill
        ID="AutoFill"
        YPosition=0.2005073
        XPosition=0.15
        XSize=0.75
        YSize=0.2
        Tooltip="Fills Up All Weapons"
        ButtonText="Auto Fill Ammo"
    End Object
    Components.Add(AutoFill)

    /* Exit Trader Button */
    Begin Object class=KFGUI_Button Name=Exit
        ID="Exit"
        YPosition=0.507681
        XPosition=0.15
        XSize=0.75
        YSize=0.2
        Tooltip="Close The Trader Menu"
        ButtonText="Exit Trader Menu"
    End Object
    Components.Add(Exit)
}