-define(BYTES , 1).

createframe(Title)->
	wxFrame:new(wx:null(),?wxID_ANY,Title).

setupframe(F)->
	MenuBar = wxMenuBar:new(),
	FileMenu=createfilemenu(),
	EditMenu=createeditmenu(),
	HelpMenu=createhelpmenu(),
	Additem = fun({X,Y})-> wxMenuBar:append(MenuBar,X,Y) end,
	Baritems=[	{FileMenu,"&File"},
						{EditMenu,"&Edit"},
						{HelpMenu,"&Help"}
					],
	wx:foreach( Additem, Baritems),

	TcOpt = [{style,?wxTE_MULTILINE }],
	Tc = wxTextCtrl:new(F,-1,TcOpt),
	Sz=wxGridSizer:new(0),
	SzOpt=[{flag,?wxALL bor ?wxEXPAND}],
	wxSizer:add(Sz,Tc,SzOpt),

	wxFrame:setMenuBar(F,MenuBar),
	wxFrame:setSizer(F,Sz),

	wxFrame:connect(F,close_window),
	wxFrame:connect(F,command_menu_selected),
	Tc.

createfilemenu()->
	FileMenu=wxMenu:new(),
	Additem = fun({Id,Label})-> wxMenu:append(FileMenu,Id,Label) end,
	Menuitems = [	{?wxID_NEW,"&New\tCTRL-N"},
							{?wxID_OPEN,"&Open\tCTRL-O"},
							{?wxID_SAVE,"&Save\tCTRL-S"},
							{?wxID_SAVEAS,"Save &As\tCTRL-SHIFT-S"},
							{?wxID_EXIT,"E&xit\tALT-F4"}
						],
	wx:foreach(Additem,Menuitems),
	FileMenu.

createeditmenu()->
	Editmenu=wxMenu:new(),
	Additem = fun({Id,Label})-> wxMenu:append(Editmenu,Id,Label) end,
	Menuitems = [	{?wxID_UNDO,"&Undo\tCTRL-Z"},
							{?wxID_REDO,"&Redo\tCTRL-Y"},
							{?wxID_CUT,"&Cut\tCTRL-X"},
							{?wxID_COPY,"C&opy\tCTRL-C"},
							{?wxID_PASTE,"&Paste\tCTRL-V"}
						],
	wx:foreach(Additem,Menuitems),
	Editmenu.

createhelpmenu()->
	Helpmenu=wxMenu:new(),
	wxMenu:append(Helpmenu,?wxID_ABOUT,"&About"),
	wxMenu:append(Helpmenu,?wxID_HELP,"&Help\tF1"),
	Helpmenu.	

savechanges(F,Tc)  ->
	case wxTextCtrl:isModified(Tc) of
		true->
			prompt_user_to_save_modified(F,Tc);
		_->
			green
	end.

prompt_user_to_save_modified(F,Tc)->
	Msg = "Do you want to save changes to current file?",
	case mboxYN(Msg) of
		?wxID_YES->
			mysave(F,Tc);
		_Any->
			green
	end.
	
myopenfile(F,Tc)->
	Style = ?wxFD_OPEN bor ?wxFD_CHANGE_DIR bor ?wxFD_FILE_MUST_EXIST ,
	Msg = "Open File",
	{Path , Name} =myfiledialog(Style,Msg),
	case Name of
		""->
			mbox("cancelled"),
			cancelled;
		_->
			try wxTextCtrl:loadFile(Tc,Path) of
				true->
					wxFrame:setLabel(F,Name);
				_Any->
					io:format("error 1 while opening file ......~p~n",[_Any])
			catch
				A:B->
					io:format("error 2 while opening file ......~p:~p~n",[A,B])
			end
	end.

mboxYN(Message)->
	mbox(wx:null(),Message,"Message",?wxYES_NO).
	
mbox(Message)->
	mbox(wx:null(),Message,"Message",?wxOK).

mbox(Frame,Message,Caption)->
	mbox(Frame,Message,Caption,?wxOK).

mbox(Frame,Msg,Caption,Style)->
	Dlg = wxMessageDialog:new(Frame,Msg,[{style,Style },{caption,Caption}]),
	case wxDialog:showModal(Dlg) of
		Any->
			ok
	end,
	wxDialog:destroy(Dlg),
	Any.

myfiledialog(Style,Msg)->
	Fd =wxFileDialog:new(wx:null(),[{style,Style},{wildCard,"*.txt"} , {message,Msg}]),
	wxFileDialog:showModal(Fd),
	Path = wxFileDialog:getPath(Fd),
	Name = wxFileDialog:getFilename(Fd),
	wxFileDialog:destroy(Fd),
	{Path , Name}.

	
