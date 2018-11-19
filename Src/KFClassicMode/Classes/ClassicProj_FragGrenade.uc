class ClassicProj_FragGrenade extends KFProj_FragGrenade;

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
    
    if( class<KFDT_Explosive_FragGrenade>(DamageType) != None && (EventInstigator == InstigatorController || (DamageCauser != None && DamageCauser.Instigator == Instigator)) )
    {
        ClearTimer('ExplodeTimer');
        ExplodeTimer();
    }
}

defaultproperties
{
    AssociatedPerkClass=class'ClassicPerk_Base'
}


