const express = require('express')
const { Client } = require('pg')

const app = express()
const port = 3000

const client = new Client({
  user: process.env.PG_USER,
  host: process.env.PG_HOST,
  database: process.env.PG_DATABASE,
  password: process.env.PG_PASSWORD,
  port: process.env.PG_PORT
})

client.connect()
    .then(() => console.log('Connected to PostgreSQL'))
    .catch(err => console.error('Error connecting', err));

app.get('/', async (req, res) => {
    try {
        const result = await client.query('SELECT NOW()');
        res.send(`¡Hello, Docker! 🐳  The time ⏱️ in PostgreSQL is: ${result.rows[0].now}\n`);
    } catch (error) {
        res.send(`Error querying PostgreSQL: ${error}\n`);
    }})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
