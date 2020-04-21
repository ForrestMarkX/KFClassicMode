Class SpectatorFlame extends Emitter
    implements(SpectatorObject);

var ParticleSystem EmitterTemplate;
var PlayerController PlayerOwner;
var Vector RandOffset;
var repnotify Color CurrentColor;

replication
{
    if( true )
        PlayerOwner, CurrentColor;
}

`include(VisSpectatorLoc.uci);

simulated function ReplicatedEvent(name VarName)
{
    if( VarName == 'CurrentColor' )
        SetColorParameter('Color', CurrentColor);
    else Super.ReplicatedEvent(VarName);
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

function SetColor( Color C )
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
    bUpdateSimulatedPosition=true
    bNoDelete=false
    RemoteRole=ROLE_SimulatedProxy
}
