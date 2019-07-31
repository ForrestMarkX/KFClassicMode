class UIR_VoiceComms extends KFGUI_MultiComponent;

var KFGUI_List VoiceOptions;
var array<Texture2D> VoiceIcons;

var KFPlayerController PC;

function InitMenu()
{
    local int i;
    local array<string> IconPaths;
    
    Super.InitMenu();
    
    VoiceOptions = KFGUI_List(FindComponentID('VoiceOptions'));
    VoiceOptions.OnDrawItem = DrawVoiceOption;    
    VoiceOptions.ChangeListSize(10);
    
    IconPaths = class'KFGFxWidget_VoiceComms'.default.IconPaths;
    for( i=0; i<IconPaths.Length; i++ )
    {
        VoiceIcons.AddItem(Texture2D(DynamicLoadObject(IconPaths[i], class'Texture2D')));
    }
    
    PC = KFPlayerController(GetPlayer());
}

function DrawVoiceOption( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local float XL,YL,BorderSize,OriginalFontScalar,TextXOffset,TextYOffset,SubBoxH;
    local Color MainColor;
    local KFPawn KFP;
    
    YOffset *= 1.05;
    BorderSize = Owner.HUDOwner.ScaledBorderSize * 2;
    
    if( Index == VCT_EMOTE && PC != None )
    {
        KFP = KFPawn(PC.Pawn);
        if( KFP != None && ClassicPlayerController(PC).SelectedEmoteIndex != INDEX_NONE && KFP.CanDoSpecialMove(SM_Emote) )
        {
            MainColor = MakeColor(255, 255, 255, 255);
        }
        else
        {
            MainColor = MakeColor(120, 120, 120, 255);
        }
    }
    else
    {
        MainColor = MakeColor(255, 255, 255, 255);
    }
    
    Owner.CurrentStyle.DrawRoundedBoxOutlined(Owner.HUDOwner.ScaledBorderSize, 0, YOffset, Height, Height, HUDOwner.HudMainColor, HUDOwner.HudOutlineColor);

    C.DrawColor = MainColor;
    C.SetPos((Height/2) - ((Height - (BorderSize*2))/2), YOffset + (Height/2) - ((Height - (BorderSize*2))/2) - 1);
    C.DrawTile(VoiceIcons[Index], Height - (BorderSize*2), Height - (BorderSize*2), 0, 0, VoiceIcons[Index].SizeX * 2, VoiceIcons[Index].SizeY * 2);
    
    SubBoxH = Owner.CurrentStyle.DefaultHeight + (BorderSize*2);
    
    Owner.CurrentStyle.DrawRoundedBoxOutlinedEx(Owner.HUDOwner.ScaledBorderSize, Height-Owner.HUDOwner.ScaledBorderSize, YOffset + (Height/2) - (SubBoxH/2), Width-Height-Owner.HUDOwner.ScaledBorderSize, SubBoxH, HUDOwner.HudMainColor, HUDOwner.HudOutlineColor, false, true, false, true);
    
    C.Font = Owner.CurrentStyle.PickFont(OriginalFontScalar);
    C.TextSize("ABC", XL, YL, OriginalFontScalar, OriginalFontScalar);
    
    TextXOffset = (Height/2) + (XL/2) + (BorderSize * 2);
    TextYOffset = YOffset + (Height/2) - (YL/2) - (Owner.HUDOwner.ScaledBorderSize/2);
    
    C.DrawColor = MainColor;
    C.SetPos(TextXOffset, TextYOffset);
    C.DrawText("["@Index@"]"@class'KFLocalMessage_VoiceComms'.default.VoiceCommsOptionStrings[Index],, OriginalFontScalar, OriginalFontScalar);
}

function bool NotifyInputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed, bool bGamepad )
{
    local int Index;
    
    if( Event == IE_Pressed )
    {
        switch(Key)
        {
            case 'Zero':
                Index = 0;
                break;
            case 'One':
                Index = 1;
                break;
            case 'Two':
                Index = 2;
                break;
            case 'Three':
                Index = 3;
                break;
            case 'Four':
                Index = 4;
                break;
            case 'Five':
                Index = 5;
                break;
            case 'Six':
                Index = 6;
                break;
            case 'Seven':
                Index = 7;
                break;
            case 'Eight':
                Index = 8;
                break;
            case 'Nine':
                Index = 9;
                break;
            default:
                return false;
        }
        
        SayVoiceCommms(Index);
        PlayMenuSound(MN_ClickButton);
        SetVisibility(false);
        
        return true;
    }
    
    return Super.NotifyInputKey(ControllerId, Key, Event, AmountDepressed, bGamepad);
}

function SayVoiceCommms(int CommsIndex)
{    
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(GetPlayer());
    if( KFPC == None )
    {
        return;
    }

    if( CommsIndex == VCT_EMOTE )
    {
        KFPC.DoEmote();
        return;
    }
    
    KFPC.ServerPlayVoiceCommsDialog(CommsIndex);
}

function SetVisibility(bool Visible)
{
    Super.SetVisibility(Visible);
    
    if( Visible )
        PlayMenuSound(MN_Dropdown);
}

defaultproperties
{
    XPosition=0.825
    YPosition=0.25
    XSize=0.15
    YSize=0.45
    
    Begin Object Class=KFGUI_List Name=VoiceOptions
        ID="VoiceOptions"
        bHideScrollbar=true
        XSize=1
        YSize=1
        ListItemsPerPage=10
    End Object
    Components.Add(VoiceOptions)
}