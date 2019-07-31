class UI_NotifyQuit extends UI_NotifyDisconnect;

function ShowMenu()
{
    Super.ShowMenu();
    WindowTitle = class'KFGFxWidget_MenuBar'.default.TitleStrings[Rand(class'KFGFxWidget_MenuBar'.default.TitleStrings.Length)];
    InfoLabel.SetText(class'KFGFxWidget_MenuBar'.default.DescriptionStrings[Rand(class'KFGFxWidget_MenuBar'.default.DescriptionStrings.Length)]);  
}

function ButtonClicked( KFGUI_Button Sender )
{
    switch(Sender.ID)
    {
        case 'Yes':
            GetPlayer().ConsoleCommand("QUIT");
            return;
    }
    
    Super.ButtonClicked(Sender);
}

function CloseMenu()
{
    Super(KFGUI_FloatingWindow).CloseMenu();
}

defaultproperties
{
    XPosition=0.25
    XSize=0.5
}