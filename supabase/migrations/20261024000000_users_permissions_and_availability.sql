-- Migration: Add DML policies for users and initial availability rules
CREATE POLICY "Users can insert users in same org" ON public.users 
  FOR INSERT WITH CHECK (organization_id = current_user_org_id());

CREATE POLICY "Users can update users in same org" ON public.users 
  FOR UPDATE USING (organization_id = current_user_org_id());

CREATE POLICY "Users can delete users in same org" ON public.users 
  FOR DELETE USING (organization_id = current_user_org_id());

