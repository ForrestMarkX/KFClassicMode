class UIR_TraderPlayerInventory extends UIR_ItemBase;

function DrawMenu()
{
    local float FontScalar, XL, YL, TempX, TempY, ArmorPercent;
    local string S;
    local KFPawn_Human P;
    
    bIsFocused = ( Owner.MousePosition.X>=CompPos[0] && Owner.MousePosition.Y>=CompPos[1] && Owner.MousePosition.X<=(CompPos[0]+((CompPos[2]+CompPos[3]) * BackgroundWidth)) && Owner.MousePosition.Y<=(CompPos[1]+CompPos[3]) );
    if( bSelected )
        bIsFocused = true;
    
    Canvas.SetDrawColor(250,250,250,255);
    Canvas.SetPos(0.f,0.f);
    Owner.CurrentStyle.DrawTileStretched(bIsFocused ? Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_HIGHLIGHTED] : Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL],0.f,0.f,CompPos[3],CompPos[3]);
    
    if( CurrentIcon != None )
    {
        Canvas.SetDrawColor(255, 0, 0, 255);
        Canvas.SetPos(4, 4);
        Canvas.DrawTile(CurrentIcon, CompPos[3] - 8, CompPos[3] - 8, 0, 0, 256, 256);
    }
    
    TempX = CompPos[3];
    TempY = (CompPos[3]/2) - ((CompPos[3] * BackgroundHeight)/2);
    
    Canvas.SetDrawColor(255, 255, 255, 255);
    Owner.CurrentStyle.DrawTileStretched(bIsFocused ? Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_HIGHLIGHTED] : Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_NORMAL], TempX, TempY, CompPos[2] * BackgroundWidth, CompPos[3] * BackgroundHeight);
    
    S = CurrentName;
    Canvas.Font = Owner.CurrentStyle.PickFont(FontScalar);
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.SetPos(CompPos[3] * 1.25, (CompPos[3]/2) - (YL/1.75));
    Canvas.DrawText(S,,FontScalar,FontScalar);
    
    if( bUsesAmmo || bIsArmor )
    {
        Canvas.SetDrawColor(255, 255, 255, 255);
        
        TempX = CompPos[2] * 0.6115;
        TempY = CompPos[3] * 0.25;
        
        Owner.CurrentStyle.DrawTileStretched(Owner.CurrentStyle.BorderTextures[`BOX_INNERBORDER_TRANSPARENT], TempX, TempY, CompPos[2] * 0.15, CompPos[3] * 0.5);
        
        if( bIsArmor )
        {
            P = KFPawn_Human(GetPlayer().Pawn);
            if( P != None )
            {
                ArmorPercent = FMin(float(P.Armor) / float(P.MaxArmor), 1.f);
                S = int(ArmorPercent*100.f)$"%";
            }
        }
        else 
        {
            if( bIsSecondaryAmmo )
                S = Sellable.SecondaryAmmoCount$"/"$Sellable.MaxSecondaryAmmo;
            else S = Sellable.SpareAmmoCount$"/"$Sellable.MaxSpareAmmo;
        }
        
        Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
        Canvas.SetPos(TempX + (((CompPos[2] * 0.15)/2) - (XL/2)), TempY + (((CompPos[3] * 0.5)/2) - (YL/1.75)));
        Canvas.DrawText(S,,FontScalar,FontScalar);
    }
}

function InternalOnClick( KFGUI_Button Sender )
{
    local KFAutoPurchaseHelper KFAPH;
    
    KFAPH = PC.GetPurchaseHelper();
    switch( Sender.ID )
    {
        case 'BuyMagB':
            if( KFAPH.GetCanAfford(bIsSecondaryAmmo ? Sellable.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice : Sellable.AmmoPricePerMagazine) )
            {
                if( bIsGrenade )
                {
                    KFAPH.BuyGrenade();
                    Sellable = KFAPH.GrenadeItem;
                }
                else
                {
                    KFAPH.BuyMagazine(ItemIndex);
                    Sellable = KFAPH.OwnedItemList[ItemIndex];
                }
                
                RefreshTraderItems();
            }
            break;
        case 'FillAmmoB':
            if( KFAPH.TotalDosh > 0 )
            {
                KFAPH.FillAmmo(bIsGrenade ? KFAPH.GrenadeItem : Sellable, bIsGrenade);
                
                //Prevents ammo from getting reset on a refresh
                if( !bIsGrenade )
                    KFAPH.OwnedItemList[ItemIndex] = Sellable;
                else Sellable = KFAPH.GrenadeItem;
                
                RefreshTraderItems();
            }
            break;
        case 'PurchaseVest':
            if( KFAPH.TotalDosh > 0 )
            {
                KFAPH.FillArmor();
                Sellable = KFAPH.ArmorItem;
                RefreshTraderItems();
            }
            break;    
    }
}

function RefreshTraderItems()
{
    if( PC.TraderMenu != None )
    {
        PC.TraderMenu.Inv.RefreshItemComponents();
        PC.TraderMenu.Sale.RefreshItemComponents();
    }
}

function Refresh(optional bool bForce)
{
    local int ArmorPrice,FillPrice;
    local KFAutoPurchaseHelper KFAPH;
    local float MissingAmmo, MagSize;
    local float PricePerMag;
    local float PricePerRound;
    local float AmmoCostScale;
    local KFGameReplicationInfo KFGRI;
    
    KFAPH = PC.GetPurchaseHelper();
    ArmorPrice = KFAPH.GetFillArmorCost();
    FillPrice = Max(bIsGrenade ? KFAPH.GetFillGrenadeCost() : KFAPH.GetFillAmmoCost(Sellable), 0);
    
    if( BuyMagB != None )
    {
        BuyMagB.ButtonText = "£" @ Sellable.AmmoPricePerMagazine;
        
        if( !KFAPH.GetCanAfford(bIsSecondaryAmmo ? Sellable.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice : Sellable.AmmoPricePerMagazine) || (bIsSecondaryAmmo ? Sellable.SecondaryAmmoCount == Sellable.MaxSecondaryAmmo : Sellable.SpareAmmoCount == Sellable.MaxSpareAmmo) )
            BuyMagB.bDisabled = true;
        else BuyMagB.bDisabled = false;
    }
    
    if( FillAmmoB != None )
    {
        KFGRI = KFGameReplicationInfo(PC.WorldInfo.GRI);
        if( KFGRI != None )
        {
            AmmoCostScale = KFGRI.GameAmmoCostScale;
        }
        else
        {
            AmmoCostScale = 1.0;
        }
        
        if( Sellable.bIsSecondaryAmmo )
        {
            MagSize = Sellable.DefaultItem.WeaponDef.default.SecondaryAmmoMagSize;
            PricePerMag = AmmoCostScale * Sellable.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice;
            MissingAmmo = Sellable.MaxSecondaryAmmo - Sellable.SecondaryAmmoCount;
        }
        else
        {
            MagSize = Sellable.DefaultItem.MagazineCapacity;
            PricePerMag = Sellable.AmmoPricePerMagazine;
            MissingAmmo = Sellable.MaxSpareAmmo - Sellable.SpareAmmoCount;
        }

        if ( FillPrice > KFAPH.TotalDosh )
        {
            if( bIsGrenade )
                PricePerRound = PricePerMag;
            else PricePerRound = (MagSize > 0) ? PricePerMag / MagSize : 0.f;

            MissingAmmo = FFloor(KFAPH.TotalDosh / PricePerRound);
        }
            
        FillAmmoB.ButtonText = "£" @ FillPrice;
        FillAmmoB.bDisabled = !GetButtonEnabled(PricePerRound, Sellable.SpareAmmoCount, Sellable.MaxSpareAmmo, MissingAmmo);
    }
    
    if( PurchaseVest != None )
    {
        if ( KFAPH.ArmorItem.SpareAmmoCount == 0 )
        {
            PurchaseVest.ButtonText = "Buy: £" @ ArmorPrice;
        }
        else if ( KFAPH.ArmorItem.SpareAmmoCount == KFAPH.ArmorItem.MaxSpareAmmo )
        {
            PurchaseVest.ButtonText = "Purchased";
        }
        else
        {
            PurchaseVest.ButtonText = "Repair: £" @ ArmorPrice;
        }
        
        PurchaseVest.bDisabled = !GetButtonEnabled(KFAPH.ArmorItem.AmmoPricePerMagazine, KFAPH.ArmorItem.SpareAmmoCount, KFAPH.ArmorItem.MaxSpareAmmo);
    }
}

function bool GetButtonEnabled( float Price, int SpareAmmoCount, int MaxSpareAmmoCount, optional int MissingAmmo=-1 )
{
    local int Dosh;
    
    Dosh = PC.GetPurchaseHelper().TotalDosh;
    if( SpareAmmoCount >= MaxSpareAmmoCount || Dosh < Price || Dosh <= 0 || MissingAmmo == 0 )
        return false;
        
    return true;
}

defaultproperties
{
    BackgroundWidth=0.5f
}