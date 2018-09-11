class ClassicThirdPersonCameraMode extends KFThirdPersonCameraMode;

var const ViewOffsetData AboveHead;
var const ViewOffsetData RightShoulderClose;
var const ViewOffsetData RightShoulderFar;
var const ViewOffsetData LeftShoulderClose;
var const ViewOffsetData LeftShoulderFar;

static simulated function ViewOffsetData GetViewOffset(ECameraViewModes ViewMode)
{
    switch (ViewMode)
    {
        case CVM_ThirdPersonAboveHead: return default.AboveHead;
        case CVM_ThirdPersonRightShoulderClose: return default.RightShoulderClose;
        case CVM_ThirdPersonRightShoulderFar: return default.RightShoulderFar;
        case CVM_ThirdPersonLeftShoulderClose: return default.LeftShoulderClose;
        case CVM_ThirdPersonLeftShoulderFar: return default.LeftShoulderFar;
    }

    return default.AboveHead;
}

defaultproperties
{
    AboveHead={( OffsetHigh=(X=-176,Y=0,Z=61),
                 OffsetLow=(X=-200,Y=0,Z=61),
                 OffsetMid=(X=-200,Y=0,Z=45), )}

    RightShoulderClose={( OffsetHigh=(X=-96,Y=61,Z=16),
                          OffsetLow=(X=-120,Y=53,Z=16),
                          OffsetMid=(X=-120,Y=53,Z=0), )}

    RightShoulderFar={( OffsetHigh=(X=-176,Y=61,Z=16),
                        OffsetLow=(X=-200,Y=53,Z=16),
                        OffsetMid=(X=-200,Y=53,Z=0), )}

    LeftShoulderClose={( OffsetHigh=(X=-96,Y=-61,Z=16),
                         OffsetLow=(X=-120,Y=-53,Z=16),
                         OffsetMid=(X=-120,Y=-53,Z=0), )}

    LeftShoulderFar={( OffsetHigh=(X=-176,Y=-61,Z=16),
                       OffsetLow=(X=-200,Y=-53,Z=16),
                       OffsetMid=(X=-200,Y=-53,Z=0), )}
}