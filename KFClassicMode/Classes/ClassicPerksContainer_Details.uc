class ClassicPerksContainer_Details extends KFGFxPerksContainer_Details;

`define AddWeaponsInfo(InClassDef) if( `InClassDef!=None ) AddWeaponInfo(WeaponNames, WeaponSources, `InClassDef.static.GetItemName(), `InClassDef.static.GetImagePath())

function UpdateDetails( class<KFPerk> PerkClass )
{
    local GFxObject DetailsProvider;
    local ClassicPlayerController KFPC;
    local array<string> WeaponNames;
    local array<string> WeaponSources;
    local int i, Level;
    local ClassicPerk_Base Perk;
    local class<KFWeaponDefinition> WeaponDef, SecondaryDef, KnifeDef, GrenadeDef;

    DetailsProvider = CreateObject( "Object" );

    KFPC = ClassicPlayerController( GetPC() );  
    if ( KFPC != None && KFPC.PerkManager != None )
    {
        Perk = KFPC.PerkManager.FindPerk(PerkClass);
        if( Perk != None )
        {
            Level = Perk.GetLevel();
            
            DetailsProvider.SetString( "ExperienceMessage", ExperienceString @ Perk.CurrentEXP );
            
            WeaponDef = Perk.static.GetWeaponDef(Level);
            if( WeaponDef != None )
            {
                `AddWeaponsInfo(WeaponDef);
            }
                
            SecondaryDef = Perk.static.GetSecondaryDef(Level);
            if( SecondaryDef != None )
            {
                `AddWeaponsInfo(SecondaryDef);
            }
                
            KnifeDef = Perk.static.GetKnifeDef(Level);
            if( KnifeDef != None )
            {
                `AddWeaponsInfo(KnifeDef);
            }
            
            GrenadeDef = Perk.static.GetGrenadeDef(Level);
            if( GrenadeDef != None )
            {
                `AddWeaponsInfo(GrenadeDef);
            }
        
            for (i = 0; i < WeaponNames.length; i++)
            {
                DetailsProvider.SetString( "WeaponName" $ i, WeaponNames[i] );        
                DetailsProvider.SetString( "WeaponImage" $ i, "img://"$WeaponSources[i] );            
            }

            DetailsProvider.SetString( "EXPAction1", Perk.EXPActions[0] );
            DetailsProvider.SetString( "EXPAction2", Perk.EXPActions[1] );        

            SetObject( "detailsData", DetailsProvider );
        }
    }
}

function UpdatePassives( class<KFPerk> PerkClass )
{
    local GFxObject PassivesProvider;
    local GFxObject PassiveObject;
    local ClassicPlayerController KFPC;
    local array<string> PassiveValues, Increments;
    local byte i;
    local ClassicPerk_Base Perk;
    local array<PassiveInfo> Infos;
    
    KFPC = ClassicPlayerController( GetPC() );
      if ( KFPC != None && KFPC.PerkManager != None )
      {
        Perk = KFPC.PerkManager.FindPerk(PerkClass);
        if( Perk != None )
        {
            Infos = Perk.static.GetPerkInfoStrings( Perk.GetLevel() );
            
            Perk.static.GetPassiveStrings( PassiveValues, Increments, Perk.GetLevel() );

            PassivesProvider = CreateArray();
            for ( i = 0; i < PassiveValues.length; i++ )
            {
                PassiveObject = CreateObject( "Object" );
                PassiveObject.SetString( "PassiveTitle", Infos[i].Title );
                PassiveObject.SetString( "PerkBonusModifier", Increments[i]); 
                PassiveObject.SetString( "PerkBonusAmount", PassiveValues[i] );
                PassivesProvider.SetElementObject( i, PassiveObject );
            }
        }
    }

    SetObject( "passivesData", PassivesProvider );
}

defaultproperties
{
}