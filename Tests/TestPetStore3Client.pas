unit TestPetStore3Client;

interface

uses
  SysUtils, TestFramework, PetStore3Client, PetStore3Dtos, OpenApiRest;

type
  TPetStore3ClientTests = class(TTestCase)
  published
    procedure CreateAndGetPet;
  end;

implementation

{ TPetStore3ClientTests }

procedure TPetStore3ClientTests.CreateAndGetPet;
const
  PetId = 61341;
  CategoryId = 61341;
  TagId = 61341;
var
  Pet: TPet;
  Tag: TTag;
  Client: IPetStore3Client;
begin
  Client := TPetStore3Client.Create;

  // Create the pet
  Pet := TPet.Create;
  try
    Pet.Id := PetId;
    Pet.Name := 'Josephine';
    Pet.Status := 'available';

    Pet.Category := TCategory.Create;
    Pet.Category.Id := CategoryId;
    Pet.Category.Name := 'Terrier Dogs';

    Pet.Tags := TTagList.Create;
    Tag := TTag.Create;
    Tag.Id := TagId;
    Tag.Name := 'Terrier';
    Pet.Tags.Add(Tag);

    Pet.PhotoUrls.Add('http://dummy.com/dog.png');
    Client.Pet.AddPet(Pet);
  finally
    Pet.Free;
  end;

  // Now pet should exist
  Pet := Client.Pet.GetPetById(PetId);
  try
    Check(Pet <> nil, Format('Pet %d not found', [PetId]));
    CheckEquals(PetId, Pet.Id);
    CheckEquals('Josephine', Pet.Name);
    CheckEquals('available', Pet.Status);

    Check(Pet.Category <> nil, 'Category is nil');
    CheckEquals(CategoryId, Pet.Category.Id);
    CheckEquals('Terrier Dogs', Pet.Category.Name);

    Check(Pet.Tags <> nil, 'Tags is nil');
    CheckEquals(1, Pet.Tags.Count);
    CheckEquals(TagId, Pet.Tags[0].Id);
    Checkequals('Terrier', Pet.Tags[0].Name);

    CheckEquals(1, Pet.PhotoUrls.Count);
    CheckEquals('http://dummy.com/dog.png', Pet.PhotoUrls[0]);
  finally
    Pet.Free;
  end;

  // Delete the newly created pet
  Client.Pet.DeletePet('special-key', PetId);

  // Make sure pet does not exist anymore
  try
    Pet := Client.Pet.GetPetById(PetId);
    Pet.Free;
    Check(False, 'Exception not raised');
  except
    on E: EOpenApiClientException do
      CheckEquals(404, E.Response.StatusCode);
  end;
end;

initialization
  RegisterTest(TPetStore3ClientTests.Suite);

end.
