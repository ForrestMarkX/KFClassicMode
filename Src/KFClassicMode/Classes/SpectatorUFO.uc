Class SpectatorUFO extends Actor
    implements(SpectatorObject);

var const editconst StaticMeshComponent StaticMeshComponent;
var PlayerController PlayerOwner;
var Vector RandOffset;

replication
{
    if( true )
        PlayerOwner;
}

simulated function PostBeginPlay()
{
    local rotator R;
    local ClientPerkRepLink RepLink;
    
    Super.PostBeginPlay();
    
    R.Pitch = Rand(2672);
    R.Yaw = Rand(65536);
    SetRotation(R);
    
    RandOffset.X = FRand()*40.f-20.f;
    RandOffset.Y = FRand()*40.f-20.f;
    RandOffset.Z = FRand()*25.f+10.f;
    RotationRate.Yaw = 8192+Rand(32768);
    
    RepLink = class'ClientPerkRepLink'.static.FindContentRep(WorldInfo);
    if( RepLink != None )
    {
        StaticMeshComponent.SetStaticMesh(StaticMesh(RepLink.ObjRef.ReferencedObjects[166]), true);
    }
    
    StaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
}

simulated function Tick(float DT)
{
    local KFPawn SpectatedPawn;
    local Vector CameraLoc, Loc;
    local Rotator CameraRot;
    
    Super.Tick(DT);
    
    if( WorldInfo.NetMode == NM_Client )
        StaticMeshComponent.SetRotation(StaticMeshComponent.Rotation + (RotationRate * DT));
    
    if( PlayerOwner == None )
        return;

    SpectatedPawn = KFPawn(PlayerOwner.GetViewTarget());
    if( SpectatedPawn != None )
    {
        if( WorldInfo.NetMode != NM_DedicatedServer && bHidden && PlayerOwner == GetALocalPlayerController() )
            SetHidden(false);
            
        Loc = SpectatedPawn.Location+(SpectatedPawn.CylinderComponent.CollisionHeight*vect(0,0,1))+RandOffset;
        if( Loc != Location )
            SetLocation(Loc);
    }
    else 
    {
        if( WorldInfo.NetMode != NM_DedicatedServer && !bHidden && PlayerOwner == GetALocalPlayerController() )
            SetHidden(true);
            
        PlayerOwner.GetPlayerViewPoint(CameraLoc, CameraRot);
        if( CameraLoc != Location )
            SetLocation(CameraLoc);
    }
}

function SetColor(Color C)
{
    local LinearColor LC;
    
    LC = ColorToLinearColor(C);
    MaterialInstanceConstant(StaticMeshComponent.GetMaterial(0)).SetVectorParameterValue('Scalar_Glow_Color', LC);
}

function Vector GetLocation()
{
    return Location;
}

function Remove()
{
    Destroy();
}

function SetPlayerOwner(PlayerController C)
{
    PlayerOwner = C;
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'KFClassicMode_Assets.UFO.UFO_SM'
    End Object
    CollisionComponent=StaticMeshComponent0
    StaticMeshComponent=StaticMeshComponent0
    Components.Add(StaticMeshComponent0)
    
    bUpdateSimulatedPosition=true
    RemoteRole=ROLE_SimulatedProxy
    DrawScale=0.12
}
