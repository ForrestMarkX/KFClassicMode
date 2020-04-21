Class HealProj extends KFProj_HealingDart_MedicBase;

simulated function Tick( float Delta )
{
    local vector D;
    
    Super(KFProj_Bullet).Tick(Delta);
    
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
	ProjFlightTemplate=ParticleSystem'KFClassicMode_Assets.UFO.FX_Healer_Ball'
	ProjFlightTemplateZedTime=ParticleSystem'KFClassicMode_Assets.UFO.FX_Healer_Ball'
    
    Speed=250.f
    MaxSpeed=500.f
    Damage=3.f
    bCollideActors=False
}