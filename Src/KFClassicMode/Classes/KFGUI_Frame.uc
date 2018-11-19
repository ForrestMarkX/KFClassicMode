Class KFGUI_Frame extends KFGUI_FloatingWindow;
 
var() float EdgeSize[4]; // Pixels wide for edges (left, top, right, bottom).
var() float HeaderSize[2]; // Pixels wide for edges (left, top).
var() Texture FrameTex;
var() bool bDrawHeader,bHeaderCenter,bUseLegacyDrawTile,bDrawBackground;
var() float FontScale;
 
function InitMenu()
{
    Super(KFGUI_Page).InitMenu();
}

function DrawMenu()
{
    if( bDrawBackground )
    {
        OnDrawFrame(Canvas, CompPos[2], CompPos[3]);
    }
}

delegate OnDrawFrame(Canvas C, float W, Float H)
{
    local float T,XL,YL;
    local FontRenderInfo FRI;
    
    if( FrameTex == None )
    {
        return;
    }
    
    C.SetDrawColor(255,255,255,FrameOpacity);
    if( bUseLegacyDrawTile )
    {
        Owner.CurrentStyle.DrawTileStretched(FrameTex,0,0,W,H);
    }
    else 
    {
        Canvas.SetPos(0.f, 0.f);
        Canvas.DrawTileStretched(FrameTex,W,H,0,0,FrameTex.GetSurfaceWidth(),FrameTex.GetSurfaceHeight());
    }
   
    if( bDrawHeader && WindowTitle!="" )
    {
        FRI.bClipText = true;
        FRI.bEnableShadow = true;
    
        C.Font = Owner.CurrentStyle.MainFont;
        T = FontScale;
        
        C.SetDrawColor(250,250,250,FrameOpacity);
        C.TextSize(WindowTitle, XL, YL, T, T);
        
        if( bHeaderCenter )
            C.SetPos((W/2) - (XL/2),HeaderSize[1]);
        else C.SetPos(HeaderSize[0],HeaderSize[1]);
        
        C.DrawText(WindowTitle,,T,T,FRI);
    }
}
 
function PreDraw()
{
    local int i;
    local byte j;
    
    if( !bVisible )
        return;
 
    ComputeCoords();
    Canvas.SetDrawColor(255,255,255);
    Canvas.SetOrigin(CompPos[0],CompPos[1]);
    Canvas.SetClip(CompPos[0]+CompPos[2],CompPos[1]+CompPos[3]);
    DrawMenu();
    
    for( i=0; i<Components.Length; ++i )
    {
        Components[i].Canvas = Canvas;
        for( j=0; j<4; ++j )
        {
            Components[i].InputPos[j] = CompPos[j]+EdgeSize[j];
        }
        Components[i].PreDraw();
    }
}

defaultproperties
{
    bDrawHeader=true
    bUseLegacyDrawTile=true
    bDrawBackground=true
    
    FontScale=0.35f
    FrameOpacity=255
    
    HeaderSize(0)=26.f
    HeaderSize(1)=0.f
   
    EdgeSize(0)=20
    EdgeSize(1)=35
    EdgeSize(2)=-40
    EdgeSize(3)=-50
}