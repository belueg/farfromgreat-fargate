const express = require('express')
const { Client } = require('pg')

const app = express()
const port = 3000

let client 

if (process.env.PG_HOST) {
  client = new Client({
    user: process.env.PG_USER || 'postgres',
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE || 'mydb',
    password: process.env.PG_PASSWORD || 'password',
    port: process.env.PG_PORT || 5432
  })

  client
    .connect()
    .then(() => console.log('✅ Connected to PostgreSQL'))
    .catch(err =>
      console.error('❌ Error connecting to PostgreSQL:', err.message)
    )
}

app.get('/', async (req, res) => {
  if (!client) {
    return res.send(
      '🔥 PostgreSQL is not configured. The app is running without a DB. 🔥\n'
    )
  }

  try {
    const result = await client.query('SELECT NOW()')
    res.send(
      `¡Hello, Docker! 🐳 The time ⏱️ in PostgreSQL is: ${result.rows[0].now}\n`
    )
  } catch (error) {
    console.error('❌ Database query error:', error.message)
    res.send(`Error querying PostgreSQL: ${error.message}\n`)
  }
})

app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Example app listening on port ${port}`)
})

