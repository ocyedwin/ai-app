#!/bin/bash

echo "Setting up SSH key..."
op read 'op://Developer/Rails/KAMAL_SSH_KEY' > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
