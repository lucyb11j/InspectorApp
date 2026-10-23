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

export type AppointmentStatus = 'PENDING' | 'CONFIRMED' | 'CANCELLED' | 'RESCHEDULED' | 'COMPLETED';
export type PaymentStatus = 'PENDING' | 'PAID' | 'REFUNDED' | 'FAILED';

export interface ServiceType {
  id: string;
  organization_id: string;
  name: string;
  description?: string;
  base_price: number;
  duration_minutes: number;
  active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Appointment {
  id: string;
  organization_id: string;
  client_id: string;
  property_id?: string;
  service_type_id?: string;
  inspector_id?: string;
  scheduled_date: string;
  start_time: string;
  end_time: string;
  status: AppointmentStatus;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface PaymentRecord {
  id: string;
  organization_id: string;
  appointment_id?: string;
  amount: number;
  currency: string;
  status: PaymentStatus;
  payment_method?: string;
  external_reference?: string;
  created_at: string;
}
