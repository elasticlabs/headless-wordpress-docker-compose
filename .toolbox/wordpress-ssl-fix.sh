#!/bin/bash
#
# This script fixes an issue with WP CLI which introduces a SSL mess while setting up wordpress

/scripts/message.sh warning "...... [UNSTABLE] Fix WP CLI messing with SSL management in wp-config-php..."

# Keep wp-config.php config
sed -i '1,/table_prefix/!d ' wp-config.php

# Add end SSL specific configs from wp-config.old.php
number=$(sed -n  '\|table_prefix|=' wp-config.old.php)
sed '/table_prefix/,$!d ' wp-config.old.php | grep -v table_prefix >> wp-config.php