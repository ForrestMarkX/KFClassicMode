class ClassicMoviePlayer_HUD extends KFGFxMoviePlayer_HUD;

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local bool Ret;
    
    Ret = Super.WidgetInitialized(WidgetName, WidgetPath, Widget);
    
    if( WaveInfoWidget != None )
    {
        WaveInfoWidget.SetVisible(false);
    }
    
    if( MusicNotification != None )
    {
        MusicNotification.SetVisible(false);
    }
    
    if( RhythmCounterWidget != None )
    {
        RhythmCounterWidget.SetVisible(false);
    }
    
    if( TraderCompassWidget != None )
    {
        TraderCompassWidget.SetVisible(false);
    }        
    
    if( BossHealthBar != None )
    {
        BossHealthBar.SetVisible(false);
    }        
    
    if( BossNameplateContainer != None )
    {
        BossNameplateContainer.SetVisible(false);
    }    
    
    if( SpectatorInfoWidget != None )
    {
        SpectatorInfoWidget.SetVisible(false);
    }    
    
    return Ret;
}

function TickHud(float DeltaTime)
{
    local ASDisplayInfo DI;
    
    Super.TickHud(DeltaTime);
    
    if( PlayerStatusContainer != None )
    {
        DI = PlayerStatusContainer.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            PlayerStatusContainer.SetDisplayInfo(DI);
        }
    }
    
    if( PlayerBackpackContainer != None )
    {
        DI = PlayerBackpackContainer.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            PlayerBackpackContainer.SetDisplayInfo(DI);
        }
    }    
    
    if( WaveInfoWidget != None )
    {
        DI = WaveInfoWidget.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            WaveInfoWidget.SetDisplayInfo(DI);
        }
    }
    
    if( MusicNotification != None )
    {
        DI = MusicNotification.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            MusicNotification.SetDisplayInfo(DI);
        }
    }
    
    if( RhythmCounterWidget != None )
    {
        DI = RhythmCounterWidget.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            RhythmCounterWidget.SetDisplayInfo(DI);
        }
    }
    
    if( TraderCompassWidget != None )
    {
        DI = TraderCompassWidget.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            TraderCompassWidget.SetDisplayInfo(DI);
        }
    }        
    
    if( BossHealthBar != None )
    {
        DI = BossHealthBar.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            BossHealthBar.SetDisplayInfo(DI);
        }
    }        
    
    if( BossNameplateContainer != None )
    {
        DI = BossNameplateContainer.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            BossNameplateContainer.SetDisplayInfo(DI);
        }
    }    
    
    if( SpectatorInfoWidget != None )
    {
        DI = SpectatorInfoWidget.GetDisplayInfo();
        if( DI.Visible )
        {
            DI.Visible = false;
            SpectatorInfoWidget.SetDisplayInfo(DI);
        }
    }    
}

function ShowKickVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
    KFHUDInterface(KFPC.myHUD).ShowVoteUI(PRI, VoteDuration, bShowChoices, VT_TYPE_KICK);
}

simulated function HideKickVote()
{
    KFHUDInterface(KFPC.myHUD).HideVoteUI();
}

function UpdateKickVoteCount(byte YesVotes, byte NoVotes)
{
    KFHUDInterface(KFPC.myHUD).UpdateVoteCount(YesVotes, NoVotes);
}

function ShowNonCriticalMessage(string LocalizedMessage)
{
    KFHUDInterface(KFPC.myHUD).ShowNonCriticalMessage(LocalizedMessage);
}

function DisplayPriorityMessage(string InPrimaryMessageString, string InSecondaryMessageString, int LifeTime, optional KFLocalMessage_Priority.EGameMessageType MessageType);
function ShowBossNameplate(string BossName, string InSecondaryMessageString);
function HideBossNamePlate();
function ShowKillMessage(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, optional bool bDeathMessage=false, optional Object OptionalObject);

DefaultProperties
{
    WidgetBindings.Remove((WidgetName="SpectatorInfoWidget",WidgetClass=class'KFGFxHUD_SpectatorInfo'))
    WidgetBindings.Add((WidgetName="SpectatorInfoWidget",WidgetClass=class'ClassicHUD_SpectatorInfo'))
    
    WidgetBindings.Remove((WidgetName="LevelUpNotificationWidget", WidgetClass=class'KFGFxWidget_LevelUpNotification'))
    WidgetBindings.Add((WidgetName="LevelUpNotificationWidget", WidgetClass=class'ClassicWidget_LevelUpNotification'))
    
    WidgetBindings.Remove((WidgetName="ControllerWeaponSelectContainer",WidgetClass=class'KFGFxHUD_WeaponSelectWidget'))
    WidgetBindings.Remove((WidgetName="WeaponSelectContainer",WidgetClass=class'KFGFxHUD_WeaponSelectWidget'))
    
    //WidgetBindings.Add((WidgetName="ControllerWeaponSelectContainer",WidgetClass=class'ClassicHUD_WeaponSelectWidget'))
    //WidgetBindings.Add((WidgetName="WeaponSelectContainer",WidgetClass=class'ClassicHUD_WeaponSelectWidget'))
    
    WidgetBindings.Remove((WidgetName="ChatBoxWidget", WidgetClass=class'KFGFxHUD_ChatBoxWidget'))
    WidgetBindings.Add((WidgetName="ChatBoxWidget", WidgetClass=class'ClassicHUD_ChatBoxWidget'))
}