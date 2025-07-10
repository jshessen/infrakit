#!/bin/bash

# GPG Setup Script for InfraKit
# This script configures GPG for proper signing in terminals and VS Code

echo "🔐 Setting up GPG for commit signing..."

# Set GPG environment variables
export GPG_TTY=$(tty)
export GNUPGHOME="/var/services/homes/jshessen/.gnupg"

# Ensure GPG agent is running with correct config
echo "📋 Restarting GPG agent..."
/volume1/@appstore/gnupg/bin/gpgconf --kill gpg-agent
sleep 1

# Test GPG functionality
echo "🧪 Testing GPG signing..."
if echo "test" | /volume1/@appstore/gnupg/bin/gpg --clearsign --batch --yes --passphrase-fd 0 >/dev/null 2>&1; then
    echo "✅ GPG signing test successful (with passphrase)"
else
    echo "ℹ️  GPG requires interactive passphrase entry"
fi

# Display current GPG configuration
echo ""
echo "📊 Current GPG Configuration:"
echo "GPG Program: /volume1/@appstore/gnupg/bin/gpg"
echo "GPG Home: $GNUPGHOME"
echo "GPG TTY: $GPG_TTY"
echo "Pinentry: /volume1/@appstore/gnupg/bin/pinentry-curses"

echo ""
echo "🔑 Available GPG Keys:"
/volume1/@appstore/gnupg/bin/gpg --list-secret-keys --keyid-format SHORT

echo ""
echo "✅ GPG setup complete!"
echo ""
echo "📝 To sign commits manually:"
echo "  export GPG_TTY=\$(tty)"
echo "  git commit -S -m \"Your commit message\""
echo ""
echo "🎯 VS Code should now be able to sign commits automatically."
echo "   Make sure to enter your GPG passphrase when prompted."
