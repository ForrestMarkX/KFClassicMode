Class MS_HUD extends HUD;

var bool bShowProgress,bProgressDC;
var array<string> ProgressLines;

event PostRender()
{
    if( bShowProgress )
        RenderProgress();
}

final function ShowProgressMsg( string S, optional bool bDis )
{
    if( S=="" )
    {
        bShowProgress = false;
        return;
    }
    bShowProgress = true;
    ParseStringIntoArray(S,ProgressLines,"|",false);
    bProgressDC = bDis;
    if( !bDis )
        ProgressLines.AddItem("Press [Esc] to cancel connection");
}

final function RenderProgress()
{
    local float Y,XL,YL,Sc;
    local int i;
    
    Canvas.Font = Canvas.GetDefaultCanvasFont();
    Sc = FMin(Canvas.ClipY/1000.f,3.f);
    if( bProgressDC )
        Canvas.SetDrawColor(255,80,80,255);
    else Canvas.SetDrawColor(255,255,255,255);
    Y = Canvas.ClipY*0.05;

    for( i=0; i<ProgressLines.Length; ++i )
    {
        Canvas.TextSize(ProgressLines[i],XL,YL,Sc,Sc);
        Canvas.SetPos((Canvas.ClipX-XL)*0.5,Y);
        Canvas.DrawText(ProgressLines[i],,Sc,Sc);
        Y+=YL;
    }
    Canvas.SetPos(Canvas.ClipX*0.2,Canvas.ClipY*0.91);
}

defaultproperties
{
}