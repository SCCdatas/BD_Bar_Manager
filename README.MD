# 📘 README – Base de Datos WebBarDB

## 1. Descripción técnica de la BD
- **Motor usado:** Microsoft SQL Server  
- **Cantidad de tablas:** 6 tablas principales  
  - `Bares`  
  - `Usuarios`  
  - `Productos`  
  - `Mesas`  
  - `Ordenes`  
  - `DetalleOrden`  

La base de datos está diseñada para gestionar la operación de bares, incluyendo administración de usuarios, productos, mesas y órdenes de venta. Además, se implementan **procedimientos almacenados** para registrar productos y calcular métricas de ventas.

---

## 2. Diccionario de datos básico

| Tabla        | Campo              | Tipo de dato        | Descripción |
|--------------|-------------------|---------------------|-------------|
| **Bares**    | IdBar             | INT (PK)            | Identificador único del bar |
|              | Nombre            | NVARCHAR(100)       | Nombre del bar |
|              | Dirección         | NVARCHAR(200)       | Dirección física |
|              | Teléfono          | NVARCHAR(20)        | Teléfono de contacto |
|              | FechaRegistro     | DATETIME            | Fecha de registro |
|              | Estado            | BIT                 | Activo/Inactivo |
| **Usuarios** | IdUsuario         | INT (PK)            | Identificador único del usuario |
|              | IdBar             | INT (FK)            | Relación con el bar |
|              | Nombre            | NVARCHAR(100)       | Nombre del usuario |
|              | Correo            | NVARCHAR(100)       | Correo único |
|              | PasswordHash      | NVARCHAR(255)       | Contraseña encriptada |
|              | Rol               | NVARCHAR(50)        | Admin / Mesero / Cajero |
|              | Activo            | BIT                 | Estado del usuario |
| **Productos**| IdProducto        | INT (PK)            | Identificador único del producto |
|              | IdBar             | INT (FK)            | Relación con el bar |
|              | Nombre            | NVARCHAR(100)       | Nombre del producto |
|              | Descripción       | NVARCHAR(200)       | Detalle del producto |
|              | Precio            | DECIMAL(10,2)       | Precio unitario |
|              | Stock             | INT                 | Cantidad disponible |
|              | Activo            | BIT                 | Estado del producto |
| **Mesas**    | IdMesa            | INT (PK)            | Identificador único de la mesa |
|              | IdBar             | INT (FK)            | Relación con el bar |
|              | Número            | INT                 | Número de mesa |
|              | Estado            | NVARCHAR(20)        | Libre / Ocupada |
|              | Capacidad         | INT                 | Número de personas |
| **Ordenes**  | IdOrden           | INT (PK)            | Identificador único de la orden |
|              | IdBar             | INT (FK)            | Relación con el bar |
|              | IdMesa            | INT (FK)            | Relación con la mesa |
|              | IdMesero          | INT (FK)            | Usuario mesero |
|              | FechaHora         | DATETIME            | Fecha y hora |
|              | Estado            | NVARCHAR(20)        | Abierta / Cerrada / Cancelada |
|              | Total             | DECIMAL(10,2)       | Total de la orden |
| **DetalleOrden** | IdDetalle     | INT (PK)            | Identificador único del detalle |
|              | IdOrden           | INT (FK)            | Relación con la orden |
|              | IdProducto        | INT (FK)            | Relación con el producto |
|              | Cantidad          | INT                 | Cantidad vendida |
|              | PrecioUnitario    | DECIMAL(10,2)       | Precio unitario |
|              | Subtotal          | Calculado           | Cantidad * PrecioUnitario |

---

## 3. Explicación de relación con los submódulos

La base de datos **WebBarDB** convive con dos submódulos principales:

### 3.1 Submódulo de Lógica de Negocio (Backend / Clases)
- Las **clases** del backend representan directamente las tablas de la BD.  
  - Ejemplo: Clase `Bar` ↔ Tabla `Bares`, Clase `Producto` ↔ Tabla `Productos`.  
- Los métodos de estas clases consumen los **procedimientos almacenados** (`sp_RegistrarProducto`, `sp_TotalVentasBar`) para ejecutar operaciones seguras y encapsuladas.  
- La lógica de validación (precio y stock no negativos) se refleja tanto en la BD como en las clases.

### 3.2 Submódulo de Interfaz de Usuario (Frontend / Vistas)
- Las **vistas del front** (pantallas de administración, gestión de mesas, ventas) se conectan con la lógica del backend, que a su vez interactúa con la BD.  
- Ejemplo:  
  - Vista “Gestión de Productos” → llama al método `AgregarProducto()` → ejecuta `sp_AgregarProducto` en la BD.  

---

## 4. Conclusión
- **BD (WebBarDB):** almacena y asegura la información.  
- **Backend (Clases):** traduce las tablas en objetos y métodos, aplicando reglas de negocio.  
- **Frontend (Vistas):** presenta la información y permite la interacción del usuario, apoyándose en la lógica del backend.  
