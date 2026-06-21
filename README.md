# ThaClick ⚡

**ThaClick** es una potente herramienta y servicio de accesibilidad para Android diseñada para automatizar flujos de trabajo repetitivos en pantallas táctiles mediante la inyección y grabación de secuencias de toques (macros).

Construida con **Flutter** en el front-end y **Kotlin** nativo en el back-end, ThaClick proporciona una experiencia de usuario fluida con un motor de inyección de gestos sumamente avanzado. Gracias a su sistema nativo de "humanización" (Jitter), la aplicación previene la detección por parte de algoritmos de monitoreo de bots mediante variaciones orgánicas y dinámicas en cada acción.

## Características Principales 🚀

* **Panel Flotante Persistente:** Controla la reproducción, grabación y ajustes de tus automatizaciones en cualquier momento a través de una superposición (Overlay) ininterrumpida que opera por encima del resto del sistema.
* **Múltiples Patrones:** Crea, guarda, clona y alterna entre diferentes configuraciones y secuencias de puntos instantáneamente para distintos casos de uso.
* **Interfaz Dinámica (Drag & Drop):** Modifica el orden y la estructura de los toques fácilmente mediante arrastrar y soltar.
* **Edición Precisa:** Ajusta directamente la duración/espera en milisegundos (`T`) y las coordenadas (`X`, `Y`) de cada evento con solo tocarlo en la lista.
* **Motor de Evasión Anti-Bot Integrado:**
  * **Dispersión Espacial (Spread):** Cada toque varía su zona de impacto dentro de un radio paramétrico (±40px), evitando repetir toques en el mismo píxel.
  * **Jitter Físico y de Tiempo:** Los intervalos de inactividad y el tiempo físico de contacto en la pantalla varían de manera aleatoria.
  * **Micro-deslizamientos Orgánicos:** Simula un ligero arrastre de fricción (2 a 6 píxeles) tras la pulsación para imitar completamente a un usuario humano real.
* **Soporte Moderno (Android 14+):** Funciona como un `ForegroundService` con permisos especiales de uso, previniendo que las capas de optimización de batería detengan la ejecución.

## Instalación y Ejecución 🛠️

Asegúrate de contar con el entorno de **Flutter** configurado para Android.

1. Navega al proyecto:
   ```bash
   cd touch
   ```
2. Obtén las dependencias de Flutter:
   ```bash
   flutter pub get
   ```
3. Compila el binario APK optimizado para tu dispositivo:
   ```bash
   flutter build apk --release
   ```
   *(También puedes instalar de manera inmediata con `flutter run`)*.

## Requisitos de Permisos del Sistema ⚙️

Para operar adecuadamente e inyectar toques, ThaClick solicitará y requerirá permisos especiales en el dispositivo:
- **Mostrar sobre otras aplicaciones (Overlay):** Obligatorio para proyectar el menú de botones.
- **Servicio de Accesibilidad (Accessibility):** Base fundamental para emitir gestos nativos de Android y simular los toques.
- **Notificaciones (Foreground Service):** Para que la herramienta pueda mantenerse en "espera" oculta y ser llamada rápidamente sin interrupciones del sistema.
