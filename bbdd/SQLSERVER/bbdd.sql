CREATE TABLE
  Categoria (
    CategoriaID INT IDENTITY (1, 1) PRIMARY KEY,
    Nombre VARCHAR(64),
    Descripcion VARCHAR(256),
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Personas (
    PersonaID INT IDENTITY (1, 1) PRIMARY KEY,
    UUID UNIQUEIDENTIFIER DEFAULT NEWID (),
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    DOB DATE, -- Fecha de nacimiento
    DOD DATE, -- Fecha de fallecimiento
    Pais VARCHAR(64),
    NumCI VARCHAR(16),
    OrigenCI VARCHAR(16),
    ExtensionCI VARCHAR(16),
    Ocupacion VARCHAR(128),
    Migrante BIT,
    RequiereInterprete BIT,
    TratamientoPersonal VARCHAR(16),
    PrimerNombre VARCHAR(64),
    SegundoNombre VARCHAR(64),
    ApellidoPaterno VARCHAR(64),
    ApellidoMaterno VARCHAR(64),
    ComunicacionPreferida VARCHAR(16),
    IdiomaPrincipal VARCHAR(64),
    IdiomaSecundario VARCHAR(64),
    NumCelular VARCHAR(16),
    CorreoElectronico VARCHAR(128),
    CorreoPrivado VARCHAR(128),
    Genero VARCHAR(16),
    EstadoCivil VARCHAR(16),
    Religion VARCHAR(64),
    Etnia VARCHAR(64),
    NumSeguroSocial VARCHAR(32),
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Hogares (
    HogarID INT IDENTITY (1, 1) PRIMARY KEY,
    GoogleMaps VARCHAR(256),
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    Pais VARCHAR(64),
    Departamento VARCHAR(64),
    Provincia VARCHAR(64),
    Ciudad VARCHAR(64),
    Zona VARCHAR(64),
    Calle VARCHAR(128),
    NumPuerta VARCHAR(16),
    NumPiso VARCHAR(16),
    NumApartamento VARCHAR(16),
    NumTelefono VARCHAR(16),
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Usuarios (
    UsuarioID INT IDENTITY (1, 1) PRIMARY KEY,
    UUID UNIQUEIDENTIFIER DEFAULT NEWID (),
    PersonaID INT,
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    NivelAcceso VARCHAR(16),
    NombreUsuario VARCHAR(64),
    Contrasena VARCHAR(128),
    InformacionAdicional VARCHAR(128),
    FuenteUsuario VARCHAR(128), -- Fuente de información del usuario (por ejemplo, "LDAP", "Base de datos interna", etc.)
    Titulo VARCHAR(64),
    Especialidad VARCHAR(64),
    CorreoElectronico VARCHAR(128),
    Enlace VARCHAR(128),
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Contactos (
    ContactoID INT IDENTITY (1, 1) PRIMARY KEY,
    PersonaID INT,
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    UsuarioID INT,
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Interpretes (
    InterpreteID INT IDENTITY (1, 1) PRIMARY KEY,
    PersonaID INT,
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    UsuarioID INT,
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Referidos (
    ReferidoID INT IDENTITY (1, 1) PRIMARY KEY,
    PersonaID INT,
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    UsuarioID INT,
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Pacientes (
    PacienteID INT IDENTITY (1, 1) PRIMARY KEY,
    UUID UNIQUEIDENTIFIER DEFAULT NEWID (),
    PubID UNIQUEIDENTIFIER DEFAULT NEWID (), -- Identificador público para compartir con otros sistemas
    DoctorID INT,
    PersonaID INT,
    HogarID INT,
    InterpreteID INT,
    ReferidoID INT,
    FarmaciaID INT,
    ContactoID INT,
    RelacionContacto VARCHAR(64), -- Relación del contacto con el paciente (por ejemplo, "Padre", "Hermano", "Amigo", etc.)
    NotaFactura VARCHAR(128),
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    UsuarioID INT,
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Doctores (
    DoctorID INT IDENTITY (1, 1) PRIMARY KEY,
    UUID UNIQUEIDENTIFIER DEFAULT NEWID (),
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    UsuarioID INT,
    Especialidad VARCHAR(64),
    NumeroLicencia VARCHAR(32),
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  HistoriasClinicas (
    HistoriaClinicaID INT IDENTITY (1, 1) PRIMARY KEY,
    DoctorID INT,
    AtencionID INT,
    PacienteID INT,
    ContactoID INT,
    ReferidoID INT,
    ConsultorioID INT,
    Fecha DATETIME,
    Hora TIME,
    -- Datos de la historia clínica
    Vacunas VARCHAR(256),
    Inmunizaciones VARCHAR(256),
    Alergias VARCHAR(256),
    Medicamentos VARCHAR(256),
    AntecedentesFamiliares VARCHAR(256),
    AntecedentesPersonales VARCHAR(256),
    AntecedentesQuirurgicos VARCHAR(256),
    OtrosAntecedentes VARCHAR(256),
    -- Datos de la evaluación médica
    PresionArterial VARCHAR(16),
    FrecuenciaCardiaca VARCHAR(16),
    FrecuenciaRespiratoria VARCHAR(16),
    Temperatura VARCHAR(16),
    Peso VARCHAR(16),
    Talla VARCHAR(16),
    IMC VARCHAR(16),
    -- Datos Finales
    DiagnosticoPresuntivo VARCHAR(256),
    DiagnosticoDefinitivo VARCHAR(256),
    PlanTratamiento VARCHAR(256),
    Observaciones VARCHAR(256),
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Consultas (
    ConsultaID INT IDENTITY (1, 1) PRIMARY KEY,
    UUID UNIQUEIDENTIFIER DEFAULT NEWID (),
    ConsultorioID INT,
    PacienteID INT,
    CitaID INT,
    DoctorID INT,
    HistoriaClinicaID INT,
    PrescripcionID INT,
    InterpreteID INT,
    Fecha DATETIME,
    Hora TIME,
    RazonPaciente VARCHAR(256),
    NumeroConsulta VARCHAR(16),
    MotivoConsulta VARCHAR(256),
    FechaHoraInicioCondicion DATETIME,
    Disposicion VARCHAR(256),
    TipoEncuentroClinico VARCHAR(256),
    Confidencialidad BIT,
    Observaciones VARCHAR(256),
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Prescripciones (
    PrescripcionID INT IDENTITY (1, 1) PRIMARY KEY,
    UUID UNIQUEIDENTIFIER DEFAULT NEWID (),
    PacienteID INT,
    UsuarioID INT,
    DoctorID INT,
    FarmaciaID INT,
    ConsultorioID INT,
    FechaInicioTratamiento DATETIME,
    Medicamento VARCHAR(256),
    MedicamentoID INT,
    RxNorm VARCHAR(256),
    FormaFarmaceutica VARCHAR(256),
    Dosis VARCHAR(256),
    Cantidad VARCHAR(256),
    Concentracion VARCHAR(256),
    ViaAdministracion VARCHAR(256),
    FrecuenciaAdministracion VARCHAR(256),
    SustitucionPermisible BIT,
    SustitucionAutorizada BIT,
    SustitucionNombre VARCHAR(256),
    Resurtido BIT,
    CantidadResurtido VARCHAR(256),
    FechaPrescripcionEfectiva DATETIME,
    Instrucciones VARCHAR(256),
    Observaciones VARCHAR(256),
    Medicacion VARCHAR(256),
    NotaAdicional VARCHAR(256),
    EstadoPrescripcion BIT,
    FuentePrescripcion VARCHAR(256), -- Fuente de la prescripción (por ejemplo, "Médico", "Farmacia", "Sistema de salud", etc.)
    DoctorPrescripcion VARCHAR(256), -- Nombre del doctor que emitió la prescripción, en caso de que sea externo
    FotoPrescripcion VARBINARY(MAX), -- Foto de la prescripción, si aplica
    CalidadPrescripcion VARCHAR(256), -- Evaluación de la calidad de la prescripción (por ejemplo, "Alta", "Media", "Baja")
    FechaInicioPrescripcion DATETIME,
    FechaFinPrescripcion DATETIME,
    DiagnosticoRelacionado VARCHAR(256), -- Diagnóstico relacionado con la prescripción
    IndicacionesEspeciales VARCHAR(256), -- Indicaciones especiales para la prescripción
    FechaRegistro DATETIME DEFAULT GETDATE (),
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    Estado BIT,
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );

CREATE TABLE
  Citas (
    CitaID INT IDENTITY (1, 1) PRIMARY KEY,
    DoctorID INT,
    PacienteID INT,
    ConsultorioID INT,
    ContactoID INT,
    Motivo VARCHAR(256),
    Recordatorio BIT, -- Indica si se envió un recordatorio de cita
    Prioridad VARCHAR(16), -- Por ejemplo: "Alta", "Media", "Baja"
    Lenguaje VARCHAR(64), -- Idioma preferido para la cita
    Categoria VARCHAR(64), -- Por ejemplo: "Consulta general", "Seguimiento", "Emergencia"
    Agrupacion VARCHAR(64), -- Por ejemplo: "Grupo familiar", "Grupo de pacientes con la misma condición", etc.
    Asunto VARCHAR(256), -- Asunto de la cita
    Descripcion VARCHAR(512), -- Descripción detallada de la cita
    Comentario VARCHAR(512), -- Comentarios adicionales sobre la cita
    Contador INT, -- Contador de veces que se ha reprogramado la cita
    Tema VARCHAR(256), -- Tema de la cita
    FechaInicio DATETIME,
    FechaFin DATETIME,
    Duracion INT, -- Duración de la cita en segundos
    Recurrencia VARCHAR(64), -- Por ejemplo: "Diaria", "Semanal", "Mensual", etc.
    ExcepcionRecurrencia VARCHAR(256), -- Excepciones a la recurrencia, si aplica
    FrecuenciaRepeticion VARCHAR(64), -- Por ejemplo: "Cada 2 semanas", "Cada mes", etc.
    FechaProgramada DATETIME,
    HoraProgramada TIME,
    Evento VARCHAR(256), -- Evento asociado a la cita, si aplica
    CelularContacto VARCHAR(16), -- Número de celular del contacto para la cita
    CostoEstimado DECIMAL(10, 2), -- Costo estimado de la cita
    CostoFinal DECIMAL(10, 2), -- Costo final de la cita
    -- Datos que da el paciente
    Sintomas VARCHAR(512),
    Enfermermedad VARCHAR(512),
    -- Datos Técnicos
    NotasAdicionales VARCHAR(256),
    FechaRegistro DATETIME DEFAULT GETDATE (),
    AutorRegistro VARCHAR(64), -- Usuario que registró la cita
    FechaActualizacion DATETIME DEFAULT GETDATE (),
    AutorActualizacion VARCHAR(64), -- Usuario que actualizó la cita
    Estado BIT, -- Por ejemplo: "Programada", "Cancelada", "Completada"
    RazonEstado VARCHAR(128),
    FechaEstado DATETIME DEFAULT GETDATE (),
  );