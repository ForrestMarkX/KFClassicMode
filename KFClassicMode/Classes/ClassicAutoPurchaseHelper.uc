class ClassicAutoPurchaseHelper extends KFAutoPurchaseHelper within ClassicPlayerController
    dependson(ClassicInventoryManager);

final function class<KFPerk> GetBasePerk()
{
    return CurrentPerk!=None ? ClassicPerk_Base(CurrentPerk).BasePerk : None;
}

function DoAutoPurchase()
{
    local int PotentialDosh, i;
    local Array <STraderItem> OnPerkWeapons;
    local STraderItem TopTierWeapon;
    local int ItemIndex;
    local bool bSecondaryWeaponPurchased;
    local bool bAutoFillPurchasedItem;
    local string AutoFillMessageString;
    local class<KFPerk> BasePerk;

    GetTraderItems();

    BasePerk = GetBasePerk();
    if(BasePerk.default.AutoBuyLoadOutPath.length == 0)
    {
        `log("!!!Autobuy load out path not set!!!");
        return;
    }

    for (i = 0; i < BasePerk.default.AutoBuyLoadOutPath.length; i++)
    {
        ItemIndex = TraderItems.SaleItems.Find('WeaponDef', BasePerk.default.AutoBuyLoadOutPath[i]);
        if(ItemIndex != INDEX_NONE)
        {
            OnPerkWeapons.AddItem(TraderItems.SaleItems[ItemIndex]);
        }
    }

    SellOffPerkWeapons();

    TopTierWeapon = GetTopTierWeapon(OnPerkWeapons);
    if(!DoIOwnThisWeapon(TopTierWeapon) && GetCanAfford( GetAdjustedBuyPriceFor(TopTierWeapon) + DoshBuffer ) && CanCarry( TopTierWeapon ) )
    {
        AttemptUpgrade(TotalDosh, OnPerkWeapons, true);
    }
    else
    {
        PotentialDosh = GetPotentialDosh();
        AttemptUpgrade(PotentialDosh+TotalDosh, OnPerkWeapons);
    }

    bAutoFillPurchasedItem = StartAutoFill();
    if(DoIOwnThisWeapon(TopTierWeapon))
    {
        while(AttemptToPurchaseNextLowerTier(TotalDosh, OnPerkWeapons))
        {
            bSecondaryWeaponPurchased = true;
            AttemptToPurchaseNextLowerTier(TotalDosh, OnPerkWeapons);
        }
    }

    MyKFIM.ServerCloseTraderMenu();

    if(bSecondaryWeaponPurchased)
    {
        AutoFillMessageString = class'KFCommon_LocalizedStrings'.default.SecondaryWeaponPurchasedString;
    }
    else if(bAutoFillPurchasedItem)
    {
        AutoFillMessageString = class'KFCommon_LocalizedStrings'.default.AutoFillCompleteString;
    }
    else
    {
        AutoFillMessageString = class'KFCommon_LocalizedStrings'.default.NoItemsPurchasedString;
    }

    if(MyGFxHUD != none)
    {
        MyGFxHUD.ShowNonCriticalMessage( class'KFCommon_LocalizedStrings'.default.AutoTradeCompleteString$AutoFillMessageString );
    }
}

function SellOnPerkWeapons()
{
    local int i;
    local class<KFPerk> Perk;
    
    Perk = GetBasePerk();
    if( Perk!=None )
    {
        for (i = 0; i < OwnedItemList.length; i++)
        {
            if( OwnedItemList[i].DefaultItem.AssociatedPerkClasses.Find(Perk)!=INDEX_NONE && OwnedItemList[i].DefaultItem.BlocksRequired != -1)
            {
                SellWeapon(OwnedItemList[i], i);
                i=-1;
            }
        }
    }
}

function int AddItemByPriority( out SItemInformation WeaponInfo )
{
    local byte i;
    local byte WeaponGroup, WeaponPriority;
    local byte BestIndex;
    local class<KFPerk> Perk;
    
    Perk = GetBasePerk();

    BestIndex = 0;
    WeaponGroup = WeaponInfo.DefaultItem.InventoryGroup;
    WeaponPriority = WeaponInfo.DefaultItem.GroupPriority;

    for( i = 0; i < OwnedItemList.length; i++ )
    {
        // If the weapon belongs in the group prior to the current weapon, we've found the spot
        if( WeaponGroup < OwnedItemList[i].DefaultItem.InventoryGroup )
        {
            BestIndex = i;
            break;
        }
        else if( WeaponGroup == OwnedItemList[i].DefaultItem.InventoryGroup )
        {
            if( WeaponPriority > OwnedItemList[i].DefaultItem.GroupPriority )
            {
                // if the weapon is in the same group but has a higher priority, we've found the spot
                BestIndex = i;
                break;
            }
            else if( WeaponPriority == OwnedItemList[i].DefaultItem.GroupPriority && WeaponInfo.DefaultItem.AssociatedPerkClasses.Find(Perk)>=0 )
            {
                // if the weapons have the same priority give the slot to the on perk weapon
                BestIndex = i;
                break;
            }
        }
        else
        {
            // Covers the case if this weapon is the only item in the last group
            BestIndex = i + 1;
        }
    }
    OwnedItemList.InsertItem( BestIndex, WeaponInfo );

    // Add secondary ammo immediately after the main weapon
    if( WeaponInfo.DefaultItem.WeaponDef.static.UsesSecondaryAmmo() )
       {
           WeaponInfo.bIsSecondaryAmmo = true;
        WeaponInfo.SellPrice = 0;
        OwnedItemList.InsertItem( BestIndex + 1, WeaponInfo );
       }

    if( MyGfxManager != none && MyGfxManager.TraderMenu != none )
    {
        MyGfxManager.TraderMenu.OwnedItemList = OwnedItemList;
    }

       return BestIndex;
}

function RemoveWeaponFromOwnedItemList( optional int OwnedListIdx = INDEX_NONE, optional name ClassName, optional bool bDoNotSell )
{
    local SItemInformation ItemInfo;
    local byte ItemIndex;
    local int SingleOwnedIndex;
    local ClassicInventoryManager CIM;

    if( OwnedListIdx == INDEX_NONE && ClassName != '' )
    {
        for( OwnedListIdx = 0; OwnedListIdx < OwnedItemList.length; ++OwnedListIdx )
        {
            if( OwnedItemList[OwnedListIdx].DefaultItem.ClassName == ClassName )
            {
                break;
            }
        }
    }

    if( OwnedListIdx >= OwnedItemList.length )
    {
        return;
    }

    ItemInfo = OwnedItemList[OwnedListIdx];

    if( !bDoNotSell )
    {
        TraderItems.GetItemIndicesFromArche( ItemIndex, ItemInfo.DefaultItem.ClassName );
        MyKFIM.ServerSellWeapon(ItemIndex);
    }
    else
    {
        TraderItems.GetItemIndicesFromArche( ItemIndex, ItemInfo.DefaultItem.ClassName );
        MyKFIM.ServerRemoveTransactionItem( ItemIndex );
        AddBlocks( -ItemInfo.DefaultItem.BlocksRequired );
    }

    if( OwnedItemList[OwnedListIdx].bIsSecondaryAmmo )
    {
        OwnedItemList.Remove( OwnedListIdx, 1 );
        if( OwnedListIdx - 1 >= 0 )
        {
            OwnedItemList.Remove( OwnedListIdx - 1, 1 );
        }
    }

    else if( OwnedItemList[OwnedListIdx].DefaultItem.WeaponDef.static.UsesSecondaryAmmo() )
    {
        if( OwnedListIdx + 1 < OwnedItemList.Length )
        {
            OwnedItemList.Remove( OwnedListIdx + 1, 1 );
            OwnedItemList.Remove( OwnedListIdx, 1 );
        }
    }
    else
    {
        OwnedItemList.Remove( OwnedListIdx, 1 );
    }

    if( ItemInfo.DefaultItem.SingleClassName != '' )
    {
        if( TraderItems.GetItemIndicesFromArche( ItemIndex, ItemInfo.DefaultItem.SingleClassName) )
        {
            SingleOwnedIndex = AddWeaponToOwnedItemList( TraderItems.SaleItems[ItemIndex], true );
            OwnedItemList[SingleOwnedIndex].SpareAmmoCount = ItemInfo.SpareAmmoCount - (ItemInfo.MaxSpareAmmo / 2.0) + ((ItemInfo.MaxSpareAmmo / 2.0) - OwnedItemList[SingleOwnedIndex].SpareAmmoCount);
        }
    }

    if( MyGfxManager != none && MyGfxManager.TraderMenu != none )
    {
        MyGfxManager.TraderMenu.OwnedItemList = OwnedItemList;
    }
    
    CIM = ClassicInventoryManager(MyKFIM);
    if( CIM != None )
    {
        CIM.ServerRemoveSavedItem(ItemInfo.DefaultItem);
    }
}

function int AddWeaponToOwnedItemList( STraderItem DefaultItem, optional bool bDoNotBuy, optional int OverrideItemUpgradeLevel = INDEX_NONE )
{
    local ClassicInventoryManager CIM;
    
    CIM = ClassicInventoryManager(MyKFIM);
    if( CIM != None )
    {
        CIM.ServerAddSavedItem(DefaultItem);
    }
    
    return Super.AddWeaponToOwnedItemList(DefaultItem, bDoNotBuy, OverrideItemUpgradeLevel);
}

function bool CanCarry( const out STraderItem Item, optional int OverrideLevelValue = INDEX_NONE )
{
    local int Result;

    Result = TotalBlocks + MyKFIM.GetDisplayedBlocksRequiredFor(Item);
    if( Result>MaxBlocks )
    {
        return false;
    }
    return true;
}

simulated function UpdateCurrentDosh()
{
    Super.UpdateCurrentDosh();
    
    if( Outer.TraderMenu != None )
    {
        Outer.TraderMenu.Inv.RefreshItemComponents();
        Outer.TraderMenu.Sale.RefreshItemComponents();
    }
}

defaultproperties
{
}