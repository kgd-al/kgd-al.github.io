#!/bin/bash

echo "#>> First install ruby and dependencies"
echo sudo apt-get install ruby-full build-essential zlib1g-dev

echo "#>> Then prepare a gem installation direction"
echo <<EOF
echo '# Install Ruby Gems to ~/.gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/.gems"' >> ~/.bashrc
echo 'export PATH="$HOME/.gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
EOF

echo "Then install Jekyll and Bundler"
echo gem install jekyll bundler
echo bundle install
