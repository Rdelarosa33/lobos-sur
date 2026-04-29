// Netlify Function — datos.js
// Lectura pública de todos los datos (vecinos, pagos, gastos, activos, config)
// No requiere PIN — cualquier visitante puede leer

const { neon } = require('@neondatabase/serverless');

exports.handler = async (event) => {
  const sql = neon(process.env.NETLIFY_DATABASE_URL);

  try {
    const [vecinos, pagos, gastos, activos, config] = await Promise.all([
      sql`SELECT * FROM vecinos ORDER BY id`,
      sql`SELECT * FROM pagos`,
      sql`SELECT * FROM gastos ORDER BY fecha`,
      sql`SELECT * FROM activos ORDER BY id`,
      sql`SELECT * FROM config`
    ]);

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ vecinos, pagos, gastos, activos, config })
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message })
    };
  }
};
