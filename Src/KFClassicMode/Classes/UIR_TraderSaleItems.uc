class UIR_TraderSaleItems extends UIR_ItemBase;

var int CurrentBuyPrice;

function DrawMenu()
{
    local float FontScalar, XL, YL, TempX, TempY;
    local string S;
    local Texture BackgroundImage,PerkBoxImage;
    local FontRenderInfo FRI;
    
    FRI = Canvas.CreateFontRenderInfo(true, true);
    
    if( bIsFocused )
    {
        PerkBoxImage = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_HIGHLIGHTED];
    }
    else if( bLocked )
    {
        PerkBoxImage = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_DISABLED];
    }
    else
    {
        PerkBoxImage = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_NORMAL];
    }
    
    Canvas.SetDrawColor(250,250,250,255);
    Owner.CurrentStyle.DrawTileStretched(PerkBoxImage,0.f,0.f,CompPos[3],CompPos[3]);
    
    if( CurrentIcon != None )
    {
        Canvas.SetDrawColor(255, 15, 15, 255);
        Canvas.SetPos(4, 4);
        Canvas.DrawTile(CurrentIcon, CompPos[3] - 8, CompPos[3] - 8, 0, 0, 256, 256);
    }
    
    TempX = CompPos[3];
    TempY = (CompPos[3]/2) - ((CompPos[3] * BackgroundHeight)/2);
    
    if( bIsFocused )
    {
        BackgroundImage = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_HIGHLIGHTED];
    }
    else if( bLocked )
    {
        BackgroundImage = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_DISABLED];
    }
    else
    {
        BackgroundImage = Owner.CurrentStyle.ItemBoxTextures[`ITEMBOX_BAR_NORMAL];
    }
    
    Canvas.SetDrawColor(255, 255, 255, 255);
    Owner.CurrentStyle.DrawTileStretched(BackgroundImage, TempX, TempY, (CompPos[2] - CompPos[3]) * BackgroundWidth, CompPos[3] * BackgroundHeight);
    
    Canvas.Font = Owner.CurrentStyle.PickFont(FontScalar);
    
    S = CurrentName;
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.SetPos(CompPos[3] * 1.25, (CompPos[3]/2) - (YL/1.75));
    Canvas.DrawText(S,,FontScalar,FontScalar,FRI);
    
    if( CurrentBuyPrice >= 10000 )
        S = Chr(208)@"10000";
    else S = Chr(208)@"1000";
    
    Canvas.TextSize(S, XL, YL, FontScalar, FontScalar);
    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.SetPos(CompPos[2] - (XL * 1.25), (CompPos[3]/2) - (YL/1.75));
    Canvas.DrawText(Chr(208) @ CurrentBuyPrice,,FontScalar,FontScalar,FRI);
}

function Refresh(optional bool bForce)
{
    local KFAutoPurchaseHelper KFAPH;
    
    KFAPH = PC.GetPurchaseHelper();
    CurrentBuyPrice = KFAPH.GetAdjustedBuyPriceFor(Buyable);
    bLocked = !KFAPH.bCanPurchase(Buyable);
}

defaultproperties
{
    BackgroundWidth=1.f
}