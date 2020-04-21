class ClassicMenu_Inventory extends KFGFxMenu_Inventory;

function InitInventory()
{
	local int i, ItemIndex, HelperIndex;
	local ItemProperties TempItemDetailsHolder;
	local GFxObject ItemArray, ItemObject;
	local bool bActiveItem;
	local array<InventoryHelper> ActiveItems;
	local InventoryHelper HelperItem;
	local array<ExchangeRuleSets> ExchangeRules;
    local array<HeadshotEffectEx> FXIDs;

	local GFxObject PendingItem;

	ItemArray = CreateArray();

	if(OnlineSub == none)
	{
		// If there is no OnlineSubsystem just send an empty array.  HSL_BB
		SetObject("inventoryList", ItemArray);
		return;
	}
	for (i = 0; i < OnlineSub.CurrentInventory.length; i++)
	{
		//look item up to get info on it.
		ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', OnlineSub.CurrentInventory[i].Definition);

		// BWJ - 12-21-16 - Hide items that have no definition
		if(ItemIndex != INDEX_NONE && OnlineSub.CurrentInventory[i].Definition != 0 )
		{
			TempItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
            if( TempItemDetailsHolder.Type == ITP_SFX )
                continue;

			if (((CurrentInventoryFilter == EInv_All || Int(CurrentInventoryFilter) == Int(TempItemDetailsHolder.Type)) && DoesMatchFilter(TempItemDetailsHolder)) || bool(OnlineSub.CurrentInventory[i].NewlyAdded))
			{
				ItemObject = CreateObject("Object");
				HelperIndex = ActiveItems.Find('ItemDefinition', onlineSub.CurrentInventory[i].Definition);

				if(HelperIndex == INDEX_NONE)
				{
					HelperItem.ItemDefinition = onlineSub.CurrentInventory[i].Definition;
					HelperItem.ItemCount = onlineSub.CurrentInventory[i].Quantity;
					ActiveItems.AddItem(HelperItem);
					HelperIndex = ActiveItems.length - 1;
				}
				else
				{
					ActiveItems[HelperIndex].ItemCount += onlineSub.CurrentInventory[i].Quantity;
				}

				OnlineSub.IsExchangeable(onlineSub.CurrentInventory[i].Definition, ExchangeRules);

				ItemObject.SetInt("count", ActiveItems[HelperIndex].ItemCount);
				ItemObject.SetString("label", TempItemDetailsHolder.Name);
				ItemObject.SetString("price", TempItemDetailsHolder.price);
				ItemObject.Setstring("typeRarity", TempItemDetailsHolder.ShortDescription);
				ItemObject.SetInt("type", TempItemDetailsHolder.Type);
				ItemObject.SetBool("exchangeable", IsItemExchangeable(TempItemDetailsHolder, ExchangeRules) && class'WorldInfo'.static.IsMenuLevel() );
				ItemObject.SetBool("recyclable", IsItemRecyclable(TempItemDetailsHolder, ExchangeRules) && class'WorldInfo'.static.IsMenuLevel());
				bActiveItem = IsItemActive(onlineSub.CurrentInventory[i].Definition) || IsSFXActive(onlineSub.CurrentInventory[i].Definition);
				ItemObject.SetBool("active", bActiveItem );
				ItemObject.SetInt("rarity", TempItemDetailsHolder.Rarity);
				ItemObject.SetString("description", TempItemDetailsHolder.Description);
				ItemObject.SetString("iconURLSmall", "img://"$TempItemDetailsHolder.IconURL);
				ItemObject.SetString("iconURLLarge", "img://"$TempItemDetailsHolder.IconURLLarge);
				ItemObject.SetInt("definition", TempItemDetailsHolder.Definition);
				ItemObject.SetBool("newlyAdded", bool(OnlineSub.CurrentInventory[i].NewlyAdded) );

				ActiveItems[HelperIndex].GfxItemObject = ItemObject;

				if(onlineSub.CurrentInventory[i].Definition == Manager.SelectIDOnOpen)
				{
					PendingItem = ItemObject;
				}

				if(bool(OnlineSub.CurrentInventory[i].NewlyAdded) && bInitialInventoryPassComplete)
				{
					SetMatineeColor(TempItemDetailsHolder.Rarity);
					KFPC.ConsoleCommand("CE gotitem");

					SetObject("details", ItemObject);
				}
			}
		}
	}

	OnlineSub.ClearNewlyAdded();

	for (i = 0; i < ActiveItems.length; i++)
	{
		ItemArray.SetElementObject(i, ActiveItems[i].GfxItemObject);
	}
    
    TempItemDetailsHolder.Type = ITP_SFX;
    TempItemDetailsHolder.Rarity = ITR_ExceedinglyRare;
    
    FXIDs = class'ClassicHeadShotEffectList'.static.GetHeadshotFXArray();
	for( i=0; i<FXIDs.Length; i++ )
	{
        if (((CurrentInventoryFilter == EInv_All || Int(CurrentInventoryFilter) == Int(TempItemDetailsHolder.Type)) && DoesMatchFilter(TempItemDetailsHolder)))
        {
            ItemObject = CreateObject("Object");
            ItemObject.SetInt("count", 1);
            ItemObject.SetString("label", GetSFXName(FXIDs[i].ItemName));
            ItemObject.Setstring("typeRarity", Localize("TypeSection", "FXDeluxeType", "ItemDefinitions"));
            ItemObject.SetInt("type", ITP_SFX);
            ItemObject.SetBool("active", IsSFXActive(FXIDs[i].Id));
            ItemObject.SetInt("rarity", ITR_ExceedinglyRare);
            ItemObject.SetString("description", GetSFXDescription(FXIDs[i].ItemName));
            ItemObject.SetString("iconURLSmall", "img://"$FXIDs[i].IconPathSmall);
            ItemObject.SetString("iconURLLarge", "img://"$FXIDs[i].IconPathLarge);
            ItemObject.SetInt("definition", FXIDs[i].Id);
            
            ItemArray.SetElementObject(ActiveItems.Length+i, ItemObject);
        }
    }

	SetObject("inventoryList", ItemArray);

	if(Manager.SelectIDOnOpen != INDEX_NONE )
	{
		CallBack_ItemDetailsClicked(Manager.SelectIDOnOpen);
		SetObject("details", PendingItem);
		Manager.SelectIDOnOpen = INDEX_NONE;
	}

	bInitialInventoryPassComplete = true;
}

function string GetSFXName(string S)
{
    local string LocalizeName;
    
    switch(S)
    {
        case "Dosh":
            LocalizeName = "DoshFXDeluxeName";
            break;
        case "Confetti":
            LocalizeName = "ConfettiFXDeluxeName";
            break;
        case "Ghost":
            LocalizeName = "GhostFXDeluxeName";
            break;
        case "Hearts":
            LocalizeName = "HeartsFXDeluxeName";
            break;
        case "Comic":
            LocalizeName = "ComicFXDeluxeName";
            break;
        case "Flower":
            LocalizeName = "FlowerPetalFXDeluxeName";
            break;
        case "Splatter":
            LocalizeName = "CartoonSplatFXDeluxeName";
            break;
        case "Gameover":
            LocalizeName = "GameOverFXDeluxeName";
            break;
        case "Glitch":
            LocalizeName = "GlitchFXDeluxeName";
            break;
        case "Headscan":
            LocalizeName = "HorzineFXDeluxeName";
            break;
    }
    
    return Localize("FXSection", LocalizeName, "ItemDefinitions");
}

function string GetSFXDescription(string S)
{
    local string LocalizeName;
    
    switch(S)
    {
        case "Dosh":
            LocalizeName = "DoshFXDeluxeDescription";
            break;
        case "Confetti":
            LocalizeName = "ConfettiFXDeluxeDescription";
            break;
        case "Ghost":
            LocalizeName = "GhostFXDeluxeDescription";
            break;
        case "Hearts":
            LocalizeName = "HeartsFXDeluxeDescription";
            break;
        case "Comic":
            LocalizeName = "ComicFXDeluxeDescription";
            break;
        case "Flower":
            LocalizeName = "FlowerPetalFXDeluxeDescription";
            break;
        case "Splatter":
            LocalizeName = "CartoonSplatFXDeluxeDescription";
            break;
        case "Gameover":
            LocalizeName = "GameOverFXDeluxeDescription";
            break;
        case "Glitch":
            LocalizeName = "GlitchFXDeluxeDescription";
            break;
        case "Headscan":
            LocalizeName = "HorzineFXDeluxeDescription";
            break;
    }
    
    return Localize("FXSection", LocalizeName, "ItemDefinitions");
}

function Callback_EquipSFX(int ItemDefinition)
{
	local int ItemIndex;

	ItemIndex = class'KFHeadShotEffectList'.static.GetHeadShotEffectIndex(ItemDefinition);

	if (ItemIndex == INDEX_NONE)
	{
		return;
	}

	if (IsSFXActive(ItemDefinition))
		class'ClassicHeadShotEffectList'.static.SaveEquippedHeadShotEffect(0, ClassicPlayerController(KFPC));
	else class'ClassicHeadShotEffectList'.static.SaveEquippedHeadShotEffect(ItemDefinition, ClassicPlayerController(KFPC));

	//refresh inventory
	InitInventory();
}

function bool IsSFXActive(int ItemDefinition)
{
	local int ItemIndex;

	ItemIndex = class'KFHeadShotEffectList'.static.GetHeadShotEffectIndex(ItemDefinition);
	if (ItemIndex == INDEX_NONE)
		return false;

	return ItemDefinition == ClassicPlayerController(KFPC).SelectedHeadshotIndex;
}

defaultproperties
{
}