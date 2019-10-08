class ShockProj extends KFProj_Bullet_LazerCutter;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    local TraceHitInfo HitInfo;
    
    if( KFPawn_Monster(Other) != None )
    {
        if( CheckRepeatingTouch(Other) )
        {
            return;
        }
            
        Other.TakeDamage(Damage, InstigatorController, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
    }
    
    if ( KFPawn_Human(Other) == None )
    {
        if ( Pawn(Other) == None && bDamageDestructiblesOnTouch && Other.bCanBeDamaged )
        {
            HitInfo.HitComponent = LastTouchComponent;
            HitInfo.Item = INDEX_None;
            Other.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType, HitInfo, self);
        }
        
        Super(KFProjectile).ProcessTouch(Other, HitLocation, HitNormal);
    }
}

simulated function ProcessBulletTouch(Actor Other, Vector HitLocation, Vector HitNormal);

defaultproperties
{
    MaxSpeed=10000.0
    Speed=1000.0
    LifeSpan=16.0f
    
    bDamageDestructiblesOnTouch=true
    bUseClientSideHitDetection=false
    
    Damage=25.0
    MyDamageType=class'KFDT_Shock_Projectile'
}
