// Interface class for outputting stats into a file or something.
Interface KFStatWriter;

function WriteValue( string Key, string Value );
function StartIntendent( string Section, optional string Key, optional string Value );
function EndIntendent();
function ResetFile();
