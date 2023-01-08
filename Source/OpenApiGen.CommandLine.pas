unit OpenApiGen.CommandLine;

interface

uses
  System.SysUtils, System.IOUtils, System.Rtti, VSoft.CommandLine.Options,
  Bcl.Json.Converters,
  Bcl.Json.Deserializer,
  OpenApiGen.Options;

function ParseCommandLine(GenOptions: TGeneratorOptions; Options: TBuilderOptions): Boolean;

implementation

procedure ConfigureOptions(GenOptions: TGeneratorOptions; Options: TBuilderOptions);
var
  option : IOptionDefinition;
begin
  option := TOptionsRegistry.RegisterOption<string>('input', 'i', 'OpenApi document to import',
    procedure(const Value: string)
    begin
      GenOptions.InputDocument := Value;
    end);
  option.Required := true;

  option := TOptionsRegistry.RegisterOption<string>('output', 'o', 'Output folder for client files',
    procedure(const Value: string)
    begin
      GenOptions.OutputFolder := Value;
    end);
  option.Required := true;

  option := TOptionsRegistry.RegisterOption<string>('name', 'n', 'Client name used for output files',
    procedure(const Value: string)
    begin
      Options.ClientName := Value;
    end);

  option := TOptionsRegistry.RegisterOption<string>('url', 'u', 'Default URL of the OpenApi document',
    procedure(const Value: string)
    begin
      Options.DocumentUrl := Value;
    end);

  option := TOptionsRegistry.RegisterOption<TServiceSolvingMode>('mode', 'm',
    'Options: SingleClientFromOperationId, MultipleClientsFromFirstTagAndOperationId',
    procedure(const Value: TServiceSolvingMode)
    begin
      Options.ServiceOptions.SolvingMode := Value;
    end);

  option := TOptionsRegistry.RegisterOption<string>('config', 'c',
    'File containing configuration in JSON format',
    procedure(const Value: string)
    var
      Json: string;
      OptionsValue: TValue;
      Deserializer: TJsonDeserializer;
    begin
      Json := TFile.ReadAllText(Value);
      OptionsValue := Options;
      Deserializer := TJsonDeserializer.Create;
      try
        Deserializer.Converters.ObjectConverterFactory.UnknownMemberHandling := TUnknownMemberHandling.Error;
        Deserializer.Read(Json, OptionsValue, TBuilderOptions);
      finally
        Deserializer.Free;
      end;
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
