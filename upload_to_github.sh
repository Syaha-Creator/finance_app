#!/bin/bash

echo "🚀 Finance App - GitHub Upload Helper"
echo "======================================"
echo ""

# Check if git remote is already set
if git remote get-url origin >/dev/null 2>&1; then
    echo "✅ Git remote origin already set to:"
    git remote get-url origin
    echo ""
    echo "📤 Pushing to GitHub..."
    git push -u origin main
else
    echo "❌ Git remote origin not set yet."
    echo ""
    echo "📋 Please follow these steps:"
    echo "1. Go to https://github.com and create a new repository named 'finance_app'"
    echo "2. Copy the repository URL (e.g., https://github.com/username/finance_app.git)"
    echo "3. Run this command with your repository URL:"
    echo "   git remote add origin YOUR_REPOSITORY_URL"
    echo "4. Then run this script again"
    echo ""
    echo "🔗 Example:"
    echo "   git remote add origin https://github.com/yourusername/finance_app.git"
    echo ""
fi

echo ""
echo "📊 Current git status:"
git status --short

echo ""
echo "📝 Recent commits:"
git log --oneline -5
