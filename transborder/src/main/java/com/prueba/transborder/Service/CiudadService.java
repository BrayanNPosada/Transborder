package com.prueba.transborder.Service;

import com.prueba.transborder.ControllerImpl.CiudadControllerImpl;
import com.prueba.transborder.DTO.CiudadDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Service
@RequestMapping(path = "ciudad")
public class CiudadService {

    @Autowired
    CiudadControllerImpl ciudadController;

    @GetMapping(produces = "application/json")
    public @ResponseBody List<CiudadDto> getCiudad() {
        return ciudadController.findAll();
    }

    @PostMapping(consumes = "application/json",produces = "application/json")
    public @ResponseBody List<CiudadDto> save(@RequestBody CiudadDto ciudadDto) {
        return ciudadController.save(ciudadDto);
    }

    @PatchMapping("/{id}")
    public @ResponseBody List<CiudadDto> Update(@PathVariable(value = "id") Long id,
                                              @RequestBody CiudadDto ciudadDto) {
        return ciudadController.update(id,ciudadDto);
    }

}
