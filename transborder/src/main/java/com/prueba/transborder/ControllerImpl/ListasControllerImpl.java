package com.prueba.transborder.ControllerImpl;

import com.prueba.transborder.DTO.CotizacionesDto;

import java.util.List;

public interface ListasControllerImpl {

    List<CotizacionesDto> findAllFechaCreacion(String fecha);

    List<CotizacionesDto> findAllStatus(String status);
}
