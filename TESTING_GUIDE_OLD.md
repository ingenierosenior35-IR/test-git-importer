# Guía de Verificación Visual - Home Unificado

## Objetivo
Verificar que solo existe una versión de la pantalla Home en toda la aplicación, independientemente del flujo de navegación.

## Características de la HomePage Correcta

### ✅ Elementos que DEBEN estar presentes:

1. **Barra Superior (Top Match Strip)**
   - Icono del clima a la izquierda
   - Texto "Próximo partido de liga" y nombre del partido
   - Iconos de búsqueda y notificaciones a la derecha
   - Fondo oscuro/gris

2. **Banner de Rendimiento (Performance Hero Card)**
   - Fondo **amarillo** (`AppColors.kYellowAccent`)
   - Texto "PERFORMANCE" en mayúsculas
   - "Último partido"
   - "Minutos jugados"
   - Número grande "108 pases totales" u otra estadística
   - Rating "8.5" en chip negro
   - Foto del jugador en círculo (o icono de persona)

3. **Sección "Tus favoritos"**
   - Título "TUS FAVORITOS" con botón "Ver todo"
   - Lista horizontal de tarjetas de clubes
   - Cada tarjeta con icono de fútbol, nombre del club, y estado (Ganó/Empató/Perdió)

4. **Sección "Herramientas"**
   - Título "HERRAMIENTAS"
   - Lista horizontal con botones:
     - Partidos (fondo amarillo, primario)
     - Pollas
     - Fixtures
     - Clima
     - Entrenamiento
     - Equipos
     - Torneos

5. **Sección "Días de juego"**
   - Título "DÍAS DE JUEGO"
   - 7 chips con letras: L, M, X, J, V, S, D

6. **Sección "Tus partidos"**
   - Título "TUS PARTIDOS"
   - Lista horizontal de tarjetas de partidos
   - Cada tarjeta con fecha, nombre, ubicación, hora

### ✅ Características de Diseño:

- **Fondo:** Negro/gris oscuro (`AppColors.kDarkBackground`)
- **Tarjetas:** Gris oscuro (`AppColors.kDarkCard`)
- **Acentos:** Amarillo neón (`AppColors.kYellowAccent`)
- **Textos:** Blancos, grises, sin subrayado
- **Layout:** No pegado al borde superior (con SafeArea)
- **Scroll:** Se puede hacer scroll vertical para ver todo el contenido

## Escenarios de Prueba

### Escenario 1: Usuario Ya Autenticado

**Pasos:**
1. Tener la app cerrada
2. Estar ya autenticado (haber iniciado sesión previamente)
3. Abrir la app

**Resultado Esperado:**
- Se muestra `SplashScreen` por 3 segundos
- Luego se muestra **HomePage** con todas las características listadas arriba
- El layout debe verse correcto (no pegado al borde superior)

**✅ PASS si:** Se ve HomePage con banner amarillo, favoritos, herramientas, etc.  
**❌ FAIL si:** Se ve una pantalla diferente o con estilos distintos

---

### Escenario 2: Iniciar Sesión con Email

**Pasos:**
1. Estar sin autenticar
2. Abrir la app → Ver `WelcomeScreen`
3. Tap en "Iniciar sesión con email"
4. Ingresar email y contraseña
5. Tap en "Iniciar sesión"

**Resultado Esperado:**
- Si el usuario ya completó onboarding: Se muestra **la misma HomePage** del Escenario 1
- Si el usuario NO completó onboarding: Se muestra `SportSelectionScreen` → completar onboarding → luego **HomePage**

**✅ PASS si:** Después de login, se ve la HomePage con banner amarillo, favoritos, herramientas  
**❌ FAIL si:** Se ve una pantalla diferente o con estilos distintos

---

### Escenario 3: Registro con Email

**Pasos:**
1. Estar sin autenticar
2. Abrir la app → Ver `WelcomeScreen`
3. Tap en "Crear cuenta"
4. Ingresar email, contraseña, nombre
5. Tap en "Registrarse"
6. Completar onboarding (deporte, género, altura, peso, medidas, foto)
7. Ver pantalla de "¡Felicitaciones!"

**Resultado Esperado:**
- Después de 5 segundos en pantalla de felicitaciones, navega automáticamente
- Se muestra **la misma HomePage** de los escenarios anteriores

**✅ PASS si:** Se ve HomePage con banner amarillo, favoritos, herramientas  
**❌ FAIL si:** Se ve una pantalla diferente o con estilos distintos

---

### Escenario 4: Iniciar Sesión con Google

**Pasos:**
1. Estar sin autenticar
2. Abrir la app → Ver `WelcomeScreen`
3. Tap en botón de Google
4. Completar autenticación de Google

**Resultado Esperado:**
- Se muestra **la misma HomePage** de los escenarios anteriores

**✅ PASS si:** Se ve HomePage con banner amarillo, favoritos, herramientas  
**❌ FAIL si:** Se ve una pantalla diferente o con estilos distintos

---

### Escenario 5: Cerrar Sesión y Volver a Entrar

**Pasos:**
1. Estar autenticado y en HomePage
2. Ir a Perfil (último tab del bottom nav)
3. Tap en "Configuración" o botón de logout
4. Cerrar sesión
5. Se muestra `WelcomeScreen`
6. Volver a iniciar sesión (con cualquier método)

**Resultado Esperado:**
- Después de re-login, se muestra **la misma HomePage** de antes

**✅ PASS si:** Se ve HomePage con banner amarillo, favoritos, herramientas  
**❌ FAIL si:** Se ve una pantalla diferente, con textos subrayados, o estilos antiguos

---

## ❌ Versión INCORRECTA que NO debe aparecer

Si ves una pantalla con estas características, es la versión antigua (INCORRECTA):

- Título "Hola, [Nombre]"
- Texto "Bienvenido a Rival"
- Sección de "Acceso Rápido" con 3 botones: Pollas, Fixtures, Clima
- Sección de "Scoreboards"
- **Esta versión NO debe aparecer en ningún flujo**

## Checklist Final

Después de todas las pruebas:

- [ ] Escenario 1 (Ya autenticado) → HomePage correcta ✅
- [ ] Escenario 2 (Login con email) → HomePage correcta ✅
- [ ] Escenario 3 (Registro con email) → HomePage correcta ✅
- [ ] Escenario 4 (Login con Google) → HomePage correcta ✅
- [ ] Escenario 5 (Logout y re-login) → HomePage correcta ✅
- [ ] Nunca apareció la versión con "Acceso Rápido" ✅
- [ ] Nunca apareció texto subrayado ✅
- [ ] El layout se ve bien (no pegado al borde superior) ✅

**Si todos los checkboxes están marcados, la unificación fue exitosa.** 🎉
