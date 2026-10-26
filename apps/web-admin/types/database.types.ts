export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      organizations: {
        Row: {
          id: string
          name: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
          updated_at?: string
        }
      }
      users: {
        Row: {
          id: string
          organization_id: string
          email: string
          role: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          organization_id: string
          email: string
          role: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          email?: string
          role?: string
          created_at?: string
          updated_at?: string
        }
      }
      clients: {
        Row: {
          id: string
          organization_id: string
          name: string
          email: string | null
          phone: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          name: string
          email?: string | null
          phone?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          name?: string
          email?: string | null
          phone?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      projects: {
        Row: {
          id: string
          organization_id: string
          name: string
          address: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          name: string
          address?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          name?: string
          address?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      properties: {
        Row: {
          id: string
          organization_id: string
          project_id: string
          client_id: string | null
          unit_number: string
          floor_number: string | null
          building: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          project_id: string
          client_id?: string | null
          unit_number: string
          floor_number?: string | null
          building?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          project_id?: string
          client_id?: string | null
          unit_number?: string
          floor_number?: string | null
          building?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      inspections: {
        Row: {
          id: string
          organization_id: string
          property_id: string
          client_id: string | null
          inspector_id: string | null
          status: string
          scheduled_at: string | null
          completed_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          property_id: string
          client_id?: string | null
          inspector_id?: string | null
          status?: string
          scheduled_at?: string | null
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          property_id?: string
          client_id?: string | null
          inspector_id?: string | null
          status?: string
          scheduled_at?: string | null
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      inspection_areas: {
        Row: {
          id: string
          organization_id: string
          inspection_id: string
          name: string
          sequence: number
          sync_status: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          inspection_id: string
          name: string
          sequence?: number
          sync_status?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          inspection_id?: string
          name?: string
          sequence?: number
          sync_status?: string
          created_at?: string
          updated_at?: string
        }
      }
      observations: {
        Row: {
          id: string
          organization_id: string
          inspection_id: string
          area_id: string | null
          title: string
          description: string | null
          category?: string | null
          subcategory?: string | null
          location_details?: string | null
          has_measurements?: boolean | null
          measured_value?: string | null
          measurement_unit?: string | null
          instrument_used?: string | null
          severity: string
          status: string
          sync_status: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          inspection_id: string
          area_id?: string | null
          title: string
          description?: string | null
          category?: string | null
          subcategory?: string | null
          location_details?: string | null
          has_measurements?: boolean | null
          measured_value?: string | null
          measurement_unit?: string | null
          instrument_used?: string | null
          severity?: string
          status?: string
          sync_status?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          inspection_id?: string
          area_id?: string | null
          title?: string
          description?: string | null
          category?: string | null
          subcategory?: string | null
          location_details?: string | null
          has_measurements?: boolean | null
          measured_value?: string | null
          measurement_unit?: string | null
          instrument_used?: string | null
          severity?: string
          status?: string
          sync_status?: string
          created_at?: string
          updated_at?: string
        }
      }
      evidence: {
        Row: {
          id: string
          organization_id: string
          observation_id: string
          storage_path: string
          file_name: string
          mime_type: string
          file_size_bytes: number
          sha256: string
          sync_status: string
          created_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          observation_id: string
          storage_path: string
          file_name: string
          mime_type: string
          file_size_bytes: number
          sha256: string
          sync_status?: string
          created_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          observation_id?: string
          storage_path?: string
          file_name?: string
          mime_type?: string
          file_size_bytes?: number
          sha256?: string
          sync_status?: string
          created_at?: string
        }
      }
      service_types: {
        Row: {
          id: string
          organization_id: string
          name: string
          description: string | null
          base_price: number
          duration_minutes: number
          active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          name: string
          description?: string | null
          base_price?: number
          duration_minutes?: number
          active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          name?: string
          description?: string | null
          base_price?: number
          duration_minutes?: number
          active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      appointments: {
        Row: {
          id: string
          organization_id: string
          client_id: string
          property_id: string | null
          service_type_id: string | null
          inspector_id: string | null
          scheduled_date: string
          start_time: string
          end_time: string
          status: string
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          organization_id: string
          client_id: string
          property_id?: string | null
          service_type_id?: string | null
          inspector_id?: string | null
          scheduled_date: string
          start_time: string
          end_time: string
          status?: string
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          organization_id?: string
          client_id?: string
          property_id?: string | null
          service_type_id?: string | null
          inspector_id?: string | null
          scheduled_date?: string
          start_time?: string
          end_time?: string
          status?: string
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      current_user_org_id: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}
