package com.prueba.transborder.Service;

import com.prueba.transborder.ControllerImpl.CotizacionesControllerImpl;
import com.prueba.transborder.DTO.CotizacionesDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Service
@RequestMapping(path = "cotizacion")
public class CotizacionService {

    @Autowired
    CotizacionesControllerImpl cotizacionesControllerImpl;

    @GetMapping(produces = "application/json")
    public @ResponseBody List<CotizacionesDto> getCotizacion() {
        return cotizacionesControllerImpl.findAll();
    }

    @PostMapping(consumes = "application/json",produces = "application/json")
    public @ResponseBody List<CotizacionesDto> save(@RequestBody CotizacionesDto cotizacionesDto) {
        return cotizacionesControllerImpl.save(cotizacionesDto);
    }

    @PatchMapping("/{id}")
    public @ResponseBody List<CotizacionesDto> Update(@PathVariable(value = "id") String id,
                                                @RequestBody CotizacionesDto cotizacionesDto) {
        return cotizacionesControllerImpl.update(id,cotizacionesDto);
    }


}
