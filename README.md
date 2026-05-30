# YakkoDelphiLLMlite

Versao lite do YakkoDelphiLLM focada em:

- TYakkoAgenteLite
- carregamento simples de modelo
- tool calling enxuto
- modo CLI para automacao de testes

## Estrutura

- doc/: diagramas e visao de arquitetura
- cli/: executavel console e guia de parametros
- exemplos/: exemplos de uso
- src/: codigo fonte da versao lite

## Quick Start

1. Abra o projeto no Delphi.
2. Compile o executavel CLI em cli/.
3. Rode um teste rapido:

```powershell
YakkoAgenteLiteCLI.exe --payload '{"name":"hora_atual","arguments":{}}' --fail-on-error
```

## CLI

Veja parametros e exemplos em:

- cli/README.md
- exemplos/02_cli/README.md

## Status

Projeto em evolucao para validar uma base minima, com menos recursos que a versao principal.
