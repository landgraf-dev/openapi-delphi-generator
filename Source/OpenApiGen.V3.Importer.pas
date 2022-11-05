unit OpenApiGen.V3.Importer;

interface

uses
  System.SysUtils, System.IOUtils,
  OpenApi.V3.Document, OpenApi.V3.Json.Serializer, OpenApiGen.Builder, OpenApiGen.Options;

procedure GenerateSourceV3(const Content: string; Options: TBuilderOptions; GenOptions: TGeneratorOptions);

implementation

uses
  Bcl.Code.MetaClasses,
  Bcl.Code.DelphiGenerator;

procedure GenerateSource(Importer: TOpenApiImporter; const OutputFolder: string);
var
  Generator: TDelphiCodeGenerator;
  Source: string;
  FileName: string;
  CodeUnit: TCodeUnit;
  FullOutputFolder: string;
begin
  FullOutputFolder := TPath.GetFullPath(OutputFolder);
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

procedure GenerateSourceV3(const Content: string; Options: TBuilderOptions; GenOptions: TGeneratorOptions);
var
  Document: TOpenApiDocument;
  Importer: TOpenApiImporter;
begin
  Importer := TOpenApiImporter.Create(Options);
  try
    Document := TOpenApiDeserializer.JsonToDocument(Content);
    try
//      Importer.Build(Document);
//      GenerateSource(Importer, GenOptions.OutputFolder);
    finally
      Document.Free;
    end;
  finally
    Importer.Free;
  end;
end;

end.

