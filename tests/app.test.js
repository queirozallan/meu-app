const request = require("supertest");
const express = require("express");
const app = express();

app.get("/saudacao", (req, res) => {
  res.json({ mensagem: "Olá, CI/CD funcionando!" });
});

test("Deve responder com a mensagem correta", async () => {
  const response = await request(app).get("/saudacao");
  expect(response.status).toBe(200);
  expect(response.body.mensagem).toBe("Olá, CI/CD funcionando!");
});
