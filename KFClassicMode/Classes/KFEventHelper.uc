Class KFEventHelper extends ReplicationInfo
    transient;

var protected enum EEventTypes
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

defaultproperties
{
}