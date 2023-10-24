package com.prueba.transborder.Controller;

import com.prueba.transborder.ControllerImpl.CiudadControllerImpl;
import com.prueba.transborder.DTO.CiudadDto;
import com.prueba.transborder.DTO.PaisDto;
import com.prueba.transborder.Entity.CiudadEntity;
import com.prueba.transborder.Entity.PaisEntity;
import com.prueba.transborder.Repository.CiudadRepository;
import com.prueba.transborder.Repository.PaisRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class CiudadController implements CiudadControllerImpl {

    @Autowired
    CiudadRepository ciudadRepository;

    @Autowired
    PaisRepository paisRepository;
    
    @Override
    public List<CiudadDto> findAll(){
        List<CiudadEntity> entities = ciudadRepository.findAll();
        return MapEntityToDto(entities);
    }

    @Override
    public List<CiudadDto> save(CiudadDto ciudadDto){
        ciudadRepository.save(MapDtoToEntity(Long.valueOf(0),ciudadDto));
        List<CiudadEntity> entities = ciudadRepository.findAll();
        return MapEntityToDto(entities);
    }

    @Override
    public List<CiudadDto> update(Long id, CiudadDto ciudadDto){
        ciudadRepository.save(MapDtoToEntity(id,ciudadDto));
        List<CiudadEntity> entities = ciudadRepository.findById(id).stream().collect(Collectors.toList());
        return MapEntityToDto(entities);
    }

    private List<CiudadDto> MapEntityToDto(List<CiudadEntity> ciudadEntity){
        List<CiudadDto> ciudadDto = new ArrayList<>();
        
        for (int i = 0; i < ciudadEntity.size(); i++){
            CiudadDto dto = new CiudadDto();
            dto.setId(ciudadEntity.get(i).getId());
            dto.setNombre(ciudadEntity.get(i).getNombre());
            dto.setCodigo(ciudadEntity.get(i).getCodigo());
            dto.setPais(paisDtoById(ciudadEntity.get(i).getPais().getId()));
            ciudadDto.add(dto);
        }
        return ciudadDto;
    }

    private CiudadEntity MapDtoToEntity(Long id,CiudadDto ciudadDto){
        CiudadEntity ciudadEntity = new CiudadEntity();
        if (id==0){
            ciudadEntity.setNombre(ciudadDto.getNombre());
            ciudadEntity.setCodigo(ciudadDto.getCodigo());
            PaisEntity paisEntity = new PaisEntity();
            paisEntity.setId(ciudadDto.getPais().getId());
            ciudadEntity.setPais(paisEntity);
        }else{
            ciudadEntity.setId(id);
            ciudadEntity.setNombre(ciudadDto.getNombre());
            ciudadEntity.setCodigo(ciudadDto.getCodigo());
            PaisEntity paisEntity = new PaisEntity();
            paisEntity.setId(ciudadDto.getPais().getId());
            ciudadEntity.setPais(paisEntity);
        }
        return ciudadEntity;
    }

    private PaisDto paisDtoById(Long idPais){
        PaisDto response = new PaisDto();
        List<PaisEntity> paisEntity = paisRepository.findById(idPais).stream().collect(Collectors.toList());
        response.setId(paisEntity.get(0).getId());
        response.setCodigo(paisEntity.get(0).getCodigo());
        response.setNombre(paisEntity.get(0).getNombre());
        return response;
    }

}
