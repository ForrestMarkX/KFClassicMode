/**
 * Partial implementation of the AchievementPack class providing the framework to store and Serialize 
 * Achievement data, and send notifications to the player.
 * @author Eric Tsai (scaryghost)
 */
class StandardAchievementPack extends AchievementPack
    abstract;

/**
 * Extension of the Achievement struct adding extra properties for controlling 
 * how the Progress variable is used and localizing the Title and Description variables
 */
struct StandardAchievement extends Achievement 
{
    var localized string Title;                 ///< Achievement Title, must be set in localization file
    var localized string Description;           ///< Achievement Description, must be set in localization file
    var byte nNotifies;                         ///< How often to send updates to the player for Achievement
    var int NextProgress;                       ///< Next Progress value when the player should get updated
    var bool DiscardProgress;                   ///< True if Achievement Progress should not be serialized
};

/** Actor owner typecasted as KFPlayerController */
var protectedwrite ClassicPlayerController OwnerController;
var protectedwrite ClassicPlayerController LocalController;
var protectedwrite array<StandardAchievement> Achievements;
/** Name of the Achievement pack, must be set in localization file */
var protectedwrite localized String PackName;
var protectedwrite Texture2D DefaultAchievementImage;

var private localized String AchvUnlockedMsg, AchvInProgressMsg;

simulated event PostBeginPlay() 
{
    if (AIController(Owner) == none)
    {
        LocalController = ClassicPlayerController(GetALocalPlayerController());
    }
    OwnerController = ClassicPlayerController(Owner);
}

function Serialize(out array<byte> ObjectState) 
{
    local StandardAchievement Ach;

    ObjectState.Length= 0;
    foreach Achievements(Ach) 
    {
        if (!Ach.DiscardProgress) 
        {
            ObjectState.AddItem(Ach.Progress & 0xff);
            ObjectState.AddItem((Ach.Progress >> 8) & 0xff);
            ObjectState.AddItem((Ach.Progress >> 16) & 0xff);
            ObjectState.AddItem((Ach.Progress >> 24) & 0xff);
        } 
        else 
        {
            ObjectState.AddItem(Ach.Completed ? 1 : 0);
        }
    }
}

function Deserialize(const out array<byte> ObjectState) 
{
    local int i, j, Count, NotifyStep;

    i= 0;
    for(j= 0; j < Achievements.Length; j++) 
    {
        if (i >= ObjectState.Length) 
        {
            break;
        }
        
        if (!Achievements[j].DiscardProgress) 
        {
            Achievements[j].Progress = (ObjectState[i] | (ObjectState[i + 1] << 8) | (ObjectState[i + 2] << 16) | (ObjectState[i + 3] << 24));
            i+= 4;

            Achievements[j].Completed = Achievements[j].Progress >= Achievements[j].MaxProgress;
            if (!Achievements[j].Completed && Achievements[j].MaxProgress != 0 && Achievements[j].nNotifies != 0) 
            {
                NotifyStep = Achievements[j].MaxProgress * (1.0 / Achievements[j].nNotifies);
                Count = Achievements[j].Progress / NotifyStep;
                Achievements[j].NextProgress = (Count + 1) * NotifyStep;
            }
        } 
        else 
        {
            Achievements[j].Completed = (ObjectState[i] != 0);
            i++;
        }

        FlushToClient(j, Achievements[j].Progress, Achievements[j].Completed);
    }
}

simulated function LookupAchievement(int Index, out Achievement Result) 
{
    Result.Title = Achievements[Index].Title;
    Result.Description = Achievements[Index].Description;
    Result.MaxProgress = Achievements[Index].MaxProgress;
    Result.Progress = Achievements[Index].Progress;
    Result.Completed = Achievements[Index].Completed;
    Result.HideProgress = Achievements[Index].HideProgress;

    if (Achievements[Index].Image == None) 
    {
        Result.Image = DefaultAchievementImage;
    } 
    else 
    {
        Result.Image = Achievements[Index].Image;
    }
}

simulated function int NumAchievements() 
{
    return Achievements.Length;
}

simulated function int NumCompleted() 
{
    local int NumCompleted;
    local StandardAchievement Ach;

    foreach Achievements(Ach) 
    {
        if (!Ach.Completed) 
        {
            NumCompleted++;
        }
    }
    
    return NumCompleted;
}

simulated function String AttrName() 
{
    return PackName;
}

simulated function String AttrId() 
{
    return Locs(PathName(self.Class));
}

/**
 * Update the Achievement state on the client side
 * @param Index         Achievement Index to update
 * @param Progress      New Progress 
 * @param Completed     New completion state
 */
reliable client function FlushToClient(int Index, int Progress, bool Completed) 
{
    Achievements[Index].Progress = Progress;
    Achievements[Index].Completed = Completed;
}

/**
 * Update the player of Achievement Progress with a popup message
 * @param Index         Achievement Index to notify the player of
 */
reliable client function NotifyProgress(int Index) 
{
    local Texture2D UsedImage;
    local PopupMessage NewMsg;

    if (LocalController != None && LocalController.HUDInterface != None) 
    {
        if (Achievements[Index].Image == none) 
        {
            UsedImage = DefaultAchievementImage;
        } 
        else 
        {
            UsedImage = Achievements[Index].Image;
        }
        NewMsg.Header = AchvInProgressMsg;
        NewMsg.Body = Achievements[Index].Title $ LocalController.HUDInterface.NewLineSeparator $ "(" $ Achievements[Index].Progress $ "/" $ Achievements[Index].MaxProgress $ ")";
        NewMsg.Image = UsedImage;
        LocalController.HUDInterface.AddAchievmentPopup(NewMsg);
    }
}

/**
 * Updates the player that an Achievement is Completed with a popup message
 * @param Index         Achievement Index to notify the player of
 */
reliable client function LocalAchievementCompleted(int Index) 
{
    local Texture2D UsedImage;
    local PopupMessage NewMsg;

    if (LocalController != None && LocalController.HUDInterface != None) 
    {
        if (Achievements[Index].Image == none) 
        {
            UsedImage = DefaultAchievementImage;
        } 
        else 
        {
            UsedImage = Achievements[Index].Image;
        }
        NewMsg.Header = AchvUnlockedMsg;
        NewMsg.Body = PackName $ LocalController.HUDInterface.NewLineSeparator $ Achievements[Index].Title;
        NewMsg.Image = UsedImage;
        LocalController.HUDInterface.AddAchievmentPopup(NewMsg);
    }
}

/**
 * Marks an Achievement as Completed
 * @param Index         Achievement Index to flag as complete
 */
function protected AchievementCompleted(int Index) 
{
    if (!Achievements[Index].Completed) 
    {
        Achievements[Index].Completed= true;
        FlushToClient(Index, Achievements[Index].Progress, Achievements[Index].Completed);
        LocalAchievementCompleted(Index);
    }
}

/**
 * Adds an Offset to the Achievement Progress
 * @param Index         Achievement Index to update
 * @param Offset        Offset to add to the Progress
 */
function protected AddProgress(int Index, int Offset) 
{
    Achievements[Index].Progress += Offset;
    
    if (Achievements[Index].Progress >= Achievements[Index].MaxProgress) 
    {
        AchievementCompleted(Index);
    } 
    else 
    {
        if (!Achievements[Index].HideProgress) 
        {
            FlushToClient(Index, Achievements[Index].Progress, Achievements[Index].Completed);
        }

        if (Achievements[Index].nNotifies != 0) 
        {
            if (Achievements[Index].NextProgress == 0) 
            {
                Achievements[Index].NextProgress = Achievements[Index].MaxProgress * (1.0 / Achievements[Index].nNotifies);
            }

            if (Achievements[Index].Progress >= Achievements[Index].NextProgress) 
            {
                NotifyProgress(Index);
                Achievements[Index].NextProgress += Achievements[Index].MaxProgress * (1.0 / Achievements[Index].nNotifies);
            }
        }
    }
}

/**
 * Reset Achievement Progress to 0 and mark Completed property as false
 * @param Index     Achievement Index to update
 */
function protected ResetProgress(int Index) 
{
    Achievements[Index].Progress = 0;
    Achievements[Index].NextProgress = 0;
    Achievements[Index].Completed = false;

    if (!Achievements[Index].HideProgress) 
    {
        FlushToClient(Index, 0, false);
    }
}

defaultproperties
{
    DefaultAchievementImage=Texture2D'EditorMaterials.Tick'
}
