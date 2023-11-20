package com.prueba.transborder.Repository;

import com.prueba.transborder.Entity.PokeEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PokeRepository extends JpaRepository<PokeEntity,Long> {

}
