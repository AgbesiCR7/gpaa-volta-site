# GPAA Volta Regional Branch Website

Production-ready static frontend for Netlify with Supabase as the backend.

## Architecture
- Frontend: static HTML/CSS/JavaScript, deployable to Netlify
- Backend: Supabase Postgres, Auth, Storage and Realtime
- Map: Leaflet with free OpenStreetMap tiles (no API key or billing account required) showing GPAA landmarks and impact story locations
- Directory: `data/members.csv` is the supplied 182-member master list; import it into `gpaa_members` using the SQL migration/import workflow.

## Environment/configuration
Set the following in the site configuration before deployment:
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

The public frontend must never contain a Supabase service-role/secret key.

## Supabase
Run `supabase_schema.sql` in the project's SQL editor. It creates the member directory, executive profiles, shop products/orders, impact stories, storage bucket and RLS policies.

Then import `data/members.csv` into `public.gpaa_members` using the Supabase Table Editor import facility, or a controlled server-side import.

## Netlify
Connect the repository to Netlify, set the environment variables above, and deploy. `netlify.toml` is included.
