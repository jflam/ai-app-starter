// Migration script to run before starting the server
import knex from 'knex';
import config from '../knexfile.js';

const environment = process.env.NODE_ENV || 'development';
console.log(`Running migrations for environment: ${environment}`);

const db = knex(config[environment]);

async function runMigrations() {
  try {
    console.log('Running database migrations...');
    await db.migrate.latest();
    console.log('Migrations complete.');
    
    console.log('Running database seeds...');
    await db.seed.run();
    console.log('Seeding complete.');
  } catch (error) {
    console.error('Error running migrations and seeds:', error);
    process.exit(1);
  } finally {
    await db.destroy();
  }
}

runMigrations();
