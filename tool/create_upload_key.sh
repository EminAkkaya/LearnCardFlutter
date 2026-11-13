#!/usr/bin/env bash
# LearnCard Play "upload key" üretir ve android/key.properties dosyasını yazar.
# Parola yalnız bu terminalde sorulur; ekrana ya da komut satırına düşmez.
# Kullanım: bash tool/create_upload_key.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY_DIR="$HOME/.android-keys"
KEYSTORE="$KEY_DIR/learncard-upload.jks"
PROPS="$ROOT/android/key.properties"
ALIAS="upload"

if [[ -e "$KEYSTORE" || -e "$PROPS" ]]; then
  echo "Zaten var, üzerine yazılmadı:"
  [[ -e "$KEYSTORE" ]] && echo "  $KEYSTORE"
  [[ -e "$PROPS" ]] && echo "  $PROPS"
  exit 1
fi

read -rsp "Anahtar parolası (en az 8 karakter): " P1; echo
read -rsp "Parolayı tekrar gir: " P2; echo
if [[ "$P1" != "$P2" ]]; then echo "Parolalar aynı değil."; exit 1; fi
if (( ${#P1} < 8 )); then echo "Parola en az 8 karakter olmalı."; exit 1; fi
if [[ "$P1" == *$'\n'* || "$P1" == *\\* ]]; then echo "Parolada ters bölü (\\) kullanma."; exit 1; fi

mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

# PKCS12 anahtar deposunda anahtar ve depo parolası aynıdır.
export LC_STOREPASS="$P1"
keytool -genkeypair -v \
  -keystore "$KEYSTORE" -storetype PKCS12 \
  -alias "$ALIAS" -keyalg RSA -keysize 4096 -validity 10000 \
  -dname "CN=Muhammet Emin Akkaya, L=Sakarya, C=TR" \
  -storepass:env LC_STOREPASS -keypass:env LC_STOREPASS
unset LC_STOREPASS
chmod 600 "$KEYSTORE"

umask 077
cat > "$PROPS" <<EOF
storePassword=$P1
keyPassword=$P1
keyAlias=$ALIAS
storeFile=$KEYSTORE
EOF
unset P1 P2

echo
echo "Hazır:"
echo "  Anahtar:   $KEYSTORE"
echo "  Ayarlar:   $PROPS (gitignore'da)"
echo "Bu .jks dosyasını ve parolayı güvenli bir yere yedekle; kaybolursa güncelleme yüklenemez."
