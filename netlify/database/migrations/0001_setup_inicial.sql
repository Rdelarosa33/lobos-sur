-- ============================================================
-- JUNTA VECINAL LOBOS SUR - Setup Neon (Netlify DB)
-- Ejecutar en: Netlify > Database > View/edit > SQL Editor
-- ============================================================

-- 1. VECINOS
create table if not exists vecinos (
  id serial primary key,
  nombre text not null,
  rol text default 'Propietario',
  activo boolean default true,
  notas text,
  created_at timestamptz default now()
);

-- 2. PAGOS (un registro por cada cuota pagada)
create table if not exists pagos (
  id serial primary key,
  vecino_id integer references vecinos(id) on delete cascade,
  periodo text not null,        -- formato 'YYYY-MM' ej: '2024-11'
  monto numeric not null,
  tipo text default 'ordinaria', -- 'ordinaria' | 'extraordinaria'
  fecha_pago date default current_date,
  registrado_por text default 'admin',
  created_at timestamptz default now()
);

-- 3. GASTOS / EGRESOS
create table if not exists gastos (
  id serial primary key,
  descripcion text not null,
  categoria text not null,
  monto numeric not null,
  fecha date default current_date,
  realizado boolean default true,
  notas text,
  created_at timestamptz default now()
);

-- 4. ACTIVOS
create table if not exists activos (
  id serial primary key,
  nombre text not null,
  categoria text not null,       -- 'Seguridad','Herramienta','Infraestructura','Agua'
  descripcion text,
  valor_aprox numeric,
  estado text default 'Buen estado', -- 'Buen estado','Regular','Mantenimiento'
  fecha_adquisicion date,
  created_at timestamptz default now()
);

-- 5. CONFIG (saldo inicial, PIN admin, etc.)
create table if not exists config (
  clave text primary key,
  valor text
);

-- ============================================================
-- POLÍTICAS DE SEGURIDAD (RLS) - lectura pública, escritura solo con clave
-- ============================================================

-- ============================================================
-- DATOS INICIALES - VECINOS (19 propietarios reales)
-- ============================================================
insert into vecinos (id, nombre, rol, notas) values
(1,  'Nolasco y Jaqueline',              'Propietario',    'Pend S/100 feb · S/100 marzo 2026'),
(2,  'Carlos Rodríguez Fernandez',       'Propietario',    'Debe 14 meses · Ofreció ponerse al día'),
(3,  'Carmen Castillo',                  'Propietario',    'Pend marzo 2026'),
(4,  'Coronel José Luis Rodríguez',      'Propietario',    'Debe 11 meses · Se retiró del grupo'),
(5,  'Frank Yactayo',                    'Propietario',    'Pend ene/feb/mar 2026 · Ofreció ponerse al día'),
(6,  'Octavio Chirinos e Ingrid Tong',   'Resp. Vigilancia / Tesorera', 'Pend S/100 marzo 2026'),
(7,  'José Pezantes y Patty Trigoso',    'Propietario',    'Pend S/100 marzo 2026'),
(8,  'Mayor Madrid',                     'Propietario',    'Ningún pago · Sugerido retirar de la Junta'),
(9,  'Marco Noa',                        'Propietario',    'Debe 13 meses · Sugerido retirar de la Junta'),
(10, 'Miguel Noa',                       'Propietario',    'Ningún pago · Sugerido retirar de la Junta'),
(11, 'Maritza Zamalloa',                 'Propietario',    'Pend S/100 marzo 2026'),
(12, 'Rafael de La Rosa',                'Propietario',    'Acuerdo: 15 postes compensan deuda anterior'),
(13, 'Williams Guzmán',                  'Vicepresidente', 'Pend S/50 sep 2025 · S/100 feb/mar 2026 · Ofreció ponerse al día'),
(14, 'Rocío Mazzei',                     'Propietario',    'Pend S/100 feb/mar 2026 · Ofreció ponerse al día'),
(15, 'Luis Iglesias y Giuliana Spelucín','Presidente',     'Al día'),
(16, 'Mateo Acaro',                      'Propietario',    'Pend ago-dic 2025, ene/feb/mar 2026 · Pagará con trabajos'),
(17, 'Darío Alfaro',                     'Propietario',    'Ningún pago · Sugerido retirar de la Junta'),
(18, 'Rosario Franco',                   'Propietario',    'Al día'),
(19, 'Cecilia López',                    'Propietario',    'Al día');

-- ============================================================
-- DATOS INICIALES - PAGOS (histórico completo del Excel)
-- Periodos: 2024-11 a 2026-04
-- Meses extraordinarios (S/100): dic, ene, feb, mar
-- Meses ordinarios (S/50): abr-nov
-- ============================================================
-- Función auxiliar: inserta pago si no existe
-- Vecino 1: Nolasco - pagó nov24 a dic25 (menos feb/mar 2026)
insert into pagos (vecino_id, periodo, monto, tipo) values
(1,'2024-11',50,'ordinaria'),(1,'2024-12',100,'extraordinaria'),
(1,'2025-01',100,'extraordinaria'),(1,'2025-02',100,'extraordinaria'),
(1,'2025-03',100,'extraordinaria'),(1,'2025-04',50,'ordinaria'),
(1,'2025-05',50,'ordinaria'),(1,'2025-06',50,'ordinaria'),
(1,'2025-07',50,'ordinaria'),(1,'2025-08',50,'ordinaria'),
(1,'2025-09',50,'ordinaria'),(1,'2025-10',50,'ordinaria'),
(1,'2025-11',50,'ordinaria'),(1,'2025-12',100,'extraordinaria');

-- Vecino 2: Carlos Rodríguez - solo dic24,ene25,feb25
insert into pagos (vecino_id, periodo, monto, tipo) values
(2,'2024-12',100,'extraordinaria'),(2,'2025-01',100,'extraordinaria'),(2,'2025-02',100,'extraordinaria');

-- Vecino 3: Carmen Castillo - nov24 a dic25 + feb26
insert into pagos (vecino_id, periodo, monto, tipo) values
(3,'2024-11',50,'ordinaria'),(3,'2024-12',100,'extraordinaria'),
(3,'2025-01',100,'extraordinaria'),(3,'2025-02',100,'extraordinaria'),
(3,'2025-03',100,'extraordinaria'),(3,'2025-04',50,'ordinaria'),
(3,'2025-05',50,'ordinaria'),(3,'2025-06',50,'ordinaria'),
(3,'2025-07',50,'ordinaria'),(3,'2025-08',50,'ordinaria'),
(3,'2025-09',50,'ordinaria'),(3,'2025-10',50,'ordinaria'),
(3,'2025-11',50,'ordinaria'),(3,'2025-12',100,'extraordinaria'),
(3,'2026-02',200,'extraordinaria');

-- Vecino 4: Coronel - abr25 a ago25 + dic25
insert into pagos (vecino_id, periodo, monto, tipo) values
(4,'2025-04',50,'ordinaria'),(4,'2025-05',50,'ordinaria'),
(4,'2025-06',50,'ordinaria'),(4,'2025-07',50,'ordinaria'),
(4,'2025-08',50,'ordinaria'),(4,'2025-12',100,'extraordinaria');

-- Vecino 5: Frank Yactayo - nov24 a ago25 + feb26
insert into pagos (vecino_id, periodo, monto, tipo) values
(5,'2024-11',50,'ordinaria'),(5,'2024-12',100,'extraordinaria'),
(5,'2025-01',100,'extraordinaria'),(5,'2025-02',100,'extraordinaria'),
(5,'2025-03',100,'extraordinaria'),(5,'2025-04',50,'ordinaria'),
(5,'2025-05',50,'ordinaria'),(5,'2025-06',50,'ordinaria'),
(5,'2025-07',50,'ordinaria'),(5,'2025-08',50,'ordinaria'),
(5,'2026-02',250,'extraordinaria');

-- Vecino 6: Octavio/Ingrid - nov24 a feb26
insert into pagos (vecino_id, periodo, monto, tipo) values
(6,'2024-11',50,'ordinaria'),(6,'2024-12',100,'extraordinaria'),
(6,'2025-01',100,'extraordinaria'),(6,'2025-02',100,'extraordinaria'),
(6,'2025-03',100,'extraordinaria'),(6,'2025-04',50,'ordinaria'),
(6,'2025-05',50,'ordinaria'),(6,'2025-06',50,'ordinaria'),
(6,'2025-07',50,'ordinaria'),(6,'2025-08',50,'ordinaria'),
(6,'2025-09',50,'ordinaria'),(6,'2025-10',50,'ordinaria'),
(6,'2025-11',50,'ordinaria'),(6,'2025-12',100,'extraordinaria'),
(6,'2026-01',100,'extraordinaria'),(6,'2026-02',100,'extraordinaria');

-- Vecino 7: José Pezantes - igual que Octavio
insert into pagos (vecino_id, periodo, monto, tipo) values
(7,'2024-11',50,'ordinaria'),(7,'2024-12',100,'extraordinaria'),
(7,'2025-01',100,'extraordinaria'),(7,'2025-02',100,'extraordinaria'),
(7,'2025-03',100,'extraordinaria'),(7,'2025-04',50,'ordinaria'),
(7,'2025-05',50,'ordinaria'),(7,'2025-06',50,'ordinaria'),
(7,'2025-07',50,'ordinaria'),(7,'2025-08',50,'ordinaria'),
(7,'2025-09',50,'ordinaria'),(7,'2025-10',50,'ordinaria'),
(7,'2025-11',50,'ordinaria'),(7,'2025-12',100,'extraordinaria'),
(7,'2026-01',100,'extraordinaria'),(7,'2026-02',100,'extraordinaria');

-- Vecinos 8,10,17: sin pagos - no insertar nada

-- Vecino 9: Marco Noa - nov24 a feb25
insert into pagos (vecino_id, periodo, monto, tipo) values
(9,'2024-11',50,'ordinaria'),(9,'2024-12',100,'extraordinaria'),
(9,'2025-01',100,'extraordinaria'),(9,'2025-02',100,'extraordinaria');

-- Vecino 11: Maritza - igual que Octavio
insert into pagos (vecino_id, periodo, monto, tipo) values
(11,'2024-11',50,'ordinaria'),(11,'2024-12',100,'extraordinaria'),
(11,'2025-01',100,'extraordinaria'),(11,'2025-02',100,'extraordinaria'),
(11,'2025-03',100,'extraordinaria'),(11,'2025-04',50,'ordinaria'),
(11,'2025-05',50,'ordinaria'),(11,'2025-06',50,'ordinaria'),
(11,'2025-07',50,'ordinaria'),(11,'2025-08',50,'ordinaria'),
(11,'2025-09',50,'ordinaria'),(11,'2025-10',50,'ordinaria'),
(11,'2025-11',50,'ordinaria'),(11,'2025-12',100,'extraordinaria'),
(11,'2026-01',100,'extraordinaria'),(11,'2026-02',100,'extraordinaria');

-- Vecino 12: Rafael de La Rosa - todos los periodos hasta abr26
insert into pagos (vecino_id, periodo, monto, tipo) values
(12,'2024-11',50,'ordinaria'),(12,'2024-12',100,'extraordinaria'),
(12,'2025-01',100,'extraordinaria'),(12,'2025-02',100,'extraordinaria'),
(12,'2025-03',100,'extraordinaria'),(12,'2025-04',50,'ordinaria'),
(12,'2025-05',50,'ordinaria'),(12,'2025-06',50,'ordinaria'),
(12,'2025-07',50,'ordinaria'),(12,'2025-08',50,'ordinaria'),
(12,'2025-09',50,'ordinaria'),(12,'2025-10',50,'ordinaria'),
(12,'2025-11',50,'ordinaria'),(12,'2025-12',100,'extraordinaria'),
(12,'2026-01',100,'extraordinaria'),(12,'2026-02',100,'extraordinaria'),
(12,'2026-03',100,'extraordinaria'),(12,'2026-04',50,'ordinaria');

-- Vecino 13: Williams Guzmán
insert into pagos (vecino_id, periodo, monto, tipo) values
(13,'2024-11',50,'ordinaria'),(13,'2024-12',100,'extraordinaria'),
(13,'2025-01',100,'extraordinaria'),(13,'2025-02',100,'extraordinaria'),
(13,'2025-03',100,'extraordinaria'),(13,'2025-10',50,'ordinaria'),
(13,'2025-11',50,'ordinaria'),(13,'2025-12',100,'extraordinaria'),
(13,'2026-01',100,'extraordinaria'),(13,'2026-02',250,'extraordinaria');

-- Vecino 14: Rocío Mazzei - nov24 a ene26
insert into pagos (vecino_id, periodo, monto, tipo) values
(14,'2024-11',50,'ordinaria'),(14,'2024-12',100,'extraordinaria'),
(14,'2025-01',100,'extraordinaria'),(14,'2025-02',100,'extraordinaria'),
(14,'2025-03',100,'extraordinaria'),(14,'2025-04',50,'ordinaria'),
(14,'2025-05',50,'ordinaria'),(14,'2025-06',50,'ordinaria'),
(14,'2025-07',50,'ordinaria'),(14,'2025-08',50,'ordinaria'),
(14,'2025-09',50,'ordinaria'),(14,'2025-10',50,'ordinaria'),
(14,'2025-11',50,'ordinaria'),(14,'2025-12',100,'extraordinaria'),
(14,'2026-01',100,'extraordinaria');

-- Vecino 15: Luis Iglesias (presidente) - todo hasta mar26
insert into pagos (vecino_id, periodo, monto, tipo) values
(15,'2024-11',50,'ordinaria'),(15,'2024-12',100,'extraordinaria'),
(15,'2025-01',100,'extraordinaria'),(15,'2025-02',100,'extraordinaria'),
(15,'2025-03',100,'extraordinaria'),(15,'2025-04',50,'ordinaria'),
(15,'2025-05',50,'ordinaria'),(15,'2025-06',50,'ordinaria'),
(15,'2025-07',50,'ordinaria'),(15,'2025-08',50,'ordinaria'),
(15,'2025-09',50,'ordinaria'),(15,'2025-10',50,'ordinaria'),
(15,'2025-11',50,'ordinaria'),(15,'2025-12',100,'extraordinaria'),
(15,'2026-01',100,'extraordinaria'),(15,'2026-02',100,'extraordinaria'),
(15,'2026-03',100,'extraordinaria');

-- Vecino 16: Mateo - nov24 a ago25
insert into pagos (vecino_id, periodo, monto, tipo) values
(16,'2024-11',50,'ordinaria'),(16,'2024-12',100,'extraordinaria'),
(16,'2025-01',100,'extraordinaria'),(16,'2025-02',100,'extraordinaria'),
(16,'2025-03',100,'extraordinaria'),(16,'2025-04',50,'ordinaria'),
(16,'2025-05',50,'ordinaria'),(16,'2025-06',50,'ordinaria'),
(16,'2025-07',50,'ordinaria'),(16,'2025-08',50,'ordinaria');

-- Vecino 18: Rosario Franco - todo hasta abr26
insert into pagos (vecino_id, periodo, monto, tipo) values
(18,'2024-11',50,'ordinaria'),(18,'2024-12',100,'extraordinaria'),
(18,'2025-01',100,'extraordinaria'),(18,'2025-02',100,'extraordinaria'),
(18,'2025-03',100,'extraordinaria'),(18,'2025-04',50,'ordinaria'),
(18,'2025-05',50,'ordinaria'),(18,'2025-06',50,'ordinaria'),
(18,'2025-07',50,'ordinaria'),(18,'2025-08',50,'ordinaria'),
(18,'2025-09',50,'ordinaria'),(18,'2025-10',50,'ordinaria'),
(18,'2025-11',50,'ordinaria'),(18,'2025-12',108,'extraordinaria'),
(18,'2026-01',92,'extraordinaria'),(18,'2026-02',100,'extraordinaria'),
(18,'2026-03',100,'extraordinaria'),(18,'2026-04',50,'ordinaria');

-- Vecino 19: Cecilia López - todo hasta mar26
insert into pagos (vecino_id, periodo, monto, tipo) values
(19,'2024-11',50,'ordinaria'),(19,'2024-12',100,'extraordinaria'),
(19,'2025-01',100,'extraordinaria'),(19,'2025-02',100,'extraordinaria'),
(19,'2025-03',100,'extraordinaria'),(19,'2025-04',50,'ordinaria'),
(19,'2025-05',50,'ordinaria'),(19,'2025-06',50,'ordinaria'),
(19,'2025-07',50,'ordinaria'),(19,'2025-08',50,'ordinaria'),
(19,'2025-09',50,'ordinaria'),(19,'2025-10',50,'ordinaria'),
(19,'2025-11',50,'ordinaria'),(19,'2025-12',100,'extraordinaria'),
(19,'2026-01',100,'extraordinaria'),(19,'2026-02',100,'extraordinaria'),
(19,'2026-03',100,'extraordinaria');

-- ============================================================
-- GASTOS (28 inversiones reales)
-- ============================================================
insert into gastos (descripcion, categoria, monto, fecha) values
('Rescate parque y eliminación parcial de desmonte (Octavio Chirinos)','Parques',420,'2024-12-01'),
('Sembrado de plantas Av. Cabos (Frank Yactayo)','Plantas',422,'2024-12-15'),
('Alquiler maquina retro, viajes de agua, rodillo y otros (Octavio Chirinos)','Infraestructura',1280,'2025-01-10'),
('Movilidad para carteles','Señalética',100,'2025-01-20'),
('Medio viaje de agua para regar plantas (Octavio Chirinos)','Riego',70,'2025-02-05'),
('Elaboración de 5 carteles (4 señalización calles + 1 prohibido basura)','Señalética',860,'2025-02-15'),
('2 viajes de agua para regar calles y plantas (Octavio Chirinos)','Riego',280,'2025-03-01'),
('Materiales y mano de obra colocación letreros (Mateo Acaro)','Señalética',690,'2025-03-15'),
('Compra de 14 luminarias solares','Luminarias',1332.8,'2025-04-01'),
('Pago encomienda','Logística',33,'2025-04-05'),
('2 luminarias solares y 2 palos (Mateo Acaro)','Luminarias',300,'2025-04-20'),
('Materiales y mano de obra instalación luminarias (Mateo Acaro)','Luminarias',690,'2025-05-01'),
('Compra de 10 luminarias','Luminarias',953,'2025-06-01'),
('Tubos brazo para asegurar postes de madera','Infraestructura',85,'2025-06-10'),
('Materiales y mano de obra instalación luminarias (Mateo Acaro)','Luminarias',659,'2025-07-01'),
('Pago encomienda','Logística',16,'2025-07-05'),
('Compra de 3 luminarias solares','Luminarias',300,'2025-08-01'),
('Pago encomienda','Logística',16,'2025-08-05'),
('15 postes de madera (Rafael de La Rosa)','Infraestructura',750,'2025-09-01'),
('Plantas y varios','Plantas',784,'2025-10-01'),
('3 cámaras solares de seguridad','Seguridad',900,'2025-11-01'),
('3 chips Bitel para cámaras','Seguridad',90,'2025-11-05'),
('1era campaña de sembrado de árboles','Plantas',1173.6,'2025-12-01'),
('2da campaña de sembrado de árboles','Plantas',1000,'2026-01-10'),
('Regado de árboles','Riego',150,'2026-01-20'),
('Regado de árboles (2da vez)','Riego',150,'2026-02-05'),
('Regado y fertilizante','Riego',210,'2026-02-20'),
('Internet para 3 cámaras (mes)','Seguridad',84,'2026-03-01');

-- ============================================================
-- ACTIVOS
-- ============================================================
insert into activos (nombre, categoria, descripcion, valor_aprox, estado, fecha_adquisicion) values
('Cámara solar seguridad #1','Seguridad','Entrada principal del condominio',300,'Buen estado','2025-11-01'),
('Cámara solar seguridad #2','Seguridad','Calle interior zona A',300,'Buen estado','2025-11-01'),
('Cámara solar seguridad #3','Seguridad','Zona parques',300,'Buen estado','2025-11-01'),
('Luminaria solar #1 al #14','Luminarias','Lote instalado por Mateo Acaro · 14 unidades',1332.8,'Buen estado','2025-04-01'),
('Luminaria solar #15 al #16','Luminarias','2 unidades adicionales',300,'Buen estado','2025-04-20'),
('Luminaria solar #17 al #26','Luminarias','10 unidades adicionales',953,'Buen estado','2025-06-01'),
('Luminaria solar #27 al #29','Luminarias','3 unidades adicionales',300,'Buen estado','2025-08-01'),
('15 postes de madera','Infraestructura','Provistos por Rafael de La Rosa como acuerdo de pago',750,'Buen estado','2025-09-01'),
('5 carteles señalización','Señalética','4 calles + 1 prohibido basura',860,'Buen estado','2025-02-15'),
('Chips Bitel x3','Seguridad','Para cámaras de seguridad · plan internet mensual',90,'Activo','2025-11-05');

-- ============================================================
-- CONFIG - PIN admin (cámbialo aquí antes de usar)
-- ============================================================
insert into config (clave, valor) values
('admin_pin', '1234'),
('nombre_junta', 'Junta Vecinal Lobos Sur'),
('cuota_ordinaria', '50'),
('cuota_extraordinaria', '100'),
('meses_extraordinarios', '12,1,2,3'),
('periodo_inicio', '2024-11'),
('periodo_corte', '2026-03');

-- ============================================================
