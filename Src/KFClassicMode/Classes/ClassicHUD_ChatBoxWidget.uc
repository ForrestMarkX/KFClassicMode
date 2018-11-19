class ClassicHUD_ChatBoxWidget extends KFGFxHUD_ChatBoxWidget;

function Init()
{
    SetVisible(false);
}

function AddChatMessage(string NewMessage, string HexVal);
function OpenInputField();
function array<GFxObject> GetDataObjects();
function SetDataObjects( array<GFxObject> DataObjects);
function SetLobbyChatVisible(bool bIsVisible);
function ClearAndCloseChat();

defaultproperties
{
}

