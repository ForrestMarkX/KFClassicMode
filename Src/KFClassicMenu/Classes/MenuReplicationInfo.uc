Class MenuReplicationInfo extends ClassicPlayerReplicationInfo;

simulated function ChangeCharacter( byte CharIndex, optional bool bFirstSet );
simulated function UpdateCustomization( byte Type, int MeshIndex, int SkinIndex, optional int SlotIndex );

simulated function CharacterCustomizationChanged()
{
    Super(KFPlayerReplicationInfo).CharacterCustomizationChanged();
}

defaultproperties
{
}