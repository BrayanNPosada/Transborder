package com.prueba.transborder.ControllerImpl;

import com.prueba.transborder.DTO.CiudadDto;

import java.util.List;

public interface CiudadControllerImpl {
    List<CiudadDto> findAll();

    List<CiudadDto> save(CiudadDto paisDto);

    List<CiudadDto> update(Long id, CiudadDto paisDto);
}
