/* =========================================================================
ARCHIVO 1: BASE DE DATOS DE CONTABILIDAD - MICROSOFT SQL SERVER (T-SQL)
========================================================================= */
SET
  ANSI_NULLS ON;

SET
  QUOTED_IDENTIFIER ON;

GO
-- =========================================================================
-- 1. MÓDULO DE CUENTAS CONTABLES
-- =========================================================================
CREATE TABLE
  dbo.PlanDeCuentas (
    CuentaID INT NOT NULL,
    -- Código de la cuenta contable
    Clase INT NOT NULL,
    Grupo INT NOT NULL,
    Subgrupo INT NOT NULL,
    Principal INT NOT NULL,
    Analitica INT NOT NULL,
    -- Detalles de la cuenta contable
    MonedaID INT NOT NULL,
    Nombre NVARCHAR (255) NOT NULL,
    Detalle NVARCHAR (255) NULL,
    -- Saldos de la cuenta contable
    Debe DECIMAL(18, 2) NOT NULL CONSTRAINT DF_PlanDeCuentas_Debe DEFAULT 0,
    Haber DECIMAL(18, 2) NOT NULL CONSTRAINT DF_PlanDeCuentas_Haber DEFAULT 0,
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_PlanDeCuentas_Activo DEFAULT 1,
    CreadoEn DATETIME2 (0) NOT NULL CONSTRAINT DF_PlanDeCuentas_CreadoEn DEFAULT SYSUTCDATETIME (),
    ActualizadoEn DATETIME2 (0) NOT NULL CONSTRAINT DF_PlanDeCuentas_ActualizadoEn DEFAULT SYSUTCDATETIME (),
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT PK_PlanDeCuentas PRIMARY KEY CLUSTERED (CuentaID),
    CONSTRAINT UQ_PlanDeCuentas_Codigo UNIQUE (Clase, Grupo, Subgrupo, Principal, Analitica)
  );

GO
CREATE TABLE
  dbo.MovimientosAsiento (
    MovimientoID INT NOT NULL,
    Fecha DATETIME2 (0) NOT NULL,
    CuentaID INT NOT NULL,
    Nota NVARCHAR (255) NOT NULL,
    MonedaID INT NOT NULL,
    TipoCambio DECIMAL(18, 4) NOT NULL CONSTRAINT DF_Movimientos_TipoCambio DEFAULT 1,
    Debe DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Movimientos_Debe DEFAULT 0,
    Haber DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Movimientos_Haber DEFAULT 0,
    Referencia NVARCHAR (255) NULL,
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_Movimientos_Activo DEFAULT 1,
    CreadoEn DATETIME2 (0) NOT NULL CONSTRAINT DF_Movimientos_CreadoEn DEFAULT SYSUTCDATETIME (),
    ActualizadoEn DATETIME2 (0) NOT NULL CONSTRAINT DF_Movimientos_ActualizadoEn DEFAULT SYSUTCDATETIME (),
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT PK_Movimientos PRIMARY KEY CLUSTERED (MovimientoID),
    CONSTRAINT FK_Movimientos_PlanDeCuentas FOREIGN KEY (CuentaID) REFERENCES dbo.PlanDeCuentas (CuentaID),
    CONSTRAINT FK_Movimientos_Monedas FOREIGN KEY (MonedaID) REFERENCES dbo.Monedas (MonedaID)
  );

GO
CREATE TABLE
  dbo.DatosAsiento (
    DatoAsientoID INT NOT NULL,
    Glosa NVARCHAR (255) NOT NULL,
    Fecha DATETIME2 (0) NOT NULL,
    ComprobanteID INT NOT NULL,
    Documento NVARCHAR (255) NOT NULL,
    RazonSocial NVARCHAR (255) NOT NULL,
    TipoAsientoID INT NOT NULL,
    NIT NVARCHAR (20) NOT NULL,
    NumeroAutorizacion NVARCHAR (50) NOT NULL,
    CodigoControl NVARCHAR (50) NOT NULL,
    Numero NVARCHAR (50) NOT NULL,
    DUIDIM NVARCHAR (50) NOT NULL,
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_PlanDeCuentas_Activo DEFAULT 1,
    CreadoEn DATETIME2 (0) NOT NULL CONSTRAINT DF_PlanDeCuentas_CreadoEn DEFAULT SYSUTCDATETIME (),
    ActualizadoEn DATETIME2 (0) NOT NULL CONSTRAINT DF_PlanDeCuentas_ActualizadoEn DEFAULT SYSUTCDATETIME (),
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT PK_DatosAsiento PRIMARY KEY CLUSTERED (DatoAsientoID),
    CONSTRAINT FK_DatosAsiento_Comprobantes FOREIGN KEY (ComprobanteID) REFERENCES dbo.Comprobantes (ComprobanteID),
    CONSTRAINT FK_DatosAsiento_TiposAsiento FOREIGN KEY (TipoAsientoID) REFERENCES dbo.TiposAsiento (TipoAsientoID)
  );

GO
-- =========================================================================
-- 2. AUXILIARES DE CONTABILIDAD
-- =========================================================================
CREATE TABLE
  dbo.TiposAsiento (
    TipoAsientoID INT NOT NULL,
    Nombre NVARCHAR (255) NOT NULL,
    CONSTRAINT PK_TiposAsiento PRIMARY KEY CLUSTERED (TipoAsientoID)
  );

CREATE TABLE
  dbo.Comprobantes (
    ComprobanteID INT NOT NULL,
    Folio NVARCHAR (50) NOT NULL,
    Fecha DATETIME2 (0) NOT NULL,
    Glosa NVARCHAR (255) NOT NULL,
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_PlanDeCuentas_Activo DEFAULT 1,
    CreadoEn DATETIME2 (0) NOT NULL CONSTRAINT DF_PlanDeCuentas_CreadoEn DEFAULT SYSUTCDATETIME (),
    ActualizadoEn DATETIME2 (0) NOT NULL CONSTRAINT DF_PlanDeCuentas_ActualizadoEn DEFAULT SYSUTCDATETIME (),
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT PK_Comprobantes PRIMARY KEY CLUSTERED (ComprobanteID)
  );

GO
CREATE TABLE
  dbo.Monedas (
    MonedaID INT NOT NULL,
    Nombre NVARCHAR (255) NOT NULL,
    Simbolo NVARCHAR (10) NOT NULL,
    CONSTRAINT PK_Monedas PRIMARY KEY CLUSTERED (MonedaID)
  );

GO
CREATE TABLE
  dbo.Impuestos (
    ImpuestoID INT NOT NULL,
    Nombre NVARCHAR (255) NOT NULL,
    Tasa DECIMAL(18, 2) NOT NULL,
    CONSTRAINT PK_Impuestos PRIMARY KEY CLUSTERED (ImpuestoID)
  );

GO
CREATE TABLE
  dbo.Bancos (
    BancoID INT NOT NULL,
    Nombre NVARCHAR (255) NOT NULL,
    CONSTRAINT PK_Bancos PRIMARY KEY CLUSTERED (BancoID)
  );

GO
CREATE TABLE
  dbo.CuentasBancarias (
    CuentaBancariaID INT NOT NULL,
    BancoID INT NOT NULL,
    Nombre NVARCHAR (255) NOT NULL,
    NumeroCuenta NVARCHAR (50) NOT NULL,
    CONSTRAINT PK_CuentasBancarias PRIMARY KEY CLUSTERED (CuentaBancariaID),
    CONSTRAINT FK_CuentasBancarias_Bancos FOREIGN KEY (BancoID) REFERENCES dbo.Bancos (BancoID)
  );

GO
CREATE TABLE
  dbo.Reportes (
    ReporteID INT NOT NULL,
    Nombre NVARCHAR (255) NOT NULL,
    Detalle NVARCHAR (255) NOT NULL,
    CONSTRAINT PK_Reportes PRIMARY KEY CLUSTERED (ReporteID)
  );

GO