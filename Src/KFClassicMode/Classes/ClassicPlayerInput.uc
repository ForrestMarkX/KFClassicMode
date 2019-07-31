class ClassicPlayerInput extends KFPlayerInput within ClassicPlayerController
    config(ClassicInput);

var bool bHandledTravel;
var KF2GUIController MyGUIController;

exec function GamepadDpadLeft()
{
    if(Outer.IsSpectating())
    {
        Outer.ServerViewPrevPlayer();
    }
    else if( bGamepadWeaponSelectOpen || CheckForWeaponMenuTimerInterrupt() )
    {
        if( HUDInterface != None )
        {
            SwitchWeaponGroup( Clamp(HUDInterface.SelectedInventoryCategory-1, 0, HUDInterface.MAX_WEAPON_GROUPS) );
            HUDInterface.SelectedInventoryIndex = 0;
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
    if(Outer.IsSpectating())
    {
        Outer.ServerViewNextPlayer();
    }
    else if( bGamepadWeaponSelectOpen || CheckForWeaponMenuTimerInterrupt() )
    {
        if( HUDInterface != None )
        {
            SwitchWeaponGroup( Clamp(HUDInterface.SelectedInventoryCategory+1, 0, HUDInterface.MAX_WEAPON_GROUPS) );
            HUDInterface.SelectedInventoryIndex = 0;
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

    if( MyGFxHUD != none && MyGFxHUD.VoiceCommsWidget != none && MyGFxHUD.VoiceCommsWidget.bActive )
        return;
        
    if (Pawn != none && bUsingGamepad)
    {
        KFW = KFWeapon(Pawn.Weapon);
        if ( KFW != None && !KFW.CanSwitchWeapons())
           return;
        
        if( HUDInterface != None )
        {
            bGamepadWeaponSelectOpen = true;
            KFInventoryManager(Pawn.InvManager).HighlightWeapon(Pawn.Weapon);
            
            if( !HUDInterface.bDisplayInventory )
            {
                HUDInterface.bDisplayInventory = true;
                HUDInterface.InventoryFadeStartTime = WorldInfo.TimeSeconds;
            }
            else
            {
                if ( `TimeSince(HUDInterface.InventoryFadeStartTime) > HUDInterface.InventoryFadeInTime )
                {
                    if ( `TimeSince(HUDInterface.InventoryFadeStartTime) > HUDInterface.InventoryFadeTime - HUDInterface.InventoryFadeOutTime )
                        HUDInterface.InventoryFadeStartTime = `TimeSince(HUDInterface.InventoryFadeInTime + ((HUDInterface.InventoryFadeTime - `TimeSince(HUDInterface.InventoryFadeStartTime)) * HUDInterface.InventoryFadeInTime));
                    else HUDInterface.InventoryFadeStartTime = `TimeSince(HUDInterface.InventoryFadeInTime);
                }
            }
        }
    }
}

exec function ShowVoiceComms()
{
    if( (bVersusInput && PlayerReplicationInfo.GetTeamNum() == 255) || IsBossCameraMode() )
        return;

    if( HUDInterface.VoiceComms != None )
        HUDInterface.VoiceComms.SetVisibility(!HUDInterface.VoiceComms.bVisible);
}

exec function OnVoteYesPressed()
{
    local KFPlayerReplicationInfo KFPRI;
    
    if( !HUDInterface.bVoteActive )
        return;
    
    KFPRI = KFPlayerReplicationInfo(Outer.PlayerReplicationInfo);
    KFPRI.CastKickVote(KFPRI, true);
}

exec function OnVoteNoPressed()
{
    local KFPlayerReplicationInfo KFPRI;
    
    if( !HUDInterface.bVoteActive )
        return;
    
    KFPRI = KFPlayerReplicationInfo(Outer.PlayerReplicationInfo);
    KFPRI.CastKickVote(KFPRI, false);
}

exec function CustomStartFire( optional Byte FireModeNum )
{
    if( !Outer.bDisableGameplayChanges && FireModeNum == class'KFWeapon'.const.BASH_FIREMODE )
        return;
        
    Super.CustomStartFire(FireModeNum);
}

exec function SwitchFire()
{
    local KFWeapon Wep;
    
    if( !Outer.bDisableGameplayChanges && Pawn != None )
    {
        Wep = KFWeapon(Pawn.Weapon);
        if( Wep != None )
        {
            if( Wep.IsMeleeWeapon() )
                return;
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
            ServerThrowOtherWeapon(W);
    }
    else SwitchFire();
}

function PreClientTravel( string PendingURL, ETravelType TravelType, bool bIsSeamlessTravel)
{
    Super.PreClientTravel(PendingURL,TravelType,bIsSeamlessTravel);
    if( !bHandledTravel )
    {
        bHandledTravel = true;
        if( HUDInterface!=None )
            HUDInterface.NotifyLevelChange(true);
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
            return true;
            
        if( MyGFxManager.bMenusOpen )
            return MyGFxManager.ToggleMenus();
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
            else MyGUIController.OpenMenu(Outer.MidGameMenuClass);
        }
    }
    
    return false;
}

exec function HideVoiceComms();

defaultproperties
{
}