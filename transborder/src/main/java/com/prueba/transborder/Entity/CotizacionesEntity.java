package com.prueba.transborder.Entity;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name="cotizacion")
public class CotizacionesEntity {

    @Id
    String numeroCotizacion;
    String estado;
    String fechaCreacion;
    String vigenciaCotizacion;
    String moneda;
    String fechaModificacion;
    String naviera;
    String mercancia;
    Double valorMercancia;
    @ManyToOne()
    @JoinColumn(name="id_ciudad_origen", nullable=false)
    CiudadEntity ciudadOrigen;
    @ManyToOne()
    @JoinColumn(name="id_ciudad_destino", nullable=false)
    CiudadEntity ciudadDestino;
    String fechaCierre;

}
