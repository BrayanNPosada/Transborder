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

    @Query(value = "select c.*,p.id from cotizacion c inner join ciudad ci inner join pais p", nativeQuery = true)
    List<CotizacionesEntity> findByStatus(String Status);

    @Query(value = "select * from cotizacion where DATE_FORMAT(fecha_creacion, '%U' ) = ?1", nativeQuery = true)
    List<CotizacionesEntity> findBySemanaCreacion(String numeroSemana);

    @Query(value = "select c.* from cotizacion c inner join ciudad ci on c.id_ciudad_origen=ci.id inner join pais p\n" +
            "        where p.codigo =  ?1 and ci.codigo =  ?2", nativeQuery = true)
    List<CotizacionesEntity> findByPaisAndCuidad(String codPais,String codCiudad);

}
