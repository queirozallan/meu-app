const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Aplicação funcionando!");
});

app.listen(3000, () => {
  console.log("Servidor rodando na porta 3000");
});

app.get("/saudacao", (req, res) => {
  res.json({ mensagem: "Olá, CI/CD funcionando!" });
});
