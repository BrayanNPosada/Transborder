package com.prueba.transborder.Repository;

import com.prueba.transborder.Entity.CiudadEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CiudadRepository extends JpaRepository<CiudadEntity,Long> {
}
