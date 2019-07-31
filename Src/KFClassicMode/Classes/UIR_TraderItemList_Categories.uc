class UIR_TraderItemList_Categories extends KFGUI_Frame;

var KFGUI_CategoryList SaleItemBox;

var ClassicPlayerController PC;
var KFAutoPurchaseHelper KFAPH;
var KFInventoryManager MyKFIM;
var UI_TraderMenu TraderMenu;

var float ButtonCooldown;
var int OldItemListLength;

function InitMenu()
{
    Super.InitMenu();
    
    PC = ClassicPlayerController(GetPlayer());
    TraderMenu = UI_TraderMenu(ParentComponent);
    KFAPH = PC.GetPurchaseHelper();
    
    SaleItemBox = KFGUI_CategoryList(FindComponentID('SaleItemBox'));
    SetupCategories();
}

function SetupCategories()
{
    local ClassicPerk_Base Perk;
    local string PerkID;
    
    SaleItemBox.AddCategory('ID_Favorite', "Favorites", Owner.CurrentStyle.FavoriteIcon, class'ClassicPerk_Base'.static.GetPerkColor(0), 1.f, 0.75f);
    foreach PC.PerkManager.UserPerks(Perk)
    {
        if( Perk.BasePerk != None )
            PerkID = string(Perk.BasePerk.Name);
        else PerkID = string(Perk.Class.Name);
        
        SaleItemBox.AddCategory(name("ID_"$PerkID), Perk.GetPerkName(), Perk.GetCurrentPerkIcon(0), Perk.GetPerkColor(0), 1.f, 0.75f);
    }
    SaleItemBox.AddCategory('ID_OffPerk', "No Perk", Texture2D(DynamicLoadObject(class'KFGFxObject_TraderItems'.default.OffPerkIconPath, class'Texture2D')), class'ClassicPerk_Base'.static.GetPerkColor(0), 1.f, 0.75f);
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
    local int i, j;
    local UIR_TraderSaleItems InvTab;
    local array<STraderItem> OnPerkWeapons, SecondaryWeapons;
    local ClassicPerk_Base Perk;
    local string PerkID;
    local STraderItem SortItem;
    
    if( PC.Pawn == None )
        return;

    foreach PC.PerkManager.UserPerks(Perk)
    {
        if( Perk.BasePerk != None )
            PerkID = string(Perk.BasePerk.Name);
        else PerkID = string(Perk.Class.Name);
        
        OnPerkWeapons.Length = 0;
        SecondaryWeapons.Length = 0;
        
        Items = KFGameReplicationInfo(PC.WorldInfo.GRI).TraderItems.SaleItems;
        for( i=0; i < Items.Length; i++ )
        {
            if ( IsItemFiltered(Items[i]) )
                continue;
            else
            {
                if(Items[i].AssociatedPerkClasses.Length > 0)
                {
                    switch (Items[i].AssociatedPerkClasses.Find(Perk.BasePerk))
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
            InvTab = UIR_TraderSaleItems(SaleItemBox.AddItemToCategory(name("ID_"$PerkID), class'UIR_TraderSaleItems'));
            InvTab.InitMenu();
            InvTab.ShowMenu();
            InvTab.SetBuyable(OnPerkWeapons[i]);
            InvTab.OnClicked = SaleItemDoClick;
            InvTab.OnDblClicked = DoPurchaseItem;
        }

        for (i = 0; i < SecondaryWeapons.Length; i++)
        {
            InvTab = UIR_TraderSaleItems(SaleItemBox.AddItemToCategory(name("ID_"$PerkID), class'UIR_TraderSaleItems'));
            InvTab.InitMenu();
            InvTab.ShowMenu();
            InvTab.SetBuyable(SecondaryWeapons[i]);
            InvTab.OnClicked = SaleItemDoClick;
            InvTab.OnDblClicked = DoPurchaseItem;
        }
    }
    
    UpdateNonePerkCategories();
    OldItemListLength = KFAPH.OwnedItemList.Length;
}

function UpdateNonePerkCategories()
{
    local int i, j, index;
    local array<STraderItem> Items;
    local array<STraderItem> OffPerkWeapons, FavoriteWeapons;
    local UIR_TraderSaleItems InvTab;
    local STraderItem SortItem;
    
    Items = KFGameReplicationInfo(PC.WorldInfo.GRI).TraderItems.SaleItems;
    for( i=0; i < Items.Length; i++ )
    {
        if( Items[i].AssociatedPerkClasses.Length <= 0 || Items[i].AssociatedPerkClasses[0] == None || Items[i].AssociatedPerkClasses.Find(class'KFPerk_Survivalist') != INDEX_NONE )
            OffPerkWeapons.AddItem(Items[i]);
        else
        {
            Index = PC.FavoriteWeaponClassNames.Find(Items[i].ClassName);
            if( Index != INDEX_NONE && !IsItemFiltered(Items[i]) )
                FavoriteWeapons.AddItem(Items[i]);
        }
    }
    
    for( i=(OffPerkWeapons.Length-1); i>0; --i )
    {
        for( j=i-1; j>=0; --j )
        {
            if( KFAPH.GetAdjustedBuyPriceFor(OffPerkWeapons[i]) < KFAPH.GetAdjustedBuyPriceFor(OffPerkWeapons[j]) )
            {
                SortItem = OffPerkWeapons[i];
                OffPerkWeapons[i] = OffPerkWeapons[j];
                OffPerkWeapons[j] = SortItem;
            }
        }
    }
    
    for( i=(FavoriteWeapons.Length-1); i>0; --i )
    {
        for( j=i-1; j>=0; --j )
        {
            if( KFAPH.GetAdjustedBuyPriceFor(FavoriteWeapons[i]) < KFAPH.GetAdjustedBuyPriceFor(FavoriteWeapons[j]) )
            {
                SortItem = FavoriteWeapons[i];
                FavoriteWeapons[i] = FavoriteWeapons[j];
                FavoriteWeapons[j] = SortItem;
            }
        }
    }
    
    for (i = 0; i < OffPerkWeapons.Length; i++)
    {
        InvTab = UIR_TraderSaleItems(SaleItemBox.AddItemToCategory('ID_OffPerk', class'UIR_TraderSaleItems'));
        InvTab.InitMenu();
        InvTab.ShowMenu();
        InvTab.SetBuyable(OffPerkWeapons[i]);
        InvTab.OnClicked = SaleItemDoClick;
        InvTab.OnDblClicked = DoPurchaseItem;
    }

    for (i = 0; i < FavoriteWeapons.Length; i++)
    {
        InvTab = UIR_TraderSaleItems(SaleItemBox.AddItemToCategory('ID_Favorite', class'UIR_TraderSaleItems'));
        InvTab.InitMenu();
        InvTab.ShowMenu();
        InvTab.SetBuyable(FavoriteWeapons[i]);
        InvTab.OnClicked = SaleItemDoClick;
        InvTab.OnDblClicked = DoPurchaseItem;
    }
}

function bool IsItemFiltered(STraderItem Item)
{
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
    if( KFAPH.OwnedItemList.Length != OldItemListLength || bForce )
    {
        SaleItemBox.EmptyList();
        UpdateBuyables();
        DeselectAll();
    }
}

defaultproperties
{
    bUseAnimation=false
    
    EdgeSize(0)=10
    EdgeSize(1)=45
    EdgeSize(2)=-18
    EdgeSize(3)=-55

    Begin Object class=KFGUI_CategoryList Name=SaleItemBox
        ID="SaleItemBox"
        ListItemsPerPage=10
    End Object
    Components.Add(SaleItemBox)
}