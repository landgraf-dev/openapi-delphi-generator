program OpenApiDelphiGenTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  TestPetStoreClient in 'TestPetStoreClient.pas',
  OpenApiJson in '..\Dist\OpenApiJson.pas',
  OpenApiRest in '..\Dist\OpenApiRest.pas',
  OpenApiHttp in '..\Dist\OpenApiHttp.pas',
  PetStoreDtos in 'PetStore\PetStoreDtos.pas',
  PetStoreJson in 'PetStore\PetStoreJson.pas',
  PetStoreClient in 'PetStore\PetStoreClient.pas',
  NuvemFiscalJson in 'S:\nuvem-fiscal\nuvemfiscal-sdk-delphi\Source\NuvemFiscalJson.pas',
  NuvemFiscalClient in 'S:\nuvem-fiscal\nuvemfiscal-sdk-delphi\Source\NuvemFiscalClient.pas',
  NuvemFiscalDtos in 'S:\nuvem-fiscal\nuvemfiscal-sdk-delphi\Source\NuvemFiscalDtos.pas',
  OpenApiUtils in '..\Dist\OpenApiUtils.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

