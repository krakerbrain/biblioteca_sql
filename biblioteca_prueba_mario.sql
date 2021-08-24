
--1. Crear el modelo en una base de datos llamada biblioteca, considerando las tablas
--definidas y sus atributos.

CREATE DATABASE biblioteca;
\c biblioteca

CREATE TABLE libro(
    isbn VARCHAR(15) UNIQUE PRIMARY KEY,
    titulo VARCHAR(50),
    numero_paginas SMALLINT,
    dias_prestamo SMALLINT,
    stock BOOLEAN DEFAULT true
);

CREATE TABLE autor(
    cod_autor SERIAL PRIMARY KEY,
    nombre VARCHAR(25),
    apellido VARCHAR(25),
    fecha_nacimiento INT,
    fecha_muerte INT NULL
); 

CREATE TABLE relacion_libro_autor(
    libro_id VARCHAR(15) REFERENCES libro(isbn),
    autor_id INT REFERENCES autor(cod_autor),
    PRIMARY KEY (libro_id, autor_id)
);

CREATE TABLE prestamo(
    id_prestamo SERIAL PRIMARY KEY,
    cod_libro VARCHAR(15),
    fecha_prestamo DATE,
    fecha_posible_dev DATE,
    fecha_devolucion DATE,
    FOREIGN KEY (cod_libro) REFERENCES libro(isbn)
);

CREATE TABLE socio(
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(25),
    apellido VARCHAR(25),
    direccion VARCHAR(50) NOT NULL UNIQUE,
    telefono INT NOT NULL UNIQUE
); 

CREATE TABLE relacion_prestamo_socio(
    prestamo_id SERIAL REFERENCES prestamo(id_prestamo),
    socio_id VARCHAR(12) REFERENCES socio(rut),
    PRIMARY KEY (prestamo_id, socio_id)
);

-- 2. Se deben insertar los registros en las tablas correspondientes.

INSERT INTO libro(isbn, titulo, numero_paginas, dias_prestamo)
VALUES 
('111-1111111-111', 'CUENTOS DE TERROR', 344, 7),
('222-2222222-222', 'POESIAS CONTEMPORANEAS', 167, 7),
('333-3333333-333', 'HISTORIA DE ASIA', 511, 14),
('444-4444444-444', 'MANUAL DE MECÁNICA', 298, 14);

INSERT INTO autor(cod_autor, nombre, apellido, fecha_nacimiento, fecha_muerte)
VALUES
(3, 'JOSE', 'SALGADO', 1968, 2020),
(4, 'ANA', 'SALGADO', 1972,NULL),  
(1, 'ANDRES', 'ULLOA', 1982,NULL),
(2, 'SERGIO', 'MARDONES', 1950, 2012),
(5, 'MARTIN', 'PORTA', 1976,NULL);

INSERT INTO relacion_libro_autor(libro_id, autor_id)
VALUES 
('111-1111111-111', 3),
('111-1111111-111', 4),
('222-2222222-222', 1),
('333-3333333-333', 2),
('444-4444444-444', 5);

INSERT INTO socio(rut, nombre, apellido, direccion, telefono)
VALUES
('1111111-1', 'JUAN', 'SOTO', 'AVENIDA 1, SANTIAGO', 91111111),
('2222222-2', 'ANA', 'PEREZ', 'PASAJE 2, SANTIAGO', 92222222),
('3333333-3', 'SANDRA', 'AGUILAR', 'AVENIDA 2, SANTIAGO', 933333333),
('4444444-4', 'ESTEBAN', 'JEREZ', 'AVENIDA3, SANTIAGO', 944444444),
('5555555-5', 'SILVANA', 'MUNOZ', 'PASAJE 3, SANTIAGO', 955555555);

INSERT INTO prestamo(cod_libro, fecha_prestamo, fecha_posible_dev, fecha_devolucion)
VALUES 
('111-1111111-111', '20-01-2020', '27-01-2020', '27-01-2020'), 
('222-2222222-222', '20-01-2020', '27-01-2020', '30-01-2020'), 
('333-3333333-333', '22-01-2020', '05-02-2020', '30-01-2020'),
('444-4444444-444', '23-01-2020', '06-02-2020', '30-01-2020'),
('111-1111111-111', '27-01-2020', '03-02-2020', '04-02-2020'),
('444-4444444-444', '31-01-2020', '14-02-2020', '12-02-2020'),
('222-2222222-222', '31-01-2020', '07-02-2020', '12-02-2020');

INSERT INTO relacion_prestamo_socio(socio_id)
VALUES
('5555555-5'),
('3333333-3'),
('4444444-4'),
('1111111-1'),
('2222222-2'),
('1111111-1'),
('3333333-3');


--3. Realizar las siguientes consultas:

-- a. Mostrar todos los libros que posean menos de 300 páginas.

SELECT  *
FROM libro
WHERE numero_paginas < 300;

-- b. Mostrar todos los autores que hayan nacido después del 01-01-1970.

SELECT  *
FROM autor
WHERE fecha_nacimiento >= 1970;

-- c. ¿Cuál es el libro más solicitado?

SELECT  titulo AS titulo_mas_vendido
       ,COUNT(cod_libro)
FROM prestamo
INNER JOIN libro
ON prestamo.cod_libro = libro.isbn
GROUP BY  titulo
ORDER BY count desc
LIMIT 1;

-- d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto
-- debería pagar cada usuario que entregue el préstamo después de 7 días.

SELECT  cod_libro
       ,dias_prestamo
       ,nombre
       ,apellido
       ,fecha_devolucion::DATE - fecha_prestamo::DATE - dias_prestamo       AS dias_de_atraso
       ,(fecha_devolucion::DATE - fecha_prestamo::DATE - dias_prestamo)*100 AS multa
FROM prestamo
INNER JOIN relacion_prestamo_socio
ON prestamo.id_prestamo = relacion_prestamo_socio.prestamo_id
INNER JOIN socio
ON relacion_prestamo_socio.socio_id = socio.rut
INNER JOIN libro
ON prestamo.cod_libro = libro.isbn
WHERE fecha_devolucion::date - fecha_prestamo::date > 7
AND libro.dias_prestamo <= 7;

--DICCIONARIO DE DATOS

SELECT  t1.TABLE_NAME       AS tabla_nombre
       ,t1.COLUMN_NAME      AS columna_nombre
       ,t1.ORDINAL_POSITION AS position
       ,t1.IS_NULLABLE      AS nulo
       ,t1.DATA_TYPE        AS tipo_dato
       ,COALESCE(t1.NUMERIC_PRECISION,t1.CHARACTER_MAXIMUM_LENGTH) AS longitud
FROM INFORMATION_SCHEMA.COLUMNS t1
WHERE t1.TABLE_SCHEMA = 'public'
ORDER BY t1.TABLE_NAME;


