unit OpenApiGen.CommandLine;

interface

uses
  VSoft.CommandLine.Options,
  OpenApiGen.Options;

function ParseCommandLine(GenOptions: TGeneratorOptions; Options: TBuilderOptions): Boolean;

implementation

procedure ConfigureOptions(GenOptions: TGeneratorOptions; Options: TBuilderOptions);
var
  option : IOptionDefinition;
begin
  option := TOptionsRegistry.RegisterOption<string>('input', 'i', 'OpenApi document to import',
    procedure(const Value : string)
    begin
      GenOptions.InputDocument := Value;
    end);
  option.Required := true;

  option := TOptionsRegistry.RegisterOption<string>('output', 'o', 'Output folder for client files',
    procedure(const Value : string)
    begin
      GenOptions.OutputFolder := Value;
    end);
  option.Required := true;

  option := TOptionsRegistry.RegisterOption<string>('name', 'n', 'Client name used for output files',
    procedure(const Value : string)
    begin
      Options.ClientName := Value;
    end);
end;

function ParseCommandLine(GenOptions: TGeneratorOptions; Options: TBuilderOptions): Boolean;
var
  ParserResult: ICommandLineParseResult;
begin
  ConfigureOptions(GenOptions, Options);
  ParserResult := TOptionsRegistry.Parse;
  Result := not ParserResult.HasErrors;
  if not Result then
  begin
    Writeln('Invalid command line :');
    Writeln(ParserResult.ErrorText);
    TOptionsRegistry.DescriptionTab := 35;
    TOptionsRegistry.PrintUsage(
      procedure(const Value : string)
      begin
        Writeln(Value);
      end);
  end;
end;


end.
