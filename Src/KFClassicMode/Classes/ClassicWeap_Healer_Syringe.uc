class ClassicWeap_Healer_Syringe extends KFWeap_Healer_Syringe;

defaultproperties
{
    AmmoCost(DEFAULT_FIREMODE)=50
    HealOtherRechargeSeconds=15
    
    Begin Object Name=FirstPersonMesh
        Animations=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Animtree_Healer'
    End Object
}
