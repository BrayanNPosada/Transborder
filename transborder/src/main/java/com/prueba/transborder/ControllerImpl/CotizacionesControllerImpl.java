package com.prueba.transborder.ControllerImpl;

import com.prueba.transborder.DTO.CotizacionesDto;

import java.util.List;

public interface CotizacionesControllerImpl {
    List<CotizacionesDto> findAll();

    List<CotizacionesDto> save(CotizacionesDto cotizacionesDto);

    List<CotizacionesDto> update(String id, CotizacionesDto cotizacionesDto);
}
