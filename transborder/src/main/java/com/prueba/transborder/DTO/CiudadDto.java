package com.prueba.transborder.DTO;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.io.Serializable;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CiudadDto implements Serializable {

    private Long id;
    private String nombre;
    private PaisDto pais;
    private String codigo;

}
