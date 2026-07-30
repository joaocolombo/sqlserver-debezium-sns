# SQL Server + Debezium Server + SNS/SQS (CDC end-to-end)

Stack completa para capturar CDC do SQL Server via Debezium Server e publicar em um tópico SNS, com entrega para uma fila SQS.

O projeto usa **LocalStack** por padrão (SNS + SQS), sem depender de Kafka.

## O que a stack faz automaticamente

1. **sqlserver** – sobe o SQL Server 2022 com o SQL Server Agent habilitado (necessário pro CDC).
2. **sqlserver-init** – espera o SQL Server ficar saudável e executa `init-db.sh`:
   - cria o banco `CadastroDB`
   - habilita CDC no banco
   - cria a tabela `dbo.pessoa`
   - habilita CDC na tabela `pessoa`
   - insere um registro de exemplo
3. **localstack** – sobe SNS + SQS na porta `4566` e executa `localstack/init-sns.sh` no boot:
   - cria o tópico SNS `cdcserver_CadastroDB_dbo_pessoa`
   - cria a fila SQS `fila-dados-pessoa`
   - cria a subscription SNS → SQS
4. **debezium-server** – conecta no CDC do SQL Server e publica cada INSERT/UPDATE/DELETE
   da tabela `dbo.pessoa` no SNS.

## Como rodar

```bash
docker compose up -d
```

O primeiro start pode levar 1–2 minutos (SQL Server demora para inicializar).

Para acompanhar o Debezium:

```bash
docker logs -f debezium-server
```

## Como testar o fluxo

1. Insira um registro na tabela `pessoa`:

```bash
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "YourStrong!Passw0rd" -C \
  -Q "USE CadastroDB; INSERT INTO dbo.pessoa (nome, email) VALUES ('Novo Teste', 'novo@teste.com');"
```

2. Verifique se a mensagem chegou na fila SQS (LocalStack):

```bash
docker compose exec localstack awslocal sqs receive-message \
  --queue-url http://localhost:4566/000000000000/fila-dados-pessoa \
  --max-number-of-messages 5
```

Se quiser inspecionar os recursos criados:

```bash
docker compose exec localstack awslocal sns list-topics
docker compose exec localstack awslocal sqs list-queues
docker compose exec localstack awslocal sns list-subscriptions
```

## Parâmetros padrão

| Item                     | Valor                          |
|--------------------------|--------------------------------|
| SQL Server usuário/senha | `sa` / `YourStrong!Passw0rd`   |
| Banco                    | `CadastroDB`                   |
| Tabela monitorada        | `dbo.pessoa`                   |
| LocalStack edge port     | `4566`                         |
| SNS topic                | `cdcserver_CadastroDB_dbo_pessoa` |
| SQS queue                | `fila-dados-pessoa`            |
| Porta SQL Server         | `1433`                         |

## Observações importantes

- O nome do tópico SNS usado pelo Debezium é derivado do *destination* (a “topic name” do conector). Neste projeto, o tópico esperado é `cdcserver_CadastroDB_dbo_pessoa`.
- O `localstack/init-sns.sh` roda somente no boot do LocalStack. Se você alterou o script e não refletiu, recrie o container:
  - `docker compose down`
  - `docker compose up -d localstack`
- Para usar **AWS real** (fora do LocalStack), remova `endpoint`/`endpoint-override` do SNS e use credenciais reais; além disso, crie o tópico na sua conta e ajuste o `accountId` do ARN (não é `000000000000`).

