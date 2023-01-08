unit OpenApiGen.Main;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes, System.IOUtils,
  OpenApi.Document, OpenApiGen.Builder, OpenApiGen.Options, OpenApiGen.CommandLine;

procedure Run;

implementation

uses
  System.Net.HttpClient,
  Bcl.Json.Reader,
  Sparkle.Uri,
  OpenApiGen.V2.Importer,
  OpenApiGen.V3.Importer;

type
  TOpenApiVersion = (Swagger20, OpenApi30);

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

function LoadContent(const Source: string; Options: TBuilderOptions): string;
var
  Uri: IUri;
begin
  if StartsText('http://', Source) or StartsText('https://', Source) then
  begin
    Result := LoadHttpContent(Source);
    Uri := TUri.Create(Source);
    if Options.DocumentUrl = '' then
      Options.DocumentUrl := Uri.Scheme + '://' + Uri.Authority;
  end
  else
    Result := TFile.ReadAllText(Source, TEncoding.UTF8);
end;

function GetOpenApiVersion(const Content: string): TOpenApiVersion;
var
  Stream: TStream;
  Reader: TJsonReader;
  Version: string;
  Prop: string;
begin
  try
    Stream := TStringStream.Create(Content, TEncoding.UTF8, False);
    try
      Reader := TJsonReader.Create(Stream);
      try
        Reader.ReadBeginObject;
        Version := '';
        while Reader.HasNext do
        begin
          Prop := Reader.ReadName;
          if (Prop = 'swagger') and StartsStr('2.0', Reader.ReadString) then
            Exit(Swagger20);
          if (Prop = 'openapi') and StartsStr('3.0', Reader.ReadString) then
            Exit(OpenApi30);
          Reader.SkipValue;
        end;
        raise Exception.Create('Version property not found');
      finally
        Reader.Free;
      end;
    finally
      Stream.Free;
    end;
  except
    on E: Exception do
      raise Exception.CreateFmt('Cannot retrieve OpenApi version - %s (%s)', [E.Message, E.ClassName]);
  end;
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
        Content := LoadContent(GenOptions.InputDocument, Options);
        case GetOpenApiVersion(Content) of
          Swagger20: GenerateSourceV2(Content, Options, GenOptions);
          OpenApi30: GenerateSourceV3(Content, Options, GenOptions);
        else
          raise Exception.Create('Unsupported OpenAPI version');
        end;
      end;
    finally
      Options.Free;
    end;
  finally
    GenOptions.Free;
  end;
end;

end.
