/* =========================================================================
   ARCHIVO 1: CREACIÓN DE TABLAS, PRIMARY KEYS, UNIQUE Y CHECK CONSTRAINTS
   ARQUITECTURA HIS/EMR MULTI-SEDE - MICROSOFT SQL SERVER (T-SQL)
   ========================================================================= */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =========================================================================
-- 1. MÓDULO DE INFRAESTRUCTURA Y MULTI-SEDE (MULTI-FACILITY)
-- =========================================================================

CREATE TABLE dbo.Sedes (
    SedeID INT IDENTITY(1,1) NOT NULL,
    UUID UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Sedes_UUID DEFAULT NEWSEQUENTIALID(),
    CodigoSede VARCHAR(16) NOT NULL,
    Nombre NVARCHAR(128) NOT NULL,
    TipoSede VARCHAR(32) NOT NULL, -- 'Consultorio', 'Policonsultorio', 'Clinica', 'Hospital'
    NIT VARCHAR(32) NULL,
    Pais NVARCHAR(64) NOT NULL CONSTRAINT DF_Sedes_Pais DEFAULT N'Bolivia',
    Departamento NVARCHAR(64) NOT NULL,
    Ciudad NVARCHAR(64) NOT NULL,
    Direccion NVARCHAR(256) NOT NULL,
    Telefono VARCHAR(32) NULL,
    ZonaHoraria VARCHAR(64) NOT NULL CONSTRAINT DF_Sedes_TZ DEFAULT 'SA Western Standard Time',
    -- Auditoría y Control
    Activo BIT NOT NULL CONSTRAINT DF_Sedes_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Sedes_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Sedes_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NULL,
    UpdatedBy INT NULL,
    CONSTRAINT PK_Sedes PRIMARY KEY CLUSTERED (SedeID),
    CONSTRAINT UQ_Sedes_Codigo UNIQUE (CodigoSede),
    CONSTRAINT CK_Sedes_Tipo CHECK (TipoSede IN ('Consultorio', 'Policonsultorio', 'Clinica', 'Hospital'))
);
GO

CREATE TABLE dbo.Consultorios (
    ConsultorioID INT IDENTITY(1,1) NOT NULL,
    SedeID INT NOT NULL,
    Codigo VARCHAR(16) NOT NULL,
    Nombre NVARCHAR(64) NOT NULL,
    Piso VARCHAR(16) NULL,
    TipoArea VARCHAR(32) NOT NULL CONSTRAINT DF_Consultorios_Tipo DEFAULT 'Consulta Externa', -- 'Consulta Externa', 'Emergencias', 'Vacunatorio', 'Ecografia'
    Activo BIT NOT NULL CONSTRAINT DF_Consultorios_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Consultorios_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Consultorios_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Consultorios PRIMARY KEY CLUSTERED (ConsultorioID),
    CONSTRAINT UQ_Consultorios_Sede_Codigo UNIQUE (SedeID, Codigo)
);
GO

CREATE TABLE dbo.Farmacias (
    FarmaciaID INT IDENTITY(1,1) NOT NULL,
    SedeID INT NULL, -- NULL si es farmacia externa convenida; NOT NULL si es farmacia intrahospitalaria
    Nombre NVARCHAR(128) NOT NULL,
    EsInterna BIT NOT NULL CONSTRAINT DF_Farmacias_EsInterna DEFAULT 1,
    Direccion NVARCHAR(256) NULL,
    Telefono VARCHAR(32) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Farmacias_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Farmacias_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Farmacias PRIMARY KEY CLUSTERED (FarmaciaID)
);
GO

CREATE TABLE dbo.Categorias (
    CategoriaID INT IDENTITY(1,1) NOT NULL,
    Nombre NVARCHAR(64) NOT NULL,
    Descripcion NVARCHAR(256) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Categorias_Activo DEFAULT 1,
    RazonEstado NVARCHAR(128) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Categorias_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Categorias_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Categorias PRIMARY KEY CLUSTERED (CategoriaID)
);
GO

-- =========================================================================
-- 2. MÓDULO DEMOGRÁFICO, IDENTIDAD Y PERSONAL (PERSONAS / ROLES)
-- =========================================================================

CREATE TABLE dbo.Hogares (
    HogarID INT IDENTITY(1,1) NOT NULL,
    GoogleMapsURL NVARCHAR(256) NULL,
    Pais NVARCHAR(64) NOT NULL CONSTRAINT DF_Hogares_Pais DEFAULT N'Bolivia',
    Departamento NVARCHAR(64) NULL,
    Provincia NVARCHAR(64) NULL,
    Ciudad NVARCHAR(64) NULL,
    Zona NVARCHAR(64) NULL,
    Calle NVARCHAR(128) NULL,
    NumPuerta VARCHAR(16) NULL,
    NumPiso VARCHAR(16) NULL,
    NumApartamento VARCHAR(16) NULL,
    NumTelefono VARCHAR(20) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Hogares_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Hogares_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Hogares_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Hogares PRIMARY KEY CLUSTERED (HogarID)
);
GO

CREATE TABLE dbo.Personas (
    PersonaID INT IDENTITY(1,1) NOT NULL,
    UUID UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Personas_UUID DEFAULT NEWSEQUENTIALID(),
    PrimerNombre NVARCHAR(64) NOT NULL,
    SegundoNombre NVARCHAR(64) NULL,
    ApellidoPaterno NVARCHAR(64) NOT NULL,
    ApellidoMaterno NVARCHAR(64) NULL,
    DOB DATE NOT NULL, -- Fecha de nacimiento
    DOD DATE NULL,     -- Fecha de defunción
    SexoBiologico CHAR(1) NOT NULL, -- 'M', 'F', 'I' (Intersexual)
    IdentidadGenero NVARCHAR(32) NULL,
    PaisNacimiento NVARCHAR(64) NULL,
    NumCI VARCHAR(20) NULL,
    OrigenCI VARCHAR(16) NULL,
    ExtensionCI VARCHAR(16) NULL,
    NumSeguroSocial VARCHAR(32) NULL,
    EstadoCivil VARCHAR(20) NULL,
    Ocupacion NVARCHAR(128) NULL,
    NivelEducativo NVARCHAR(64) NULL,
    Migrante BIT NOT NULL CONSTRAINT DF_Personas_Migrante DEFAULT 0,
    RequiereInterprete BIT NOT NULL CONSTRAINT DF_Personas_Interprete DEFAULT 0,
    TratamientoPersonal NVARCHAR(16) NULL, -- Sr., Sra., Dr., etc.
    ComunicacionPreferida VARCHAR(20) NULL,
    IdiomaPrincipal NVARCHAR(64) NULL,
    IdiomaSecundario NVARCHAR(64) NULL,
    NumCelular VARCHAR(20) NULL,
    CorreoElectronico NVARCHAR(128) NULL,
    CorreoPrivado NVARCHAR(128) NULL,
    Religion NVARCHAR(64) NULL,
    Etnia NVARCHAR(64) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Personas_Activo DEFAULT 1,
    RazonEstado NVARCHAR(128) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Personas_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Personas_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Personas PRIMARY KEY CLUSTERED (PersonaID),
    CONSTRAINT CK_Personas_Sexo CHECK (SexoBiologico IN ('M', 'F', 'I')),
    CONSTRAINT CK_Personas_FechasVida CHECK (DOD IS NULL OR DOD >= DOB)
);
GO

CREATE TABLE dbo.Usuarios (
    UsuarioID INT IDENTITY(1,1) NOT NULL,
    UUID UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Usuarios_UUID DEFAULT NEWSEQUENTIALID(),
    PersonaID INT NOT NULL,
    SedePrincipalID INT NOT NULL, -- Sede base del usuario
    NombreUsuario VARCHAR(64) NOT NULL,
    PasswordHash VARBINARY(64) NOT NULL,
    PasswordSalt VARBINARY(32) NOT NULL,
    NivelAcceso VARCHAR(32) NOT NULL, -- 'SuperAdmin', 'AdminSede', 'Medico', 'Enfermeria', 'Recepcion'
    FuenteUsuario VARCHAR(64) NOT NULL CONSTRAINT DF_Usuarios_Fuente DEFAULT 'Interno',
    Titulo NVARCHAR(64) NULL,
    InformacionAdicional NVARCHAR(128) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Usuarios_Activo DEFAULT 1,
    RazonEstado NVARCHAR(128) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Usuarios_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Usuarios_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Usuarios PRIMARY KEY CLUSTERED (UsuarioID),
    CONSTRAINT UQ_Usuarios_NombreUsuario UNIQUE (NombreUsuario)
);
GO

-- Tabla puente para permitir que un Usuario/Médico opere en múltiples sedes
CREATE TABLE dbo.UsuariosSedes (
    UsuarioID INT NOT NULL,
    SedeID INT NOT NULL,
    RolEnSede VARCHAR(32) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_UsuariosSedes_Activo DEFAULT 1,
    FechaAsignacion DATETIME2(0) NOT NULL CONSTRAINT DF_UsuariosSedes_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UsuariosSedes PRIMARY KEY CLUSTERED (UsuarioID, SedeID)
);
GO

CREATE TABLE dbo.Doctores (
    DoctorID INT IDENTITY(1,1) NOT NULL,
    UUID UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Doctores_UUID DEFAULT NEWSEQUENTIALID(),
    UsuarioID INT NOT NULL,
    EspecialidadPrincipal NVARCHAR(64) NOT NULL,
    SubEspecialidad NVARCHAR(64) NULL,
    MatriculaMinisterial VARCHAR(32) NOT NULL,
    MatriculaColegioMedico VARCHAR(32) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Doctores_Activo DEFAULT 1,
    RazonEstado NVARCHAR(128) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Doctores_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Doctores_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Doctores PRIMARY KEY CLUSTERED (DoctorID),
    CONSTRAINT UQ_Doctores_Matricula UNIQUE (MatriculaMinisterial)
);
GO

CREATE TABLE dbo.Contactos (
    ContactoID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL,
    UsuarioRegistroID INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Contactos_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Contactos_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Contactos PRIMARY KEY CLUSTERED (ContactoID)
);
GO

CREATE TABLE dbo.Interpretes (
    InterpreteID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL,
    IdiomasDominados NVARCHAR(128) NOT NULL,
    UsuarioRegistroID INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Interpretes_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Interpretes_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Interpretes PRIMARY KEY CLUSTERED (InterpreteID)
);
GO

CREATE TABLE dbo.Referidos (
    ReferidoID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL,
    InstitucionOrigen NVARCHAR(128) NULL,
    UsuarioRegistroID INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Referidos_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Referidos_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Referidos PRIMARY KEY CLUSTERED (ReferidoID)
);
GO

CREATE TABLE dbo.Pacientes (
    PacienteID INT IDENTITY(1,1) NOT NULL,
    UUID UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Pacientes_UUID DEFAULT NEWSEQUENTIALID(),
    PubID VARCHAR(32) NOT NULL, -- Número de Historia Clínica (NHC) legible o código público único
    PersonaID INT NOT NULL,
    SedeRegistroID INT NOT NULL, -- Sede donde se abrió el expediente por primera vez
    DoctorCabeceraID INT NULL,
    HogarID INT NULL,
    InterpreteID INT NULL,
    ReferidoID INT NULL,
    FarmaciaPreferidaID INT NULL,
    ContactoEmergenciaID INT NULL,
    RelacionContacto NVARCHAR(64) NULL,
    GrupoSanguineo VARCHAR(3) NULL, -- 'A', 'B', 'AB', 'O'
    FactorRH CHAR(1) NULL,          -- '+', '-'
    NotaFactura NVARCHAR(128) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Pacientes_Activo DEFAULT 1,
    RazonEstado NVARCHAR(128) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Pacientes_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Pacientes_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NULL,
    CONSTRAINT PK_Pacientes PRIMARY KEY CLUSTERED (PacienteID),
    CONSTRAINT UQ_Pacientes_Persona UNIQUE (PersonaID),
    CONSTRAINT UQ_Pacientes_PubID UNIQUE (PubID),
    CONSTRAINT CK_Pacientes_GrupoSang CHECK (GrupoSanguineo IS NULL OR GrupoSanguineo IN ('A', 'B', 'AB', 'O')),
    CONSTRAINT CK_Pacientes_FactorRH CHECK (FactorRH IS NULL OR FactorRH IN ('+', '-'))
);
GO

-- Expediente Maestro (1 por Paciente, contenedor administrativo de su Historia Clínica)
CREATE TABLE dbo.HistoriasClinicas (
    HistoriaClinicaID INT IDENTITY(1,1) NOT NULL,
    PacienteID INT NOT NULL,
    SedeAperturaID INT NOT NULL,
    NumeroExpediente VARCHAR(32) NOT NULL,
    FechaApertura DATETIME2(0) NOT NULL CONSTRAINT DF_HC_FechaApertura DEFAULT SYSUTCDATETIME(),
    ObservacionesGenerales NVARCHAR(512) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_HC_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_HC_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_HC_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_HistoriasClinicas PRIMARY KEY CLUSTERED (HistoriaClinicaID),
    CONSTRAINT UQ_HistoriasClinicas_Paciente UNIQUE (PacienteID),
    CONSTRAINT UQ_HistoriasClinicas_NumExpediente UNIQUE (NumeroExpediente)
);
GO

-- =========================================================================
-- 3. MÓDULO NORMALIZADO DE ANTECEDENTES MÉDICOS, ALERGIAS Y VACUNAS
-- =========================================================================

-- 3.1. Antecedentes Patológicos Personales, Quirúrgicos y Traumáticos
CREATE TABLE dbo.AntecedentesPersonales (
    AntecedentePersonalID INT IDENTITY(1,1) NOT NULL,
    PacienteID INT NOT NULL,
    TipoAntecedente VARCHAR(32) NOT NULL, -- 'Patologico', 'Quirurgico', 'Traumatico', 'Hospitalizacion', 'Transfusional'
    CodigoCIE10 VARCHAR(10) NULL,
    NombreCondicion NVARCHAR(256) NOT NULL,
    FechaDiagnosticoOEvento DATE NULL,
    EstadoCondicion VARCHAR(20) NOT NULL CONSTRAINT DF_AntPers_Estado DEFAULT 'Activo', -- 'Activo', 'En Remision', 'Resuelto'
    TratamientoActual NVARCHAR(256) NULL,
    Complicaciones NVARCHAR(256) NULL,
    Observaciones NVARCHAR(512) NULL,
    RegistradoPorDoctorID INT NULL,
    SedeRegistroID INT NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_AntPers_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_AntPers_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_AntPers_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AntecedentesPersonales PRIMARY KEY CLUSTERED (AntecedentePersonalID),
    CONSTRAINT CK_AntPers_Tipo CHECK (TipoAntecedente IN ('Patologico', 'Quirurgico', 'Traumatico', 'Hospitalizacion', 'Transfusional'))
);
GO

-- 3.2. Antecedentes Heredofamiliares
CREATE TABLE dbo.AntecedentesFamiliares (
    AntecedenteFamiliarID INT IDENTITY(1,1) NOT NULL,
    PacienteID INT NOT NULL,
    Parentesco VARCHAR(32) NOT NULL, -- 'Padre', 'Madre', 'Hermano/a', 'Abuelo/a Paterno', 'Abuelo/a Materno', 'Tio/a'
    CodigoCIE10 VARCHAR(10) NULL,
    DiagnosticoCondicion NVARCHAR(256) NOT NULL,
    EdadAproxDiagnostico TINYINT NULL,
    FallecidoPorCausa BIT NOT NULL CONSTRAINT DF_AntFam_Fallecido DEFAULT 0,
    Observaciones NVARCHAR(512) NULL,
    RegistradoPorDoctorID INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_AntFam_Activo DEFAULT 1,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_AntFam_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AntecedentesFamiliares PRIMARY KEY CLUSTERED (AntecedenteFamiliarID)
);
GO

-- 3.3. Alergias y Reacciones Adversas
CREATE TABLE dbo.PacienteAlergias (
    AlergiaID INT IDENTITY(1,1) NOT NULL,
    PacienteID INT NOT NULL,
    TipoAlergeno VARCHAR(32) NOT NULL, -- 'Medicamento', 'Alimento', 'Ambiental', 'Latex', 'Contraste', 'Otro'
    SustanciaAlergeno NVARCHAR(128) NOT NULL,
    CodigoRxNorm VARCHAR(32) NULL,
    Severidad VARCHAR(20) NOT NULL, -- 'Leve', 'Moderada', 'Severa', 'Anafilaxia'
    TipoReaccion NVARCHAR(256) NOT NULL, -- Ej. 'Urticaria', 'Broncoespasmo', 'Shock anafiláctico'
    FechaDeteccion DATE NULL,
    EstadoAlergia VARCHAR(16) NOT NULL CONSTRAINT DF_Alergia_Estado DEFAULT 'Activa', -- 'Activa', 'Inactiva', 'Descartada'
    RegistradoPorDoctorID INT NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Alergia_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Alergia_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PacienteAlergias PRIMARY KEY CLUSTERED (AlergiaID),
    CONSTRAINT CK_Alergias_Severidad CHECK (Severidad IN ('Leve', 'Moderada', 'Severa', 'Anafilaxia'))
);
GO

-- 3.4. Hábitos Tóxicos y Estilo de Vida (No Patológicos)
CREATE TABLE dbo.PacienteHabitos (
    HabitoID INT IDENTITY(1,1) NOT NULL,
    PacienteID INT NOT NULL,
    CategoriaHabito VARCHAR(32) NOT NULL, -- 'Tabaco', 'Alcohol', 'SustanciasPsicoactivas', 'ActividadFisica', 'Sueno', 'Dieta'
    ConsumeOPractica BIT NOT NULL,
    Frecuencia NVARCHAR(64) NULL, -- Ej. 'Diario', 'Social', '3 veces por semana'
    CantidadDetalle NVARCHAR(128) NULL, -- Ej. '5 cigarrillos/día (Índice paquetes/año: 10)'
    FechaInicio DATE NULL,
    FechaAbandono DATE NULL,
    Observaciones NVARCHAR(256) NULL,
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Habitos_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PacienteHabitos PRIMARY KEY CLUSTERED (HabitoID)
);
GO

-- 3.5. Catálogo y Registro de Vacunas (Inmunizaciones)
CREATE TABLE dbo.CatalogoVacunas (
    VacunaCatalogoID INT IDENTITY(1,1) NOT NULL,
    CodigoCVX VARCHAR(16) NULL, -- Estándar internacional de vacunas
    NombreVacuna NVARCHAR(128) NOT NULL,
    EnfermedadPreviene NVARCHAR(256) NOT NULL,
    TotalDosisEsquema TINYINT NOT NULL CONSTRAINT DF_CatVac_Dosis DEFAULT 1,
    ViaAdministracionDefecto VARCHAR(32) NULL, -- 'IM', 'SC', 'Oral', 'ID'
    Activo BIT NOT NULL CONSTRAINT DF_CatVac_Activo DEFAULT 1,
    CONSTRAINT PK_CatalogoVacunas PRIMARY KEY CLUSTERED (VacunaCatalogoID)
);
GO

CREATE TABLE dbo.PacienteInmunizaciones (
    InmunizacionID INT IDENTITY(1,1) NOT NULL,
    PacienteID INT NOT NULL,
    VacunaCatalogoID INT NOT NULL,
    SedeAplicacionID INT NULL, -- NULL si fue aplicada fuera de la red y solo se transcribe el carnet
    ConsultaID BIGINT NULL,    -- Ajustado a BIGINT para coincidir exactamente con Consultas(ConsultaID)
    NumeroDosis VARCHAR(16) NOT NULL, -- '1ra Dosis', '2da Dosis', 'Refuerzo 1', 'Dosis Unica'
    FechaAplicacion DATETIME2(0) NOT NULL,
    NumeroLote VARCHAR(64) NOT NULL,
    Fabricante NVARCHAR(128) NULL,
    FechaVencimientoLote DATE NULL,
    SitioAnatomico VARCHAR(64) NULL, -- 'Deltoides Izquierdo', 'Vasto Lateral Derecho', etc.
    ViaAdministracion VARCHAR(32) NOT NULL, -- 'Intramuscular', 'Subcutanea', 'Oral', 'Intradermica'
    DosisCantidad VARCHAR(32) NULL, -- Ej. '0.5 ml'
    AplicadoPorUsuarioID INT NULL,
    EsTranscripcionExterna BIT NOT NULL CONSTRAINT DF_Inm_Externa DEFAULT 0,
    ReaccionAdversaReportada NVARCHAR(256) NULL, -- ESAVI
    FechaProximaDosis DATE NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Inm_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PacienteInmunizaciones PRIMARY KEY CLUSTERED (InmunizacionID)
);
GO

-- =========================================================================
-- 4. MÓDULO DE CITAS Y AGENDA MULTI-SEDE
-- =========================================================================

CREATE TABLE dbo.Citas (
    CitaID INT IDENTITY(1,1) NOT NULL,
    SedeID INT NOT NULL,
    ConsultorioID INT NOT NULL,
    DoctorID INT NOT NULL,
    PacienteID INT NOT NULL,
    ContactoID INT NULL,
    CategoriaID INT NULL,
    FechaInicio DATETIME2(0) NOT NULL,
    FechaFin DATETIME2(0) NOT NULL,
    EstadoCita VARCHAR(24) NOT NULL CONSTRAINT DF_Citas_Estado DEFAULT 'Programada', -- 'Programada', 'Confirmada', 'EnSala', 'EnAtencion', 'Completada', 'Cancelada', 'NoAsistio'
    Prioridad VARCHAR(16) NOT NULL CONSTRAINT DF_Citas_Prioridad DEFAULT 'Normal', -- 'Baja', 'Normal', 'Alta', 'Urgente'
    Motivo NVARCHAR(256) NOT NULL,
    SintomasReportados NVARCHAR(512) NULL,
    EnfermedadActualReportada NVARCHAR(512) NULL,
    IdiomaPreferido NVARCHAR(64) NULL,
    RecordatorioEnviado BIT NOT NULL CONSTRAINT DF_Citas_Recordatorio DEFAULT 0,
    ContadorReprogramaciones TINYINT NOT NULL CONSTRAINT DF_Citas_Contador DEFAULT 0,
    RecurrenciaRegla VARCHAR(128) NULL, -- Estándar iCal RRULE si aplica
    CelularContacto VARCHAR(20) NULL,
    CostoEstimado DECIMAL(10, 2) NULL,
    CostoFinal DECIMAL(10, 2) NULL,
    NotasAdicionales NVARCHAR(512) NULL,
    RazonCancelacionOEstado NVARCHAR(128) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Citas_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Citas_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NULL,
    UpdatedBy INT NULL,
    CONSTRAINT PK_Citas PRIMARY KEY CLUSTERED (CitaID),
    CONSTRAINT CK_Citas_Fechas CHECK (FechaFin > FechaInicio),
    CONSTRAINT CK_Citas_Estado CHECK (EstadoCita IN ('Programada', 'Confirmada', 'EnSala', 'EnAtencion', 'Completada', 'Cancelada', 'NoAsistio'))
);
GO

-- =========================================================================
-- 5. MÓDULO NUCLEAR DE ENCUENTROS CLÍNICOS (CONSULTAS GENÉRICAS Y ESPECIALIZADAS)
-- =========================================================================

-- 5.1. Tabla Base de Encuentro (Aplicable a cualquier especialidad)
CREATE TABLE dbo.Consultas (
    ConsultaID BIGINT IDENTITY(1,1) NOT NULL, -- BIGINT para soportar millones de encuentros a nivel hospitalario
    UUID UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Consultas_UUID DEFAULT NEWSEQUENTIALID(),
    HistoriaClinicaID INT NOT NULL,
    PacienteID INT NOT NULL,
    SedeID INT NOT NULL,
    ConsultorioID INT NOT NULL,
    DoctorID INT NOT NULL,
    CitaID INT NULL,
    CategoriaID INT NULL,
    InterpreteID INT NULL,
    ReferidoID INT NULL,
    NumeroConsulta VARCHAR(32) NOT NULL,
    TipoEncuentro VARCHAR(32) NOT NULL, -- 'ConsultaExterna', 'Control', 'Emergencia', 'Interconsulta', 'Telemedicina', 'ProcedimientoAmbulatorio'
    EspecialidadAtencion VARCHAR(64) NOT NULL, -- 'MedicinaGeneral', 'Pediatria', 'GinecoObstetricia', 'Cardiologia', etc.
    FechaHoraInicio DATETIME2(0) NOT NULL CONSTRAINT DF_Consultas_Inicio DEFAULT SYSUTCDATETIME(),
    FechaHoraFin DATETIME2(0) NULL,
    FechaHoraInicioCondicion DATETIME2(0) NULL,
    -- Estructura Clínica SOAP (Subjetivo, Objetivo, Análisis, Plan)
    MotivoConsulta NVARCHAR(512) NOT NULL,
    HistoriaEnfermedadActual NVARCHAR(MAX) NULL, -- Anamnesis / Subjetivo
    ExamenFisicoGeneral NVARCHAR(MAX) NULL,      -- Objetivo
    DiagnosticoPresuntivoTexto NVARCHAR(512) NULL,
    DiagnosticoDefinitivoTexto NVARCHAR(512) NULL,
    CodigoCIE10Principal VARCHAR(10) NULL,
    CodigoCIE10Secundario VARCHAR(10) NULL,
    PlanTratamiento NVARCHAR(MAX) NULL,          -- Plan terapéutico y estudios
    DisposicionAlta VARCHAR(64) NULL,            -- 'Domicilio', 'SeguimientoAmbulatorio', 'Internacion', 'ReferenciaTercerNivel'
    ConfidencialidadRestringida BIT NOT NULL CONSTRAINT DF_Consultas_Confidencial DEFAULT 0,
    Observaciones NVARCHAR(1024) NULL,
    EstadoConsulta VARCHAR(20) NOT NULL CONSTRAINT DF_Consultas_Estado DEFAULT 'Abierta', -- 'Abierta', 'FirmadaCerrada', 'Anulada'
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Consultas_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Consultas_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NULL,
    CONSTRAINT PK_Consultas PRIMARY KEY CLUSTERED (ConsultaID),
    CONSTRAINT CK_Consultas_Estado CHECK (EstadoConsulta IN ('Abierta', 'FirmadaCerrada', 'Anulada'))
);
GO

-- 5.2. Signos Vitales y Somatometría por Encuentro
CREATE TABLE dbo.ConsultaSignosVitales (
    SignoVitalID BIGINT IDENTITY(1,1) NOT NULL,
    ConsultaID BIGINT NOT NULL,
    PacienteID INT NOT NULL,
    FechaHoraToma DATETIME2(0) NOT NULL CONSTRAINT DF_Signos_Fecha DEFAULT SYSUTCDATETIME(),
    PresionSistolica SMALLINT NULL,        -- mmHg (ej. 120)
    PresionDiastolica SMALLINT NULL,       -- mmHg (ej. 80)
    FrecuenciaCardiaca SMALLINT NULL,      -- lpm
    FrecuenciaRespiratoria SMALLINT NULL,  -- rpm
    TemperaturaC DECIMAL(4, 2) NULL,       -- °C (ej. 36.65)
    SaturacionOxigeno TINYINT NULL,        -- % SpO2 (ej. 94)
    FraccionInspiradaO2 TINYINT NULL,      -- % FiO2 (21% ambiente)
    PesoKg DECIMAL(6, 3) NULL,             -- Kg con precisión de gramos para neonatos/pediatría (ej. 3.450)
    TallaCm DECIMAL(5, 2) NULL,            -- cm (ej. 165.50)
    IMC AS (CASE WHEN TallaCm > 0 THEN CONVERT(DECIMAL(5,2), PesoKg / POWER(TallaCm / 100.0, 2)) ELSE NULL END) PERSISTED,
    PerimetroCefalicoCm DECIMAL(4, 2) NULL,
    PerimetroAbdominalCm DECIMAL(5, 2) NULL,
    GlucemiaCapilarMgDl SMALLINT NULL,
    EscalaDolorEVA TINYINT NULL,           -- 0 a 10
    TomadoPorUsuarioID INT NULL,
    CONSTRAINT PK_ConsultaSignosVitales PRIMARY KEY CLUSTERED (SignoVitalID),
    CONSTRAINT CK_Signos_PA CHECK ((PresionSistolica IS NULL AND PresionDiastolica IS NULL) OR (PresionSistolica BETWEEN 30 AND 300 AND PresionDiastolica BETWEEN 15 AND 200)),
    CONSTRAINT CK_Signos_SpO2 CHECK (SaturacionOxigeno IS NULL OR SaturacionOxigeno BETWEEN 20 AND 100),
    CONSTRAINT CK_Signos_EVA CHECK (EscalaDolorEVA IS NULL OR EscalaDolorEVA BETWEEN 0 AND 10)
);
GO

-- =========================================================================
-- 6. MÓDULOS DE ESPECIALIDADES MÉDICAS (EXTENSIÓN MODULAR)
-- =========================================================================

-- 6.1. Especialidad: PEDIATRÍA Y NEONATOLOGÍA
-- A) Antecedentes Perinatales (1:1 con Paciente)
CREATE TABLE dbo.AntecedentesPerinatales (
    PacienteID INT NOT NULL,
    EdadGestacionalSemanas TINYINT NULL,
    ViaParto VARCHAR(24) NULL, -- 'Eutocico', 'CesareaElectiva', 'CesareaEmergencia', 'Instrumental'
    PesoNacimientoGramos SMALLINT NULL,
    TallaNacimientoCm DECIMAL(4, 2) NULL,
    PerimetroCefalicoNacimientoCm DECIMAL(4, 2) NULL,
    ApgarMinuto1 TINYINT NULL,
    ApgarMinuto5 TINYINT NULL,
    ApgarMinuto10 TINYINT NULL,
    RequirioReanimacion BIT NOT NULL CONSTRAINT DF_Perinatal_Reanim DEFAULT 0,
    TamizajeMetabolicoNeonatal NVARCHAR(128) NULL,
    TamizajeAuditivoNeonatal NVARCHAR(128) NULL,
    ComplicacionesNeonatales NVARCHAR(512) NULL,
    UpdatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Perinatal_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AntecedentesPerinatales PRIMARY KEY CLUSTERED (PacienteID),
    CONSTRAINT CK_Perinatal_Apgar CHECK (
        (ApgarMinuto1 IS NULL OR ApgarMinuto1 BETWEEN 0 AND 10) AND
        (ApgarMinuto5 IS NULL OR ApgarMinuto5 BETWEEN 0 AND 10) AND
        (ApgarMinuto10 IS NULL OR ApgarMinuto10 BETWEEN 0 AND 10)
    )
);
GO

-- B) Evaluación Pediátrica por Encuentro (1:1 con Consultas)
CREATE TABLE dbo.ConsultasPediatria (
    ConsultaID BIGINT NOT NULL,
    PacienteID INT NOT NULL,
    EdadMesesCumplidos SMALLINT NOT NULL,
    TipoAlimentacion VARCHAR(32) NOT NULL, -- 'LactanciaMaternaExclusiva', 'Formula', 'Mixta', 'Complementaria', 'DietaFamiliar'
    PercentilPesoEdad DECIMAL(5, 2) NULL,
    PercentilTallaEdad DECIMAL(5, 2) NULL,
    PercentilIMCEdad DECIMAL(5, 2) NULL,
    PercentilPerimetroCefalico DECIMAL(5, 2) NULL,
    DesarrolloPsicomotorAcorde BIT NOT NULL CONSTRAINT DF_Ped_Desarrollo DEFAULT 1,
    HitosDesarrolloObservaciones NVARCHAR(512) NULL,
    EstadoFontanelas NVARCHAR(128) NULL,
    EstadioTanner VARCHAR(16) NULL,
    ObservacionesPediatricas NVARCHAR(1024) NULL,
    CONSTRAINT PK_ConsultasPediatria PRIMARY KEY CLUSTERED (ConsultaID)
);
GO
