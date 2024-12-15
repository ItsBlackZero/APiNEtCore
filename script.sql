USE [CLINICA_SAN_JUAN]
GO
/****** Object:  Table [dbo].[CARROS]    Script Date: 14/12/2024 22:01:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CARROS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[modelo] [varchar](50) NOT NULL,
	[anio] [int] NOT NULL,
	[color] [varchar](20) NULL,
	[precio] [decimal](10, 2) NULL,
	[disponible] [bit] NULL,
	[marca_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MARCA]    Script Date: 14/12/2024 22:01:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MARCA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CARROS] ADD  DEFAULT ((1)) FOR [disponible]
GO
ALTER TABLE [dbo].[CARROS]  WITH CHECK ADD  CONSTRAINT [FK_MARCA] FOREIGN KEY([marca_id])
REFERENCES [dbo].[MARCA] ([id])
GO
ALTER TABLE [dbo].[CARROS] CHECK CONSTRAINT [FK_MARCA]
GO
/****** Object:  StoredProcedure [dbo].[GetCarro]    Script Date: 14/12/2024 22:01:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetCarro]
    -- Parámetros para el procedimiento almacenado
    @itransaccion AS VARCHAR(50),
    @iXML AS XML = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables locales
    DECLARE @respuesta AS VARCHAR(10);
    DECLARE @leyenda AS VARCHAR(50);
    DECLARE @anio AS INT;
    DECLARE @marca AS NVARCHAR(50);

    BEGIN TRY
        -- Lógica según el valor de @itransaccion
        IF (@itransaccion = 'CONSULTAR_CARRO_BY_PRECIO_40_50')
        BEGIN
            SELECT 
                carros.modelo,
                carros.anio,
                carros.color,
                carros.precio,
                carros.disponible,
                marca.nombre AS marca
            FROM 
                carros
            JOIN 
                marca ON carros.marca_id = marca.id
            WHERE 
                carros.precio >= 20000 AND carros.precio <= 45000;

            SET @respuesta = 'OK';
            SET @leyenda = 'Consulta Exitosa';
        END

        IF (@itransaccion = 'CONSULTAR_CARRO_BY_ANIO_FABRICACION')
        BEGIN
            -- Obtener el año desde el XML
            SET @anio = (SELECT @iXML.value('(/Carro/anio)[1]', 'INT'));

            SELECT 
                carros.modelo,
                carros.anio,
                carros.color,
                carros.precio,
                carros.disponible,
                marca.nombre AS marca
            FROM 
                carros
            JOIN 
                marca ON carros.marca_id = marca.id
            WHERE 
                carros.anio >= @anio;

            SET @respuesta = 'OK';
            SET @leyenda = 'Consulta Exitosa';
        END

        IF (@itransaccion = 'CONSULTAR_CARRO_BY_MARCA')
        BEGIN
            -- Obtener la marca desde el XML
            SET @marca = (SELECT @iXML.value('(/Carro/marca/Nombre)[1]', 'NVARCHAR(50)'));

            SELECT 
                carros.modelo,
                carros.anio,
                carros.color,
                carros.precio,
                carros.disponible,
                marca.nombre AS marca
            FROM 
                carros
            JOIN 
                marca ON carros.marca_id = marca.id
            WHERE 
                marca.nombre = @marca;

            SET @respuesta = 'OK';
            SET @leyenda = 'Consulta Exitosa';
        END
    END TRY

    BEGIN CATCH
        -- Manejo de errores
        SET @respuesta = 'ERROR';
        SET @leyenda = 'Error al ejecutar el comando: ' + ERROR_MESSAGE();
    END CATCH

    -- Retorno de la respuesta
    SELECT @respuesta AS respuesta, @leyenda AS leyenda;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_carro_entre_20_40]    Script Date: 14/12/2024 22:01:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_obtener_carro_entre_20_40]
as 
begin 
	select * from carros where precio >= 20000 and precio <= 45000
end
GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_carro_fabricacion_parametro]    Script Date: 14/12/2024 22:01:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_obtener_carro_fabricacion_parametro]
@Anio INT
as 
begin 
	SELECT 
        C.id AS CarroID,
        C.modelo,
        C.anio,
        C.color,
        C.precio,
        C.disponible,
        M.nombre AS Marca
    FROM CARROS C
    INNER JOIN MARCA M ON C.marca_id = M.id
    WHERE C.anio >= @Anio;
end
GO
