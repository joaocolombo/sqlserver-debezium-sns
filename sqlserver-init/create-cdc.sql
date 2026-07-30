-- Cria o banco de dados, se ainda nao existir
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CadastroDB')
BEGIN
    CREATE DATABASE CadastroDB;
END
GO

USE CadastroDB;
GO

-- Habilita CDC no nivel do banco de dados
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'CadastroDB' AND is_cdc_enabled = 1)
BEGIN
    EXEC sys.sp_cdc_enable_db;
END
GO

-- Cria a tabela pessoa
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'pessoa')
BEGIN
    CREATE TABLE dbo.pessoa (
        id              INT IDENTITY(1,1) PRIMARY KEY,
        nome            VARCHAR(150) NOT NULL,
        email           VARCHAR(150) NULL,
        data_nascimento DATE NULL,
        criado_em       DATETIME2 DEFAULT SYSUTCDATETIME(),
        atualizado_em   DATETIME2 DEFAULT SYSUTCDATETIME()
    );
END
GO

-- Habilita CDC na tabela pessoa
IF NOT EXISTS (
    SELECT 1
    FROM cdc.change_tables ct
    INNER JOIN sys.tables t ON ct.source_object_id = t.object_id
    WHERE t.name = 'pessoa'
)
BEGIN
    EXEC sys.sp_cdc_enable_table
        @source_schema         = N'dbo',
        @source_name           = N'pessoa',
        @role_name              = NULL,
        @supports_net_changes  = 1;
END
GO

-- Registro de exemplo, so para validar o fluxo end-to-end
IF NOT EXISTS (SELECT 1 FROM dbo.pessoa)
BEGIN
    INSERT INTO dbo.pessoa (nome, email, data_nascimento)
    VALUES ('Pessoa Exemplo', 'exemplo@teste.com', '1990-01-01');
END
GO


-- Cria a tabela pespessoa2
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'pessoa2')
BEGIN
    CREATE TABLE dbo.pessoa2 (
        id              INT IDENTITY(1,1) PRIMARY KEY,
        nome            VARCHAR(150) NOT NULL,
        email           VARCHAR(150) NULL,
        data_nascimento DATE NULL,
        criado_em       DATETIME2 DEFAULT SYSUTCDATETIME(),
        atualizado_em   DATETIME2 DEFAULT SYSUTCDATETIME()
    );
END
GO

-- Habilita CDC na tabela pessoa2
IF NOT EXISTS (
    SELECT 1
    FROM cdc.change_tables ct
    INNER JOIN sys.tables t ON ct.source_object_id = t.object_id
    WHERE t.name = 'pessoa2'
)
BEGIN
    EXEC sys.sp_cdc_enable_table
        @source_schema         = N'dbo',
        @source_name           = N'pessoa2',
        @role_name              = NULL,
        @supports_net_changes  = 1;
END
GO

-- Registro de exemplo, so para validar o fluxo end-to-end
IF NOT EXISTS (SELECT 1 FROM dbo.pessoa2)
BEGIN
    INSERT INTO dbo.pessoa2 (nome, email, data_nascimento)
    VALUES ('Pessoa Exemplo', 'exemplo@teste.com', '1990-01-01');
END
GO
