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
			if( KFAPH.GetCanAfford(KFAPH.GetFillAmmoCost(Sellable)) )
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
			if( KFAPH.GetCanAfford(KFAPH.GetFillArmorCost()) )
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
	
	KFAPH = PC.GetPurchaseHelper();
	ArmorPrice = KFAPH.GetFillArmorCost();
	FillPrice = bIsGrenade ? KFAPH.GetFillGrenadeCost() : KFAPH.GetFillAmmoCost(Sellable);
	
	if( BuyMagB != None )
	{
		BuyMagB.ButtonText = "$" @ Sellable.AmmoPricePerMagazine;
		
		if( !KFAPH.GetCanAfford(bIsSecondaryAmmo ? Sellable.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice : Sellable.AmmoPricePerMagazine) || (bIsSecondaryAmmo ? Sellable.SecondaryAmmoCount == Sellable.MaxSecondaryAmmo : Sellable.SpareAmmoCount == Sellable.MaxSpareAmmo) )
			BuyMagB.bDisabled = true;
		else BuyMagB.bDisabled = false;
	}
	
	if( FillAmmoB != None )
	{
		FillAmmoB.ButtonText = "$" @ FillPrice;
		
		if( !KFAPH.GetCanAfford(FillPrice) || (bIsSecondaryAmmo ? Sellable.SecondaryAmmoCount == Sellable.MaxSecondaryAmmo : Sellable.SpareAmmoCount == Sellable.MaxSpareAmmo) )
			FillAmmoB.bDisabled = true;
		else FillAmmoB.bDisabled = false;
	}
	
	if( PurchaseVest != None )
	{
		if ( KFAPH.ArmorItem.SpareAmmoCount == 0 )
		{
			PurchaseVest.ButtonText = "Buy: $" @ ArmorPrice;
		}
		else if ( KFAPH.ArmorItem.SpareAmmoCount == KFAPH.ArmorItem.MaxSpareAmmo )
		{
			PurchaseVest.ButtonText = "Purchased";
		}
		else
		{
			PurchaseVest.ButtonText = "Repair: $" @ ArmorPrice;
		}
		
		if( !KFAPH.GetCanAfford(ArmorPrice) || KFAPH.ArmorItem.SpareAmmoCount == KFAPH.ArmorItem.MaxSpareAmmo )
			PurchaseVest.bDisabled = true;
		else PurchaseVest.bDisabled = false;
	}
}

defaultproperties
{
	BackgroundWidth=0.5f
}