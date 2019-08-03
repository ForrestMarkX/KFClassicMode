Class UIP_GameInfo extends KFGUI_Page
    Config(UI);
    
var UIR_GameTypesList GamesFrame;
var UIR_MapsList MapsFrame;
var UIR_DifficultyList DifficultyFrame;
var UIR_LengthList LengthFrame;
var KFGUI_Image MapImage;
var KFGUI_EditBox CommandBox;
var MenuPlayerController PC;
var KFGUI_Frame MapBackground;
var UI_StartGame StartGame;

var config string CustomParameter, SelectedMap;
var config int SelectedMode, SelectedDif, SelectedLength;
var config array<string> SavedMutators;

function InitMenu()
{
    MapBackground = KFGUI_Frame(FindComponentID('MapBackground'));
    MapBackground.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL_SLIGHTTRANSPARENT];
    
    GamesFrame = UIR_GameTypesList(FindComponentID('GamesFrame'));
    GamesFrame.InfoMenu = self;
    
    MapsFrame = UIR_MapsList(FindComponentID('MapsFrame'));
    MapsFrame.InfoMenu = self;
    
    DifficultyFrame = UIR_DifficultyList(FindComponentID('DifficultyFrame'));
    DifficultyFrame.InfoMenu = self;
    
    LengthFrame = UIR_LengthList(FindComponentID('LengthFrame'));
    LengthFrame.InfoMenu = self;
    
    CommandBox = KFGUI_EditBox(FindComponentID('CommandBox'));
    CommandBox.OnChange = CustomParameterChanged;
    CommandBox.SetText(CustomParameter, true);
    
    MapImage = KFGUI_Image(FindComponentID('MapImage'));
    MapImage.Image = class'MS_HUD'.static.GetMapImage("KF-Default");
    
    Super.InitMenu();
    
    PC = MenuPlayerController(GetPlayer());
}

function ShowMenu()
{
    local int i;
    
    Super.ShowMenu();
    
    GamesFrame.SelectedIndex = SelectedMode;
    DifficultyFrame.SelectedIndex = SelectedDif;
    LengthFrame.SelectedIndex = SelectedLength;
    
    for(i=0; i<MapsFrame.Options.Length; i++)
    {
        if( MapsFrame.Options[i] ~= SelectedMap )
        {
            MapsFrame.SelectedIndex = i;
            break;
        }
    }
    
    if( MenuInterface(Owner.HUDOwner) != None )
        MapImage.Image = MenuInterface(Owner.HUDOwner).GetMapImage(MapsFrame.Options[MapsFrame.SelectedIndex]);
        
    SetTimer(0.01f, false, 'UpdateSavedMutators');
}

function UpdateSavedMutators()
{
    local int i, j;
    
    for(i=0; i<SavedMutators.Length; i++)
    {
        for(j=0; j<StartGame.MutatorInfo.MutatorFrame.Mutators.Length; j++)
        {
            if( SavedMutators[i] == StartGame.MutatorInfo.MutatorFrame.Mutators[j].Summary.ClassName )
            {
                StartGame.MutatorInfo.EMutatorFrame.AddMutator(StartGame.MutatorInfo.MutatorFrame.Mutators[j].Summary);
                StartGame.MutatorInfo.MutatorFrame.RemoveMutator(StartGame.MutatorInfo.MutatorFrame.Mutators[j].Summary);
            }
        }
    }
}

function string BuildStartGameURL()
{
    local string URL, Mutators;
    local int i;
    
    URL = MapsFrame.TranslateOptionsIntoURL();
        
    if( GamesFrame.SelectedIndex != -1 && GamesFrame.Options[GamesFrame.SelectedIndex] != class'KFCommon_LocalizedStrings'.default.CustomString )
        URL $= "?Game="$GamesFrame.TranslateOptionsIntoURL();
        
    if( LengthFrame.SelectedIndex != -1 )
        URL $= "?Length="$LengthFrame.TranslateOptionsIntoURL();
        
    if( DifficultyFrame.SelectedIndex != -1 )
        URL $= "?Difficulty="$DifficultyFrame.TranslateOptionsIntoURL();
        
    if( StartGame.MutatorInfo != None && StartGame.MutatorInfo.EMutatorFrame.Mutators.Length > 0 )
    {
        Mutators = PC.WorldInfo.Game.static.ParseOption(CustomParameter, "Mutator");
        
        URL $= "?Mutator=";
        for( i=0; i<StartGame.MutatorInfo.EMutatorFrame.Mutators.Length; ++i )
        {
            URL $= (i==0 ? StartGame.MutatorInfo.EMutatorFrame.Mutators[i].Summary.ClassName : ","$StartGame.MutatorInfo.EMutatorFrame.Mutators[i].Summary.ClassName);
        }
        
        if( Mutators != "" )
        {
            StripOption(CustomParameter, "Mutator");
            URL $= ","$Mutators;
        }
    }
        
    if( CustomParameter != "" )
        URL $= CustomParameter;
        
    return URL;
}

static final function StripOption( out string S, string Param )
{
    local int EndIndex,StartIndex;
    
    StartIndex = InStr(S, "?"$Param$"=");
    if( StartIndex != INDEX_NONE )
    {
        EndIndex = InStr(Mid(S, InStr(S, Param$"=")), "?");
        if( EndIndex == INDEX_NONE )
            EndIndex = Len(S);
            
        S = Left(S,StartIndex) $ Mid(S, EndIndex+Len(Left(S,StartIndex))+1);
    }
}

function CustomParameterChanged(KFGUI_EditBox Sender)
{
    CustomParameter = Sender.TextStr;
    SaveConfig();
}

defaultproperties
{
    Begin Object class=KFGUI_Frame Name=MapBackground
        ID="MapBackground"
        YPosition=0.12
        XPosition=0.37
        XSize=0.26
        YSize=0.26
    End Object
    Components.Add(MapBackground)    
    
    Begin Object class=KFGUI_Image Name=MapImage
        ID="MapImage"
        YPosition=0.125
        XPosition=0.375
        XSize=0.25
        YSize=0.25
        bAlignCenter=true
    End Object
    Components.Add(MapImage)    
    
    Begin Object Class=UIR_GameTypesList Name=GamesFrame
        XPosition=0.025
        YPosition=0.05
        YSize=0.75
        XSize=0.25
        EdgeSize(2)=-20
        WindowTitle="Avaliable Game Types"
        bHeaderCenter=true
        ID="GamesFrame"
    End Object    
    Components.Add(GamesFrame)
    
    Begin Object Class=UIR_MapsList Name=MapsFrame
        XPosition=0.725
        YPosition=0.05
        YSize=0.75
        XSize=0.25
        EdgeSize(2)=-20
        WindowTitle="Avaliable Maps"
        bHeaderCenter=true
        ID="MapsFrame"
    End Object    
    Components.Add(MapsFrame)
    
    Begin Object Class=UIR_DifficultyList Name=DifficultyFrame
        XPosition=0.375
        YPosition=0.4
        YSize=0.4
        XSize=0.125
        EdgeSize(2)=-20
        WindowTitle="Avaliable Difficulties"
        bHeaderCenter=true
        ID="DifficultyFrame"
    End Object    
    Components.Add(DifficultyFrame)
    
    Begin Object Class=UIR_LengthList Name=LengthFrame
        XPosition=0.5
        YPosition=0.4
        YSize=0.4
        XSize=0.125
        EdgeSize(2)=-20
        WindowTitle="Avaliable Game Lengths"
        bHeaderCenter=true
        ID="LengthFrame"
    End Object    
    Components.Add(LengthFrame)    
    
    Begin Object Class=KFGUI_EditBox Name=CommandBox
        XPosition=0.15
        YPosition=0.88
        XSize=0.75
        YSize=0.02
        ToolTip="Add custom parameters to the open command"
        bNoClearOnEnter=true
        bDrawBackground=true
        ID="CommandBox"
    End Object    
    Components.Add(CommandBox)
    
    Begin Object Class=KFGUI_TextLable Name=CommandLabel
        XPosition=0.15
        YPosition=0.83
        XSize=0.75
        YSize=0.04
        FontScale=2
        Text="Custom Launch Parameters"
        ID="CommandLabel"
    End Object
    Components.Add(CommandLabel)
}