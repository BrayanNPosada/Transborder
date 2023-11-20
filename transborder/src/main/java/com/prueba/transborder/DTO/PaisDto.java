package com.prueba.transborder.DTO;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PaisDto implements Serializable {

    private Long id;
    private String nombre;
    private String codigo;

}
