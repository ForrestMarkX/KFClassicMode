class UIR_ItemBase extends KFGUI_MultiComponent;

var KFGUI_Button BuyMagB, FillAmmoB, PurchaseVest;

var STraderItem Buyable;
var SItemInformation Sellable;

var Texture CurrentIcon;
var string CurrentName;

var UI_TraderMenu TraderMenu;
var ClassicPlayerController PC;

var byte PressedDown[2];
var bool bPressedDown;

var bool bIsSecondaryAmmo;

var transient bool bIsFocused,bSelected,bUsesAmmo,bIsArmor,bIsGrenade,bLocked;
var float BackgroundWidth,BackgroundHeight;

var int ItemIndex;

function InitMenu()
{
    Super.InitMenu();
    
    bClickable = !bDisabled;
    TraderMenu = UI_TraderMenu(ParentComponent);
    
    PC = ClassicPlayerController(GetPlayer());

    SetTimer( 1.f, true, nameof(Refresh) );
    Refresh(true);
}

function PreDraw()
{
    bIsFocused = ( Owner.MousePosition.X>=CompPos[0] && Owner.MousePosition.Y>=CompPos[1] && Owner.MousePosition.X<=(CompPos[0]+((CompPos[2]+CompPos[3]) * BackgroundWidth)) && Owner.MousePosition.Y<=(CompPos[1]+CompPos[3]) );
    if( bSelected )
    {
        bIsFocused = true;
    }
        
    Super.PreDraw();
}

function DoubleMouseClick( bool bRight )
{
    if( !bDisabled && bClickable && bIsFocused )
    {
        PressedDown[byte(bRight)] = 0;
        bPressedDown = (PressedDown[0]!=0 || PressedDown[1]!=0);
        OnDblClicked(self,bRight,Owner.MousePosition.X-CompPos[0],Owner.MousePosition.Y-CompPos[1]);
    }
}

function MouseClick( bool bRight )
{
    if( !bDisabled && bClickable )
    {
        PressedDown[byte(bRight)] = 1;
        bPressedDown = true;
    }
}

function MouseRelease( bool bRight )
{
    if( !bDisabled && bClickable && PressedDown[byte(bRight)]==1 && bIsFocused && !bSelected )
    {
        PlayMenuSound(MN_ClickButton);
        PressedDown[byte(bRight)] = 0;
        bPressedDown = (PressedDown[0]!=0 || PressedDown[1]!=0);
        OnClicked(self,bRight,Owner.MousePosition.X-CompPos[0],Owner.MousePosition.Y-CompPos[1]);
    }
}

function MouseLeave()
{
    Super.MouseLeave();

    PressedDown[0] = 0;
    PressedDown[1] = 0;
    bPressedDown = false;
}

function ScrollMouseWheel( bool bUp )
{
    if( KFGUI_List(ParentComponent) != None )
    {
        if( !KFGUI_List(ParentComponent).ScrollBar.bDisabled )
            KFGUI_List(ParentComponent).ScrollBar.ScrollMouseWheel(bUp);
    }
}

function SetBuyable( STraderItem Info )
{
    local ClassicPerk_Base Perk;
    local ClassicPerkManager PerkManager;
    local byte i;
    
    Buyable = Info;
    CurrentName = Info.WeaponDef.static.GetItemName();
    
    PerkManager = ClassicPlayerController(GetPlayer()).PerkManager;
    if( PerkManager != None )
    {
        if( Buyable.AssociatedPerkClasses.Length > 0 && Buyable.AssociatedPerkClasses[0] != None)
        {
            for( i=0; i<PerkManager.UserPerks.Length; ++i )
            {
                if( PerkManager.UserPerks[i].BasePerk == Buyable.AssociatedPerkClasses[0] )
                {
                    Perk = PerkManager.UserPerks[i];
                    break;
                }
            }
            
            if( Perk != None )
            {
                CurrentIcon = Perk.static.GetCurrentPerkIcon(0);
            }
        }
    }
    
    if( CurrentIcon == None )
    {
        CurrentIcon = Texture(DynamicLoadObject(class'KFGFxObject_TraderItems'.default.OffPerkIconPath, class'Texture'));
    }
    
    Refresh(true);
}

function SetSellable( SItemInformation Info, optional bool bHasAmmo )
{
    local ClassicPerk_Base Perk;
    local ClassicPerkManager PerkManager;
    local KFAutoPurchaseHelper KFAPH;
    local byte i;
    
    KFAPH = PC.GetPurchaseHelper();
    Sellable = Info;
    bUsesAmmo = bHasAmmo;
    bIsArmor = (Info == KFAPH.ArmorItem);
    bIsGrenade = (Info == KFAPH.GrenadeItem);
    
    if( bIsSecondaryAmmo )
    {
        CurrentName = Info.DefaultItem.WeaponDef.static.GetItemLocalization("SecondaryAmmo");
    }
    else
    {
        CurrentName = Info.DefaultItem.WeaponDef.static.GetItemName();
    }
    
    PerkManager = ClassicPlayerController(GetPlayer()).PerkManager;
    if( PerkManager != None )
    {
        if( Sellable.DefaultItem.AssociatedPerkClasses.Length > 0 && Sellable.DefaultItem.AssociatedPerkClasses[0] != None)
        {
            for( i=0; i<PerkManager.UserPerks.Length; ++i )
            {
                if( PerkManager.UserPerks[i].BasePerk == Sellable.DefaultItem.AssociatedPerkClasses[0] )
                {
                    Perk = PerkManager.UserPerks[i];
                    break;
                }
            }
            
            if( Perk != None )
            {
                CurrentIcon = Perk.static.GetCurrentPerkIcon(0);
            }
        }
    }
    
    if( CurrentIcon == None )
    {
        CurrentIcon = Texture(DynamicLoadObject(class'KFGFxObject_TraderItems'.default.OffPerkIconPath, class'Texture'));
    }
    
    if( bHasAmmo )
    {
        BuyMagB = AddButton('BuyMagB', Chr(208)@bIsSecondaryAmmo ? Sellable.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice : Sellable.AmmoPricePerMagazine, 0.775, 0.25, 0.1, 0.5);

        FillAmmoB = AddButton('FillAmmoB', Chr(208)@(Sellable == KFAPH.GrenadeItem ? KFAPH.GetFillGrenadeCost() : KFAPH.GetFillAmmoCost(Sellable)), 0.89, 0.25, 0.16, 0.5);
        FillAmmoB.GamepadButtonName = "XboxTypeS_X";
    }
    else if( bIsArmor )
    {
        PurchaseVest = AddButton('PurchaseVest', Chr(208)@KFAPH.GetFillArmorCost(), 0.775, 0.25, 0.275, 0.5);
        PurchaseVest.GamepadButtonName = "XboxTypeS_X";
    }
    
    Refresh(true);
}

final function KFGUI_Button AddButton(name ButtonID, coerce string S, float X, float Y, float XL, float YL)
{
    local KFGUI_Button But;
    
    But = new(Self) class'KFGUI_Button';
    But.ButtonText = S;
    But.XPosition = X;
    But.YPosition = Y;
    But.XSize = XL;
    But.YSize = YL;
    But.OnClickLeft = InternalOnClick;
    But.OnClickRight = InternalOnClick;
    But.ID = ButtonID;
    
    AddComponent(But);
    return But;
}

function InternalOnClick( KFGUI_Button Sender );
function Refresh(optional bool bForce);

delegate OnClicked( UIR_ItemBase Sender, bool bRight, int MouseX, int MouseY );
delegate OnDblClicked( UIR_ItemBase Sender, bool bRight, int MouseX, int MouseY );

defaultproperties
{
    BackgroundWidth=1.f
    BackgroundHeight=0.75f
}