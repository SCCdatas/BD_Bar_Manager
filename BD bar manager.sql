-- Crear la base de datos
CREATE DATABASE WebBarDB;


-- Usar la base de datos recién creada
USE WebBarDB;


-- Tabla principal que representa cada empresa (bar)
CREATE TABLE Bares (
    IdBar INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único del bar
    Nombre NVARCHAR(100) NOT NULL,        -- Nombre del bar
    Direccion NVARCHAR(200) NOT NULL,     -- Dirección física
    Telefono NVARCHAR(20) NOT NULL,       -- Teléfono de contacto
    FechaRegistro DATETIME DEFAULT GETDATE(), -- Fecha en que se registró
    Estado BIT DEFAULT 1                  -- 1 = Activo, 0 = Inactivo
);

-- Tabla que almacena los usuarios del sistema (dueños, meseros, cajeros)
CREATE TABLE Usuarios (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único del usuario
    IdBar INT NOT NULL,                       -- Relación con el bar
    Nombre NVARCHAR(100) NOT NULL,            -- Nombre del usuario
    Correo NVARCHAR(100) UNIQUE NOT NULL,     -- Correo único para login
    PasswordHash NVARCHAR(255) NOT NULL,      -- Contraseña encriptada
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

-- Tabla que representa las mesas físicas del bar
CREATE TABLE Mesas (
    IdMesa INT IDENTITY(1,1) PRIMARY KEY,
    IdBar INT NOT NULL,
    Numero INT NOT NULL,                      
    Estado NVARCHAR(20) DEFAULT 'Libre' 
        CHECK (Estado IN ('Libre','Ocupada')), 
    Capacidad INT NOT NULL CHECK (Capacidad > 0),

    CONSTRAINT UQ_Mesa_Numero UNIQUE (IdBar, Numero),
        -- Evita que existan dos mesas con el mismo número en el mismo bar

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
        -- Columna calculada automáticamente

    CONSTRAINT FK_Detalle_Orden FOREIGN KEY (IdOrden)
        REFERENCES Ordenes(IdOrden)
        ON DELETE CASCADE,

    CONSTRAINT FK_Detalle_Producto FOREIGN KEY (IdProducto)
        REFERENCES Productos(IdProducto)
);

