# Mon Cangur

Reconstrucción de la app Flutter `cangur_app` (versión 1.0.0+1) a partir de lo que todavía sirve [moncangur.web.app](https://moncangur.web.app/).

Firebase Hosting solo guarda el build de `flutter build web` (26 de junio de 2026): `main.dart.js` minificado, sin source map, más imágenes, fuentes y dos páginas de pago. El Dart original no está en ese despliegue y no aparece en ningún repositorio público. Esta copia reescribe las pantallas, las rutas, los textos, el tema y las reglas de precio y disponibilidad que sí se pueden leer en ese build. Los datos son de demostración y **no se conectan** al Firebase de producción.

## Cómo ejecutarla

Hace falta Flutter 3.47 o posterior.

```bash
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 43123
```

Abre la app en el navegador. Cuentas de prueba, contraseña `demo1234`:

- `familia@moncangur.ad` — familia
- `cangur@moncangur.ad` — cangur
- `admin@moncangur.ad` — administración

También existen `marc@moncangur.ad` y `anna@moncangur.ad`.

## Qué se recuperó del build

- Rutas: `/login`, `/signup`, `/admin`, `/cangur`, `/father`. El rol decide el destino (0 admin, 1 cangur, 2 familia).
- Tema `AppColors` citado por `web/pago-ok.html` y `web/pago-ko.html`: fondo `#f3d7b7`, marrón `#8b5a2b`, turquesa `#5fadbb`, oliva `#d4d9a1`.
- Fuentes del bundle: M PLUS Rounded 1c y Cy Grotesk Key. Las páginas de pago pedían CoreBandiFace y Scripter, pero esos archivos no están en el hosting.
- Imágenes: `cangurLogin.png`, `signupImage.png`, `FamiliaMC.png`.
- Textos en catalán, castellano, inglés y francés (bienvenida, auth, servicios, reservas, perfil, admin, pago).
- Servicios: ocasional, emergencia, repaso, fijo y eventos. Tipos de evento: cumpleaños, fiesta, boda, excursión, otros. Edades: 0-2, 3-6, 7-12 y adolescentes.
- Precio: `tarifaBase`, `tarifaConIGI`, `igi`, `tarifasPorNinos` y `tarifasPorNinosConIGI`. La comisión de la pantalla de resumen es la diferencia del IGI. El IGI de demostración es el 4,5 %; las tarifas reales viven en Firestore.
- Disponibilidad semanal (`lunes`…`domingo`, franjas `inicio`/`fin`) y excepciones. Una franja cubre la reserva solo si la hora de fin es posterior a la de inicio y el intervalo cabe entero dentro de la franja.
- Colecciones nombradas en el cliente: `users`, `servicios`, `perfiles_canguro`, `perfiles_padre`, `reservas`, `disponibilidad`, `excepciones_disponibilidad`, `reviews`.
- Pago: Redsys devolvía a `pago-ok.html` / `pago-ko.html`, que avisan a la app con `{ source: "moncangur_redsys", kind: "payment_result" }`. Aquí el pago se simula.
- Configuración web de Firebase del proyecto `moncangur`, en `lib/firebase_options.dart`. No se inicializa el SDK.

## Lo que no se puede reconstruir

El código Dart original, los documentos de Firestore, las Cloud Functions (`crearPago`, `crearReserva`) y las credenciales de Redsys. Si aparece el repositorio privado o un export de las functions, se puede volver a conectar esta estructura con los datos reales.
