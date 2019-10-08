class UIR_TraderItemList extends KFGUI_Frame;

var KFGUI_ComponentList SaleItemBox;

var ClassicPlayerController PC;
var KFInventoryManager MyKFIM;
var UI_TraderMenu TraderMenu;

var float ButtonCooldown;
var int OldItemListLength;

function InitMenu()
{
    Super.InitMenu();
    
    PC = ClassicPlayerController(GetPlayer());
    TraderMenu = UI_TraderMenu(ParentComponent);
    SaleItemBox = KFGUI_ComponentList(FindComponentID('SaleItemBox'));
    SaleItemBox.ScrollBar.YSize = 1.f;
}

function ShowMenu()
{
    Super.ShowMenu();
    
    MyKFIM = KFInventoryManager(GetPlayer().Pawn.InvManager);
    SetTimer(0.05f, true, nameOf(Refresh));
}

function UpdateBuyables()
{
    local array<STraderItem> Items;
    local int i,j,Index;
    local UIR_TraderSaleItems InvTab;
    local array<STraderItem> OnPerkWeapons, SecondaryWeapons;
    local STraderItem SortItem;
    local class<KFPerk> TargetPerkClass;
    local KFAutoPurchaseHelper KFAPH;
    local bool bUseFavs,bUseOffPerk;
    
    if( PC.Pawn == None )
        return;
        
    KFAPH = PC.GetPurchaseHelper();
        
    if( TraderMenu.CurrentPerkInfo.bIsFavorites )
    {
        bUseFavs = true;
    }
    else if( TraderMenu.CurrentPerkInfo.bIsOffPerk )
    {
        bUseOffPerk = true;
    }
    else
    {
        TargetPerkClass = TraderMenu.CurrentPerkInfo.PerkClass;
    }

    Items = KFGameReplicationInfo(PC.WorldInfo.GRI).TraderItems.SaleItems;
    for( i=0; i < Items.Length; i++ )
    {
        if( bUseFavs )
        {
            Index = PC.FavoriteWeaponClassNames.Find(Items[i].ClassName);
            if( Index != INDEX_NONE && !IsItemFiltered(Items[i]) )
            {
                OnPerkWeapons.AddItem(Items[i]);
            }
            
            continue;
        }
        else if( bUseOffPerk )
        {
            if( Items[i].AssociatedPerkClasses.Length <= 0 || Items[i].AssociatedPerkClasses[0] == None || Items[i].AssociatedPerkClasses.Find(class'KFPerk_Survivalist') != INDEX_NONE )
            {
                OnPerkWeapons.AddItem(Items[i]);
            }
            
            continue;
        }
        else if ( IsItemFiltered(Items[i]) )
        {
            continue;
        }
        else
        {
            if(Items[i].AssociatedPerkClasses.Length > 0)
            {
                switch (Items[i].AssociatedPerkClasses.Find(TargetPerkClass))
                {
                    case 0:
                        OnPerkWeapons.AddItem(Items[i]);
                        break;
                
                    case 1:
                        SecondaryWeapons.AddItem(Items[i]);
                        break;
                }
            }
        }
    }
    
    for( i=(OnPerkWeapons.Length-1); i>0; --i )
    {
        for( j=i-1; j>=0; --j )
        {
            if( KFAPH.GetAdjustedBuyPriceFor(OnPerkWeapons[i]) < KFAPH.GetAdjustedBuyPriceFor(OnPerkWeapons[j]) )
            {
                SortItem = OnPerkWeapons[i];
                OnPerkWeapons[i] = OnPerkWeapons[j];
                OnPerkWeapons[j] = SortItem;
            }
        }
    }
    
    for( i=(SecondaryWeapons.Length-1); i>0; --i )
    {
        for( j=i-1; j>=0; --j )
        {
            if( KFAPH.GetAdjustedBuyPriceFor(SecondaryWeapons[i]) < KFAPH.GetAdjustedBuyPriceFor(SecondaryWeapons[j]) )
            {
                SortItem = SecondaryWeapons[i];
                SecondaryWeapons[i] = SecondaryWeapons[j];
                SecondaryWeapons[j] = SortItem;
            }
        }
    }
    
    for (i = 0; i < OnPerkWeapons.Length; i++)
    {
        InvTab = UIR_TraderSaleItems(SaleItemBox.AddListComponent(class'UIR_TraderSaleItems'));
        InvTab.InitMenu();
        InvTab.ShowMenu();
        InvTab.SetBuyable(OnPerkWeapons[i]);
        InvTab.OnClicked = SaleItemDoClick;
        InvTab.OnDblClicked = DoPurchaseItem;
    }

    for (i = 0; i < SecondaryWeapons.Length; i++)
    {
        InvTab = UIR_TraderSaleItems(SaleItemBox.AddListComponent(class'UIR_TraderSaleItems'));
        InvTab.InitMenu();
        InvTab.ShowMenu();
        InvTab.SetBuyable(SecondaryWeapons[i]);
        InvTab.OnClicked = SaleItemDoClick;
        InvTab.OnDblClicked = DoPurchaseItem;
    }
    
    OldItemListLength = KFAPH.OwnedItemList.Length;
}

function bool IsItemFiltered(STraderItem Item)
{
    local KFAutoPurchaseHelper KFAPH;
    KFAPH = PC.GetPurchaseHelper();
       return KFAPH.IsInOwnedItemList(Item.ClassName) || KFAPH.IsInOwnedItemList(Item.DualClassName) || !KFAPH.IsSellable(Item);
}

function UIR_TraderSaleItems GetSelectedItem()
{
    local int i;
    
    for( i=SaleItemBox.ItemComponents.Length - 1; i>=0; i-- )
    {
        if( UIR_TraderSaleItems(SaleItemBox.ItemComponents[i]).bSelected )
            return UIR_TraderSaleItems(SaleItemBox.ItemComponents[i]);
    }
    
    return None;
}

function bool ReceievedControllerInput(int ControllerId, name Key, EInputEvent Event)
{
    local UIR_TraderSaleItems Item;
    
    Item = GetSelectedItem();
    if( Item == None )
        return false;
        
    switch(Key)
    {
        case 'XboxTypeS_Y':
            if( Event == IE_Pressed )
            {
                DoPurchaseItem(Item, false, 0, 0);
            }
            break;
    }
    
    return Super.ReceievedControllerInput(ControllerId, Key, Event);
}

function DeselectAll()
{
    local int i;
    local UIR_TraderSaleItems Inv;
    
    for(i=0; i < SaleItemBox.ItemComponents.Length; i++)
    {
        Inv = UIR_TraderSaleItems(SaleItemBox.ItemComponents[i]);
        if( Inv != None && Inv.bSelected )
            Inv.bSelected = false;
    }    
    
    for(i=0; i < Components.Length; i++)
    {
        Inv = UIR_TraderSaleItems(Components[i]);
        if( Inv != None && Inv.bSelected )
            Inv.bSelected = false;
    }
}

function RefreshItemComponents()
{
    local int i;
    local UIR_TraderSaleItems Inv;
    
    for(i=0; i < SaleItemBox.ItemComponents.Length; i++)
    {
        Inv = UIR_TraderSaleItems(SaleItemBox.ItemComponents[i]);
        if( Inv != None )
            Inv.Refresh();
    }    
    
    for(i=0; i < Components.Length; i++)
    {
        Inv = UIR_TraderSaleItems(Components[i]);
        if( Inv != None )
            Inv.Refresh();
    }
}

function DoPurchaseItem( UIR_ItemBase Sender, bool bRight, int MouseX, int MouseY )
{
    local KFAutoPurchaseHelper KFAPH;
    
    KFAPH = PC.GetPurchaseHelper();
    if( KFAPH.bCanPurchase(Sender.Buyable) && ButtonCooldown < GetPlayer().WorldInfo.TimeSeconds )
    {
        ButtonCooldown = GetPlayer().WorldInfo.TimeSeconds + 0.25;
        
        KFAPH.PurchaseWeapon(Sender.Buyable);
        TraderMenu.Refresh();
        
        TraderMenu.Inv.RefreshItemComponents();
        RefreshItemComponents();
        
        TraderMenu.Inv.DeselectAll();
        DeselectAll();
        
        TraderMenu.BuyWeaponInfoPanel.ResetValues();
        TraderMenu.MyBuyable = TraderMenu.default.MyBuyable;
        
        TraderMenu.IScrollText.SetText(TraderMenu.InfoText[0]);
        TraderMenu.WeightB.NewBoxes = 0;
        TraderMenu.bDidBuyableUpdate = true;
        
        PC.PlayAKEvent(AkEvent'WW_UI_Menu.Play_TRADER_BUY_WEAPON');
    }
}

function SaleItemDoClick( UIR_ItemBase Sender, bool bRight, int MouseX, int MouseY )
{
    local SBuyableInfo Info;
    local SItemInformation Item;
    local KFAutoPurchaseHelper KFAPH;
    
    KFAPH = PC.GetPurchaseHelper();
    TraderMenu.MyBuyable = TraderMenu.default.MyBuyable;
    
    TraderMenu.Inv.DeselectAll();
    DeselectAll();
    
    Sender.bSelected = true;
    TraderMenu.CurrentSelectedComp = Sender;
    
    Item.DefaultItem = TraderMenu.CreateItem(Sender.Buyable.WeaponDef);
    
    Info.Item = Sender.Buyable;
    Info.bInventory = KFAPH.DoIOwnThisWeapon(Sender.Buyable);
    
    TraderMenu.MyBuyable = Info;
    TraderMenu.CurrentItem = TraderMenu.default.CurrentItem;
    TraderMenu.BuyWeaponInfoPanel.SetDisplay(Item);
}

function Refresh(optional bool bForce)
{
    local KFAutoPurchaseHelper KFAPH;
    
    KFAPH = PC.GetPurchaseHelper();
    if( KFAPH.OwnedItemList.Length != OldItemListLength || bForce )
    {
        SaleItemBox.EmptyList();
        UpdateBuyables();
        DeselectAll();
    }
}

defaultproperties
{
    EdgeSize(0)=10
    EdgeSize(1)=45
    EdgeSize(2)=-18
    EdgeSize(3)=-55
    
    Begin Object class=KFGUI_ComponentList Name=SaleItemBox
        ID="SaleItemBox"
        ListItemsPerPage=10
    End Object
    Components.Add(SaleItemBox)
}