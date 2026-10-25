// Catálogo técnico de especialidades, subcategorías y observaciones típicas recurrentes (QA/QC)
// Actualizado con las definiciones objetivas y sin juicios de causalidad prematuros según RNE y especificaciones
export const TYPICAL_DEFECTS_CATALOG: Record<string, Record<string, string[]>> = {
  'Arquitectura y acabados': {
    'Muros, tabiques y revoques': [
      'Fisura visible en muro o tabique (registrar ubicación, orientación y ancho aprox.)',
      'Desviación aparente de verticalidad en muro (registrar medición instrumental)',
      'Irregularidad superficial o abombamiento aparente en muro',
      'Fisura en encuentro entre muro y elemento constructivo',
      'Desprendimiento o sonido hueco en revoque/tarrajeo al percutir suavemente'
    ],
    'Paredes y muros': [
      'Fisura visible en muro o tabique (registrar ubicación, orientación y ancho aprox.)',
      'Desviación aparente de verticalidad en tabique (registrar medición)',
      'Irregularidad superficial o abombamiento aparente en muro',
      'Fisura en encuentro entre muro y columna o viga',
      'Humedad o eflorescencia salina visible en muro'
    ],
    'Tarrajeo y enlucidos': [
      'Desprendimiento o sonido hueco en revoque/tarrajeo al percutir suavemente',
      'Rugosidad excesiva o falta de afinado homogéneo en tarrajeo',
      'Porosidad abierta y coqueras en esquinas de vanos',
      'Encuentros muro-columna sin bruña de dilatación prevista'
    ],
    'Empaste y pintura': [
      'Pintura con marcas de aplicación, traslapes o acabado irregular bajo luz rasante',
      'Pintura con ampollamiento, descascaramiento o pérdida visible de adherencia',
      'Variación de tonalidad o manchas de obra en pintura',
      'Empaste con rayaduras o masillado irregular visible',
      'Falta de segunda mano de pintura o cobertura incompleta en recortes perimetrales'
    ],
    'Cielos rasos y bruñas': [
      'Desnivel, deformación o pandeo visible en cielo raso',
      'Fisura visible en junta de placas de falso techo',
      'Bruña perimetral desalineada, con rebabas o remate deficiente',
      'Mancha visible en cielo raso (indicar si presenta humedad activa)'
    ],
    'Molduras y drywall': [
      'Fijaciones expuestas o sin masillar en placas de yeso/drywall',
      'Moldura decorativa despegada o con unión abierta en esquina',
      'Falta de refuerzo interno para soporte de cargas suspendidas'
    ],
    'Zócalos y contrazócalos': [
      'Zócalo suelto o con sonido hueco al percutir suavemente',
      'Sello superior elástico ausente o discontinuo en encuentro con muro (según detalle constructivo previsto)',
      'Corte visiblemente astillado o junta abierta entre piezas de zócalo',
      'Desalineación de plomo en encuentros de esquinas'
    ]
  },
  'Pisos y revestimientos': {
    'Porcelanato y cerámicos': [
      'Diferencia de nivel entre piezas de revestimiento (cejas; registrar medición instrumental)',
      'Pieza de revestimiento desportillada, fisurada o quiñada',
      'Pieza cerámica suelta o con sonido hueco al percutir suavemente',
      'Diferencia visible de lote o tono entre baldosas instaladas'
    ],
    'Pisos laminados': [
      'Piso laminado presenta zona amortiguada o hundimiento aparente al pisar',
      'Piso con crujidos, piezas con movimiento perceptible o juntas deterioradas',
      'Separación o junta abierta visible entre tablas de piso flotante',
      'Pérdida de capa protectora o rayas visibles de obra'
    ],
    'Pisos vinílicos': [
      'Ampollamiento o burbujas de aire visibles bajo el vinílico',
      'Despegue en extremos o juntas de traslape',
      'Marcas o hendiduras por base irregular'
    ],
    'Juntas y alineación': [
      'Líneas de junta desalineadas o fuera de escuadra geométrica',
      'Ancho irregular en juntas de colocación entre baldosas',
      'Junta de dilatación estructural obstruida o sin elastómero previsto'
    ],
    'Fragua y encuentros': [
      'Fragua decolorada, manchada o con tonalidad dispareja',
      'Fragua fisurada, porosa o con desprendimiento de material',
      'Falta de limpieza final de fragua (velo cementicio superficial)'
    ],
    'Nivelación y pendientes': [
      'Evacuación deficiente o empozamiento de agua durante prueba (registrar método y duración)',
      'Diferencia de nivel perceptible en umbral de paso entre ambientes contiguos',
      'Pendiente con dirección contraria al punto de desagüe'
    ]
  },
  'Carpintería de madera y melamina': {
    'Puertas interiores': [
      'Puerta presenta rozamiento con el marco o con el piso al abrir/cerrar',
      'Hoja de puerta presenta desviación o alabeo visible',
      'Holgura perimetral irregular entre hoja y marco de puerta'
    ],
    'Puerta principal y marcos': [
      'Puerta principal presenta rozamiento con el marco o con el piso al abrir/cerrar',
      'Holgura perimetral irregular entre hoja y marco de puerta',
      'Marco de puerta con desaplomado o fijación deficiente al muro',
      'Acabado o barniz con rayaduras o manchas de obra'
    ],
    'Clósets y vestidores': [
      'Puerta corrediza de clóset trabada o con dificultad de rodadura en riel',
      'Puerta batiente desalineada o sin retención adecuada',
      'Cajonera con correderas duras o roce en estructura del mueble',
      'Repisa interior presenta deformación visible o canto desprendido'
    ],
    'Muebles de cocina (altos/bajos)': [
      'Puerta de repostero desalineada o con rozamiento al cerrar',
      'Puerta que no mantiene su posición de apertura o cierre',
      'Módulo con fijación aparentemente deficiente al muro',
      'Fondo del mueble deteriorado o con indicios de humedad',
      'Mecanismo de cierre suave no funciona o mecanismo ofrecido no instalado (cuando corresponda a lo contratado)',
      'Bisagra floja o con fijación deficiente en panel de melamina',
      'Cajón presenta dificultad de desplazamiento o traba en correderas',
      'Tapacanto de melamina despegado, astillado o con filo cortante'
    ],
    'Cajones y correderas': [
      'Cajonera descolgada o con roce lateral',
      'Freno o mecanismo de autocierre de corredera inoperativo',
      'Tiradores o jaladores flojos o desalineados'
    ],
    'Tapacantos y repisas': [
      'Tapacanto PVC desprendido en bordes expuestos',
      'Filos cortantes en cantos de melamina sin perfilar',
      'Tapa-tornillos adhesivos embellecedores faltantes'
    ]
  },
  'Carpintería de aluminio, vidrio y mamparas': {
    'Ventanas corredizas y proyectantes': [
      'Hoja corrediza presenta dificultad o resistencia de desplazamiento en rieles',
      'Cierre incompleto, holgura perceptible o mecanismo de apertura que no opera correctamente',
      'Seguros, pestillos o mecanismos de cierre no traban o presentan desalineación',
      'Falta de orificios de desagüe pluvial (lloraderos) en perfil de ventana',
      'Sellado perimetral con discontinuidades visibles y entrada de aire o agua observada en prueba'
    ],
    'Mamparas corredizas': [
      'Mampara corrediza presenta dificultad de desplazamiento o atasco en riel',
      'Seguros, pestillos o mecanismos de cierre no traban o presentan desalineación',
      'Riel inferior deformado o con tornillos sobresalientes',
      'Cierre perimetral con holgura que permite ingreso de polvo o viento'
    ],
    'Perfiles de aluminio': [
      'Perfil de aluminio abollado, quiñado o con pintura rayada',
      'Uniones a inglete abiertas en esquinas de marco',
      'Tapas embellecedoras ausentes en extremos de perfiles'
    ],
    'Felpas y hermeticidad': [
      'Felpa perimetral ausente, deteriorada o desprendida',
      'Sellado perimetral exterior con discontinuidades visibles',
      'Espacio visible entre perfiles en posición cerrada'
    ],
    'Vidrios y cristales templados': [
      'Vidrio o cristal con rayadura, quiñe o daño superficial visible',
      'Presencia de burbujas internas o quiñes en bordes',
      'Manchas de salpicadura de soldadura o pintura difíciles de remover',
      'Grabado reglamentario de vidrio de seguridad ausente (según especificación)'
    ],
    'Barandas acristaladas': [
      'Baranda con movimiento perceptible o fijación aparentemente deficiente; restringir el uso y solicitar evaluación si existen indicios de inseguridad',
      'Vidrio de baranda con daño superficial, quiñe o astillado visible (contrastar aptitud con especificación)',
      'Pasamanos desalineado o con aristas vivas'
    ]
  },
  'Cerrajería y herrajes': {
    'Cerraduras principales e interiores': [
      'Cerradura presenta dificultad u oposición al giro de la llave',
      'Pestillo no encaja suavemente en el recibidor del marco',
      'Contrafrontal desalineado impidiendo el cierre sin empujar con fuerza',
      'Cilindro de seguridad con juego o tambaleo'
    ],
    'Pestillos y cerrojos': [
      'Cerradura o cerrojo de baño presenta traba o dificultad de operación',
      'Pestillo magnético sin fuerza de retención',
      'Falta de holgura para el ingreso del pestillo en el marco'
    ],
    'Bisagras y topes de piso': [
      'Bisagras ruidosas o con restos de pintura de obra',
      'Falta de tornillos en paletas de bisagras',
      'Tope de puerta ausente o no evita contacto de manija con muro (verificar especificación)',
      'Tope de piso flojo o despegado'
    ],
    'Manijas y manijones': [
      'Manija de puerta floja o con juego axial perceptible',
      'Manija caída o con resorte de retorno vencido',
      'Acabado metálico con rayaduras o desprendimiento'
    ],
    'Jaladores de muebles': [
      'Jalador de clóset o repostero desalineado respecto al adyacente',
      'Tornillo de sujeción sobresaliente en el interior del cajón'
    ]
  },
  'Instalaciones eléctricas': {
    'Tomacorrientes 220V': [
      'Tomacorriente con resultado anómalo en la comprobación realizada; requiere verificación eléctrica',
      'Indicación de anomalía en la comprobación de puesta a tierra (especificar método e instrumento utilizado)',
      'Placa de tomacorriente floja, desaplomada o separada del muro',
      'Placa ubicada en posición diferente a la indicada en plano de acabados'
    ],
    'Interruptores y conmutadores': [
      'Interruptor no acciona el centro de luz correspondiente',
      'Interruptor conmutador no conmuta la luminaria desde uno de los puntos',
      'Mecanismo de balancín duro o trabado',
      'Placa sucia con salpicaduras de pintura o rajada'
    ],
    'Puntos de luz y luminarias': [
      'Centro de iluminación sin respuesta en la prueba o accesorio flojo/dañado',
      'Punto de luz descentrado respecto al eje del ambiente',
      'Portalámparas provisional quebrado o con falso contacto'
    ],
    'Tablero General (TG)': [
      'Tablero general sin leyenda o rotulación identificando circuitos',
      'Interruptor diferencial: prueba funcional mediante botón TEST no satisfactoria (cuando la prueba esté contemplada y pueda realizarse de forma segura)',
      'Conexión de puesta a tierra del gabinete metálico o tapa: por verificar',
      'Llaves termomagnéticas flojas en riel DIN'
    ],
    'Llaves termomagnéticas y diferenciales': [
      'Interruptor diferencial: prueba funcional mediante botón TEST no satisfactoria',
      'Dispositivo flojo o mal anclado en riel DIN',
      'Falta de peineta de interconexión reglamentaria'
    ],
    'Puesta a tierra': [
      'Indicación de anomalía en la comprobación de puesta a tierra',
      'Conexión de puesta a tierra del gabinete o tapa: por verificar'
    ]
  },
  'Instalaciones sanitarias': {
    'Redes accesibles y llaves de paso': [
      'Llave de paso de agua presenta goteo o fuga visible',
      'Llave de corte general de agua inaccesible o de difícil operación',
      'Tubería visible con marcas de golpe o soporte flojo'
    ],
    'Puntos de lavadora': [
      'Ausencia del punto previsto en planos, fuga en la llave de agua o drenaje que presenta evacuación deficiente',
      'Punto de desagüe de lavadora: ubicación o altura por verificar con plano o especificación de referencia',
      'Llave de corte de agua de lavadora presenta fuga o goteo al abrir'
    ],
    'Desagües y ventilación sanitaria': [
      'Evacuación lenta en trampa de desagüe o retorno de olores',
      'Tapa de registro roscado no asienta al ras de piso terminado',
      'Filtro o rejilla de sumidero floja o atascada'
    ]
  },
  'Aparatos sanitarios y griferías': {
    'Inodoro y accesorios': [
      'Inodoro presenta movimiento al aplicar una comprobación suave',
      'Descarga con funcionamiento irregular, llenado continuo del tanque o fuga visible después de accionar la descarga',
      'Fuga o goteo visible en válvula de abasto o manguera flexible de conexión',
      'Sello perimetral en la base del aparato ausente o deteriorado'
    ],
    'Lavatorios y pedestales': [
      'Lavatorio presenta movimiento al aplicar una comprobación suave',
      'Grifería presenta goteo o fuga en caño, maneral o base',
      'Evacuación lenta de agua en el pozuelo durante la prueba realizada',
      'Caudal irregular o dificultad para operar el mando de la grifería',
      'Disposición de agua fría/caliente no conforme con lo esperado o especificado'
    ],
    'Lavaderos de cocina / lavandería': [
      'Grifería presenta goteo o fuga visible en caño, maneral o base',
      'Pozuelo de lavadero con retención de agua o evacuación lenta durante prueba de descarga',
      'Fuga visible en conexiones accesibles o trampa de desagüe bajo el mueble',
      'Disposición de agua fría/caliente no conforme con lo especificado (verificar plano)'
    ],
    'Duchas y cabezales': [
      'Caudal irregular, fuga visible en conexiones accesibles o dificultad para operar el mando de la grifería',
      'Rociador de ducha con chorro obstruido o brazo con inclinación negativa',
      'Maneral de mezcladora flojo o con giro falseado'
    ],
    'Poza o lavadero de servicio': [
      'Poza de lavado presenta movimiento al aplicar una comprobación suave',
      'Grifería móvil presenta fuga o goteo en caño/flexible',
      'Evacuación lenta en trampa de desagüe'
    ]
  },
  'Evacuación e impermeabilización': {
    'Sumideros y drenajes': [
      'Evacuación deficiente o empozamiento de agua durante prueba en ducha (registrar método, duración y zona afectada)',
      'Evacuación deficiente o empozamiento de agua observado en piso durante prueba (registrar duración y zona)',
      'Sumidero con drenaje lento o cota de rejilla sobre nivel de piso'
    ],
    'Sellos y juntas húmedas': [
      'Sello perimetral elástico deteriorado o ausente en encuentro ducha-muro (según detalle constructivo)',
      'Ausencia o discontinuidad visible de sellos y paso de agua al exterior durante prueba controlada',
      'Sello elástico deteriorado en juntas de dilatación o encuentro de fachada'
    ]
  },
  'Gas y calentamiento de agua': {
    'Puntos y llaves de paso de gas': [
      'Acceso a llave de paso de gas obstruido o de difícil manipulación',
      'Válvula de corte de gas dura o con sello deteriorado',
      'Componente, conexión o condición de ventilación que requiere comprobación respecto del diseño del sistema',
      'Punto de conexión de gas sin tapón de protección reglamentario (cuando no haya equipo conectado)'
    ],
    'Rejillas y ventilación de gas': [
      'Rejilla de ventilación prevista ausente, obstruida o dañada; contrastar con el diseño y el sistema de gas',
      'Ducto de ventilación con restricción de paso de aire aparente'
    ],
    'Terma / Calentador de agua': [
      'Equipo que no enciende o no responde a los controles durante una prueba autorizada y segura, cuando esté incluido en la entrega',
      'Fuga o goteo visible en conexiones hidráulicas o descarga en válvula de alivio (indicar punto exacto y condición de funcionamiento del equipo)',
      'Ducto de evacuación de gases: trazado o pendiente por verificar respecto al proyecto (si es a gas)'
    ]
  },
  'Ventilación y climatización': {
    'Extractores de aire de baños': [
      'Extractor de aire sin funcionamiento en la prueba de encendido',
      'Extracción aparentemente insuficiente en la prueba realizada; requiere comprobación adicional si corresponde',
      'Extractor con ruido o vibración anormal durante el giro'
    ],
    'Rejillas y ductos': [
      'Rejilla de extracción atascada con polvo de obra o pintura',
      'Fijación suelta o marco despegado del cielo raso'
    ],
    'Preinstalación de aire acondicionado': [
      'Preinstalación de A/C: tubo de drenaje con obstrucción en prueba de purga',
      'Tapa de pase o caja de preinstalación ausente o dañada',
      'Puntos de preinstalación no coincidentes con el plano del proyecto'
    ]
  },
  'Equipamiento y electrodomésticos': {
    'Campana extractora': [
      'Campana extractora: funcionamiento o modalidad de extracción por verificar (recirculación o ducto exterior según proyecto)',
      'Filtros metálicos antigrasa abollados o mal asentados',
      'Botonera o iluminación de campana no responde'
    ],
    'Encimera (cocina empotrada)': [
      'Cocina encimera: equipo que no enciende o no responde a los controles durante prueba autorizada y segura',
      'Llama irregular con combustión deficiente observada',
      'Cubierta o quemador con rayaduras o manchas de obra'
    ],
    'Horno empotrado': [
      'Horno empotrado: puerta no asienta correctamente o selector no operativo',
      'Falta de ventilación perimetral requerida por fabricante en mueble'
    ],
    'Terma o calentador': [
      'Equipo que no enciende o no responde a los controles durante una prueba autorizada y segura, cuando esté incluido en la entrega',
      'Fuga o goteo visible en conexiones hidráulicas o descarga en válvula de alivio'
    ]
  },
  'Seguridad y elementos complementarios': {
    'Barandas y protección contra caídas': [
      'Baranda con movimiento perceptible, fijación aparentemente deficiente o daño visible que amerite evaluación de seguridad (restringir uso si existen indicios de inseguridad)',
      'Vidrio de baranda con daño superficial, quiñe o astillado visible (contrastar aptitud con especificación)'
    ],
    'Detectores y alarmas': [
      'Detector de humo: indicador de estado o prueba funcional no satisfactorios, según el modelo instalado',
      'Detector conserva cubierta plástica protectora de obra en el techo',
      'Dispositivo previsto no instalado según plano de equipamiento'
    ],
    'Válvulas de corte general': [
      'Llave general de corte de agua dura o no cierra en su totalidad',
      'Nicho de llaves de paso sin tapa o sin rotulación clara'
    ],
    'Intercomunicador': [
      'Intercomunicador: sin señal de llamada o sin comunicación audible con conserjería',
      'Pulsador de apertura remota no acciona cerradura eléctrica'
    ]
  },
  'Estructuras — inspección visual': {
    'Indicios en concreto y elementos constructivos': [
      'Indicio visual que requiere evaluación técnica especializada (registrar ubicación y foto con escala)',
      'Fisura visible en elemento de concreto ubicado en encuentro entre muro y losa/techo',
      'Desprendimiento de recubrimiento de concreto o armadura de refuerzo expuesta visible en elemento estructural'
    ]
  },
  'Documentación y correspondencia': {
    'Verificación contra planos y acabados': [
      'Componente previsto en planos o especificaciones que no se encuentra instalado, sujeto a contrastación documental',
      'Acabado, material o color aparentemente diferente al de la ficha técnica aprobada (distinguir diferencia aparente de discrepancia confirmada)',
      'Ubicación de punto de instalación difiere del plano proporcionado'
    ]
  },
  'Limpieza y entrega final': {
    'Limpieza profunda de obra': [
      'Manchas de pintura, silicona o adhesivo en cristales o perfiles',
      'Residuos de cemento o polvo de lijado en pisos, esquinas o muebles',
      'Plásticos o embalajes protectores de obra sin retirar'
    ]
  }
}
