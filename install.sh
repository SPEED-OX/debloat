#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/SPEED-OX/debloate/main"
INSTALL_DIR="$HOME/.debloate"

echo "📦 Installing 'debloate' to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR/lists"

# Download main script
curl -sS "$REPO/debloater.py" -o "$INSTALL_DIR/debloater.py"

# Download all package lists you maintain
for file in realme.txt xiaomi.txt; do
    curl -sS "$REPO/lists/$file" -o "$INSTALL_DIR/lists/$file"
done

chmod +x "$INSTALL_DIR/debloater.py"

# Create launcher in Termux
LAUNCHER="$PREFIX/bin/debloate"
echo -e "#!/data/data/com.termux/files/usr/bin/bash\npython3 $INSTALL_DIR/debloater.py" > "$LAUNCHER"
chmod +x "$LAUNCHER"

echo ""
echo "✅ Installation complete!"
echo "🚀 Launch the tool anytime by typing:"
echo ""
echo "  debloate"
echo ""
