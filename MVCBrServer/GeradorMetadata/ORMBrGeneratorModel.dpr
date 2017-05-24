program ORMBrGeneratorModel;

uses
  Forms,
  MVCBr.ApplicationController,
  Frm_Principal in 'Frm_Principal.pas' {FrmPrincipal},
  Frm_Connection in 'Frm_Connection.pas' {FrmConnection},
  GeradorMetadata.Controller.Interf in 'Controllers\GeradorMetadata.Controller.Interf.pas',
  GeradorMetadata.Controller in 'Controllers\GeradorMetadata.Controller.pas',
  GeradorMetadataConnection.Controller.Interf in 'Controllers\GeradorMetadataConnection.Controller.Interf.pas',
  GeradorMetadataConnection.Controller in 'Controllers\GeradorMetadataConnection.Controller.pas';

{$R *.res}

begin
  // Application.Initialize;
  // Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  // Application.Run;

  ApplicationController.run( TGeradorMetadataController.New  ,
    function: boolean
    begin
       result := true;
    end);

end.
