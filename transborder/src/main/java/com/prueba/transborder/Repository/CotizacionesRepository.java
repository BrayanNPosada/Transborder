package com.prueba.transborder.Repository;

import com.prueba.transborder.Entity.CotizacionesEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface CotizacionesRepository extends JpaRepository<CotizacionesEntity ,String> {
    @Query(value = "select * from cotizacion where DATE_FORMAT(fecha_creacion, '%Y-%m-%d' ) LIKE %?1%", nativeQuery = true)
    List<CotizacionesEntity> findByFechaCreacion(String fecha);

    @Query(value = "select c.numero_cotizacion,c.vigencia_cotizacion,c.naviera,c.mercancia,p.id,c.id_ciudad_destino from cotizacion c inner join ciudad ci inner join pais p", nativeQuery = true)
    List<String> findByStatus(String Status);

}
