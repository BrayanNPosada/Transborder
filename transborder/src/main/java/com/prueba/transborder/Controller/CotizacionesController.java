package com.prueba.transborder.Controller;

import com.prueba.transborder.ControllerImpl.CotizacionesControllerImpl;
import com.prueba.transborder.DTO.CiudadDto;
import com.prueba.transborder.DTO.CotizacionesDto;
import com.prueba.transborder.DTO.PaisDto;
import com.prueba.transborder.Entity.CiudadEntity;
import com.prueba.transborder.Entity.CotizacionesEntity;
import com.prueba.transborder.Entity.PaisEntity;
import com.prueba.transborder.Repository.CiudadRepository;
import com.prueba.transborder.Repository.CotizacionesRepository;
import com.prueba.transborder.Repository.PaisRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class CotizacionesController implements CotizacionesControllerImpl {

    @Autowired
    CotizacionesRepository cotizacionesRepository;

    @Autowired
    CiudadRepository ciudadRepository;

    @Autowired
    PaisRepository paisRepository;

    @Override
    public List<CotizacionesDto> findAll(){
        List<CotizacionesEntity> entities = cotizacionesRepository.findAll();
        return MapEntityToDto(entities);
    }

    @Override
    public List<CotizacionesDto> save(CotizacionesDto cotizacionesDto){
        DateFormat dateFormat = new SimpleDateFormat("YYYY-MM-dd HH:MM:ss");
        Date date = new Date();
        CotizacionesEntity cotizacionesEntity = new CotizacionesEntity();
        cotizacionesEntity.setNumeroCotizacion(cotizacionesDto.getNumeroCotizacion());
        cotizacionesEntity.setEstado("Creada");
        cotizacionesEntity.setFechaCreacion(dateFormat.format(date));
        cotizacionesEntity.setVigenciaCotizacion(cotizacionesDto.getVigenciaCotizacion());
        cotizacionesEntity.setMoneda(cotizacionesDto.getMoneda());
        cotizacionesEntity.setNaviera(cotizacionesDto.getNaviera());
        cotizacionesEntity.setMercancia(cotizacionesDto.getMercancia());
        cotizacionesEntity.setValorMercancia(cotizacionesDto.getValorMercancia());

        CiudadEntity ciudadEntity = new CiudadEntity();
        ciudadEntity.setId(cotizacionesDto.getIdCiudadOrigen().getId());
        cotizacionesEntity.setCiudadOrigen(ciudadEntity);
        ciudadEntity.setId(cotizacionesDto.getIdCiudadDestino().getId());
        cotizacionesEntity.setCiudadDestino(ciudadEntity);

        cotizacionesRepository.save(cotizacionesEntity);
        List<CotizacionesEntity> entities = cotizacionesRepository.findAll();
        return MapEntityToDto(entities);
    }

    @Override
    public List<CotizacionesDto> update(String id, CotizacionesDto cotizacionesDto){
        DateFormat dateFormat = new SimpleDateFormat("YYYY-MM-dd HH:MM:ss");
        Date date = new Date();
        CotizacionesEntity cotizacionesEntity = new CotizacionesEntity();
        List<CotizacionesEntity> entities = cotizacionesRepository.findById(id).stream().collect(Collectors.toList());
        cotizacionesEntity.setNumeroCotizacion(id);
        switch (cotizacionesDto.getEstado()){
            case "Modificada":
                cotizacionesEntity.setEstado("Modificada");
                cotizacionesEntity.setFechaModificacion(dateFormat.format(date));

                cotizacionesEntity.setFechaCreacion(entities.get(0).getFechaCreacion());

                break;
            case "Cerrada":
                cotizacionesEntity.setEstado("Cerrada");
                cotizacionesEntity.setFechaCierre(dateFormat.format(date));

                cotizacionesEntity.setFechaCreacion(entities.get(0).getFechaCreacion());
                cotizacionesEntity.setFechaModificacion(entities.get(0).getFechaModificacion());

                break;
        }
        if (cotizacionesDto.getVigenciaCotizacion()==""){
            cotizacionesEntity.setVigenciaCotizacion(entities.get(0).getVigenciaCotizacion());
        }else{
            cotizacionesEntity.setVigenciaCotizacion(cotizacionesDto.getVigenciaCotizacion());
        }

        if (cotizacionesDto.getMoneda()==""){
            cotizacionesEntity.setMoneda(entities.get(0).getMoneda());
        }else{
            cotizacionesEntity.setMoneda(cotizacionesDto.getMoneda());
        }

        if (cotizacionesDto.getNaviera()==""){
            cotizacionesEntity.setNaviera(entities.get(0).getNaviera());
        }else{
            cotizacionesEntity.setNaviera(cotizacionesDto.getNaviera());
        }

        if (cotizacionesDto.getMercancia()==""){
            cotizacionesEntity.setMercancia(entities.get(0).getMercancia());
        }else{
            cotizacionesEntity.setMercancia(cotizacionesDto.getMercancia());
        }

        if (cotizacionesDto.getValorMercancia()==0){
            cotizacionesEntity.setValorMercancia(entities.get(0).getValorMercancia());
        }else{
            cotizacionesEntity.setValorMercancia(cotizacionesDto.getValorMercancia());
        }

        CiudadEntity ciudadEntity = new CiudadEntity();

        if (cotizacionesDto.getIdCiudadOrigen().getId()==0){
            ciudadEntity.setId(entities.get(0).getCiudadOrigen().getId());
        }else{
            ciudadEntity.setId(cotizacionesDto.getIdCiudadOrigen().getId());
        }
        cotizacionesEntity.setCiudadOrigen(ciudadEntity);

        if (cotizacionesDto.getValorMercancia()==0){
            ciudadEntity.setId(entities.get(0).getCiudadDestino().getId());
        }else{
            ciudadEntity.setId(cotizacionesDto.getIdCiudadDestino().getId());
        }
        cotizacionesEntity.setCiudadDestino(ciudadEntity);

        cotizacionesRepository.save(cotizacionesEntity);
        List<CotizacionesEntity> response = cotizacionesRepository.findById(id).stream().collect(Collectors.toList());
        return MapEntityToDto(response);
    }

    private List<CotizacionesDto> MapEntityToDto(List<CotizacionesEntity> cotizacionesEntity){
        List<CotizacionesDto> cotizacionesDto = new ArrayList<>();

        for (int i = 0; i < cotizacionesEntity.size(); i++){
            CotizacionesDto dto = new CotizacionesDto();
            dto.setNumeroCotizacion(cotizacionesEntity.get(i).getNumeroCotizacion());
            dto.setEstado(cotizacionesEntity.get(i).getEstado());
            dto.setFechaCreacion(cotizacionesEntity.get(i).getFechaCreacion());
            dto.setVigenciaCotizacion(cotizacionesEntity.get(i).getVigenciaCotizacion());
            dto.setMoneda(cotizacionesEntity.get(i).getMoneda());
            dto.setFechaModificacion(cotizacionesEntity.get(i).getFechaModificacion());
            dto.setNaviera(cotizacionesEntity.get(i).getNaviera());
            dto.setMercancia(cotizacionesEntity.get(i).getMercancia());
            dto.setValorMercancia(cotizacionesEntity.get(i).getValorMercancia());
            dto.setFechaCierre(cotizacionesEntity.get(i).getFechaCierre());

            dto.setIdCiudadDestino(ciudadDtoById(cotizacionesEntity.get(i).getCiudadDestino().getId()));
            dto.setIdCiudadOrigen(ciudadDtoById(cotizacionesEntity.get(i).getCiudadDestino().getId()));

            cotizacionesDto.add(dto);
        }
        return cotizacionesDto;
    }

    private CiudadDto ciudadDtoById(Long idCiudad){
        CiudadDto response = new CiudadDto();
        List<CiudadEntity> ciudadEntity = ciudadRepository.findById(idCiudad).stream().collect(Collectors.toList());
        response.setId(ciudadEntity.get(0).getId());
        response.setNombre(ciudadEntity.get(0).getNombre());
        response.setCodigo(ciudadEntity.get(0).getCodigo());
        response.setPais(paisDtoById(ciudadEntity.get(0).getPais().getId()));
        return response;
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
