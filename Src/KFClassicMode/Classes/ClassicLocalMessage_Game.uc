class ClassicLocalMessage_Game extends KFLocalMessage_Game;

static function string GetString(
    optional int Switch,
    optional bool bPRI1HUD,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local string TempString;
    local KFGFxObject_TraderItems TraderItems;
    local int Index;

    switch ( Switch )
    {
        case GMT_PickedupItem:
            if( KFWeapon(OptionalObject) != None )
            {
                TraderItems = KFGameReplicationInfo( KFWeapon(OptionalObject).WorldInfo.GRI ).TraderItems;
                Index = TraderItems.SaleItems.Find('ClassName', KFWeapon(OptionalObject).Class.Name);
                if( Index != INDEX_NONE )
                {
                    TempString = TraderItems.SaleItems[Index].WeaponDef.static.GetItemName();
                }
            }
            else
            {
                TempString = Inventory( OptionalObject ).ItemName;
            }
            
            return default.PickupMessage @ TempString;
        default:
            return Super.GetString(Switch, bPRI1HUD, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    }
}


DefaultProperties
{
}

