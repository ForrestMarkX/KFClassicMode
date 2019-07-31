class ZEDReplacmentInfo extends Object
    PerObjectConfig
    config(ClassicZEDInfo);
    
struct AIReplacement
{
    var string Original, Replacment;
    var bool bCheckChildren;
    var float ReplacmentChance;
    
    structdefaultproperties
    {
        ReplacmentChance=1.f
        bCheckChildren=false
    }
};
var    config array<AIReplacement> AIReplacments;

defaultproperties
{
}