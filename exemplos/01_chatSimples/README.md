# Exemplo 01 - ChatSimples

Objetivo: demonstrar o fluxo minimo com TYakkoAgenteLite.

## Fluxo

1. Criar o agente
2. Carregar o modelo
3. Registrar uma tool
4. Executar um payload
5. Finalizar o agente

## Exemplo (Delphi)

```pascal
uses
  System.SysUtils,
  uYakkoAgenteLite,
  uYakkoToolManagerLite;

type
  THoraAtualTool = class(TYakkoToolLite)
  public
    function Nome: string; override;
    function Descricao: string; override;
    function Execute(const AParametrosJson: string): string; override;
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

procedure RodarChatSimples;
var
  Agente: TYakkoAgenteLite;
  Report: TYakkoToolExecutionReport;
begin
  Agente := TYakkoAgenteLite.Create(nil);
  try
    Agente.Initialize;
    if not Agente.CarregarModelo('models/meu-modelo.gguf') then
      raise Exception.Create('Falha ao carregar modelo.');

    Agente.RegistrarTool(THoraAtualTool.Create);

    Report := Agente.ExecutarRawPayload('{"name":"hora_atual","arguments":{}}');
    if Report.Result.Sucesso then
      Writeln('Resultado: ' + Report.Result.ResultadoTexto)
    else
      Writeln('Erro: ' + Report.Result.Erro);

    Agente.FinalizeAgent;
  finally
    Agente.Free;
  end;
end;
```

## Payload esperado

Formato minimo aceito pelo parser:

```json
{
  "name": "hora_atual",
  "arguments": {}
}
```

## Observacao

Este exemplo segue o diagrama lite e nao depende de chat completo, RAG ou memoria.
