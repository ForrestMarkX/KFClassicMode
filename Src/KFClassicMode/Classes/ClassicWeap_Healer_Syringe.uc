class ClassicWeap_Healer_Syringe extends KFWeap_Healer_Syringe;

function AttachThirdPersonWeapon( KFPawn P )
{
    local ClassicPlayerController KFPC;
    
    Super.AttachThirdPersonWeapon(P);
    
    foreach WorldInfo.AllControllers( class'ClassicPlayerController', KFPC )
    {
        KFPC.ClientUpdateAttachmentSkin( 0, P, MaterialInstanceConstant'WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_3P_Mint_MIC' );
    }
}

defaultproperties
{
    Begin Object Name=FirstPersonMesh
        Animations=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Animtree_Healer'
        Materials(0)=MaterialInstanceConstant'WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_1P_Mint_MIC'
    End Object
    
    FireInterval(DEFAULT_FIREMODE)=2.25
    AmmoCost(DEFAULT_FIREMODE)=50
}
