const fs = require('fs');
const path = require('path');

const outputDirectory = path.join(__dirname, 'dist');
const publicFiles = ['index.html', 'gpaa-logo.jpg'];

fs.rmSync(outputDirectory, { recursive: true, force: true });
fs.mkdirSync(outputDirectory, { recursive: true });

for (const file of publicFiles) {
  fs.copyFileSync(path.join(__dirname, file), path.join(outputDirectory, file));
}

const config = [
  `window.GPAA_SUPABASE_URL=${JSON.stringify(process.env.SUPABASE_URL || '')};`,
  `window.GPAA_SUPABASE_KEY=${JSON.stringify(process.env.SUPABASE_PUBLISHABLE_KEY || '')};`,
  '',
].join('\n');

fs.writeFileSync(path.join(outputDirectory, 'config.js'), config);
