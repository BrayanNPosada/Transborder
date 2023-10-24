package com.prueba.transborder.Service;

import com.prueba.transborder.ControllerImpl.ListasControllerImpl;
import com.prueba.transborder.DTO.CotizacionesDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Service
@RequestMapping(path = "Listas")
public class ListasService {

    @Autowired
    ListasControllerImpl listasController;

    @GetMapping("/L1/{fecha}")
    public @ResponseBody List<CotizacionesDto> getlista1(@PathVariable(value = "fecha") String fecha) {
        return listasController.findAllFechaCreacion(fecha);
    }

    @GetMapping("/L2/{status}")
    public @ResponseBody List<CotizacionesDto> getLista2(@PathVariable(value = "status") String status) {
        return listasController.findAllStatus(status);
    }

    @GetMapping("/L3/{codPais}/{codCiudad}")
    public @ResponseBody List<CotizacionesDto> getlista3(@PathVariable(value = "codPais") String codPais,@PathVariable(value = "codCiudad") String codCiudad) {
        return listasController.findAllCodePaisCiudad(codPais,codCiudad);
    }

    @GetMapping("/L4/{semana}")
    public @ResponseBody List<CotizacionesDto> getlista4(@PathVariable(value = "semana") String semana) {
        return listasController.findAllSemanaCreacion(semana);
    }

}
