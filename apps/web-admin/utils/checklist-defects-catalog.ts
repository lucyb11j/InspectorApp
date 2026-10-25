// Catálogo técnico de especialidades, subcategorías y observaciones típicas recurrentes (QA/QC)
export const TYPICAL_DEFECTS_CATALOG: Record<string, Record<string, string[]>> = {
  'Arquitectura y acabados': {
    'Paredes y muros': [
      'Fisura capilar diagonal en tabiquería o enlucido',
      'Desplome o falta de verticalidad en tabique (desviación > 3mm)',
      'Alabeo, panza o hendidura en superficie de muro',
      'Fisura en encuentro entre muro y losa/columna (junta fría)',
      'Humedad o eflorescencia salina visible en muro'
    ],
    'Tarrajeo y enlucidos': [
      'Desprendimiento o sonido a hueco en revoque/tarrajeo',
      'Rugosidad excesiva o falta de afinado en tarrajeo',
      'Porosidad abierta y coqueras en esquinas de vanos',
      'Encuentros muro-columna sin bruña de dilatación'
    ],
    'Empaste y pintura': [
      'Pintura con huellas visibles de rodillo o traslapes bajo luz rasante',
      'Ampollas, desprendimiento o falta de adherencia en pintura látex',
      'Variación de tonalidad o manchas de obra en pintura',
      'Empaste deficiente con rayaduras y masillado irregular',
      'Falta de segunda mano de pintura en recortes perimetrales'
    ],
    'Cielos rasos y bruñas': [
      'Desnivel o pandeo (deflexión) en falso techo de drywall',
      'Bruña arquitectónica perimetral desalineada o con rebabas',
      'Fisura longitudinal en junta de placas de yeso/drywall',
      'Mancha de condensación o filtración en cielo raso'
    ],
    'Molduras y drywall': [
      'Tornillos de fijación expuestos o sin masillar en drywall',
      'Moldura decorativa despegada o con unión abierta en esquina',
      'Falta de refuerzo interno para soporte de cargas suspendidas'
    ],
    'Zócalos y contrazócalos': [
      'Zócalo despegado o con sonido a hueco (falta de pegamento)',
      'Falta de sellado superior con masilla/silicona entre zócalo y muro',
      'Corte de zócalo astillado o junta abierta mayor a 2mm',
      'Desalineación de plomo en encuentros de esquinas'
    ]
  },
  'Pisos y revestimientos': {
    'Porcelanato y cerámicos': [
      'Presencia de cejas (desnivel entre piezas adyacentes > 1mm)',
      'Piezas desportilladas o quiñadas en esquinas',
      'Piezas cerámicas sueltas o con sonido a hueco al percutir',
      'Diferencia visible de lote o tono entre baldosas instaladas'
    ],
    'Pisos laminados': [
      'Piso laminado con sensación amortiguada o hundimiento al pisar',
      'Juntas abiertas entre tablas de piso flotante',
      'Levantamiento o englobamiento por falta de holgura perimetral',
      'Pérdida de capa protectora o rayas profundas de obra'
    ],
    'Pisos vinílicos': [
      'Ampollamiento o burbujas de aire atrapadas bajo el vinílico',
      'Despegue en extremos o juntas de traslape',
      'Marcas o hendiduras por base irregular sin nivelar'
    ],
    'Juntas y alineación': [
      'Líneas de junta desalineadas o fuera de escuadra geométrica',
      'Ancho irregular en juntas de colocación',
      'Junta de dilatación estructural obstruida o sin elastómero'
    ],
    'Fragua y encuentros': [
      'Fragua decolorada, manchada o con tonalidad dispareja',
      'Fragua fisurada, pulverulenta o con vacíos de llenado',
      'Falta de limpieza final de fragua (velo cementicio superficial)'
    ],
    'Nivelación y pendientes': [
      'Pendiente insuficiente hacia sumidero con acumulación de agua',
      'Desnivel marcado en umbral de paso entre ambientes contiguos',
      'Charcos o contrapendiente en zonas húmedas'
    ]
  },
  'Carpintería de madera y melamina': {
    'Puertas interiores': [
      'Puerta roza o raspa contra el marco o el piso al girar',
      'Alabeo o deformación en hoja de puerta interior',
      'Holgura perimetral irregular (luz mayor a 4mm o menor a 2mm)',
      'Chapa o manija suelta con holgura en pestillo'
    ],
    'Puerta principal y marcos': [
      'Cerradura de seguridad dura o pestillo no encaja con suavidad',
      'Marco de puerta desaplomado o con anclaje flojo al muro',
      'Defectos de acabado o barniz con rayaduras de obra',
      'Falta de sello acústico/cortaviento inferior'
    ],
    'Clósets y vestidores': [
      'Puertas corredizas se traban o descarrilan en riel superior/inferior',
      'Cajones con correderas telescópicas duras o desalineadas',
      'Tapacantos de melamina despegados o astillados',
      'Repisas interiores pandeadas o sin soporte intermedio'
    ],
    'Muebles de cocina (altos/bajos)': [
      'Puertas de reposteros desalineadas o sin cierre suave funcional',
      'Bisagras tipo cangrejo flojas o con tornillos falseados',
      'Fondo de mueble bajo con humedad o deformación',
      'Falta de sellado antihongos en unión con pared o tablero'
    ],
    'Cajones y correderas': [
      'Cajonera descolgada o con roce lateral',
      'Freno o autocierre de corredera inoperativo',
      'Tiradores o jaladores flojos y desalineados'
    ],
    'Tapacantos y repisas': [
      'Tapacanto PVC desprendido en bordes expuestos',
      'Filos cortantes en cantos de melamina sin perfilar',
      'Falta de tapatornillos adhesivos embellecedores'
    ]
  },
  'Carpintería de aluminio, vidrio y mamparas': {
    'Ventanas corredizas y proyectantes': [
      'Hoja de ventana atascada en riel por suciedad o deformación',
      'Seguro o pestillo caracol inoperativo / no traba',
      'Falta de orificios de desagüe pluvial (cortagotera/lloraderos) en perfil',
      'Filtración de aire o silbido por falta de felpas'
    ],
    'Mamparas corredizas': [
      'Mampara desencajada con cierre duro o falta de arrastre',
      'Riel inferior deformado o con tornillos sobresalientes',
      'Cierre perimetral no hermético con ingreso de polvo'
    ],
    'Perfiles de aluminio': [
      'Perfil de aluminio abollado, quiñado o con pintura electrostática rayada',
      'Uniones a 45 grados abiertas en esquinas de marco',
      'Falta de tapas embellecedoras en extremos de perfiles'
    ],
    'Felpas y hermeticidad': [
      'Felpa perimetral rota, desprendida o incompleta',
      'Sellado perimetral exterior con silicona neutra ausente o agrietada',
      'Espacio visible entre perfiles en posición cerrada'
    ],
    'Vidrios y cristales templados': [
      'Cristal templado con rayadura profunda de obra',
      'Presencia de quiñes o despostilladuras en borde de vidrio',
      'Manchas de salpicadura de soldadura o pintura indelebles',
      'Falta de sello de seguridad o grabado de vidrio templado reglamentario'
    ],
    'Barandas acristaladas': [
      'Baranda con oscilación o cabeceo estructural (anclaje flojo)',
      'Vidrio laminado con delaminación o burbujas internas',
      'Pasamanos desalineado o con aristas vivas cortantes'
    ]
  },
  'Cerrajería y accesorios': {
    'Cerraduras principales e interiores': [
      'Cerradura traba la llave al girar el cilindro',
      'Pestillo no retrae completamente al bajar la manija',
      'Contrafrontal desalineado impidiendo el cierre sin empujar con fuerza',
      'Juego o tambaleo en cilindro de seguridad'
    ],
    'Pestillos y cerrojos': [
      'Cerrojo pasador inoperativo en puertas de baño',
      'Pestillo magnético sin fuerza de retención',
      'Falta de holgura para el ingreso del pestillo en el marco'
    ],
    'Bisagras y topes de piso': [
      'Bisagras chirrían o presentan restos de óxido/pintura',
      'Falta de tornillos en paletas de bisagras',
      'Tope de puerta mal ubicado permitiendo que la manija golpee el muro',
      'Tope de piso flojo o despegado'
    ],
    'Manijas y manijones': [
      'Manija floja con juego axial excesivo',
      'Manija caída o con resorte de retorno vencido',
      'Rayaduras o acabado desprendido en manija metálica'
    ],
    'Jaladores de muebles': [
      'Jalador de clóset/repostero desalineado respecto al adyacente',
      'Tornillo de sujeción largo rozando el interior del cajón'
    ]
  },
  'Instalaciones eléctricas': {
    'Tomacorrientes 220V': [
      'Tomacorriente sin energía (circuito abierto)',
      'Falta de continuidad de puesta a tierra (borne de tierra desconectado)',
      'Placa de tomacorriente desaplomada, floja o separada del muro',
      'Polaridad invertida o fase invertida en tomacorriente'
    ],
    'Interruptores y conmutadores': [
      'Interruptor conmutador no apaga la luz desde uno de los puntos',
      'Mecanismo de balancín duro o trabado',
      'Placa sucia con manchas de pintura de obra o rajada'
    ],
    'Puntos de luz y luminarias': [
      'Punto de luz descentrado respecto al eje del ambiente',
      'Portalámparas o soquete provisional quebrado o falso contacto',
      'Luminaria empotrada (spotlight) parpadea o no enciende'
    ],
    'Tablero General (TG)': [
      'Falta de rotulación y leyenda técnica identificando cada circuito',
      'Gabinete o tapa sin conexión de puesta a tierra equipotencial',
      'Llaves termomagnéticas sobredimensionadas para la sección de cable',
      'Presencia de cables sueltos o terminales sin prensar'
    ],
    'Llaves termomagnéticas y diferenciales': [
      'Disyuntor diferencial de 30mA no dispara al accionar botón de TEST',
      'Termomagnético flojo en riel DIN del tablero',
      'Falta de peineta de interconexión o puentes de cable inadecuados'
    ],
    'Puesta a tierra': [
      'Falta de bornera de tierra general rotulada',
      'Cable verde/amarillo ausente en circuitos derivados'
    ]
  },
  'Instalaciones sanitarias': {
    'Inodoros y fluxómetros': [
      'Filtración o fuga continua de agua limpia en la taza (válvula flapper)',
      'Perno de fijación al piso flojo o inodoro con movimiento/cabeceo',
      'Falta de cordón de silicona antihongos en base del inodoro',
      'Manguera flexible de abasto estrangulada o goteando'
    ],
    'Lavatorios y pedestales': [
      'Filtración en desagüe trampa P debajo del lavamanos',
      'Lavatorio flojo o sin anclaje rígido a muro',
      'Falta de sellado perimetral contra enchape cerámico',
      'Caudal de agua fría o caliente insuficiente'
    ],
    'Lavaderos de cocina / lavandería': [
      'Goteo o fuga en conexión de tubería de desagüe de lavadero',
      'Rebose de lavadero obstruido o sin conectar',
      'Falta de silicona perimetral bajo la pestaña de acero inoxidable'
    ],
    'Griferías y mezcladoras': [
      'Goteo continuo por cartucho cerámico defectuoso',
      'Mezcladora invertida (agua caliente conectada en lado derecho)',
      'Aireador de grifería atascado con restos de arena o cemento',
      'Cuerpo de grifería gira sobre la encimera al abrir'
    ],
    'Duchas y cabezales': [
      'Presión deficiente o rociado obstruido en cabezal de ducha',
      'Brazo de ducha con inclinación negativa o goteo en rosca',
      'Maneral de ducha flojo o con giro falseado'
    ],
    'Desagües, sifones y trampas P': [
      'Evacuación lenta con retorno de olores por falta de sello hidráulico',
      'Abrazadera o tuerca de unión de desagüe partida o mal enroscada',
      'Falta de registro de inspección roscado hermético'
    ],
    'Sumideros y registros': [
      'Rejilla de sumidero floja o atascada con fragua de obra',
      'Tapa de registro no enrosca al ras del piso terminado'
    ]
  },
  'Impermeabilización y evacuación de agua': {
    'Impermeabilización de ducha': [
      'Filtración de humedad visible en muro colindante a la ducha',
      'Falta de sellador impermeable en esquinas y encuentro piso-muro',
      'Bandeja de ducha con retención de agua por contrapendiente'
    ],
    'Pisos de baños y sellos húmedos': [
      'Fragua absorbente en piso de ducha sin aditivo hidrófugo',
      'Cordón de silicona antihongos perimetral ennegrecido o agrietado'
    ],
    'Balcones y terrazas': [
      'Filtración hacia losa inferior en borde de balcón',
      'Falta de goterón o canaleta de corte de agua en borde de fachada',
      'Empozamiento de agua de lluvia por pendiente deficiente'
    ],
    'Pendientes hacia sumideros': [
      'Agua no evacúa hacia la rejilla y forma charcos en esquinas',
      'Rejilla de sumidero colocada en cota superior a la del piso terminado'
    ]
  },
  'Gas y calentamiento de agua': {
    'Puntos y llaves de paso de gas': [
      'Llave de paso de gas inaccesible o bloqueada por mobiliario',
      'Válvula de corte de gas dura o con sello dañado',
      'Punto de gas sin tapón de seguridad reglamentario'
    ],
    'Tuberías y ventilación normada': [
      'Rejilla de ventilación inferior/superior normada ausente o bloqueada',
      'Tubería de cobre sin aislamiento o expuesta a golpes'
    ],
    'Terma / Calentador de agua': [
      'Chimenea / ducto de evacuación de monóxido sin pendiente positiva exterior',
      'Goteo en válvula de sobrepresión o en llave de paso de agua',
      'Falta de toma eléctrica exclusiva con puesta a tierra para terma'
    ],
    'Conexiones flexibles certificadas': [
      'Manguera flexible de gas no certificada o vencida',
      'Falta de abrazadera o conexión rápida con sello elastomérico'
    ]
  },
  'Ventilación y climatización': {
    'Extractores de aire de baños': [
      'Extractor de aire inoperativo o sin encendido sincronizado',
      'Succión deficiente (falla prueba de retención de papel en rejilla)',
      'Extractor con ruido o vibración excesiva por aspas desbalanceadas',
      'Falta de compuerta antirretorno permitiendo ingreso de olores del ducto'
    ],
    'Rejillas de ventilación': [
      'Rejilla de extracción atascada de polvo o pintura de obra',
      'Fijación suelta o marco despegado del cielo raso'
    ],
    'Ductos de evacuación': [
      'Ducto corrugado flexible estrangulado impidiendo el flujo de aire',
      'Falta de hermeticidad en empalme de extracción'
    ],
    'Preinstalación de aire acondicionado': [
      'Tubo de drenaje de condensados obstruido (falla prueba de purga)',
      'Tuberías frigoríficas de cobre sin tapón hermético deshumidificado',
      'Caja de paso para unidad evaporadora mal aplomada'
    ]
  },
  'Equipamiento y electrodomésticos': {
    'Campana extractora': [
      'Campana extractora sin tiro activo hacia el exterior',
      'Filtros metálicos antigrasa abollados o mal encajados',
      'Luminaria de campana o botonera de velocidad defectuosa'
    ],
    'Encimera (cocina empotrada)': [
      'Encendido eléctrico piezoeléctrico no activa en una o más hornillas',
      'Llama irregular con puntas amarillas (combustión deficiente)',
      'Vidrio vitrocerámico o cubierta de acero con rayas de obra'
    ],
    'Horno empotrado': [
      'Puerta de horno no cierra herméticamente (fuga de calor)',
      'Termostato o perilla selectora gira en falso',
      'Falta de ventilación perimetral requerida por fabricante en mueble'
    ],
    'Equipos fijos auxiliares': [
      'Intercomunicador no timbra o micrófono/altavoz con ruido estático',
      'Timbre principal de departamento inoperativo'
    ]
  },
  'Seguridad y elementos complementarios': {
    'Detectores de humo y temperatura': [
      'Detector de humo fotoeléctrico sin luz LED de supervisión (sin energía)',
      'Detector conserva cobertor plástico protector de obra en el techo',
      'Sensor de temperatura de cocina desalineado o suelto'
    ],
    'Barandas de escaleras y balcones': [
      'Altura de baranda reglamentaria inferior a 1.00m',
      'Separación entre barrotes mayor a 11cm (riesgo de atrapamiento infantil)',
      'Fijaciones de base sin tapapernos embellecedores'
    ],
    'Válvulas generales de corte': [
      'Llave general de corte de agua dura o no cierra al 100%',
      'Nicho de llaves de paso sin tapa o sin rotulación clara',
      'Válvula esférica gotea por el vástago al manipular'
    ],
    'Intercomunicador': [
      'Pantalla o auricular no comunica con conserjería',
      'Pulsador de apertura remota de puerta del edificio inoperativo'
    ]
  },
  'Limpieza y entrega final': {
    'Limpieza profunda de obra': [
      'Restos de cemento, yeso o pegamento en pisos y esquinas',
      'Polvo fino de lijado dentro de cajones y clósets',
      'Zócalos y marcos de ventanas sucios con salpicaduras'
    ],
    'Retiro de manchas de pintura/cemento': [
      'Salpicaduras secas de látex sobre cerámicos o perfiles de aluminio',
      'Manchas de grasa o silicona en cristales'
    ],
    'Vidrios limpios sin adhesivos': [
      'Stickers o cintas de embalaje de fábrica aún adheridas en lunas',
      'Restos de pegamento pegajoso en ventanas y mamparas'
    ],
    'Protecciones retiradas': [
      'Plásticos termo-encogibles no retirados en tableros o sanitarios',
      'Embalajes protectores de obra abandonados en la unidad'
    ]
  }
}
