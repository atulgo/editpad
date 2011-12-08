-module(editpad).
-compile(export_all).
-include_lib("wx/include/wx.hrl").
-include_lib("editpad.hrl").

start()->
	register(?MODULE,spawn(?MODULE,mystart,[ok])),
	ok.

mystart(_)->
	wx:new(),
	F=createframe("untitled.txt"),
	Tc =wx:batch(fun()->setupframe(F) end),
	wxFrame:show(F),
	loop(F,Tc).

loop(F,Tc)->
	receive
		#wx{obj=F,event=#wxClose{}}->				
			myexit(F,Tc);
		#wx{ id=ID,obj=F,event=#wxCommand{type=command_menu_selected}}->
			case ID of
				?wxID_EXIT->
					myexit(F,Tc);
				?wxID_ABOUT->
					myabout(F);
				?wxID_HELP->
					myhelp(F);
				?wxID_NEW->
					mynew(F,Tc);
				?wxID_OPEN->
					myopen(F,Tc);
				?wxID_SAVE->
					mysave(F,Tc);
				?wxID_SAVEAS->
					mysave_as(F,Tc);
				?wxID_UNDO->
					wxTextCtrl:undo(Tc);
				?wxID_REDO->
					wxTextCtrl:redo(Tc);
				?wxID_CUT->
					wxTextCtrl:cut(Tc);
				?wxID_COPY->
					wxTextCtrl:copy(Tc);
				?wxID_PASTE->
					wxTextCtrl:paste(Tc)
				
			end;
		_Any->
			ok
	end,
	loop(F,Tc).

mynew(F,Tc)->
	case savechanges(F,Tc) of
		green->
			wxTextCtrl:clear(Tc),
			wxFrame:setLabel(F,"untitled.txt");
		cancelled->
			ok
	end.

myopen(F,Tc)->
	case savechanges(F,Tc) of
		green->
			wxTextCtrl:clear(Tc),
			myopenfile(F,Tc);
		_->
			ok
	end.
	
mysave(F,Tc)	->
	case wxWindow:getLabel(F) of
		"untitled.txt"->
			mysave_as(F,Tc);
		Name->
			case wxTextCtrl:saveFile(Tc,[{file,Name }]) of
				true->
					mbox("saved...."++Name);
				_->
					mbox("cant save...."++Name)
			end,
			green
	end.

mysave_as(F,Tc)->
	Style = ?wxFD_SAVE bor ?wxFD_CHANGE_DIR bor ?wxFD_OVERWRITE_PROMPT ,
	Msg = "Save File As",
	{Path ,Name }= myfiledialog(Style,Msg),
	case Name of
		""->
			mbox("cancelled"),
			cancelled;
		_->
			case wxTextCtrl:saveFile(Tc,[{file,Path }]) of
				true->
					wxFrame:setLabel(F,Name),
					mbox("the file will be saved as "++Name);
				_->
					mbox("cant save...."++Name)
			end,
			green
	end.

myabout(F)->
	mbox(F,"Editor simple text editor created in wxERLANG by Atul","About Editor").

myhelp(F)->
	mbox(F,"This is all help u got !!!","Help").
	
myexit(F,Tc)->
	case savechanges(F,Tc) of
		green->
			wxWindow:destroy(F),
			wx:destroy(),
			exit(normal);
		_->
			cancelled
	end.

