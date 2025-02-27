const express = require('express')
const { Client } = require('pg')
const fs = require('fs')

const app = express()
const port = 3000

let client

const sslConfig =
  process.env.PG_SSL_CERT_PATH && fs.existsSync(process.env.PG_SSL_CERT_PATH)
    ? { ca: fs.readFileSync(process.env.PG_SSL_CERT_PATH) }
    : false

const connectDB = async () => {
  client = new Client({
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE,
    password: process.env.PG_PASSWORD,
    port: process.env.PG_PORT,
    connectionTimeoutMillis: 3000,
    ssl: sslConfig
  })

  try {
    await client.connect()
    console.log('✅ Connected to PostgreSQL')
  } catch (error) {
    console.error('❌ DB connection error:', error.message)
    client = null 
  }
}

connectDB()

app.get('/', async (req, res) => {
  if (!client) {
    return res.send(
      '🔥 PostgreSQL connection error. Check your DB configuration. 🔥\n'
    )
  }

  try {
    const result = await client.query('SELECT NOW()')
    res.send(
      `¡Hello, Docker! 🐳 The time ⏱️ in PostgreSQL is: ${result.rows[0].now}\n`
    )
  } catch (error) {
    console.error('❌ Query error:', error.message)
    res.send(`Error querying PostgreSQL: ${error.message}\n`)
  }
})

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Example app listening on port ${port}`)
})


module.exports = { app, server }  