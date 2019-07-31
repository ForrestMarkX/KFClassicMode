Class UIR_MutatorList extends KFGUI_Frame;

struct FMutatorSummary
{
    var string FriendlyName, Description;
    var KFMutatorSummary Summary;
};
var array<FMutatorSummary> Mutators;

var KFGUI_List MutatorList;
var int SelectedIndex;
var UIR_MutatorList EnabledMutatorsFrame;
var UIP_GameInfo GamePage;

function InitMenu()
{
    Super.InitMenu();
    
    FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM_SLIGHTTRANSPARENT];
    
    GamePage = UIP_Mutators(ParentComponent).StartGame.GameInfo;
    
    MutatorList = KFGUI_List(FindComponentID('MutatorList'));
    MutatorList.OnDrawItem = DrawMutators;
    MutatorList.OnClickedItem = SelectItem;
    MutatorList.OnDblClickedItem = DoubleClickedItem;
    MutatorList.ScrollBar.YSize = 1.f;
    MutatorList.ChangeListSize(0);
    
    FindMutators();
}

function FindMutators()
{
    local int i;
    local KFUIDataStore_GameResource GameResourceDS;
    local array<UIResourceDataProvider> MutatorProviders;
    local KFMutatorSummary Summary;
    
    GameResourceDS = KFUIDataStore_GameResource(class'UIRoot'.static.StaticResolveDataStore(class'KFUIDataStore_GameResource'.default.Tag));
	if ( GameResourceDS != None && GameResourceDS.GetResourceProviders('Mutators', MutatorProviders) )
	{
        for (i = 0; i < MutatorProviders.Length; i++)
        {
            Summary = KFMutatorSummary(MutatorProviders[i]);
            if( Summary != None && !Summary.bIsDisabled )
                AddMutatorToList(Summary);
        }
    }
    
    MutatorList.ChangeListSize(Mutators.Length);
}

function AddMutatorToList(KFMutatorSummary Mut)
{
    local FMutatorSummary Info;
    
    Info.Summary = Mut;
    GetMutatorInfo(Info.FriendlyName, Info.Description, Mut);
    Mutators.AddItem(Info);
}

function GetMutatorInfo(out string FN, out string D, KFMutatorSummary Mut)
{
    local string ClassName, PackageName;
    
    ClassName = GetClassName(Mut.ClassName);
    PackageName = GetPackageNameEx(Mut.ClassName);
    
    D = Mut.Description;
    if( D == "" )
    {
        D = Localize(ClassName, "Description", PackageName);
        if( InStr(D, ClassName$".Description?") != INDEX_NONE )
            D = "No Description";
    }
    
    FN = Mut.FriendlyName;
    if( FN == "" )
    {
        FN = Localize(ClassName, "FriendlyName", PackageName);
        if( InStr(FN, ClassName$".FriendlyName?") != INDEX_NONE )
            FN = ClassName;
    }
}

function SelectItem(int Index, bool bRight, int MouseX, int MouseY)
{
    PlayMenuSound(MN_ClickButton);
    SelectedIndex = Index;
    UIP_Mutators(ParentComponent).DescriptionText.SetText(Mutators[SelectedIndex].Description);
}

function DoubleClickedItem(int Index, bool bRight, int MouseX, int MouseY)
{
    SelectedIndex = -1;
    PlayMenuSound(MN_DropdownChange);
    
    if( Mutators[Index].Summary.ClassName != "" )
    {
        GamePage.SavedMutators.AddItem(Mutators[Index].Summary.ClassName);
        GamePage.SaveConfig();
    }
    
    EnabledMutatorsFrame.AddMutator(Mutators[Index].Summary);
    RemoveMutator(Mutators[Index].Summary);
}

function DrawMutators( Canvas C, int Index, float YOffset, float Height, float Width, bool bFocus )
{
    local float FontScalar, XL, YL;
    local string S;
    
    if( SelectedIndex == Index )
        bFocus = true;
        
    Owner.CurrentStyle.DrawRoundedBoxOutlined(1, 0.f, YOffset, Width, Height, bFocus ? MakeColor(0, 0, 0, 195) : MakeColor(15, 15, 15, 195), bFocus ? MakeColor(90, 0, 0, 195) : MakeColor(195, 0, 0, 195));
    
    S = Mutators[Index].FriendlyName;
        
    C.Font = Owner.CurrentStyle.PickFont(FontScalar);
    FontScalar *= 1.125f;
    
    C.TextSize(S, XL, YL, FontScalar, FontScalar);
    C.SetPos((Width/2) - (XL/2), YOffset + (Height/2) - (YL/2));
    
    if( bFocus )
        C.SetDrawColor(255, 0, 0, 255);
    else C.SetDrawColor(255, 255, 255, 255);
    
    C.DrawText(S,,FontScalar,FontScalar);
}

static final function string GetPackageNameEx(string FullPath)
{
    local int Index;
    
    Index = InStr(FullPath, ".");
    if( Index != INDEX_NONE )
        return Left(FullPath, Index);
        
    return FullPath;
}

static final function string GetClassName(string FullPath)
{
    local int Index;
    
    Index = InStr(FullPath, ".");
    if( Index != INDEX_NONE )
        return Mid(FullPath, Index+1);
        
    return FullPath;
}

function AddMutator(KFMutatorSummary Mut)
{
    AddMutatorToList(Mut);
    MutatorList.ChangeListSize(Mutators.Length);
}

function RemoveMutator(KFMutatorSummary Mut)
{
    local int Index;
    
    Index = Mutators.Find('Summary', Mut);
    if( Index != INDEX_NONE )
    {
        Mutators.RemoveItem(Mutators[Index]);
        MutatorList.ChangeListSize(Mutators.Length);
    }
}

defaultproperties
{
    SelectedIndex=-1
    bUseAnimation=true
    
    EdgeSize(0)=10
    EdgeSize(2)=0
    
    Begin Object Class=KFGUI_List Name=MutatorList
        ID="MutatorList"
        ListItemsPerPage=16
        bClickable=true
    End Object
    Components.Add(MutatorList)
}