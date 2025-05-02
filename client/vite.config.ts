import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: { '/api': 'http://localhost:4000' }
  },
  define: {
    // Make sure environment variables are properly passed to the client
    'process.env.VITE_API_BASE_URL': JSON.stringify(process.env.VITE_API_BASE_URL)
  },
  build: {
    // Generate sourcemaps for easier debugging
    sourcemap: true
  }
});
