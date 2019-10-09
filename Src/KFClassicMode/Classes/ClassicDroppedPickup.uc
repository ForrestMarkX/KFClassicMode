class ClassicDroppedPickup extends KFDroppedPickup;

var int MagazineAmmo[2];
var int SpareAmmo[2];

var byte UpgradeLevel;

var bool bDisablePickup;
var Pawn DroppedPawn;
var PlayerController OwnerController;
var string OwnerName;

replication
{
    if (bNetDirty)
        MagazineAmmo,SpareAmmo,UpgradeLevel,bDisablePickup,DroppedPawn,OwnerName;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    DroppedPawn = Instigator;
    if( ClassicPlayerController(Instigator.Controller) != None )
        bDisablePickup = ClassicPlayerController(Instigator.Controller).bPickupsDisabled;
        
    if( PlayerController(Instigator.Controller) != None )
        OwnerController = PlayerController(Instigator.Controller);
        
    OwnerName = DroppedPawn.GetHumanReadableName();
}

simulated function SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
    Super.SetPickupMesh(NewPickupMesh);

    if (Role == ROLE_Authority)
        SetTimer(0.2, false, nameof(UpdateInformation));
}

simulated function UpdateInformation()
{
    local KFWeapon KFW;

    KFW = KFWeapon(Inventory);
    if (KFW != None)
    {
        UpgradeLevel = byte(KFW.CurrentWeaponUpgradeIndex);

        if (KFW.UsesAmmo())
        {
            MagazineAmmo[0] = KFW.AmmoCount[0];
            SpareAmmo[0] = KFW.SpareAmmoCount[0];
        }
        
        if (KFW.UsesSecondaryAmmo() && KFW.bCanRefillSecondaryAmmo)
        {
            if (KFW.MagazineCapacity[1] > 0)
                MagazineAmmo[1] = KFW.AmmoCount[1];
            
            if (KFW.SpareAmmoCapacity[1] > 0)
                SpareAmmo[1] = KFW.SpareAmmoCount[1];
        }
    }
}

defaultproperties
{
    Lifespan=1200.f
    MagazineAmmo(0)=-1
    MagazineAmmo(1)=-1
    SpareAmmo(0)=-1
    SpareAmmo(1)=-1
}