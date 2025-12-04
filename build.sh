#!/bin/bash

# Compile all .tex files in tex/ folder to pdfs/ folder
# Uses pdflatex and latexmk for reliable builds

set -e

# Configuration
TEX_DIR="tex"
PDF_DIR="pdfs"
THEME_DIR="$TEX_DIR/beamerthemes"
LATEX_CMD="latexmk -pdf -interaction=nonstopmode"

# Create output directory if it doesn't exist
mkdir -p "$PDF_DIR"

# Check if tex directory exists
if [ ! -d "$TEX_DIR" ]; then
    echo "Error: '$TEX_DIR' directory not found."
    exit 1
fi

# Compile all .tex files
tex_files=("$TEX_DIR"/*.tex)

if [ ${#tex_files[@]} -eq 0 ] || [ ! -e "${tex_files[0]}" ]; then
    echo "No .tex files found in '$TEX_DIR/'."
    exit 1
fi

echo "Building LaTeX files..."
for tex_file in "${tex_files[@]}"; do
    if [ -f "$tex_file" ]; then
        filename=$(basename "$tex_file" .tex)
        echo "Compiling: $tex_file → $PDF_DIR/$filename.pdf"
        
        # Use latexmk with TEXINPUTS to find theme files
        TEXINPUTS=".:$THEME_DIR:" $LATEX_CMD -outdir="$PDF_DIR" "$tex_file" > /dev/null 2>&1 || {
            echo "Error compiling $tex_file"
            exit 1
        }
    fi
done

echo "✓ Build complete! PDFs saved to '$PDF_DIR/'."
ls -lh "$PDF_DIR"/*.pdf 2>/dev/null || echo "No PDFs generated."

# Clean temporary files
echo "Cleaning temporary LaTeX files..."
latexmk -c -outdir="$PDF_DIR" "$TEX_DIR"/*.tex > /dev/null 2>&1 || true
rm -f "$TEX_DIR"/*.fls "$TEX_DIR"/*.fdb_latexmk "$PDF_DIR"/*.fls "$PDF_DIR"/*.fdb_latexmk "$PDF_DIR"/*.aux "$PDF_DIR"/*.log "$PDF_DIR"/*.out "$PDF_DIR"/*.toc "$PDF_DIR"/*.nav "$PDF_DIR"/*.snm "$PDF_DIR"/*.vrb
echo "✓ Cleanup complete."
