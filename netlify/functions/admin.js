// Netlify Function — admin.js
// Escritura protegida por PIN — solo admin puede modificar datos

const { neon } = require('@neondatabase/serverless');

exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method not allowed' };
  }

  let body;
  try { body = JSON.parse(event.body); }
  catch { return { statusCode: 400, body: 'Bad request' }; }

  const { pin, action, payload } = body;

  // Validar PIN
  if (pin !== process.env.ADMIN_PIN) {
    return { statusCode: 401, body: JSON.stringify({ error: 'PIN incorrecto' }) };
  }

  const sql = neon(process.env.NETLIFY_DATABASE_URL);

  try {
    let result;

    switch (action) {

      case 'verify':
        return { statusCode: 200, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ ok: true }) };

      case 'insert_pago':
        result = await sql`
          INSERT INTO pagos (vecino_id, periodo, monto, tipo, fecha_pago, registrado_por)
          VALUES (${payload.vecino_id}, ${payload.periodo}, ${payload.monto}, ${payload.tipo}, ${payload.fecha_pago || new Date().toISOString().slice(0,10)}, 'admin')
          RETURNING *`;
        break;

      case 'insert_gasto':
        result = await sql`
          INSERT INTO gastos (descripcion, categoria, monto, fecha, notas, realizado)
          VALUES (${payload.descripcion}, ${payload.categoria}, ${payload.monto}, ${payload.fecha}, ${payload.notas || ''}, true)
          RETURNING *`;
        break;

      case 'insert_activo':
        result = await sql`
          INSERT INTO activos (nombre, categoria, valor_aprox, descripcion, estado, fecha_adquisicion)
          VALUES (${payload.nombre}, ${payload.categoria}, ${payload.valor_aprox || null}, ${payload.descripcion || ''}, ${payload.estado}, ${new Date().toISOString().slice(0,10)})
          RETURNING *`;
        break;

      case 'insert_vecino':
        result = await sql`
          INSERT INTO vecinos (nombre, rol, notas, activo)
          VALUES (${payload.nombre}, ${payload.rol}, ${payload.notas || ''}, true)
          RETURNING *`;
        break;

      case 'delete_pago':
        result = await sql`DELETE FROM pagos WHERE id = ${payload.id}`;
        break;

      case 'update_config':
        result = await sql`UPDATE config SET valor = ${payload.valor} WHERE clave = ${payload.clave}`;
        break;

      default:
        return { statusCode: 400, body: JSON.stringify({ error: 'Acción no reconocida' }) };
    }

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ok: true, data: result })
    };

  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message })
    };
  }
};
