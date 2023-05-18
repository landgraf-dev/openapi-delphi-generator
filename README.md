# OpenAPI Client Generator for Delphi

Generate Delphi client SDKs for any REST API defined with the OpenAPI specification. 

This generator can read an OpenAPI document (from local file or URL) of a REST API and generate Delphi classes that you can use to invoke such REST API endpoints in a friendly way.

The generator creates the DTO classes (representing the JSON definitions used by the API) and the interfaces with methods you can call (representing the endpoints to invoke).

## Usage

[Download the binaries](https://github.com/landgraf-dev/openapi-delphi-generator/releases) and decompress in a folder in your disk. The generator is a single command-line exe file named `OpenApiDelphiGen.exe`. Execute it passing the proper command-line parameters. The tool provides a help file showing you all the available options.

### Generating the client

The following example generates client files for the popular [Swagger PetStore](https://petstore.swagger.io) example API.

```shell
OpenApiDelphiGen -i:"https://petstore.swagger.io/v2/swagger.json" -o:"C:\PetStore" -n:PetStore -m:MultipleClientsFromFirstTagAndOperationId
```

The `-i` parameter indicates the OpenAPI document to import. The `-o` parameter provides the output folder where the Delphi files should be generated. The `-n` parameter is the name of the API, used to prefix unit and class names. Finally, `-m` parameter indicates how the service classes and interfaces should be organized.

The generator will create the following units:

<img width="408" alt="image" src="https://user-images.githubusercontent.com/10242580/181278336-6ec72270-ee32-416b-bb69-8e90b88e5b07.png">

`PetStoreClient` is the main unit with the service classes and interfaces. `PetStoreDTOs` contains all the DTO classes, and `PetStoreJson` holds code for serializing/deserializing DTOs to and from JSON.

### Using the client

To use the client, just add the generated units to your uses classes. Instantiate the client and use its methods. Note that the generated code depends on the units provided in the [Dist](Dist) folder, so you must also add them to your project.

Once you instantiate the client, just call a method from a service to invoke an endpoint. The following example will create a new pet in the server by invoking the `POST /Pets`  endpoint:

```delphi
uses {...}, PetStoreClient, PetStoreDtos;

procedure TPetStoreClientTests.CreateAndGetPet;
const
  PetId = 61341;
  CategoryId = 61341;
  TagId = 61341;
var
  Pet: TPet;
  Tag: TTag;
  Client: IPetStoreClient;
begin
  Client := TPetStoreClient.Create;

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
```

Another example that will retrieve and then delete a pet:

```delphi
  Client := TPetStoreClient.Create;
  Pet := Client.Pet.GetPetById(PetId);
  try
    Check(Pet <> nil, Format('Pet %d not found', [PetId]));
    CheckEquals(PetId, Pet.Id);
    CheckEquals('Josephine', Pet.Name);
    CheckEquals('available', Pet.Status);
  finally
    Pet.Free;
  end;

  // Delete the newly created pet
  Client.Pet.DeletePet('special-key', PetId);
```

You must create and destroy all DTO classes yourself. The classes and lists owned by the DTO classes are destroyed automatically.

### Authentication

You can set the `Config.AccessToken` property to authenticate with the API:

```delphi
Client.Config.AccessToken := '<access token>';
```

It will set the `Authorization` HTTP header with the token value prefixed by `Bearer `.

### Client compatibility

Current the generated code doesn't require any dependency on 3rd party units, working with a plain Delphi install. The code is currently using `THttpClient` class from unit `System.Net.HttpClient` to perform the HTTP requests, so the client will only compile on Delphi versions that provide such class.

Alternatively, you can force the client to use Indy components to perform HTTP requests. For that, can use the following code snippet.

```delphi
uses {...}, OpenApiRest, OpenApiIndy;

begin
  // At the beginning of your application, set the DefaultRequestFactory
  DefaultRequestFactory := TIndyRestRequestFactory.Create;
end;
```

You can intercept the moment where a new `TIdHTTP` client is created - in case you want to setup specific properties like proxy or IO handlers. For that you can use a code like this:

```delphi
uses {...}, OpenApiRest, OpenApiIndy, IdHTTP;

procedure TMainDataModule.IndyClientCreated(Client: TIdHTTP);
begin
  // Set extra Client properties here
end;

procedure TMainDataModule.DataModuleCreate(Sender: TObject);
var
  Factory: TIndyRestRequestFactory;
begin
  // At the beginning of your application, set the DefaultRequestFactory
  Factory := TIndyRestRequestFactory.Create;
  DefaultRequestFactory := Factory;
  Factory.OnClientCreated := IndyClientCreated;
end;
```

## Compiling and running tests

You can compile and run the test project also without any dependencies. The tests were created using DUnit for maximum compatibility with several Delphi versions. 

## Compiling the generator tool

The generator tool itself uses 3rd party libraries. You don't need them to use it, you can simply download the executable and use it directly. In case you want to compile and debug the tool, you will need the following libraries:

* [VSoft.CommandLineParser](https://github.com/VSoftTechnologies/VSoft.CommandLineParser)
* [TMS BIZ](https://www.tmssoftware.com/site/tmsbizintro.asp)

Note that TMS BIZ is a commercial library. You can use the trial version for development (in case you want to contribute with the project).

## License

This project is [fair-code](http://faircode.io) distributed under [**Apache 2.0 with Commons Clause**](LICENSE) license.
