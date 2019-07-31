/**
 * Abstract class containing a collection of achievements and defining callbacks for handling game functions.  
 * This mutator only uses references to this class. 
 * @author Eric Tsai (scaryghost)
 */
class AchievementPack extends Actor
    abstract;

/**
 * Achievement properties
 */
struct Achievement {
    var string Title;               ///< Achievement Title
    var string Description;         ///< Achievement Description
    var Texture2D Image;            ///< Achievement Image
    var int MaxProgress;            ///< Max Progress to reach before achievement is Completed
    var int Progress;               ///< Current achievement Progress
    var bool HideProgress;          ///< True if Progress is hidden from the player aka no Progress bar
    var bool Completed;             ///< True if achievement is Completed
};

/**
 * Enumeration of possible match outcomes
 */
enum MatchResult {
    SA_MR_UNKNOWN,          ///< Outcome unknown
    SA_MR_WON,              ///< Match won
    SA_MR_LOST              ///< Match lost
};

/**
 * Tuple holding properties of the current match
 */
struct MatchInfo {
    var string MapName;             ///< Map the match was played on
    var byte Difficulty;            ///< Difficulty of the match
    var byte Length;                ///< Game Length
    var MatchResult Result;         ///< Result of the match
};

/**
 * Called when the match ends
 * @param info      Information about the match
 */
function MatchEnded(const out MatchInfo Info);
/**
 * Called when a wave begins
 * @param newWave   Wave number that started
 * @param waveMax   Maximum number of waves in the game
 */
function WaveStarted(byte NewWave, byte WaveMax);
/**
 * Called when a grenade is thrown
 * @param grenadeClass      Class of the thrown grenade
 */
function TossedGrenade(class<KFProj_Grenade> GrenadeClass);
/**
 * Called when a gun begins its reloading animation
 * @param currentWeapon     Weapon being reloaded
 */
function ReloadedWeapon(Weapon CurrentWeapon);
/**
 * Called when a gun begins its firing animation
 * @param currentWeapon     Weapon being fired
 */
function FiredWeapon(Weapon CurrentWeapon);
/**
 * Called when a gun stops its firing animation
 * @param currentWeapon     Weapon that ceases firing
 */
function StoppedFiringWeapon(Weapon CurrentWeapon);
/**
 * Called when a weapon begins its swinging animation
 * @param currentWeapon     Weapon that is swinging
 */
function SwungWeapon(Weapon CurrentWeapon);
/**
 * Called when the player dies
 * @param killer            Controller of the killer
 * @param damageType        Type of damage that killed the player
 */
function Died(Controller Killer, class<DamageType> DamageType);
/**
 * Called when the player kills a specimen
 * @param target            Specimen the player killed
 * @param damageType        Type of damage that killed the specimen
 */
function KilledMonster(Pawn Target, class<DamageType> DamageType);
/**
 * Called when the player damages a specimen
 * @param damage            Amount of damage done
 * @param target            Specimen that was hurt
 * @param damageType        Type of damage that hurt the specimen
 * @param headshot          True if attack was a headshot
 */
function DamagedMonster(int Damage, Pawn Target, class<DamageType> DamageType, bool Headshot);
/**
 * Called when the player picks up an item
 * @param item              Item that is picked up
 */
function PickedUpItem(Actor Item);

/**
 * Convert the achievement pack to a byte array to be saved to disk
 * @param objectState           Array to write the bytes to
 */
function Serialize(out array<byte> ObjectState);
/**
 * Restore the achievement pack's internal state 
 * @param objectState           Byte array containing the class' state
 */
function Deserialize(const out array<byte> ObjectState);

/**
 * Look up achievement definition at a specific index
 * @param index         Numerical index to lookup
 * @param Result        Pass by reference variable to store the lookup Result
 */
simulated function LookupAchievement(int Index, out Achievement Result);
/**
 * Get the number of achievements in this pack
 */
simulated function int NumAchievements();
/**
 * Get the number of achievements that are Completed
 */
simulated function int NumCompleted();
/**
 * Get the name of the achievement pack
 */
simulated function String AttrName();
/**
 * Unique identifier for the achievement pack
 */
simulated function String AttrId();

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true

    bStatic=false
    bNoDelete=false
    bHidden=true
}
