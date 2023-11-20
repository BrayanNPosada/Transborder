package com.prueba.transborder.Controller;

import com.prueba.transborder.ControllerImpl.ListasControllerImpl;
import com.prueba.transborder.DTO.PokeDTO;
import com.prueba.transborder.Service.PokeService;
import liquibase.change.custom.CustomTaskChange;
import liquibase.change.custom.CustomTaskRollback;
import liquibase.database.Database;
import liquibase.exception.CustomChangeException;
import liquibase.exception.RollbackImpossibleException;
import liquibase.exception.SetupException;
import liquibase.exception.ValidationErrors;
import liquibase.resource.ResourceAccessor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import org.springframework.web.client.RestTemplate;

@Component
public class Pokeclase implements CustomTaskChange, CustomTaskRollback {

    @Autowired
    PokeService pokeService;

    @Override
    public void execute(Database database) throws CustomChangeException {
        pokeService.getDian();
    }

    @Override
    public String getConfirmationMessage() {
        return null;
    }

    @Override
    public void setUp() throws SetupException {

    }

    @Override
    public void setFileOpener(ResourceAccessor resourceAccessor) {

    }

    @Override
    public ValidationErrors validate(Database database) {
        return null;
    }

    @Override
    public void rollback(Database database) throws CustomChangeException, RollbackImpossibleException {

    }
}
