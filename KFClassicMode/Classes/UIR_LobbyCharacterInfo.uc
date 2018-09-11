class UIR_LobbyCharacterInfo extends KFGUI_Frame;

var KFGUI_Image PlayerPortrait;
var KFGUI_TextLable CharacterName;
var Texture OldPortrait;

function InitMenu()
{
    Super.InitMenu();
    PlayerPortrait = KFGUI_Image(FindComponentID('PlayerPortrait'));
    CharacterName = KFGUI_TextLable(FindComponentID('CharacterName'));
}

function DrawMenu()
{
    local ClassicPlayerReplicationInfo PRI;
    local KFCharacterInfo_Human CurrentCharacter;
    local string S;
    
    PRI = ClassicPlayerReplicationInfo(GetPlayer().PlayerReplicationInfo);
    if( PRI==None )
        return;
        
    if( OldPortrait != PRI.CharPortrait )
    {
        PlayerPortrait.Image = PRI.CharPortrait;
        OldPortrait = PRI.CharPortrait;
        
        CurrentCharacter = PRI.GetSelectedArch();
        if( PRI.ReallyUsingCustomChar() )
        {
            S = Repl(string(CurrentCharacter.Name),"_"," ");
        }
        else
        {
            S = Localize(string(CurrentCharacter.Name), "CharacterName", class'KFGFxMenu_Gear'.Default.KFCharacterInfoString);
        }
        CharacterName.SetText(S);
    }
        
    Super.DrawMenu();
}

defaultproperties
{
    Begin Object class=KFGUI_Image Name=PlayerPortrait
        ID="PlayerPortrait"
          YPosition=0
        XPosition=0
        XSize=1
        YSize=1
        bAlignCenter=true
    End Object
    Components.Add(PlayerPortrait)
    
    Begin Object class=KFGUI_TextLable Name=CharacterName
        ID="CharacterName"
        AlignX=1
          YPosition=0.75
        XPosition=0
        XSize=1
        YSize=1
    End Object
    Components.Add(CharacterName)
}