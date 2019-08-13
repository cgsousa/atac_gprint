unit Form.LogView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, JvExStdCtrls, JvRichEdit,
  FormBase;

type
//  ILogView = interface
//    ['{D539227E-7062-4713-8F39-4A0223FB6177}']
//    procedure Show ;
//  end;
  Tfrm_LogView = class(TBaseForm)
    txt_Log: TJvRichEdit;
  private
    { Private declarations }
  protected
    procedure Loaded; override;
  public
    { Public declarations }
    procedure OnUpdateStr(const aStr: string) ;
  end;


implementation

{$R *.dfm}

{ Tfrm_LogView }

procedure Tfrm_LogView.Loaded;
begin
    DefaultMonitor :=dmDesktop;
	  Position  :=poScreenCenter;
end;

procedure Tfrm_LogView.OnUpdateStr(const aStr: string);
begin
    if Pos('Erro', aStr) > 0 then
    begin
        txt_Log.AddFormatText(aStr, [fsBold,fsItalic], 'Arial', clRed) ;
        txt_Log.AddFormatText(#13#10, []) ;
    end
    else
        txt_Log.Lines.Add(aStr);
    txt_Log.SelLength := 0;
    txt_Log.SelStart:=txt_Log.GetTextLen; //mmo_Log.Perform(EM_LINEINDEX, mmo_Log.Lines.Count -1, 0);
    txt_Log.Perform( EM_SCROLLCARET, 0, 0 ); {::garantir a exibição é correto}
end;

end.
