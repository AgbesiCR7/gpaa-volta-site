const fs = require('fs');

// Supabase publishable keys are intended for browser use. Keep the actual
// value in Netlify environment variables, not in the Git repository.
const esc = v => String(v || '').replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, '');
const js = `window.GPAA_SUPABASE_URL='${esc(process.env.SUPABASE_URL)}';\nwindow.GPAA_SUPABASE_KEY='${esc(process.env.SUPABASE_PUBLISHABLE_KEY)}';\n`;
fs.writeFileSync('config.js', js);
