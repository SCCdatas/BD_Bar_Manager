
CREATE DATABASE WebBarDB;


-- Usar la base de datos reci�n creada
USE WebBarDB;


-- Tabla principal que representa cada empresa (bar)
CREATE TABLE Bares (
    IdBar INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador �nico del bar
    Nombre NVARCHAR(100) NOT NULL,        -- Nombre del bar
    Direccion NVARCHAR(200) NOT NULL,     -- Direcci�n f�sica
    Telefono NVARCHAR(20) NOT NULL,       -- Tel�fono de contacto
    FechaRegistro DATETIME DEFAULT GETDATE(), -- Fecha en que se registr�
    Estado BIT DEFAULT 1                  -- 1 = Activo, 0 = Inactivo
);

-- Tabla que almacena los usuarios del sistema (due�os, meseros, cajeros)
CREATE TABLE Usuarios (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador �nico del usuario
    IdBar INT NOT NULL,                       -- Relaci�n con el bar
    Nombre NVARCHAR(100) NOT NULL,            -- Nombre del usuario
    Correo NVARCHAR(100) UNIQUE NOT NULL,     -- Correo �nico para login
    PasswordHash NVARCHAR(255) NOT NULL,      -- Contrase�a encriptada
    Rol NVARCHAR(50) NOT NULL CHECK (Rol IN ('Admin','Mesero','Cajero')), 
                                                -- Rol del usuario
    Activo BIT DEFAULT 1,                     -- Estado del usuario
    CONSTRAINT FK_Usuarios_Bares FOREIGN KEY (IdBar)
        REFERENCES Bares(IdBar)
        ON DELETE CASCADE                     -- Si se elimina el bar, elimina sus usuarios
);

-- Tabla que almacena los productos de cada bar
CREATE TABLE Productos (
    IdProducto INT IDENTITY(1,1) PRIMARY KEY, 
    IdBar INT NOT NULL,                       
    Nombre NVARCHAR(100) NOT NULL,            
    Descripcion NVARCHAR(200),                
    Precio DECIMAL(10,2) NOT NULL CHECK (Precio >= 0), 
    Stock INT DEFAULT 0 CHECK (Stock >= 0),   
    Activo BIT DEFAULT 1,                     

    CONSTRAINT FK_Productos_Bares FOREIGN KEY (IdBar)
        REFERENCES Bares(IdBar)
        ON DELETE CASCADE
);

-- Tabla que representa las mesas f�sicas del bar
CREATE TABLE Mesas (
    IdMesa INT IDENTITY(1,1) PRIMARY KEY,
    IdBar INT NOT NULL,
    Numero INT NOT NULL,                      
    Estado NVARCHAR(20) DEFAULT 'Libre' 
        CHECK (Estado IN ('Libre','Ocupada')), 
    Capacidad INT NOT NULL CHECK (Capacidad > 0),

    CONSTRAINT UQ_Mesa_Numero UNIQUE (IdBar, Numero),
        -- Evita que existan dos mesas con el mismo n�mero en el mismo bar

    CONSTRAINT FK_Mesas_Bares FOREIGN KEY (IdBar)
        REFERENCES Bares(IdBar)
        ON DELETE CASCADE
);


-- Tabla que almacena cada venta realizada
CREATE TABLE Ordenes (
    IdOrden INT IDENTITY(1,1) PRIMARY KEY,
    IdBar INT NOT NULL,
    IdMesa INT NOT NULL,
    IdMesero INT NOT NULL, -- Usuario con rol Mesero
    FechaHora DATETIME DEFAULT GETDATE(),
    Estado NVARCHAR(20) DEFAULT 'Abierta'
        CHECK (Estado IN ('Abierta','Cerrada','Cancelada')),
    Total DECIMAL(10,2) DEFAULT 0 CHECK (Total >= 0),

    CONSTRAINT FK_Ordenes_Bares FOREIGN KEY (IdBar)
        REFERENCES Bares(IdBar),

    CONSTRAINT FK_Ordenes_Mesas FOREIGN KEY (IdMesa)
        REFERENCES Mesas(IdMesa),

    CONSTRAINT FK_Ordenes_Usuarios FOREIGN KEY (IdMesero)
        REFERENCES Usuarios(IdUsuario)
);

-- Tabla intermedia que guarda los productos vendidos en cada orden
CREATE TABLE DetalleOrden (
    IdDetalle INT IDENTITY(1,1) PRIMARY KEY,
    IdOrden INT NOT NULL,
    IdProducto INT NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL CHECK (PrecioUnitario >= 0),
    Subtotal AS (Cantidad * PrecioUnitario) PERSISTED,
        -- Columna calculada autom�ticamente

    CONSTRAINT FK_Detalle_Orden FOREIGN KEY (IdOrden)
        REFERENCES Ordenes(IdOrden)
        ON DELETE CASCADE,

    CONSTRAINT FK_Detalle_Producto FOREIGN KEY (IdProducto)
        REFERENCES Productos(IdProducto)
);


INSERT INTO Bares (Nombre, Direccion, Telefono)
VALUES 
('Bar La Noche', 'Calle 10 #45-23', '3001234567'),
('El Rinc�n Paisa', 'Carrera 50 #30-10', '3019876543'),
('Bar Central', 'Av. 80 #20-15', '3024567890');


INSERT INTO Usuarios (IdBar, Nombre, Correo, PasswordHash, Rol)
VALUES
(1, 'Carlos Admin', 'admin1@bar.com', 'hash123', 'Admin'),
(1, 'Juan Mesero', 'mesero1@bar.com', 'hash123', 'Mesero'),
(1, 'Ana Cajera', 'cajero1@bar.com', 'hash123', 'Cajero'),

(2, 'Luis Admin', 'admin2@bar.com', 'hash123', 'Admin'),
(2, 'Pedro Mesero', 'mesero2@bar.com', 'hash123', 'Mesero'),

(3, 'Maria Admin', 'admin3@bar.com', 'hash123', 'Admin'),
(3, 'Sofia Mesera', 'mesero3@bar.com', 'hash123', 'Mesero');


INSERT INTO Productos (IdBar, Nombre, Descripcion, Precio, Stock)
VALUES
(1, 'Cerveza', 'Cerveza fr�a', 5000, 100),
(1, 'Ron', 'Ron a�ejo', 8000, 50),

(2, 'Whisky', 'Whisky importado', 12000, 30),
(2, 'Gaseosa', 'Bebida gaseosa', 3000, 80),

(3, 'Tequila', 'Tequila premium', 15000, 20),
(3, 'Agua', 'Botella de agua', 2000, 100);

INSERT INTO Mesas (IdBar, Numero, Estado, Capacidad)
VALUES
(1, 1, 'Libre', 4),
(1, 2, 'Ocupada', 6),

(2, 1, 'Libre', 4),
(2, 2, 'Libre', 2),

(3, 1, 'Ocupada', 5),
(3, 2, 'Libre', 3);

INSERT INTO Ordenes (IdBar, IdMesa, IdMesero, Estado, Total)
VALUES
(1, 1, 2, 'Abierta', 10000),
(1, 2, 2, 'Cerrada', 16000),
(2, 3, 5, 'Abierta', 12000),
(3, 5, 7, 'Cerrada', 17000);

INSERT INTO DetalleOrden (IdOrden, IdProducto, Cantidad, PrecioUnitario)
VALUES
(1, 1, 2, 5000),
(2, 2, 2, 8000),
(3, 3, 1, 12000),
(4, 5, 1, 15000),
(4, 6, 1, 2000);





SELECT * FROM Usuarios;

SELECT * FROM Productos;

SELECT * FROM Mesas;

SELECT * FROM Ordenes;

SELECT * FROM DetalleOrden;

SELECT AVG (SUBTOTAL) AS PROM_SUBTO FROM DetalleOrden;-- Promedio de subtotales en las �rdenes

-- ¿Cuánto ha vendido cada bar? (solo los que superan 20,000 en ventas)
SELECT 
    b.Nombre AS NombreBar,
    SUM(o.Total) AS TotalVentas
FROM Ordenes o
INNER JOIN Bares b ON o.IdBar = b.IdBar
WHERE o.Estado = 'Cerrada'
GROUP BY b.Nombre
HAVING SUM(o.Total) > 20000;



-- Cual es el consumo promedio por orden en cada bar?
SELECT 
    b.Nombre AS NombreBar,
    AVG(o.Total) AS PromedioConsumo
FROM Ordenes o
INNER JOIN Bares b ON o.IdBar = b.IdBar
WHERE o.Estado = 'Cerrada'
GROUP BY b.Nombre;


-- Cuantas ordenes ha atendido cada mesero?
SELECT 
    u.Nombre AS NombreMesero,
    COUNT(o.IdOrden) AS TotalOrdenes
FROM Ordenes o
INNER JOIN Usuarios u ON o.IdMesero = u.IdUsuario
WHERE u.Rol = 'Mesero'
GROUP BY u.Nombre
HAVING COUNT(o.IdOrden) > 0;



-- Cuales son los productos mas vendidos?
SELECT 
    p.Nombre AS Producto,
    SUM(d.Cantidad) AS CantidadVendida
FROM DetalleOrden d
INNER JOIN Productos p ON d.IdProducto = p.IdProducto
GROUP BY p.Nombre
HAVING SUM(d.Cantidad) >= 1
ORDER BY CantidadVendida DESC;


-- Cuanto se vendio en un rango de fechas especifico?
SELECT 
    b.Nombre AS NombreBar,
    SUM(o.Total) AS TotalVentas
FROM Ordenes o
INNER JOIN Bares b ON o.IdBar = b.IdBar
WHERE o.FechaHora BETWEEN '2026-04-01' AND '2026-04-30'
AND o.Estado = 'Cerrada'
GROUP BY b.Nombre;
