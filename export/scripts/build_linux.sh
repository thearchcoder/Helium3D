#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXPORT_DIR="$PROJECT_DIR/export/godot-export/linux"
BUILD_DIR="$PROJECT_DIR/export/build"
FORMULAS_DIR="$PROJECT_DIR/formulas"
APP_NAME="Helium3D"
VERSION="0.9.1-beta"

echo "Building Helium3D for Linux"

echo "Cleaning export directory..."
rm -r "$EXPORT_DIR"/* 2>/dev/null || true
rm -r "$BUILD_DIR"/appimage/* 2>/dev/null || true
rm -r "$BUILD_DIR"/deb/* 2>/dev/null || true
rm -r "$BUILD_DIR"/flatpak/* 2>/dev/null || true

echo "Exporting with Godot..."
cd "$PROJECT_DIR"
/home/thearchcoder/Documents/Godot/Godot_v4.5-stable_mono_linux_x86_64/Godot_v4.5-stable_mono_linux.x86_64 --headless --verbose --export-release "Linux" "$EXPORT_DIR/$APP_NAME.x86_64"

echo "Copying formulas..."
mkdir -p "$EXPORT_DIR/formulas"
cp -r "$FORMULAS_DIR"/* "$EXPORT_DIR/formulas/"

echo "Creating packages..."

mkdir -p "$BUILD_DIR/appimage"
mkdir -p "$BUILD_DIR/deb"
mkdir -p "$BUILD_DIR/flatpak"

echo "Building AppImage..."
APPDIR="$BUILD_DIR/appimage/$APP_NAME.AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

cp "$EXPORT_DIR/$APP_NAME.x86_64" "$APPDIR/usr/bin/$APP_NAME"
cp "$EXPORT_DIR/$APP_NAME.pck" "$APPDIR/usr/bin/"
cp -r "$EXPORT_DIR/formulas" "$APPDIR/usr/bin/"
cp -r "$EXPORT_DIR/data_Helium3D_linuxbsd_x86_64" "$APPDIR/usr/bin/"
cp "$PROJECT_DIR/icon.png" "$APPDIR/helium3d.png"
cp "$PROJECT_DIR/icon.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/helium3d.png"

cp "$SCRIPT_DIR/app.desktop" "$APPDIR/$APP_NAME.desktop"

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
cd "${HERE}/usr/bin"
exec "${HERE}/usr/bin/Helium3D" "$@"
EOF
chmod +x "$APPDIR/AppRun"

if command -v appimagetool &> /dev/null; then
    ARCH=x86_64 appimagetool "$APPDIR" "$BUILD_DIR/appimage/$APP_NAME-$VERSION-x86_64.AppImage"
else
    echo "appimagetool not found, skipping AppImage"
fi

echo "Building DEB package..."
DEBDIR="$BUILD_DIR/deb/$APP_NAME-$VERSION"
rm -rf "$DEBDIR"
mkdir -p "$DEBDIR/DEBIAN"
mkdir -p "$DEBDIR/usr/share/applications"
mkdir -p "$DEBDIR/usr/share/$APP_NAME"

cp "$EXPORT_DIR/$APP_NAME.x86_64" "$DEBDIR/usr/share/$APP_NAME/$APP_NAME.bin"
cp "$EXPORT_DIR/$APP_NAME.pck" "$DEBDIR/usr/share/$APP_NAME/"
cp -r "$EXPORT_DIR/formulas" "$DEBDIR/usr/share/$APP_NAME/"
cp -r "$EXPORT_DIR/data_Helium3D_linuxbsd_x86_64" "$DEBDIR/usr/share/$APP_NAME/"
mkdir -p "$DEBDIR/usr/share/icons/hicolor/256x256/apps"
cp "$PROJECT_DIR/icon.png" "$DEBDIR/usr/share/icons/hicolor/256x256/apps/helium3d.png"

mkdir -p "$DEBDIR/usr/bin"
cat > "$DEBDIR/usr/bin/$APP_NAME" <<'EOF'
#!/bin/bash
cd /usr/share/Helium3D
exec /usr/share/Helium3D/Helium3D.bin "$@"
EOF
chmod +x "$DEBDIR/usr/bin/$APP_NAME"

cp "$SCRIPT_DIR/deb.control" "$DEBDIR/DEBIAN/control"
cp "$SCRIPT_DIR/app.desktop" "$DEBDIR/usr/share/applications/$APP_NAME.desktop"

if command -v dpkg-deb &> /dev/null; then
    dpkg-deb --build "$DEBDIR" "$BUILD_DIR/deb/$APP_NAME-$VERSION-amd64.deb"
else
    echo "dpkg-deb not found, skipping DEB"
fi

echo "Building Flatpak..."
if command -v flatpak-builder &> /dev/null; then
    if flatpak list --runtime | grep -q "org.freedesktop.Platform.*24.08"; then
        mkdir -p "$BUILD_DIR/flatpak/source"
        cp "$EXPORT_DIR/$APP_NAME.x86_64" "$BUILD_DIR/flatpak/source/"
        cp "$EXPORT_DIR/$APP_NAME.pck" "$BUILD_DIR/flatpak/source/"
        cp "$PROJECT_DIR/icon.png" "$BUILD_DIR/flatpak/source/"
        cp "$SCRIPT_DIR/app.desktop" "$BUILD_DIR/flatpak/source/"

        cd "$BUILD_DIR/flatpak/source"
        tar czf formulas.tar.gz -C "$EXPORT_DIR" formulas
        tar czf data.tar.gz -C "$EXPORT_DIR" data_Helium3D_linuxbsd_x86_64

        cp "$SCRIPT_DIR/flatpak.json" .
        flatpak-builder --force-clean "$BUILD_DIR/flatpak/build" flatpak.json
        flatpak build-export "$BUILD_DIR/flatpak/repo" "$BUILD_DIR/flatpak/build"
        flatpak build-bundle "$BUILD_DIR/flatpak/repo" "$BUILD_DIR/flatpak/$APP_NAME-$VERSION.flatpak" com.helium3d.Helium3D
    else
        echo "Flatpak runtime not installed. Install with:"
        echo "  flatpak install flathub org.freedesktop.Platform//24.08 org.freedesktop.Sdk//24.08"
    fi
else
    echo "flatpak-builder not found, skipping Flatpak"
fi

echo "Done. Packages in export/build/"
