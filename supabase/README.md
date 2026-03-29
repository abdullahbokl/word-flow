# WordFlow Supabase Backend

This directory contains the database migrations for the WordFlow Supabase project.

## Running Migrations

To apply these migrations to your Supabase project, use the Supabase CLI:

1.  **Login** (if not already logged in):
    ```bash
    supabase login
    ```

2.  **Lint / Dry Run** (optional):
    ```bash
    supabase db lint
    ```

3.  **Push to Project**:
    ```bash
    supabase db push
    ```

## Security Model

WordFlow uses **Row-Level Security (RLS)** to protect user data. 
- All data in the `words` table is private to the user who created it.
- Security is enforced via `(auth.uid() = user_id)`.
- Client-side filters are still used for performance but are no longer the primary security boundary.
