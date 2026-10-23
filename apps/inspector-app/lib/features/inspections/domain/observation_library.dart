class PresetObservationItem {
  final String title;
  final String defaultSeverity;
  final String category;
  final String suggestedDescription;

  const PresetObservationItem({
    required this.title,
    required this.defaultSeverity,
    required this.category,
    required this.suggestedDescription,
  });
}

class ObservationLibrary {
  static const List<PresetObservationItem> standardDefects = [
    PresetObservationItem(
      title: 'Pintura irregular o con variación de tonalidad',
      defaultSeverity: 'MENOR',
      category: 'Acabados de Muros y Techos',
      suggestedDescription: 'Se aprecian desniveles de textura o variación visible de tonalidad sobre la superficie.',
    ),
    PresetObservationItem(
      title: 'Fisura superficial tipo tela de araña',
      defaultSeverity: 'MENOR',
      category: 'Muros y Tabiquería',
      suggestedDescription: 'Fisura capilar superficial sin compromiso estructural observable en el enlucido.',
    ),
    PresetObservationItem(
      title: 'Junta de cerámico/porcelanato desalineada o hueca',
      defaultSeverity: 'MODERADA',
      category: 'Pisos y Revestimientos',
      suggestedDescription: 'Junta excede los 2mm o presenta sonido hueco a la percusión.',
    ),
    PresetObservationItem(
      title: 'Ausencia de sellador de silicona en encuentro sanitario',
      defaultSeverity: 'MODERADA',
      category: 'Aparatos e Instalaciones Sanitarias',
      suggestedDescription: 'Falta cordón de sellador fungicida entre muro y artefacto sanitario/tina.',
    ),
    PresetObservationItem(
      title: 'Puerta con roce o descuadre en marco',
      defaultSeverity: 'MENOR',
      category: 'Carpintería de Madera',
      suggestedDescription: 'La hoja presenta dificultad de cierre o roce con el marco o piso.',
    ),
    PresetObservationItem(
      title: 'Tomacorriente sin polaridad adecuada o neutro invertido',
      defaultSeverity: 'MAYOR',
      category: 'Instalaciones Eléctricas',
      suggestedDescription: 'Verificado con medidor de polaridad: ausencia de tierra o línea/neutro invertidos.',
    ),
    PresetObservationItem(
      title: 'Fuga o filtración activa en llave de paso / sifón',
      defaultSeverity: 'CRÍTICA',
      category: 'Instalaciones Sanitarias',
      suggestedDescription: 'Goteo continuo visible bajo presión de servicio.',
    ),
  ];
}
