-- Migration: Add missing INSERT, UPDATE, DELETE policies for core tables
CREATE POLICY "Users can insert clients in same org" ON public.clients FOR INSERT WITH CHECK (organization_id = current_user_org_id());
CREATE POLICY "Users can update clients in same org" ON public.clients FOR UPDATE USING (organization_id = current_user_org_id());
CREATE POLICY "Users can delete clients in same org" ON public.clients FOR DELETE USING (organization_id = current_user_org_id());

CREATE POLICY "Users can insert projects in same org" ON public.projects FOR INSERT WITH CHECK (organization_id = current_user_org_id());
CREATE POLICY "Users can update projects in same org" ON public.projects FOR UPDATE USING (organization_id = current_user_org_id());
CREATE POLICY "Users can delete projects in same org" ON public.projects FOR DELETE USING (organization_id = current_user_org_id());

CREATE POLICY "Users can insert properties in same org" ON public.properties FOR INSERT WITH CHECK (organization_id = current_user_org_id());
CREATE POLICY "Users can update properties in same org" ON public.properties FOR UPDATE USING (organization_id = current_user_org_id());
CREATE POLICY "Users can delete properties in same org" ON public.properties FOR DELETE USING (organization_id = current_user_org_id());

CREATE POLICY "Users can insert inspections in same org" ON public.inspections FOR INSERT WITH CHECK (organization_id = current_user_org_id());
CREATE POLICY "Users can update inspections in same org" ON public.inspections FOR UPDATE USING (organization_id = current_user_org_id());
CREATE POLICY "Users can delete inspections in same org" ON public.inspections FOR DELETE USING (organization_id = current_user_org_id());
