class ClassicGearContainer_PerksSelection extends KFGFxGearContainer_PerksSelection;

function UpdatePerkSelection( byte SelectedPerkIndex )
{
     local int i;
    local GFxObject DataProvider;
    local GFxObject TempObj;
    local ClassicPlayerController KFPC;
    local ClassicPerk_Base PerkClass;    

    KFPC = ClassicPlayerController( GetPC() );

    if ( KFPC!=none && KFPC.PerkManager!=None )
    {
           DataProvider = CreateArray();

        for (i = 0; i < KFPC.PerkList.Length; i++)
        {
            PerkClass = KFPC.PerkManager.FindPerk(KFPC.PerkList[i].PerkClass);
            
            TempObj = CreateObject( "Object" );
            TempObj.SetInt( "PerkLevel", PerkClass.GetLevel() );
            TempObj.SetString( "Title",  PerkClass.static.GetPerkName() );    
            TempObj.SetString( "iconSource",  "img://"$PathName(PerkClass.static.GetCurrentPerkIcon(PerkClass.GetLevel())) );
            TempObj.SetBool( "bTierUnlocked", false );
            
            DataProvider.SetElementObject( i, TempObj );
        }    
        SetObject( "perkData", DataProvider );
        SetInt("SelectedIndex", SelectedPerkIndex);
        
        KFPC.ServerChangePerks(KFPC.PerkManager.FindPerk(KFPC.PerkList[SelectedPerkIndex].PerkClass));
    }
}