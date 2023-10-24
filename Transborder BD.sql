create database Transborder;
Use Transborder;

create table pais(
id int primary key auto_increment,
nombre varchar(50),
codigo varchar(20)
);

create table ciudad(
id int primary key auto_increment,
nombre varchar(50),
id_pais int,
codigo varchar(20),
foreign key (id_pais) references pais (id)
);

create table cotizacion(
numero_cotizacion varchar(20) primary key,
estado varchar(50),
fecha_creacion datetime,
vigencia_cotizacion datetime,
moneda varchar(5),
fecha_modificacion datetime,
naviera varchar(30),
mercancia varchar(500),
valor_mercancia int,
id_ciudad_origen int,
id_ciudad_destino int,
fecha_cierre datetime,
foreign key (id_ciudad_origen) references ciudad (id),
foreign key (id_ciudad_destino) references ciudad (id)
);

Drop table pais;
Drop table ciudad;
Drop table cotizacion;