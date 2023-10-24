package com.prueba.transborder.Entity;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name="pais")
public class PaisEntity {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;
    private String nombre;
    private String codigo;

}
