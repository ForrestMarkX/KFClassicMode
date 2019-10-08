Class SpectatorFlame extends Emitter
    implements(SpectatorObject);

var ParticleSystem EmitterTemplate;
var PlayerController PlayerOwner;
var Vector RandOffset;

replication
{
    if( true )
        PlayerOwner;
}

simulated function PostBeginPlay()
{
    local ClientPerkRepLink RepLink;
    
    Super.PostBeginPlay();
    
    RandOffset.X = FRand()*40.f-20.f;
    RandOffset.Y = FRand()*40.f-20.f;
    RandOffset.Z = FRand()*25.f+10.f;
    
    RepLink = class'ClientPerkRepLink'.static.FindContentRep(WorldInfo);
    if( RepLink != None )
    {
        EmitterTemplate = ParticleSystem(RepLink.ObjRef.ReferencedObjects[167]);
    }
    else
    {
        EmitterTemplate = ParticleSystem'KFClassicMode_Assets.UFO.FX_Spectator_Flame';
    }
    
    SetTemplate(EmitterTemplate);
}

simulated function Tick(float DT)
{
    local KFPawn SpectatedPawn;
    local Vector CameraLoc, Loc;
    local Rotator CameraRot;
    
    Super.Tick(DT);
    
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

function SetColor( Color C )
{
    SetColorParameter('Color', C);
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
    bUpdateSimulatedPosition=true
    bNoDelete=false
    RemoteRole=ROLE_SimulatedProxy
}
