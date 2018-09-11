class ClassicTraderContainer_Filter extends KFGFxTraderContainer_Filter;

function SetPerkFilterData(byte FilterIndex)
{
     local int i;
    local GFxObject DataProvider;
    local GFxObject FilterObject;
    local ClassicPlayerController KFPC;
    local KFPlayerReplicationInfo KFPRI;
    local ClassicPerk_Base PerkClass;

    SetBool("filterVisibliity", true);

    KFPC = ClassicPlayerController( GetPC() );
    if ( KFPC != none )
    {
        KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
        if ( KFPRI != none )
        {
            SetInt("selectedIndex", KFPRI.NetPerkIndex);

            // Set the title of this filter based on either the perk or the off perk string
            if( FilterIndex < KFPC.PerkList.Length )
            {
                SetString("filterText", class<ClassicPerk_Base>(KFPC.PerkList[FilterIndex].PerkClass).static.GetPerkName());
            }
            else
            {
                SetString("filterText", OffPerkString);
            }

               DataProvider = CreateArray();
            for (i = 0; i < KFPC.PerkList.Length; i++)
            {
                PerkClass = KFPC.PerkManager.FindPerk(KFPC.PerkList[i].PerkClass);
                
                FilterObject = CreateObject( "Object" );
                FilterObject.SetString("source",  "img://"$PathName(PerkClass.static.GetCurrentPerkIcon(PerkClass.GetLevel())));
                FilterObject.SetBool("isMyPerk",  KFPC.PerkList[i].PerkClass == KFPC.CurrentPerk.class);
                DataProvider.SetElementObject( i, FilterObject );
            }

            FilterObject = CreateObject( "Object" );
            FilterObject.SetString("source",  "img://"$class'KFGFxObject_TraderItems'.default.OffPerkIconPath);
            DataProvider.SetElementObject( i, FilterObject );

            SetObject( "filterSource", DataProvider );
        }
    }
}

DefaultProperties
{
}