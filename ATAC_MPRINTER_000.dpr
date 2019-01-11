program ATAC_MPRINTER_000;

uses
  Forms,
  uadodb,
  uprinter in 'units\uprinter.pas',
  Form.Print00Log in 'view\configuracoes\Form.Print00Log.pas' {frm_Print00Log},
  Form.Print00 in 'view\configuracoes\Form.Print00.pas' {frm_Print00},
  Form.Print00List in 'view\configuracoes\Form.Print00List.pas' {frm_Print00List},
  Form.PrinterPP00 in 'view\configuracoes\Form.PrinterPP00.pas' {frm_PrinterPP00},
  Form.Etiqueta in 'view\configuracoes\Form.Etiqueta.pas' {frm_ConfigEtq},
  Form.BaseEtqRL in 'view\configuracoes\Form.BaseEtqRL.pas' {frm_BaseETQ};

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
