#!/bin/bash

# Icon Converter Script for Flutter Projects
# Automatically converts a high-res icon for all platform variations
# Usage: ./icon_converter.sh [input_icon.png]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "'${GREEN}[INFO]'${NC} $1"
}

print_warning() {
    echo -e "'${YELLOW}[WARNING]'${NC} $1"
}

print_error() {
    echo -e "'${RED}[ERROR]'${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [input_icon.png]"
    echo "Converts a high-resolution icon to all required sizes for Flutter app"
    echo ""
    echo "Requirements:"
    echo "  - Input icon should be at least 1024x1024 pixels (preferably 1024x1024)"
    echo "  - ImageMagick must be installed (convert/magick command)"
    echo ""
    echo "This script will generate icons for:"
    echo "  - Android (mipmap directories)"
    echo "  - iOS (AppIcon.appiconset)"
    echo "  - Web (icons directory)"
    echo "  - macOS (AppIcon.appiconset)"
    echo "  - Windows (if needed)"
}
# Check if input file is provided
if [ $# -eq 0 ]; then
    print_error "No input icon file provided!"
    show_usage
    exit 1
fi

INPUT_ICON="$1"

# Check if input file exists
if [ ! -f "$INPUT_ICON" ]; then
    print_error "Input file does not exist: $INPUT_ICON"
    exit 1
fi

# Check if ImageMagick is available
if ! command -v convert &> /dev/null && ! command -v magick &> /dev/null; then
    print_error "ImageMagick is required but not installed."
    print_error "Please install ImageMagick to use this script."
    exit 1
fi

print_status "Starting icon conversion process..."
print_status "Input icon: $INPUT_ICON"

# Find project root (directory with pubspec.yaml)
PROJECT_ROOT=$(pwd)
while [ "$PROJECT_ROOT" != "/" ]; do
    if [ -f "$PROJECT_ROOT/pubspec.yaml" ]; then
        break
    fi
    PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
    print_error "Could not find Flutter project root (pubspec.yaml)"
    exit 1
fi

print_status "Project root found: $PROJECT_ROOT"

# Android icon sizes
# Reference: https://developer.android.com/develop/ui/views/launch#icon-specs
ANDROID_SIZES=(
    "mipmap-mdpi:48x48"
    "mipmap-hdpi:72x72" 
    "mipmap-xhdpi:96x96"
    "mipmap-xxhdpi:144x144"
    "mipmap-xxxhdpi:192x192"
)
# iOS App Icon sizes
# Reference: https://developer.apple.com/design/human-interface-guidelines/app-icons
IOS_SIZES=(
    "20x20@1x:20x20"
    "20x20@2x:40x40"
    "20x20@3x:60x60"
    "29x29@1x:29x29"
    "29x29@2x:58x58"
    "29x29@3x:87x87"
    "40x40@1x:40x40"
    "40x40@2x:80x80"
    "40x40@3x:120x120"
    "60x60@2x:120x120"
    "60x60@3x:180x180"
    "76x76@1x:76x76"
    "76x76@2x:152x152"
    "83.5x83.5@2x:167x167"
    "1024x1024@1x:1024x1024"
)

# Web icon sizes
WEB_SIZES=(
    "192x192:192x192"
    "512x512:512x512"
)

# macOS icon sizes
MACOS_SIZES=(
    "16x16:16x16"
    "32x32:32x32"
    "64x64:64x64"
    "128x128:128x128"
    "256x256:256x256"
    "512x512:512x512"
    "1024x1024:1024x1024"
)

# Windows icon sizes
WINDOWS_SIZES=(
    "48x48:48x48"
    "1024x1024:1024x1024"
)

# Function to create directory if it doesn't exist
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_status "Created directory: $1"
    fi
}

# Function to convert image using ImageMagick
convert_icon() {
    local input="$1"
    local output="$2"
    local size="$3"
    
    # Use magick if available, otherwise use convert
    if command -v magick &> /dev/null; then
        magick "$input" -resize "$size^" -gravity center -extent "$size" "$output"
    else
        convert "$input" -resize "$size^" -gravity center -extent "$size" "$output"
    fi
    
    if [ $? -eq 0 ]; then
        print_status "Created: $output ($size)"
    else
        print_error "Failed to create: $output"
    fi
}

# Android adaptive icon sizes
# Adaptive icons have 108x108dp size with 16dp margin (3.6x for safe zone)
# Foreground and background layers should be 108x108dp but safe content area is 72x72dp (safe zone)
ANDROID_ADAPTIVE_SIZES=(
    "mipmap-mdpi:48x48"
    "mipmap-hdpi:72x72" 
    "mipmap-xhdpi:96x96"
    "mipmap-xxhdpi:144x144"
    "mipmap-xxxhdpi:192x192"
)

# Process Android icons (including adaptive)
process_android_icons() {
    local android_dir="$PROJECT_ROOT/android/app/src/main/res"
    
    for size_entry in "${ANDROID_SIZES[@]}"; do
        local density="${size_entry%%:*}"
        local size="${size_entry#*:}"
        
        local output_dir="$android_dir/$density"
        create_dir "$output_dir"
        local output_file="$output_dir/ic_launcher.png"
        
        convert_icon "$INPUT_ICON" "$output_file" "$size"
    done
    
    # Generate adaptive icons
    print_status "Creating Android adaptive icons..."
    local adaptive_dir="$android_dir/mipmap-anydpi-v26"
    create_dir "$adaptive_dir"
    
    # Create adaptive icon XML
    local xml_content='<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>'
    
    local xml_file="$adaptive_dir/ic_launcher.xml"
    echo "$xml_content" > "$xml_file"
    print_status "Created adaptive icon XML: $xml_file"
    
    # Create drawable directories for foreground and background
    local drawable_dir="$android_dir/drawable-v24"
    create_dir "$drawable_dir"
    
    # Create background layer - using a simple solid color or modified version of input
    local background_file="$drawable_dir/ic_launcher_background.png"
    # For the background, we'll create a solid color based on the dominant color of the input icon or white
    if command -v magick &> /dev/null; then
        # Create a white background with the same dimensions as the input
        magick "$INPUT_ICON" -resize 108x108^ -gravity center -extent 108x108 -background white -alpha remove -alpha off "$background_file"
    else
        # Alternative using convert with a white background
        convert "$INPUT_ICON" -resize 108x108^ -gravity center -extent 108x108 -background white -alpha remove "$background_file"
    fi
    
    # Create foreground layer - the main icon content, properly sized to fit in the safe zone
    local foreground_file="$drawable_dir/ic_launcher_foreground.png"
    # For the foreground, resize the input to fit within the safe zone (typically 72x72 of a 108x108 canvas)
    if command -v magick &> /dev/null; then
        magick "$INPUT_ICON" -resize 72x72 -gravity center -extent 108x108 "$foreground_file"
    else
        convert "$INPUT_ICON" -resize 72x72 -gravity center -extent 108x108 "$foreground_file"
    fi
    
    # Also create the mipmap versions for each density for adaptive icons
    for size_entry in "${ANDROID_ADAPTIVE_SIZES[@]}"; do
        local density="${size_entry%%:*}"
        local size="${size_entry#*:}"
        
        local output_dir="$android_dir/$density"
        create_dir "$output_dir"
        local bg_output="$output_dir/ic_launcher_background.png"
        local fg_output="$output_dir/ic_launcher_foreground.png"
        
        # Calculate the corresponding sizes for background and foreground
        local bg_size="${size}"
        local fg_size_w=$(echo "$size" | cut -d'x' -f1)
        local fg_size_h=$(echo "$size" | cut -d'x' -f2)
        # Calculate foreground safe zone size (2/3 of total size to match 72x72 of 108x108)
        local fg_safe_w=$((fg_size_w * 2 / 3))
        local fg_safe_h=$((fg_size_h * 2 / 3))
        local fg_safe_size="${fg_safe_w}x${fg_safe_h}"
        
        if command -v magick &> /dev/null; then
            # Background
            magick "$INPUT_ICON" -resize "${bg_size}^" -gravity center -extent "${bg_size}" -background white -alpha remove -alpha off "$bg_output"
            # Foreground 
            magick "$INPUT_ICON" -resize "${fg_safe_size}" -gravity center -extent "${bg_size}" "$fg_output"
        else
            # Background
            convert "$INPUT_ICON" -resize "${bg_size}^" -gravity center -extent "${bg_size}" -background white -alpha remove "$bg_output"
            # Foreground
            convert "$INPUT_ICON" -resize "${fg_safe_size}" -gravity center -extent "${bg_size}" "$fg_output"
        fi
        
        if [ $? -eq 0 ]; then
            print_status "Created: $bg_output ($bg_size)"
            print_status "Created: $fg_output ($bg_size with $fg_safe_size foreground)"
        else
            print_error "Failed to create: $bg_output or $fg_output"
        fi
    done
}

# Process iOS icons
process_ios_icons() {
    local ios_dir="$PROJECT_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    create_dir "$ios_dir"
    
    # Create Contents.json for iOS
    local contents_json='{
  "images" : [
'
    
    for size_entry in "${IOS_SIZES[@]}"; do
        local name_size="${size_entry%%:*}"
        local size="${size_entry#*:}"
        
        # Parse the name_size to get dimensions and scale properly
        if [[ "$name_size" == *"@"* ]]; then
            local name="${name_size%@*}"
            local scale="${name_size#*@}"
        else
            # For entries like "1024x1024@1x:1024x1024", we already have the scale
            local name="${size}"
            local scale="1x"
        fi
        
        # Create proper filename by replacing 'x' with 'x' in size for filename
        local filename_size=$(echo "$size" | sed 's/x/xx/g')
        local output_file="$ios_dir/AppIcon${filename_size}.png"
        convert_icon "$INPUT_ICON" "$output_file" "$size"
        
        # Extract width and height for JSON
        local width="${size%x*}"
        local height="${size#*x}"
        
        # Determine scale number
        local scale_num
        if [[ "$name_size" == *"@2x"* ]] || [[ "$name_size" == *"@2x:"* ]]; then
            scale_num="2x"
        elif [[ "$name_size" == *"@3x"* ]] || [[ "$name_size" == *"@3x:"* ]]; then
            scale_num="3x"
        else
            scale_num="1x"
        fi
        
        # Determine idiom based on size
        local idiom="iphone"
        if [ "$width" -ge 76 ] && [ "$height" -ge 76 ]; then
            if [ "$width" -ge 1024 ] && [ "$height" -ge 1024 ]; then
                idiom="ios-marketing"  # For 1024x1024 marketing icon
            elif [ "$width" -ge 76 ]; then
                idiom="ipad"
            fi
        fi
        
        if [ "$width" -ge 20 ] && [ "$width" -lt 40 ]; then
            idiom="iphone"  # 20x20 sizes
        elif [ "$width" -ge 29 ] && [ "$width" -lt 60 ]; then
            idiom="iphone"  # 29x29 sizes
        elif [ "$width" -ge 40 ] && [ "$width" -lt 60 ]; then
            idiom="iphone"  # 40x40 sizes
        elif [ "$width" -ge 60 ] && [ "$width" -lt 76 ]; then
            idiom="iphone"  # 60x60 sizes
        elif [ "$width" -ge 76 ] && [ "$width" -lt 84 ]; then
            idiom="ipad"    # 76x76 sizes
        elif [ "$width" -ge 83 ] && [ "$width" -lt 84 ]; then
            idiom="ipad"    # 83.5x83.5 sizes
        elif [ "$width" -ge 1024 ]; then
            idiom="ios-marketing"  # 1024x1024 marketing icon
        fi
        
        contents_json="$contents_json    {
      \"size\" : \"${width}x${height}\",
      \"idiom\" : \"${idiom}\",
      \"filename\" : \"AppIcon${filename_size}.png\",
      \"scale\" : \"${scale_num}\"
    },"
    done
    
    # Close Contents.json
    contents_json="${contents_json%,}
  ],
  \"info\" : {
    \"version\" : 1,
    \"author\" : \"xcode\"
  }
"
    local contents_file="$ios_dir/Contents.json"
    echo "$contents_json" > "$contents_file"
    print_status "Created: $contents_file"
}

# Process Web icons
process_web_icons() {
    local web_dir="$PROJECT_ROOT/web/icons"
    create_dir "$web_dir"
    
    for size_entry in "${WEB_SIZES[@]}"; do
        local size="${size_entry%%:*}"
        local output_file="$web_dir/icon-$size.png"
        convert_icon "$INPUT_ICON" "$output_file" "$size"
    done
}

# Process macOS icons
process_macos_icons() {
    local macos_dir="$PROJECT_ROOT/macos/Runner/Assets.xcassets/AppIcon.appiconset"
    create_dir "$macos_dir"
    
    # Create Contents.json for macOS
    local contents_json='{
  "images" : [
'
    
    for size_entry in "${MACOS_SIZES[@]}"; do
        local size="${size_entry%%:*}"
        local output_file="$macos_dir/app_icon_$size.png"
        convert_icon "$INPUT_ICON" "$output_file" "$size"
        
        # Add to Contents.json
        local width="${size%x*}"
        local height="${size#*x}"
        contents_json="$contents_json    {
      \"size\" : \"${width}x${height}\",
      \"idiom\" : \"mac\",
      \"filename\" : \"app_icon_${size}.png\",
      \"scale\" : \"1x\"
    },"
        contents_json="$contents_json    {
      \"size\" : \"${width}x${height}\",
      \"idiom\" : \"mac\",
      \"filename\" : \"app_icon_${size}@2x.png\",
      \"scale\" : \"2x\"
    },"
    done
    
    # Close Contents.json
    contents_json="${contents_json%,}
  ],
  \"info\" : {
    \"version\" : 1,
    \"author\" : \"xcode\"
  }
"
    local contents_file="$macos_dir/Contents.json"
    echo "$contents_json" > "$contents_file"
    print_status "Created: $contents_file"
}

# Process Windows icons
process_windows_icons() {
    local windows_dir="$PROJECT_ROOT/windows/runner/resources"
    create_dir "$windows_dir"
    
    for size_entry in "${WINDOWS_SIZES[@]}"; do
        local size="${size_entry%%:*}"
        local output_file="$windows_dir/icon-$size.ico"
        
        # Handle the 1024x1024 size specially as it may be too large for ICO format
        if [ "$size" = "1024x1024" ]; then
            # Use a more reasonable size for ICO format
            local temp_size="256x256"
            local temp_file=$(mktemp --suffix=.png)
            
            # First resize the input to a reasonable size
            if command -v magick &> /dev/null; then
                magick "$INPUT_ICON" -resize "$temp_size" "$temp_file"
                # Then convert to ICO
                magick "$temp_file" "$output_file"
            else
                convert "$INPUT_ICON" -resize "$temp_size" "$temp_file"
                convert "$temp_file" "$output_file"
            fi
            
            # Clean up temp file
            rm "$temp_file"
        else
            # For other sizes, proceed normally
            if command -v magick &> /dev/null; then
                magick "$INPUT_ICON" -resize "$size" "$output_file"
            else
                convert "$INPUT_ICON" -resize "$size" "$output_file"
            fi
        fi
        
        if [ $? -eq 0 ]; then
            print_status "Created: $output_file ($size)"
        else
            print_error "Failed to create: $output_file"
        fi
    done
}

# Main execution
process_android_icons
process_ios_icons
process_web_icons
process_macos_icons
process_windows_icons

print_status "Icon conversion completed successfully!"
