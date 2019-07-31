Class MenuPawn extends ClassicHumanPawn;

simulated function KFCharacterInfoBase GetCharacterInfo()
{
    return Super(KFPawn_Human).GetCharacterInfo();
}

simulated function SetCharacterArch(KFCharacterInfoBase Info, optional bool bForce )
{
    Super(KFPawn_Human).SetCharacterArch(Info, bForce);
}

defaultproperties
{
}