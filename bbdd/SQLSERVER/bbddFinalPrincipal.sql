/* =========================================================================
   ARCHIVO 0: CREACIÓN DE LA BASE DE DATOS (CREATE DATABASE)
   ARQUITECTURA HIS/EMR MULTI-SEDE - MICROSOFT SQL SERVER (T-SQL)
   ========================================================================= */

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'bbddMedicoBolivia')
BEGIN
    CREATE DATABASE [bbddMedicoBolivia]
    COLLATE Modern_Spanish_CI_AS;
END
GO

ALTER DATABASE [bbddMedicoBolivia] SET RECOVERY FULL;
ALTER DATABASE [bbddMedicoBolivia] SET READ_COMMITTED_SNAPSHOT ON;
GO

USE [bbddMedicoBolivia];
GO