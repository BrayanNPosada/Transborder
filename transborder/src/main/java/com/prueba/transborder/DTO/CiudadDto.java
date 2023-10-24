package com.prueba.transborder.DTO;

import lombok.Data;

@Data
public class CiudadDto {

    private Long id;
    private String nombre;
    private PaisDto pais;
    private String codigo;

}
