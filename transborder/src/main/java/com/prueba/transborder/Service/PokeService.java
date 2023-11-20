package com.prueba.transborder.Service;
import java.util.Arrays;
import java.util.List;

import com.prueba.transborder.ControllerImpl.ListasControllerImpl;
import com.prueba.transborder.DTO.PokeDTO;
import com.prueba.transborder.DTO.Results;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

@Data
@Service
public class PokeService {

    @Autowired
    RestTemplate restTemplate;

    @Autowired
    ListasControllerImpl listasController;

    public void getDian(){
        RestTemplate restTemplate = new RestTemplate();
        PokeDTO dto = restTemplate.getForObject("https://pokeapi.co/api/v2/pokemon?limit=100000&offset=0", PokeDTO.class);
        listasController.savePoke(dto);

    }

}
