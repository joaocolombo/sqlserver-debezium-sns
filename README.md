# SQL Server + Debezium Server + Pub/Sub (CDC end-to-end)

Stack completa, sobe pronta para uso, sem nenhum passo manual após o `docker compose up`.

## O que a stack faz automaticamente

1. **sqlserver** – sobe o SQL Server 2022 com o SQL Server Agent habilitado (necessário pro CDC).
2. **sqlserver-init** – espera o SQL Server ficar saudável e executa `create-cdc.sql`:
   - cria o banco `CadastroDB`
   - habilita CDC no banco
   - cria a tabela `dbo.pessoa`
   - habilita CDC na tabela `pessoa`
   - insere um registro de exemplo
3. **pubsub-emulator** – sobe o emulador do Google Cloud Pub/Sub na porta `8085`.
4. **pubsub-init** – espera o emulador ficar disponível e cria:
   - tópico `cdcserver.dbo.pessoa`
   - subscription `cdcserver.dbo.pessoa.sub`
5. **debezium-server** – conecta no CDC do SQL Server e publica cada INSERT/UPDATE/DELETE
   da tabela `pessoa` diretamente no tópico do Pub/Sub (usando o sink nativo do Debezium
   Server para Pub/Sub — não precisa de Kafka no meio).

## Como rodar

```bash
docker compose up -d
```

A ordem de dependências (`depends_on` + `condition: service_healthy` /
`service_completed_successfully`) garante que tudo suba na sequência certa.
O primeiro start pode levar de 1 a 2 minutos (SQL Server demora um pouco pra inicializar).

Para acompanhar o Debezium capturando e publicando:

```bash
docker logs -f debezium-server
```

## Como testar o fluxo

1. Insira/altere um registro na tabela `pessoa`:

```bash
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "YourStrong!Passw0rd" -C \
  -Q "USE CadastroDB; INSERT INTO dbo.pessoa (nome, email) VALUES ('Novo Teste', 'novo@teste.com');"
```

2. Confira nos logs do `debezium-server` a mensagem sendo publicada no Pub/Sub, ou
   puxe uma mensagem da subscription usando a REST API do emulador:

```bash
curl -X POST "http://localhost:8085/v1/projects/meu-projeto-local/subscriptions/cdcserver.dbo.pessoa.sub:pull" \
  -H "Content-Type: application/json" \
  -d '{"maxMessages": 5}'
```
caso nao tenham sido criados
```bash
curl --location --request PUT 'http://localhost:8085/v1/projects/meu-projeto-local/topics/cdcserver.CadastroDB.dbo.pessoa'
```
```bash
curl --location --request PUT 'http://localhost:8085/v1/projects/meu-projeto-local/subscriptions/cdcserver.CadastroDB.dbo.pessoa.sub' \
--header 'Content-Type: application/json' \
--data '{
       "topic": "projects/meu-projeto-local/topics/cdcserver.CadastroDB.dbo.pessoa"
     }'
```
## Credenciais / parâmetros padrão

| Item                        | Valor                         |
|-----------------------------|--------------------------------|
| SQL Server usuário/senha    | `sa` / `YourStrong!Passw0rd`  |
| Banco                       | `CadastroDB`                  |
| Tabela monitorada           | `dbo.pessoa`                  |
| Projeto GCP (fake, emulador)| `meu-projeto-local`           |
| Tópico Pub/Sub              | `cdcserver.dbo.pessoa`        |
| Subscription Pub/Sub        | `cdcserver.dbo.pessoa.sub`    |
| Porta Pub/Sub emulator      | `8085`                        |
| Porta SQL Server            | `1433`                        |

> Altere a senha do `sa` e o nome do projeto/tópico à vontade — só lembre de manter
> consistência entre `docker-compose.yml`, `application.properties` e `init-pubsub.sh`,
> já que o nome do tópico é derivado de `topic.prefix` + schema + tabela.

## Observações importantes

- Isso usa o **emulador** do Pub/Sub (não o Google Cloud real). Para produção, troque o
  serviço `pubsub-emulator` por credenciais reais (`GOOGLE_APPLICATION_CREDENTIALS` apontando
  para um service account) e remova o `PUBSUB_EMULATOR_HOST`.
- CDC no SQL Server depende do **SQL Server Agent**, por isso `MSSQL_AGENT_ENABLED=true`.
- Se quiser monitorar mais tabelas, basta ampliar `debezium.source.table.include.list` no
  `application.properties` e criar os tópicos/subscriptions correspondentes no `pubsub-init`.

