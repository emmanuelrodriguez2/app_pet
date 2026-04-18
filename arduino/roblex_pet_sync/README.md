# ROBLEX Pet Sync Firmware

Este sketch extiende el ejemplo de ROBLEX para controlar alimentacion desde la app.

## Comandos que usa la app

- `GET /?cmd=dispense:80`
  - Dispensa una porcion de 80 gramos.
- `GET /?cmd=schedule:1:07:00:80`
  - Programa el slot 1 a las 07:00 para 80 gramos.
- `GET /?cmd=schedule:2:18:00:80`
  - Programa el slot 2 a las 18:00 para 80 gramos.
- `GET /?r201g32b255&`
  - Compatible con ejemplo original ROBLEX para RGB.

## Importante

Dentro del sketch hay comentarios `TODO` donde debes conectar tu logica real de motor/servo del dispensador.
