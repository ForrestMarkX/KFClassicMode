class UIR_InventoryList extends KFGUI_Frame
	DependsOn(UI_TraderMenu);

var KFGUI_Image EquipmentBG;

var KFGUI_ComponentList InventoryBox;
var UIR_TraderPlayerInventory KnifeInventory,GrenadeInventory,ArmorInventory;

var ClassicPlayerController PC;
var KFInventoryManager MyKFIM;
var UI_TraderMenu TraderMenu;

var int OldItemListLength;
var float ButtonCooldown;

function InitMenu()
{
	Super.InitMenu();

	PC = ClassicPlayerController(GetPlayer());
	TraderMenu = UI_TraderMenu(ParentComponent);
	
	EquipmentBG = KFGUI_Image(FindComponentID('EquipmentBG'));
	
	InventoryBox = KFGUI_ComponentList(FindComponentID('InventoryBox'));
	
	KnifeInventory = UIR_TraderPlayerInventory(FindComponentID('KnifeInventory'));
	KnifeInventory.OnClicked = InventoryDoClick;
	
	GrenadeInventory = UIR_TraderPlayerInventory(FindComponentID('GrenadeInventory'));
	GrenadeInventory.OnClicked = InventoryDoClick;
	
	ArmorInventory = UIR_TraderPlayerInventory(FindComponentID('ArmorInventory'));
	ArmorInventory.OnClicked = InventoryDoClick;
}

function ShowMenu()
{
	Super.ShowMenu();
	
	MyKFIM = KFInventoryManager(GetPlayer().Pawn.InvManager);
	SetTimer(0.05f, true, nameOf(Refresh));
}

function DrawMenu()
{
	if( !bTextureInit )
	{
		GetStyleTextures();
	}
		
	Super.DrawMenu();
}

function UIR_TraderPlayerInventory GetSelectedItem()
{
	local int i;
	
	for( i=InventoryBox.ItemComponents.Length - 1; i>=0; i-- )
	{
		if( UIR_TraderPlayerInventory(InventoryBox.ItemComponents[i]).bSelected )
			return UIR_TraderPlayerInventory(InventoryBox.ItemComponents[i]);
	}
	
	if( KnifeInventory.bSelected )
	{
		return KnifeInventory;
	}
	else if( GrenadeInventory.bSelected )
	{
		return GrenadeInventory;
	}
	else if( ArmorInventory.bSelected )
	{
		return ArmorInventory;
	}
	
	return None;
}

function bool ReceievedControllerInput(int ControllerId, name Key, EInputEvent Event)
{
	local UIR_TraderPlayerInventory Item;
	
	Item = GetSelectedItem();
	if( Item == None )
		return false;
		
	switch(Key)
	{
		case 'XboxTypeS_Y':
			if( Event == IE_Pressed )
			{
				DoSellItem(Item, false, 0, 0);
			}
			break;
		case 'XboxTypeS_X':
			if( Event == IE_Pressed )
			{
				if( !Item.bIsArmor )
				{
					if( !Item.FillAmmoB.bDisabled )
					{
						PC.PlayAKEvent(AkEvent'WW_UI_Menu.Play_PERK_MENU_BUTTON_CLICK');
					}
					
					Item.FillAmmoB.HandleMouseClick(false);
				}
				else 
				{
					if( !Item.PurchaseVest.bDisabled )
					{
						PC.PlayAKEvent(AkEvent'WW_UI_Menu.Play_PERK_MENU_BUTTON_CLICK');
					}
					
					Item.PurchaseVest.HandleMouseClick(false);
				}
			}
			break;
	}
	
	return Super.ReceievedControllerInput(ControllerId, Key, Event);
}

function DeselectAll()
{
	local int i;
	local UIR_TraderPlayerInventory Inv;
	
	for(i=0; i < InventoryBox.ItemComponents.Length; i++)
	{
		Inv = UIR_TraderPlayerInventory(InventoryBox.ItemComponents[i]);
		if( Inv != None && Inv.bSelected )
			Inv.bSelected = false;
	}	
	
	for(i=0; i < Components.Length; i++)
	{
		Inv = UIR_TraderPlayerInventory(Components[i]);
		if( Inv != None && Inv.bSelected )
			Inv.bSelected = false;
	}
}

function RefreshItemComponents()
{
	local int i;
	local UIR_TraderPlayerInventory Inv;
	
	for(i=0; i < InventoryBox.ItemComponents.Length; i++)
	{
		Inv = UIR_TraderPlayerInventory(InventoryBox.ItemComponents[i]);
		if( Inv != None )
			Inv.Refresh();
	}	
	
	for(i=0; i < Components.Length; i++)
	{
		Inv = UIR_TraderPlayerInventory(Components[i]);
		if( Inv != None )
			Inv.Refresh();
	}
}

function DoSellItem( UIR_ItemBase Sender, bool bRight, int MouseX, int MouseY )
{
	local KFAutoPurchaseHelper KFAPH;
	
	KFAPH = PC.GetPurchaseHelper();
	if( KFAPH.IsSellable(Sender.Sellable.DefaultItem) && ButtonCooldown < GetPlayer().WorldInfo.TimeSeconds )
	{
		ButtonCooldown = GetPlayer().WorldInfo.TimeSeconds + 0.25;
		
		KFAPH.SellWeapon(Sender.Sellable, Sender.ItemIndex);
		TraderMenu.Refresh();
		
		TraderMenu.Sale.RefreshItemComponents();
		RefreshItemComponents();
		
		TraderMenu.Sale.DeselectAll();
		DeselectAll();
		
        TraderMenu.IScrollText.SetText(TraderMenu.InfoText[0]);
		TraderMenu.WeightB.NewBoxes = 0;
        TraderMenu.bDidBuyableUpdate = true;
		
		GetPlayer().PlayAKEvent(AkEvent'WW_UI_Menu.Play_TRADER_SELL_WEAPON');
	}
}

function InventoryDoClick( UIR_ItemBase Sender, bool bRight, int MouseX, int MouseY )
{
	local SBuyableInfo Info;
	local KFAutoPurchaseHelper KFAPH;
	
	KFAPH = PC.GetPurchaseHelper();
	TraderMenu.MyBuyable = TraderMenu.default.MyBuyable;
	
	TraderMenu.Sale.DeselectAll();
	DeselectAll();
	
	Sender.bSelected = true;
	TraderMenu.CurrentSelectedComp = Sender;
	
	Info.Item = Sender.Sellable.DefaultItem;
	Info.bInventory = KFAPH.DoIOwnThisWeapon(Sender.Sellable.DefaultItem);
	Info.bSecondary = Sender.bIsSecondaryAmmo;
	
	TraderMenu.MyBuyable = Info;
	TraderMenu.BuyWeaponInfoPanel.SetDisplay(Sender.Sellable);
}

function UpdateSellables()
{
	local array<SItemInformation> Items;
	local SItemInformation Item;
	local int i;
	local UIR_TraderPlayerInventory InvTab;
	local KFAutoPurchaseHelper KFAPH;
	
	if( PC.Pawn == None )
		return;
		
	KFAPH = PC.GetPurchaseHelper();
		
	Item.DefaultItem = TraderMenu.CreateItem(ClassicPerk_Base(PC.CurrentPerk).static.GetKnifeDef(PC.CurrentPerk.GetLevel()));
	KnifeInventory.SetSellable(Item);
	
	GrenadeInventory.SetSellable(KFAPH.GrenadeItem, true);	
	ArmorInventory.SetSellable(KFAPH.ArmorItem, false);
	
	Items = KFAPH.OwnedItemList;
	for( i=0; i < Items.Length; i++ )
	{
		InvTab = UIR_TraderPlayerInventory(InventoryBox.AddListComponent(class'UIR_TraderPlayerInventory'));
		InvTab.InitMenu();
		InvTab.ShowMenu();
		InvTab.ItemIndex = i;
		InvTab.bIsSecondaryAmmo = Items[i].bIsSecondaryAmmo;
		InvTab.SetSellable(Items[i], InvTab.bIsSecondaryAmmo ? Items[i].DefaultItem.WeaponDef.static.UsesSecondaryAmmo() : Items[i].DefaultItem.WeaponDef.static.UsesAmmo());
		InvTab.OnClicked = InventoryDoClick;
		InvTab.OnDblClicked = DoSellItem;
	}
	
	OldItemListLength = KFAPH.OwnedItemList.Length;
}

function Refresh(optional bool bForce)
{
	local KFAutoPurchaseHelper KFAPH;
	
	KFAPH = PC.GetPurchaseHelper();
	if( KFAPH.OwnedItemList.Length != OldItemListLength || bForce )
	{
		InventoryBox.EmptyList();
		UpdateSellables();
		DeselectAll();
	}
}

function GetStyleTextures()
{
	if( !Owner.bFinishedReplication )
	{
		return;
	}

	EquipmentBG.Image = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT];
	
	if( EquipmentBG.Image == None )
	{
		return;
	}
	
	bTextureInit = true;
}

defaultproperties
{
    EdgeSize(0)=10
    EdgeSize(1)=45
    EdgeSize(2)=-23
    EdgeSize(3)=-55
	
	Begin Object class=KFGUI_ComponentList Name=InventoryBox
		ID="InventoryBox"
		YPosition=0
		XPosition=0
		XSize=1
		YSize=0.5875
		ListItemsPerPage=6
		bHideScrollbar=true
	End Object
	Components.Add(InventoryBox)
	
	Begin Object class=KFGUI_Image Name=EquipmentBG
		ID="EquipmentBG"
		YPosition=0.6
		XPosition=0.01
		XSize=0.174624
		YSize=0.075
		ImageStyle=ISTY_Stretched
	End Object
	Components.Add(EquipmentBG)
	
	Begin Object Class=KFGUI_TextLable Name=EquipmentLabel
		ID="EquipmentLabel"
		YPosition=0.6
		XPosition=0.01
		XSize=0.174624
		YSize=0.075
		AlignX=1
		AlignY=1
		Text="Equipment"
		TextColor=(R=255,G=255,B=255,A=255)
	End Object
	Components.Add(EquipmentLabel)
	
	Begin Object Class=UIR_TraderPlayerInventory Name=KnifeInventory
		ID="KnifeInventory"
		YPosition=0.7
		XPosition=0
		XSize=0.955
		YSize=0.1
	End Object
	Components.Add(KnifeInventory)
	
	Begin Object Class=UIR_TraderPlayerInventory Name=GrenadeInventory
		ID="GrenadeInventory"
		YPosition=0.8
		XPosition=0
		XSize=0.955
		YSize=0.1
	End Object
	Components.Add(GrenadeInventory)
	
	Begin Object Class=UIR_TraderPlayerInventory Name=ArmorInventory
		ID="ArmorInventory"
		YPosition=0.9
		XPosition=0
		XSize=0.955
		YSize=0.1
	End Object
	Components.Add(ArmorInventory)
}