#!/bin/bash

# ========================================
# JP Universe - Build APK Script
# ========================================

echo "🤖 JP Universe - Build APK"
echo "=================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
PROJECT_DIR="/home/ubuntu/jp-universe-mobile"
BUILD_OUTPUT="$PROJECT_DIR/builds"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Função para imprimir com cor
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Verificar se o projeto existe
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Projeto não encontrado em: $PROJECT_DIR"
    exit 1
fi

print_status "Projeto encontrado"

# Criar diretório de saída
mkdir -p "$BUILD_OUTPUT"
print_status "Diretório de build criado"

# Ir para o diretório do projeto
cd "$PROJECT_DIR" || exit 1
print_status "Entrando no diretório do projeto"

# Instalar dependências
echo ""
echo -e "${BLUE}📦 Instalando dependências...${NC}"
pnpm install --no-frozen-lockfile > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status "Dependências instaladas"
else
    print_error "Erro ao instalar dependências"
    exit 1
fi

# Limpar cache anterior
echo ""
echo -e "${BLUE}🧹 Limpando cache...${NC}"
rm -rf node_modules/.cache > /dev/null 2>&1
print_status "Cache limpo"

# Build para Android
echo ""
echo -e "${BLUE}🔨 Compilando para Android...${NC}"

# Opção 1: Usar EAS Build (Recomendado)
print_info "Tentando usar EAS Build (cloud)..."
eas build --platform android --release --non-interactive 2>&1 | tee "$BUILD_OUTPUT/build_$TIMESTAMP.log"

if [ $? -eq 0 ]; then
    print_status "Build concluído com sucesso!"
    echo ""
    echo -e "${GREEN}=================================="
    echo "✓ APK gerado com sucesso!"
    echo "=================================="
    echo ""
    print_info "O APK será enviado para seu email ou disponível no EAS Build"
    print_info "Acesse: https://expo.dev/builds"
else
    print_warning "EAS Build não disponível, tentando build local..."
    
    # Opção 2: Build local com Gradle
    if [ -d "$PROJECT_DIR/android" ]; then
        cd "$PROJECT_DIR/android" || exit 1
        ./gradlew assembleRelease 2>&1 | tee "$BUILD_OUTPUT/gradle_build_$TIMESTAMP.log"
        
        if [ $? -eq 0 ]; then
            APK_PATH="$PROJECT_DIR/android/app/build/outputs/apk/release/app-release.apk"
            if [ -f "$APK_PATH" ]; then
                cp "$APK_PATH" "$BUILD_OUTPUT/jp-universe-$TIMESTAMP.apk"
                print_status "APK copiado para: $BUILD_OUTPUT/jp-universe-$TIMESTAMP.apk"
            fi
        else
            print_error "Erro ao compilar com Gradle"
            exit 1
        fi
    else
        print_error "Diretório android não encontrado"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}=================================="
echo "📱 Build Finalizado!"
echo "=================================="
echo ""
print_info "Arquivos de build: $BUILD_OUTPUT"
print_info "Log de build: $BUILD_OUTPUT/build_$TIMESTAMP.log"
echo ""
print_info "Próximos passos:"
echo "  1. Baixe o APK"
echo "  2. Transfira para seu Android"
echo "  3. Instale o app"
echo "  4. Aproveite! 🎮"
echo ""
