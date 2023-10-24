package com.prueba.transborder.Repository;

import com.prueba.transborder.Entity.PaisEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PaisRepository extends JpaRepository<PaisEntity,Long> {

}
