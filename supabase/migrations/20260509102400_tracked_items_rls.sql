-- Ensure tracked_items is protected and readable only by its owner.
alter table if exists public.tracked_items enable row level security;

-- Recreate policies idempotently to avoid duplicates during repeated deploys.
drop policy if exists tracked_items_select_own on public.tracked_items;
create policy tracked_items_select_own
  on public.tracked_items
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists tracked_items_insert_own on public.tracked_items;
create policy tracked_items_insert_own
  on public.tracked_items
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists tracked_items_update_own on public.tracked_items;
create policy tracked_items_update_own
  on public.tracked_items
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists tracked_items_delete_own on public.tracked_items;
create policy tracked_items_delete_own
  on public.tracked_items
  for delete
  to authenticated
  using (auth.uid() = user_id);
