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
      const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || '';
      const res = await fetch(`${apiBaseUrl}/api/fortunes/random`);
      if (!res.ok) throw new Error('Failed to load fortune');
      setFortune(await res.json());
    } catch (e: any) {
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
