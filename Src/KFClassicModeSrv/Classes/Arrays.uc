class Arrays extends Object;

static function UniqueInsert(out array<string> List, string Key) 
{
    local int Low, High, Mid;

    if (List.Length == 0) 
    {
        List.AddItem(Key);
        return;
    }

    Low = 0;
    High = List.Length - 1;
    Mid = -1;

    while(Low <= High) 
    {
        Mid = (Low+High)/2;
        if( List[Mid] < Key ) 
        {
            Low = Mid + 1;
        } 
        else if( List[Mid] > Key ) 
        {
            High = Mid - 1;
        }
        else break;
    }
    
    if( Low > High ) 
    {
        List.InsertItem(Low, Key);
    }
}