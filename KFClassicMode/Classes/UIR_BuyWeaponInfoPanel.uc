class UIR_BuyWeaponInfoPanel extends KFGUI_Frame;

var KFGUI_TextLable SelectedItemL,IName,LWeight,PowerCap,RangeCap,SpeedCap,SaleValue;
var KFGUI_Frame INameBG,LWeightBG,SaleValueBG;
var KFGUI_Button FavoriteB;
var KFGUI_Image ItemIcon;
var UIR_WeaponBar PowerBar,RangeBar,SpeedBar;

var SItemInformation CurrentInfo;

var string Weight;
var string FavoriteString;
var string UnfavoriteString;

var KFInventoryManager MyKFIM;
var ClassicPlayerController PC;

function InitMenu()
{
    Super.InitMenu();
    
    SelectedItemL = KFGUI_TextLable(FindComponentID('SelectedItemL'));
    
    IName = KFGUI_TextLable(FindComponentID('IName'));
    INameBG = KFGUI_Frame(FindComponentID('INameBG'));
    
    SaleValueBG = KFGUI_Frame(FindComponentID('SaleValueBG'));
    SaleValue = KFGUI_TextLable(FindComponentID('SaleValue'));
    
    PowerCap = KFGUI_TextLable(FindComponentID('PowerCap'));
    RangeCap = KFGUI_TextLable(FindComponentID('RangeCap'));
    SpeedCap = KFGUI_TextLable(FindComponentID('SpeedCap'));
    
    LWeight = KFGUI_TextLable(FindComponentID('LWeight'));
    LWeightBG = KFGUI_Frame(FindComponentID('LWeightBG'));
    
    FavoriteB = KFGUI_Button(FindComponentID('FavoriteB'));
    FavoriteB.GamepadButtonName = "XboxTypeS_RightThumbStick";
    FavoriteB.OnClickLeft = InternalOnClick;
    FavoriteB.OnClickRight = InternalOnClick;
    
    ItemIcon = KFGUI_Image(FindComponentID('ItemIcon'));
    
    PowerBar = UIR_WeaponBar(FindComponentID('PowerBar'));
    RangeBar = UIR_WeaponBar(FindComponentID('RangeBar'));
    SpeedBar = UIR_WeaponBar(FindComponentID('SpeedBar'));
    
    PowerBar.SetValue(0);
    PowerBar.SetVisibility(false);
    SpeedBar.SetValue(0);
    SpeedBar.SetVisibility(false);
    RangeBar.SetValue(0);
    RangeBar.SetVisibility(false);

    PowerCap.SetVisibility(false);
    RangeCap.SetVisibility(false);
    SpeedCap.SetVisibility(false);
}

function bool ReceievedControllerInput(int ControllerId, name Key, EInputEvent Event)
{
    switch(Key)
    {
        case 'XboxTypeS_RightThumbStick':
            if( Event == IE_Pressed )
            {
                GetPlayer().PlayAKEvent(AkEvent'WW_UI_Menu.Play_UI_Trader_Item_Favorite');
                FavoriteB.HandleMouseClick(false);
            }
            break;
    }
    
    return Super.ReceievedControllerInput(ControllerId, Key, Event);
}

function SetDisplay(SItemInformation NewBuyable)
{
    local Texture TraderIcon;
    local class<KFWeapon> Wep;
    local KFAutoPurchaseHelper KFAPH;
    
    KFAPH = PC.GetPurchaseHelper();
    
    if ( NewBuyable.DefaultItem == KFAPH.ArmorItem.DefaultItem || NewBuyable.DefaultItem == KFAPH.GrenadeItem.DefaultItem || NewBuyable.bIsSecondaryAmmo )
    {
        PowerBar.SetValue(0);
        PowerBar.SetVisibility(false);
        SpeedBar.SetValue(0);
        SpeedBar.SetVisibility(false);
        RangeBar.SetValue(0);
        RangeBar.SetVisibility(false);

        PowerCap.SetVisibility(false);
        RangeCap.SetVisibility(false);
        SpeedCap.SetVisibility(false);

        LWeight.SetVisibility(false);
        LWeightBG.SetVisibility(false);

        FavoriteB.SetVisibility(false);
    }
    else
    {    
        LWeight.SetVisibility(true);
        LWeightBG.SetVisibility(true);
        
        if( NewBuyable.DefaultItem.WeaponStats.Length <= 0 )
        {
            return;
        }
        
        PowerBar.SetValue(NewBuyable.DefaultItem.WeaponStats[TWS_Damage].StatValue);
        SpeedBar.SetValue(NewBuyable.DefaultItem.WeaponStats[TWS_RateOfFire].StatValue);
        RangeBar.SetValue(NewBuyable.DefaultItem.WeaponStats[TWS_Range].StatValue);

        PowerBar.SetVisibility(true);
        SpeedBar.SetVisibility(true);
        RangeBar.SetVisibility(true);

        PowerCap.SetVisibility(true);
        RangeCap.SetVisibility(true);
        SpeedCap.SetVisibility(true);
        
        if( KFAPH.IsInOwnedItemList(NewBuyable.DefaultItem.ClassName) || !KFAPH.IsSellable(NewBuyable.DefaultItem) )
        {
            FavoriteB.SetVisibility(false);
        }
        else
        {
            FavoriteB.SetVisibility(true);
        }

        RefreshFavoriteButton(PC.FavoriteWeaponClassNames.Find(NewBuyable.DefaultItem.ClassName) != INDEX_NONE);
    }
    
    if( NewBuyable.DefaultItem.WeaponDef != None )
    {
        Wep = class<KFWeapon>(DynamicLoadObject(NewBuyable.DefaultItem.WeaponDef.default.WeaponClassPath, class'Class'));
        if( Wep != None && Wep.default.SecondaryAmmoTexture != None && NewBuyable.bIsSecondaryAmmo )
        {
            TraderIcon = Wep.default.SecondaryAmmoTexture;
        }
        else
        {
            TraderIcon = Texture(DynamicLoadObject(NewBuyable.DefaultItem.WeaponDef.static.GetImagePath(), class'Texture'));
        }
        
        if( TraderIcon != None )
        {
            ItemIcon.Image = TraderIcon;
        }
        
        IName.SetText(NewBuyable.bIsSecondaryAmmo ? NewBuyable.DefaultItem.WeaponDef.static.GetItemLocalization("SecondaryAmmo") : NewBuyable.DefaultItem.WeaponDef.static.GetItemName());
        LWeight.SetText(Repl(Weight, "%i", MyKFIM.GetDisplayedBlocksRequiredFor( NewBuyable.DefaultItem )));
    }
    
    CurrentInfo = NewBuyable;
}

function RefreshFavoriteButton(bool bFavorite)
{
    FavoriteB.ButtonText = bFavorite ? UnfavoriteString : FavoriteString;
}

function DrawMenu()
{
    Super.DrawMenu();
    
    if( !bTextureInit )
    {
        GetStyleTextures();
    }
}

function ShowMenu()
{
    Super.ShowMenu();
    
    PC = ClassicPlayerController(GetPlayer());
    MyKFIM = KFInventoryManager(PC.Pawn.InvManager);
    
    SetTimer(0.05f, true);
    Timer();
}

function Timer()
{
    local KFAutoPurchaseHelper KFAPH;
    local UI_TraderMenu Trader;
    
    Trader = UI_TraderMenu(ParentComponent);
    if( Trader == None )
        return;
        
    KFAPH = PC.GetPurchaseHelper();
    if ( Trader.MyBuyable != Trader.default.MyBuyable && Trader.MyBuyable.bInventory && KFAPH.IsSellable(Trader.MyBuyable.Item) && !Trader.MyBuyable.bSecondary )
    {
        SaleValue.SetText("Sell Value: $" $ KFAPH.GetAdjustedSellPriceFor(Trader.MyBuyable.Item));
        SaleValue.bVisible = true;
    }
    else
    {
        SaleValue.bVisible = false;
    }
}

function InternalOnClick( KFGUI_Button Sender )
{
    local UI_TraderMenu Trader;
    local int Index;
    
    if( CurrentInfo == default.CurrentInfo )
        return;
        
    Trader = UI_TraderMenu(ParentComponent);
    if( Trader == None )
        return;
    
    switch( Sender.ID )
    {
        case 'FavoriteB':
            Index = PC.FavoriteWeaponClassNames.Find(CurrentInfo.DefaultItem.ClassName);
            if( Index != INDEX_NONE )
            {
                PC.FavoriteWeaponClassNames.Remove(Index, 1);
                PC.SaveConfig();
                
                RefreshFavoriteButton(false);
                Trader.Inv.RefreshItemComponents();
                Trader.Sale.RefreshItemComponents();
            }
            else
            {
                PC.FavoriteWeaponClassNames.AddItem(CurrentInfo.DefaultItem.ClassName);
                PC.SaveConfig();
                
                RefreshFavoriteButton(true);
                Trader.Inv.RefreshItemComponents();
                Trader.Sale.RefreshItemComponents();
            }
            break;
    }
}

function GetStyleTextures()
{
    if( !Owner.bFinishedReplication )
    {
        return;
    }
    
    INameBG.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT];
    LWeightBG.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT];
    
    bTextureInit = true;
}

defaultproperties
{
    bHeaderCenter=true
    
    Weight="Weight: %i blocks"
    FavoriteString="Favorite"
    UnfavoriteString="Un-favorite"
    WindowTitle="Selected Item Info"
    
    Begin Object Class=KFGUI_Image Name=IImage
        ID="ItemIcon"
         YPosition=0.113025
        XPosition=0.147005
        XSize=0.748718
        YSize=0.374359
        bAlignCenter=true
    End Object
    Components.Add(IImage)
    
    Begin Object Class=KFGUI_TextLable Name=IName
        ID="IName"
        YPosition=0.025236
        XPosition=0.035800
        XSize=0.928366
        YSize=0.070000
        Text=""
        AlignX=1
        FontScale=2
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    Components.Add(IName)

    Begin Object class=KFGUI_Frame Name=INameBG
        ID="INameBG"
        YPosition=0.02
        XPosition=0.035800
        XSize=0.928366
        YSize=0.105446
    End Object
    Components.Add(INameBG)
    
    Begin Object Class=KFGUI_TextLable Name=PowerCap
        ID="PowerCap"
        YPosition=0.488943
        XPosition=0.131552
        XSize=0.739260
        YSize=0.070000
        Text="Power:"
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    Components.Add(PowerCap)
    
    Begin Object Class=KFGUI_TextLable Name=RangeCap
        ID="RangeCap"
        YPosition=0.588943
        XPosition=0.131552
        XSize=0.739260
        YSize=0.070000
        Text="Range:"
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    Components.Add(RangeCap)
    
    Begin Object Class=KFGUI_TextLable Name=SpeedCap
        ID="SpeedCap"
        YPosition=0.688943
        XPosition=0.131552
        XSize=0.739260
        YSize=0.070000
        Text="Speed:"
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    Components.Add(SpeedCap)
    
    Begin Object Class=KFGUI_TextLable Name=LWeight
        ID="LWeight"
        YPosition=0.779874
        XPosition=0.058031
        XSize=0.885273
        YSize=0.093913
        Text="Weight: "
        AlignX=1
        FontScale=2
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    Components.Add(LWeight)

    Begin Object class=KFGUI_Frame Name=LWeightBG
        ID="LWeightBG"
        YPosition=0.773124
        XPosition=0.112600
        XSize=0.765905
        YSize=0.108400
    End Object
    Components.Add(LWeightBG)
    
    Begin Object Class=KFGUI_Button Name=FavoriteB
        ID="FavoriteB"
        ButtonText="Favorite"
        Tooltip=""
        YPosition=0.9
        XPosition=0.25
        XSize=0.5
        YSize=0.08
    End Object
    Components.Add(FavoriteB)
    
    Begin Object Class=UIR_WeaponBar Name=PowerBar
        ID="PowerBar"
        YPosition=0.488943
        XPosition=0.366433
        XSize=0.471784
        YSize=0.050000
        BorderSize=3.0
    End Object
    Components.Add(PowerBar)

    Begin Object Class=UIR_WeaponBar Name=RangeBar
        ID="RangeBar"
        Value=-5.000000
        YPosition=0.588943
        XPosition=0.366433
        XSize=0.471784
        YSize=0.050000
        BorderSize=3.0
        Low=0.f
        High=10.f
    End Object
    Components.Add(RangeBar)

    Begin Object Class=UIR_WeaponBar Name=SpeedBar
        ID="SpeedBar"
        YPosition=0.688943
        XPosition=0.366433
        XSize=0.471784
        YSize=0.050000
        BorderSize=3.0
    End Object
    Components.Add(SpeedBar)
    
    Begin Object Class=KFGUI_TextLable Name=SaleValue
        ID="SaleValue"
        YPosition=0.900183
        XPosition=0.337502
        XSize=0.325313
        YSize=0.059661
        AlignX=1
        AlignY=1
        FontScale=2
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    Components.Add(SaleValue)
}