class UI_TraderMenu extends KFGUI_Page;

struct SBuyableInfo
{
	var STraderItem Item;
	var bool bInventory,bSecondary;
};
var SBuyableInfo MyBuyable,OldBuyable;

struct SCurrentPerkInfo
{
	var ClassicPerk_Base CurrentPerk;
	var class<KFPerk> PerkClass;
	var bool bIsFavorites,bIsOffPerk;
};
var SCurrentPerkInfo CurrentPerkInfo;
var int SelectedPerkIndex;

var UIR_ItemBase CurrentSelectedComp;

var UIR_BuyWeaponInfoPanel BuyWeaponInfoPanel;
var KFGUI_Frame HBGLeft,HBGCenter,HBGRight,MoneyBack,Info,Weight,WeightIcoBG,AmmoExit,CurrentPerkIcon;
var KFGUI_Button SaleB,PurchaseB;
var KFGUI_TextLable MagL,FillL,Money,Time,Wave,Perk;
var KFGUI_Image MagB,FillB,Cash;
var KFGUI_TextScroll IScrollText;
var UIR_WeightBar WeightB;
var UIR_InventoryList Inv;
var UIR_TraderItemList Sale;
var KFGUI_ListHorz PerkList,QuickPerkSelect;

var KFAutoPurchaseHelper KFAPH;
var KFInventoryManager MyKFIM;
var ClassicPlayerController PC;
var KFPlayerReplicationInfo MyKFPRI;

var transient bool bDidBuyableUpdate;

var array<string> InfoText;
var string CurrentPerk,NoActivePerk,TraderClose,WaveString,LvAbbrString,AutoFillString;
var int PrevArmor;

function InitMenu()
{
	Super.InitMenu();
	
	PC = ClassicPlayerController(GetPlayer());
	
	PerkList = KFGUI_ListHorz(FindComponentID('PerkList'));
	PerkList.OnDrawItem = DrawPerkList;
	PerkList.OnClickedItem = PerkListClick;	
	
	QuickPerkSelect = KFGUI_ListHorz(FindComponentID('QuickPerkSelect'));
	QuickPerkSelect.OnDrawItem = DrawQuickPerk;
	QuickPerkSelect.OnClickedItem = QuickPerkClick;
	
	BuyWeaponInfoPanel = UIR_BuyWeaponInfoPanel(FindComponentID('ItemInf'));
	
	IScrollText = KFGUI_TextScroll(FindComponentID('IScrollText'));
	
	HBGLeft = KFGUI_Frame(FindComponentID('HBGLeft'));
	HBGCenter = KFGUI_Frame(FindComponentID('HBGCenter'));
	HBGRight = KFGUI_Frame(FindComponentID('HBGRight'));
	MoneyBack = KFGUI_Frame(FindComponentID('MoneyBack'));
	Info = KFGUI_Frame(FindComponentID('Info'));
	Weight = KFGUI_Frame(FindComponentID('Weight'));
	WeightIcoBG = KFGUI_Frame(FindComponentID('WeightIcoBG'));
	AmmoExit = KFGUI_Frame(FindComponentID('AmmoExit'));
	
	CurrentPerkIcon = KFGUI_Frame(FindComponentID('CurrentPerkIcon'));
	CurrentPerkIcon.OnDrawFrame = DrawCurrentPerkBox;
	
	Inv = UIR_InventoryList(FindComponentID('Inv'));
	Sale = UIR_TraderItemList(FindComponentID('Sale'));
	
	SaleB = KFGUI_Button(FindComponentID('SaleB'));
	SaleB.OnClickLeft = InternalOnClick;
	SaleB.OnClickRight = InternalOnClick;
	SaleB.GamepadButtonName = "XboxTypeS_Y";
		
	PurchaseB = KFGUI_Button(FindComponentID('PurchaseB'));
	PurchaseB.OnClickLeft = InternalOnClick;
	PurchaseB.OnClickRight = InternalOnClick;
	PurchaseB.GamepadButtonName = "XboxTypeS_Y";
	
	MagL = KFGUI_TextLable(FindComponentID('MagL'));
	FillL = KFGUI_TextLable(FindComponentID('FillL'));
	Money = KFGUI_TextLable(FindComponentID('Money'));
	Time = KFGUI_TextLable(FindComponentID('Time'));
	Wave = KFGUI_TextLable(FindComponentID('Wave'));
	Perk = KFGUI_TextLable(FindComponentID('Perk'));
	
	WeightB = UIR_WeightBar(FindComponentID('WeightB'));
	
	Cash = KFGUI_Image(FindComponentID('Cash'));
	MagB = KFGUI_Image(FindComponentID('MagB'));
	FillB = KFGUI_Image(FindComponentID('FillB'));
}

function ShowMenu()
{
	Super.ShowMenu();

	KFAPH = PC.GetPurchaseHelper(true);
	MyKFIM = KFInventoryManager(PC.Pawn.InvManager);
	MyKFPRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
	
	if( CurrentPerkInfo == default.CurrentPerkInfo )
	{
		SelectedPerkIndex = PC.GetPerkIndexFromClass(PC.CurrentPerk.Class);
		CurrentPerkInfo.CurrentPerk = ClassicPerk_Base(PC.CurrentPerk); 
		CurrentPerkInfo.PerkClass = ClassicPerk_Base(PC.CurrentPerk).BasePerk; 
	}
	
	SetTimer(0.05f, true);
	Timer();
	
	PC.TraderMenu = self;
	PC.bClientTraderMenuOpen = true;
	
	KFAPH.TotalBlocks = MyKFIM.CurrentCarryBlocks;
	KFAPH.MaxBlocks = MyKFIM.MaxCarryBlocks;
	KFAPH.TotalDosh = MyKFPRI.Score;
	
	PlayMenuSound(MN_DropdownChange);
	
	PerkList.ChangeListSize(PC.PerkList.Length+2);
	QuickPerkSelect.ChangeListSize(PC.PerkList.Length);
	
	Refresh(true);
	Inv.RefreshItemComponents();
	Sale.RefreshItemComponents();
}

function InventoryChanged(optional KFWeapon Wep, optional bool bRemove)
{
	local int i;
	
	Super.InventoryChanged(Wep);
	
	if( bRemove )
	{
		Refresh();
		return;
	}

	// Check if we own this weapon
	for ( i = 0; i < KFAPH.OwnedItemList.Length; i++ )
	{
		if( KFAPH.OwnedItemList[i].DefaultItem.ClassName == Wep.Class.Name )
		{
			return;
		}
	}

	// Only add the item to our owned list if we have the capacity to carry it
	if( KFAPH.TotalBlocks + Wep.GetModifiedWeightValue() > KFAPH.MaxBlocks )
	{
		if( PC.Pawn != none )
		{
			// Throw it if we can't carry
			PC.Pawn.TossInventory(Wep);
		}
	}
	else
	{
		KFAPH.AddBlocks(Wep.GetModifiedWeightValue());
		KFAPH.SetWeaponInformation(Wep);
		
		Refresh();
	}
}

function Refresh(optional bool bInitList)
{
	if( bInitList )
		KFAPH.InitializeOwnedItemList();
	
	Inv.Refresh(true);
	Sale.Refresh(true);
	
	WeightB.MaxBoxes = KFAPH.MaxBlocks;
	WeightB.CurBoxes = KFAPH.TotalBlocks;
}

function Timer()
{
	local KFPawn_Human KFP;
	
	SetInfoText();
	UpdateHeader();
	
	KFP = KFPawn_Human(PC.Pawn);
	if( KFP != none && PrevArmor != KFP.Armor )
	{
		KFAPH.ArmorItem.SpareAmmoCount = KFP.Armor;
		PrevArmor = KFP.Armor;

		Inv.RefreshItemComponents();
		Sale.RefreshItemComponents();
	}
}

function UpdateHeader()
{
	local int TimeLeftMin, TimeLeftSec;
	local string TimeString;
	
	if ( PC == None || PC.PlayerReplicationInfo == None || PC.WorldInfo.GRI == None )
		return;

	// Current Perk
	if ( PC.CurrentPerk != None )
		Perk.SetText(CurrentPerk$":" @ ClassicPerk_Base(PC.CurrentPerk).static.GetPerkName() @ LvAbbrString$PC.CurrentPerk.GetLevel());
    else Perk.SetText(CurrentPerk$":" @ NoActivePerk);

	// Trader time left
	TimeLeftMin = KFGameReplicationInfo(PC.WorldInfo.GRI).GetTraderTimeRemaining() / 60;
	TimeLeftSec = KFGameReplicationInfo(PC.WorldInfo.GRI).GetTraderTimeRemaining() % 60;

	if ( TimeLeftMin < 1 )
		TimeString = "00:";
	else TimeString = "0" $ TimeLeftMin $ ":";

	if ( TimeLeftSec >= 10 )
		TimeString = TimeString $ TimeLeftSec;
	else TimeString = TimeString $ "0" $ TimeLeftSec;

	Time.SetText(TraderClose @ TimeString);

	if ( KFGameReplicationInfo(PC.WorldInfo.GRI).GetTraderTimeRemaining() < 10 )
		Time.TextColor = MakeColor(255, 0, 0, 255);
	else Time.TextColor = MakeColor(175, 176, 158, 255);

	// Wave Counter
	if( KFGameReplicationInfo_Endless(PC.WorldInfo.GRI) != None )
		Wave.SetText(WaveString$":" @ KFGameReplicationInfo(PC.WorldInfo.GRI).WaveNum);
	else Wave.SetText(WaveString$":" @ KFGameReplicationInfo(PC.WorldInfo.GRI).WaveNum$"/"$(KFGameReplicationInfo(PC.WorldInfo.GRI).WaveMax-1));
	
	// Player Cash
	Money.SetText("$"$KFAPH.TotalDosh);
}

function SetInfoText()
{
    local string TempString;

    if ( MyBuyable == default.MyBuyable && !bDidBuyableUpdate )
    {
        IScrollText.SetText(InfoText[0]);
		WeightB.NewBoxes = 0;
        bDidBuyableUpdate = true;
        return;
    }

    if ( MyBuyable != default.MyBuyable && MyBuyable != OldBuyable )
    {
		if ( KFAPH.GetAdjustedBuyPriceFor(MyBuyable.Item) > PC.PlayerReplicationInfo.Score && !MyBuyable.bInventory )
        {
			KFPlayerController(GetPlayer()).PlayTraderSelectItemDialog(true, false);
            IScrollText.SetText(InfoText[2]);
        }
        else if ( !KFAPH.CanCarry(MyBuyable.Item) && !MyBuyable.bInventory )
        {
			KFPlayerController(GetPlayer()).PlayTraderSelectItemDialog(false, true);
	
            TempString = Repl(Infotext[1], "%1", MyKFIM.GetDisplayedBlocksRequiredFor( MyBuyable.Item ));
            TempString = Repl(TempString, "%2", KFAPH.MaxBlocks - KFAPH.TotalBlocks);
            IScrollText.SetText(TempString);
        }
        else
        {
            IScrollText.SetText(MyBuyable.Item.WeaponDef.static.GetItemDescription());
        }
		
		if( !MyBuyable.bInventory )
		{
			WeightB.NewBoxes = MyKFIM.GetDisplayedBlocksRequiredFor(MyBuyable.Item);
		}

        bDidBuyableUpdate = false;
        OldBuyable = MyBuyable;
    }
}

function STraderItem CreateItem(class<KFWeaponDefinition> WeaponDef)
{
	local STraderItem Item;
	local class<KFWeapon> WepClass;
	local array<STraderItemWeaponStats> S;
	
	WepClass = class<KFWeapon>(DynamicLoadObject(WeaponDef.default.WeaponClassPath, class'Class'));
	
	Item.WeaponDef = WeaponDef;
	Item.ClassName = WepClass.Name;
	
	if( class<KFWeap_DualBase>(WepClass)!=None && class<KFWeap_DualBase>(WepClass).default.SingleClass!=None )
		Item.SingleClassName = class<KFWeap_DualBase>(WepClass).default.SingleClass.Name;
	else Item.SingleClassName = '';
	
	Item.DualClassName = WepClass.default.DualClass!=None ? WepClass.default.DualClass.Name : '';
	Item.AssociatedPerkClasses = WepClass.Static.GetAssociatedPerkClasses();
	Item.MagazineCapacity = WepClass.default.MagazineCapacity[0];
	Item.InitialSpareMags = WepClass.default.InitialSpareMags[0];
	Item.MaxSpareAmmo = WepClass.default.SpareAmmoCapacity[0];
	Item.MaxSecondaryAmmo = WepClass.default.MagazineCapacity[1] * WepClass.default.SpareAmmoCapacity[1];
	Item.BlocksRequired = WepClass.default.InventorySize;
	
	Item.SecondaryAmmoImagePath = WepClass.default.SecondaryAmmoTexture!=None ? "img://"$PathName(WepClass.default.SecondaryAmmoTexture) : "";
	Item.TraderFilter = WepClass.Static.GetTraderFilter();
	Item.InventoryGroup = WepClass.default.InventoryGroup;
	Item.GroupPriority = WepClass.default.GroupPriority;
	WepClass.Static.SetTraderWeaponStats(S);
	Item.WeaponStats = S;
	
	return Item;
}

function DrawMenu()
{
	local Texture Texture;
	
	Super.DrawMenu();
	
	Texture = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER];
	Canvas.SetPos(0.f, 0.f);
	Canvas.DrawTileStretched(Texture,CompPos[2],CompPos[3],0,0,Texture.GetSurfaceWidth(),Texture.GetSurfaceHeight());
	
	if( !bTextureInit )
	{
		GetStyleTextures();
	}
}

function DrawPerkList( Canvas C, int Index, float XOffset, float Height, float Width, bool bFocus )
{
	local class<ClassicPerk_Base> PerkClass;
	local ClassicPerk_Base MyPerk;
	local Texture PerkIconTex;
	
	if( bFocus || SelectedPerkIndex == Index )
		C.SetDrawColor(250,0,0,255);
	else C.SetDrawColor(250,250,250,255);
	Owner.CurrentStyle.DrawTileStretched(Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER],XOffset,0.f,Height,Height);
	
	if( Index == PC.PerkList.Length )
	{
		C.DrawColor = class'ClassicPerk_Base'.static.GetPerkColor(0);
		PerkIconTex = Texture(DynamicLoadObject(class'KFGFxObject_TraderItems'.default.OffPerkIconPath, class'Texture'));
	}
	else if( Index == PC.PerkList.Length+1 )
	{
		C.DrawColor = class'ClassicPerk_Base'.static.GetPerkColor(0);
		PerkIconTex = Owner.CurrentStyle.FavoriteIcon;
	}
	else
	{
		PerkClass = class<ClassicPerk_Base>(PC.PerkList[Index].PerkClass);
		if( PerkClass != None )
		{
			MyPerk = PC.PerkManager.FindPerk(PerkClass);
			if( MyPerk == None )
				return;
				
			C.DrawColor = MyPerk.static.GetPerkColor(0);
			PerkIconTex = MyPerk.static.GetCurrentPerkIcon(0);
		}
	}
	
	if( PerkIconTex == None )
		return;
	
	C.SetPos(XOffset + 4, 4);
	C.DrawTile(PerkIconTex, Height - 8, Height - 8, 0, 0, 256, 256);
}

function PerkListClick( int Index, bool bRight, int MouseX, int MouseY )
{
	local class<KFPerk> BasePerkClass;
	local ClassicPerk_Base MyPerk;
	
	CurrentPerkInfo = default.CurrentPerkInfo;
	SelectedPerkIndex = Index;
	
	if( Index == PC.PerkList.Length )
	{
		CurrentPerkInfo.bIsOffPerk = true;
		
		Sale.Refresh(true);
		
		PlayMenuSound(MN_ClickButton);
		return;
	}
	else if( Index == PC.PerkList.Length+1 )
	{
		CurrentPerkInfo.bIsFavorites = true;
		
		Sale.Refresh(true);
		
		PlayMenuSound(MN_ClickButton);
		return;
	}
	
	BasePerkClass = PC.PerkList[Index].PerkClass;
	if( BasePerkClass != None )
	{
		MyPerk = PC.PerkManager.FindPerk(BasePerkClass);
		if( MyPerk != None )
		{
			PlayMenuSound(MN_ClickButton);
			
			CurrentPerkInfo.CurrentPerk = MyPerk; 
			CurrentPerkInfo.PerkClass = MyPerk.BasePerk;
			CurrentPerkInfo.bIsFavorites = false;			
			
			Sale.Refresh(true);
		}
	}
}

function DrawCurrentPerkBox( Canvas C, float W, Float H )
{
	local ClassicPerk_Base MyPerk;
	
	MyPerk = ClassicPerk_Base(PC.CurrentPerk);
	if( MyPerk == None )
		return;
		
	Owner.CurrentStyle.DrawTileStretched(Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL],0.f,0.f,H,H);
	
	C.DrawColor = MyPerk.static.GetPerkColor(0);
	C.SetPos(4, 4);
	C.DrawTile(MyPerk.static.GetCurrentPerkIcon(0), H - 8, H - 8, 0, 0, 256, 256);
}

function DrawQuickPerk( Canvas C, int Index, float XOffset, float Height, float Width, bool bFocus )
{
	local class<ClassicPerk_Base> PerkClass;
	local ClassicPerk_Base MyPerk;
	
	PerkClass = class<ClassicPerk_Base>(PC.PerkList[Index].PerkClass);
	if( PerkClass != None )
	{
		MyPerk = PC.PerkManager.FindPerk(PerkClass);
		if( MyPerk == None )
			return;
			
		if( bFocus || PC.CurrentPerk.Class == PerkClass )
		{
			C.SetDrawColor(250,0,0,255);
		}
		else if( PC.PendingPerk == MyPerk )
		{
			C.SetDrawColor(0,250,0,255);
		}
		else
		{
			C.SetDrawColor(250,250,250,255);
		}
		
		Owner.CurrentStyle.DrawTileStretched(Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER],XOffset,0.f,Height,Height);
		
		C.SetDrawColor(255, 0, 0, 255);
		C.SetPos(XOffset + 4, 4);
		C.DrawTile(MyPerk.static.GetCurrentPerkIcon(0), Height - 8, Height - 8, 0, 0, 256, 256);
	}
}

function QuickPerkClick( int Index, bool bRight, int MouseX, int MouseY )
{
	local ClassicPerk_Base PerkClass;
	local UIP_PerkSelection PerkSelection;
	
	if( MyKFPRI.NetPerkIndex != Index )
	{
		PlayMenuSound(MN_ClickButton);
		
		PerkSelection = PC.PerkSelectionBox;
		PerkClass = PC.PerkManager.FindPerk(PC.PerkList[Index].PerkClass);
		if( PerkClass == PC.PendingPerk )
			return;
			
		if( PerkSelection != None )
		{
			PerkSelection.PerkInfoBox.PrevPendingPerk = None;
			PerkSelection.PerkInfoBox.PendingPerk = None;
			PerkSelection.PerkInfoBox.OldUsedPerk = None;
		}
			
		PC.ServerChangePerks(PerkClass);
		if( PC.CanUpdatePerkInfoEx() )
		{
			PC.SetHaveUpdatePerk(true);
		}
	}
	
	Inv.RefreshItemComponents();
	Sale.RefreshItemComponents();
}

function DoClose()
{
	MyKFIM.ServerCloseTraderMenu();
	if(PC.MyGFxHUD.WeaponSelectWidget != none)
	{
		PC.MyGFxHUD.WeaponSelectWidget.RefreshWeaponSelect();
	}

	KFAPH.TotalDosh = 0;
	PC.TraderMenu = None;
	
	Super.DoClose();
	
	PC.bClientTraderMenuOpen = false;
}

function GetStyleTextures()
{
	if( !Owner.bFinishedReplication )
	{
		return;
	}
	
	BuyWeaponInfoPanel.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_TRANSPARENT];

	HBGLeft.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
	HBGCenter.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
	HBGRight.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
	Inv.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_LARGE_TRANSPARENT];
	MoneyBack.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL_TRANSPARENT];
	Sale.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_LARGE_TRANSPARENT];
	Info.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
	Weight.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
	AmmoExit.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL];
	
	MagB.Image = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT];
	FillB.Image = Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT];
	Cash.Image = Owner.CurrentStyle.BankNoteIcon;
	
	bTextureInit = true;
}

function InternalOnClick( KFGUI_Button Sender )
{
	if( CurrentSelectedComp == None )
		return;
	
	switch( Sender.ID )
	{
		case 'PurchaseB':
			if( CurrentSelectedComp.Buyable.WeaponDef == None )
				return;
				
			Sale.DoPurchaseItem(CurrentSelectedComp, false, 0, 0);
			break;
		case 'SaleB':
			if( CurrentSelectedComp.Sellable.DefaultItem.WeaponDef == None )
				return;
				
			Inv.DoSellItem(CurrentSelectedComp, false, 0, 0);
			break;
	}
}

defaultproperties
{
	XSize=1
	YSize=1
	YPosition=0
	XPosition=0
	
	InfoText(0)="Welcome to my shop! You can buy ammo or sell from your inventory on the left. Or you can buy new items from the right."
	InfoText(1)="Item is too heavy! It requires %1 free weight blocks, you only have %2 free. Sell some of your inventory!"
	InfoText(2)="Item is too expensive! Ask some blokes to spare some money or sell some of your inventory!"
	InfoText(3)="Select an item or option"
	
	CurrentPerk="Current Perk"
	NoActivePerk="No Active Perk!"
	TraderClose="Trader Closes in"
	WaveString="Wave"
	LvAbbrString="Lv"
	AutoFillString="Auto Fill Ammo"
	
	Begin Object class=KFGUI_Frame Name=HBGLeft
		ID="HBGLeft"
		YPosition=0.00100
		XPosition=0.00100
		XSize=0.33230
		YSize=0.10000
	End Object
	Components.Add(HBGLeft)

	Begin Object class=KFGUI_Frame Name=HBGCenter
		ID="HBGCenter"
		YPosition=0.00100
		XPosition=0.33400
		XSize=0.331023
		YSize=0.10000
	End Object
	Components.Add(HBGCenter)
	
	Begin Object class=KFGUI_Frame Name=HBGRight
		ID="HBGRight"
		YPosition=0.00100
		XPosition=0.66600
		XSize=0.33200
		YSize=0.10000
	End Object
	Components.Add(HBGRight)
	
	Begin Object class=UIR_InventoryList Name=Inv
		ID="Inv"
		YPosition=0.1
		XPosition=0.00100
		XSize=0.33230
		YSize=0.647
	End Object
	Components.Add(Inv)
	
	Begin Object class=KFGUI_Frame Name=MoneyBack
		ID="MoneyBack"
		YPosition=0.1
		XPosition=0.33400
		XSize=0.331023
		YSize=0.1335
		HeaderSize(0)=0.f
		HeaderSize(1)=0.f
		EdgeSize(0)=0.f
		EdgeSize(1)=0.f
		EdgeSize(2)=0.f
		EdgeSize(3)=0.f
	End Object
	Components.Add(MoneyBack)
	
	Begin Object class=UIR_TraderItemList Name=Sale
		ID="Sale"
		YPosition=0.1
		XPosition=0.66600
		XSize=0.33230
		YSize=0.647
	End Object
	Components.Add(Sale)
	
	Begin Object class=KFGUI_Frame Name=Info
		ID="Info"
		YPosition=0.746753
		XPosition=0.00100
		XSize=0.664
		YSize=0.179353
		HeaderSize(0)=0.f
		HeaderSize(1)=0.f
		EdgeSize(0)=0.f
		EdgeSize(1)=0.f
		EdgeSize(2)=0.f
		EdgeSize(3)=0.f
	End Object
	Components.Add(Info)
	
	Begin Object class=KFGUI_Frame Name=Weight
		ID="Weight"
		YPosition=0.92675
		XPosition=0.00100
		XSize=0.664
		YSize=0.0725
		HeaderSize(0)=0.f
		HeaderSize(1)=0.f
		EdgeSize(0)=0.f
		EdgeSize(1)=0.f
		EdgeSize(2)=0.f
		EdgeSize(3)=0.f
	End Object
	Components.Add(Weight)
	
	Begin Object class=UIR_TraderWeightFrame Name=WeightIcoBG
		ID="WeightIcoBG"
		YPosition=0.935
		XPosition=0.0055
		XSize=0.04
		YSize=0.055
	End Object
	Components.Add(WeightIcoBG)
	
	Begin Object class=UIR_TraderExitFrame Name=AmmoExit
		ID="AmmoExit"
		YPosition=0.746753
		XPosition=0.66600
		XSize=0.33200
		YSize=0.252349
	End Object
	Components.Add(AmmoExit)
	
	Begin Object Class=KFGUI_TextLable Name=HBGLL
		ID="HBGLL"
		YPosition=0.007238
        XPosition=0.024937
        XSize=0.329761
        YSize=0.019524
		Text="Quick Perk Select"
		AlignX=1
		AlignY=1
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(HBGLL)
	
	Begin Object class=KFGUI_Frame Name=CurrentPerkIcon
		ID="CurrentPerkIcon"
		YPosition=0.011906
		XPosition=0.008008
		XSize=0.075
		YSize=0.075
	End Object
	Components.Add(CurrentPerkIcon)

	Begin Object class=KFGUI_ListHorz Name=QuickPerkSelect
		ID="QuickPerkSelect"
		YPosition=0.032775
		XPosition=0.075
        XSize=0.25
        YSize=0.05
		bClickable=true
		bUseFocusSound=true
	End Object
	Components.Add(QuickPerkSelect)
	
	Begin Object class=KFGUI_Image Name=MagB
		ID="MagB"
		YPosition=0.11
		XPosition=0.205986
		XSize=0.054624
		YSize=0.0225
		ImageStyle=ISTY_Stretched
	End Object
	Components.Add(MagB)
	
	Begin Object class=KFGUI_Image Name=FillB
		ID="FillB"
		YPosition=0.11
		XPosition=0.266769
		XSize=0.054624
		YSize=0.0225
		ImageStyle=ISTY_Stretched
	End Object
	Components.Add(FillB)
	
	Begin Object class=KFGUI_TextLable Name=MagL
		ID="MagL"
		YPosition=0.11
		XPosition=0.205986
		XSize=0.054624
		YSize=0.0225
		Text="1 Mag"
		AlignX=1
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(MagL)
	
	Begin Object class=KFGUI_TextLable Name=FillL
		ID="FillL"
		YPosition=0.11
		XPosition=0.266769
		XSize=0.054624
		YSize=0.0225
		Text="Fill"
		AlignX=1
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(FillL)
	
	Begin Object class=KFGUI_Button Name=SaleB
		ID="SaleB"
		YPosition=0.1075
		XPosition=0.0035
		XSize=0.162886
		YSize=0.02685
		Tooltip="Sell selected weapon"
		ButtonText="Sell Weapon"
	End Object
	Components.Add(SaleB)
	
	Begin Object class=UIR_WeightBar Name=WeightB
		ID="WeightB"
        YPosition=0.945302
        XPosition=0.055266
        XSize=0.443888
        YSize=0.053896
	End Object
	Components.Add(WeightB)
	
	Begin Object Class=KFGUI_TextLable Name=Time
		ID="Time"
		YPosition=0.020952
        XPosition=0.335000
        XSize=0.330000
        YSize=0.035000
		AlignX=1
		AlignY=1
		FontScale=2
		Text="Trader closes in 00:31"
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(Time)
	
	Begin Object Class=KFGUI_TextLable Name=Wave
		ID="Wave"
        YPosition=0.052857
        XPosition=0.336529
        XSize=0.327071
        YSize=0.035000
		Text="Wave: 7/10"
		FontScale=1.25
		AlignX=1
		AlignY=1
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(Wave)
	
	Begin Object Class=KFGUI_TextLable Name=Perk
		ID="Perk"
        YPosition=0.005
        XPosition=0.665
        XSize=0.329761
        YSize=0.050000
		Text=""
		AlignX=1
		FontScale=1
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(Perk)
	
	Begin Object Class=KFGUI_ListHorz Name=PerkList
		ID="PerkList"
        YPosition=0.032775
        XPosition=0.7
        XSize=0.275
        YSize=0.05
		bClickable=true
		bUseFocusSound=true
		ListItemsPerPage=9
	End Object
	Components.Add(PerkList)
	
	Begin Object class=KFGUI_Image Name=Cash
		ID="Cash"
		YPosition=0.126828
		XPosition=0.393095
		XSize=0.107313
		YSize=0.077172
	End Object
	Components.Add(Cash)

	Begin Object Class=KFGUI_TextLable Name=Money
		ID="Money"
		YPosition=0.135524
		XPosition=0.516045
		XSize=0.144797
		YSize=0.058675
		FontScale=4
		TextColor=(R=175,G=176,B=158,A=255)
	End Object
	Components.Add(Money)

	Begin Object class=UIR_BuyWeaponInfoPanel Name=ItemInf
		ID="ItemInf"
		YPosition=0.234311
		XPosition=0.33400
		XSize=0.331023
		YSize=0.5125
	End Object
	Components.Add(ItemInf)

	Begin Object Class=KFGUI_TextScroll Name=IScrollText
		ID="IScrollText"
		YPosition=0.758244
		XPosition=0.004946
		XSize=0.651687
		YSize=0.160580
		ScrollSpeed=0.005
	End Object
	Components.Add(IScrollText)
	
	Begin Object class=KFGUI_Button Name=PurchaseB
		ID="PurchaseB"
		YPosition=0.1075
		XPosition=0.72
		XSize=0.220714
		YSize=0.02685
		Tooltip="Buy selected weapon"
		ButtonText="Purchase Weapon"
	End Object
	Components.Add(PurchaseB)
}