class ClassicMenu_Trader extends KFGFxMenu_Trader;

var ClassicPlayerController ClassicKFPC;

function OnOpen()
{
    Super.OnOpen();

    if( ClassicKFPC == None )
        ClassicKFPC = ClassicPlayerController(MyKFPC);
}

function Callback_PerkChanged(int PerkIndex)
{
    if( MyKFPRI.NetPerkIndex != PerkIndex )
    {
        ClassicKFPC.ServerChangePerks(ClassicKFPC.PerkManager.FindPerk(MyKFPC.PerkList[PerkIndex].PerkClass));
        
        if( ClassicKFPC.CanUpdatePerkInfoEx() )
        {
            ClassicKFPC.SetHaveUpdatePerk(true);
        }
    }
        
    if( PlayerInventoryContainer != none )
    {
        PlayerInventoryContainer.UpdateLock();
    }
    UpdatePlayerInfo();

    // Refresh the UI
    RefreshItemComponents();
}

defaultproperties
{
    SubWidgetBindings.Remove((WidgetName="filterContainer",WidgetClass=class'KFGFxTraderContainer_Filter'))
    SubWidgetBindings.Add((WidgetName="filterContainer",WidgetClass=class'ClassicTraderContainer_Filter'))
    
    SubWidgetBindings.Remove((WidgetName="playerInfoContainer",WidgetClass=class'KFGFxTraderContainer_PlayerInfo'))
    SubWidgetBindings.Add((WidgetName="playerInfoContainer",WidgetClass=class'ClassicTraderContainer_PlayerInfo'))
    
    SubWidgetBindings.Remove((WidgetName="shopContainer",WidgetClass=class'KFGFxTraderContainer_Store'))
    SubWidgetBindings.Add((WidgetName="shopContainer",WidgetClass=class'ClassicTraderContainer_Store'))
    
    SubWidgetBindings.Remove((WidgetName="itemDetailsContainer",WidgetClass=class'KFGFxTraderContainer_ItemDetails'))
    SubWidgetBindings.Add((WidgetName="itemDetailsContainer",WidgetClass=class'ClassicTraderContainer_ItemDetails'))
}