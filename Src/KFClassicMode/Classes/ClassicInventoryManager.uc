class ClassicInventoryManager extends KFInventoryManager;

/*
var KFAnimNotify_MeleeImpact_1P PendingMeleeNotify;
var KFWeapon PendingMeleeWeapon;
*/

struct SavedWeaponPrices
{
    var class<KFWeaponDefinition> Def;
    var ClassicPerk_Base Perk;
    var int PerkLevel;
};
var array<SavedWeaponPrices> SavedPrices;

simulated function Inventory CreateInventory(class<Inventory> NewInventoryItemClass, optional bool bDoNotActivate)
{
    local Inventory Inv;
    local KFGameReplicationInfo MyKFGRI;
    local KFGFxObject_TraderItems TraderItems;
    local int Index;
    
    Inv = Super.CreateInventory(NewInventoryItemClass, bDoNotActivate);
    if( KFWeapon(Inv) != None )
    {
        MyKFGRI = KFGameReplicationInfo(WorldInfo.GRI);
        if( MyKFGRI != None )
        {
            TraderItems = MyKFGRI.TraderItems;
            if( TraderItems != None )
            {
                Index = TraderItems.SaleItems.Find('ClassName', KFWeapon(Inv).Class.Name);
                if( Index != INDEX_NONE )
                    ServerAddSavedItem(TraderItems.SaleItems[Index]);
            }
        }
    
        NotifyInventoryChange(KFWeapon(Inv));
    }
    
    return Inv;
}

simulated function RemoveFromInventory(Inventory ItemToRemove)
{
    local KFGameReplicationInfo MyKFGRI;
    local KFGFxObject_TraderItems TraderItems;
    local int Index;
    
    if( KFWeapon(ItemToRemove) != None )
    {
        MyKFGRI = KFGameReplicationInfo(WorldInfo.GRI);
        if( MyKFGRI != None )
        {
            TraderItems = MyKFGRI.TraderItems;
            if( TraderItems != None )
            {
                Index = TraderItems.SaleItems.Find('ClassName', KFWeapon(ItemToRemove).Class.Name);
                if( Index != INDEX_NONE )
                    ServerRemoveSavedItem(TraderItems.SaleItems[Index]);
            }
        }
        
        NotifyInventoryChange(KFWeapon(ItemToRemove), true);
    }
    
    Super.RemoveFromInventory(ItemToRemove);
    
    if( Instigator != none && Instigator.IsLocallyControlled() )
        UpdateHUD();
}

reliable server function ServerAddSavedItem(STraderItem Item)
{
    local SavedWeaponPrices SavedItem;
    local KFPlayerController PC;
    local ClassicPerk_Base Perk;
    
    PC = KFPlayerController(Instigator.Controller);
    if( PC == None )
        return;
        
    Perk = ClassicPerk_Base(PC.CurrentPerk);
    if( Perk == None )
        return;
    
    SavedItem.Def = Item.WeaponDef;
    SavedItem.Perk = Perk;
    SavedItem.PerkLevel = Perk.GetLevel();
    
    SavedPrices.AddItem(SavedItem);
    ClientAddSavedItem(SavedItem);
}

reliable client function ClientAddSavedItem(SavedWeaponPrices Item)
{
    SavedPrices.AddItem(Item);
}

reliable server function ServerRemoveSavedItem(STraderItem Item)
{
    local int Index;
    
    Index = SavedPrices.Find('Def', Item.WeaponDef);
    if( Index != INDEX_NONE )
    {
        SavedPrices.Remove(Index, 1);
        ClientRemoveSavedItem(Item);
    }
}

reliable client function ClientRemoveSavedItem(STraderItem Item)
{
    local int Index;
    
    Index = SavedPrices.Find('Def', Item.WeaponDef);
    if( Index != INDEX_NONE )
        SavedPrices.Remove(Index, 1);
}

reliable client function NotifyInventoryChange(KFWeapon Wep, optional bool bRemove)
{
    local KFHUDInterface myHUD;
    local KFPlayerController PC;
    
    if( Instigator == None )
        return;

    PC = KFPlayerController(Instigator.Controller);
    if( PC == None )
        return;
        
    myHUD = KFHUDInterface(PC.myHUD);
    if( myHUD == None || myHUD.GUIController == None )
        return;
    
    myHUD.GUIController.InventoryChanged(Wep, bRemove);
}

simulated function int GetWeaponBlocks(const out STraderItem ShopItem, optional int OverrideLevelValue = INDEX_NONE)
{
    local int ItemUpgradeLevel;
    local KFPlayerController KFPC;
    local Inventory InventoryItem;

    KFPC = KFPlayerController(Instigator.Owner);
    
    if( KFPC==None )
        return 0;
    
    if (ShopItem.SingleClassName != '' && OverrideLevelValue == INDEX_NONE && ClassNameIsInInventory(ShopItem.SingleClassName, InventoryItem))
        ItemUpgradeLevel = KFWeapon(InventoryItem).CurrentWeaponUpgradeIndex;
    else ItemUpgradeLevel = OverrideLevelValue != INDEX_NONE ? OverrideLevelValue : KFPC.GetPurchaseHelper().GetItemUpgradeLevelByClassName(ShopItem.ClassName);

    return ShopItem.BlocksRequired + (ItemUpgradeLevel > INDEX_NONE ? ShopItem.WeaponUpgradeWeight[ItemUpgradeLevel] : 0);
}

simulated function AttemptQuickHeal()
{
    local KFWeap_HealerBase W;
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(Instigator.Owner);
    if( KFPC == None )
        return;
        
    if ( Instigator.Health >= Instigator.HealthMax )
    {
        if( KFHUDInterface(KFPC.myHUD) != None )
            KFHUDInterface(KFPC.myHUD).ShowNonCriticalMessage("Health Full");
        
         return;
    }

    if ( KFWeap_HealerBase(Instigator.Weapon) != None && !Instigator.Weapon.IsFiring() )
    {
        Instigator.Weapon.StartFire(1);
        return;
    }

    ForEach InventoryActors( class'KFWeap_HealerBase', W )
    {
        if ( W != Instigator.Weapon )
        {
            if( W.HasAmmo(1) )
            {
                W.bQuickHealMode = true;
                SetCurrentWeapon(W);
            }
            else if( KFHUDInterface(KFPC.myHUD) != None )
                KFHUDInterface(KFPC.myHUD).ShowQuickSyringe();
        }
    }
}

simulated function int GetAdjustedBuyPriceFor( const out STraderItem ShopItem, optional const array<SItemInformation> TraderOwnedItems )
{
    local KFPlayerController KFPC;
    local int OriginalPrice;
    
    if( ShopItem.WeaponDef == None )
        return 0;
    
    OriginalPrice = Super.GetAdjustedBuyPriceFor(ShopItem, TraderOwnedItems);
    KFPC = KFPlayerController(Instigator.Controller);
    
    if( KFPC != None )
    {
        if( ClassicPerk_Base(KFPC.CurrentPerk) != None )
            OriginalPrice *= ClassicPerk_Base(KFPC.CurrentPerk).GetCostScaling(KFPC.CurrentPerk.GetLevel(), ShopItem);
    }
    
    return OriginalPrice;
}

simulated function int GetAdjustedSellPriceFor(const out STraderItem OwnedItem, optional const array<SItemInformation> TraderOwnedItems)
{
    local KFPlayerController KFPC;
    local int OriginalSellPrice, Index;
    
    if( OwnedItem.WeaponDef == None )
        return 0;
    
    OriginalSellPrice = Super.GetAdjustedSellPriceFor(OwnedItem, TraderOwnedItems);
    KFPC = KFPlayerController(Instigator.Controller);
    
    if( KFPC != None )
    {
        Index = SavedPrices.Find('Def', OwnedItem.WeaponDef);
        if( Index != INDEX_NONE )
            OriginalSellPrice *= SavedPrices[Index].Perk.GetCostScaling(SavedPrices[Index].PerkLevel, OwnedItem);
    }
    
    return OriginalSellPrice;
}

simulated function UpdateHUD()
{
    local KFHUDInterface HUD;
    local KFWeapon KFW, KFPendingWeapon;
    local byte WeaponIndex;

    WeaponIndex = 0;
    if( PendingWeapon != none && !PendingWeapon.bDeleteMe && PendingWeapon.Instigator == Instigator )
        KFPendingWeapon = KFWeapon( PendingWeapon );
    else KFPendingWeapon = KFWeapon( Instigator.Weapon );

    if ( KFPendingWeapon == none || KFPendingWeapon.InventoryGroup == IG_None )
        return;

    // Get the index of this weapon in its group
    ForEach InventoryActors( class'KFWeapon', KFW )
    {
        if ( KFW.InventoryGroup == KFPendingWeapon.InventoryGroup )
        {
            if ( KFW == KFPendingWeapon )
                break;

            WeaponIndex++;
        }
    }

    if( KFPlayerController(Instigator.Controller) != none )
        HUD = KFHUDInterface(KFPlayerController(Instigator.Controller).myHUD);
        
    if( HUD != None )
    {
        if(!bAutoswitchWeapon && !(KFPendingWeapon == HealerWeapon && HealerWeapon.bQuickHealMode))
        {
            if( !HUD.bDisplayInventory )
            {
                HUD.bDisplayInventory = true;
                HUD.InventoryFadeStartTime = WorldInfo.TimeSeconds;
            }
            else
            {
                if ( `TimeSince(HUD.InventoryFadeStartTime) > HUD.InventoryFadeInTime )
                {
                    if ( `TimeSince(HUD.InventoryFadeStartTime) > HUD.InventoryFadeTime - HUD.InventoryFadeOutTime )
                        HUD.InventoryFadeStartTime = `TimeSince(HUD.InventoryFadeInTime + ((HUD.InventoryFadeTime - `TimeSince(HUD.InventoryFadeStartTime)) * HUD.InventoryFadeInTime));
                    else HUD.InventoryFadeStartTime = `TimeSince(HUD.InventoryFadeInTime);
                }
            }
            
            HUD.SelectedInventoryCategory = KFPendingWeapon.InventoryGroup;
            HUD.SelectedInventoryIndex = WeaponIndex;

            SelectedGroupIndicies[KFPendingWeapon.InventoryGroup] = WeaponIndex;
        }
    }
}

/*
simulated function SetPendingFire(Weapon InWeapon, int InFiringMode)
{
    local int i;
    local AnimSequence AnimSeq;
    local float MeleeDamageTime;
    local KFWeapon KFW;
    local KFPawn Pawn;
    
    Pawn = KFPawn(Instigator);
    if( Pawn != None && !Pawn.IsFirstPerson() && Pawn.IsLocallyControlled() )
    {
        KFW = KFWeapon(InWeapon);
        if( KFW != None && KFW.MySkelMesh != None && KFW.MeleeAttackHelper != None )
        {
            AnimSeq = KFW.MySkelMesh.FindAnimSequence(KFW.GetMeleeAnimName(KFW.MeleeAttackHelper.CurrentAttackDir, ATK_Normal));
            if( AnimSeq != None && AnimSeq.RateScale > 0.f )
            {
                for(i=0; i<AnimSeq.Notifies.Length; i++)
                {
                    PendingMeleeNotify = KFAnimNotify_MeleeImpact_1P(AnimSeq.Notifies[i].Notify);
                    if( PendingMeleeNotify!=None )
                    {
                        MeleeDamageTime = (AnimSeq.Notifies[i].Time / AnimSeq.RateScale);
                        break;
                    }
                }
            }
            
            if( MeleeDamageTime>0.f )
            {
                PendingMeleeWeapon = KFW;
                SetTimer(MeleeDamageTime,false,nameof(CheckMeleeDamage),Self);
            }
        }
    }
    
    Super.SetPendingFire(InWeapon, InFiringMode);
}

simulated function CheckMeleeDamage()
{
    local KFMeleeHelperAI AIHelper;
    local KFAnimNotify_MeleeImpact Impact;
    
    if( PendingMeleeNotify == None || PendingMeleeWeapon == None || PendingMeleeWeapon.MeleeAttackHelper == None )
        return;
    
    Impact = New(Instigator) class'KFAnimNotify_MeleeImpact';
    Impact.bDoSwipeDamage = true;
    Impact.CustomDamageType = class<KFDamageType>(PendingMeleeWeapon.InstantHitDamageTypes[PendingMeleeWeapon.CurrentFireMode]);
    Impact.SwipeDirection = PendingMeleeWeapon.ChooseAttackDir();
    
    AIHelper = New(Instigator) class'KFMeleeHelperAI';
    AIHelper.SetMeleeRange(PendingMeleeWeapon.MeleeAttackHelper.MaxHitRange);
    AIHelper.WorldImpactEffects = PendingMeleeWeapon.MeleeAttackHelper.WorldImpactEffects;
    AIHelper.BaseDamage = PendingMeleeWeapon.InstantHitDamage[PendingMeleeWeapon.CurrentFireMode];
    AIHelper.MeleeImpactNotify(Impact);
        
    PendingMeleeNotify = None;
    PendingMeleeWeapon = None;
}
*/

defaultproperties
{
}
