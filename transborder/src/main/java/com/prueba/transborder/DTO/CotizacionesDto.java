package com.prueba.transborder.DTO;

import lombok.Data;

import java.util.Date;

@Data
public class CotizacionesDto {

    String numeroCotizacion;
    String estado;
    String fechaCreacion;
    String vigenciaCotizacion;
    String moneda;
    String fechaModificacion;
    String naviera;
    String mercancia;
    Double valorMercancia;
    CiudadDto idCiudadOrigen;
    CiudadDto idCiudadDestino;
    String fechaCierre;

}
