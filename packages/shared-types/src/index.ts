export interface Organization {
  id: string;
  name: string;
  createdAt: string;
  updatedAt: string;
}

export interface User {
  id: string;
  organizationId: string;
  email: string;
  firstName?: string;
  lastName?: string;
  role: 'OWNER' | 'ADMIN' | 'INSPECTOR' | 'CLIENT';
  createdAt: string;
}

export interface Inspection {
  id: string;
  organizationId: string;
  propertyId: string;
  inspectorId?: string;
  clientId?: string;
  status: 'DRAFT' | 'SCHEDULED' | 'IN_PROGRESS' | 'COMPLETED' | 'REVIEW' | 'PUBLISHED' | 'CANCELLED';
  scheduledAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Observation {
  id: string;
  organizationId: string;
  inspectionId: string;
  areaId: string;
  title: string;
  description?: string;
  severity: 'INFO' | 'MENOR' | 'MODERADA' | 'MAYOR' | 'CRÍTICA';
  status: 'PENDING' | 'EN_CORRECCIÓN' | 'CORREGIDO' | 'RECHAZADO' | 'VERIFICADO' | 'CERRADO';
  createdAt: string;
  syncStatus: string;
  hash?: string;
}
