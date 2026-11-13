/* =========================================================================
   ARCHIVO 2: CREACIÓN DE LLAVES FORÁNEAS (ALTER TABLE ... ADD CONSTRAINT)
   ARQUITECTURA HIS/EMR MULTI-SEDE - MICROSOFT SQL SERVER (T-SQL)
   ========================================================================= */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =========================================================================
-- 1. LLAVES FORÁNEAS - MÓDULO DE INFRAESTRUCTURA Y MULTI-SEDE
-- =========================================================================

ALTER TABLE dbo.Consultorios
ADD CONSTRAINT FK_Consultorios_Sedes 
    FOREIGN KEY (SedeID) REFERENCES dbo.Sedes(SedeID);
GO

ALTER TABLE dbo.Farmacias
ADD CONSTRAINT FK_Farmacias_Sedes 
    FOREIGN KEY (SedeID) REFERENCES dbo.Sedes(SedeID);
GO

-- =========================================================================
-- 2. LLAVES FORÁNEAS - MÓDULO DEMOGRÁFICO, IDENTIDAD Y PERSONAL
-- =========================================================================

ALTER TABLE dbo.Usuarios
ADD CONSTRAINT FK_Usuarios_Personas 
        FOREIGN KEY (PersonaID) REFERENCES dbo.Personas(PersonaID),
    CONSTRAINT FK_Usuarios_Sedes 
        FOREIGN KEY (SedePrincipalID) REFERENCES dbo.Sedes(SedeID);
GO

ALTER TABLE dbo.UsuariosSedes
ADD CONSTRAINT FK_UsuariosSedes_Usuarios 
        FOREIGN KEY (UsuarioID) REFERENCES dbo.Usuarios(UsuarioID),
    CONSTRAINT FK_UsuariosSedes_Sedes 
        FOREIGN KEY (SedeID) REFERENCES dbo.Sedes(SedeID);
GO

ALTER TABLE dbo.Doctores
ADD CONSTRAINT FK_Doctores_Usuarios 
    FOREIGN KEY (UsuarioID) REFERENCES dbo.Usuarios(UsuarioID);
GO

ALTER TABLE dbo.Contactos
ADD CONSTRAINT FK_Contactos_Personas 
        FOREIGN KEY (PersonaID) REFERENCES dbo.Personas(PersonaID),
    CONSTRAINT FK_Contactos_Usuarios 
        FOREIGN KEY (UsuarioRegistroID) REFERENCES dbo.Usuarios(UsuarioID);
GO

ALTER TABLE dbo.Interpretes
ADD CONSTRAINT FK_Interpretes_Personas 
        FOREIGN KEY (PersonaID) REFERENCES dbo.Personas(PersonaID),
    CONSTRAINT FK_Interpretes_Usuarios 
        FOREIGN KEY (UsuarioRegistroID) REFERENCES dbo.Usuarios(UsuarioID);
GO

ALTER TABLE dbo.Referidos
ADD CONSTRAINT FK_Referidos_Personas 
        FOREIGN KEY (PersonaID) REFERENCES dbo.Personas(PersonaID),
    CONSTRAINT FK_Referidos_Usuarios 
        FOREIGN KEY (UsuarioRegistroID) REFERENCES dbo.Usuarios(UsuarioID);
GO

ALTER TABLE dbo.Pacientes
ADD CONSTRAINT FK_Pacientes_Personas 
        FOREIGN KEY (PersonaID) REFERENCES dbo.Personas(PersonaID),
    CONSTRAINT FK_Pacientes_Sedes 
        FOREIGN KEY (SedeRegistroID) REFERENCES dbo.Sedes(SedeID),
    CONSTRAINT FK_Pacientes_Doctores 
        FOREIGN KEY (DoctorCabeceraID) REFERENCES dbo.Doctores(DoctorID),
    CONSTRAINT FK_Pacientes_Hogares 
        FOREIGN KEY (HogarID) REFERENCES dbo.Hogares(HogarID),
    CONSTRAINT FK_Pacientes_Interpretes 
        FOREIGN KEY (InterpreteID) REFERENCES dbo.Interpretes(InterpreteID),
    CONSTRAINT FK_Pacientes_Referidos 
        FOREIGN KEY (ReferidoID) REFERENCES dbo.Referidos(ReferidoID),
    CONSTRAINT FK_Pacientes_Farmacias 
        FOREIGN KEY (FarmaciaPreferidaID) REFERENCES dbo.Farmacias(FarmaciaID),
    CONSTRAINT FK_Pacientes_Contactos 
        FOREIGN KEY (ContactoEmergenciaID) REFERENCES dbo.Contactos(ContactoID),
    CONSTRAINT FK_Pacientes_Usuarios 
        FOREIGN KEY (CreatedBy) REFERENCES dbo.Usuarios(UsuarioID);
GO

ALTER TABLE dbo.HistoriasClinicas
ADD CONSTRAINT FK_HistoriasClinicas_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID),
    CONSTRAINT FK_HistoriasClinicas_Sedes 
        FOREIGN KEY (SedeAperturaID) REFERENCES dbo.Sedes(SedeID);
GO

-- =========================================================================
-- 3. LLAVES FORÁNEAS - MÓDULO DE ANTECEDENTES MÉDICOS, ALERGIAS Y VACUNAS
-- =========================================================================

ALTER TABLE dbo.AntecedentesPersonales
ADD CONSTRAINT FK_AntPers_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID),
    CONSTRAINT FK_AntPers_Doctores 
        FOREIGN KEY (RegistradoPorDoctorID) REFERENCES dbo.Doctores(DoctorID),
    CONSTRAINT FK_AntPers_Sedes 
        FOREIGN KEY (SedeRegistroID) REFERENCES dbo.Sedes(SedeID);
GO

ALTER TABLE dbo.AntecedentesFamiliares
ADD CONSTRAINT FK_AntFam_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID),
    CONSTRAINT FK_AntFam_Doctores 
        FOREIGN KEY (RegistradoPorDoctorID) REFERENCES dbo.Doctores(DoctorID);
GO

ALTER TABLE dbo.PacienteAlergias
ADD CONSTRAINT FK_Alergias_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID),
    CONSTRAINT FK_Alergias_Doctores 
        FOREIGN KEY (RegistradoPorDoctorID) REFERENCES dbo.Doctores(DoctorID);
GO

ALTER TABLE dbo.PacienteHabitos
ADD CONSTRAINT FK_Habitos_Pacientes 
    FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID);
GO

ALTER TABLE dbo.PacienteInmunizaciones
ADD CONSTRAINT FK_Inm_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID),
    CONSTRAINT FK_Inm_Catalogo 
        FOREIGN KEY (VacunaCatalogoID) REFERENCES dbo.CatalogoVacunas(VacunaCatalogoID),
    CONSTRAINT FK_Inm_Sedes 
        FOREIGN KEY (SedeAplicacionID) REFERENCES dbo.Sedes(SedeID),
    CONSTRAINT FK_Inm_Usuarios 
        FOREIGN KEY (AplicadoPorUsuarioID) REFERENCES dbo.Usuarios(UsuarioID),
    CONSTRAINT FK_Inmunizaciones_Consultas 
        FOREIGN KEY (ConsultaID) REFERENCES dbo.Consultas(ConsultaID);
GO

-- =========================================================================
-- 4. LLAVES FORÁNEAS - MÓDULO DE CITAS Y AGENDA MULTI-SEDE
-- =========================================================================

ALTER TABLE dbo.Citas
ADD CONSTRAINT FK_Citas_Sedes 
        FOREIGN KEY (SedeID) REFERENCES dbo.Sedes(SedeID),
    CONSTRAINT FK_Citas_Consultorios 
        FOREIGN KEY (ConsultorioID) REFERENCES dbo.Consultorios(ConsultorioID),
    CONSTRAINT FK_Citas_Doctores 
        FOREIGN KEY (DoctorID) REFERENCES dbo.Doctores(DoctorID),
    CONSTRAINT FK_Citas_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID),
    CONSTRAINT FK_Citas_Contactos 
        FOREIGN KEY (ContactoID) REFERENCES dbo.Contactos(ContactoID),
    CONSTRAINT FK_Citas_Categorias 
        FOREIGN KEY (CategoriaID) REFERENCES dbo.Categorias(CategoriaID);
GO

-- =========================================================================
-- 5. LLAVES FORÁNEAS - MÓDULO NUCLEAR DE ENCUENTROS CLÍNICOS
-- =========================================================================

ALTER TABLE dbo.Consultas
ADD CONSTRAINT FK_Consultas_HistoriasClinicas 
        FOREIGN KEY (HistoriaClinicaID) REFERENCES dbo.HistoriasClinicas(HistoriaClinicaID),
    CONSTRAINT FK_Consultas_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID),
    CONSTRAINT FK_Consultas_Sedes 
        FOREIGN KEY (SedeID) REFERENCES dbo.Sedes(SedeID),
    CONSTRAINT FK_Consultas_Consultorios 
        FOREIGN KEY (ConsultorioID) REFERENCES dbo.Consultorios(ConsultorioID),
    CONSTRAINT FK_Consultas_Doctores 
        FOREIGN KEY (DoctorID) REFERENCES dbo.Doctores(DoctorID),
    CONSTRAINT FK_Consultas_Citas 
        FOREIGN KEY (CitaID) REFERENCES dbo.Citas(CitaID),
    CONSTRAINT FK_Consultas_Categorias 
        FOREIGN KEY (CategoriaID) REFERENCES dbo.Categorias(CategoriaID),
    CONSTRAINT FK_Consultas_Interpretes 
        FOREIGN KEY (InterpreteID) REFERENCES dbo.Interpretes(InterpreteID),
    CONSTRAINT FK_Consultas_Referidos 
        FOREIGN KEY (ReferidoID) REFERENCES dbo.Referidos(ReferidoID);
GO

ALTER TABLE dbo.ConsultaSignosVitales
ADD CONSTRAINT FK_Signos_Consultas 
        FOREIGN KEY (ConsultaID) REFERENCES dbo.Consultas(ConsultaID),
    CONSTRAINT FK_Signos_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID),
    CONSTRAINT FK_Signos_Usuarios 
        FOREIGN KEY (TomadoPorUsuarioID) REFERENCES dbo.Usuarios(UsuarioID);
GO

-- =========================================================================
-- 6. LLAVES FORÁNEAS - MÓDULOS DE ESPECIALIDADES MÉDICAS
-- =========================================================================

ALTER TABLE dbo.AntecedentesPerinatales
ADD CONSTRAINT FK_Perinatal_Pacientes 
    FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID);
GO

ALTER TABLE dbo.ConsultasPediatria
ADD CONSTRAINT FK_Pediatria_Consultas 
        FOREIGN KEY (ConsultaID) REFERENCES dbo.Consultas(ConsultaID),
    CONSTRAINT FK_Pediatria_Pacientes 
        FOREIGN KEY (PacienteID) REFERENCES dbo.Pacientes(PacienteID);
GO
