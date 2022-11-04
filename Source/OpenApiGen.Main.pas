unit OpenApiGen.Main;

interface

uses
  System.SysUtils, System.StrUtils, System.IOUtils,
  OpenApi.Document, OpenApiGen.Builder, OpenApiGen.Options, OpenApiGen.CommandLine;

procedure Run;

implementation

uses
  System.Net.HttpClient,
  OpenApiGen.V2.Importer;

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
    Result := TFile.ReadAllText(Source, TEncoding.UTF8);
end;

procedure Run;
var
  GenOptions: TGeneratorOptions;
  Options: TBuilderOptions;
  Content: string;
begin
  WriteHeader;
  GenOptions := TGeneratorOptions.Create;
  try
    Options := TBuilderOptions.Create;
    try
      if ParseCommandLine(GenOptions, Options) then
      begin
        Content := LoadContent(GenOptions.InputDocument);
        GenerateSourceV2(Content, Options, GenOptions);
      end;
    finally
      Options.Free;
    end;
  finally
    GenOptions.Free;
  end;
end;

end.
