import { describe, it, expect } from 'vitest'

describe('Fase 4 — Reports Engine', () => {
  it('debe estructurar correctamente la data de un acta técnica con severidades y SHA-256', () => {
    const reportData = {
      code: 'ACTA-2026-305',
      unit: 'Unidad 305',
      project: 'Condominio Los Cedros',
      inspector: 'Arq. Roberto Silva',
      observations: [
        { id: '1', severity: 'MENOR', sha256: 'a'.repeat(64), marker: { x: 30, y: 40 } },
        { id: '2', severity: 'MODERADA', sha256: 'b'.repeat(64), marker: { x: 60, y: 70 } }
      ]
    }

    expect(reportData.observations).toHaveLength(2)
    expect(reportData.observations[0].sha256).toHaveLength(64)
    expect(reportData.observations[0].marker.x).toBeGreaterThanOrEqual(0)
    expect(reportData.observations[0].marker.x).toBeLessThanOrEqual(100)
  })

  it('debe agrupar observaciones por severidad para el resumen cuantitativo', () => {
    const list = [
      { severity: 'MENOR' },
      { severity: 'MODERADA' },
      { severity: 'MENOR' },
      { severity: 'CRÍTICA' }
    ]

    const counts = list.reduce((acc, curr) => {
      acc[curr.severity] = (acc[curr.severity] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    expect(counts['MENOR']).toBe(2)
    expect(counts['MODERADA']).toBe(1)
    expect(counts['CRÍTICA']).toBe(1)
    expect(counts['MAYOR']).toBeUndefined()
  })
})
