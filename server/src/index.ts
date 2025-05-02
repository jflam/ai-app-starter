import express from 'express';
import cors from 'cors';
import db from './db';

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware to add proper headers
app.use((req, res, next) => {
  res.setHeader('Content-Type', 'application/json');
  next();
});

app.use(cors());

// Simple health check endpoint
app.get('/health', (_, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.get('/api/fortunes/random', async (_req, res) => {
  try {
    console.log('Request received for /api/fortunes/random');
    const fortune = await db<{ id: number; text: string }>('fortunes')
      .orderByRaw('RANDOM()')
      .first();
    
    if (!fortune) {
      console.log('No fortunes found in database');
      return res.status(404).type('application/json').json({ error: 'No fortunes found.' });
    }
    
    console.log('Returning fortune:', fortune);
    res.type('application/json').json(fortune);
  } catch (err) {
    console.error('Error fetching fortune:', err);
    res.status(500).type('application/json').json({ error: 'Internal server error.' });
  }
});

app.listen(PORT, () => {
  console.log(`🪄 Fortune API listening at http://localhost:${PORT}`);
});
