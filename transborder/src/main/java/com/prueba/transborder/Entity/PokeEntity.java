package com.prueba.transborder.Entity;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name="pokemon")
public class PokeEntity {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String url;

}
