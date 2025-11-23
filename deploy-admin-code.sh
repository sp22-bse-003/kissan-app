#!/bin/bash

# Deployment Script for Kissan Admin Portal CRUD Features
# This script will copy all the necessary code to your admin portal

set -e  # Exit on error

ADMIN_DIR="/Users/ammarhamza/Documents/flutter dev/Code/kissan-admin"
WORKSPACE_DIR="/Users/ammarhamza/Documents/flutter dev/Code/kissan"

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                            ║"
echo "║           🚀 Kissan Admin Portal - Code Deployment                         ║"
echo "║                                                                            ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if admin portal directory exists
if [ ! -d "$ADMIN_DIR" ]; then
    echo "❌ Error: Admin portal directory not found at: $ADMIN_DIR"
    exit 1
fi

echo "✓ Admin portal directory found"
echo ""

# Navigate to workspace directory
cd "$WORKSPACE_DIR"

echo "📋 This script will:"
echo "  1. Show you the code from ADMIN_PORTAL_UPDATES.md"
echo "  2. Guide you through copying it to the admin portal"
echo ""
echo "Press Enter to continue..."
read

# Check if documentation exists
if [ ! -f "ADMIN_PORTAL_UPDATES.md" ]; then
    echo "❌ Error: ADMIN_PORTAL_UPDATES.md not found!"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Step 1: Open Documentation in VS Code"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Opening ADMIN_PORTAL_UPDATES.md in VS Code..."
code "ADMIN_PORTAL_UPDATES.md"
sleep 2

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Step 2: Copy Products.jsx Code"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Instructions:"
echo "  1. In VS Code, scroll to section '## 1. Products.jsx'"
echo "  2. Copy ALL the code between the jsx markers"
echo "  3. Open: $ADMIN_DIR/src/pages/Products.jsx"
echo "  4. Replace ENTIRE file content with copied code"
echo ""
echo "Current Products.jsx location:"
echo "  $ADMIN_DIR/src/pages/Products.jsx"
echo ""
echo "Press Enter when you've copied Products.jsx..."
read

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Step 3: Create Products.css"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Instructions:"
echo "  1. In ADMIN_PORTAL_UPDATES.md, scroll to '## 2. Products.css'"
echo "  2. Copy ALL the CSS code"
echo "  3. Create NEW file: $ADMIN_DIR/src/pages/Products.css"
echo "  4. Paste the CSS code"
echo ""
echo "Press Enter when you've created Products.css..."
read

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Step 4: Create KnowledgeHub.jsx"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Instructions:"
echo "  1. In ADMIN_PORTAL_UPDATES.md, scroll to '## 3. KnowledgeHub.jsx'"
echo "  2. Copy ALL the JSX code"
echo "  3. Create NEW file: $ADMIN_DIR/src/pages/KnowledgeHub.jsx"
echo "  4. Paste the code"
echo ""
echo "Press Enter when you've created KnowledgeHub.jsx..."
read

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Step 5: Create KnowledgeHub.css"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Instructions:"
echo "  1. In ADMIN_PORTAL_UPDATES.md, scroll to '## 4. KnowledgeHub.css'"
echo "  2. Copy ALL the CSS code"
echo "  3. Create NEW file: $ADMIN_DIR/src/pages/KnowledgeHub.css"
echo "  4. Paste the CSS code"
echo ""
echo "Press Enter when you've created KnowledgeHub.css..."
read

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Step 6: Update App.jsx"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Opening App.jsx..."
code "$ADMIN_DIR/src/App.jsx"
sleep 1

echo ""
echo "Instructions:"
echo "  1. Find the imports section at the top"
echo "  2. ADD this line with other page imports:"
echo ""
echo "     import KnowledgeHub from './pages/KnowledgeHub';"
echo ""
echo "  3. Find the <Routes> section"
echo "  4. ADD this route after the products route:"
echo ""
echo "     <Route path=\"/knowledge-hub\" element={<KnowledgeHub />} />"
echo ""
echo "Press Enter when you've updated App.jsx..."
read

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Step 7: Update Layout.jsx"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Opening Layout.jsx..."
code "$ADMIN_DIR/src/components/Layout.jsx"
sleep 1

echo ""
echo "Instructions:"
echo "  1. Find the lucide-react import"
echo "  2. ADD 'BookOpen' to the imports:"
echo ""
echo "     import { ..., BookOpen } from 'lucide-react';"
echo ""
echo "  3. Find the menuItems array"
echo "  4. ADD this navigation item after products:"
echo ""
echo "     {"
echo "       path: '/knowledge-hub',"
echo "       icon: BookOpen,"
echo "       label: 'Knowledge Hub'"
echo "     },"
echo ""
echo "Press Enter when you've updated Layout.jsx..."
read

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Step 8: Start Dev Server"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Starting the development server..."
echo ""

cd "$ADMIN_DIR"

# Kill any existing processes on port 3000
lsof -ti:3000 | xargs kill -9 2>/dev/null || true

echo "Starting npm run dev..."
echo ""
echo "The admin portal will open at http://localhost:3000"
echo ""
echo "✅ Deployment complete!"
echo ""
echo "Test checklist:"
echo "  [ ] Products page shows grid (not placeholder)"
echo "  [ ] Can add new product"
echo "  [ ] Can edit product"
echo "  [ ] Can delete product"
echo "  [ ] Knowledge Hub menu item visible"
echo "  [ ] Knowledge Hub page works"
echo ""
echo "Starting server now..."
npm run dev
