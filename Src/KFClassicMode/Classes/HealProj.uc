Class HealProj extends Projectile;

var Actor SeekTarget;
var ParticleSystemComponent	ParticleSystemComponent;
var ParticleSystem ProjectileTemplate;

simulated function PreBeginPlay()
{
    local ClientPerkRepLink RepLink;
    
    RepLink = class'ClientPerkRepLink'.static.FindContentRep(WorldInfo);
    if( RepLink != None )
    {
        ProjectileTemplate = ParticleSystem(RepLink.ObjRef.ReferencedObjects[165]);
    }
    
    Super.PreBeginPlay();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    ParticleSystemComponent.SetTemplate(ProjectileTemplate);
    ParticleSystemComponent.ActivateSystem();
}

simulated function Tick( float Delta )
{
	local vector D;
    
    Super.Tick(Delta);
	
	if( SeekTarget==None || SeekTarget.bDeleteMe )
	{
		Destroy();
		return;
	}
	D = SeekTarget.Location-Location;
	if( VSize(D)<(Speed*Delta*2.f) )
	{
		if( WorldInfo.NetMode!=NM_Client && Pawn(SeekTarget).Health>0 )
            SeekTarget.HealDamage(Damage,InstigatorController,class'KFDT_Dart_Healing',false,false);
		Destroy();
		return;
	}
	Velocity = Normal(D)*Speed;
	Speed+=(Delta*150.f);
}

defaultproperties
{
    Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
        SecondsBeforeInactive=1
        bUpdateComponentInTick=true
    End Object
    ParticleSystemComponent=ParticleSystemComponent0
    Components.Add(ParticleSystemComponent0)
    
    ProjectileTemplate=ParticleSystem'KFClassicMode_Assets.UFO.FX_Healer_Ball'
    
    Speed=250.f
    MaxSpeed=500.f
    Damage=3.f
    bCollideActors=False
}