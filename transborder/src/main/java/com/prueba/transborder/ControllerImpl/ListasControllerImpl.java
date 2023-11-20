package com.prueba.transborder.ControllerImpl;

import com.prueba.transborder.DTO.CotizacionesDto;
import com.prueba.transborder.DTO.PokeDTO;
import com.prueba.transborder.DTO.Results;

import java.util.List;

public interface ListasControllerImpl {

    List<CotizacionesDto> findAllFechaCreacion(String fecha);

    List<CotizacionesDto> findAllStatus(String status);

    List<CotizacionesDto> findAllSemanaCreacion(String numeroSemana);

    List<CotizacionesDto> findAllCodePaisCiudad(String codPais, String codCiudad);

    void savePoke(PokeDTO listaData);
}
