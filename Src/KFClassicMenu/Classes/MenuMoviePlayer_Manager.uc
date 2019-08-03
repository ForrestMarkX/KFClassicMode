class MenuMoviePlayer_Manager extends ClassicMoviePlayer_Manager;

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    return Super(KFGFxMoviePlayer_Manager).WidgetInitialized(WidgetName, WidgetPath, Widget);
}

function TextureMovie GetBackgroundMovie()
{
    return TextureMovie'KFClassicMenu_Assets.MainMenu';
}

defaultproperties
{
    WidgetPaths.Remove("../UI_Widgets/PartyWidget_SWF.swf")
    WidgetPaths.Remove("../UI_Widgets/MenuBarWidget_SWF.swf")
    
    WidgetBindings.Remove((WidgetName="exitMenu",WidgetClass=class'KFGFxMenu_Exit'))
    WidgetBindings.Remove((WidgetName="postGameMenu",WidgetClass=class'KFGFxMenu_PostGameReport'))
    WidgetBindings.Remove((WidgetName="traderMenu",WidgetClass=class'KFGFxMenu_Trader'))
    WidgetBindings.Remove((WidgetName="ChatBoxWidget", WidgetClass=class'KFGFxHUD_ChatBoxWidget'))
    WidgetBindings.Remove((WidgetName="IISMenu", WidgetClass=class'KFGFxMenu_IIS'))
    WidgetBindings.Remove((WidgetName="gearMenu",WidgetClass=class'ClassicMenu_Gear'))
    WidgetBindings.Remove((WidgetName="startMenu",WidgetClass=class'KFGFxMenu_StartGame'))
    WidgetBindings.Remove((WidgetName="GammaPopup",WidgetClass=class'KFGFxPopup_Gamma'))
    WidgetBindings.Remove((WidgetName="ConnectionErrorPopup",WidgetClass=class'KFGFxPopup_ConnectionError'))
    
    WidgetBindings.Add((WidgetName="gearMenu",WidgetClass=class'GFXMenu_Gear_Entry'))
    WidgetBindings.Add((WidgetName="startMenu",WidgetClass=class'GFXMenu_Start_Entry'))
    WidgetBindings.Add((WidgetName="GammaPopup",WidgetClass=class'ClassicGFxPopup_Gamma'))
    WidgetBindings.Add((WidgetName="ConnectionErrorPopup",WidgetClass=class'ClassicGFxPopup_ConnectionError'))
}