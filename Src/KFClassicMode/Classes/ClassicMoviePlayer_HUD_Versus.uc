class ClassicMoviePlayer_HUD_Versus extends KFGFxMoviePlayer_HUD_Versus;

DefaultProperties
{
	WidgetBindings.Remove((WidgetName="moveListContainer",WidgetClass=class'KFGFxHUD_PlayerMoveList'))
	WidgetBindings.Add((WidgetName="moveListContainer",WidgetClass=class'ClassicHUD_PlayerMoveList'))
}
