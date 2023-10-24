package com.prueba.transborder.Controller;

import com.prueba.transborder.ControllerImpl.PaisControllerImpl;
import com.prueba.transborder.DTO.PaisDto;
import com.prueba.transborder.Entity.PaisEntity;
import com.prueba.transborder.Repository.PaisRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
public class PaisController implements PaisControllerImpl {

    @Autowired
    PaisRepository paisRepository;

    @Override
    public List<PaisDto> findAll(){
        List<PaisEntity> entities = paisRepository.findAll();
        return MapEntityToDto(entities);
    }

    @Override
    public List<PaisDto> save(PaisDto paisDto){
        paisRepository.save(MapDtoToEntity(Long.valueOf(0),paisDto));
        List<PaisEntity> entities = paisRepository.findAll();
        return MapEntityToDto(entities);
    }

    @Override
    public List<PaisDto> update(Long id, PaisDto paisDto){
        paisRepository.save(MapDtoToEntity(id,paisDto));
        List<PaisEntity> entities = paisRepository.findById(id).stream().collect(Collectors.toList());
        return MapEntityToDto(entities);
    }

    private List<PaisDto> MapEntityToDto(List<PaisEntity> paisEntity){
        List<PaisDto> paisDto = new ArrayList<>();
        for (int i = 0; i < paisEntity.size(); i++){
            PaisDto dto = new PaisDto();
            dto.setId(paisEntity.get(i).getId());
            dto.setCodigo(paisEntity.get(i).getCodigo());
            dto.setNombre(paisEntity.get(i).getNombre());
            paisDto.add(dto);
        }
        return paisDto;
    }

    private PaisEntity MapDtoToEntity(Long id,PaisDto paisDto){
        PaisEntity paisEntity = new PaisEntity();
        if (id==0){
            paisEntity.setNombre(paisDto.getNombre());
            paisEntity.setCodigo(paisDto.getCodigo());
        }else{
            paisEntity.setId(id);
            paisEntity.setNombre(paisDto.getNombre());
            paisEntity.setCodigo(paisDto.getCodigo());
        }
        return paisEntity;
    }

}
