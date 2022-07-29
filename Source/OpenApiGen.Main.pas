unit OpenApiGen.Main;

interface

uses
  System.SysUtils, System.StrUtils, System.IOUtils,
  OpenApi.Document, OpenApi.Json.Serializer, OpenApiGen.Builder, OpenApiGen.Options, OpenApiGen.CommandLine;

procedure Run;

implementation

uses
  System.Net.HttpClient,
  Bcl.Code.MetaClasses,
  Bcl.Code.DelphiGenerator;

function ProductVersion: string;
var
  Major, Minor, Build: Cardinal;
begin
  if GetProductVersion(ParamStr(0), Major, Minor, Build) then
    Result := Major.ToString + '.' + Minor.ToString + '.' + Build.ToString
  else
    Result := '(unknown)';
end;

procedure WriteHeader;
begin
  WriteLn(Format('OpenApi Client Generator for Delphi version %s', [ProductVersion]));
  WriteLn('Copyright (c) Landgraf.dev - all rights reserved.');
  WriteLn('');
end;

function LoadHttpContent(Source: string): string;
var
  HttpClient: THttpClient;
  HttpResponse: IHttpResponse;
begin
  HttpClient := THTTPClient.Create;
  try
    HttpResponse := HttpClient.Get(Source);
    if HttpResponse.StatusCode <> 200 then
      raise Exception.CreateFmt('Could not load content from URL %s', [Source]);
    Result := HttpResponse.ContentAsString();
  finally
    HttpClient.Free;
  end;
end;

function LoadContent(const Source: string): string;
begin
  if StartsText('http://', Source) or StartsText('https://', Source) then
    Result := LoadHttpContent(Source)
  else
    Result := TFile.ReadAllText(Source);
end;

procedure GenerateSource(Importer: TOpenApiImporter; const OutputFolder: string);
var
  Generator: TDelphiCodeGenerator;
  Source: string;
  FileName: string;
  CodeUnit: TCodeUnit;
  FullOutputFolder: string;
begin
  FullOutputFolder := TPath.GetFullPath(OutputFolder);
//  ForceDirectories(FullOutputFolder);
  Generator := TDelphiCodeGenerator.Create;
  try
    Generator.StructureStatements := True;
    Generator.ReservedWordMode := TReservedWordMode.Ignore;
    for CodeUnit in Importer.CodeUnits do
    begin
      Source := Generator.GenerateCodeFromUnit(CodeUnit);
      FileName := TPath.ChangeExtension(CodeUnit.Name, '.pas');
      FileName := TPath.Combine(OutputFolder, FileName);
      TFile.WriteAllText(FileName, Source);
    end;

    WriteLn(Format('Files generated succesfully in folder %s.', [FullOutputFolder]));
  finally
    Generator.Free;
  end;
end;

procedure Run;
var
  GenOptions: TGeneratorOptions;
  Document: TOpenApiDocument;
  Importer: TOpenApiImporter;
begin
  WriteHeader;
  GenOptions := TGeneratorOptions.Create;
  try
    Importer := TOpenApiImporter.Create;
    try
      if ParseCommandLine(GenOptions, Importer.Options) then
      begin
        Document := TOpenApiDeserializer.JsonToDocument(LoadContent(GenOptions.InputDocument));
        try
          Importer.Build(Document);
          GenerateSource(Importer, GenOptions.OutputFolder);
        finally
          Document.Free;
        end;
      end;
    finally
      Importer.Free;
    end;
  finally
    GenOptions.Free;
  end;
end;

end.
