Class ClassicWebApp extends Object implements(IQueryHandler);

var WebAdmin webadmin;
var string ClassicWebURL;
var int EditPageIndex;
var ClassicWebAdmin_UI ClassicAdminUI;
var ClassicMode MyMutator;

function cleanup()
{
	webadmin = None;
	MyMutator = None;
	if( ClassicAdminUI!=None )
	{
		ClassicAdminUI.Cleanup();
		ClassicAdminUI = None;
	}
}
function init(WebAdmin webapp)
{
	webadmin = webapp;
}
function registerMenuItems(WebAdminMenu menu)
{
	menu.addMenu(ClassicWebURL, "Classic Mode", self, "Modify settings of Classic Mode.", -44);
}
function bool handleQuery(WebAdminQuery q)
{
	switch (q.request.URI)
	{
		case ClassicWebURL:
			handleClassicMod(q);
			return true;
	}
	return false;
}

final function IncludeFile( WebAdminQuery q, string file )
{
	local string S;
	
	if( webadmin.HTMLSubDirectory!="" )
	{
		S = webadmin.Path $ "/" $ webadmin.HTMLSubDirectory $ "/" $ file;
		if ( q.response.FileExists(S) )
		{
			q.response.IncludeUHTM(S);
			return;
		}
	}
	q.response.IncludeUHTM(webadmin.Path $ "/" $ file);
}
final function SendHeader( WebAdminQuery q, string Title )
{
	local IQueryHandler handler;
	
	q.response.Subst("page.title", Title);
	q.response.Subst("page.description", "");
	foreach webadmin.handlers(handler)
	{
		handler.decoratePage(q);
	}
	q.response.Subst("messages", webadmin.renderMessages(q));
	if (q.session.getString("privilege.log") != "")
	{
		q.response.Subst("privilege.log", webadmin.renderPrivilegeLog(q));
	}
	IncludeFile(q,"header.inc");
	q.response.SendText("<div id=\"content\"><h2>"$Title$"</h2></div><div class=\"section\">");
}
final function SendFooter( WebAdminQuery q )
{
	IncludeFile(q,"navigation.inc");
	IncludeFile(q,"footer.inc");
	q.response.ClearSubst();
}

final function AddConfigEditbox( WebAdminQuery q, string InfoStr, string CurVal, int MaxLen, string ResponseVar, string Tooltip, optional bool bSkipTrail )
{
	local string S;
	
	S = "<TR><TD><abbr title=\""$Tooltip$"\">"$InfoStr$":</abbr></TD><TD><input class=\"textbox\" class=\"text\" name=\""$ResponseVar$"\" value=\""$CurVal$"\"></TD>";
	if( !bSkipTrail )
		S $= "</TR>";
	q.response.SendText(S);
}
final function AddConfigCheckbox( WebAdminQuery q, string InfoStr, bool bCur, string ResponseVar, string Tooltip )
{
	local string S;
	
	S = bCur ? " checked" : "";
	S = "<TR><TD><abbr title=\""$Tooltip$"\">"$InfoStr$":</abbr></TD><TD><input type=\"checkbox\" name=\""$ResponseVar$"\" value=\"1\" "$S$"></TD></TR>";
	q.response.SendText(S);
}
final function AddConfigTextbox( WebAdminQuery q, string InfoStr, string CurVal, int Rows, string ResponseVar, string Tooltip )
{
	local string S;
	
	S = "<TR><TD><abbr title=\""$Tooltip$"\">"$InfoStr$":</abbr></TD><TD>";
	S $= "<textarea name=\""$ResponseVar$"\" rows=\""$Rows$"\" cols=\"80\">"$CurVal$"</textarea></TD></TR>";
	q.response.SendText(S);
}

function handleClassicMod(WebAdminQuery q)
{
	local int i,j,z;
	local string S;
	local delegate<ClassicWebAdmin_UI.OnGetValue> GetV;
	local delegate<ClassicWebAdmin_UI.OnSetValue> SetV;
	local bool bEditArray;

	if( ClassicAdminUI==None )
	{
		ClassicAdminUI = new (None) class'ClassicWebAdmin_UI';
		MyMutator.InitWebAdmin(ClassicAdminUI);
	}

	// First check if user is trying to get to another page.
	S = q.request.getVariable("GoToPage");
	if( S!="" )
	{
		if( S=="Main Menu" )
			EditPageIndex = -1;
		else EditPageIndex = ClassicAdminUI.ConfigList.Find('PageName',S);
	}

	if( EditPageIndex<0 || EditPageIndex>=ClassicAdminUI.ConfigList.Length )
	{
		// Show main links page.
		SendHeader(q,"Classic Server Links page");
		q.response.SendText("<table id=\"settings\" class=\"grid\"><thead><tr><th>Links</th></tr></thead><tbody>");
		for( i=0; i<ClassicAdminUI.ConfigList.Length; ++i )
			q.response.SendText("<tr><td><form action=\""$webadmin.Path$ClassicWebURL$"\"><input class=\"button\" name=\"GoToPage\" type=\"submit\" value=\""$ClassicAdminUI.ConfigList[i].PageName$"\"></form></td></tr>");
		q.response.SendText("</tbody></table></div></div></body></html>");
	}
	else
	{
		S = q.request.getVariable("edit"$EditPageIndex);
		bEditArray = false;
		if( S=="Submit" )
		{
			// Read setting values.
			for( i=0; i<ClassicAdminUI.ConfigList[EditPageIndex].Configs.Length; ++i )
			{
				S = q.request.getVariable("PR"$i,"#NULL");
				if( S!="#NULL" )
				{
					SetV = ClassicAdminUI.ConfigList[EditPageIndex].SetValue;
					SetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,0,S);
				}
				else if( ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropType==1 ) // Checkboxes return nothing if unchecked.
				{
					SetV = ClassicAdminUI.ConfigList[EditPageIndex].SetValue;
					SetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,0,"0");
				}
			}
		}
		else if( Left(S,5)=="Edit " )
		{
			i = ClassicAdminUI.ConfigList[EditPageIndex].Configs.Find('UIName',Mid(S,5));
			if( i!=-1 && ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].NumElements==-1 ) // Check if valid.
			{
				// Edit dynamic array.
				bEditArray = true;
			}
		}
		else if( Left(S,7)=="Submit " )
		{
			i = ClassicAdminUI.ConfigList[EditPageIndex].Configs.Find('UIName',Mid(S,7));
			if( i!=-1 && ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].NumElements==-1 ) // Check if valid.
			{
				// Submitted dynamic array values.
				GetV = ClassicAdminUI.ConfigList[EditPageIndex].GetValue;
				SetV = ClassicAdminUI.ConfigList[EditPageIndex].SetValue;
				z = int(GetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,-1));
				
				for( j=z; j>=0; --j )
				{
					if( q.request.getVariable("DEL"$j)=="1" )
						SetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,j,"#DELETE");
					else
					{
						S = q.request.getVariable("PR"$j,"New Line");
						if( S!="New Line" )
							SetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,j,S);
					}
				}
			}
		}

		// Show settings page
		SendHeader(q,ClassicAdminUI.ConfigList[EditPageIndex].PageName$" ("$PathName(ClassicAdminUI.ConfigList[EditPageIndex].ObjClass)$")");
		q.response.SendText("<form method=\"post\" action=\""$webadmin.Path$ClassicWebURL$"\"><table id=\"settings\" class=\"grid\">");

		if( bEditArray )
		{
			q.response.SendText("<table id=\"settings\" class=\"grid\"><thead><tr><th><abbr title=\""$ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIDesc$"\">Edit Array "$ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIName$"</abbr></th><th></th><th>Delete Line</th></tr></thead><tbody>");
			
			GetV = ClassicAdminUI.ConfigList[EditPageIndex].GetValue;
			z = int(GetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,-1));

			for( j=0; j<=z; ++j )
			{
				if( j<z )
					S = GetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,j);
				else S = "New Line";
				switch( ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropType )
				{
				case 0: // int
					AddConfigEditbox(q,"["$j$"]",S,8,"PR"$j,"",true);
					if( j<z )
						q.response.SendText("<TD><input type=\"checkbox\" name=\"DEL"$j$"\" value=\"1\" "$S$"></TD></TR>");
					else q.response.SendText("<TD></TD></TR>");
					break;
				case 2: // string
					AddConfigEditbox(q,"["$j$"]",S,80,"PR"$j,"",true);
					if( j<z )
						q.response.SendText("<TD><input type=\"checkbox\" name=\"DEL"$j$"\" value=\"1\" "$S$"></TD></TR>");
					else q.response.SendText("<TD></TD></TR>");
					break;
				}
			}
			
			q.response.SendText("<tr><td></td><td><input class=\"button\" type=\"submit\" name=\"edit"$EditPageIndex$"\" value=\"Submit "$ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIName$"\"></td></tr></form>");
		}
		else
		{
			q.response.SendText("<table id=\"settings\" class=\"grid\"><thead><tr><th>Settings</th></tr></thead><tbody>");
			for( i=0; i<ClassicAdminUI.ConfigList[EditPageIndex].Configs.Length; ++i )
			{
				if( ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].NumElements==-1 ) // Dynamic array.
				{
					GetV = ClassicAdminUI.ConfigList[EditPageIndex].GetValue;
					j = int(GetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,-1));
					q.response.SendText("<TR><TD><abbr title=\""$ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIDesc$"\">"$ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIName$"["$j$"]:</abbr></TD><TD><input class=\"button\" type=\"submit\" name=\"edit"$EditPageIndex$"\" value=\"Edit "$ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIName$"\"></TD></TR>");
				}
				else
				{
					GetV = ClassicAdminUI.ConfigList[EditPageIndex].GetValue;
					S = GetV(ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropName,0);
					switch( ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].PropType )
					{
					case 0: // Int
						AddConfigEditbox(q,ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIName,S,8,"PR"$i,ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIDesc);
						break;
					case 1: // Bool
						AddConfigCheckbox(q,ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIName,bool(S),"PR"$i,ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIDesc);
						break;
					case 2: // String
						AddConfigEditbox(q,ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIName,S,80,"PR"$i,ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIDesc);
						break;
					case 3: // Text field
						AddConfigTextbox(q,ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIName,S,25,"PR"$i,ClassicAdminUI.ConfigList[EditPageIndex].Configs[i].UIDesc);
						break;
					}
				}
			}
			
			// Submit button
			q.response.SendText("<tr><td></td><td><input class=\"button\" type=\"submit\" name=\"edit"$EditPageIndex$"\" value=\"Submit\"></td></tr></form>");
		}

		// Return to main menu button.
		q.response.SendText("<tr><td><form action=\""$webadmin.Path$ClassicWebURL$"\"><input class=\"button\" name=\"GoToPage\" type=\"submit\" value=\"Main Menu\"></form></td></tr>");
		q.response.SendText("</tbody></table></div></div></body></html>");
	}
	SendFooter(q);
}

function bool producesXhtml()
{
	return true;
}
function bool unhandledQuery(WebAdminQuery q);
function decoratePage(WebAdminQuery q);

defaultproperties
{
	ClassicWebURL="/settings/ClassicServerMod"
	EditPageIndex=-1
}