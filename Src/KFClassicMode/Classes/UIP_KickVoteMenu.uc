class UIP_KickVoteMenu extends KFGUI_Page;

var int PlayerIndex;
var KFPlayerReplicationInfo RightClickPlayer;
var editinline export KFGUI_RightClickMenu PlayerContext;
var KFGUI_List PlayersList;
var transient int InitAdminSize;
var Texture ItemBoxTexture, ItemBarTexture;

var KFGameReplicationInfo KFGRI;
var array<KFPlayerReplicationInfo> KFPRIArray;

var KFPlayerController KFPlayerOwner;

var KFGUI_Tooltip ToolTipItem;

var transient bool bHasSelectedPlayer,bMeAdmin;

struct FAdminCmdType
{
    var string Cmd,Info;
};
var array<FAdminCmdType> AdminCommands;

function InitMenu()
{
    Super.InitMenu();
    PlayersList = KFGUI_List(FindComponentID('PlayerList'));
    KFPlayerOwner = KFPlayerController(GetPlayer());
}

function ShowMenu()
{
    local int i;
    local bool bAdmin;
    
    Timer();
    SetTimer(0.01,true);
    
    bAdmin = KFPlayerOwner!=None && (KFPlayerOwner.WorldInfo.NetMode!=NM_Client || (KFPlayerOwner.PlayerReplicationInfo!=None && KFPlayerOwner.PlayerReplicationInfo.bAdmin));
    if( KFPlayerOwner!=None && (InitAdminSize!=AdminCommands.Length || !bAdmin) )
    {
        InitAdminSize = (bAdmin ? AdminCommands.Length : 0);
        PlayerContext.ItemRows.Length = 4+InitAdminSize;
        for( i=0; i<InitAdminSize; ++i )
            PlayerContext.ItemRows[4+i].Text = AdminCommands[i].Info;
    } 
}

function Timer()
{
    local KFPlayerReplicationInfo PRI;
    local int i;
    
    if( !bTextureInit )
    {
        GetStyleTextures();
    }
    
    if( KFGRI == None )
    {
        KFGRI = KFGameReplicationInfo(GetPlayer().WorldInfo.GRI);
        return;
    }
    
    KFPRIArray.Length = 0;
    for( i=0; i<KFGRI.PRIArray.Length; ++i )
    {
        PRI = KFPlayerReplicationInfo(KFGRI.PRIArray[i]);
        if( PRI==None || PRI.bIsInactive )
            continue;
            
        KFPRIArray.AddItem(PRI);
    }
    PlayersList.ChangeListSize(KFPRIArray.Length);
}

function CloseMenu()
{
    KFGRI = None;
    KFPRIArray.Length = 0;
    RightClickPlayer = None;
    bHasSelectedPlayer = false;
}

function DrawPlayerEntry( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local float FontScalar, TextYOffset, XL, YL, AvatarXPos, AvatarYPos, ImageBorder;
    local KFPlayerReplicationInfo PRI;
    
    if( KFPRIArray.Length <= 0 )
        return;
    
    PRI = KFPRIArray[Index];
    if( PRI == None )
        return;
    
    YOffset *= 1.05;
    ImageBorder = Owner.CurrentStyle.ScreenScale(6);
    
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
    FontScalar += 0.2;
    
    if( bFocus )
    {
        C.SetDrawColor(0, 255, 0, 255);
    }
    else
    {
        C.SetDrawColor(255, 255, 255, 255);
    }
    
    C.SetPos(Height,YOffset);
    C.DrawTileStretched(ItemBarTexture,Width-(Height * 2.5),Height,0,0,ItemBarTexture.GetSurfaceWidth(),ItemBarTexture.GetSurfaceHeight());
    
    C.SetDrawColor(255, 255, 255, 255);
    
    C.SetPos(0.f,YOffset);
    C.DrawTileStretched(ItemBoxTexture,Height,Height,0,0,ItemBoxTexture.GetSurfaceWidth(),ItemBoxTexture.GetSurfaceHeight());
    
    C.TextSize("ABC", XL, YL, FontScalar, FontScalar);
    TextYOffset = YOffset + (Height / 2) - (YL / 1.75f);
    
    if( PRI.Avatar != None )
    {
        if( PRI.Avatar == class'KFScoreBoard'.default.DefaultAvatar )
            class'KFScoreBoard'.static.CheckAvatar(PRI, KFPlayerOwner);
            
        AvatarXPos = Height-(ImageBorder*2);
        AvatarYPos = Height-(ImageBorder*2);
        
        C.SetPos((Height / 2) - (AvatarXPos / 2), YOffset + (Height / 2) - (AvatarYPos / 2));
        C.DrawRect(AvatarXPos, AvatarYPos, PRI.Avatar);
    } 
    else
    {
        if( !PRI.bBot )
            class'KFScoreBoard'.static.CheckAvatar(PRI, KFPlayerOwner);
    }
    
    C.SetPos(Height + (ImageBorder*2), TextYOffset);
    C.DrawText(PRI.PlayerName,, FontScalar, FontScalar);
}

function ShowPlayerTooltip( int Index )
{
    local KFPlayerReplicationInfo PRI;
    local string S, HealthString;
    
    PRI = KFPRIArray[Index];
    if( PRI!=None )
    {
        if( ToolTipItem==None )
        {
            ToolTipItem = New(None)Class'KFGUI_Tooltip';
            ToolTipItem.Owner = Owner;
            ToolTipItem.ParentComponent = Self;
            ToolTipItem.InitMenu();
        }
        HealthString = GetPlayer().PlayerReplicationInfo.GetTeamNum() != PRI.GetTeamNum() ? "Unknown" : (PRI.PlayerHealthPercent<=0 ? "0" : string(PRI.PlayerHealth));
        S = "Player: "$PRI.PlayerName$"<SEPERATOR>Health: "$HealthString;
        if( KFGRI.bVersusGame )
            S = S$"<SEPERATOR>Team: "$PRI.Team.GetHumanReadableName();
        if( PRI.bAdmin )
            S = S$"<SEPERATOR> Admin";
        S = S$"<SEPERATOR>(Right click for options)";
        ToolTipItem.SetText(S);
        ToolTipItem.ShowMenu();
        ToolTipItem.CompPos[0] = Owner.MousePosition.X;
        ToolTipItem.CompPos[1] = Owner.MousePosition.Y;
        ToolTipItem.GetInputFocus();
    }
}

function ClickedPlayer( int Index, bool bRight, int MouseX, int MouseY )
{
    local PlayerController PC;
    local int i;

    if( !bRight || Index<0 )
        return;
    bHasSelectedPlayer = true;
    RightClickPlayer = KFPRIArray[Index];
    
    // Check what items to disable.
    PC = GetPlayer();
    PlayerContext.ItemRows[0].bDisabled = (PlayerIndex==Index || !PC.IsSpectating() || !PC.WorldInfo.GRI.bMatchHasBegun);
    PlayerContext.ItemRows[1].bDisabled = RightClickPlayer.bBot;
    PlayerContext.ItemRows[2].bDisabled = (PlayerIndex==Index || RightClickPlayer.bBot);
    PlayerContext.ItemRows[2].Text = (PlayerContext.ItemRows[2].bDisabled || PC.IsPlayerMuted(RightClickPlayer.UniqueId)) ? "Unmute player" : "Mute player";

    if( PlayerIndex==Index ) // Selected self.
    {
        for( i=4; i<PlayerContext.ItemRows.Length; ++i )
            PlayerContext.ItemRows[i].bDisabled = true;
    }
    else
    {
        for( i=4; i<PlayerContext.ItemRows.Length; ++i )
            PlayerContext.ItemRows[i].bDisabled = false;
    }

    PlayerContext.OpenMenu(Self);
}

function HidRightClickMenu( KFGUI_RightClickMenu M )
{
    bHasSelectedPlayer = false;
}
function SelectedRCItem( int Index )
{
    local PlayerController PC;
    local KFPlayerReplicationInfo KFPRI;
    local String S;

    PC = GetPlayer();
    KFPRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
    switch( Index )
    {
    case 0: // Spectate this player.
        PC.ConsoleCommand("ViewPlayerID "$RightClickPlayer.PlayerID);
        break;
    case 1: // Steam profile.
        OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem()).ShowProfileUI(0,,RightClickPlayer.UniqueId);
        break;
    case 2: // Mute voice.
        if( !PC.IsPlayerMuted(RightClickPlayer.UniqueId) )
        {
            PC.ClientMessage("You've muted "$RightClickPlayer.PlayerName);
            PC.ClientMutePlayer(RightClickPlayer.UniqueId);
        }
        else
        {
            PC.ClientMessage("You've unmuted "$RightClickPlayer.PlayerName);
            PC.ClientUnmutePlayer(RightClickPlayer.UniqueId);
        }
        break;
    case 3: // Vote kick.
        KFPRI.ServerStartKickVote(RightClickPlayer, KFPRI);
        break;
    default:
        if( Index>=5 )
        {
            S = "Admin ";
            PC.ConsoleCommand(S$AdminCommands[Index-5].Cmd@RightClickPlayer.PlayerName);
        }
    }
}

function GetStyleTextures()
{
    if( !Owner.bFinishedReplication )
    {
        return;
    }
    
    ItemBoxTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL];
    ItemBarTexture = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_NORMAL];
    PlayersList.OnDrawItem = DrawPlayerEntry;
    
    bTextureInit = true;
}

defaultproperties
{
    bNoBackground=true
    
    Begin Object Class=KFGUI_List Name=PlayerList
        XSize=0.625
        OnClickedItem=ClickedPlayer
        ID="PlayerList"
        bClickable=true
        OnMouseRest=ShowPlayerTooltip
        ListItemsPerPage=16
    End Object
    Components.Add(PlayerList)
    
    Begin Object Class=KFGUI_RightClickMenu Name=PlayerContextMenu
        ItemRows.Add((Text="Spectate this player"))
        ItemRows.Add((Text="View player Steam profile"))
        ItemRows.Add((Text="Mute Player"))
        ItemRows.Add((Text="Vote Kick Player"))
        ItemRows.Add((bSplitter=true))
        OnSelectedItem=SelectedRCItem
        OnBecameHidden=HidRightClickMenu
    End Object
    PlayerContext=PlayerContextMenu
    
    AdminCommands.Add((Info="Kick Player",Cmd="Kick"))
    AdminCommands.Add((Info="Ban Player",Cmd="KickBan"))
}