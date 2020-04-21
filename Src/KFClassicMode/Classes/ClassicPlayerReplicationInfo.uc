Class ClassicPlayerReplicationInfo extends KFPlayerReplicationInfo;

var int CurrentHeadShotEffectIndex;
var byte CurrentPerkLevel;
var transient int RepIndex, RepState;

struct FCustomCharEntry
{
    var bool bLock;
    var KFCharacterInfo_Human Char;
    var ObjectReferencer Ref;
};
struct FMyCustomChar // Now without constant.
{
    var int CharacterIndex,HeadMeshIndex,HeadSkinIndex,BodyMeshIndex,BodySkinIndex,AttachmentMeshIndices[`MAX_COSMETIC_ATTACHMENTS],AttachmentSkinIndices[`MAX_COSMETIC_ATTACHMENTS];
    
    structdefaultproperties
    {
        CharacterIndex=INDEX_NONE
        AttachmentMeshIndices[0]=`CLEARED_ATTACHMENT_INDEX
        AttachmentMeshIndices[1]=`CLEARED_ATTACHMENT_INDEX
        AttachmentMeshIndices[2]=`CLEARED_ATTACHMENT_INDEX
    }
};
var array<FCustomCharEntry> CustomCharList;
var repnotify FMyCustomChar CustomCharacter;
var transient array<ClassicCharDataInfo> SaveDataObjects;
var transient ClassicPlayerReplicationInfo LocalOwnerPRI;
var bool bClientUseCustom,bClientFirstChar,bClientCharListDone,bClientInitChars;

struct FCustomTraderItem
{
    var class<KFWeaponDefinition> WeaponDef;
    var class<KFWeapon> WeaponClass;
};

var KFGFxObject_TraderItems CustomList;
var array<FCustomTraderItem> CustomItems;

replication
{
    // Things the server should send to the client.
    //if ( bNetDirty )
    if ( true )
        CurrentPerkLevel, CustomCharacter;
}

simulated function PostBeginPlay()
{
    local PlayerController PC;

    Super.PostBeginPlay();
    
    if( WorldInfo.NetMode!=NM_DedicatedServer )
    {
        PC = GetALocalPlayerController();
        if( PC!=None )
            LocalOwnerPRI = ClassicPlayerReplicationInfo(PC.PlayerReplicationInfo);
    }
    else LocalOwnerPRI = Self; // Dedicated server can use self PRI.
}

simulated function ClientInitialize(Controller C)
{
    local ClassicPlayerReplicationInfo PRI;

    Super.ClientInitialize(C);
    
    LoadAllHeadshotEffects();
    ServerSetCurrentHeadShotSFX(ClassicPlayerController(C).SelectedHeadshotIndex);
    
    if( WorldInfo.NetMode!=NM_DedicatedServer )
    {
        LocalOwnerPRI = Self;

        // Make all other PRI's load character list from local owner PRI.
        foreach DynamicActors(class'ClassicPlayerReplicationInfo',PRI)
            PRI.LocalOwnerPRI = Self;
    }
}

simulated event ReplicatedEvent(name VarName)
{
    if ( VarName == 'CustomCharacter' )
    {
        CharacterCustomizationChanged();
    }

    Super.ReplicatedEvent(VarName);
}

function ReplicateTimer()
{
    switch(RepState)
    {
        case 0:
            if( RepIndex>=CustomCharList.Length )
            {
                AllCharReceived();
                RepIndex = 0;
                ++RepState;
            }
            else
            {
                ReceivedCharacter(RepIndex,CustomCharList[RepIndex]);
                ++RepIndex;
            }
            break;
        case 1:
            if( !OnRepNextItem(Self,RepIndex) )
            {
                RepIndex = 0;
                ++RepState;
            }
            else ++RepIndex;
            break;
        default:
            RepState=0;
            ClearTimer('ReplicateTimer');
            break;
    }
}

simulated static final function KFGFxObject_TraderItems CreateNewList()
{
    return new(None) class'KFGFxObject_TraderItems';
}

delegate bool OnRepNextItem( ClassicPlayerReplicationInfo PRI, int Index )
{
    return false;
}

simulated reliable client function ClientAddTraderItem( int Index, FCustomTraderItem Item )
{
    // Make sure to not execute on server.
    if( WorldInfo.NetMode!=NM_Client && (PlayerController(Owner)==None || LocalPlayer(PlayerController(Owner).Player)==None) )
        return;

    if( CustomList==None )
    {
        CustomList = CreateNewList();
        RecheckGRI();
    }
    CustomItems.AddItem(Item);
    SetWeaponInfo(false,Index,Item,CustomList);
}

simulated static final function SetWeaponInfo( bool bDedicated, int Index, FCustomTraderItem Item, KFGFxObject_TraderItems List )
{
    local array<STraderItemWeaponStats> S;
    local int i;

    if( List.SaleItems.Length<=Index )
        List.SaleItems.Length = Index+1;

    List.SaleItems[Index].WeaponDef = Item.WeaponDef;
    List.SaleItems[Index].ClassName = Item.WeaponClass.Name;
    
    for(i=0; i<Item.WeaponClass.default.WeaponUpgrades.Length; i++)
    {
        List.SaleItems[Index].WeaponUpgradeWeight[i] = Item.WeaponClass.static.GetUpgradeWeight(i);
        List.SaleItems[Index].WeaponUpgradeDmgMultiplier[i] = Item.WeaponClass.static.GetUpgradeStatScale(EWeaponUpgradeStat(EWUS_Damage0 + Item.WeaponClass.default.UpgradeFireModes[class'KFWeapon'.const.DEFAULT_FIREMODE]), i);
    }
    
    //Dual Weapon Check
    if(class<KFWeap_DualBase>(Item.WeaponClass)!=None && class<KFWeap_DualBase>(Item.WeaponClass).Default.SingleClass!=None)
    {
        List.SaleItems[Index].SingleClassName = class<KFWeap_DualBase>(Item.WeaponClass).Default.SingleClass.Name;
    }
    //Single Weapon Check
    else if (Item.WeaponClass.Default.DualClass!=None)
    {
        List.SaleItems[Index].DualClassName = Item.WeaponClass.Default.DualClass.Name;
    }
    
    List.SaleItems[Index].AssociatedPerkClasses = Item.WeaponClass.Static.GetAssociatedPerkClasses();
    List.SaleItems[Index].MagazineCapacity = Item.WeaponClass.Default.MagazineCapacity[0];
    List.SaleItems[Index].InitialSpareMags = Item.WeaponClass.Default.InitialSpareMags[0];
    List.SaleItems[Index].MaxSpareAmmo = Item.WeaponClass.Default.SpareAmmoCapacity[0];
    List.SaleItems[Index].InitialSecondaryAmmo = Item.WeaponClass.Default.MagazineCapacity[1];
    List.SaleItems[Index].MaxSecondaryAmmo = Item.WeaponClass.Default.SpareAmmoCapacity[1] + Item.WeaponClass.Default.MagazineCapacity[1];
    List.SaleItems[Index].BlocksRequired = Item.WeaponClass.Default.InventorySize;
    List.SaleItems[Index].ItemID = Index;
    
    if( !bDedicated )
    {
        List.SaleItems[Index].SecondaryAmmoImagePath = Item.WeaponClass.Default.SecondaryAmmoTexture!=None ? "img://"$PathName(Item.WeaponClass.Default.SecondaryAmmoTexture) : "";
        List.SaleItems[Index].TraderFilter = Item.WeaponClass.Static.GetTraderFilter();
        List.SaleItems[Index].InventoryGroup = Item.WeaponClass.Default.InventoryGroup;
        List.SaleItems[Index].GroupPriority = Item.WeaponClass.Default.GroupPriority;
        Item.WeaponClass.Static.SetTraderWeaponStats(S);
        List.SaleItems[Index].WeaponStats = S;
    }
}

simulated function RecheckGRI()
{
    local ClassicPlayerController PC;

    if( KFGameReplicationInfo(WorldInfo.GRI)==None )
        SetTimer(0.1,false,'RecheckGRI');
    else
    {
        KFGameReplicationInfo(WorldInfo.GRI).TraderItems = CustomList;
        foreach LocalPlayerControllers(class'ClassicPlayerController',PC)
            if( PC.PurchaseHelper!=None )
                PC.PurchaseHelper.TraderItems = CustomList;
    }
}

simulated function VOIPStatusChanged( PlayerReplicationInfo Talker, bool bIsTalking )
{
    local KFPlayerController KFPC;
    local KFPlayerReplicationInfo TalkerKFPRI;
    local OnlineSubsystem OSS;
    local KFHUDInterface HUD;

    OSS = class'GameEngine'.static.GetOnlineSubsystem();

    foreach WorldInfo.LocalPlayerControllers(class'KFPlayerController', KFPC)
    {
        if( OSS != None && OSS.HasChatRestriction( LocalPlayer(KFPC.Player).ControllerId ) )
        {
            return;
        }

        TalkerKFPRI = KFPlayerReplicationInfo(Talker);
        if( TalkerKFPRI != none )
        {
            if( TalkerKFPRI.VOIPStatus == 6 && !KFPC.PlayerReplicationInfo.bOnlySpectator )
            {
                return;
            }
        }

        HUD = KFHUDInterface(KFPC.myHUD);
        if( HUD != None )
        {
            HUD.VOIPEventTriggered(Talker, bIsTalking);
        }
        
        if( ClassicPlayerController(KFPC).LobbyMenu != None )
        {
            ClassicPlayerController(KFPC).LobbyMenu.UpdateVOIP(Talker, bIsTalking);
        }
    }
}

/*
Purpose: Used to add a string before the players name in the chat.
Returns: String
*/
simulated function string GetNamePrefix(name Type)
{
    if( bAdmin )
    {
        return class'KFLocalMessage'.default.AdminString;
    }
    else if( bOnlySpectator )
    {
        return class'KFCommon_LocalizedStrings'.default.SpectatorString;
    }
    
    return "";
}

/*
Purpose: Used to add a string after the players name in the chat.
Returns: String
*/
simulated function string GetNamePostfix(name Type)
{
    return "";
}

/*
Purpose: Gets the hex color used for the name of the player in the chat.
Returns: String
*/
simulated function string GetNameHexColor(name Type)
{
    if( bAdmin )
    {
        return class'KFLocalMessage'.default.PriorityColor;
    }
    
    return GetMessageHexColor(Type);
}

/*
Purpose: Gets the hex color used for the players chat message text.
Returns: String
*/
simulated function string GetMessageHexColor(name Type)
{
    return class'KFLocalMessage'.default.SayColor;
}

simulated function byte GetActivePerkLevel()
{
    return CurrentPerkLevel;
}

function AddDosh( int DoshAmount, optional bool bEarned )
{
    Super.AddDosh(DoshAmount, bEarned);
    
    if ( WorldInfo.NetMode == NM_StandAlone )
    {
        UpdateTraderDosh();
    }
}

simulated final function bool LoadPlayerCharacter( byte CharIndex, out FMyCustomChar CharInfo )
{
    local KFCharacterInfo_Human C;

    if( CharIndex>=(CharacterArchetypes.Length+CustomCharList.Length) )
        return false;

    if( SaveDataObjects.Length<=CharIndex )
        SaveDataObjects.Length = CharIndex+1;
    if( SaveDataObjects[CharIndex]==None )
    {
        if( CharIndex<CharacterArchetypes.Length )
        {
            C = CharacterArchetypes[CharIndex];
        }
        else
        {
            C = CustomCharList[CharIndex-CharacterArchetypes.Length].Char;
        }
        SaveDataObjects[CharIndex] = new(None,PathName(C)) class'ClassicCharDataInfo';
    }
    CharInfo = SaveDataObjects[CharIndex].LoadData();
    return true;
}

simulated final function bool SavePlayerCharacter()
{
    local KFCharacterInfo_Human C;

    if( CustomCharacter.CharacterIndex>=(CharacterArchetypes.Length+CustomCharList.Length) )
        return false;

    if( SaveDataObjects.Length<=CustomCharacter.CharacterIndex )
        SaveDataObjects.Length = CustomCharacter.CharacterIndex+1;
    if( SaveDataObjects[CustomCharacter.CharacterIndex]==None )
    {
        C = (CustomCharacter.CharacterIndex<CharacterArchetypes.Length) ? CharacterArchetypes[CustomCharacter.CharacterIndex] : CustomCharList[CustomCharacter.CharacterIndex-CharacterArchetypes.Length].Char;
        SaveDataObjects[CustomCharacter.CharacterIndex] = new(None,PathName(C)) class'ClassicCharDataInfo';
    }
    SaveDataObjects[CustomCharacter.CharacterIndex].SaveData(CustomCharacter);
    return true;
}

simulated function ChangeCharacter( byte CharIndex, optional bool bFirstSet )
{
    local FMyCustomChar NewChar;
    local int i;

    if( CharIndex>=(CharacterArchetypes.Length+CustomCharList.Length) || IsClientCharLocked(CharIndex) )
        CharIndex = 0;

    if( bFirstSet && RepCustomizationInfo.CharacterIndex==CharIndex )
    {
        // Copy properties from default character info.
        NewChar.HeadMeshIndex = RepCustomizationInfo.HeadMeshIndex;
        NewChar.HeadSkinIndex = RepCustomizationInfo.HeadSkinIndex;
        NewChar.BodyMeshIndex = RepCustomizationInfo.BodyMeshIndex;
        NewChar.BodySkinIndex = RepCustomizationInfo.BodySkinIndex;
        for( i=0; i<`MAX_COSMETIC_ATTACHMENTS; ++i )
        {
            NewChar.AttachmentMeshIndices[i] = RepCustomizationInfo.AttachmentMeshIndices[i];
            NewChar.AttachmentSkinIndices[i] = RepCustomizationInfo.AttachmentSkinIndices[i];
        }
    }
    if( LoadPlayerCharacter(CharIndex,NewChar) )
    {
        NewChar.CharacterIndex = CharIndex;
        CustomCharacter = NewChar;
        ServerSetCharacterX(NewChar);
        if( WorldInfo.NetMode==NM_Client )
            CharacterCustomizationChanged();
    }
}

simulated function UpdateCustomization( byte Type, int MeshIndex, int SkinIndex, optional int SlotIndex )
{
    switch( Type )
    {
    case CO_Head:
        CustomCharacter.HeadMeshIndex = MeshIndex;
        CustomCharacter.HeadSkinIndex = SkinIndex;
        break;
    case CO_Body:
        CustomCharacter.BodyMeshIndex = MeshIndex;
        CustomCharacter.BodySkinIndex = SkinIndex;
        break;
    case CO_Attachment:
        CustomCharacter.AttachmentMeshIndices[SlotIndex] = MeshIndex;
        CustomCharacter.AttachmentSkinIndices[SlotIndex] = SkinIndex;
        break;
    }
    SavePlayerCharacter();
    ServerSetCharacterX(CustomCharacter);
    if( WorldInfo.NetMode==NM_Client )
        CharacterCustomizationChanged();
}

simulated final function RemoveAttachments()
{
    local int i;

    for( i=0; i<`MAX_COSMETIC_ATTACHMENTS; ++i )
    {
        CustomCharacter.AttachmentMeshIndices[i] = `CLEARED_ATTACHMENT_INDEX;
        CustomCharacter.AttachmentSkinIndices[i] = 0;
    }
    SavePlayerCharacter();
    ServerSetCharacterX(CustomCharacter);
    if( WorldInfo.NetMode==NM_Client )
        CharacterCustomizationChanged();
}

simulated function ClearCharacterAttachment(int AttachmentIndex)
{
    if( UsesCustomChar() )
    {
        CustomCharacter.AttachmentMeshIndices[AttachmentIndex] = `CLEARED_ATTACHMENT_INDEX;
        CustomCharacter.AttachmentSkinIndices[AttachmentIndex] = 0;
    }
    else Super.ClearCharacterAttachment(AttachmentIndex);
}

reliable server final function ServerSetCharacterX( FMyCustomChar NewMeshInfo )
{
    if( NewMeshInfo.CharacterIndex>=(CharacterArchetypes.Length+CustomCharList.Length) || IsClientCharLocked(NewMeshInfo.CharacterIndex) )
        return;

    CustomCharacter = NewMeshInfo;

    if ( Role == Role_Authority )
    {
        CharacterCustomizationChanged();
    }
}

simulated final function bool IsClientCharLocked( byte Index )
{
    if( Index<CharacterArchetypes.Length )
        return false;
    Index-=CharacterArchetypes.Length;
    return (Index<CustomCharList.Length && CustomCharList[Index].bLock && !bAdmin);
}

simulated reliable client function ReceivedCharacter( byte Index, FCustomCharEntry C )
{
    if( WorldInfo.NetMode==NM_DedicatedServer )
        return;

    if( CustomCharList.Length<=Index )
        CustomCharList.Length = Index+1;
    CustomCharList[Index] = C;
}

simulated reliable client function AllCharReceived()
{
    if( WorldInfo.NetMode==NM_DedicatedServer )
        return;

    if( !bClientInitChars )
    {
        OnCharListDone();
        NotifyCharListDone();
        bClientInitChars = true;
    }
}

simulated final function NotifyCharListDone()
{
    local KFPawn_Human KFP;
    local KFCharacterInfo_Human NewCharArch;
    local ClassicPlayerReplicationInfo EPRI;

    foreach WorldInfo.AllPawns(class'KFPawn_Human', KFP)
    {
        EPRI = ClassicPlayerReplicationInfo(KFP.PlayerReplicationInfo);
        if( EPRI!=None )
        {
            NewCharArch = EPRI.GetSelectedArch();

            if( NewCharArch != KFP.CharacterArch )
            {
                // selected a new character
                KFP.SetCharacterArch( NewCharArch );
            }
            else if( WorldInfo.NetMode != NM_DedicatedServer )
            {
                // refresh cosmetics only
                class'ClassicCharacterInfo'.Static.SetCharacterMeshFromArch( NewCharArch, KFP, EPRI );
            }
        }
    }
}

simulated delegate OnCharListDone();

// Player has a server specific setting for a character selected.
simulated final function bool UsesCustomChar()
{
    if( LocalOwnerPRI==None || CustomCharacter.CharacterIndex < 0 )
        return false; // Not yet init on client.
    return CustomCharacter.CharacterIndex<(LocalOwnerPRI.CustomCharList.Length+CharacterArchetypes.Length);
}

// Client uses a server specific custom character.
simulated final function bool ReallyUsingCustomChar()
{
    if( !UsesCustomChar() )
        return false;
    return (CustomCharacter.CharacterIndex>=CharacterArchetypes.Length);
}

simulated final function KFCharacterInfo_Human GetSelectedArch()
{
    if( UsesCustomChar() )
    {
        if( CustomCharacter.CharacterIndex<CharacterArchetypes.Length )
        {
            return CharacterArchetypes[CustomCharacter.CharacterIndex];
        }
        else
        {
            return LocalOwnerPRI.CustomCharList[CustomCharacter.CharacterIndex-CharacterArchetypes.Length].Char;
        }
    }
    return CharacterArchetypes[RepCustomizationInfo.CharacterIndex];
}

simulated event CharacterCustomizationChanged()
{
    local KFPawn_Human KFP;
    local KFCharacterInfo_Human NewCharArch;

    foreach WorldInfo.AllPawns(class'KFPawn_Human', KFP)
    {
        if( KFP.PlayerReplicationInfo == self || (KFP.DrivenVehicle != None && KFP.DrivenVehicle.PlayerReplicationInfo == self) )
        {
            NewCharArch = GetSelectedArch();

            if( NewCharArch != KFP.CharacterArch )
            {
                // selected a new character
                KFP.SetCharacterArch( NewCharArch );
            }
            else if( WorldInfo.NetMode != NM_DedicatedServer )
            {
                // refresh cosmetics only
                class'ClassicCharacterInfo'.Static.SetCharacterMeshFromArch( NewCharArch, KFP, self );
            }
        }
    }
}

// Save/Load custom character information.
final function SaveCustomCharacter( KFSaveDataBase Data )
{
    local int i,c;
    local string S;

    // Write the name of custom character.
    if( UsesCustomChar() )
        S = string(GetSelectedArch().Name);
    Data.SaveStr(S);
    if( S=="" )
        return;
    
    // Write selected accessories.
    Data.SaveInt(CustomCharacter.HeadMeshIndex);
    Data.SaveInt(CustomCharacter.HeadSkinIndex);
    Data.SaveInt(CustomCharacter.BodyMeshIndex);
    Data.SaveInt(CustomCharacter.BodySkinIndex);
    
    c = 0;
    for( i=0; i<`MAX_COSMETIC_ATTACHMENTS; ++i )
    {
        if( CustomCharacter.AttachmentMeshIndices[i]!=`CLEARED_ATTACHMENT_INDEX )
            ++c;
    }

    // Write attachments count.
    Data.SaveInt(c);
    
    // Write attachments.
    for( i=0; i<`MAX_COSMETIC_ATTACHMENTS; ++i )
    {
        if( CustomCharacter.AttachmentMeshIndices[i]!=`CLEARED_ATTACHMENT_INDEX )
        {
            Data.SaveInt(i);
            Data.SaveInt(CustomCharacter.AttachmentMeshIndices[i]);
            Data.SaveInt(CustomCharacter.AttachmentSkinIndices[i]);
        }
    }
}

final function LoadCustomCharacter( KFSaveDataBase Data )
{
    local string S;
    local int i,n,j;

    if( Data.GetArVer()>=2 )
        S = Data.ReadStr();
    if( S=="" ) // Stock skin.
        return;

    for( i=0; i<CharacterArchetypes.Length; ++i )
    {
        if( string(CharacterArchetypes[i].Name)~=S )
            break;
    }
    
    if( i==CharacterArchetypes.Length )
    {
        for( i=0; i<CustomCharList.Length; ++i )
        {
            if( string(CustomCharList[i].Char.Name)~=S )
                break;
        }
        if( i==CharacterArchetypes.Length )
        {
            // Character not found = Skip data.
            Data.SkipBytes(4);
            n = Data.ReadInt();
            for( i=0; i<n; ++i )
                Data.SkipBytes(3);
            return;
        }
        i+=CharacterArchetypes.Length;
    }

    CustomCharacter.CharacterIndex = i;
    CustomCharacter.HeadMeshIndex = Data.ReadInt();
    CustomCharacter.HeadSkinIndex = Data.ReadInt();
    CustomCharacter.BodyMeshIndex = Data.ReadInt();
    CustomCharacter.BodySkinIndex = Data.ReadInt();

    n = Data.ReadInt();
    for( i=0; i<n; ++i )
    {
        j = Min(Data.ReadInt(),`MAX_COSMETIC_ATTACHMENTS-1);
        CustomCharacter.AttachmentMeshIndices[j] = Data.ReadInt();
        CustomCharacter.AttachmentSkinIndices[j] = Data.ReadInt();
    }
    bNetDirty = true;
}

// Only used to skip offset (in case of an error).
static final function DummyLoadChar( KFSaveDataBase Data )
{
    local string S;
    local int i,n;

    if( Data.GetArVer()>=2 )
        S = Data.ReadStr();
    if( S=="" ) // Stock skin.
        return;

    Data.SkipBytes(4);
    n = Data.ReadInt();
    for( i=0; i<n; ++i )
        Data.SkipBytes(3);
}

static final function DummySaveChar( KFSaveDataBase Data )
{
    Data.SaveStr("");
}

reliable client function ShowKickVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(Owner);
    if( KFPC != None )
    {
        KFHUDInterface(KFPC.myHUD).ShowVoteUI(PRI, VoteDuration, bShowChoices, VT_TYPE_KICK);
    }
}

reliable client function HideKickVote()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(Owner);
    if( KFPC != None )
    {
        KFHUDInterface(KFPC.myHUD).HideVoteUI();
    }
}

simulated function Texture2D GetCurrentIconToDisplay()
{
    if( CurrentVoiceCommsRequest == VCT_NONE )
    {
        if( class<ClassicPerk_Base>(CurrentPerkClass) != None )
            return class<ClassicPerk_Base>(CurrentPerkClass).static.GetCurrentPerkIcon(CurrentPerkLevel);
        else return Super.GetCurrentIconToDisplay();
    }

    return class'KFLocalMessage_VoiceComms'.default.VoiceCommsIcons[CurrentVoiceCommsRequest];
}

simulated function LoadAllHeadshotEffects()
{
    local ClassicHeadShotEffectList EffectList;
    local int i;
    
    EffectList = ClassicHeadShotEffectList(FindObject("KFClassicMode.Default__ClassicHeadShotEffectList",class'ClassicHeadShotEffectList'));
    for(i=0; i<EffectList.HeadshotFXIDs.Length; i++)
    {
        EffectList.HeadshotFXIDs[i].EffectPS = ParticleSystem(class'ClassicCharacterInfo'.Static.SafeLoadObject(EffectList.HeadshotFXIDs[i].EffectPSName, class'ParticleSystem'));
    }
}

reliable server function ServerSetCurrentHeadShotSFX(int ItemID)
{
    CurrentHeadShotEffectIndex = ItemID;
}

simulated final function int GetHeadShotEffectIndex()
{
	return CurrentHeadShotEffectIndex;
}

// BodyVariants, HeadVariants, and CosmeticVariants are const but the asset var isn't used anyway so lets just not full load a UPK
simulated function bool StartLoadCosmeticContent(KFCharacterInfo_Human CharArch, INT CosmeticType, INT CosmeticIdx)
{
    return true;
}

// I already load the headshot effects so lets make this function do nothing
simulated function StartLoadHeadshotFxContent()
{
    return;
}

defaultproperties
{
}