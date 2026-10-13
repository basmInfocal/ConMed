-- LLAVES FORÁNEAS PARA SQL SERVER
ALTER TABLE Usuarios
ADD CONSTRAINT FK_Usuarios_Personas
FOREIGN KEY (PersonaID)
REFERENCES Personas(PersonaID);

GO

ALTER TABLE Contactos
ADD CONSTRAINT FK_Contactos_Personas
FOREIGN KEY (PersonaID)
REFERENCES Personas(PersonaID);

GO

ALTER TABLE Contactos
ADD CONSTRAINT FK_Contactos_Usuarios
FOREIGN KEY (UsuarioID)
REFERENCES Usuarios(UsuarioID);
  
GO

ALTER TABLE Interpretes
ADD CONSTRAINT FK_Interpretes_Personas
FOREIGN KEY (PersonaID)
REFERENCES Personas(PersonaID);
  
GO

ALTER TABLE Interpretes
ADD CONSTRAINT FK_Interpretes_Usuarios
FOREIGN KEY (UsuarioID)
REFERENCES Usuarios(UsuarioID);
  
GO

ALTER TABLE Referidos
ADD CONSTRAINT FK_Referidos_Personas
FOREIGN KEY (PersonaID)
REFERENCES Personas(PersonaID);
  
GO

ALTER TABLE Referidos
ADD CONSTRAINT FK_Referidos_Usuarios
FOREIGN KEY (UsuarioID)
REFERENCES Usuarios(UsuarioID);
  
GO

ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Doctores
FOREIGN KEY (DoctorID)
REFERENCES Doctores(DoctorID);
  
GO

ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Doctores
FOREIGN KEY (DoctorID)
REFERENCES Doctores(DoctorID);
  
GO

ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Personas
FOREIGN KEY (PersonaID)
REFERENCES Personas(PersonaID);
  
GO

ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Hogares
FOREIGN KEY (HogarID)
REFERENCES Hogares(HogarID);
  
GO

ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Interpretes
FOREIGN KEY (InterpreteID)
REFERENCES Interpretes(InterpreteID);
  
GO

ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Referidos
FOREIGN KEY (RefereidoID)
REFERENCES Referidos(RefereidoID);
  
GO

/*
ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Farmacias
FOREIGN KEY (FarmaciaID)
REFERENCES Farmacias(FarmaciaID);
  
GO

*/

ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Contactos
FOREIGN KEY (ContactoID)
REFERENCES Contactos(ContactoID);
  
GO

ALTER TABLE Pacientes
ADD CONSTRAINT FK_Pacientes_Usuarios
FOREIGN KEY (UsuarioID)
REFERENCES Usuarios(UsuarioID);
  
GO

ALTER TABLE Doctores
ADD CONSTRAINT FK_Doctores_Usuarios
FOREIGN KEY (UsuarioID)
REFERENCES Usuarios(UsuarioID);
  
GO

ALTER TABLE HistoriasClinicas
ADD CONSTRAINT FK_HistoriasClinicas_Pacientes
FOREIGN KEY (PacienteID)
REFERENCES Pacientes(PacienteID);
  
GO

ALTER TABLE HistoriasClinicas
ADD CONSTRAINT FK_HistoriasClinicas_Contactos
FOREIGN KEY (ContactoID)
REFERENCES Contactos(ContactoID);

GO

ALTER TABLE HistoriasClinicas
ADD CONSTRAINT FK_HistoriasClinicas_Referidos
FOREIGN KEY (ReferidoID)
REFERENCES Referidos(ReferidoID);

GO

ALTER TABLE HistoriasClinicas
ADD CONSTRAINT FK_HistoriasClinicas_Consultorios
FOREIGN KEY (ConsultorioID)
REFERENCES Consultorios(ConsultorioID);
  
GO

ALTER TABLE Consultas
ADD CONSTRAINT FK_Consultas_Categorias
FOREIGN KEY (CategoriaID)
REFERENCES Categorias(CategoriaID);
  
GO

ALTER TABLE Consultas
ADD CONSTRAINT FK_Consultas_Consultorios
FOREIGN KEY (ConsultorioID)
REFERENCES Consultorios(ConsultorioID);
  
GO

ALTER TABLE Consultas
ADD CONSTRAINT FK_Consultas_Citas
FOREIGN KEY (CitaID)
REFERENCES Citas(CitaID);
  
GO

ALTER TABLE Consultas
ADD CONSTRAINT FK_Consultas_Doctores
FOREIGN KEY (DoctorID)
REFERENCES Doctores(DoctorID);
  
GO

ALTER TABLE Consultas
ADD CONSTRAINT FK_Consultas_HistoriasClinicas
FOREIGN KEY (HistoriaClinicaID)
REFERENCES HistoriasClinicas(HistoriaClinicaID);
  
GO

/*
ALTER TABLE Consultas
ADD CONSTRAINT FK_Consultas_Prescripciones
FOREIGN KEY (PrescripcionID)
REFERENCES Prescripciones(PrescripcionID);
  
GO

*/

ALTER TABLE Consultas
ADD CONSTRAINT FK_Consultas_Interpretes
FOREIGN KEY (InterpreteID)
REFERENCES Interpretes(InterpreteID);
  
GO

ALTER TABLE Consultas
ADD CONSTRAINT FK_Consultas_Interpretes
FOREIGN KEY (InterpreteID)
REFERENCES Interpretes(InterpreteID);
  
GO

ALTER TABLE Citas
ADD CONSTRAINT FK_Citas_Doctores
FOREIGN KEY (DoctorID)
REFERENCES Doctores(DoctorID);
  
GO

ALTER TABLE Citas
ADD CONSTRAINT FK_Citas_Pacientes
FOREIGN KEY (PacienteID)
REFERENCES Pacientes(PacienteID);
  
GO

ALTER TABLE Citas
ADD CONSTRAINT FK_Citas_Consultorios
FOREIGN KEY (ConsultorioID)
REFERENCES Consultorios(ConsultorioID);
  
GO

ALTER TABLE Citas
ADD CONSTRAINT FK_Citas_Contactos
FOREIGN KEY (ContactoID)
REFERENCES Contactos(ContactoID);
  
GO
