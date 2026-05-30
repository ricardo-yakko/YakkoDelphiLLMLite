program YakkoAgenteLiteCLI;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  uYakkoAgenteLite,
  uYakkoToolManagerLite;

type
  THoraAtualTool = class(TYakkoToolLite)
  public
    function Nome: string; override;
    function Descricao: string; override;
    function Execute(const AParametrosJson: string): string; override;
  end;

  TYakkoCliOptions = record
    ModelPath: string;
    Payload: string;
    Iterations: Integer;
    ListTools: Boolean;
    FailOnError: Boolean;
    OutputPath: string;
    Help: Boolean;
  end;

function THoraAtualTool.Nome: string;
begin
  Result := 'hora_atual';
end;

function THoraAtualTool.Descricao: string;
begin
  Result := 'Retorna data e hora atual.';
end;

function THoraAtualTool.Execute(const AParametrosJson: string): string;
begin
  Result := DateTimeToStr(Now);
end;

procedure PrintUsage;
begin
  Writeln('YakkoAgenteLiteCLI - modo CLI para automacao de testes');
  Writeln('');
  Writeln('Uso:');
  Writeln('  YakkoAgenteLiteCLI --model <caminho.gguf> --payload <json> [opcoes]');
  Writeln('');
  Writeln('Opcoes:');
  Writeln('  --model <path>         Caminho do modelo');
  Writeln('  --payload <json>       Payload de tool call');
  Writeln('  --iterations <n>       Numero de repeticoes (padrao: 1)');
  Writeln('  --list-tools           Lista tools registradas e encerra');
  Writeln('  --fail-on-error        Retorna exit code 1 quando houver falha');
  Writeln('  --output <arquivo>     Salva resultado em arquivo json');
  Writeln('  --help                 Mostra esta ajuda');
end;

function TryGetArgValue(const AName: string; out AValue: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  AValue := '';
  for I := 1 to ParamCount - 1 do
  begin
    if SameText(ParamStr(I), AName) then
    begin
      AValue := ParamStr(I + 1);
      Exit(True);
    end;
  end;
end;

function HasFlag(const AName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), AName) then
      Exit(True);
end;

function ParseOptions(out AOptions: TYakkoCliOptions): Boolean;
var
  LValue: string;
begin
  AOptions.ModelPath := '';
  AOptions.Payload := '';
  AOptions.Iterations := 1;
  AOptions.ListTools := False;
  AOptions.FailOnError := False;
  AOptions.OutputPath := '';
  AOptions.Help := False;

  AOptions.Help := HasFlag('--help') or HasFlag('-h');
  AOptions.ListTools := HasFlag('--list-tools');
  AOptions.FailOnError := HasFlag('--fail-on-error');

  if TryGetArgValue('--model', LValue) then
    AOptions.ModelPath := Trim(LValue);

  if TryGetArgValue('--payload', LValue) then
    AOptions.Payload := Trim(LValue);

  if TryGetArgValue('--output', LValue) then
    AOptions.OutputPath := Trim(LValue);

  if TryGetArgValue('--iterations', LValue) then
  begin
    if not TryStrToInt(LValue, AOptions.Iterations) then
      Exit(False);
    if AOptions.Iterations < 1 then
      Exit(False);
  end;

  Result := True;
end;

function BuildResultJson(const AParsed: Boolean; const AReport: TYakkoToolExecutionReport; const ARunIndex: Integer): string;
var
  LObj: TJSONObject;
begin
  LObj := TJSONObject.Create;
  try
    LObj.AddPair('run', TJSONNumber.Create(ARunIndex));
    LObj.AddPair('parsed', TJSONBool.Create(AParsed));
    LObj.AddPair('tool', AReport.ToolCall.Nome);
    LObj.AddPair('arguments', AReport.ToolCall.ParametrosJson);
    LObj.AddPair('success', TJSONBool.Create(AReport.Result.Sucesso));
    LObj.AddPair('result', AReport.Result.ResultadoTexto);
    LObj.AddPair('error', AReport.Result.Erro);
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;

function RunCli(const AOptions: TYakkoCliOptions): Integer;
var
  LAgente: TYakkoAgenteLite;
  LReport: TYakkoToolExecutionReport;
  LParsed: Boolean;
  I: Integer;
  LJson: string;
  LWriter: TStreamWriter;
begin
  Result := 0;
  LAgente := TYakkoAgenteLite.Create(nil);
  try
    LAgente.Initialize;

    if AOptions.ModelPath <> '' then
    begin
      if not LAgente.CarregarModelo(AOptions.ModelPath) then
      begin
        Writeln('Falha ao carregar modelo: ' + AOptions.ModelPath);
        Exit(2);
      end;
    end;

    LAgente.RegistrarTool(THoraAtualTool.Create);

    if AOptions.ListTools then
    begin
      Writeln(LAgente.BuildToolListJson);
      Exit(0);
    end;

    if Trim(AOptions.Payload) = '' then
    begin
      Writeln('Parametro obrigatorio ausente: --payload');
      Exit(2);
    end;

    for I := 1 to AOptions.Iterations do
    begin
      LReport := LAgente.ExecutarRawPayload(AOptions.Payload);
      LParsed := LReport.Parsed;
      LJson := BuildResultJson(LParsed, LReport, I);
      Writeln(LJson);

      if AOptions.OutputPath <> '' then
      begin
        LWriter := TStreamWriter.Create(AOptions.OutputPath, I > 1, TEncoding.UTF8);
        try
          LWriter.WriteLine(LJson);
        finally
          LWriter.Free;
        end;
      end;

      if AOptions.FailOnError and ((not LParsed) or (not LReport.Result.Sucesso)) then
        Exit(1);
    end;
  finally
    LAgente.FinalizeAgent;
    LAgente.Free;
  end;
end;

var
  LOptions: TYakkoCliOptions;

begin
  try
    if not ParseOptions(LOptions) then
    begin
      Writeln('Parametros invalidos.');
      PrintUsage;
      ExitCode := 2;
      Exit;
    end;

    if LOptions.Help or (ParamCount = 0) then
    begin
      PrintUsage;
      ExitCode := 0;
      Exit;
    end;

    ExitCode := RunCli(LOptions);
  except
    on E: Exception do
    begin
      Writeln('Erro fatal: ' + E.Message);
      ExitCode := 3;
    end;
  end;
end.
