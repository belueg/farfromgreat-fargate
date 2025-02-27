const request = require('supertest')
const { app, server } = require('../server')

jest.mock('pg', () => {
  const mClient = {
    connect: jest.fn(),
    query: jest
      .fn()
      .mockResolvedValue({ rows: [{ now: new Date().toISOString() }] }),
    end: jest.fn()
  }
  return { Client: jest.fn(() => mClient) }
})

describe('API Endpoints', () => {
  afterAll(() => {
    server.close() 
    jest.clearAllMocks() 
  })

  it('should return a response from the root endpoint', async () => {
    const res = await request(app).get('/')
    expect(res.statusCode).toEqual(200)
    expect(res.text).toContain('¡Hello, Docker!')
  })
})
