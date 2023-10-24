package com.prueba.transborder.DTO;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CotizacionesDto implements Serializable {

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
