class ClassicTraderContainer_Store extends KFGFxTraderContainer_Store;

function RefreshWeaponListByPerk(byte FilterIndex, const out array<STraderItem> ItemList)
{
	local int i, SlotIndex;
	local GFxObject ItemDataArray; // This array of information is sent to ActionScript to update the Item data
	local array<STraderItem> OnPerkWeapons, SecondaryWeapons, OffPerkWeapons;
	local class<KFPerk> TargetPerkClass;

	if ( KFPC!=None )
	{
		TargetPerkClass = class<ClassicPerk_Base>(KFPC.PerkList[FilterIndex].PerkClass).default.BasePerk;

		SlotIndex = 0;
	    ItemDataArray = CreateArray();

		for (i = 0; i < ItemList.Length; i++)
		{
			if ( IsItemFiltered(ItemList[i]) )
			{
				continue; // Skip this item if it's in our inventory
			}
			else if ( ItemList[i].AssociatedPerkClasses.length > 0 && ItemList[i].AssociatedPerkClasses[0] != none && TargetPerkClass != class'KFPerk_Survivalist'
				&& (TargetPerkClass==None || ItemList[i].AssociatedPerkClasses.Find(TargetPerkClass) == INDEX_NONE ) )
			{
				continue; // filtered by perk
			}
			else
			{
				if(ItemList[i].AssociatedPerkClasses.length > 0)
				{
					switch (ItemList[i].AssociatedPerkClasses.Find(TargetPerkClass))
					{
						case 0: //primary perk
							OnPerkWeapons.AddItem(ItemList[i]);
							break;
					
						case 1: //secondary perk
							SecondaryWeapons.AddItem(ItemList[i]);
							break;
					
						default: //off perk
							OffPerkWeapons.AddItem(ItemList[i]);
							break;
					}
				}
			}
		}

		for (i = 0; i < OnPerkWeapons.length; i++)
		{
			SetItemInfo(ItemDataArray, OnPerkWeapons[i], SlotIndex);
			SlotIndex++;	
		}

		for (i = 0; i < SecondaryWeapons.length; i++)
		{
			SetItemInfo(ItemDataArray, SecondaryWeapons[i], SlotIndex);
			SlotIndex++;
		}

		for (i = 0; i < OffPerkWeapons.length; i++)
		{
			SetItemInfo(ItemDataArray, OffPerkWeapons[i], SlotIndex);
			SlotIndex++;
		}		

		SetObject("shopData", ItemDataArray);
	}
}

function SetItemInfo(out GFxObject ItemDataArray, STraderItem TraderItem, int SlotIndex)
{
	local GFxObject SlotObject;
	local ClassicPerk_Base Perk;
	local ClassicPerkManager PerkManager;
	local string ItemTexPath;
	local string IconPath;
	local string SecondaryIconPath;
	local bool bCanAfford, bCanCarry;
	local int AdjustedBuyPrice, ItemUpgradeLevel, i;
	
	PerkManager = ClassicPlayerController(GetPC()).PerkManager;
	if( PerkManager == None )
		return;

	SlotObject = CreateObject( "Object" );

	ItemTexPath = "img://"$TraderItem.WeaponDef.static.GetImagePath();
	if( TraderItem.AssociatedPerkClasses.length > 0 && TraderItem.AssociatedPerkClasses[0] != none)
	{
		for( i=0; i<PerkManager.UserPerks.Length; ++i )
		{
			if( PerkManager.UserPerks[i].BasePerk == TraderItem.AssociatedPerkClasses[0] )
			{
				Perk = PerkManager.UserPerks[i];
				break;
			}
		}
		
		if( Perk != None )
		{
			IconPath = "img://"$PathName(Perk.static.GetCurrentPerkIcon(Perk.GetLevel()));
			if( TraderItem.AssociatedPerkClasses.length > 1 )
			{
				for( i=0; i<PerkManager.UserPerks.Length; ++i )
				{
					if( PerkManager.UserPerks[i].BasePerk == TraderItem.AssociatedPerkClasses[1] )
					{
						Perk = PerkManager.UserPerks[i];
						break;
					}
				}
		
				if( Perk != None )
				{
					SecondaryIconPath = "img://"$PathName(Perk.static.GetCurrentPerkIcon(Perk.GetLevel()));
				}
			}
		}
	}
	else
	{
		IconPath = "img://"$class'KFGFxObject_TraderItems'.default.OffPerkIconPath;
	}
	SlotObject.SetString("buyText", Localize("KFGFxTraderContainer_ItemDetails", "BuyString", "KFGame"));

	SlotObject.SetInt("itemID", TraderItem.ItemID);
	SlotObject.SetString("weaponSource", ItemTexPath);
	SlotObject.SetString( "perkIconSource", IconPath );
	SlotObject.SetString( "perkSecondaryIconSource", SecondaryIconPath );

	SlotObject.SetString( "weaponName", TraderItem.WeaponDef.static.GetItemName() );
	SlotObject.SetString( "weaponType", TraderItem.WeaponDef.static.GetItemCategory() );

	ItemUpgradeLevel = TraderItem.SingleClassName != '' ?
		KFPC.GetPurchaseHelper().GetItemUpgradeLevelByClassName(TraderItem.SingleClassName) :
		INDEX_None;
	SlotObject.SetInt("weaponWeight", MyTraderMenu.GetDisplayedBlocksRequiredFor(TraderItem, ItemUpgradeLevel));

	AdjustedBuyPrice = KFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(TraderItem);

	SlotObject.SetInt( "weaponCost",  AdjustedBuyPrice );

	bCanAfford = KFPC.GetPurchaseHelper().GetCanAfford(AdjustedBuyPrice);
	bCanCarry = KFPC.GetPurchaseHelper().CanCarry(TraderItem, ItemUpgradeLevel);

	SlotObject.SetBool("bCanAfford", bCanAfford);
	SlotObject.SetBool("bCanCarry", bCanCarry);
	
	ItemDataArray.SetElementObject( SlotIndex, SlotObject );
}
