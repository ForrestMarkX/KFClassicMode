class ClassicStartContainer_InGameOverview extends KFGFxStartContainer_InGameOverview;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	Super.Initialize(NewParentMenu);
	
	if(SharedContentButton != none)
	{
		SharedContentButton.SetVisible(false);
	}
}

function UpdateSharedContent();

DefaultProperties
{
}

