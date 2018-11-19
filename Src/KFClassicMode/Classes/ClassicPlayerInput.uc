class ClassicPlayerInput extends KFPlayerInput within ClassicPlayerController
    config(ClassicInput);

var bool bHandledTravel;
var KF2GUIController MyGUIController;

/*
simulated exec function ToggleFlashlight()
{
    local KFPawn_Human KFP;
    local KFInventoryManager InvMan;
    local Inventory Inv;
    local KFWeapon Wep;
    
    if( Pawn == none || Pawn.InvManager == none || bGamepadWeaponSelectOpen )
    {
         return;
    }
    
    InvMan = KFInventoryManager(Pawn.InvManager);
    if( InvMan != None )
    {
        for( Inv = InvMan.InventoryChain; Inv != None; Inv = Inv.Inventory )
        {
            if( Inv.Class == class'KFWeap_Pistol_9mm' || Inv.Class == class'KFWeap_Pistol_9mm' )
            {
                Wep = KFWeapon(Inv);
                break;
            }
        }
        
        if( Wep != None )
        {
            Pawn.InvManager.SetCurrentWeapon(Wep);

            KFP = KFPawn_Human(Pawn);
            if( KFP != None && KFP.MyKFWeapon != None )
            {
                InternalToggleFlashlight();
            }
        }
    }
}
*/

function PlayerInput( float DeltaTime )
{
    local KFHUDInterface HUD;
    
    HUD = KFHUDInterface(Outer.myHUD);
    if( HUD != None && HUD.bChatOpen )
    {
        aMouseX = 0;
        aMouseY = 0;
        aBaseX = 0;
        aBaseY = 0;
        aBaseZ = 0;
        aForward = 0;
        aTurn = 0;
        aStrafe = 0;
        aUp = 0;
        aLookUp = 0;
        return;
    }
    
    Super.PlayerInput(DeltaTime);
}

exec function GamepadDpadLeft()
{
    local KFHUDInterface HUD;
    
    if(Outer.IsSpectating())
    {
        Outer.ServerViewPrevPlayer();
    }
    else if( bGamepadWeaponSelectOpen || CheckForWeaponMenuTimerInterrupt() )
    {
        HUD = KFHUDInterface(Outer.myHUD);
        if( HUD != None )
        {
            SwitchWeaponGroup( Clamp(HUD.SelectedInventoryCategory-1, 0, HUD.MAX_WEAPON_GROUPS) );
            HUD.SelectedInventoryIndex = 0;
        }
    }
    else
    {
        // taunt while playing as zed
        if ( bVersusInput && ChangeZedCamera(true) )
        {
            return; // player zed move override
        }

        ShowVoiceComms();
    }
}

exec function GamepadDpadRight()
{
    local KFHUDInterface HUD;
    
    if(Outer.IsSpectating())
    {
        Outer.ServerViewNextPlayer();
    }
    else if( bGamepadWeaponSelectOpen || CheckForWeaponMenuTimerInterrupt() )
    {
        HUD = KFHUDInterface(Outer.myHUD);
        if( HUD != None )
        {
            SwitchWeaponGroup( Clamp(HUD.SelectedInventoryCategory+1, 0, HUD.MAX_WEAPON_GROUPS) );
            HUD.SelectedInventoryIndex = 0;
        }
    }
    else
    {
        // taunt while playing as zed
        if ( bVersusInput && ChangeZedCamera(false) )
        {
            return; // player zed move override
        }

        TossMoney();
    }
}

exec function GamepadDpadDown()
{
    local KFInventoryManager KFIM;
    
    if(Outer.IsSpectating())
    {
        Outer.ServerNextSpectateMode();
    }
    else if( bGamepadWeaponSelectOpen || CheckForWeaponMenuTimerInterrupt() )
    {
        KFIM = KFInventoryManager(Pawn.InvManager);
        if ( KFIM != none )
        {
            KFIM.HighlightNextWeapon();
        }
    }
    else
    {
        // taunt while playing as zed
        if ( bVersusInput && CustomStartFireVersus(7) )
        {
            return; // player zed move override
        }

        ToggleFlashlight();
    }
}

exec function GamepadDpadUp()
{
    local KFInventoryManager KFIM;
    
    if( bGamepadWeaponSelectOpen || CheckForWeaponMenuTimerInterrupt() )
    {
        KFIM = KFInventoryManager(Pawn.InvManager);
        if ( KFIM != none )
        {
            KFIM.HighlightPrevWeapon();
        }
    }    
    else
    {
        // taunt while playing as zed
        if ( bVersusInput && CustomStartFireVersus(7) )
        {
            return; // player zed move override
        }

        // toggle between healer and last weapon
        if ( Pawn != None && Pawn.Weapon != None && Pawn.Weapon.IsA('KFWeap_HealerBase') )
        {
            KFInventoryManager( Pawn.InvManager ).SwitchToLastWeapon();
        }
        else
        {
            SelectLastWeapon();
        }
    }
}

exec function ReleaseGamepadWeaponSelect()
{
    if ( bGamepadWeaponSelectOpen )
    {
        bGamepadWeaponSelectOpen = false;
    }
    
    Super.ReleaseGamepadWeaponSelect();
}

function GamepadWeaponMenuTimer()
{
    local KFWeapon KFW;
    local KFHUDInterface HUD;

    if( MyGFxHUD != none && MyGFxHUD.VoiceCommsWidget != none && MyGFxHUD.VoiceCommsWidget.bActive )
    {
        return;
    }
    if (Pawn != none && bUsingGamepad)
    {
        KFW = KFWeapon(Pawn.Weapon);
        if ( KFW != None && !KFW.CanSwitchWeapons())
        {
           return;
        }
        
        HUD = KFHUDInterface(Outer.myHUD);
        if( HUD != None )
        {
            bGamepadWeaponSelectOpen = true;
            KFInventoryManager(Pawn.InvManager).HighlightWeapon(Pawn.Weapon);
            
            if( !HUD.bDisplayInventory )
            {
                HUD.bDisplayInventory = true;
                HUD.InventoryFadeStartTime = WorldInfo.TimeSeconds;
            }
            else
            {
                if ( WorldInfo.TimeSeconds - HUD.InventoryFadeStartTime > HUD.InventoryFadeInTime )
                {
                    if ( WorldInfo.TimeSeconds - HUD.InventoryFadeStartTime > HUD.InventoryFadeTime - HUD.InventoryFadeOutTime )
                    {
                        HUD.InventoryFadeStartTime = WorldInfo.TimeSeconds - HUD.InventoryFadeInTime + ((HUD.InventoryFadeTime - (WorldInfo.TimeSeconds - HUD.InventoryFadeStartTime)) * HUD.InventoryFadeInTime);
                    }
                    else
                    {
                        HUD.InventoryFadeStartTime = WorldInfo.TimeSeconds - HUD.InventoryFadeInTime;
                    }
                }
            }
        }
    }
}

exec function OnVoteYesPressed()
{
    local KFPlayerReplicationInfo KFPRI;
    
    if( !KFHUDInterface(Outer.myHUD).bVoteActive )
        return;
    
    KFPRI = KFPlayerReplicationInfo(Outer.PlayerReplicationInfo);
    KFPRI.CastKickVote(KFPRI, true);
}

exec function OnVoteNoPressed()
{
    local KFPlayerReplicationInfo KFPRI;
    
    if( !KFHUDInterface(Outer.myHUD).bVoteActive )
        return;
    
    KFPRI = KFPlayerReplicationInfo(Outer.PlayerReplicationInfo);
    KFPRI.CastKickVote(KFPRI, false);
}

exec function CustomStartFire( optional Byte FireModeNum )
{
    if( FireModeNum == class'KFWeapon'.const.BASH_FIREMODE )
        return;
        
    Super.CustomStartFire(FireModeNum);
}

exec function SwitchFire()
{
    local KFWeapon Wep;
    
    if( Pawn != None )
    {
        Wep = KFWeapon(Pawn.Weapon);
        if( Wep != None )
        {
            if( Wep.IsMeleeWeapon() )
            {
                return;
            }
        }
    }
    
    Super.SwitchFire();
}

exec function GamepadSwitchFire()
{
    local Weapon W;

    if ( bGamepadWeaponSelectOpen )
    {
        W = Pawn.InvManager.PendingWeapon != none ? Pawn.InvManager.PendingWeapon : Pawn.Weapon;
        if( W != None && W.CanThrow() )
        {
            ServerThrowOtherWeapon(W);
        }
    }
    else
    {
        SwitchFire();
    }
}

function PreClientTravel( string PendingURL, ETravelType TravelType, bool bIsSeamlessTravel)
{
    Super.PreClientTravel(PendingURL,TravelType,bIsSeamlessTravel);
    if( !bHandledTravel )
    {
        bHandledTravel = true;
        if( KFHUDInterface(MyHUD)!=None )
            KFHUDInterface(MyHUD).NotifyLevelChange(true);
    }
}

function bool FilterButtonInput(int ControllerId, Name Key, EInputEvent Event, float AmountDepressed, bool bGamepad)
{
    local xVotingReplication R;
    local KeyBind BoundKey;
    
    if( Event == IE_Pressed )
    {
        GetKeyBindFromCommand(BoundKey, "GBA_Talk", false);
        if( Key == name(GetBindDisplayName(BoundKey)) )
        {
            Outer.Talk();
            return true;
        }
        else
        {
            GetKeyBindFromCommand(BoundKey, "GBA_TeamTalk", false);
            if( Key == name(GetBindDisplayName(BoundKey)) )
            {
                Outer.TeamTalk();
                return true;
            }
        }
    }
    
    GetKeyBindFromCommand(BoundKey, "GBA_ShowMenu", false);
    if( Event==IE_Pressed && Key == name(GetBindDisplayName(BoundKey)) )
    {
        if( MyGUIController==None || MyGUIController.bIsInvalid )
        {
            MyGUIController = class'KF2GUIController'.Static.GetGUIController(Outer);
            if( MyGUIController==None )
            {
                Outer.CancelConnection();
                return false;
            }
        }
        
        if( MyGUIController.bIsInMenuState )
        {
            return true;
        }
            
        if ( (WorldInfo.GRI.bMatchHasBegun || WorldInfo.GRI.bMatchIsOver) )
        {
            if( MyGFxManager.bMenusOpen )
            {
                return MyGFxManager.ToggleMenus();
            }
            else
            {
                if( WorldInfo.GRI.bMatchIsOver )
                {
                    foreach Outer.DynamicActors(class'KFClassicMode.xVotingReplication',R)
                    {
                        R.ClientOpenMapvote();
                        break;
                    }
                        
                    return true;
                }
                else
                {
                    MyGUIController.OpenMenu(Outer.MidGameMenuClass);
                }
            }
        }
        else if( !WorldInfo.GRI.bMatchHasBegun )
        {
            MyGUIController.OpenMenu(Outer.LobbyMenuClass);
        }
    }
    
    return false;
}

defaultproperties
{
    bQuickWeaponSelect=false
}