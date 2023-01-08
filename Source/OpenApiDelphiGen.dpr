program OpenApiDelphiGen;

{$APPTYPE CONSOLE}

{$R 'version.res' 'version.rc'}
{$R *.res}

uses
  System.SysUtils,
  OpenApiGen.Metadata in 'OpenApiGen.Metadata.pas',
  OpenApiGen.Builder in 'OpenApiGen.Builder.pas',
  OpenApiGen.Main in 'OpenApiGen.Main.pas',
  OpenApiGen.Options in 'OpenApiGen.Options.pas',
  OpenApiGen.CommandLine in 'OpenApiGen.CommandLine.pas',
  OpenApiGen.V2.Importer in 'OpenApiGen.V2.Importer.pas',
  OpenApiGen.V3.Importer in 'OpenApiGen.V3.Importer.pas',
  OpenApiGen.V2.Analyzer in 'OpenApiGen.V2.Analyzer.pas',
  OpenApiGen.CustomAnalyzer in 'OpenApiGen.CustomAnalyzer.pas',
  OpenApiGen.V3.Analyzer in 'OpenApiGen.V3.Analyzer.pas';

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  try
    Run;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;

{$IFDEF DEBUG}
{$IFDEF MSWINDOWS}
{$WARNINGS OFF}
  if (DebugHook <> 0) then ReadLn;
{$WARNINGS ON}
{$ENDIF}
{$ENDIF}

end.
