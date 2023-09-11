USE master;
GO
IF DB_ID (N'RegistrationDemoDB') IS NOT NULL
DROP DATABASE RegistrationDemoDB;
GO
CREATE DATABASE RegistrationDemoDB;
GO

USE [RegistrationDemoDB]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Registrations]') AND type in (N'U'))
	DROP TABLE			[Registrations]
GO
BEGIN
CREATE TABLE			[Registrations](
	[Id]				UNIQUEIDENTIFIER NOT NULL,
	[Name]				[NVARCHAR](100) NOT NULL,
	[Email]				[NVARCHAR](100) NOT NULL,
	[Phone]				[NVARCHAR](30) NULL,
	[Address]			[VARCHAR](2500) NULL,
	[CreatedOn]			[DATETIME] NOT NULL,	
	[LastUpdatedOn]		[DATETIME] NULL,	
	[Active]			[BIT] NOT NULL,
 CONSTRAINT [PK_Registrations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


END
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Registrations') AND NAME ='IX_Accounting_Registrations_Name')
    DROP INDEX IX_Accounting_Registrations_Name ON [dbo].[Registrations]
CREATE NONCLUSTERED INDEX [IX_Accounting_Registrations_Name] ON [dbo].[Registrations]
(
	[Name] ASC
)
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Registrations') AND NAME ='IX_Accounting_Registrations_Email')
    DROP INDEX IX_Accounting_Registrations_Email ON [dbo].[Registrations]
CREATE NONCLUSTERED INDEX [IX_Accounting_Registrations_Email] ON [dbo].[Registrations]
(
	[Email] ASC
)
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Registrations') AND NAME ='IX_Accounting_Registrations_Phone')
    DROP INDEX IX_Accounting_Registrations_Phone ON [dbo].[Registrations]
CREATE NONCLUSTERED INDEX [IX_Accounting_Registrations_Phone] ON [dbo].[Registrations]
(
	[Phone] ASC
)
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Registrations') AND NAME ='IX_Accounting_Registrations_Address')
    DROP INDEX IX_Accounting_Registrations_Address ON [dbo].[Registrations]
CREATE NONCLUSTERED INDEX [IX_Accounting_Registrations_Address] ON [dbo].[Registrations]
(
	[Address] ASC
)
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Registrations') AND NAME ='IX_Accounting_Registrations_CreatedOn')
    DROP INDEX IX_Accounting_Registrations_CreatedOn ON [dbo].[Registrations]
CREATE NONCLUSTERED INDEX [IX_Accounting_Registrations_CreatedOn] ON [dbo].[Registrations]
(
	[CreatedOn] ASC
)
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Registrations') AND NAME ='IX_Accounting_Registrations_LastUpdatedOn')
    DROP INDEX IX_Accounting_Registrations_LastUpdatedOn ON [dbo].[Registrations]
CREATE NONCLUSTERED INDEX [IX_Accounting_Registrations_LastUpdatedOn] ON [dbo].[Registrations]
(
	[LastUpdatedOn] ASC
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Users]') AND type in (N'U'))
	DROP TABLE			[Users]
GO
BEGIN
CREATE TABLE			[Users](
	[Id]				UNIQUEIDENTIFIER NOT NULL,	
	[Username]			[NVARCHAR](100) NOT NULL,
	[Salt]				[NVARCHAR](128) NOT NULL,
	[HashPassword]		[BINARY](20) NOT NULL,	
	[CreatedOn]			[DATETIME] NOT NULL,	
	[LastUpdatedOn]		[DATETIME] NULL,
	[Active]			[BIT] NOT NULL,
	[IsAdmin]			[BIT] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


END
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Users') AND NAME ='IX_Accounting_Users_Username')
    DROP INDEX IX_Accounting_Users_Username ON [dbo].[Users]
CREATE NONCLUSTERED INDEX [IX_Accounting_Users_Username] ON [dbo].[Users]
(
	[Username] ASC
)
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Users') AND NAME ='IX_Accounting_Users_HashPassword')
    DROP INDEX IX_Accounting_Users_HashPassword ON [dbo].[Users]
CREATE NONCLUSTERED INDEX [IX_Accounting_Users_HashPassword] ON [dbo].[Users]
(
	[HashPassword] ASC
)
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Users') AND NAME ='IX_Accounting_Users_CreatedOn')
    DROP INDEX IX_Accounting_Users_CreatedOn ON [dbo].[Users]
CREATE NONCLUSTERED INDEX [IX_Accounting_Users_CreatedOn] ON [dbo].[Users]
(
	[CreatedOn] ASC
)
GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('Accounting.Users') AND NAME ='IX_Accounting_Users_LastUpdatedOn')
    DROP INDEX IX_Accounting_Users_LastUpdatedOn ON [dbo].[Users]
CREATE NONCLUSTERED INDEX [IX_Accounting_Users_LastUpdatedOn] ON [dbo].[Users]
(
	[LastUpdatedOn] ASC
)
GO

ALTER TABLE [Users] ADD FOREIGN KEY (Id) REFERENCES Registrations(Id);
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[ValidateUser]', 'P') IS NOT NULL
DROP PROC [ValidateUser]
GO
CREATE PROCEDURE [ValidateUser] 
	@userName	NVARCHAR(50), 
	@password	NVARCHAR(50),
	@success	INT OUTPUT

AS

	SET NOCOUNT ON;

    DECLARE @salt					NVARCHAR(128)
	DECLARE @HashedPasswordAndSalt	BINARY(20)

	SELECT	@salt = [Salt]
	FROM	[dbo].[Users]
	WHERE	LOWER([UserName]) = LOWER(@userName) AND [Active] = 1

	SELECT @hashedPasswordAndSalt = HASHBYTES('SHA1', @password + @salt)
		
	IF(	SELECT	COUNT(*)
		FROM	[Users]
		WHERE	LOWER([UserName]) = LOWER(@userName) AND [HashPassword] = @hashedPasswordAndSalt AND [Active] = 1) = 1
		SELECT @success		= 1
	ELSE
		SELECT @success		= 0

GO


--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--IF OBJECT_ID('[AddEditRegistration]', 'P') IS NOT NULL
--DROP PROC [AddEditRegistration]
--GO
--CREATE PROCEDURE [AddEditRegistration]	
--	@id			UNIQUEIDENTIFIER,
--	@name		NVARCHAR(100),
--	@email		NVARCHAR(100),
--	@phone		NVARCHAR(30),
--	@address	NVARCHAR(2500),
--	@userName	NVARCHAR(100),
--	@salt		NVARCHAR(100),
--	@password	NVARCHAR(100),
--	@active		BIT
--AS
--BEGIN	
	 
--	DECLARE @dt		DATETIME = GETDATE()	
	
--	MERGE [Registrations] AS TARGET    
--	USING (SELECT @id AS Id, @name AS Name, @email AS Email, @phone AS Phone, @address AS [Address], @dt AS CreatedOn, @active AS Active) 
--	AS SOURCE (Id, Name, Email, Phone, [Address], CreatedOn, Active)  
--	ON (TARGET.Id = @id)
--	WHEN MATCHED THEN   
--		UPDATE	
--		SET		Name = @name, Email = @email,Phone = @phone, [Address] = @address, LastUpdatedOn = @dt, Active = @active
--	WHEN NOT MATCHED THEN  
--	INSERT (Id, Name, Phone, Email, [Address], CreatedOn, Active)  
--	VALUES (SOURCE.Id, SOURCE.Name, SOURCE.Phone, SOURCE.Email, SOURCE.[Address], SOURCE.CreatedOn, SOURCE.Active);

--	IF @active = 0
--		UPDATE [Users] SET Active = 0 WHERE Id = @id
--	ELSE
--		BEGIN
--			MERGE [Users] AS TARGET  
--			USING (SELECT @id AS Id, @userName AS Username, @salt AS [Salt], CONVERT(VARBINARY(MAX), @password) AS [Password], @dt AS CreatedOn, @active AS Active) 
--			AS SOURCE (Id, Username, [Salt], [Password], CreatedOn, Active)  
--			ON (TARGET.Id = @id)
--			WHEN MATCHED THEN   
--				UPDATE	
--				SET		[Salt] = @salt, [HashPassword] = CONVERT(VARBINARY(MAX), @password), LastUpdatedOn = @dt, Active = @active
--			WHEN NOT MATCHED THEN  
--			INSERT (Id, [Salt], [HashPassword], CreatedOn, Active)  
--			VALUES (SOURCE.Id, SOURCE.[Salt], SOURCE.[Password], SOURCE.CreatedOn, SOURCE.Active);
--		END		
--END

--GO