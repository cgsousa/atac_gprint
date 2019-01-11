program ATAC_MPRINTER_000;

uses
  Forms,
  uadodb,
  uprinter in 'units\uprinter.pas',
  Form.Print00Log in 'forms\Form.Print00Log.pas' {frm_Print00Log},
  Form.Print00 in 'forms\Form.Print00.pas' {frm_Print00},
  Form.Print00List in 'forms\Form.Print00List.pas' {frm_Print00List},
  Form.PrinterPP00 in 'forms\Form.PrinterPP00.pas' {frm_PrinterPP00},
  Form.Etiqueta in 'forms\Form.Etiqueta.pas' {frm_ConfigEtq},
  Form.BaseEtqRL in 'forms\Form.BaseEtqRL.pas' {frm_BaseETQ};

{$R *.res}
{$R UAC.res}


begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  ConnectionADO :=NewADOConnFromIniFile('Configuracoes.ini') ;
  if ConnectionADO <> nil then
  begin
    try
      ConnectionADO.Connected :=True;
  Application.CreateForm(Tfrm_Print00Log, frm_Print00Log);
  Application.Run;

    except
      raise ;
    end;
  end
  else
    Application.MessageBox('Arquivo [Configuracoes.ini] inexistente!','Erro');
end.
