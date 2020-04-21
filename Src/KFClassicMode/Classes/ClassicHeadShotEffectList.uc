class ClassicHeadShotEffectList extends Object
    abstract;
    
struct HeadshotEffectEx
{
	var int Id;
	var string ItemName, EffectPSName, IconPathSmall, IconPathLarge;
    var edithide transient ParticleSystem EffectPS;
    var AkEvent HeadshotSoundEffect;
    
	structdefaultproperties
	{
		Id=INDEX_NONE
	}
};
var array<HeadshotEffectEx> HeadshotFXIDs;

static final function HeadshotEffectEx GetUnlockedHeadshotEffect( int ItemId )
{
    local int i;
    local HeadshotEffectEx Dummy;

    i = default.HeadshotFXIDs.Find('Id', ItemId);
    if( i != INDEX_NONE )
        return default.HeadshotFXIDs[i];

    Dummy.Id = INDEX_NONE;
    Dummy.ItemName = "Dummy";
    return Dummy;
}

static final function SaveEquippedHeadShotEffect( int ItemId, ClassicPlayerController PC )
{
    if( PC == None )
        return;
        
    PC.SelectedHeadshotIndex = ItemId;
    PC.SaveConfig();
    ClassicPlayerReplicationInfo(PC.PlayerReplicationInfo).ServerSetCurrentHeadShotSFX(ItemId);
}

static final function int GetEquippedHeadShotEffectId(ClassicPlayerController PC)
{
    if( PC == None )
        return -1;
        
    return PC.SelectedHeadshotIndex;
}

static final function array<HeadshotEffectEx> GetHeadshotFXArray()
{
    return default.HeadshotFXIDs;
}

defaultproperties
{
	HeadshotFXIDs.Add((Id=6260, ItemName="Dosh", EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Dosh_01", IconPathSmall="HEADSHOT_TEX.Headshot_Dosh_128", IconPathLarge="HEADSHOT_TEX.Headshot_Dosh_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Dosh_Headshot')
	HeadshotFXIDs.Add((Id=6261, ItemName="Confetti", EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Confetti_01", IconPathSmall="HEADSHOT_TEX.Headshot_Confetti_128", IconPathLarge="HEADSHOT_TEX.Headshot_Confetti_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Confetti_Headshot')
	HeadshotFXIDs.Add((Id=6262, ItemName="Ghost", EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Ghost_01", IconPathSmall="HEADSHOT_TEX.Headshot_Ghost_128", IconPathLarge="HEADSHOT_TEX.Headshot_Ghost_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Ghost_Headshot')
	HeadshotFXIDs.Add((Id=6263, ItemName="Hearts", EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Hearts_01", IconPathSmall="HEADSHOT_TEX.Headshot_Hearts_128", IconPathLarge="HEADSHOT_TEX.Headshot_Hearts_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Hearts_Headshot')
	HeadshotFXIDs.Add((Id=6264, ItemName="Comic", EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Comic_01", IconPathSmall="HEADSHOT_TEX.Headshot_Comic_128", IconPathLarge="HEADSHOT_TEX.Headshot_Comic_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Pixel_Headshot')
	HeadshotFXIDs.Add((Id=7042, ItemName="Flower", EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Flower_01", IconPathSmall="HEADSHOT_TEX.02.KF2_Headshots_Flower_128", IconPathLarge="HEADSHOT_TEX.02.KF2_Headshots_Flower_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Flower_Headshot')
	HeadshotFXIDs.Add((Id=7043, ItemName="Splatter", EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Splatter_01", IconPathSmall="HEADSHOT_TEX.02.KF2_Headshots_Splatter_128", IconPathLarge="HEADSHOT_TEX.02.KF2_Headshots_Splatter_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Splatter_A_Headshot')
	HeadshotFXIDs.Add((Id=7044, ItemName="Gameover", EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Gameover_01", IconPathSmall="HEADSHOT_TEX.02.KF2_Headshots_GameOver_128", IconPathLarge="HEADSHOT_TEX.02.KF2_Headshots_GameOver_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Gameover_Headshot')
	HeadshotFXIDs.Add((Id=7045, ItemName="Glitch", EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Glitch_01", IconPathSmall="HEADSHOT_TEX.02.KF2_Headshots_Glitch_128", IconPathLarge="HEADSHOT_TEX.02.KF2_Headshots_Glitch_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Glitch_Headshot')
	HeadshotFXIDs.Add((Id=7046, ItemName="Headscan", EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Headscan_01", IconPathSmall="HEADSHOT_TEX.02.KF2_Headshots_Horzine_128", IconPathLarge="HEADSHOT_TEX.02.KF2_Headshots_Horzine_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Headscan_Headshot')
}