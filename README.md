# 📱 Calculadora de Notas - Flutter

Aplicación móvil para calcular el promedio ponderado de 3 notas con validación en tiempo real.

## ✨ Características

- ✅ Cálculo de promedio ponderado de 3 notas
- ✅ Validación en tiempo real con feedback visual
- ✅ Soporte para decimales con coma (formato chileno)
- ✅ Validación de rangos (notas: 1,0 - 7,0)
- ✅ Validación de porcentajes (suma debe ser 100%)
- ✅ Popup elegante para mostrar resultados
- ✅ Indicación clara si debe rendir examen (promedio < 5,5)
- ✅ Interfaz intuitiva con Material Design 3

## 📸 Capturas de pantalla

_Próximamente_

## 🚀 Comenzando

### Prerrequisitos

- Flutter SDK (3.0 o superior)
- Dart SDK (3.0 o superior)
- Android Studio o VS Code
- Emulador Android o dispositivo físico

### Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/jarayaa/calculadora-notas.git
cd calculadora-notas
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## 🎮 Uso

1. Ingresa las 3 notas (rango: 1,0 - 7,0)
2. Asigna el porcentaje de ponderación a cada nota
3. Asegúrate que la suma de porcentajes sea exactamente 100%
4. Presiona "Calcular"
5. Visualiza tu promedio en el popup:
   - **Verde** con "¡Aprobado!" si el promedio es ≥ 5,5
   - **Rojo** con "Debe Rendir Examen" si el promedio es < 5,5

## 🛠️ Tecnologías

- **Flutter** 3.38.3
- **Dart** 3.10.1
- **Material Design 3**

## 📋 Validaciones

### Notas:
- Rango permitido: 1,0 a 7,0 (ambos inclusive)
- Solo acepta números con coma como separador decimal
- Validación en tiempo real con popup de error

### Porcentajes:
- Rango permitido: 0 a 100
- La suma total debe ser exactamente 100%
- Validación en tiempo real con popup de error

## 🎨 Características de UI/UX

- **Feedback visual inmediato:** Bordes rojos cuando hay errores
- **Popups informativos:** Mensajes claros sobre errores de validación
- **Formato chileno:** Uso de coma para decimales (6,5 en lugar de 6.5)
- **Diseño responsive:** Adaptable a diferentes tamaños de pantalla
- **Material Design 3:** Interfaz moderna y elegante

## 📱 Compatibilidad

- ✅ Android 5.0 (API 21) o superior
- ✅ iOS 12.0 o superior (sin probar)
- ✅ Web (sin probar)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👤 Autor

**Jaime Araya Aros**

- GitHub: [@jarayaa](https://github.com/jarayaa)

## Otros

- Inspirado en el sistema de calificaciones de la UNAB.
- Desarrollado con Flutter.
