package com.prueba.transborder.Controller;

import com.prueba.transborder.ControllerImpl.ListasControllerImpl;
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

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class ListasController implements ListasControllerImpl {

    @Autowired
    CotizacionesRepository cotizacionesRepository;

    @Autowired
    CiudadRepository ciudadRepository;

    @Autowired
    PaisRepository paisRepository;

    @Override
    public List<CotizacionesDto> findAllFechaCreacion(String fecha){
        List<CotizacionesEntity> cotizacionesEntity = cotizacionesRepository.findByFechaCreacion(fecha);

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

    @Override
    public List<CotizacionesDto> findAllStatus(String status){
        List<CotizacionesDto> cotizacionesDto = new ArrayList<>();
        List<CotizacionesEntity> cotizacionesEntity = cotizacionesRepository.findByStatus(status);
        for(int i=0; i< cotizacionesEntity.size(); i++) {
            CotizacionesDto dto = new CotizacionesDto();
            dto.setNumeroCotizacion(cotizacionesEntity.get(i).getNumeroCotizacion());
            dto.setVigenciaCotizacion(cotizacionesEntity.get(i).getNumeroCotizacion());
            dto.setNaviera(cotizacionesEntity.get(i).getNumeroCotizacion());
            dto.setMercancia(cotizacionesEntity.get(i).getNumeroCotizacion());

            CiudadDto ciuDto = new CiudadDto();
            ciuDto.setCodigo(ciudadRepository.findById(cotizacionesEntity.get(i).getCiudadDestino().getId()).get().getCodigo());

            PaisDto paisDto = new PaisDto();
            paisDto.setCodigo(paisRepository.findById(cotizacionesEntity.get(i).getCiudadDestino().getPais().getId()).get().getCodigo());
            ciuDto.setPais(paisDto);

            dto.setIdCiudadDestino(ciuDto);
            cotizacionesDto.add(dto);
        }


        return cotizacionesDto;
    }

    @Override
    public List<CotizacionesDto> findAllSemanaCreacion(String numeroSemana){
        List<CotizacionesEntity> cotizacionesEntity = cotizacionesRepository.findBySemanaCreacion(numeroSemana);

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

    @Override
    public List<CotizacionesDto> findAllCodePaisCiudad(String codPais,String codCiudad){
        List<CotizacionesEntity> cotizacionesEntity = cotizacionesRepository.findByPaisAndCuidad(codPais,codCiudad);

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
