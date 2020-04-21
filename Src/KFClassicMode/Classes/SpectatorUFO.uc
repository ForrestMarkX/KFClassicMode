Class SpectatorUFO extends Actor
    implements(SpectatorObject);

var const editconst StaticMeshComponent StaticMeshComponent;
var PlayerController PlayerOwner;
var Vector RandOffset;
var MaterialInstanceConstant MIC;
var repnotify Color CurrentColor;

replication
{
    if( true )
        PlayerOwner, CurrentColor;
}

`include(VisSpectatorLoc.uci);

simulated function ReplicatedEvent(name VarName)
{
    local LinearColor LC;
    
    if( VarName == 'CurrentColor' )
    {
        LC = ColorToLinearColor(CurrentColor);
        MIC.SetVectorParameterValue('Scalar_Glow_Color', LC);
    }
    else Super.ReplicatedEvent(VarName);
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
    SetPhysics(PHYS_Rotating);
    
    RepLink = class'ClientPerkRepLink'.static.FindContentRep(WorldInfo);
    if( RepLink != None )
    {
        StaticMeshComponent.SetStaticMesh(StaticMesh(RepLink.ObjRef.ReferencedObjects[166]), true);
    }
    
    MIC = StaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
}

function SetColor(Color C)
{
    CurrentColor = C;
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
