unit MVCBr.HTTPRestClient;

interface

uses System.Classes, System.SysUtils,
  System.Generics.Collections, Data.DB,
  System.Net.HttpClient,
  System.Net.HttpClientComponent;

type

  THTTPRestMethod = (rmGET, rmPUT, rmPOST, rmPATCH, rmOPTIONS, rmDELETE);

  THTTPRestClient = class(TComponent)
  private
    FIdHTTP: TNetHTTPClient;
    FContent: string;
    FBaseURL: string;
    FResource: string;
    FMethod: THTTPRestMethod;
    FAcceptCharset: string;
    FAccept: String;
    FAcceptEncoding: string;
    FResourcePrefix: string;
    FTimeout: integer;
    FBody: TStrings;
    FResponseCode: Integer;
    procedure SetBaseURL(const Value: string);
    procedure SetResource(const Value: string);
    procedure SetMethod(const Value: THTTPRestMethod);
    procedure SetAcceptCharset(const Value: string);
    procedure SetAccept(const Value: String);
    procedure SetAcceptEncoding(const Value: string);
    procedure SetResourcePrefix(const Value: string);
    procedure SetTimeout(const Value: integer);
    procedure SetBody(const Value: TStrings);
    function GetHTTP: TNetHTTPClient;
    procedure SetResponseCode(const Value: Integer);
  protected
    function CreateURI: string;
    procedure Loaded; override;
  public
    function Execute(AProc: TProc): boolean; overload; virtual;
    function Execute(): boolean; overload; virtual;
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
    Property Content: String read FContent;
    Property HttpClient: TNetHTTPClient read GetHTTP;
    property ResponseCode:Integer read FResponseCode write SetResponseCode;
  published
    Property URL: string read CreateURI;
    Property Body: TStrings read FBody write SetBody;
    Property BaseURL: string read FBaseURL write SetBaseURL;
    Property Resource: string read FResource write SetResource;
    Property ResourcePrefix: string read FResourcePrefix
      write SetResourcePrefix;
    Property Method: THTTPRestMethod read FMethod write SetMethod default rmGET;
    Property AcceptCharset: string read FAcceptCharset write SetAcceptCharset;
    Property Accept: String read FAccept write SetAccept;
    Property AcceptEncoding: string read FAcceptEncoding
      write SetAcceptEncoding;
    Property Timeout: integer read FTimeout write SetTimeout default 30000;
  end;

implementation

Uses
  System.JSON;

{ TIdHTTPRestClient }

procedure THTTPRestClient.Loaded;
begin
  inherited;

end;

constructor THTTPRestClient.Create(AOwner: TComponent);
begin
  inherited;
  FMethod := rmGET;
  FIdHTTP := TNetHTTPClient.Create(self);
  /// workaroud   403 - Forbidden
  // FIdHTTP.Request.UserAgent :=
  // 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv: 12.0)Gecko / 20100101 Firefox / 12.0 ';

  FBody := TStringList.Create;
  if (csDesigning in ComponentState) and (FAccept = '') then
  begin
    FAcceptCharset := 'UTF-8';
    FAccept := 'application/json';
    // ; odata.metadata=minimal'; // , text/plain, text/html';
    FAcceptEncoding := 'gzip';
    FTimeout := 360000;
  end;
end;

function THTTPRestClient.CreateURI: string;
begin
  result := FBaseURL + FResourcePrefix + FResource;
end;

destructor THTTPRestClient.destroy;
begin
  FBody.DisposeOf;
  inherited;
end;

function THTTPRestClient.Execute: boolean;
begin
  result := Execute(nil);
end;

function THTTPRestClient.GetHTTP: TNetHTTPClient;
begin
  result := FIdHTTP;
end;

function THTTPRestClient.Execute(AProc: TProc): boolean;
var
  streamSource: TStringStream;
  i: integer;
  Response: IHTTPResponse;
begin
  result := false;
  streamSource := TStringStream.Create;
  try
    if FAcceptCharset = '' then
      FAcceptCharset := 'UTF-8';

    FIdHTTP.AcceptCharset := FAcceptCharset;
    FIdHTTP.AcceptCharset := FAcceptCharset;
    FIdHTTP.AcceptEncoding := FAcceptEncoding;
    FIdHTTP.Accept := FAccept;

    FIdHTTP.ContentType := 'application/json' + '; charset=' + FAcceptCharset;
    FIdHTTP.ResponseTimeout := FTimeout;
    FIdHTTP.ConnectionTimeout := 60000;

    if assigned(FBody) and (FBody.Count > 0) then
      for i := 0 to FBody.Count - 1 do
        streamSource.WriteString(FBody[i]);
    streamSource.Position := 0;

    case FMethod of
      rmGET:
        Response := FIdHTTP.Get(CreateURI);
      rmPUT:
        Response := FIdHTTP.Put(CreateURI, streamSource);
      rmPOST:
        Response := FIdHTTP.Post(CreateURI, FBody);
      rmPATCH:
        Response := FIdHTTP.Patch(CreateURI, streamSource);
      rmOPTIONS:
        Response := FIdHTTP.Options(CreateURI);
      rmDELETE:
        Response := FIdHTTP.Delete(CreateURI);
    end;
    FResponseCode := Response.StatusCode;
    result := (Response.StatusCode >= 200) and (Response.StatusCode <= 299);
    FContent := Response.ContentAsString(TEncoding.UTF8);
    if assigned(AProc) then
      AProc();
  finally
    freeAndNil(streamSource);
  end;

end;

procedure THTTPRestClient.SetAccept(const Value: String);
begin
  FAccept := Value;
end;

procedure THTTPRestClient.SetAcceptCharset(const Value: string);
begin
  FAcceptCharset := Value;
end;

procedure THTTPRestClient.SetAcceptEncoding(const Value: string);
begin
  FAcceptEncoding := Value;
end;

procedure THTTPRestClient.SetBaseURL(const Value: string);
begin
  FBaseURL := Value;
end;

procedure THTTPRestClient.SetBody(const Value: TStrings);
begin
  FBody := Value;
end;

procedure THTTPRestClient.SetMethod(const Value: THTTPRestMethod);
begin
  FMethod := Value;
end;

procedure THTTPRestClient.SetResource(const Value: string);
begin
  FResource := Value;
end;

procedure THTTPRestClient.SetResourcePrefix(const Value: string);
begin
  FResourcePrefix := Value;
end;

procedure THTTPRestClient.SetResponseCode(const Value: Integer);
begin
  FResponseCode := Value;
end;

procedure THTTPRestClient.SetTimeout(const Value: integer);
begin
  FTimeout := Value;
end;

end.
