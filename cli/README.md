# YakkoAgenteLiteCLI

Modo CLI para iniciar o agente lite com parametros e automatizar testes.

## Parametros

- --model <path>: caminho do modelo (opcional)
- --payload <json>: payload de tool call (obrigatorio, exceto com --list-tools)
- --iterations <n>: numero de execucoes sequenciais
- --list-tools: lista as tools registradas e encerra
- --fail-on-error: retorna exit code 1 quando parse/tool falhar
- --output <arquivo>: salva cada resultado json em arquivo
- --help: mostra ajuda

## Exit codes

- 0: sucesso
- 1: falha de parse/tool com --fail-on-error
- 2: parametros invalidos ou falha no carregamento do modelo
- 3: erro fatal nao tratado

## Exemplos

Listar tools:

```powershell
YakkoAgenteLiteCLI.exe --list-tools
```

Executar 1 vez:

```powershell
YakkoAgenteLiteCLI.exe --payload '{"name":"hora_atual","arguments":{}}'
```

Executar 10 vezes para teste automatizado e falhar no primeiro erro:

```powershell
YakkoAgenteLiteCLI.exe --model 'models\meu-modelo.gguf' --payload '{"name":"hora_atual","arguments":{}}' --iterations 10 --fail-on-error
```

Salvar saida:

```powershell
YakkoAgenteLiteCLI.exe --payload '{"name":"hora_atual","arguments":{}}' --iterations 5 --output 'saida_cli.jsonl'
```
