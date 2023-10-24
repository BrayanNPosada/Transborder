package com.prueba.transborder.ControllerImpl;

import com.prueba.transborder.DTO.PaisDto;

import java.util.List;

public interface PaisControllerImpl {
    List<PaisDto> findAll();

    List<PaisDto> save(PaisDto paisDto);

    List<PaisDto> update(Long id, PaisDto paisDto);
}
