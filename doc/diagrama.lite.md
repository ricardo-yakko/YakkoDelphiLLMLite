# YakkoDelphiLLM Lite - Diagrama de Classes

Versao lite focada em um agente unico, com carregamento de modelo e execucao de tools.

```mermaid
classDiagram

namespace "LITE / TOOL EXECUTION" {
  class TYakkoAgenteLite {
    +Modelo: TYakkoModeloLite
    +ToolManager: TYakkoToolManagerLite
    +CarregarModelo(AModelPath) Boolean
    +DescarregarModelo()
    +ModeloCarregado() Boolean
    +Initialize()
    +FinalizeAgent()
    +RegistrarTool(ATool)
    +ExecutarRawPayload(ARawPayload) TYakkoToolExecutionReport
    +ExecutarTool(ANome, AParametrosJson) TYakkoToolExecutionReport
    +BuildToolListJson() string
  }

  class TYakkoModeloLite {
    +ModelPath: string
    +Carregar(ACaminho) Boolean
    +Descarregar()
    +EstaCarregado() Boolean
  }

  class TYakkoToolManagerLite {
    +Parser: IYakkoToolCallParserLite
    +RegistrarTool(ATool)
    +EncontrarTool(ANome) TYakkoToolLite
    +ExecutarToolCall(AToolCall) TYakkoToolResultLite
    +TryParseToolCall(ARawPayload, out AToolCall) Boolean
    +TryProcessRawPayload(ARawPayload, out AToolCall, out AResult) Boolean
    +BuildToolEventPayload(APhase, AToolCall, AResult) string
    +ListarTools() TArray~string~
  }

  class TYakkoToolLite {
    +Enabled: Boolean
    +Nome() string
    +Descricao() string
    +SchemaJson() string
    +Execute(AParametrosJson) string
  }

  class TYakkoJsonToolParserLite {
    +TryParse(ARawPayload, out AToolCall) Boolean
  }

  class IYakkoToolCallParserLite {
    <<interface>>
    +TryParse(ARawPayload, out AToolCall) Boolean
  }

  class TYakkoToolCallLite {
    +Nome: string
    +ParametrosJson: string
  }

  class TYakkoToolResultLite {
    +Sucesso: Boolean
    +ResultadoTexto: string
    +Erro: string
  }

  class TYakkoToolExecutionReport {
    +Parsed: Boolean
    +ToolCall: TYakkoToolCallLite
    +Result: TYakkoToolResultLite
    +PayloadJson: string
  }
}

namespace "CLI / AUTOMACAO" {
  class TYakkoCliOptions {
    +ModelPath: string
    +Payload: string
    +Iterations: Integer
    +ListTools: Boolean
    +FailOnError: Boolean
    +OutputPath: string
    +TryParseFromArgs(AArgs) Boolean
    +Validate() Boolean
  }

  class TYakkoAgenteLiteCli {
    +Options: TYakkoCliOptions
    +Run(AArgs) Integer
    +PrintUsage()
    +BuildSummaryJson(AReport) string
  }
}

TYakkoAgenteLite --> TYakkoModeloLite : usa
TYakkoAgenteLite --> TYakkoToolManagerLite : usa
TYakkoToolManagerLite --> TYakkoToolLite : gerencia N tools
TYakkoToolManagerLite --> IYakkoToolCallParserLite : estrategia de parse
TYakkoJsonToolParserLite ..|> IYakkoToolCallParserLite : implementa
TYakkoToolManagerLite --> TYakkoToolCallLite : consome
TYakkoToolManagerLite --> TYakkoToolResultLite : produz
TYakkoAgenteLite --> TYakkoToolExecutionReport : retorna
TYakkoToolExecutionReport --> TYakkoToolCallLite : contem
TYakkoToolExecutionReport --> TYakkoToolResultLite : contem
TYakkoAgenteLiteCli --> TYakkoCliOptions : usa
TYakkoAgenteLiteCli --> TYakkoAgenteLite : executa
```

## Escopo removido no Lite

- Sem engine de inferencia
- Sem chat/memoria/context window
- Sem RAG
- Sem pipeline de geracao de tokens
- Sem recursos avancados de orquestracao

## Objetivo

Manter somente um agente lite com carregamento simples de modelo e camada de tool calling para execucao controlada de tools, com baixa complexidade.
