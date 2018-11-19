class ClassicDialogManager extends KFDialogManager;

function float GetEventRadius( int EventID, class< KFPawnVoiceGroupEventData > EventDataClass )
{
    if( EventDataClass != none )
    {
        return EventDataClass.default.Events[EventID].Radius;
    }

    return 0.f;
}

function float GetEventFOV( int EventID, class< KFPawnVoiceGroupEventData > EventDataClass )
{
    if( EventDataClass != none )
    {
        return EventDataClass.default.Events[EventID].FOV;
    }

    return 0.f;
}

function byte GetEventPriority( int EventID, class< KFPawnVoiceGroupEventData > EventDataClass )
{
    if( EventDataClass != none )
    {
        return EventDataClass.default.Events[EventID].Priority;
    }

    return 255;
}

function float GetEventCoolDownTime( int EventID, class< KFPawnVoiceGroupEventData > EventDataClass )
{
    if( EventDataClass != none )
    {
        return EventDataClass.default.Events[EventID].CoolDownTime;
    }

    return 0.f;
}

function float GetEventCoolDownRadius( int EventID, class< KFPawnVoiceGroupEventData > EventDataClass )
{
    if( EventDataClass != none )
    {
        return EventDataClass.default.Events[EventID].CoolDownRadius;
    }

    return 0.f;
}

function int GetEventCoolDownCategory( int EventID, class< KFPawnVoiceGroupEventData > EventDataClass )
{
    if( EventDataClass != none )
    {
        if( EventDataClass.default.Events.Length > EventID )
        {
            return EventDataClass.default.Events[EventID].CoolDownCategory;
        }
        else
        {
            return 255;
        }
    }

    return 255;
}

function bool GetEventIsOnlyPlayedLocally( int EventID, class< KFPawnVoiceGroupEventData > EventDataClass )
{
    if( EventDataClass != none )
    {
        return EventDataClass.default.Events[EventID].bOnlyPlayLocally;
    }

    return true;
}

DefaultProperties
{
}
