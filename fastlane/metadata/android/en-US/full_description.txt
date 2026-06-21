<h1>
  <img src="assets/thaclick_logo.svg" width="40" align="center" alt="ThaClick Logo" /> ThaClick
</h1>

<div align="center">
  <a href="#english">English</a> | <a href="#español">Español</a>
</div>

<br>

<div align="justify">

<h2 id="english">English</h2>


Built with **Flutter** on the front-end and native **Kotlin** on the back-end, ThaClick provides a seamless user experience coupled with a highly advanced gesture injection engine. Thanks to its native "humanization" (Jitter) system, the app prevents detection by bot-monitoring heuristics through organic and dynamic variations in every single action.

### Key Features

* **Persistent Floating Panel:** Control playback, recording, and macro adjustments at any time via an uninterrupted overlay that operates seamlessly on top of the entire system.
* **Multiple Patterns:** Instantly create, save, clone, and switch between different configurations and point sequences for various use cases.
* **Dynamic Interface (Drag & Drop):** Easily modify the order and structure of your touches using a simple drag-and-drop mechanism.
* **Precise Editing:** Directly adjust the duration/delay in milliseconds (`T`) and the exact coordinates (`X`, `Y`) of each event by simply tapping it on the list.
* **Integrated Anti-Bot Evasion Engine:**
  * **Spatial Spread:** Every touch dynamically shifts its impact zone within a parametric radius (±40px), avoiding repeated pixel-perfect touches.
  * **Physical & Timing Jitter:** Inactivity intervals and physical screen contact times vary randomly.
  * **Organic Micro-Swipes:** Simulates a slight friction drag (2 to 6 pixels) after every tap to perfectly mimic a real human finger.
* **Modern Android Support (14+):** Runs as a `ForegroundService` with special-use permissions, preventing battery optimization layers from killing the background execution.

### Installation & Build

Ensure you have the **Flutter** environment configured for Android.

1. Navigate to the project directory:
   ```bash
   cd touch
   ```
2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Compile the optimized APK binary for your device:
   ```bash
   flutter build apk --release
   ```

   *(You can also install immediately via `flutter run`)*

### System Permission Requirements

To operate properly and inject touch events, ThaClick will request and require special permissions on your device:

* **Display over other apps (Overlay):** Mandatory to project the floating control menu.
* **Accessibility Service:** The fundamental core required to emit native Android gestures and simulate touches.
* **Notifications (Foreground Service):** Allows the tool to remain in a hidden "standby" mode and be summoned quickly without OS interruptions.

### Credits

Crafted with love and dedication by **E33-a**.

</div>

<hr>

<div align="justify">

<h2 id="español">Español</h2>

**ThaClick** es una potente herramienta y servicio de accesibilidad para Android diseñada para automatizar flujos de trabajo repetitivos en pantallas táctiles mediante la inyección y grabación de secuencias de toques (macros).

Construida con **Flutter** en el front-end y **Kotlin** nativo en el back-end, ThaClick proporciona una experiencia de usuario fluida con un motor de inyección de gestos sumamente avanzado. Gracias a su sistema nativo de "humanización" (Jitter), la aplicación previene la detección por parte de algoritmos de monitoreo de bots mediante variaciones orgánicas y dinámicas en cada acción.

### Características Principales

* **Panel Flotante Persistente:** Controla la reproducción, grabación y ajustes de tus automatizaciones en cualquier momento a través de una superposición (Overlay) ininterrumpida que opera por encima del resto del sistema.
* **Múltiples Patrones:** Crea, guarda, clona y alterna entre diferentes configuraciones y secuencias de puntos instantáneamente para distintos casos de uso.
* **Interfaz Dinámica (Drag & Drop):** Modifica el orden y la estructura de los toques fácilmente mediante arrastrar y soltar.
* **Edición Precisa:** Ajusta directamente la duración/espera en milisegundos (`T`) y las coordenadas (`X`, `Y`) de cada evento con solo tocarlo en la lista.
* **Motor de Evasión Anti-Bot Integrado:**
  * **Dispersión Espacial (Spread):** Cada toque varía su zona de impacto dentro de un radio paramétrico (±40px), evitando repetir toques en el mismo píxel.
  * **Jitter Físico y de Tiempo:** Los intervalos de inactividad y el tiempo físico de contacto en la pantalla varían de manera aleatoria.
  * **Micro-deslizamientos Orgánicos:** Simula un ligero arrastre de fricción (2 a 6 píxeles) tras la pulsación para imitar completamente a un usuario humano real.
* **Soporte Moderno (Android 14+):** Funciona como un `ForegroundService` con permisos especiales de uso, previniendo que las capas de optimización de batería detengan la ejecución.

### Instalación y Ejecución

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

   *(También puedes instalar de manera inmediata con `flutter run`)*

### Requisitos de Permisos del Sistema

Para operar adecuadamente e inyectar toques, ThaClick solicitará y requerirá permisos especiales en el dispositivo:

* **Mostrar sobre otras aplicaciones (Overlay):** Obligatorio para proyectar el menú de botones.
* **Servicio de Accesibilidad (Accessibility):** Base fundamental para emitir gestos nativos de Android y simular los toques.
* **Notificaciones (Foreground Service):** Para que la herramienta pueda mantenerse en "espera" oculta y ser llamada rápidamente sin interrupciones del sistema.

### Créditos

Creada con esfuerzo y dedicación por **E33-a**.

</div>
