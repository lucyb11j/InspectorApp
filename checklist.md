# Catálogo y Matriz QA/QC de Entrega de Departamentos (Perú)

## 1. Marco Técnico de Referencia y Alcance

> **Marco técnico de referencia:** El catálogo se utiliza como herramienta de inspección visual, medición y comprobación funcional. La aceptación de cada elemento se contrasta, según corresponda, con el **Reglamento Nacional de Edificaciones (RNE)** vigente y aplicable (normas técnicas de arquitectura, estructuras, instalaciones sanitarias, instalaciones eléctricas, ventilación y gas publicadas por el Ministerio de Vivienda, Construcción y Saneamiento), los planos aprobados, las especificaciones técnicas, la documentación de acabados y las condiciones contractuales del proyecto. La inclusión de una observación en el catálogo no implica por sí sola la existencia de un incumplimiento normativo ni atribuye automáticamente responsabilidad previa a la evaluación de la inmobiliaria.
>
> **Precisiones fundamentales de peritaje:**
> 1. **Sin tolerancias numéricas universales predeterminadas:** Una ceja entre baldosas, una holgura de puerta o una desviación de verticalidad se registran con su valor medido en campo. La evaluación se contrasta con el criterio técnico aplicable al elemento, las especificaciones y la documentación técnica del proyecto, sin convertir automáticamente un valor fijo en un incumplimiento normativo.
> 2. **Sin pruebas destructivas ni maniobras de riesgo:** Las pruebas de campo respetan estrictamente las condiciones de seguridad y el alcance del servicio. Si no es posible comprobar una instalación de forma segura, se registra como `NV` y se explica el motivo.

---

## 2. Estados de Evaluación del Checklist

Para asegurar un control técnico riguroso y transparente, la aplicación y las actas de entrega manejan formalmente estas definiciones definitivas:

| Código | Nombre | Regla de Uso |
| :---: | :--- | :--- |
| **`OK`** | **Conforme** | El componente fue inspeccionado y cumple el criterio de aceptación aplicable dentro del alcance de las comprobaciones de la inspección. *(No implica certificación total de todas las exigencias normativas fuera del alcance visual/funcional).* |
| **`OBS`** | **Observado** | Se identificó una condición que requiere corrección, aclaración o evaluación técnica. Incluye elementos faltantes que estén previstos en la documentación contractual o en los planos de entrega. |
| **`N/A`** | **No aplica** | El componente o sistema no corresponde al inmueble ni al alcance contratado (ej. sin gas natural, sin terma instalada o sin aire acondicionado). |
| **`NV`** | **No verificado** | No fue posible realizar la comprobación prevista por falta de acceso físico, cerrajería trabada, falta de suministro de servicios (electricidad, agua o gas), condiciones de prueba o una limitación debidamente documentada. |

> **Regla de integridad:** Si el inspector simplemente omitió o no revisó un elemento, no debe marcarlo como `NV` para cerrar falsamente el checklist. La aplicación debe permitir identificar y alertar sobre los ítems efectivamente pendientes de inspección.

---

## 3. Delimitación de Especialidades y Reglas Anti-Solapamiento

Para evitar duplicidades y garantizar consistencia en la base de datos entre ambientes:

1. **`CAR` vs. `CERR` (Puertas y Cerrajería):**
   * **`CAR` (Carpintería de madera/melamina):** Cubre hoja, marco, aplomado y ajuste geométrico (rozamientos con piso/marco, holguras perimetrales, alabeos).
   * **`CERR` (Cerrajería y herrajes):** Cubre cerraduras, cilindros, pestillos, manijas, bisagras y topes de piso.
2. **`SAN` vs. `APA` (Instalaciones vs. Aparatos Sanitarios):**
   * **`SAN` (Instalaciones sanitarias):** Cubre redes accesibles de agua y desagüe, tuberías generales, llaves de paso, válvulas esféricas y conexiones generales de alimentación.
   * **`APA` (Aparatos sanitarios y griferías):** Cubre el artefacto específico (inodoro, lavatorio, tina, poza), su grifería/mezcladora, la descarga del tanque y el funcionamiento propio del aparato. No incluye las redes generales.
3. **`PIS` vs. `EVA` (Pisos vs. Evacuación e Impermeabilización):**
   * **`PIS` (Pisos y revestimientos):** Cubre acabado superficial, nivel relativo entre baldosas (cejas), integridad física de piezas y fragua estética de acabado.
   * **`EVA` (Evacuación e impermeabilización):** Cubre drenaje activo, empozamiento observado en pruebas de agua, sumideros y sellos elásticos perimetrales de estanqueidad. *(Separar las observaciones de empozamiento de las de acabado de fragua: una fragua deteriorada es acabado; el empozamiento es una condición de evacuación. Pueden coexistir si ambos hechos ocurren).*
4. **`ARQ` vs. `PIN` (Muros vs. Pintura):**
   * **`ARQ` (Arquitectura y acabados):** Cubre el sustrato, tabiquería, revoques, tarrajeo, nivelación de muros y encuentros constructivos.
   * **`PIN` (Pintura y empaste):** Cubre la película de pintura, marcas de aplicación, manchas, traslapes, empaste superficial y adherencia.
5. **`ALU` vs. `SEG` (Carpintería de aluminio vs. Seguridad):**
   * **`ALU` (Carpintería de aluminio y vidrio):** Cubre perfiles, rieles, rodamientos, felpas, deslizamiento operativo y mecanismos de cierre.
   * **`SEG` (Seguridad y protección):** Cubre estabilidad aparente de barandas, elementos contra caídas, detectores de alarma y protocolos de escalamiento de riesgo. *(No clasificar automáticamente todos los vidrios de baranda como defectos de seguridad; el daño visible se documenta, y su aptitud se contrasta con la especificación técnica).*
6. **`ARQ` vs. `EST` (Fisuras superficiales vs. Indicios estructurales):**
   * **`ARQ`:** Registra fisuras superficiales, capilares o en el acabado/empaste.
   * **`EST` (Estructuras — inspección visual):** Registra indicios visuales relevantes (grietas con características atípicas, desprendimientos de concreto, armadura expuesta o deformaciones notables) para su advertencia y evaluación especializada, sin emitir diagnósticos causales concluyentes en campo.
7. **`DOC` (Documentación y correspondencia con lo ofrecido):**
   * Distingue entre *diferencia aparente* y *discrepancia confirmada*. Un acabado distinto a una imagen comercial no demuestra por sí solo un incumplimiento contractual; requiere contrastar con planos aprobados y especificaciones de entrega.

> **Regla de duplicados:** El inspector puede registrar varias observaciones en un mismo elemento, pero cada observación debe representar una condición distinta (ej. una mampara puede tener un cierre con holgura y un vidrio con rayadura: se registran como dos observaciones independientes).

---

## 4. Separación de Datos: Observación, Medición y Criterio Técnico

1. **Estructura gramatical:** `[Componente] + [condición observable] + [ubicación o detalle adicional]`.
2. **Registro de datos paramétricos:**
   * **Valor medido y unidad:** (ej. *ceja de 1.8 mm*, *15 minutos de prueba de agua*).
   * **Instrumento empleado:** (si aplica: calibrador, nivel láser, probador de polaridad).
   * **Ubicación exacta:** (registrada en plano táctil interactivo o descripción de vano/eje).
   * **Resultado de la evaluación técnica:** Contraste documentado frente a la tolerancia del proyecto o normativa aplicable.
3. **Acciones recomendadas abiertas (Sin imponer una única solución):**
   * La observación clásica describe el hecho observable. La acción recomendada admite alternativas según la evaluación que realice la inmobiliaria (ej. ante un empozamiento: *"Evaluar la geometría del piso y corregir la condición de evacuación según corresponda"* en vez de ordenar rehacer toda la impermeabilización).

---

## 5. Catálogo Maestro de Especialidades y Códigos

| Código | Especialidad / Categoría | Subcategorías / Componentes Principales | Enfoque de Evaluación |
| :--- | :--- | :--- | :--- |
| **ARQ** | Arquitectura y acabados | Muros, tabiques, encuentros y revoques | Sustrato, verticalidad aparente, fisuras superficiales, remates entre materiales. |
| **PIN** | Pintura y empaste | Paredes, cielos rasos, retoques | Homogeneidad visual, marcas de rodillo, traslapes, ampollamiento, descascaramiento o pérdida visible de adherencia. |
| **CIE** | Cielos rasos y falsos techos | Placas de yeso/drywall, juntas, bruñas | Desnivel, deformación o pandeo visible en cielo raso; juntas y bruñas arquitectónicas. |
| **PIS** | Pisos y revestimientos | Porcelanatos, cerámicos, laminados, vinílicos | Diferencia de nivel entre piezas (cejas), juntas de colocación, crujidos, piezas con movimiento perceptible o sueltas. |
| **ZOC** | Zócalos y contrazócalos | Cerámicos, porcelanatos, madera, MDF | Fijación, cortes, juntas abiertas, sellado superior cuando aplique al detalle constructivo. |
| **CAR** | Carpintería de madera y melamina | Puertas de paso, marcos, clósets, reposteros | Rozamiento de hojas, holguras perimetrales, fijación de módulos, cajones, tapacantos. |
| **CERR** | Cerrajería y herrajes | Cerraduras, manijas, bisagras, topes | Suavidad de giro de llave, encaje de pestillo, fijación de manijas, funcionamiento de topes. |
| **ALU** | Carpintería de aluminio y vidrio | Ventanas, mamparas, perfiles, felpas, cristales | Desplazamiento en rieles, seguros, pestillos y mecanismos de cierre, felpas perimetrales, sellos exteriores e integridad de vidrios. |
| **SAN** | Instalaciones sanitarias | Redes accesibles, llaves de paso, válvulas | Fugas visibles en redes o llaves de paso, operatividad y accesibilidad de llaves de corte. |
| **APA** | Aparatos sanitarios y griferías | Inodoros, lavatorios, tinas, duchas, lavaderos | Estabilidad del artefacto, griferías con fugas/goteos, descarga del tanque, caudal y evacuación propia del aparato. |
| **EVA** | Evacuación e impermeabilización | Sumideros, pendientes de ducha/balcón, sellos | Evacuación de agua en prueba controlada, ausencia de empozamiento, sellos perimetrales elásticos contra humedad. |
| **ELE** | Instalaciones eléctricas | Tomacorrientes, interruptores, puntos de luz, tablero general | Tomacorriente con resultado anómalo en comprobación, placas flojas, rotulación de circuitos, prueba funcional mediante botón TEST en diferencial. |
| **COM** | Telecomunicaciones y datos | Tomas de red, TV cable, intercomunicador | Intercomunicador y tomas de comunicaciones: verificación funcional cuando aplique. |
| **VEN** | Ventilación | Extractores mecánicos, rejillas, ductos | Extractor de aire en prueba de encendido, extracción aparente, rejillas de ventilación. |
| **GAS** | Instalaciones de gas | Llaves de corte, puntos de conexión, ventilación | Acceso a llave de paso, componentes o condiciones de ventilación que requieran comprobación respecto del diseño del sistema. |
| **EQU** | Equipamiento fijo | Campana, encimera, horno, terma/calentador | Equipo que no enciende o no responde a controles en prueba autorizada y segura; verificación respecto a lo ofrecido. |
| **SEG** | Seguridad y protección | Barandas, vidrios de seguridad, detectores/alarmas | Baranda con movimiento perceptible o fijación aparentemente deficiente (alerta de seguridad); detectores según modelo instalado. |
| **CLI** | Climatización y preinstalaciones | Cajas de paso de A/C, drenajes de condensado | Drenaje de condensado en prueba de purga, tapas y pases de preinstalación respecto del proyecto. |
| **EST** | Estructuras — inspección visual | Columnas, vigas, placas, losas de concreto | Indicio visual que requiere evaluación técnica especializada (fisuras atípicas, desprendimiento de concreto, acero expuesto). |
| **DOC** | Documentación y correspondencia | Planos, especificaciones, fichas de acabados | Componente previsto en planos o especificaciones que no se encuentra instalado, sujeto a contrastación documental. |
| **LIM** | Limpieza y entrega final | Superficies, cristales, artefactos y muebles | Residuos de pintura, adhesivos o polvo de obra removibles para permitir recepción. |

---

## 6. Matriz Detallada por Ambientes y Observaciones Clásicas (QA/QC)

> **Criterio de aplicación en campo:** Todo componente que no corresponda al departamento o al alcance contratado se marca como **`N/A`**. Los elementos que no pudieron ser comprobados de forma segura por falta de suministros o acceso se consignan como **`NV`**.

| Ambiente / Recinto | Especialidad (Código) | Componente / Subcategoría | Redacción Objetiva de Observaciones Clásicas (Desplegable) |
| :--- | :--- | :--- | :--- |
| **Sala / Comedor** | ARQ / PIN | Muros, tabiques y pintura | • Fisura visible en muro o tabique (registrar ubicación, orientación, longitud y ancho aprox.)<br>• Desviación aparente de verticalidad en muro (registrar medición instrumental)<br>• Irregularidad superficial o abombamiento aparente en muro<br>• Fisura en encuentro entre muro y elemento constructivo<br>• Pintura con marcas de aplicación, traslapes o acabado irregular bajo luz rasante<br>• Pintura con ampollamiento, descascaramiento o pérdida visible de adherencia |
| | CIE | Cielos rasos y molduras | • Desnivel, deformación o pandeo visible en cielo raso<br>• Fisura visible en junta de placas de cielo raso<br>• Bruña perimetral desalineada, con rebabas o remate deficiente |
| | PIS | Porcelanatos / Cerámicos / Laminados | • Diferencia de nivel entre piezas de revestimiento (cejas; registrar medición instrumental)<br>• Pieza de revestimiento desportillada, fisurada o quiñada<br>• Piso laminado presenta zona amortiguada o hundimiento aparente al pisar<br>• Piso con crujidos, piezas con movimiento perceptible o juntas deterioradas, según el revestimiento instalado |
| | ZOC | Zócalos y contrazócalos | • Zócalo suelto o con sonido hueco al percutir suavemente<br>• Sello superior elástico ausente o discontinuo en encuentro con muro (según detalle constructivo previsto)<br>• Corte visiblemente astillado o junta abierta entre piezas de zócalo |
| | CAR | Puerta principal de ingreso | • Puerta presenta rozamiento con el marco o con el piso al abrir/cerrar<br>• Holgura perimetral irregular entre hoja y marco de puerta<br>• Hoja de puerta presenta desviación o alabeo visible |
| | CERR | Cerrajería y herrajes | • Cerradura presenta dificultad u oposición al giro de la llave<br>• Pestillo no encaja suavemente en el recibidor del marco<br>• Manija de puerta floja o con juego axial perceptible<br>• Tope de puerta ausente o no evita contacto de manija con muro (verificar especificación) |
| | ALU | Ventanas y mamparas corredizas | • Hoja corrediza presenta dificultad o resistencia de desplazamiento en rieles<br>• Seguros, pestillos o mecanismos de cierre no traban o presentan desalineación<br>• Felpa perimetral ausente, deteriorada o desprendida<br>• Sellado perimetral con discontinuidades visibles y entrada de aire o agua observada durante una prueba apropiada, cuando corresponda<br>• Vidrio o cristal con rayadura, quiñe o daño superficial visible |
| | ELE | Puntos eléctricos e iluminación | • Tomacorriente con resultado anómalo en la comprobación realizada; requiere verificación eléctrica<br>• Indicación de anomalía en la comprobación de puesta a tierra (especificar método e instrumento utilizado)<br>• Placa de tomacorriente o interruptor floja, desaplomada o separada del muro<br>• Interruptor no acciona el centro de luz correspondiente<br>• Centro de iluminación sin respuesta en la prueba o accesorio flojo/dañado |
| | ELE | Tablero General (TG) | • Tablero general sin leyenda o rotulación identificando circuitos<br>• Interruptor diferencial: prueba funcional mediante botón TEST no satisfactoria (cuando la prueba esté contemplada y pueda realizarse de forma segura)<br>• Conexión de puesta a tierra del gabinete metálico o tapa: por verificar |
| | COM | Comunicaciones y datos | • Intercomunicador: sin señal de llamada o sin comunicación audible con conserjería<br>• Placa de toma de datos o TV floja o inoperativa en comprobación |
| | SEG | Alarma y detección de humo | • Detector de humo: indicador de estado o prueba funcional no satisfactorios, según el modelo instalado<br>• Detector conserva cubierta plástica protectora de obra en el techo<br>• Dispositivo previsto no instalado según plano de equipamiento |
| | ARQ / EST | Encuentros y estructura visual | • Remate deficiente en encuentro de muro con marco, contrazócalo o moldura<br>• Indicio visual que requiere evaluación técnica especializada (ver Sección 7) |
| **Cocina y Kitchenette** | ARQ / PIN | Muros y salpicaderos | • Enchape cerámico con pieza fisurada, desportillada o fragua discontinua<br>• Sello elástico deteriorado o ausente en encuentro de zócalo con encimera<br>• Pintura en muros con salpicaduras, manchas o cobertura incompleta |
| | PIS | Pisos cerámicos o porcelanato | • Diferencia de nivel entre baldosas cerámicas (cejas; registrar medición)<br>• Pieza cerámica con sonido hueco al percutir suavemente o pieza con movimiento perceptible<br>• Fragua fisurada, porosa o con desprendimiento de material |
| | CAR | Muebles reposteros (Altos/Bajos) | • Puerta de repostero desalineada o con rozamiento al cerrar<br>• Puerta que no mantiene su posición de apertura o cierre<br>• Módulo con fijación aparentemente deficiente al muro<br>• Fondo del mueble deteriorado o con indicios de humedad<br>• Mecanismo de cierre suave no funciona o mecanismo ofrecido no instalado (cuando corresponda a lo contratado)<br>• Bisagra floja o con fijación deficiente en panel de melamina<br>• Cajón presenta dificultad de desplazamiento o traba en correderas<br>• Tapacanto de melamina despegado, astillado o con filo cortante |
| | EQU | Tablero y encimera de trabajo | • Encimera de granito, cuarzo o laminada con rayadura, mancha o daño visible<br>• Unión entre tramos de tablero con junta abierta o desnivel aparente<br>• Sello perimetral contra salpicaduras discontinuo o con poros |
| | APA | Lavadero y grifería | • Grifería presenta goteo o fuga visible en caño, maneral o base<br>• Disposición de agua fría/caliente no conforme con lo especificado (verificar plano de instalaciones)<br>• Caudal de agua aparentemente insuficiente en la salida<br>• Pozuelo de lavadero con evacuación lenta durante prueba de descarga<br>• Fuga visible en conexiones accesibles o trampa de desagüe bajo el mueble *(registrar evacuación lenta y fuga visible por separado si ambas ocurren)* |
| | GAS | Instalaciones de gas (Si aplica) | • Acceso a llave de paso de gas obstruido o de difícil manipulación<br>• Rejilla de ventilación prevista ausente, obstruida o dañada; contrastar con el diseño y el sistema de gas<br>• Componente, conexión o condición de ventilación que requiere comprobación respecto del diseño del sistema |
| | EQU | Equipamiento electrodoméstico fijo | • Campana extractora: funcionamiento o modalidad de extracción por verificar (recirculación o ducto exterior según proyecto)<br>• Cocina encimera: equipo que no enciende o no responde a los controles durante prueba autorizada y segura<br>• Horno empotrado: puerta no asienta correctamente o selector no operativo |
| | ELE | Instalaciones eléctricas de cocina | • Tomacorriente con resultado anómalo en la comprobación realizada; requiere verificación eléctrica<br>• Placa ubicada en posición diferente a la indicada en plano de acabados |
| **Baños (Principal / Visitas)** | ARQ / PIN | Enchapes y cielos rasos | • Cerámicos de pared fisurados, quiñados o con fragua discontinua<br>• Pintura en cielo raso con manchas de humedad o ampollamiento |
| | PIS / EVA | Pisos y zona de ducha | • Diferencia de nivel entre baldosas en piso de baño (registrar medición)<br>• Evacuación deficiente o empozamiento de agua durante prueba en ducha (registrar método, duración y zona afectada)<br>• Fragua fisurada o porosa en área húmeda de ducha (registrar como acabado)<br>• Sello perimetral elástico deteriorado o ausente en encuentro ducha-muro (según detalle constructivo) |
| | APA | Inodoro y accesorios | • Inodoro presenta movimiento al aplicar una comprobación suave<br>• Descarga con funcionamiento irregular, llenado continuo del tanque o fuga visible después de accionar la descarga<br>• Fuga o goteo visible en válvula de abasto o manguera flexible de conexión<br>• Sello perimetral en la base del aparato ausente o deteriorado |
| | APA | Lavatorio y grifería | • Lavatorio presenta movimiento al aplicar una comprobación suave<br>• Grifería presenta goteo o fuga en conexiones inferiores<br>• Evacuación lenta de agua en el pozuelo durante la prueba realizada<br>• Caudal irregular o dificultad para operar el mando de la grifería<br>• Disposición de agua fría/caliente no conforme con lo esperado o especificado |
| | ALU | Mampara o puerta de ducha | • Mampara corrediza presenta dificultad de desplazamiento o atasco en riel<br>• Ausencia o discontinuidad visible de sellos y paso de agua al exterior durante una prueba controlada, cuando sea posible realizarla<br>• Vidrio de mampara con daño superficial visible |
| | VEN | Ventilación mecánica (Extractor) | • Extractor de aire sin funcionamiento en la prueba de encendido<br>• Extracción aparentemente insuficiente en la prueba realizada; requiere comprobación adicional si corresponde<br>• Extractor con ruido o vibración anormal durante el giro |
| | CAR / CERR | Puerta y accesorios de baño | • Puerta roza con el piso o marco al abrir/cerrar<br>• Cerradura o cerrojo de baño presenta traba o dificultad de operación<br>• Accesorios (toallero, portarrollo) sueltos o con fijación deficiente |
| **Dormitorios** | ARQ / PIN | Muros y pintura | • Fisura visible en muro o tabique (registrar ubicación, orientación, longitud y ancho aprox.)<br>• Pintura con ampollamiento, descascaramiento o marcas visibles bajo luz rasante<br>• Zócalo suelto o con junta abierta respecto al piso |
| | CAR | Clósets y vestidores | • Puerta corrediza de clóset trabada o con dificultad de rodadura en riel<br>• Puerta batiente desalineada o sin retención adecuada<br>• Cajonera con correderas duras o roce en estructura del mueble<br>• Repisa interior presenta deformación visible o canto desprendido |
| | CAR / CERR | Puerta interior de dormitorio | • Puerta roza el piso o marco al girar<br>• Cerradura interior o manija con juego axial excesivo o floja<br>• Tope de piso ausente (cuando esté contemplado en especificaciones) |
| | ALU | Ventana corrediza o proyectante | • Cierre incompleto, holgura perceptible o mecanismo de apertura que no opera correctamente<br>• Seguro o pestillo de cierre no ajusta adecuadamente o presenta holgura<br>• Cristal con rayaduras visibles de obra o quiñes |
| | ELE | Instalaciones eléctricas | • Tomacorriente con resultado anómalo en la comprobación realizada; requiere verificación eléctrica<br>• Interruptor conmutador de cabecera no conmuta la luminaria indicada |
| | CLI | Climatización / A.C. (Si aplica) | • Preinstalación de A/C: tubo de drenaje con obstrucción en prueba de purga<br>• Tapa de pase o caja de preinstalación ausente o dañada |
| **Lavandería y Patio** | APA | Poza o lavadero de servicio | • Poza de lavado presenta movimiento al aplicar una comprobación suave<br>• Grifería móvil presenta fuga o goteo en caño/flexible<br>• Evacuación lenta en trampa de desagüe |
| | SAN | Puntos de lavadora | • Ausencia del punto previsto en planos, fuga en la llave de agua o drenaje que presenta evacuación deficiente<br>• Punto de desagüe de lavadora: ubicación o altura por verificar con plano o especificación de referencia<br>• Conexión eléctrica con tomacorriente sin funcionamiento |
| | EQU | Terma o calentador de agua | • Equipo que no enciende o no responde a los controles durante una prueba autorizada y segura, cuando esté incluido en la entrega<br>• Fuga o goteo visible en conexiones hidráulicas o descarga en válvula de alivio (indicar punto exacto y condición de funcionamiento del equipo)<br>• Ducto de evacuación de gases: trazado o pendiente por verificar respecto al proyecto (si es a gas) |
| | GAS | Instalación de gas (Si aplica) | • Válvula de corte de gas de terma de difícil acceso<br>• Rejilla de ventilación ausente o tapada; contrastar con diseño del sistema |
| **Balcón / Terraza** | PIS / EVA | Piso y evacuación pluvial | • Evacuación deficiente o empozamiento de agua observado en piso durante prueba (registrar método, duración y zona afectada)<br>• Sumidero pluvial con drenaje lento o cota de rejilla sobre nivel de piso<br>• Sello elástico deteriorado en juntas de dilatación o encuentro de fachada |
| | ALU / SEG | Barandas y mamparas de fachada | • Baranda con movimiento perceptible, fijación aparentemente deficiente o daño visible que amerite evaluación de seguridad (restringir uso si existen indicios de inseguridad)<br>• Vidrio de baranda con daño superficial, quiñe o astillado visible (contrastar aptitud con especificación)<br>• Mampara de fachada presenta dificultad de cierre o felpas deterioradas |
| | SAN | Grifería exterior (Si aplica) | • Grifo o punto de riego con fuga o sin llave de corte independiente |
| **Todos los Ambientes** | LIM | Limpieza y residuos de obra | • Manchas de pintura, silicona o adhesivo en cristales o perfiles<br>• Residuos de cemento o polvo de lijado en pisos, esquinas o muebles<br>• Plásticos o embalajes protectores de obra sin retirar |
| | DOC | Correspondencia con lo ofrecido | • Componente previsto en planos o especificaciones que no se encuentra instalado, sujeto a contrastación documental<br>• Acabado, material o color aparentemente diferente al de la ficha técnica aprobada (distinguir diferencia aparente de discrepancia confirmada)<br>• Ubicación de punto de instalación difiere del plano proporcionado |
| | EST | Estructuras — inspección visual | • Indicio visual que requiere evaluación técnica especializada (ver criterios de la Sección 7) |

---

## 7. Criterios de Inspección Visual para la Categoría EST

La categoría **`EST`** se utiliza exclusivamente para registrar **indicios visuales en elementos estructurales** que, por sus características, ubicación o extensión aparente, ameriten evaluación técnica especializada.

### Procedimiento en campo:
1. **Registrar el elemento y su ubicación exacta** en el departamento (marcador de pin en plano táctil interactivo y ambiente).
2. **Fotografiar el indicio**, incorporando una escala de referencia cuando sea posible y seguro.
3. **Describir objetivamente la condición visible**, indicando las dimensiones aproximadas cuando corresponda.
4. **Evitar atribuir causas, determinar responsabilidades o emitir diagnósticos estructurales** que excedan el alcance de la inspección.
5. **Incluir en el informe una advertencia** que indique que el hallazgo requiere evaluación técnica especializada.

### Ejemplo de registro:
* **Categoría:** `EST` (Estructuras — inspección visual).
* **Observación:** *«Fisura visible en elemento de concreto ubicado en el encuentro entre muro y techo»*.
* **Evidencia:** Fotografía general y fotografía de detalle con escala de referencia, cuando sea posible.
* **Resultado:** *«Indicio visual pendiente de evaluación técnica especializada»*.
* **Alcance:** La inspección visual no determina por sí sola la causa, profundidad, actividad ni relevancia estructural de la fisura.

> **Advertencia de seguridad y alcance del servicio:** Cuando se identifiquen desprendimientos de concreto, armadura expuesta, deformaciones notables u otros indicios que puedan representar un riesgo, se debe advertir expresamente al cliente y recomendar una evaluación profesional especializada. Si existe peligro aparente, se deben recomendar medidas preventivas proporcionadas, sin exponer al inspector ni al cliente a riesgos innecesarios.
>
> La emisión del informe inicial documenta el hallazgo. La evaluación especializada, la reparación y el seguimiento posterior quedan fuera del alcance de esta fase, salvo contratación expresa de un servicio adicional.
