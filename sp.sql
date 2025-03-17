-- =============================================
-- Author@		Diego Suesca
-- Create date@ 2022-02-01
-- Description@	
-- =============================================
CREATE PROCEDURE [dbo].[USP_GET_CotizacionesActualizarTarifa] 
	@idLogCargaArchivo VARCHAR(20) = NULL,
	@fechaVigenciaDesde DATE = NULL,
	@tipoCarga VARCHAR (50) = NULL
	
AS
BEGIN	
	SET NOCOUNT ON;

BEGIN TRY	


	CREATE TABLE #cotizaciones
	(	id_cotizacion BIGINT,
		id_concepto BIGINT,
		id_tarifa_actualizada BIGINT,
		tipo_tarifa SMALLINT,
		fecha_creacion VARCHAR(10),
		estado VARCHAR(20),
		numero_instruccion_embarque VARCHAR(10),
		fecha_estimada_zarpe_buque VARCHAR(10),
		categoria SMALLINT,
		numero_cotizacion VARCHAR(30),
		usuario_asignado VARCHAR(100),
		id_cliente BIGINT,
		tipo_carga VARCHAR(100),
		id_tarifa_ant BIGINT
	);


	IF @tipoCarga IS NULL OR @tipoCarga = 'DEVOLUCION_CONTENEDOR_DESTINO_FCL'
	BEGIN

		SELECT old.*
		INTO #tarifasVig1
		FROM TARIFA_DEVOLUCION_CONTENEDOR_DESTINO_FCL_VIGENTE new
		JOIN TARIFA_DEVOLUCION_CONTENEDOR_DESTINO_FCL_VIGENTE old ON (new.id_ciudad_recogida_origen 	= old.id_ciudad_recogida_origen
        															AND new.id_ciudad_entrega_destino 	= old.id_ciudad_entrega_destino)
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo	  


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente,tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
				(SELECT MAX(tv.id_tarifa_devolucion_contenedor_destino_fcl) 
					FROM #tarifasVig1 tv
					WHERE tv.id_ciudad_recogida_origen = t.id_ciudad_recogida_origen
				  	  AND tv.id_ciudad_entrega_destino = t.id_ciudad_entrega_destino
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
				) id_tarifa_actualizada,
				1 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 2
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'DEVOLUCION_CONTENEDOR_DESTINO_FCL' AS tipo_carga,
				c.id_tarifa_devolucion_contenedor_destino_act as id_tarifa_ant
			FROM TARIFA_DEVOLUCION_CONTENEDOR_DESTINO_FCL t		
			JOIN CONCEPTO_DEVOLUCION_CONTENEDOR_DESTINO_FCL c ON c.id_tarifa_devolucion_contenedor_destino_act = t.id
			JOIN COTIZACION_FCL fcl ON fcl.id = c.id_cotizacion_fcl 
			JOIN COTIZACION cot ON cot.id = fcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL			  
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant;
		

		UPDATE concepto 
		SET concepto.id_tarifa_devolucion_contenedor_destino_act = c.id_tarifa_actualizada
		FROM CONCEPTO_DEVOLUCION_CONTENEDOR_DESTINO_FCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 1;
		  
	END

	IF @tipoCarga IS NULL OR @tipoCarga = 'RECARGOS_CARRIER_DESTINO_LCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig2
		FROM TARIFA_RECARGOS_CARRIER_DESTINO_LCL_VIGENTE new
		JOIN TARIFA_RECARGOS_CARRIER_DESTINO_LCL_VIGENTE old ON new.id_naviera_nvocc 	= old.id_naviera_nvocc
        													AND new.id_puerto_origen 	= old.id_puerto_origen
        													AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (

		SELECT cot.id AS id_cotizacion, c.id AS id_concepto,		
			(SELECT MAX(tv.id_tarifa_recargos_carrier_destino_lcl) 
						FROM #tarifasVig2 tv
						WHERE tv.id_naviera_nvocc = t.id_naviera_nvocc
					  	  AND tv.id_puerto_origen = t.id_puerto_origen
					  	  AND tv.id_puerto_destino = t.id_puerto_destino
					 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
					) id_tarifa_actualizada,

			 2 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'RECARGOS_CARRIER_DESTINO_LCL' AS tipo_carga,
				c.id_tarifa_recargos_carrier_destino_lcl_act as id_tarifa_ant
			FROM TARIFA_RECARGOS_CARRIER_DESTINO_LCL t
			JOIN CONCEPTO_RECARGOS_CARRIER_DESTINO_LCL c ON c.id_tarifa_recargos_carrier_destino_lcl_act = t.id
			JOIN COTIZACION_LCL lcl ON lcl.id = c.id_cotizacion_lcl 
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant

		 UPDATE concepto 
		SET concepto.id_tarifa_recargos_carrier_destino_lcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_RECARGOS_CARRIER_DESTINO_LCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 2;
	END

	
	IF @tipoCarga IS NULL OR @tipoCarga = 'RECARGOS_CARRIER_ORIGEN_LCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig3
		FROM TARIFA_RECARGOS_CARRIER_ORIGEN_LCL_VIGENTE new
		JOIN TARIFA_RECARGOS_CARRIER_ORIGEN_LCL_VIGENTE old ON new.id_naviera_nvocc 	= old.id_naviera_nvocc
        													AND new.id_puerto_origen 	= old.id_puerto_origen
        													AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)

		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_recargos_carrier_origen_lcl) 
						FROM #tarifasVig3 tv
						WHERE tv.id_naviera_nvocc = t.id_naviera_nvocc
					  	  AND tv.id_puerto_origen = t.id_puerto_origen
					  	  AND tv.id_puerto_destino = t.id_puerto_destino
					 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
					) id_tarifa_actualizada,

				3 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'RECARGOS_CARRIER_ORIGEN_LCL' AS tipo_carga,
				c.id_tarifa_recargos_carrier_origen_lcl_act as id_tarifa_ant
			FROM TARIFA_RECARGOS_CARRIER_ORIGEN_LCL t
			JOIN CONCEPTO_RECARGOS_CARRIER_ORIGEN_LCL c ON c.id_tarifa_recargos_carrier_origen_lcl_act = t.id
			JOIN COTIZACION_LCL lcl ON lcl.id = c.id_cotizacion_lcl 
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant


		UPDATE concepto 
		SET concepto.id_tarifa_recargos_carrier_origen_lcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_RECARGOS_CARRIER_ORIGEN_LCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 3;

	END

	IF @tipoCarga IS NULL OR @tipoCarga = 'FLETES_INTERNACIONALES_LCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig4Esp
		FROM TARIFA_FLETES_INTERNACIONAL_LCL_VIGENTE new
		JOIN TARIFA_FLETES_INTERNACIONAL_LCL_VIGENTE old ON new.id_naviera_nvocc 		= old.id_naviera_nvocc
        													AND new.id_puerto_origen 	= old.id_puerto_origen
        													AND new.id_puerto_destino 	= old.id_puerto_destino
        													AND new.tipo_tarifa 		= old.tipo_tarifa  
        													AND new.descripcion_tarifa = old.descripcion_tarifa      															
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo
		  AND new.tipo_tarifa = 'ESPECIFICA';


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_fletes_internacional_lcl) 
					FROM #tarifasVig4Esp tv
					WHERE tv.id_naviera_nvocc 	= t.id_naviera_nvocc
				  	  AND tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino
				  	  AND tv.tipo_tarifa 		= t.tipo_tarifa      
				  	  AND tv.descripcion_tarifa = t.descripcion_tarifa      			 
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
				) id_tarifa_actualizada,

			4 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'FLETES_INTERNACIONALES_LCL' AS tipo_carga,
				c.id_tarifa_fletes_internacional_lcl_act as id_tarifa_ant
			FROM TARIFA_FLETES_INTERNACIONAL_LCL t
			JOIN CONCEPTO_TARIFA_FLETES_INTERNACIONAL_LCL  c ON c.id_tarifa_fletes_internacional_lcl_act = t.id
			JOIN COTIZACION_LCL lcl ON lcl.id = c.id_cotizacion_lcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
			  AND t.tipo_tarifa = 'ESPECIFICA'
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant;

	


		SELECT old.*
		INTO #tarifasVig4Fak
		FROM TARIFA_FLETES_INTERNACIONAL_LCL_VIGENTE new
		JOIN TARIFA_FLETES_INTERNACIONAL_LCL_VIGENTE old ON new.id_naviera_nvocc 	= old.id_naviera_nvocc
        													AND new.id_puerto_origen 	= old.id_puerto_origen
        													AND new.id_puerto_destino 	= old.id_puerto_destino
        													AND new.tipo_tarifa 		= old.tipo_tarifa  

		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo
		  AND new.tipo_tarifa = 'FAK';


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_fletes_internacional_lcl) 
					FROM #tarifasVig4Fak tv
					WHERE tv.id_naviera_nvocc 	= t.id_naviera_nvocc
				  	  AND tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino
				  	  AND tv.tipo_tarifa 		= t.tipo_tarifa       
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
				) id_tarifa_actualizada,

			4 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'FLETES_INTERNACIONALES_LCL' AS tipo_carga,
				c.id_tarifa_fletes_internacional_lcl_act as id_tarifa_ant
			FROM TARIFA_FLETES_INTERNACIONAL_LCL t
			JOIN CONCEPTO_TARIFA_FLETES_INTERNACIONAL_LCL  c ON c.id_tarifa_fletes_internacional_lcl_act = t.id
			JOIN COTIZACION_LCL lcl ON lcl.id = c.id_cotizacion_lcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
			   AND t.tipo_tarifa = 'FAK'
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant;



		UPDATE concepto 
		SET concepto.id_tarifa_fletes_internacional_lcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_TARIFA_FLETES_INTERNACIONAL_LCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 4;


	END


	IF @tipoCarga IS NULL OR @tipoCarga = 'TRANSPORTE_TERRESTRE_DESTINO_LCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig5
		FROM TARIFA_TERRESTRE_DESTINO_LCL_VIGENTE new
		JOIN TARIFA_TERRESTRE_DESTINO_LCL_VIGENTE old ON new.id_ciudad_entrega_destino 	= old.id_ciudad_entrega_destino        													
        													AND new.id_puerto_destino 	= old.id_puerto_destino

		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_terrestre_destino_lcl)
					FROM #tarifasVig5 tv
					WHERE tv.id_ciudad_entrega_destino 	= t.id_ciudad_entrega_destino
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino			  	  
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
			) id_tarifa_actualizada,

			5 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'TRANSPORTE_TERRESTRE_DESTINO_LCL' AS tipo_carga,
				c.id_tarifa_terrestre_destino_lcl_act as id_tarifa_ant
			FROM TARIFA_TERRESTRE_DESTINO_LCL  t
			JOIN CONCEPTO_TERRESTRE_DESTINO_LCL c ON c.id_tarifa_terrestre_destino_lcl_act = t.id
			JOIN COTIZACION_LCL lcl ON lcl.id = c.id_cotizacion_lcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant


		UPDATE concepto 
		SET concepto.id_tarifa_terrestre_destino_lcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_TERRESTRE_DESTINO_LCL concepto
		JOIN #cotizaciones c
						ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 5;


	END



	IF @tipoCarga IS NULL OR @tipoCarga = 'TRANSPORTE_TERRESTRE_ORIGEN_LCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig6
		FROM TARIFA_TERRESTRE_ORIGEN_LCL_VIGENTE new
		JOIN TARIFA_TERRESTRE_ORIGEN_LCL_VIGENTE old ON new.id_ciudad_recogida_origen 	= old.id_ciudad_recogida_origen        													
        													AND new.id_puerto_origen 	= old.id_puerto_origen
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,			
			(SELECT MAX(tv.id_tarifa_terrestre_origen_lcl)
					FROM #tarifasVig6 tv
					WHERE tv.id_ciudad_recogida_origen 	= t.id_ciudad_recogida_origen
				  	  AND tv.id_puerto_origen 	= t.id_puerto_origen			  	  
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
			) id_tarifa_actualizada,

			6 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'TRANSPORTE_TERRESTRE_ORIGEN_LCL' AS tipo_carga,
				c.id_tarifa_terrestre_origen_lcl_act as id_tarifa_ant
			FROM TARIFA_TERRESTRE_ORIGEN_LCL t
			JOIN CONCEPTO_TERRESTRE_ORIGEN_LCL c ON c.id_tarifa_terrestre_origen_lcl_act = t.id
			JOIN COTIZACION_LCL lcl ON lcl.id = c.id_cotizacion_lcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant

		UPDATE concepto 
		SET concepto.id_tarifa_terrestre_origen_lcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_TERRESTRE_ORIGEN_LCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 6;

	END


	IF @tipoCarga IS NULL OR @tipoCarga = 'RECARGOS_CARRIER_DESTINO_FCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig7
		FROM TARIFA_RECARGOS_CARRIER_DESTINO_FCL_VIGENTE new
		JOIN TARIFA_RECARGOS_CARRIER_DESTINO_FCL_VIGENTE old ON new.id_naviera_nvocc 	= old.id_naviera_nvocc
        													AND new.id_puerto_origen 	= old.id_puerto_origen
        													AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_recargos_carrier_destino_fcl)
					FROM #tarifasVig7 tv
					WHERE tv.id_naviera_nvocc 	= t.id_naviera_nvocc				
				  	  AND tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino				  	  
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
			) id_tarifa_actualizada,

			 7 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'RECARGOS_CARRIER_DESTINO_FCL' AS tipo_carga,
				c.id_tarifa_recargos_carrier_destino_fcl_act as id_tarifa_ant
			FROM TARIFA_RECARGOS_CARRIER_DESTINO_FCL t
			JOIN CONCEPTO_RECARGOS_CARRIER_DESTINO_FCL c ON c.id_tarifa_recargos_carrier_destino_fcl_act = t.id
			JOIN COTIZACION_FCL fcl ON fcl.id = c.id_cotizacion_fcl
			JOIN COTIZACION cot ON cot.id = fcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant

		UPDATE concepto 
		SET concepto.id_tarifa_recargos_carrier_destino_fcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_RECARGOS_CARRIER_DESTINO_FCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 7;
	END


	IF @tipoCarga IS NULL OR @tipoCarga = 'RECARGOS_CARRIER_ORIGEN_FCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig8
		FROM TARIFA_RECARGOS_CARRIER_ORIGEN_FCL_VIGENTE new
		JOIN TARIFA_RECARGOS_CARRIER_ORIGEN_FCL_VIGENTE old ON new.id_naviera_nvocc 	= old.id_naviera_nvocc
        													AND new.id_puerto_origen 	= old.id_puerto_origen
        													AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_recargos_carrier_origen_fcl)
					FROM #tarifasVig8 tv
					WHERE tv.id_naviera_nvocc 	= t.id_naviera_nvocc				
				  	  AND tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino				  	  
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
			) id_tarifa_actualizada,

			8 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'RECARGOS_CARRIER_ORIGEN_FCL' AS tipo_carga,
				c.id_tarifa_recargos_carrier_origen_fcl_act as id_tarifa_ant
			FROM TARIFA_RECARGOS_CARRIER_ORIGEN_FCL t
			JOIN CONCEPTO_RECARGOS_CARRIER_ORIGEN_FCL c ON c.id_tarifa_recargos_carrier_origen_fcl_act = t.id
			JOIN COTIZACION_FCL lcl ON lcl.id = c.id_cotizacion_fcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant


		UPDATE concepto 
		SET concepto.id_tarifa_recargos_carrier_origen_fcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_RECARGOS_CARRIER_ORIGEN_FCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 8;

	END


	IF @tipoCarga IS NULL OR @tipoCarga = 'GASTOS_ORIGEN_FCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig9
		FROM TARIFA_GASTOS_ORIGEN_FCL_VIGENTE new
		JOIN TARIFA_GASTOS_ORIGEN_FCL_VIGENTE old ON new.id_puerto_origen 	= old.id_puerto_origen
        										 AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_gastos_origen_fcl)
					FROM #tarifasVig9 tv				
				  	  WHERE tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino				  	  
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
			) id_tarifa_actualizada,

			 9 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'GASTOS_ORIGEN_FCL' AS tipo_carga,
				c.id_tarifa_gastos_origen_fcl_act as id_tarifa_ant
			FROM TARIFA_GASTOS_ORIGEN_FCL t
			JOIN CONCEPTO_GASTOS_ORIGEN_FCL c ON c.id_tarifa_gastos_origen_fcl_act = t.id
			JOIN COTIZACION_FCL lcl ON lcl.id = c.id_cotizacion_fcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant



		UPDATE concepto 
		SET concepto.id_tarifa_gastos_origen_fcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_GASTOS_ORIGEN_FCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 9;

	END



	IF @tipoCarga IS NULL OR @tipoCarga = 'GASTOS_ORIGEN_LCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig10
		FROM TARIFA_GASTOS_ORIGEN_LCL_VIGENTE new
		JOIN TARIFA_GASTOS_ORIGEN_LCL_VIGENTE old ON new.id_puerto_origen 	= old.id_puerto_origen
        										 AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion,  c.id AS id_concepto,		
			(SELECT MAX(tv.id_tarifa_gastos_origen_lcl)
					FROM #tarifasVig10 tv				
				  	  WHERE tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino				  	  
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
			) id_tarifa_actualizada,

			10 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'GASTOS_ORIGEN_LCL' AS tipo_carga,
				c.id_tarifa_gastos_origen_lcl_act as id_tarifa_ant
			FROM TARIFA_GASTOS_ORIGEN_LCL t
			JOIN CONCEPTO_GASTOS_ORIGEN_LCL c ON c.id_tarifa_gastos_origen_lcl_act = t.id
			JOIN COTIZACION_LCL lcl ON lcl.id = c.id_cotizacion_lcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant


		UPDATE concepto 
		SET concepto.id_tarifa_gastos_origen_lcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_GASTOS_ORIGEN_LCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 10;	


	END 


	IF @tipoCarga IS NULL OR @tipoCarga = 'FLETES_INTERNACIONALES_FCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig11Esp
		FROM TARIFA_FLETE_INTERNACIONAL_FCL_VIGENTE new
		JOIN TARIFA_FLETE_INTERNACIONAL_FCL_VIGENTE old ON new.id_naviera 	= old.id_naviera
        													AND new.id_puerto_origen 	= old.id_puerto_origen
        													AND new.id_puerto_destino 	= old.id_puerto_destino
        													AND new.tipo_tarifa 		= old.tipo_tarifa      
			  	  											AND new.descripcion_tarifa = old.descripcion_tarifa    

		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo
		  AND new.tipo_tarifa = 'ESPECIFICA';



		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion,  c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_flete_internacional_fcl) 
					FROM #tarifasVig11Esp tv
					WHERE tv.id_naviera 	= t.id_naviera
				  	  AND tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino
				  	  AND tv.tipo_tarifa 		= t.tipo_tarifa      
				  	  AND tv.descripcion_tarifa = t.descripcion_tarifa      			 
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
				) id_tarifa_actualizada,

			11 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'FLETES_INTERNACIONALES_FCL' AS tipo_carga,
				c.id_tarifa_flete_internacional_fcl_act as id_tarifa_ant
			FROM TARIFA_FLETE_INTERNACIONAL_FCL t
			JOIN CONCEPTO_TARIFA_FLETE_INTERNACIONAL_FCL c ON c.id_tarifa_flete_internacional_fcl_act = t.id
			JOIN COTIZACION_FCL fcl ON fcl.id = c.id_cotizacion_fcl
			JOIN COTIZACION cot ON cot.id = fcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
			  AND t.tipo_tarifa = 'ESPECIFICA'
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant;



		SELECT old.*
		INTO #tarifasVig11Fak
		FROM TARIFA_FLETE_INTERNACIONAL_FCL_VIGENTE new
		JOIN TARIFA_FLETE_INTERNACIONAL_FCL_VIGENTE old ON new.id_naviera 	= old.id_naviera
        													AND new.id_puerto_origen 	= old.id_puerto_origen
        													AND new.id_puerto_destino 	= old.id_puerto_destino
        													AND new.tipo_tarifa 		= old.tipo_tarifa      
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo
		  AND new.tipo_tarifa = 'FAK';



		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion,  c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_flete_internacional_fcl) 
					FROM #tarifasVig11Fak tv
					WHERE tv.id_naviera 	= t.id_naviera
				  	  AND tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino
				  	  AND tv.tipo_tarifa 		= t.tipo_tarifa      			  	      			 
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
				) id_tarifa_actualizada,

			11 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'FLETES_INTERNACIONALES_FCL' AS tipo_carga,
				c.id_tarifa_flete_internacional_fcl_act as id_tarifa_ant
			FROM TARIFA_FLETE_INTERNACIONAL_FCL t
			JOIN CONCEPTO_TARIFA_FLETE_INTERNACIONAL_FCL c ON c.id_tarifa_flete_internacional_fcl_act = t.id
			JOIN COTIZACION_FCL fcl ON fcl.id = c.id_cotizacion_fcl
			JOIN COTIZACION cot ON cot.id = fcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
			  AND t.tipo_tarifa = 'FAK'
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant;
		   

		UPDATE concepto 
		SET concepto.id_tarifa_flete_internacional_fcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_TARIFA_FLETE_INTERNACIONAL_FCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 11;

	END


	IF @tipoCarga IS NULL OR @tipoCarga = 'TRANSPORTE_TERRESTRE_DESTINO_FCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig12
		FROM TARIFA_TERRESTRE_DESTINO_FCL_VIGENTE new
		JOIN TARIFA_TERRESTRE_DESTINO_FCL_VIGENTE old ON new.id_ciudad_entrega_destino 	= old.id_ciudad_entrega_destino        													
        													AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;



		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion,  c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_terrestre_destino_fcl) 
					FROM #tarifasVig12 tv
					WHERE tv.id_ciudad_entrega_destino 	= t.id_ciudad_entrega_destino
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
				) id_tarifa_actualizada,

			12 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'TRANSPORTE_TERRESTRE_DESTINO_FCL' AS tipo_carga,
				c.id_tarifa_terrestre_destino_fcl_act as id_tarifa_ant
			FROM TARIFA_TERRESTRE_DESTINO_FCL t
			JOIN CONCEPTO_TERRESTRE_DESTINO_FCL c ON c.id_tarifa_terrestre_destino_fcl_act = t.id
			JOIN COTIZACION_FCL fcl ON fcl.id = c.id_cotizacion_fcl
			JOIN COTIZACION cot ON cot.id = fcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant

		UPDATE concepto 
		SET concepto.id_tarifa_terrestre_destino_fcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_TERRESTRE_DESTINO_FCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 12;

	END


	IF @tipoCarga IS NULL OR @tipoCarga = 'TRANSPORTE_TERRESTRE_ORIGEN_FCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig13
		FROM TARIFA_TERRESTRE_ORIGEN_FCL_VIGENTE new
		JOIN TARIFA_TERRESTRE_ORIGEN_FCL_VIGENTE old ON new.id_ciudad_recogida_origen 	= old.id_ciudad_recogida_origen        													
        													AND new.id_puerto_origen 	= old.id_puerto_origen
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion,  c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_terrestre_origen_fcl) 
					FROM #tarifasVig13 tv
					WHERE tv.id_ciudad_recogida_origen 	= t.id_ciudad_recogida_origen
				  	  AND tv.id_puerto_origen 	= t.id_puerto_origen
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
				) id_tarifa_actualizada,

			13 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'TRANSPORTE_TERRESTRE_ORIGEN_FCL' AS tipo_carga,
				c.id_tarifa_terrestre_origen_fcl_act as id_tarifa_ant
			FROM TARIFA_TERRESTRE_ORIGEN_FCL t
			JOIN CONCEPTO_TERRESTRE_ORIGEN_FCL c ON c.id_tarifa_terrestre_origen_fcl_act = t.id
			JOIN COTIZACION_FCL fcl ON fcl.id = c.id_cotizacion_fcl
			JOIN COTIZACION cot ON cot.id = fcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant


		UPDATE concepto 
		SET concepto.id_tarifa_terrestre_origen_fcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_TERRESTRE_ORIGEN_FCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 13;


	IF @tipoCarga IS NULL OR @tipoCarga = 'GASTOS_DESTINO_FCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig14
		FROM TARIFA_GASTOS_DESTINO_FCL_VIGENTE new
		JOIN TARIFA_GASTOS_DESTINO_FCL_VIGENTE old ON new.id_puerto_origen 	= old.id_puerto_origen
        										 AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion, c.id AS id_concepto,
			(SELECT MAX(tv.id_tarifa_gastos_destino_fcl)
					FROM #tarifasVig14 tv				
				  	  WHERE tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino				  	  
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
			) id_tarifa_actualizada,

			 14 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'GASTOS_DESTINO_FCL' AS tipo_carga,
				c.id_tarifa_gastos_destino_fcl_act as id_tarifa_ant
			FROM TARIFA_GASTOS_DESTINO_FCL t
			JOIN CONCEPTO_GASTOS_DESTINO_FCL c ON c.id_tarifa_gastos_destino_fcl_act = t.id
			JOIN COTIZACION_FCL lcl ON lcl.id = c.id_cotizacion_fcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant



		UPDATE concepto 
		SET concepto.id_tarifa_gastos_destino_fcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_GASTOS_DESTINO_FCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 14;

	END



	IF @tipoCarga IS NULL OR @tipoCarga = 'GASTOS_DESTINO_LCL'
	BEGIN
		SELECT old.*
		INTO #tarifasVig15
		FROM TARIFA_GASTOS_DESTINO_LCL_VIGENTE new
		JOIN TARIFA_GASTOS_DESTINO_LCL_VIGENTE old ON new.id_puerto_origen 	= old.id_puerto_origen
        										 AND new.id_puerto_destino 	= old.id_puerto_destino
		WHERE new.id_Log_carga_archivo = @idLogCargaArchivo;


		INSERT #cotizaciones (id_cotizacion ,id_concepto ,id_tarifa_actualizada, tipo_tarifa, fecha_creacion, estado , numero_instruccion_embarque , fecha_estimada_zarpe_buque, categoria, numero_cotizacion, usuario_asignado, id_cliente, tipo_carga, id_tarifa_ant)
		SELECT * FROM (
			SELECT cot.id AS id_cotizacion,  c.id AS id_concepto,		
			(SELECT MAX(tv.id_tarifa_gastos_destino_lcl)
					FROM #tarifasVig15 tv				
				  	  WHERE tv.id_puerto_origen 	= t.id_puerto_origen
				  	  AND tv.id_puerto_destino 	= t.id_puerto_destino				  	  
				 	  AND cot.fecha_estimada_embarque BETWEEN tv.vigencia_desde AND tv.vigencia_hasta
			) id_tarifa_actualizada,

			15 AS tipo_tarifa, 
				CONVERT(varchar, cot.fecha_creacion, 103) fecha_creacion, 
				cot.estado, 
				ISNULL(ie.numero_instruccion_embarque,'No aplica') numero_instruccion_embarque, 
				CASE WHEN ie.fecha_estimada_zarpe_buque IS NULL THEN 'No aplica' ELSE CONVERT(varchar, ie.fecha_estimada_zarpe_buque, 103) END fecha_estimada_zarpe_buque,
				CASE WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NOT NULL THEN 1
					WHEN cot.estado = 'PREP_INST_EMBARQ_ENV' AND ie.fecha_estimada_zarpe_buque IS NULL THEN 1
					ELSE 3 END categoria,
				cot.numero_cotizacion,
				cot.usuario_asignado,
				cot.id_cliente,
				'GASTOS_DESTINO_LCL' AS tipo_carga,
				c.id_tarifa_gastos_destino_lcl_act as id_tarifa_ant
			FROM TARIFA_GASTOS_DESTINO_LCL t
			JOIN CONCEPTO_GASTOS_DESTINO_LCL c ON c.id_tarifa_gastos_destino_lcl_act = t.id
			JOIN COTIZACION_LCL lcl ON lcl.id = c.id_cotizacion_lcl
			JOIN COTIZACION cot ON cot.id = lcl.id_cotizacion
			LEFT JOIN INSTRUCCION_EMBARQUE ie ON ie.id = cot.id_instruccion_embarque
			WHERE cot.estado IN ('PREP_INST_EMBARQ_ENV','PENDIENTE_ACEPTACION','ACEPTADA')
			  AND cot.versionada IS NULL
		) A
		WHERE id_tarifa_actualizada IS NOT NULL AND id_tarifa_actualizada <> id_tarifa_ant


		UPDATE concepto 
		SET concepto.id_tarifa_gastos_destino_lcl_act = c.id_tarifa_actualizada
		FROM CONCEPTO_GASTOS_DESTINO_LCL concepto
		JOIN #cotizaciones c
							ON c.id_concepto = concepto.id
		WHERE c.tipo_tarifa = 15;	


	END

	END


	-- FIN UPDATES

	SELECT DISTINCT c.id_cotizacion, --0
		cli.razon_social, --1
		c.fecha_creacion, -- 2
		c.estado,			--3
		c.numero_instruccion_embarque,  --4
		c.fecha_estimada_zarpe_buque, -- 5,
		c.numero_cotizacion, -- 6
		c.usuario_asignado, --7
		c.categoria,
		c.tipo_tarifa,
		c.tipo_carga
	FROM #cotizaciones c
	JOIN CLIENTE cli ON cli.id = c.id_cliente
	ORDER BY c.usuario_asignado, c.categoria, c.fecha_creacion

END TRY
BEGIN CATCH
	INSERT RegistroLog (relFecha, relErrorMessage, relParametrosEjecucion) 
	VALUES(dbo.GetLocalDateTime(), ERROR_MESSAGE(), 
			'dbo.USP_GET_CotizacionesActualizarTarifa');
	THROW;
END CATCH
END