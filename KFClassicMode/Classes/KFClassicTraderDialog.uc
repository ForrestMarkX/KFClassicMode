class KFClassicTraderDialog extends Info;

struct FTraderReplacmentDialog
{
	var string Replacement;
	var name OriginalName;
};
var array<FTraderReplacmentDialog> TraderVoices;

static function bool GetReplacment(Pawn P, AkEvent OriginalDialog, out SoundCue Sound)
{
	local int Index;
	
	Index = default.TraderVoices.Find('OriginalName', OriginalDialog.Name);
	if( Index != INDEX_None )
	{
		Sound = SoundCue(P.DynamicLoadObject(default.TraderVoices[Index].Replacement, class'SoundCue'));
		return InStr(Sound.Name, "Radio", false, true) != INDEX_None;
	}
	
	return false;
}

defaultproperties
{
	TraderVoices.Add((OriginalName="Play_Trader_COM_20ZedDead", Replacement="KFClassicMode_Assets.Trader.Radio_AlmostOpen"))
	TraderVoices.Add((OriginalName="Play_Trader_COM_80ZedDead", Replacement="KFClassicMode_Assets.Trader.Radio_Moving"))
	TraderVoices.Add((OriginalName="Play_Trader_COM_LastZedDead", Replacement="KFClassicMode_Assets.Trader.Radio_ShopsOpen"))
	TraderVoices.Add((OriginalName="Play_Trader_COM_ShopClose", Replacement="KFClassicMode_Assets.Trader.Radio_Closed"))
	TraderVoices.Add((OriginalName="Play_Trader_SHOP_30Seconds", Replacement="KFClassicMode_Assets.Trader.Radio_ThirtySeconds"))
	TraderVoices.Add((OriginalName="Play_Trader_SHOP_10Seconds", Replacement="KFClassicMode_Assets.Trader.Radio_TenSeconds"))
	TraderVoices.Add((OriginalName="Play_Trader_SHOP_LastShop", Replacement="KFClassicMode_Assets.Trader.Radio_LastWave"))
	TraderVoices.Add((OriginalName="Play_Trader_SHOP_PlayerArrives", Replacement="KFClassicMode_Assets.Trader.Welcome"))
	TraderVoices.Add((OriginalName="Play_Trader_SHOP_TooExp", Replacement="KFClassicMode_Assets.Trader.TooExpensive"))
	TraderVoices.Add((OriginalName="Play_Trader_SHOP_TooHeavy", Replacement="KFClassicMode_Assets.Trader.TooHeavy"))
}