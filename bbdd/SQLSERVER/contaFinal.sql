/* ========================================================================= */
/*       SISTEMA CONTABLE MULTIEMPRESA - MICROSOFT SQL SERVER (T-SQL)        */
/* ========================================================================= */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =========================================================================
-- 1. CATÁLOGOS GLOBALES Y PARÁMETROS TRANSVERSALES
-- =========================================================================

CREATE TABLE dbo.Monedas (
    MonedaID INT IDENTITY(1,1) NOT NULL,
    CodigoISO CHAR(3) NOT NULL, -- Ej: 'BOB', 'USD', 'UFV'
    Nombre NVARCHAR(100) NOT NULL,
    Simbolo NVARCHAR(10) NOT NULL,
    EsMonedaCursoLegal BIT NOT NULL CONSTRAINT DF_Monedas_CursoLegal DEFAULT 0,
    Activo BIT NOT NULL CONSTRAINT DF_Monedas_Activo DEFAULT 1,
    CONSTRAINT PK_Monedas PRIMARY KEY CLUSTERED (MonedaID),
    CONSTRAINT UQ_Monedas_CodigoISO UNIQUE (CodigoISO)
);
GO

CREATE TABLE dbo.CotizacionesMoneda (
    CotizacionID INT IDENTITY(1,1) NOT NULL,
    MonedaID INT NOT NULL,
    Fecha DATE NOT NULL,
    TipoCambioOficial DECIMAL(18, 6) NOT NULL,
    TipoCambioCompra DECIMAL(18, 6) NULL,
    TipoCambioVenta DECIMAL(18, 6) NULL,
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Cotizaciones_CreadoEn DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_CotizacionesMoneda PRIMARY KEY CLUSTERED (CotizacionID),
    CONSTRAINT UQ_Cotizaciones_Moneda_Fecha UNIQUE (MonedaID, Fecha),
    CONSTRAINT FK_Cotizaciones_Monedas FOREIGN KEY (MonedaID) REFERENCES dbo.Monedas (MonedaID),
    CONSTRAINT CK_Cotizaciones_Positivo CHECK (TipoCambioOficial > 0)
);
GO

CREATE TABLE dbo.Bancos (
    BancoID INT IDENTITY(1,1) NOT NULL,
    CodigoASFI VARCHAR(20) NULL,
    Nombre NVARCHAR(150) NOT NULL,
    Sigla NVARCHAR(20) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Bancos_Activo DEFAULT 1,
    CONSTRAINT PK_Bancos PRIMARY KEY CLUSTERED (BancoID)
);
GO

CREATE TABLE dbo.Impuestos (
    ImpuestoID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(20) NOT NULL, -- Ej: 'IVA', 'IT', 'IUE', 'RC-IVA'
    Nombre NVARCHAR(150) NOT NULL,
    TasaPorcentaje DECIMAL(5, 2) NOT NULL, -- Ej: 13.00, 3.00, 25.00
    Activo BIT NOT NULL CONSTRAINT DF_Impuestos_Activo DEFAULT 1,
    CONSTRAINT PK_Impuestos PRIMARY KEY CLUSTERED (ImpuestoID),
    CONSTRAINT UQ_Impuestos_Codigo UNIQUE (Codigo),
    CONSTRAINT CK_Impuestos_Tasa CHECK (TasaPorcentaje >= 0 AND TasaPorcentaje <= 100)
);
GO

-- =========================================================================
-- 2. MÓDULO DE USUARIOS, EMPRESAS, ROLES Y PERMISOS (MULTI-EMPRESA)
-- =========================================================================

CREATE TABLE dbo.Usuarios (
    UsuarioID INT IDENTITY(1,1) NOT NULL,
    NombreUsuario VARCHAR(64) NOT NULL,
    CorreoElectronico NVARCHAR(150) NOT NULL,
    Nombres NVARCHAR(100) NOT NULL,
    Apellidos NVARCHAR(100) NOT NULL,
    DocumentoIdentidad VARCHAR(30) NULL,
    Telefono NVARCHAR(30) NULL,
    ContrasenaHash VARBINARY(64) NOT NULL, -- Hash criptográfico (ej. SHA2_512 / Argon2)
    ContrasenaSalt VARBINARY(32) NOT NULL,
    EsSuperAdministradorSistema BIT NOT NULL CONSTRAINT DF_Usuarios_SuperAdmin DEFAULT 0,
    UltimoAcceso DATETIME2(0) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Usuarios_Activo DEFAULT 1,
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Usuarios_CreadoEn DEFAULT SYSUTCDATETIME(),
    ActualizadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Usuarios_ActualizadoEn DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Usuarios PRIMARY KEY CLUSTERED (UsuarioID),
    CONSTRAINT UQ_Usuarios_NombreUsuario UNIQUE (NombreUsuario),
    CONSTRAINT UQ_Usuarios_Correo UNIQUE (CorreoElectronico)
);
GO

CREATE TABLE dbo.Empresas (
    EmpresaID INT IDENTITY(1,1) NOT NULL,
    RazonSocial NVARCHAR(255) NOT NULL,
    NombreComercial NVARCHAR(255) NULL,
    NIT NVARCHAR(25) NOT NULL,
    MatriculaComercio VARCHAR(50) NULL,
    TipoContribuyente NVARCHAR(50) NULL, -- Ej: 'Unipersonal', 'SRL', 'SA'
    TipoActividadEconomica NVARCHAR(100) NULL, -- Define el mes de cierre (Comercial, Industrial, Minera, Agropecuaria)
    MesCierreFiscal TINYINT NOT NULL CONSTRAINT DF_Empresas_MesCierre DEFAULT 12, -- 3, 6, 9 o 12
    MonedaBaseID INT NOT NULL,
    DireccionFiscal NVARCHAR(255) NULL,
    Telefono NVARCHAR(50) NULL,
    CorreoCorporativo NVARCHAR(150) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Empresas_Activo DEFAULT 1,
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Empresas_CreadoEn DEFAULT SYSUTCDATETIME(),
    ActualizadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Empresas_ActualizadoEn DEFAULT SYSUTCDATETIME(),
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT PK_Empresas PRIMARY KEY CLUSTERED (EmpresaID),
    CONSTRAINT UQ_Empresas_NIT UNIQUE (NIT),
    CONSTRAINT FK_Empresas_Monedas FOREIGN KEY (MonedaBaseID) REFERENCES dbo.Monedas (MonedaID),
    CONSTRAINT FK_Empresas_CreadoPor FOREIGN KEY (CreadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT CK_Empresas_MesCierre CHECK (MesCierreFiscal BETWEEN 1 AND 12)
);
GO

CREATE TABLE dbo.SucursalesEmpresa (
    SucursalID INT IDENTITY(1,1) NOT NULL,
    EmpresaID INT NOT NULL,
    NumeroSucursalSIN SMALLINT NOT NULL CONSTRAINT DF_Sucursales_Numero DEFAULT 0, -- 0 = Casa Matriz
    Nombre NVARCHAR(150) NOT NULL,
    Direccion NVARCHAR(255) NOT NULL,
    Ciudad NVARCHAR(100) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Sucursales_Activo DEFAULT 1,
    CONSTRAINT PK_SucursalesEmpresa PRIMARY KEY CLUSTERED (SucursalID),
    CONSTRAINT UQ_Sucursales_Empresa_Numero UNIQUE (EmpresaID, NumeroSucursalSIN),
    CONSTRAINT FK_Sucursales_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID)
);
GO

CREATE TABLE dbo.Roles (
    RolID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(50) NOT NULL, -- Ej: 'DUENO', 'CONTADOR', 'AUDITOR', 'ADMINISTRACION', 'SISTEMAS', 'AUXILIAR'
    Nombre NVARCHAR(100) NOT NULL,
    AreaFuncional NVARCHAR(100) NOT NULL, -- Ej: 'Contabilidad', 'Auditoría', 'Dirección', 'Administración', 'TI/Sistemas'
    Descripcion NVARCHAR(255) NULL,
    EsSoloLectura BIT NOT NULL CONSTRAINT DF_Roles_SoloLectura DEFAULT 0, -- Útil para Auditores o Socios
    Activo BIT NOT NULL CONSTRAINT DF_Roles_Activo DEFAULT 1,
    CONSTRAINT PK_Roles PRIMARY KEY CLUSTERED (RolID),
    CONSTRAINT UQ_Roles_Codigo UNIQUE (Codigo)
);
GO

CREATE TABLE dbo.Permisos (
    PermisoID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(100) NOT NULL, -- Ej: 'COMPROBANTES_CREAR', 'COMPROBANTES_ANULAR', 'PERIODO_CERRAR', 'USUARIOS_GESTIONAR'
    Modulo NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_Permisos PRIMARY KEY CLUSTERED (PermisoID),
    CONSTRAINT UQ_Permisos_Codigo UNIQUE (Codigo)
);
GO

CREATE TABLE dbo.RolesPermisos (
    RolID INT NOT NULL,
    PermisoID INT NOT NULL,
    CONSTRAINT PK_RolesPermisos PRIMARY KEY CLUSTERED (RolID, PermisoID),
    CONSTRAINT FK_RolesPermisos_Roles FOREIGN KEY (RolID) REFERENCES dbo.Roles (RolID),
    CONSTRAINT FK_RolesPermisos_Permisos FOREIGN KEY (PermisoID) REFERENCES dbo.Permisos (PermisoID)
);
GO

-- Tabla Puente N:M: Permite que un usuario esté en varias empresas con distintos o iguales roles
CREATE TABLE dbo.UsuariosEmpresasRoles (
    UsuarioEmpresaRolID INT IDENTITY(1,1) NOT NULL,
    UsuarioID INT NOT NULL,
    EmpresaID INT NOT NULL,
    RolID INT NOT NULL,
    SucursalAsignadaID INT NULL, -- NULL si tiene acceso a todas las sucursales de esa empresa
    FechaInicioAsignacion DATE NOT NULL CONSTRAINT DF_UER_FechaInicio DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    FechaFinAsignacion DATE NULL, -- Muy útil para accesos temporales de Auditores Externos
    Activo BIT NOT NULL CONSTRAINT DF_UER_Activo DEFAULT 1,
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_UER_CreadoEn DEFAULT SYSUTCDATETIME(),
    AsignadoPor INT NULL,
    CONSTRAINT PK_UsuariosEmpresasRoles PRIMARY KEY CLUSTERED (UsuarioEmpresaRolID),
    CONSTRAINT UQ_Usuario_Empresa_Rol UNIQUE (UsuarioID, EmpresaID, RolID),
    CONSTRAINT FK_UER_Usuarios FOREIGN KEY (UsuarioID) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT FK_UER_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID),
    CONSTRAINT FK_UER_Roles FOREIGN KEY (RolID) REFERENCES dbo.Roles (RolID),
    CONSTRAINT FK_UER_Sucursales FOREIGN KEY (SucursalAsignadaID) REFERENCES dbo.SucursalesEmpresa (SucursalID),
    CONSTRAINT FK_UER_AsignadoPor FOREIGN KEY (AsignadoPor) REFERENCES dbo.Usuarios (UsuarioID)
);
GO

-- =========================================================================
-- 3. GESTIONES Y PERIODOS CONTABLES (CONTROL DE CIERRES)
-- =========================================================================

CREATE TABLE dbo.GestionesContables (
    GestionID INT IDENTITY(1,1) NOT NULL,
    EmpresaID INT NOT NULL,
    NombreGestion NVARCHAR(50) NOT NULL, -- Ej: 'Gestión 2026'
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    Estado VARCHAR(20) NOT NULL CONSTRAINT DF_Gestiones_Estado DEFAULT 'Abierta', -- 'Abierta', 'Cerrada', 'Auditada'
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Gestiones_CreadoEn DEFAULT SYSUTCDATETIME(),
    CerradoPor INT NULL,
    CONSTRAINT PK_GestionesContables PRIMARY KEY CLUSTERED (GestionID),
    CONSTRAINT FK_Gestiones_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID),
    CONSTRAINT FK_Gestiones_CerradoPor FOREIGN KEY (CerradoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT CK_Gestiones_Fechas CHECK (FechaFin > FechaInicio),
    CONSTRAINT CK_Gestiones_Estado CHECK (Estado IN ('Abierta', 'Cerrada', 'Auditada'))
);
GO

CREATE TABLE dbo.PeriodosContables (
    PeriodoID INT IDENTITY(1,1) NOT NULL,
    GestionID INT NOT NULL,
    EmpresaID INT NOT NULL,
    Anio SMALLINT NOT NULL,
    Mes TINYINT NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    Cerrado BIT NOT NULL CONSTRAINT DF_Periodos_Cerrado DEFAULT 0, -- Impide que se editen asientos de meses ya declarados
    CONSTRAINT PK_PeriodosContables PRIMARY KEY CLUSTERED (PeriodoID),
    CONSTRAINT UQ_Periodos_Empresa_Anio_Mes UNIQUE (EmpresaID, Anio, Mes),
    CONSTRAINT FK_Periodos_Gestiones FOREIGN KEY (GestionID) REFERENCES dbo.GestionesContables (GestionID),
    CONSTRAINT FK_Periodos_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID),
    CONSTRAINT CK_Periodos_Mes CHECK (Mes BETWEEN 1 AND 12)
);
GO

-- =========================================================================
-- 4. PLAN DE CUENTAS Y CENTROS DE COSTO POR EMPRESA
-- =========================================================================

CREATE TABLE dbo.PlanDeCuentas (
    CuentaID INT IDENTITY(1,1) NOT NULL,
    EmpresaID INT NOT NULL,
    CuentaPadreID INT NULL, -- Jerarquía recursiva para árbol contable
    -- Estructura codificada
    CodigoFormateado VARCHAR(50) NOT NULL, -- Ej: '1.1.01.01.001'
    Clase TINYINT NOT NULL,
    Grupo TINYINT NOT NULL,
    Subgrupo SMALLINT NOT NULL,
    Principal SMALLINT NOT NULL,
    Analitica INT NOT NULL,
    Nivel TINYINT NOT NULL, -- 1 a 5
    -- Propiedades contables
    Nombre NVARCHAR(255) NOT NULL,
    Detalle NVARCHAR(255) NULL,
    Naturaleza CHAR(1) NOT NULL, -- 'D' (Deudora: Activo/Egreso), 'A' (Acreedora: Pasivo/Patrimonio/Ingreso)
    EsImputable BIT NOT NULL CONSTRAINT DF_PlanDeCuentas_Imputable DEFAULT 1, -- 1 = Recibe asientos; 0 = Cuenta agrupadora/título
    MonedaID INT NOT NULL,
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_PlanDeCuentas_Activo DEFAULT 1,
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_PlanDeCuentas_CreadoEn DEFAULT SYSUTCDATETIME(),
    ActualizadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_PlanDeCuentas_ActualizadoEn DEFAULT SYSUTCDATETIME(),
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT PK_PlanDeCuentas PRIMARY KEY CLUSTERED (CuentaID),
    CONSTRAINT UQ_PlanDeCuentas_Empresa_Niveles UNIQUE (EmpresaID, Clase, Grupo, Subgrupo, Principal, Analitica),
    CONSTRAINT UQ_PlanDeCuentas_Empresa_Codigo UNIQUE (EmpresaID, CodigoFormateado),
    CONSTRAINT FK_PlanDeCuentas_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID),
    CONSTRAINT FK_PlanDeCuentas_Padre FOREIGN KEY (CuentaPadreID) REFERENCES dbo.PlanDeCuentas (CuentaID),
    CONSTRAINT FK_PlanDeCuentas_Monedas FOREIGN KEY (MonedaID) REFERENCES dbo.Monedas (MonedaID),
    CONSTRAINT FK_PlanDeCuentas_CreadoPor FOREIGN KEY (CreadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT FK_PlanDeCuentas_ActualizadoPor FOREIGN KEY (ActualizadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT CK_PlanDeCuentas_Naturaleza CHECK (Naturaleza IN ('D', 'A'))
);
GO

CREATE TABLE dbo.CentrosDeCosto (
    CentroCostoID INT IDENTITY(1,1) NOT NULL,
    EmpresaID INT NOT NULL,
    Codigo VARCHAR(30) NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CentrosCosto_Activo DEFAULT 1,
    CONSTRAINT PK_CentrosDeCosto PRIMARY KEY CLUSTERED (CentroCostoID),
    CONSTRAINT UQ_CentrosCosto_Empresa_Codigo UNIQUE (EmpresaID, Codigo),
    CONSTRAINT FK_CentrosCosto_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID)
);
GO

CREATE TABLE dbo.CuentasBancarias (
    CuentaBancariaID INT IDENTITY(1,1) NOT NULL,
    EmpresaID INT NOT NULL,
    BancoID INT NOT NULL,
    MonedaID INT NOT NULL,
    CuentaContableID INT NOT NULL, -- Vínculo directo con la cuenta del Plan de Cuentas
    Nombre NVARCHAR(255) NOT NULL,
    NumeroCuenta NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CuentasBancarias_Activo DEFAULT 1,
    CONSTRAINT PK_CuentasBancarias PRIMARY KEY CLUSTERED (CuentaBancariaID),
    CONSTRAINT UQ_CuentasBancarias_Banco_Numero UNIQUE (BancoID, NumeroCuenta),
    CONSTRAINT FK_CuentasBancarias_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID),
    CONSTRAINT FK_CuentasBancarias_Bancos FOREIGN KEY (BancoID) REFERENCES dbo.Bancos (BancoID),
    CONSTRAINT FK_CuentasBancarias_Monedas FOREIGN KEY (MonedaID) REFERENCES dbo.Monedas (MonedaID),
    CONSTRAINT FK_CuentasBancarias_PlanDeCuentas FOREIGN KEY (CuentaContableID) REFERENCES dbo.PlanDeCuentas (CuentaID)
);
GO

-- =========================================================================
-- 5. MOTOR TRANSACCIONAL: COMPROBANTES, MOVIMIENTOS Y DOCUMENTOS FISCALES
-- =========================================================================

CREATE TABLE dbo.TiposAsiento (
    TipoAsientoID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(10) NOT NULL, -- Ej: 'ING' (Ingreso), 'EGR' (Egreso), 'TRA' (Traspaso), 'AJU' (Ajuste), 'APE' (Apertura)
    Nombre NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_TiposAsiento PRIMARY KEY CLUSTERED (TipoAsientoID),
    CONSTRAINT UQ_TiposAsiento_Codigo UNIQUE (Codigo)
);
GO

-- Cabecera del Asiento Contable
CREATE TABLE dbo.Comprobantes (
    ComprobanteID BIGINT IDENTITY(1,1) NOT NULL,
    EmpresaID INT NOT NULL,
    SucursalID INT NOT NULL,
    PeriodoID INT NOT NULL,
    TipoAsientoID INT NOT NULL,
    NumeroCorrelativo INT NOT NULL, -- Correlativo por Empresa, Periodo y Tipo (Ej: EGR-00045)
    Folio NVARCHAR(50) NOT NULL,
    Fecha DATE NOT NULL,
    MonedaID INT NOT NULL,
    TipoCambio DECIMAL(18, 6) NOT NULL CONSTRAINT DF_Comprobantes_TipoCambio DEFAULT 1,
    GlosaGeneral NVARCHAR(500) NOT NULL,
    BeneficiarioPagador NVARCHAR(255) NULL,
    Estado VARCHAR(20) NOT NULL CONSTRAINT DF_Comprobantes_Estado DEFAULT 'Borrador', -- 'Borrador', 'Mayorizado', 'Anulado'
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_Comprobantes_Activo DEFAULT 1,
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Comprobantes_CreadoEn DEFAULT SYSUTCDATETIME(),
    ActualizadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Comprobantes_ActualizadoEn DEFAULT SYSUTCDATETIME(),
    CreadoPor INT NOT NULL,
    ActualizadoPor INT NULL,
    AprobadoPor INT NULL,
    CONSTRAINT PK_Comprobantes PRIMARY KEY CLUSTERED (ComprobanteID),
    CONSTRAINT UQ_Comprobantes_Correlativo UNIQUE (EmpresaID, PeriodoID, TipoAsientoID, NumeroCorrelativo),
    CONSTRAINT FK_Comprobantes_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID),
    CONSTRAINT FK_Comprobantes_Sucursales FOREIGN KEY (SucursalID) REFERENCES dbo.SucursalesEmpresa (SucursalID),
    CONSTRAINT FK_Comprobantes_Periodos FOREIGN KEY (PeriodoID) REFERENCES dbo.PeriodosContables (PeriodoID),
    CONSTRAINT FK_Comprobantes_TiposAsiento FOREIGN KEY (TipoAsientoID) REFERENCES dbo.TiposAsiento (TipoAsientoID),
    CONSTRAINT FK_Comprobantes_Monedas FOREIGN KEY (MonedaID) REFERENCES dbo.Monedas (MonedaID),
    CONSTRAINT FK_Comprobantes_CreadoPor FOREIGN KEY (CreadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT FK_Comprobantes_ActualizadoPor FOREIGN KEY (ActualizadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT FK_Comprobantes_AprobadoPor FOREIGN KEY (AprobadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT CK_Comprobantes_Estado CHECK (Estado IN ('Borrador', 'Mayorizado', 'Anulado'))
);
GO

-- Detalle del Asiento Contable (Líneas de Partida Doble)
CREATE TABLE dbo.MovimientosAsiento (
    MovimientoID BIGINT IDENTITY(1,1) NOT NULL,
    ComprobanteID BIGINT NOT NULL, -- Vínculo obligatorio con la cabecera
    NumeroLinea SMALLINT NOT NULL,
    CuentaID INT NOT NULL,
    CentroCostoID INT NULL,
    GlosaLinea NVARCHAR(255) NOT NULL,
    ReferenciaDocumento NVARCHAR(100) NULL, -- Ej: Nro. Cheque, Transferencia, Recibo
    -- Importes en Moneda Base de la Empresa (ej. BOB)
    DebeMonedaBase DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Movimientos_DebeBase DEFAULT 0,
    HaberMonedaBase DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Movimientos_HaberBase DEFAULT 0,
    -- Importes en Moneda Extranjera / Transacción (ej. USD)
    DebeMonedaExtranjera DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Movimientos_DebeExt DEFAULT 0,
    HaberMonedaExtranjera DECIMAL(18, 2) NOT NULL CONSTRAINT DF_Movimientos_HaberExt DEFAULT 0,
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_Movimientos_Activo DEFAULT 1,
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Movimientos_CreadoEn DEFAULT SYSUTCDATETIME(),
    ActualizadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_Movimientos_ActualizadoEn DEFAULT SYSUTCDATETIME(),
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT PK_MovimientosAsiento PRIMARY KEY CLUSTERED (MovimientoID),
    CONSTRAINT FK_Movimientos_Comprobantes FOREIGN KEY (ComprobanteID) REFERENCES dbo.Comprobantes (ComprobanteID),
    CONSTRAINT FK_Movimientos_PlanDeCuentas FOREIGN KEY (CuentaID) REFERENCES dbo.PlanDeCuentas (CuentaID),
    CONSTRAINT FK_Movimientos_CentrosCosto FOREIGN KEY (CentroCostoID) REFERENCES dbo.CentrosDeCosto (CentroCostoID),
    CONSTRAINT FK_Movimientos_CreadoPor FOREIGN KEY (CreadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT FK_Movimientos_ActualizadoPor FOREIGN KEY (ActualizadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    -- Regla contable: Una línea no puede tener valores negativos ni cargar Debe y Haber al mismo tiempo
    CONSTRAINT CK_Movimientos_NoNegativos CHECK (DebeMonedaBase >= 0 AND HaberMonedaBase >= 0 AND DebeMonedaExtranjera >= 0 AND HaberMonedaExtranjera >= 0),
    CONSTRAINT CK_Movimientos_DebeOHaber CHECK (
        (DebeMonedaBase > 0 AND HaberMonedaBase = 0) OR
        (HaberMonedaBase > 0 AND DebeMonedaBase = 0)
    )
);
GO

-- Documentos Fiscales Asociados (Reemplaza y normaliza DatosAsiento para Libros de Compras/Ventas IVA)
CREATE TABLE dbo.DocumentosFiscalesAsiento (
    DocumentoFiscalID BIGINT IDENTITY(1,1) NOT NULL,
    ComprobanteID BIGINT NOT NULL,
    EmpresaID INT NOT NULL,
    TipoRegistro VARCHAR(15) NOT NULL, -- 'COMPRA', 'VENTA'
    FechaFactura DATE NOT NULL,
    NITProveedorCliente NVARCHAR(25) NOT NULL,
    ComplementoDocumento VARCHAR(5) NULL,
    RazonSocial NVARCHAR(255) NOT NULL,
    NumeroFactura NVARCHAR(50) NOT NULL,
    NumeroDUI_DIM NVARCHAR(50) NULL, -- Opcional, solo para pólizas de importación
    CodigoAutorizacionCUF NVARCHAR(150) NOT NULL, -- Soporta CUF de facturación en línea SIAT (largo)
    CodigoControl NVARCHAR(50) NULL, -- NULL en facturas electrónicas en línea, usado en manuales/computarizadas antiguas
    ImporteTotal DECIMAL(18, 2) NOT NULL,
    ImporteICE DECIMAL(18, 2) NOT NULL CONSTRAINT DF_DocFiscal_ICE DEFAULT 0,
    ImporteExento DECIMAL(18, 2) NOT NULL CONSTRAINT DF_DocFiscal_Exento DEFAULT 0,
    DescuentosBonificaciones DECIMAL(18, 2) NOT NULL CONSTRAINT DF_DocFiscal_Descuentos DEFAULT 0,
    ImporteBaseCreditoDebitoFiscal DECIMAL(18, 2) NOT NULL,
    ImpuestoIVA DECIMAL(18, 2) NOT NULL,
    EstadoFactura VARCHAR(20) NOT NULL CONSTRAINT DF_DocFiscal_Estado DEFAULT 'Valida', -- 'Valida', 'Anulada'
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_DocFiscal_Activo DEFAULT 1,
    CreadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_DocFiscal_CreadoEn DEFAULT SYSUTCDATETIME(),
    ActualizadoEn DATETIME2(0) NOT NULL CONSTRAINT DF_DocFiscal_ActualizadoEn DEFAULT SYSUTCDATETIME(),
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT PK_DocumentosFiscalesAsiento PRIMARY KEY CLUSTERED (DocumentoFiscalID),
    CONSTRAINT FK_DocFiscal_Comprobantes FOREIGN KEY (ComprobanteID) REFERENCES dbo.Comprobantes (ComprobanteID),
    CONSTRAINT FK_DocFiscal_Empresas FOREIGN KEY (EmpresaID) REFERENCES dbo.Empresas (EmpresaID),
    CONSTRAINT FK_DocFiscal_CreadoPor FOREIGN KEY (CreadoPor) REFERENCES dbo.Usuarios (UsuarioID),
    CONSTRAINT CK_DocFiscal_TipoRegistro CHECK (TipoRegistro IN ('COMPRA', 'VENTA'))
);
GO

CREATE TABLE dbo.Reportes (
    ReporteID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(50) NOT NULL,
    Nombre NVARCHAR(255) NOT NULL,
    Detalle NVARCHAR(255) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Reportes_Activo DEFAULT 1,
    CONSTRAINT PK_Reportes PRIMARY KEY CLUSTERED (ReporteID),
    CONSTRAINT UQ_Reportes_Codigo UNIQUE (Codigo)
);
GO

-- =========================================================================
-- 6. ÍNDICES DE RENDIMIENTO PARA CONSULTAS CONTABLES Y REPORTES
-- =========================================================================

-- Índice para validar rápidamente qué empresas y roles tiene un usuario al iniciar sesión
CREATE NONCLUSTERED INDEX IX_UsuariosEmpresasRoles_Acceso
ON dbo.UsuariosEmpresasRoles (UsuarioID, EmpresaID)
INCLUDE (RolID, SucursalAsignadaID)
WHERE Activo = 1;
GO

-- Índice para generación veloz del Libro Mayor y Balance de Comprobación de Sumas y Saldos
CREATE NONCLUSTERED INDEX IX_MovimientosAsiento_Cuenta_Comprobante
ON dbo.MovimientosAsiento (CuentaID, ComprobanteID)
INCLUDE (DebeMonedaBase, HaberMonedaBase, DebeMonedaExtranjera, HaberMonedaExtranjera, GlosaLinea)
WHERE Activo = 1;
GO

-- Índice para búsqueda de Comprobantes por Empresa y Rango de Fechas (Libro Diario)
CREATE NONCLUSTERED INDEX IX_Comprobantes_Empresa_Fecha
ON dbo.Comprobantes (EmpresaID, Fecha DESC)
INCLUDE (TipoAsientoID, NumeroCorrelativo, Folio, Estado, GlosaGeneral)
WHERE Activo = 1;
GO

-- Índice para generación de Libros de Compras y Ventas IVA (SIAT)
CREATE NONCLUSTERED INDEX IX_DocumentosFiscales_Empresa_Fecha
ON dbo.DocumentosFiscalesAsiento (EmpresaID, TipoRegistro, FechaFactura)
INCLUDE (NITProveedorCliente, RazonSocial, NumeroFactura, ImporteTotal, ImpuestoIVA, EstadoFactura)
WHERE Activo = 1;
GO