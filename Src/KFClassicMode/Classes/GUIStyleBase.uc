Class GUIStyleBase extends Object
    abstract;

var Texture2D ItemTex;
var array<Texture2D> BorderTextures, ArrowTextures, ButtonTextures, TabTextures, ItemBoxTextures, PerkBox, CheckBoxTextures, ProgressBarTextures, SliderTextures;
var Texture2D ScrollTexture,FavoriteIcon,BankNoteIcon; 

var SoundCue MenuDown, MenuDrag, MenuEdit, MenuFade, MenuClick, MenuHover, MenuUp;

var() byte MaxFontScale;
var float DefaultHeight; // Default font text size.
var transient Canvas Canvas;
var transient KF2GUIController Owner;

var Font MainFont, NumberFont, InfiniteFont;
var Color BlurColor, BlurColor2;

struct FColorInfo
{
    var name Code;
    var Color Color;
};
var array<FColorInfo> ColorCodes;

function InitStyle()
{
    local FColorInfo ColorInfo;
    
    ItemTex=Texture2D(DynamicLoadObject("UI_LevelChevrons_TEX.UI_LevelChevron_Icon_02",class'Texture2D'));
    if( ItemTex==None )
        ItemTex=Texture2D'EngineMaterials.DefaultWhiteGrid';
        
    NumberFont = Font(DynamicLoadObject("UI_Canvas_Fonts.Font_General", class'Font'));
    
    BlurColor = MakeColor(60, 60, 60, 220);
    BlurColor2 = MakeColor(40, 40, 40, 140);
    
    ColorInfo.Code='Q';
    ColorInfo.Color = MakeColor(0,140,0,255); // Dark Green
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='E';
    ColorInfo.Color = MakeColor(210,180,140,255); // Tan
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='R';
    ColorInfo.Color = MakeColor(128,0,0,255); // Dark Red
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='T';
    ColorInfo.Color = MakeColor(153,102,204,255); // Purple
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='U';
    ColorInfo.Color = MakeColor(128,128,128,255); // Dark Gray
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='I';
    ColorInfo.Color = MakeColor(255,170,0,255); // Orange
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='O';
    ColorInfo.Color = MakeColor(255,204,153,255); // Cream
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='P';
    ColorInfo.Color = MakeColor(209,216,168,255); // Olive
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='A';
    ColorInfo.Color = MakeColor(204,51,51,255); // Brick
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='S';
    ColorInfo.Color = MakeColor(153,102,51,255); // Brown
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='D';
    ColorInfo.Color = MakeColor(0,204,0,255); // Green
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='F';
    ColorInfo.Color = MakeColor(238,238,51,255); // Yellow
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='G';
    ColorInfo.Color = MakeColor(200,0,0,255); // Red
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='H';
    ColorInfo.Color = MakeColor(153,153,255,255); // Blue
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='J';
    ColorInfo.Color = MakeColor(192,192,192,255); // Silver
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='K';
    ColorInfo.Color = MakeColor(255,204,0,255); // Gold
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='C';
    ColorInfo.Color = MakeColor(255,255,255,255); // White
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='V';
    ColorInfo.Color = MakeColor(0,191,255,255); // Sky Blue
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='B';
    ColorInfo.Color = MakeColor(204,204,204,255); // Gray
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='N';
    ColorInfo.Color = MakeColor(0,128,255,255); // Dark Sky Blue
    ColorCodes.AddItem(ColorInfo);
    
    ColorInfo.Code='M';
    ColorInfo.Color = MakeColor(18,18,18,255); // Black
    ColorCodes.AddItem(ColorInfo);
}

function RenderFramedWindow( KFGUI_FloatingWindow P );
function RenderWindow( KFGUI_Page P );
function RenderToolTip( KFGUI_Tooltip TT );
function RenderButton( KFGUI_Button B );
function RenderScrollBar( KFGUI_ScrollBarBase S );
function RenderColumnHeader( KFGUI_ColumnTop C, float XPos, float Width, int Index, bool bFocus, bool bSort );
function RenderRightClickMenu( KFGUI_RightClickMenu C );
function RenderCheckbox( KFGUI_CheckBox C );
function RenderComboBox( KFGUI_ComboBox C );
function RenderComboList( KFGUI_ComboSelector C );

function Font PickFont( out float Scaler, optional bool bNumbersOnly, optional bool bInfinite )
{
    Scaler = GetFontScaler();
    
    if( bNumbersOnly )
        return NumberFont;
    else if( bInfinite )
        return InfiniteFont;
    
    return MainFont;
}

function PickDefaultFontSize( float YRes )
{
    local int XL,YL;
    local string S;

    S="ABC";
    PickFont(YRes).GetStringHeightAndWidth(S,YL,XL);
    
    DefaultHeight=float(YL)*YRes;
}
final function float ScreenScale( float Size, optional float MaxRes=1920.f )
{
    local float SizeX;
    
    if( Owner == None )
        SizeX = Canvas.SizeX;
    else SizeX = Owner.ScreenSize.X;
    
    return Size * ( SizeX / MaxRes );
}
final function float GetFontScaler(optional float Scaler=0.375f, optional float Min=0.175f, optional float Max=0.375f)
{
    local float SizeX;
    
    if( Owner == None )
        SizeX = Canvas.SizeX;
    else SizeX = Owner.ScreenSize.X;
    
    return FClamp((SizeX / 1920.f) * Scaler, Min, Max);
}
final function DrawText( coerce string S )
{
    local float Scale;
    
    Canvas.Font=PickFont(Scale);
    Canvas.DrawText(S,,Scale,Scale);
}
final function DrawCenteredText( coerce string S, float X, float Y, optional float Scale=1.f, optional bool bVertical, optional bool bUseOutline )
{
    local float XL,YL;

    Canvas.TextSize(S,XL,YL);
    if( bVertical )
        Canvas.SetPos(X,Y-(YL*Scale*0.5));
    else Canvas.SetPos(X-(XL*Scale*0.5),Y);
    
    if( bUseOutline )
        DrawTextShadow(S, Canvas.CurX, Canvas.CurY, 1, Scale);
    else Canvas.DrawText(S,,Scale,Scale);
}
final function string StripColorTags( coerce string S )
{
    local int Pos;
    
    Pos = InStr(S, "\\c");
    while( Pos != INDEX_NONE )
    {
        S = Left(S,Pos) $ Mid(S,Pos+3);
        Pos = InStr(S, "\\c");
    }
    
    return S;
}
final function DrawColoredText( coerce string S, float X, float Y, optional float Scale=1.f, optional bool bUseOutline )
{
    local float XL,YL;
    local int i, Index;
    local array<string> SArray;
    local string T, PrevT;
    local Color TextColor;
    local Color OrgC;
    
    OrgC = Canvas.DrawColor;
    Canvas.TextSize(S,XL,YL);
    
    if( InStr(S, "\\c") == INDEX_NONE )
    {
        if( bUseOutline )
            DrawTextShadow(S, X, Y, 1, Scale);
        else 
        {
            Canvas.SetPos(X,Y);
            Canvas.DrawText(S,,Scale,Scale);
        }
    }
    else
    {
        SArray = SplitString(S, "\\c");
        
        PrevT = Left(S,InStr(S, "\\c"));
        if( Len(PrevT) > 0 )
        {
            Canvas.TextSize(PrevT,XL,YL,Scale,Scale);

            if( bUseOutline )
                DrawTextShadow(PrevT, X, Y, 1, Scale);
            else 
            {
                Canvas.SetPos(X,Y);
                Canvas.DrawText(PrevT,,Scale,Scale);
            }
        }
        
        for( i=0; i<SArray.Length; i++ )
        {
            T = SArray[i];
            if( i>0 || Left(S, 2)~="\\c" )
            {
                Index = ColorCodes.Find('Code', name(Left(T, 1)));
                if( Index != INDEX_NONE )
                    TextColor = ColorCodes[Index].Color;
                else TextColor = class'HUD'.default.WhiteColor;
                
                TextColor.A = OrgC.A;
                
                T = Mid(T, 1);
            }
            
            Canvas.DrawColor = TextColor;
            Canvas.TextSize(T,XL,YL,Scale,Scale);
            
            if( bUseOutline )
                DrawTextShadow(T, X, Y, 1, Scale);
            else 
            {
                Canvas.SetPos(X,Y);
                Canvas.DrawText(T,,Scale,Scale);
            }

            X += XL;
        }
    }
}
final function DrawTextBlurry( coerce string S, float X, float Y, optional float Scale=1.f )
{
    local Color OldDrawColor;
    
    OldDrawColor = Canvas.DrawColor;
    BlurColor.A = OldDrawColor.A * 0.85;
    BlurColor2.A = OldDrawColor.A * 0.55;
    
    Canvas.DrawColor = BlurColor;
    Canvas.SetPos(X + Owner.FontBlurX, Y + Owner.FontBlurY);
    Canvas.DrawText(S,,Scale,Scale);
    
    Canvas.DrawColor = BlurColor2;
    Canvas.SetPos(X + Owner.FontBlurX2, Y + Owner.FontBlurY2);
    Canvas.DrawText(S,,Scale,Scale);
    
    Canvas.DrawColor = OldDrawColor;
    Canvas.SetPos(X, Y);
    Canvas.DrawText(S,,Scale,Scale);
}
final function DrawTextOutline( coerce string S, float X, float Y, int Size, Color OutlineColor, optional float Scale=1.f, optional FontRenderInfo FRI )
{
    local Color OldDrawColor;
    local int XS, YS, Steps;
    
    OldDrawColor = Canvas.DrawColor;
    OutlineColor.A = OldDrawColor.A;
    
    Size += 1;
    Steps = (Size * 2) / 3;
    if( Steps < 1 ) 
    {
        Steps = 1;
    }
    
    Canvas.DrawColor = OutlineColor;
    for (XS = -Size; XS <= Size; XS+=Steps)
    {
        for (YS = -Size; YS <= Size; YS+=Steps)
        {
            Canvas.SetPos(X + XS, Y + YS);
            Canvas.DrawText(S,, Scale, Scale, FRI);
        }
    }
    
    Canvas.DrawColor = OldDrawColor;
    Canvas.SetPos(X, Y);
    Canvas.DrawText(S,, Scale, Scale, FRI);
}
final function DrawTextShadow( coerce string S, float X, float Y, float ShadowSize, optional float Scale=1.f )
{
    local Color OldDrawColor;
    
    OldDrawColor = Canvas.DrawColor;
    
    Canvas.SetPos(X + ShadowSize, Y + ShadowSize);
    Canvas.SetDrawColor(0, 0, 0, OldDrawColor.A);
    Canvas.DrawText(S,, Scale, Scale);
    
    Canvas.SetPos(X, Y);
    Canvas.DrawColor = OldDrawColor;
    Canvas.DrawText(S,, Scale, Scale);
}
final function DrawTexturedString( coerce string S, float X, float Y, optional float TextScaler=1.f, optional FontRenderInfo FRI, optional bool bUseOutline, optional bool bOnlyTexture )
{
    local Texture2D Mat;
    local string D;
    local float XL, YL;
    local int i,j;
    local Color OrgC;
    
    OrgC = Canvas.DrawColor;
    
    Mat = FindNextTexture(S);
    while( Mat != None )
    {
        i = InStr(S,"<TEXTURE");
        j = InStr(S,">");
        
        D = Left(S,i);
        S = Mid(S,j+2);
        
        if( !bOnlyTexture )
        {
            Canvas.TextSize(StripColorTags(D),XL,YL,TextScaler,TextScaler);
            DrawColoredText(D,X,Y,TextScaler,bUseOutline);
            
            X += XL;
        }
        else Canvas.TextSize("W",XL,YL,TextScaler,TextScaler);
        
        Canvas.DrawColor = class'HUD'.default.WhiteColor;
        Canvas.DrawColor.A = OrgC.A;
        
        Canvas.SetPos(X,Y+(Owner.HUDOwner.ScaledBorderSize/2));
        Canvas.DrawRect(YL-Owner.HUDOwner.ScaledBorderSize,YL-Owner.HUDOwner.ScaledBorderSize,Mat);
        
        X += YL-Owner.HUDOwner.ScaledBorderSize;
        
        Canvas.DrawColor = OrgC;
        Mat = FindNextTexture(S);
    }
    
    DrawColoredText(S,X,Y,TextScaler,bUseOutline);
}
final function Texture2D FindNextTexture(out string S)
{
    local int i, j;
    local string Path;
    local Texture2D Tex;

    Path = S;
    i = InStr(Path,"<Icon>");
    if( i == INDEX_NONE )
        return None;
        
    j = InStr(Path,"</Icon>");
    S = Left(Path,i)$"<TEXTURE>"$Mid(Path, j+Len("/Icon>"));
    
    Tex = Texture2D(FindObject(Mid(Path, i+6, j-(i+6)), class'Texture2D'));
    if( Tex != None )
        return Tex;

    return Texture2D(DynamicLoadObject(Mid(Path, i+6, j-(i+6)), class'Texture2D'));
}
final function string StripTextureFromString(string S, optional bool bNoStringAdd)
{
    local int i, j;
    
    while( true )
    {
        i = InStr(S,"<Icon>");
        if( i == INDEX_NONE )
            break;
            
        j = InStr(S,"</Icon>");
        S = Left(S,i)$(bNoStringAdd ? "" : "W")$Mid(S, j+Len("</Icon>"));
    }

    return StripColorTags(S);
}
final function string GetTimeString(int Seconds)
{
    local int Minutes, Hours;
    local string Time;

    if( Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

        Time = Hours$":";
    }
    Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    if( Minutes >= 10 )
        Time = Time $ Minutes $ ":";
    else Time = Time $ "0" $ Minutes $ ":";

    if( Seconds >= 10 )
        Time = Time $ Seconds;
    else Time = Time $ "0" $ Seconds;

    return Time;
}

final function DrawCornerTexNU( int SizeX, int SizeY, byte Dir ) // Draw non-uniform corner.
{
    switch( Dir )
    {
    case 0: // Up-left
        Canvas.DrawTile(ItemTex,SizeX,SizeY,77,15,-66,58);
        break;
    case 1: // Up-right
        Canvas.DrawTile(ItemTex,SizeX,SizeY,11,15,66,58);
        break;
    case 2: // Down-left
        Canvas.DrawTile(ItemTex,SizeX,SizeY,77,73,-66,-58);
        break;
    default: // Down-right
        Canvas.DrawTile(ItemTex,SizeX,SizeY,11,73,66,-58);
    }
}
final function DrawCornerTex( int Size, byte Dir )
{
    switch( Dir )
    {
    case 0: // Up-left
        Canvas.DrawTile(ItemTex,Size,Size,77,15,-66,58);
        break;
    case 1: // Up-right
        Canvas.DrawTile(ItemTex,Size,Size,11,15,66,58);
        break;
    case 2: // Down-left
        Canvas.DrawTile(ItemTex,Size,Size,77,73,-66,-58);
        break;
    default: // Down-right
        Canvas.DrawTile(ItemTex,Size,Size,11,73,66,-58);
    }
}
final function DrawWhiteBox( float XS, float YS, optional bool bClip )
{
    Canvas.DrawTile(ItemTex,XS,YS,19,45,1,1,,bClip);
}

final function DrawRectBox( float X, float Y, float XS, float YS, int Edge, optional byte Extrav )
{
    if( Extrav==2 )
        Edge=Min(FMin(Edge,(XS)*0.5),YS);// Verify size.
    else Edge=Min(FMin(Edge,(XS)*0.5),(YS)*0.5);// Verify size.
    
    Canvas.PreOptimizeDrawTiles(Extrav==0 ? 7 : 6, ItemTex);

    // Top left
    Canvas.SetPos(X,Y);
    DrawCornerTex(Edge,0);
    
    if( Extrav<=1 )
    {
        if( Extrav==0 )
        {
            // Top right
            Canvas.SetPos(X+XS-Edge,Y);
            DrawCornerTex(Edge,1);
            
            // Bottom right
            Canvas.SetPos(X+XS-Edge,Y+YS-Edge);
            DrawCornerTex(Edge,3);
            
            // Fill
            Canvas.SetPos(X+Edge,Y);
            DrawWhiteBox(XS-Edge*2,YS);
            Canvas.SetPos(X,Y+Edge);
            DrawWhiteBox(Edge,YS-Edge*2);
            Canvas.SetPos(X+XS-Edge,Y+Edge);
            DrawWhiteBox(Edge,YS-Edge*2);
        }
        else if( Extrav==1 )
        {
            // Top right
            Canvas.SetPos(X+XS,Y);
            DrawCornerTex(Edge,3);
            
            // Bottom right
            Canvas.SetPos(X+XS,Y+YS-Edge);
            DrawCornerTex(Edge,1);

            // Fill
            Canvas.SetPos(X+Edge,Y);
            DrawWhiteBox(XS-Edge,YS);
            Canvas.SetPos(X,Y+Edge);
            DrawWhiteBox(Edge,YS-Edge*2);
        }
        
        // Bottom left
        Canvas.SetPos(X,Y+YS-Edge);
        DrawCornerTex(Edge,2);
    }
    else
    {
        // Top right
        Canvas.SetPos(X+XS-Edge,Y);
        DrawCornerTex(Edge,1);
        
        // Bottom right
        Canvas.SetPos(X+XS-Edge,Y+YS);
        DrawCornerTex(Edge,2);
        
        // Bottom left
        Canvas.SetPos(X,Y+YS);
        DrawCornerTex(Edge,3);
        
        // Fill
        Canvas.SetPos(X,Y+Edge);
        DrawWhiteBox(XS,YS-Edge);
        Canvas.SetPos(X+Edge,Y);
        DrawWhiteBox(XS-Edge*2,Edge);
    }
}

final function DrawBoxHollow( float X, float Y, float Width, float Height, float Thickness )
{
    Canvas.PreOptimizeDrawTiles(4, ItemTex);

    Canvas.SetPos(X + Thickness, Y);
    DrawWhiteBox(Width - Thickness * 2, Thickness);

    Canvas.SetPos(X + Thickness, Y+Height-Thickness);
    DrawWhiteBox(Width - Thickness * 2, Thickness);

    Canvas.SetPos(X, Y);
    DrawWhiteBox(Thickness, Height);

    Canvas.SetPos(X + Width - Thickness, Y);
    DrawWhiteBox(Thickness, Height);
}

final function DrawOutlinedBox( float X, float Y, float Width, float Height, float Thickness, Color BoxColor, Color OutlineColor )
{
    Canvas.DrawColor = BoxColor;
    Canvas.SetPos(X + Thickness, Y + Thickness);
    DrawWhiteBox(Width - (Thickness*2), Height - (Thickness*2));
    
    Canvas.DrawColor = OutlineColor;
    DrawBoxHollow(X, Y, Width, Height, Thickness);
}

final function DrawBoxCorners(float BorderSize, float X, float Y, float W, float H, optional bool TopLeft, optional bool TopRight, optional bool BottomLeft, optional bool BottomRight)
{
    // Top left
    Canvas.SetPos(X,Y);
    if( TopLeft )
        DrawCornerTex(BorderSize,0);
    else DrawWhiteBox(BorderSize, BorderSize);
    
    // Top right
    Canvas.SetPos(X+W-BorderSize,Y);
    if( TopRight )
        DrawCornerTex(BorderSize,1);
    else DrawWhiteBox(BorderSize, BorderSize);
    
    // Bottom left
    Canvas.SetPos(X,Y+H-BorderSize);
    if( BottomLeft )
        DrawCornerTex(BorderSize,2);
    else DrawWhiteBox(BorderSize, BorderSize);
    
    // Bottom right
    Canvas.SetPos(X+W-BorderSize,Y+H-BorderSize);
    if( BottomRight )
        DrawCornerTex(BorderSize,3);
    else DrawWhiteBox(BorderSize, BorderSize);
}

final function DrawRoundedBox( float BorderSize, float X, float Y, float W, float H, Color BoxColor )
{
    DrawRoundedBoxEx(BorderSize, X, Y, W, H, BoxColor, true, true, true, true);
}

final function DrawRoundedBoxEx( float BorderSize, float X, float Y, float W, float H, Color BoxColor, optional bool TopLeft, optional bool TopRight, optional bool BottomLeft, optional bool BottomRight )
{
    Canvas.DrawColor = BoxColor;

    if( BorderSize <= 0 )
    {
        Canvas.SetPos(X, Y);
        DrawWhiteBox(W, H);
        return;
    }
    
    Canvas.PreOptimizeDrawTiles(7, ItemTex);

    BorderSize = Min(FMin(BorderSize,(W)*0.5),(H)*0.5);

    Canvas.SetPos(X + BorderSize, Y);
    DrawWhiteBox(W - BorderSize * 2, H);
    
    Canvas.SetPos(X, Y + BorderSize);
    DrawWhiteBox(BorderSize, H - BorderSize * 2);
    
    Canvas.SetPos(X + W - BorderSize, Y + BorderSize);
    DrawWhiteBox(BorderSize, H - BorderSize * 2);

    DrawBoxCorners(BorderSize, X, Y, W, H, TopLeft, TopRight, BottomLeft, BottomRight);
}

final function DrawRoundedBoxHollow( float BorderSize, float X, float Y, float W, float H, Color BoxColor )
{
    DrawRoundedBoxHollowEx(BorderSize, X, Y, W, H, BoxColor, true, true, true, true);
}

final function DrawRoundedBoxHollowEx( float BorderSize, float X, float Y, float W, float H, Color BoxColor, optional bool TopLeft, optional bool TopRight, optional bool BottomLeft, optional bool BottomRight )
{
    Canvas.PreOptimizeDrawTiles(8, ItemTex);
    
    BorderSize = Min(FMin(BorderSize,(W)*0.5),(H)*0.5);

    Canvas.DrawColor = BoxColor;

    Canvas.SetPos(X + BorderSize, Y);
    DrawWhiteBox(W - BorderSize * 2, BorderSize);
    
    Canvas.SetPos(X + BorderSize, Y+H-BorderSize);
    DrawWhiteBox(W - BorderSize * 2, BorderSize);
    
    Canvas.SetPos(X, Y + BorderSize);
    DrawWhiteBox(BorderSize, H - BorderSize * 2);    
    
    Canvas.SetPos(X + W - BorderSize, Y + BorderSize);
    DrawWhiteBox(BorderSize, H - BorderSize * 2);

    DrawBoxCorners(BorderSize, X, Y, W, H, TopLeft, TopRight, BottomLeft, BottomRight);
}

final function DrawRoundedBoxOutlined( float BorderSize, float X, float Y, float Width, float Height, Color BoxColor, Color OutlineColor )
{
    Canvas.DrawColor = BoxColor;
    Canvas.SetPos(X + BorderSize, Y + BorderSize);
    DrawWhiteBox(Width - (BorderSize*2), Height - (BorderSize*2));
    
    DrawRoundedBoxHollow(BorderSize, X, Y, Width, Height, OutlineColor);
}

final function DrawRoundedBoxOutlinedEx( float BorderSize, float X, float Y, float Width, float Height, Color BoxColor, Color OutlineColor, optional bool TopLeft, optional bool TopRight, optional bool BottomLeft, optional bool BottomRight )
{
    Canvas.DrawColor = BoxColor;
    Canvas.SetPos(X + BorderSize, Y + BorderSize);
    DrawWhiteBox(Width - (BorderSize*2), Height - (BorderSize*2));
    
    DrawRoundedBoxHollowEx(BorderSize, X, Y, Width, Height, OutlineColor, TopLeft, TopRight, BottomLeft, BottomRight);
}

final function DrawArrowBox( int Direction, float X, float Y, float Width, float Height )
{
    local Texture2D DirectionMat;
    
    switch( Direction )
    {
        case 0:
            DirectionMat=ArrowTextures[`ARROW_UP];
            break;
        case 1:
            DirectionMat=ArrowTextures[`ARROW_RIGHT];
            break;
        case 2:
            DirectionMat=ArrowTextures[`ARROW_DOWN];
            break;
        case 3:
            DirectionMat=ArrowTextures[`ARROW_LEFT];
            break;
        default:
            DirectionMat=ArrowTextures[`ARROW_UP];
            break;
    }
    
    DrawTileStretched(ScrollTexture,X,Y,Width,Height);
    DrawTileStretched(DirectionMat,X,Y,Width,Height);
}

final function DrawTileStretched( Texture Tex, float X, float Y, float XS, float YS )
{
    local float mW,mH,MidX,MidY,SmallTileW,SmallTileH,fX,fY;
    local int OptimizeTiles;
 
    if( Tex==None ) Tex = Texture2D'EngineMaterials.DefaultDiffuse';
 
    // Get the size of the image
    mW = Tex.GetSurfaceWidth();
    mH = Tex.GetSurfaceHeight();
 
    // Get the midpoints of the image
    MidX = int(mW/2);
    MidY = int(mH/2);
 
    // Grab info about the scaled image
    SmallTileW = XS - mW;
    SmallTileH = YS - mH;
    
    // Optimized
    OptimizeTiles = 4;
    
    if( mW<XS )
        OptimizeTiles += 2;
    if( mH<YS )
        OptimizeTiles += 2;
    if( (mH<YS) && (mW<XS) )
        OptimizeTiles += 1;
        
    Canvas.PreOptimizeDrawTiles(OptimizeTiles, Tex);
 
    // Draw the spans first
    // Top and Bottom
    if (mW<XS)
    {
        fX = MidX;
 
        if (mH>YS)
            fY = YS/2;
        else
            fY = MidY;
 
        Canvas.SetPos(X+fX,Y);
        Canvas.DrawTile(Tex,SmallTileW,fY,MidX,0,1,fY);
        Canvas.SetPos(X+fX,Y+YS-fY);
        Canvas.DrawTile(Tex,SmallTileW,fY,MidX,mH-fY,1,fY);
    }
    else
        fX = XS / 2;
 
    // Left and Right
    if (mH<YS)
    {
        fY = MidY;
 
        Canvas.SetPos(X,Y+fY);
        Canvas.DrawTile(Tex,fX,SmallTileH,0,fY,fX,1);
        Canvas.SetPos(X+XS-fX,Y+fY);
        Canvas.DrawTile(Tex,fX,SmallTileH,mW-fX,fY,fX,1);
    }
    else
        fY = YS / 2;
 
    // Center
    if ( (mH<YS) && (mW<XS) )
    {
        Canvas.SetPos(X+fX,Y+fY);
        Canvas.DrawTile(Tex,SmallTileW,SmallTileH,fX,fY,1,1);
    }
 
    // Draw the 4 corners.
    Canvas.SetPos(X,Y);
    Canvas.DrawTile(Tex,fX,fY,0,0,fX,fY);
    Canvas.SetPos(X+XS-fX,Y);
    Canvas.DrawTile(Tex,fX,fY,mW-fX,0,fX,fY);
    Canvas.SetPos(X,Y+YS-fY);
    Canvas.DrawTile(Tex,fX,fY,0,mH-fY,fX,fY);
    Canvas.SetPos(X+XS-fX,Y+YS-fY);
    Canvas.DrawTile(Tex,fX,fY,mW-fX,mH-fY,fX,fY);
}

final function DrawTextJustified( byte Justification, float X1, float Y1, float X2, float Y2, coerce string S, optional float XS, optional float YS )
{
    local float XL, YL;
    local float CurY, CurX;
    
    Canvas.TextSize(S, XL, YL, XS, YS);
    
    CurY = ((Y2-Y1) / 2) - (YL/2);

    if( Justification == 0 )
    {
        CurX = 0;
    }
    else if( Justification == 1 )
    {
        if( XL > X2-X1 )
            CurX = 0;
        else CurX = ((X2-X1) / 2) - (XL/2);
    }
    else if( Justification == 2 )
    {
        CurX = (X2-X1) - XL;
    }

    Canvas.SetPos(CurX, CurY);
    Canvas.DrawText(S,,XS, YS);
}

static final function float TimeFraction( float Start, float End, float Current )
{
    return FClamp((Current - Start) / (End - Start), 0.f, 1.f);
}

static final function string LTrim(coerce string S)
{
    while (Left(S, 1) == " ")
        S = Right(S, Len(S) - 1);
    return S;
}

static final function string RTrim(coerce string S)
{
    while (Right(S, 1) == " ")
        S = Left(S, Len(S) - 1);
    return S;
}

static final function string Trim(coerce string S)
{
    return LTrim(RTrim(S));
}

defaultproperties
{
    MainFont=Font'KFClassicMode_Assets.Font.KFMainFont'
    NumberFont=Font'UI_Canvas_Fonts.Font_General'
    InfiniteFont=Font'KFClassicMode_Assets.Font.KFInfiniteFont'
}