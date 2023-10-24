package com.prueba.transborder.Entity;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name="ciudad")
public class CiudadEntity {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;
    private String nombre;
    @ManyToOne()
    @JoinColumn(name="id_pais", nullable=false)
    private PaisEntity pais;
    private String codigo;

}
