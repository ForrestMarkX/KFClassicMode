class TestStandardAchievementPack extends StandardAchievementPack;

enum TestSapIndex 
{
    EXPERIMENTIMILLICIDE,
    AMMO_COLLECTOR,
    WATCH_YOUR_STEP,
    FIRE_IN_THE_HOLE,
    BLOODY_RUSSIANS,
    NOT_THE_FACE,
    SAVOR_EMOTIONS,
    MERDE
};

private function checkBloodyRussians(Weapon CurrentWeapon) 
{
    if (!Achievements[BLOODY_RUSSIANS].Completed && CurrentWeapon.IsA('KFWeap_AssaultRifle_AK12') && !CurrentWeapon.HasAmmo(0)) 
    {
        if (Achievements[BLOODY_RUSSIANS].Progress == Achievements[BLOODY_RUSSIANS].MaxProgress) 
        {
            AchievementCompleted(BLOODY_RUSSIANS);
        } 
        else 
        {
            Achievements[BLOODY_RUSSIANS].Progress = 0;
        }
    }
}

function MatchEnded(const out MatchInfo Info) 
{
    if (Info.Result == SA_MR_LOST && Locs(Info.MapName) == "kf-burningparis") 
    {
        AchievementCompleted(MERDE);
    }
}

function waveStarted(byte newWave, byte waveMax) 
{
    if (!Achievements[FIRE_IN_THE_HOLE].Completed) 
    {
        ResetProgress(FIRE_IN_THE_HOLE);
    }
}

function TossedGrenade(class<KFProj_Grenade> GrenadeClass) 
{
    AddProgress(FIRE_IN_THE_HOLE, 1);
}

function ReloadedWeapon(Weapon CurrentWeapon) 
{
    Achievements[BLOODY_RUSSIANS].Progress = 0;
}

function StoppedFiringWeapon(Weapon CurrentWeapon) 
{
    CheckBloodyRussians(CurrentWeapon);
}

function Died(Controller Killer, class<DamageType> DamageType) 
{
    if (DamageType == class'KFDT_Falling') 
    {
        AddProgress(WATCH_YOUR_STEP, 1);
    }
}

function KilledMonster(Pawn Target, class<DamageType> DamageType) 
{
    AddProgress(EXPERIMENTIMILLICIDE, 1);

    if (ClassIsChildOf(DamageType, class'KFDT_Ballistic_AK12')) 
    {
        Achievements[BLOODY_RUSSIANS].Progress++;
    } 
    else if (ClassIsChildOf(DamageType, class'KFDT_Slashing_Knife') || ClassIsChildOf(DamageType, class'KFDT_Piercing_KnifeStab')) 
    {
        AddProgress(SAVOR_EMOTIONS, 1);
    }
}

function PickedUpItem(Actor Item) 
{
    if (Item.IsA('KFPickupFactory_Ammo')) 
    {
        AddProgress(AMMO_COLLECTOR, 1);
    }
}

function DamagedMonster(int Damage, Pawn Target, class<DamageType> DamageType, bool Headshot) 
{
    if (Headshot && ClassIsChildOf(DamageType, class'KFDT_Bludgeon')) 
    {
        AddProgress(NOT_THE_FACE, 1);
    }
}

defaultproperties
{
    Achievements[0]=(MaxProgress=1000,nNotifies=4)
    Achievements[1]=(MaxProgress=15,HideProgress=true,DiscardProgress=true)
    Achievements[2]=(MaxProgress=10)
    Achievements[3]=(MaxProgress=5,HideProgress=true,DiscardProgress=true)
    Achievements[4]=(MaxProgress=1,HideProgress=true,DiscardProgress=true)
    Achievements[5]=(MaxProgress=50,nNotifies=2)
    Achievements[6]=(MaxProgress=100,nNotifies=4)
    Achievements[7]=(HideProgress=true,DiscardProgress=true)
}
