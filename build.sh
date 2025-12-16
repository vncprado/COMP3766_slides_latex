#!/bin/bash

# Compile one or all .tex files in tex/ folder to pdfs/ folder
# Uses pdflatex and latexmk for reliable builds

set -e

# Configuration
TEX_DIR="tex"
PDF_DIR="pdfs"
THEME_DIR="$TEX_DIR"
LATEX_CMD="latexmk -pdf -interaction=nonstopmode"

# Get the command-line argument (the file to build, if specified)
BUILD_FILE="$1"

# Create output directory if it doesn't exist
mkdir -p "$PDF_DIR"

# Always use absolute path for output directory so latexmk doesn't create
# the directory relative to the source when using -cd
OUTDIR_ABS="$(pwd)/$PDF_DIR"

# Check if tex directory exists
if [ ! -d "$TEX_DIR" ]; then
    echo "Error: '$TEX_DIR' directory not found."
    exit 1
fi

# Determine the files to compile
if [ -n "$BUILD_FILE" ]; then
    # Specific file provided as argument
    if [ ! -f "$BUILD_FILE" ]; then
        echo "Error: Specified file '$BUILD_FILE' not found."
        exit 1
    fi
    # Ensure it's a .tex file
    if [[ "$BUILD_FILE" != *.tex ]]; then
        echo "Error: Specified file '$BUILD_FILE' is not a .tex file."
        exit 1
    fi
    
    tex_files=("$BUILD_FILE")
    echo "Building specified LaTeX file..."
else
    # No file specified, compile all
    tex_files=("$TEX_DIR"/*.tex)
    
    if [ ${#tex_files[@]} -eq 0 ] || [ ! -e "${tex_files[0]}" ]; then
        echo "No .tex files found in '$TEX_DIR/'."
        exit 1
    fi
    
    echo "Building all LaTeX files..."
fi

# Compile the files
for tex_file in "${tex_files[@]}"; do
    # Check if the file actually exists (important for the glob case when no files are found)
    if [ -f "$tex_file" ]; then
        filename=$(basename "$tex_file" .tex)
        echo "Compiling: $tex_file → $PDF_DIR/$filename.pdf"
        
        # Use latexmk with TEXINPUTS to find theme files. Pass absolute
        # outdir so files are written to repo-level pdfs/ not tex/pdfs/.
        # Output is piped to null to suppress the normal latexmk output
        TEXINPUTS=".:$THEME_DIR:" $LATEX_CMD -outdir="$OUTDIR_ABS" "$tex_file" > /dev/null 2>&1 || {
            echo "Error compiling $tex_file"
            exit 1
        }
    fi
done

echo "✓ Build complete! PDFs saved to '$PDF_DIR/'."

# List generated PDFs
# Only list files that were actually built, or all if nothing was specified
if [ -n "$BUILD_FILE" ] && [ -f "$PDF_DIR/$filename.pdf" ]; then
    ls -lh "$PDF_DIR/$filename.pdf"
elif [ ! -n "$BUILD_FILE" ]; then
    ls -lh "$PDF_DIR"/*.pdf 2>/dev/null || echo "No PDFs generated."
fi


# Clean temporary files
echo "Cleaning temporary LaTeX files..."
# The cleaning logic is kept to clean files for all .tex files in TEX_DIR to simplify.
# Use absolute outdir when asking latexmk to clean
latexmk -c -outdir="$OUTDIR_ABS" "$TEX_DIR"/*.tex > /dev/null 2>&1 || true
# Remove other common temporary files directly
rm -f "$TEX_DIR"/*.fls "$TEX_DIR"/*.fdb_latexmk "$OUTDIR_ABS"/*.fls "$OUTDIR_ABS"/*.fdb_latexmk "$OUTDIR_ABS"/*.aux "$OUTDIR_ABS"/*.log "$OUTDIR_ABS"/*.out "$OUTDIR_ABS"/*.toc "$OUTDIR_ABS"/*.nav "$OUTDIR_ABS"/*.snm "$OUTDIR_ABS"/*.vrb
echo "✓ Cleanup complete."