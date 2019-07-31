class UIR_BuyWeaponInfoPanel extends KFGUI_Frame;

var KFGUI_TextLable SelectedItemL,IName,LWeight,DamageCap,RangeCap,MagCap,AmmoCap,PenetrationCap,ROFCap,SaleValue;
var KFGUI_Frame INameBG;
var KFGUI_Button FavoriteB,UpgradeB;
var KFGUI_Image ItemIcon;
var UIR_WeaponBar DamageBar,RangeBar,MagBar,AmmoBar,PenetrationBar,ROFBar;

var SItemInformation CurrentInfo;

var string Weight;
var string FavoriteString;
var string UnfavoriteString;

var KFInventoryManager MyKFIM;
var ClassicPlayerController PC;

var int TopMag,TopAmmo,TopDamage,TopRange,TopPenetration,TopROF;

function InitMenu()
{
    Super.InitMenu();
    
    SelectedItemL = KFGUI_TextLable(FindComponentID('SelectedItemL'));
    
    IName = KFGUI_TextLable(FindComponentID('IName'));
    INameBG = KFGUI_Frame(FindComponentID('INameBG'));
    
    SaleValue = KFGUI_TextLable(FindComponentID('SaleValue'));
    
    DamageCap = KFGUI_TextLable(FindComponentID('DamageCap'));
    RangeCap = KFGUI_TextLable(FindComponentID('RangeCap'));
    MagCap = KFGUI_TextLable(FindComponentID('MagCap'));
    AmmoCap = KFGUI_TextLable(FindComponentID('AmmoCap'));
    ROFCap = KFGUI_TextLable(FindComponentID('ROFCap'));
    PenetrationCap = KFGUI_TextLable(FindComponentID('PenetrationCap'));
    
    LWeight = KFGUI_TextLable(FindComponentID('LWeight'));
    
    FavoriteB = KFGUI_Button(FindComponentID('FavoriteB'));
    FavoriteB.GamepadButtonName = "XboxTypeS_RightThumbStick";
    FavoriteB.OnClickLeft = InternalOnClick;
    FavoriteB.OnClickRight = InternalOnClick;
    
    UpgradeB = KFGUI_Button(FindComponentID('UpgradeB'));
    UpgradeB.GamepadButtonName = "XboxTypeS_LeftThumbStick";
    UpgradeB.OnClickLeft = InternalOnClick;
    UpgradeB.OnClickRight = InternalOnClick;
    
    ItemIcon = KFGUI_Image(FindComponentID('ItemIcon'));
    
    DamageBar = UIR_WeaponBar(FindComponentID('DamageBar'));
    RangeBar = UIR_WeaponBar(FindComponentID('RangeBar'));
    MagBar = UIR_WeaponBar(FindComponentID('MagBar'));
    AmmoBar = UIR_WeaponBar(FindComponentID('AmmoBar'));
    PenetrationBar = UIR_WeaponBar(FindComponentID('PenetrationBar'));
    ROFBar = UIR_WeaponBar(FindComponentID('ROFBar'));
    
    TopDamage = class'KFGFxTraderContainer_ItemDetails'.const.WeaponStatMax_Damage;
    TopRange = class'KFGFxTraderContainer_ItemDetails'.const.WeaponStatMax_Range;
    TopPenetration = class'KFGFxTraderContainer_ItemDetails'.const.WeaponStatMax_Penetration;
    TopROF = class'KFGFxTraderContainer_ItemDetails'.const.WeaponStatMax_FireRate;
    
    PC = ClassicPlayerController(GetPlayer());
    if( !PC.bDisableGameplayChanges )
    {
        SaleValue.YPosition = 0.900183;
        SaleValue.XPosition = 0.337502;
        SaleValue.XSize = 0.325313;
        SaleValue.YSize = 0.059661;
        
        LWeight.YPosition = 0.095;
        LWeight.XPosition = 0.f;
        LWeight.XSize = 1.f;
        LWeight.YSize = 0.1;
    }
    
    ResetValues();
}

function ResetValues()
{
    DamageBar.SetValue(0);
    DamageBar.CaptionOverride = "";
    DamageBar.SetVisibility(false);
    RangeBar.SetValue(0);
    RangeBar.CaptionOverride = "";
    RangeBar.SetVisibility(false);
    MagBar.SetValue(0);
    MagBar.CaptionOverride = "";
    MagBar.SetVisibility(false);    
    AmmoBar.SetValue(0);
    AmmoBar.CaptionOverride = "";
    AmmoBar.SetVisibility(false);
    PenetrationBar.SetValue(0);
    PenetrationBar.CaptionOverride = "";
    PenetrationBar.SetVisibility(false);    
    ROFBar.SetValue(0);
    ROFBar.CaptionOverride = "";
    ROFBar.SetVisibility(false);
    
    DamageCap.SetVisibility(false);
    RangeCap.SetVisibility(false);
    MagCap.SetVisibility(false);
    AmmoCap.SetVisibility(false);
    ROFCap.SetVisibility(false);
    PenetrationCap.SetVisibility(false);
    
    ItemIcon.Image = None;
    ItemIcon.SetVisibility(false);
    
    IName.SetText("");
    IName.SetVisibility(false);    
    
    LWeight.SetText("");
    LWeight.SetVisibility(false);
    
    FavoriteB.SetVisibility(false);
    UpgradeB.SetVisibility(false);
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
        case 'XboxTypeS_LeftThumbStick':
            if( Event == IE_Pressed )
            {
                UpgradeB.HandleMouseClick(false);
            }
            break;
    }
    
    return Super.ReceievedControllerInput(ControllerId, Key, Event);
}

function float GetBarPct(float Value, float MaxValue)
{
    if ( Value == 0 || MaxValue == 0 )
        return 0.f;
    
    if ( Value >= MaxValue )
        return 1.f;
        
    return Sqrt(Value) / Sqrt(MaxValue);
}

function SetDisplay(SItemInformation NewBuyable)
{
    local Texture TraderIcon;
    local class<KFWeapon> Wep;
    local KFWeapon HackWep;
    local KFAutoPurchaseHelper KFAPH;
    local ClassicPerk_Base CurrentPerk;
    local int PerkedValue, MagCapacity, MaxAmmo, Damage, Range, ROF, Index, UpgradeLevel;
    local byte PerkedByteValue;
    local float PerkedFloatValue, Penetration;
    local string S;
    local SItemInformation ItemInfo;
    
    KFAPH = PC.GetPurchaseHelper();
    ResetValues();
    
    Index = KFAPH.OwnedItemList.Find('DefaultItem', NewBuyable.DefaultItem);
    if( Index != INDEX_NONE )
    {
        ItemInfo = KFAPH.OwnedItemList[Index];
    }
    
    if( NewBuyable.DefaultItem.WeaponDef != None )
    {
        Wep = class<KFWeapon>(DynamicLoadObject(NewBuyable.DefaultItem.WeaponDef.default.WeaponClassPath, class'Class'));
    }
    
    if ( NewBuyable.DefaultItem == KFAPH.ArmorItem.DefaultItem || NewBuyable.DefaultItem == KFAPH.GrenadeItem.DefaultItem )
    {
        LWeight.SetVisibility(false);
        FavoriteB.SetVisibility(false);
        UpgradeB.SetVisibility(false);
    }
    else
    {    
        IName.SetVisibility(true);
        LWeight.SetVisibility(!NewBuyable.bIsSecondaryAmmo);
        
        MagBar.SetVisibility(true);
        MagCap.SetVisibility(true);  
        
        AmmoBar.SetVisibility(true);
        AmmoCap.SetVisibility(true);
        
        DamageBar.SetVisibility(true);
        DamageCap.SetVisibility(true);
        
        RangeBar.SetVisibility(true);
        RangeCap.SetVisibility(true);
        
        PenetrationBar.SetVisibility(true);
        PenetrationCap.SetVisibility(true);
                    
        ROFBar.SetVisibility(true);
        ROFCap.SetVisibility(true);
        
        UpgradeLevel = ItemInfo.ItemUpgradeLevel;
        
        CurrentPerk = ClassicPerk_Base(PC.CurrentPerk);
        if( CurrentPerk != None )
        {
            if( Wep != None )
            {
                HackWep = PC.Spawn(Wep, PC,,,,, true);
                
                MagCapacity = NewBuyable.bIsSecondaryAmmo ? Wep.default.MagazineCapacity[Wep.const.ALTFIRE_FIREMODE] : Wep.default.MagazineCapacity[Wep.const.DEFAULT_FIREMODE];
                if ( MagCapacity > 0 )
                {
                    PerkedByteValue = MagCapacity;
                    CurrentPerk.ModifyMagSizeAndNumber(HackWep, PerkedByteValue, NewBuyable.DefaultItem.AssociatedPerkClasses);
                    
                    TopMag = Max(TopMag, PerkedByteValue);
                    MagBar.Value = MagBar.High * GetBarPct(PerkedByteValue, TopMag);            
                    
                    S = string(PerkedByteValue);
                    MagBar.SetHighlight(PerkedByteValue > MagCapacity);
                    
                    if ( PerkedByteValue != MagCapacity ) 
                    {
                        if ( PerkedByteValue > MagCapacity )
                            S @= "("$string(MagCapacity)$"+"$string(PerkedByteValue-MagCapacity)$")";
                        else S @= "("$string(MagCapacity)$string(PerkedByteValue-MagCapacity)$")";
                    }
                    MagBar.CaptionOverride = S;
                }
                
                MaxAmmo = NewBuyable.bIsSecondaryAmmo ? Wep.default.SpareAmmoCapacity[Wep.const.ALTFIRE_FIREMODE] : Wep.default.SpareAmmoCapacity[Wep.const.DEFAULT_FIREMODE];
                if ( MaxAmmo > 0 )
                {
                    PerkedValue = MaxAmmo;
                    CurrentPerk.ModifyMaxSpareAmmoAmount(None, PerkedValue, NewBuyable.DefaultItem);

                    TopAmmo = Max(TopAmmo, PerkedValue);
                    AmmoBar.Value = AmmoBar.High * GetBarPct(PerkedValue, TopAmmo);
                    
                    S = string(PerkedValue);
                    AmmoBar.SetHighlight(PerkedValue > MaxAmmo);
                    
                    if ( PerkedValue != MaxAmmo ) 
                    {
                        if ( PerkedValue > MaxAmmo )
                            S @= "("$string(MaxAmmo)$"+"$string(PerkedValue-MaxAmmo)$")";
                        else S @= "("$string(MaxAmmo)$string(PerkedValue-MaxAmmo)$")";
                    }
                    AmmoBar.CaptionOverride = S;
                }
                
                Damage = NewBuyable.bIsSecondaryAmmo ? Wep.default.InstantHitDamage[Wep.const.ALTFIRE_FIREMODE] : Wep.static.CalculateTraderWeaponStatDamage();
                if ( Damage > 0 )
                {
                    if( UpgradeLevel > 0 )
                        Damage *= HackWep.GetUpgradeDamageMod(NewBuyable.bIsSecondaryAmmo ? Wep.const.ALTFIRE_FIREMODE : Wep.const.DEFAULT_FIREMODE, UpgradeLevel);
                        
                    PerkedValue = Damage;
                    CurrentPerk.ModifyDamageGiven(PerkedValue,PC,,PC,class<KFDamageType>(Wep.default.InstantHitDamageTypes[Wep.const.DEFAULT_FIREMODE]));
                    
                    DamageBar.Value = DamageBar.High * GetBarPct(PerkedValue, TopDamage);
                    
                    S = string(PerkedValue);
                    DamageBar.SetHighlight(PerkedValue > Damage, UpgradeLevel > 0);

                    if ( PerkedValue != Damage ) 
                    {
                        if ( PerkedValue > Damage )
                            S @= "("$string(Damage)$"+"$string(PerkedValue-Damage)$")";
                        else S @= "("$string(Damage)$string(PerkedValue-Damage)$")";
                    }

                    DamageBar.CaptionOverride = S;
                }
                
                Range = NewBuyable.DefaultItem.WeaponStats[TWS_Range].StatValue;
                if ( Range > 0 )
                {
                    PerkedFloatValue = Range;
                    if( KFPlayerReplicationInfo(PC.PlayerReplicationInfo).bExtraFireRange && class<KFWeap_FlameBase>(Wep) != None )
                        PerkedFloatValue *= 2;
                    
                    RangeBar.Value = RangeBar.High * GetBarPct(PerkedFloatValue, TopRange);
                    
                    S = string(int(PerkedFloatValue));
                    RangeBar.SetHighlight(PerkedFloatValue > Range);
                    
                    if ( PerkedFloatValue != Range ) 
                    {
                        if ( PerkedFloatValue > Range )
                            S @= "("$string(Range)$"+"$string(int(PerkedFloatValue)-Range)$")";
                        else S @= "("$string(Range)$string(int(PerkedFloatValue)-Range)$")";
                    }
                    RangeBar.CaptionOverride = S;
                }
                
                Penetration =  NewBuyable.bIsSecondaryAmmo ? Wep.default.PenetrationPower[Wep.const.ALTFIRE_FIREMODE] : Wep.default.PenetrationPower[Wep.const.DEFAULT_FIREMODE];
                if ( Penetration > 0.f )
                {
                    PerkedFloatValue = Penetration;
                    PerkedFloatValue += CurrentPerk.GetPenetrationModifier(CurrentPerk.CurrentVetLevel, class<KFDamageType>(Wep.default.InstantHitDamageTypes[Wep.const.DEFAULT_FIREMODE]));
                    
                    PenetrationBar.Value = PenetrationBar.High * GetBarPct(PerkedFloatValue, TopPenetration);
                    
                    S = string(int(PerkedFloatValue));
                    PenetrationBar.SetHighlight(PerkedFloatValue > Penetration);
                    
                    if ( PerkedFloatValue != Penetration ) 
                    {
                        if ( PerkedFloatValue > Penetration )
                            S @= "("$string(Penetration)$"+"$string(int(PerkedFloatValue)-Penetration)$")";
                        else S @= "("$string(Penetration)$string(int(PerkedFloatValue)-Penetration)$")";
                    }
                    PenetrationBar.CaptionOverride = S;
                }
                
                NewBuyable.bIsSecondaryAmmo ? (60.f / Wep.default.FireInterval[Wep.const.ALTFIRE_FIREMODE]) : Wep.static.CalculateTraderWeaponStatFireRate();
                ROF = NewBuyable.DefaultItem.WeaponStats[TWS_RateOfFire].StatValue;
                if ( ROF > 0 )
                {
                    PerkedFloatValue = ROF;
                    CurrentPerk.ModifyRateOfFire(PerkedFloatValue, HackWep);
                    
                    ROFBar.Value = ROFBar.High * GetBarPct(PerkedFloatValue, TopROF);
                    
                    S = string(int(PerkedFloatValue));
                    ROFBar.SetHighlight(PerkedFloatValue < ROF);
                    
                    if ( PerkedFloatValue != ROF ) 
                    {
                        if ( PerkedFloatValue < ROF )
                            S @= "("$string(ROF)$"-"$string(ROF-int(PerkedFloatValue))$")";
                        else S @= "("$string(ROF)$"+"$string(ROF-int(PerkedFloatValue))$")";
                    }
                    ROFBar.CaptionOverride = S;
                }
                
                if( HackWep != None )
                    HackWep.Destroy();
            }
        }
        
        if( !NewBuyable.bIsSecondaryAmmo )
        {
            if( KFAPH.IsInOwnedItemList(NewBuyable.DefaultItem.ClassName) || !KFAPH.IsSellable(NewBuyable.DefaultItem) )
            {
                FavoriteB.SetVisibility(false);

                if( PC.bDisableGameplayChanges && UpgradeLevel > INDEX_NONE && !PC.bDisableUpgrades )
                {
                    UpgradeB.SetVisibility(true);
                    RefreshUpgradeButton(NewBuyable);
                }
            }
            else
            {
                FavoriteB.SetVisibility(true);
                UpgradeB.SetVisibility(false);
            }

            RefreshFavoriteButton(PC.FavoriteWeaponClassNames.Find(NewBuyable.DefaultItem.ClassName) != INDEX_NONE);
        }
        else
        {
            UpgradeB.SetVisibility(false);
            FavoriteB.SetVisibility(false);
        }
    }
    
    if( Wep != None )
    {
        if( Wep.default.SecondaryAmmoTexture != None && NewBuyable.bIsSecondaryAmmo )
        {
            TraderIcon = Wep.default.SecondaryAmmoTexture;
        }
        else
        {
            TraderIcon = Texture(DynamicLoadObject(NewBuyable.DefaultItem.WeaponDef.static.GetImagePath(), class'Texture'));
        }
        
        if( TraderIcon != None )
        {
            ItemIcon.SetVisibility(true);
            ItemIcon.Image = TraderIcon;
        }
        
        IName.SetText(NewBuyable.bIsSecondaryAmmo ? NewBuyable.DefaultItem.WeaponDef.static.GetItemLocalization("SecondaryAmmo") : NewBuyable.DefaultItem.WeaponDef.static.GetItemName());
        
        if( UpgradeLevel > 0 )
        {
            IName.TextColor = MakeColor(255, 255, 0, 255);
            IName.SetText(IName.GetText()@"x"$UpgradeLevel);
        }
        else
        {
            IName.TextColor = MakeColor(255, 255, 255, 255);
        }
        
        LWeight.SetText(Repl(Weight, "%i", MyKFIM.GetDisplayedBlocksRequiredFor( NewBuyable.DefaultItem, UpgradeLevel )));
    }
    
    CurrentInfo = NewBuyable;
}

function RefreshUpgradeButton(SItemInformation Item)
{
    local int CanCarryIndex, CanAffordIndex;
    
    if( Item.DefaultItem.WeaponDef == None )
    {
        UpgradeB.SetVisibility(false);
        return;
    }
    
    if( !(Item.ItemUpgradeLevel < Item.DefaultItem.WeaponDef.default.UpgradePrice.Length) )
    {
        UpgradeB.SetVisibility(false);
        return;
    }
    
    UpgradeB.ButtonText = "Upgrade (£"$Item.DefaultItem.WeaponDef.static.GetUpgradePrice(Item.ItemUpgradeLevel)$")";
    UpgradeB.SetDisabled(!PC.GetPurchaseHelper().CanUpgrade(Item.DefaultItem, CanCarryIndex, CanAffordIndex));
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
        SaleValue.SetText("Sell Value: £" $ KFAPH.GetAdjustedSellPriceFor(Trader.MyBuyable.Item));
        SaleValue.bVisible = true;
        
        LWeight.XPosition = 0.f;
        LWeight.XSize = 0.5f;
    }
    else
    {
        SaleValue.bVisible = false;
        
        LWeight.XPosition = 0.f;
        LWeight.XSize = 1.f;
    }
}

function InternalOnClick( KFGUI_Button Sender )
{
    local UI_TraderMenu Trader;
    local int Index;
	local SItemInformation ItemInfo;
	local KFAutoPurchaseHelper PurchaseHelper;
    
    if( CurrentInfo == default.CurrentInfo )
        return;
        
    Trader = UI_TraderMenu(ParentComponent);
    if( Trader == None )
        return;
        
    PurchaseHelper = PC.GetPurchaseHelper();
    if( PurchaseHelper == None )
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
        case 'UpgradeB':
            Index = PurchaseHelper.OwnedItemList.Find('DefaultItem', CurrentInfo.DefaultItem);
            if( PurchaseHelper.UpgradeWeapon(Index) )
            {
                ItemInfo = PurchaseHelper.OwnedItemList[Index];
                
                PurchaseHelper.OwnedItemList[Index].ItemUpgradeLevel++;
                PurchaseHelper.OwnedItemList[Index].SellPrice = PurchaseHelper.GetAdjustedSellPriceFor(ItemInfo.DefaultItem);
                
                SetDisplay(PurchaseHelper.OwnedItemList[Index]);
                
                CurrentInfo = ItemInfo;
                
                Trader.Refresh();
                
                Trader.Inv.RefreshItemComponents();
                Trader.Sale.RefreshItemComponents();
                
                class'KFMusicStingerHelper'.static.PlayWeaponUpgradeStinger(PC);
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
        YPosition=0.0235
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
        YSize=0.080000
    End Object
    Components.Add(INameBG)

    Begin Object Class=KFGUI_TextLable Name=DamageCap
        ID="DamageCap"
        Text="Damage:"
        TextColor=(B=158,G=176,R=175)
        AlignX=0
        YPosition=0.480000
        XPosition=0.050000
        XSize=0.250000
        YSize=0.055000
        bVisible=False
    End Object
    Components.Add(DamageCap)

    Begin Object Class=KFGUI_TextLable Name=PenetrationCap
        ID="PenetrationCap"
        Text="Penetration:"
        TextColor=(B=158,G=176,R=175)
        AlignX=0
        YPosition=0.550000
        XPosition=0.050000
        XSize=0.250000
        YSize=0.055000
        bVisible=False
    End Object
    Components.Add(PenetrationCap)

    Begin Object Class=KFGUI_TextLable Name=ROFCap
        ID="ROFCap"
        Text="Rate of Fire:"
        TextColor=(B=158,G=176,R=175)
        AlignX=0
        YPosition=0.620000
        XPosition=0.050000
        XSize=0.250000
        YSize=0.055000
        bVisible=False
    End Object
    Components.Add(ROFCap)

    Begin Object Class=KFGUI_TextLable Name=RangeCap
        ID="RangeCap"
        Text="Range:"
        TextColor=(B=158,G=176,R=175)
        AlignX=0
        YPosition=0.690000
        XPosition=0.050000
        XSize=0.250000
        YSize=0.055000
        bVisible=False
    End Object
    Components.Add(RangeCap)

    Begin Object Class=KFGUI_TextLable Name=MagCap
        ID="MagCap"
        Text="Magazine:"
        TextColor=(B=158,G=176,R=175)
        AlignX=0
        YPosition=0.760000
        XPosition=0.050000
        XSize=0.250000
        YSize=0.055000
        bVisible=False
    End Object
    Components.Add(MagCap)

    Begin Object Class=KFGUI_TextLable Name=AmmoCap
        ID="AmmoCap"
        Text="Total Ammo:"
        TextColor=(B=158,G=176,R=175)
        AlignX=0
        YPosition=0.830000
        XPosition=0.050000
        XSize=0.250000
        YSize=0.055000
        bVisible=False
    End Object
    Components.Add(AmmoCap)

    Begin Object Class=UIR_WeaponBar Name=DamageBar
        ID="DamageBar"
        BorderSize=3.000000
        YPosition=0.480000
        XPosition=0.300000
        XSize=0.650000
        YSize=0.055000
        bShowValue=False
        bVisible=False
    End Object
    Components.Add(DamageBar)
    
    Begin Object Class=UIR_WeaponBar Name=PenetrationBar
        ID="PenetrationBar"
        BorderSize=3.000000
        YPosition=0.550000
        XPosition=0.300000
        XSize=0.650000
        YSize=0.055000
        bShowValue=False
        bVisible=False
    End Object
    Components.Add(PenetrationBar)

    Begin Object Class=UIR_WeaponBar Name=ROFBar
        ID="ROFBar"
        BorderSize=3.000000
        YPosition=0.620000
        XPosition=0.300000
        XSize=0.650000
        YSize=0.055000
        bShowValue=False
        bVisible=False
    End Object
    Components.Add(ROFBar)

    Begin Object Class=UIR_WeaponBar Name=RangeBar
        ID="RangeBar"
        BorderSize=3.000000
        YPosition=0.690000
        XPosition=0.300000
        XSize=0.650000
        YSize=0.055000
        bShowValue=False
        bVisible=False
    End Object
    Components.Add(RangeBar)

    Begin Object Class=UIR_WeaponBar Name=MagBar
        ID="MagBar"
        BorderSize=3.000000
        YPosition=0.760000
        XPosition=0.300000
        XSize=0.650000
        YSize=0.055000
        bShowValue=False
        bVisible=False
    End Object
    Components.Add(MagBar)

    Begin Object Class=UIR_WeaponBar Name=AmmoBar
        ID="AmmoBar"
        BorderSize=3.000000
        YPosition=0.830000
        XPosition=0.300000
        XSize=0.650000
        YSize=0.055000
        bShowValue=False
        bVisible=False
    End Object
    Components.Add(AmmoBar)
    
    Begin Object Class=KFGUI_TextLable Name=LWeight
        ID="LWeight"
        YPosition=0.095000
        XPosition=0.000000
        XSize=0.500000
        YSize=0.100000
        Text="Weight: "
        AlignX=1
        FontScale=2
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    Components.Add(LWeight)
    
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
    
    Begin Object Class=KFGUI_Button Name=UpgradeB
        ID="UpgradeB"
        ButtonText="Upgrade"
        Tooltip=""
        YPosition=0.9
        XPosition=0.25
        XSize=0.5
        YSize=0.08
    End Object
    Components.Add(UpgradeB)
    
    Begin Object Class=KFGUI_TextLable Name=SaleValue
        ID="SaleValue"
        YPosition=0.095000
        XPosition=0.500000
        XSize=0.500000
        YSize=0.100000
        AlignX=1
        AlignY=1
        FontScale=2
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    Components.Add(SaleValue)
}