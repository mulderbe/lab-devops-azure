// server.js — app web mínima de Node.js, sin dependencias (solo el módulo http).
const http = require("http");
const os = require("os");

const puerto = process.env.PORT || 8080;

http
  .createServer((req, res) => {
    res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
    res.end(
      [
        "Lab 5 de 6 - Azure Container Apps",
        `Version: ${process.env.VERSION}`,
        `Replica: ${os.hostname()}`,
        `Mensaje del Key Vault: ${process.env.MENSAJE ?? "(no llego)"}`,
        "",
      ].join("\n")
    );
  })
  .listen(puerto, () => console.log(`Escuchando en el puerto ${puerto}`));
