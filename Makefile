# Atajos de desarrollo local (§5.5.7). Uso: make <objetivo>
FLUTTER ?= flutter
DART    ?= dart
ADB     ?= adb
APK_PROD := build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk

.PHONY: help run run-prod test gen gen-once apk install format analyze check logs devices clean

help: ## Lista los objetivos
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

run: ## Ascend Dev en modo debug (hot reload)
	$(FLUTTER) run --flavor dev -t lib/main_dev.dart

run-prod: ## Ascend (prod) en modo release, para medir la velocidad real
	$(FLUTTER) run --release --flavor prod -t lib/main_prod.dart

test: ## Pruebas unitarias, de widgets y goldens
	$(FLUTTER) test

gen: ## Generación de código en modo watch (Drift, Riverpod, freezed)
	$(DART) run build_runner watch -d

gen-once: ## Generación de código una sola vez
	$(DART) run build_runner build -d

apk: ## APK release de prod, separado por ABI
	$(FLUTTER) build apk --release --flavor prod -t lib/main_prod.dart --split-per-abi

install: apk ## Compila e instala Ascend (prod) en el celular conectado, sin borrar datos
	$(ADB) install -r $(APK_PROD)

format: ## Formatea el código
	$(DART) format .

analyze: ## Análisis estático
	$(FLUTTER) analyze

check: ## Lo mismo que el pre-commit: formato, análisis y pruebas
	$(DART) format --set-exit-if-changed .
	$(FLUTTER) analyze
	$(FLUTTER) test

logs: ## Logs de Flutter desde el celular
	$(ADB) logcat | grep -i flutter

devices: ## Dispositivos conectados
	$(ADB) devices -l

clean: ## Limpia artefactos de compilación
	$(FLUTTER) clean
