# Exemplo 02 - CLI para testes automatizados

Este exemplo usa o executavel YakkoAgenteLiteCLI para validar o fluxo de tools em linha de comando.

## 1) Sanidade

```powershell
YakkoAgenteLiteCLI.exe --list-tools
```

## 2) Teste unico

```powershell
YakkoAgenteLiteCLI.exe --payload '{"name":"hora_atual","arguments":{}}' --fail-on-error
```

## 3) Teste em lote

```powershell
YakkoAgenteLiteCLI.exe --payload '{"name":"hora_atual","arguments":{}}' --iterations 20 --fail-on-error --output 'resultado.jsonl'
```

## 4) Teste com modelo carregado

```powershell
YakkoAgenteLiteCLI.exe --model 'models\meu-modelo.gguf' --payload '{"name":"hora_atual","arguments":{}}' --iterations 5 --fail-on-error
```

## Resultado esperado

- Cada execucao imprime um JSON por linha
- Em caso de erro com --fail-on-error, processo encerra com exit code 1
- Saida em arquivo pode ser consumida por pipelines de CI
