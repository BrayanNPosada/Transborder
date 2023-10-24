package com.prueba.transborder.Service;

import com.prueba.transborder.ControllerImpl.PaisControllerImpl;
import com.prueba.transborder.DTO.PaisDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Service
@RequestMapping(path = "pais")
public class PaisService {

    @Autowired
    PaisControllerImpl paisController;

    @GetMapping(produces = "application/json")
    public @ResponseBody List<PaisDto> getPais() {
        return paisController.findAll();
    }

    @PostMapping(consumes = "application/json",produces = "application/json")
    public @ResponseBody List<PaisDto> save(@RequestBody PaisDto paisDto) {
        return paisController.save(paisDto);
    }

    @PatchMapping("/{id}")
    public @ResponseBody List<PaisDto> Update(@PathVariable(value = "id") Long id,
                                              @RequestBody PaisDto paisDto) {
        return paisController.update(id,paisDto);
    }

}
