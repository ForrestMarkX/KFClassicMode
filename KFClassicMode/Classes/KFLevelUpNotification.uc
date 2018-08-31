class KFLevelUpNotification extends ClassicLocalMessage
	abstract;
	
var(Message) string EarnedString;

static function string GetString(
    optional int Switch,
	optional bool bPRI1HUD,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	local string S;

	if( Class<ClassicPerk_Base>(OptionalObject)==None )
		return "";
		
	S = Default.EarnedString;
	class'Actor'.static.ReplaceText(S,"%s",RelatedPRI_1!=None ? RelatedPRI_1.PlayerName : "Someone");
	class'Actor'.static.ReplaceText(S,"%v",class<ClassicPerk_Base>(OptionalObject).static.GetPerkName());
	class'Actor'.static.ReplaceText(S,"%l",string(Switch));
	
	Return S;
}

defaultproperties
{
	bIsUnique=True
	FontSize=2
	PosY=0.05
	DrawColor=(R=255,G=50,B=255)
	EarnedString="%s has earned %v level %l!"
	bIsConsoleMessage=True
	Lifetime=3
}
