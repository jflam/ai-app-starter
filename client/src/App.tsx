import { useEffect, useState } from 'react';
// Import the type declarations to recognize import.meta.env
/// <reference types="vite/client" />

interface Fortune {
  id: number;
  text: string;
}

export default function App() {
  const [fortune, setFortune] = useState<Fortune | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);  const fetchFortune = async () => {
    setLoading(true);
    setError(null);
    try {
      // In production, API_BASE_URL is available as window.API_BASE_URL (set at runtime)
      // In development, use the Vite env variable
      const apiBaseUrl = (window as any).API_BASE_URL || import.meta.env.VITE_API_BASE_URL || '';
      console.log('Fetching fortune from', `${apiBaseUrl}/api/fortunes/random`);
      
      // Add cache-busting query parameter to prevent caching issues
      const timestamp = new Date().getTime();
      const res = await fetch(`${apiBaseUrl}/api/fortunes/random?_t=${timestamp}`, {
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache'
        }
      });
      
      // Check for non-JSON responses
      const contentType = res.headers.get('content-type');
      if (!contentType || !contentType.includes('application/json')) {
        const text = await res.text();
        console.error('Server returned non-JSON response:', text);
        throw new Error(`Server returned non-JSON response: ${contentType || 'unknown'}`);
      }
      
      // Parse JSON once
      const data = await res.json();
      
      if (!res.ok) {
        throw new Error(data?.error || `Server responded with status: ${res.status}`);
      }
      
      setFortune(data);
    } catch (e: any) {
      console.error('Error fetching fortune:', e);
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFortune();
  }, []);

  return (
    <div className="app-container">
      <div className="card">
        {loading && <p>Loading…</p>}
        {error && <p className="error">Error: {error}</p>}
        {fortune && <p>{fortune.text}</p>}
      </div>
      <button className="btn" onClick={fetchFortune} disabled={loading}>
        moar fortunes
      </button>
    </div>
  );
}
