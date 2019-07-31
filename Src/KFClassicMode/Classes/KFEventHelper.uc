Class KFEventHelper extends ReplicationInfo
    transient;

var protectedwrite enum EEventTypes
{
    EV_NONE,
    EV_NORMAL,
    EV_SUMMER,
    EV_WINTER,
    EV_SPRING,
    EV_FALL
} CurrentEventType;

replication
{
    if( true )
        CurrentEventType;
}

simulated static final function KFEventHelper FindEventHelper( WorldInfo Level )
{
    local KFEventHelper H;
    
    foreach Level.DynamicActors(class'KFEventHelper',H)
    {
        if( H != None )
            return H;
    }
    
    if( Level.NetMode!=NM_Client )
    {
        H = Level.Spawn(class'KFEventHelper');
        return H;
    }
    
    return None;
}

simulated function EEventTypes GetEventType()
{
    return CurrentEventType;
}

simulated function SetEventType(EEventTypes Type)
{
    CurrentEventType = Type;
}

simulated function SeasonalEventIndex GetSeasonalID()
{
    switch( CurrentEventType )
    {
        case EV_SUMMER:
            return SEI_Summer;
        case EV_WINTER:
            return SEI_Winter;
        case EV_FALL:
            return SEI_Fall;
        case EV_SPRING:
            return SEI_Spring;
        default:
            return SEI_None;
    }
    
    return SEI_None;
}

simulated function name GetSeasonalName(SeasonalEventIndex ID)
{
    switch( ID )
    {
        case SEI_Summer:
            return 'Summer_Sideshow';
        case SEI_Winter:
            return 'Winter';
        case SEI_Fall:
            return 'Fall';
        case SEI_Spring:
            return 'Spring';
        default:
            return 'No_Event';
    }
    
    return 'No_Event';
}

defaultproperties
{
}