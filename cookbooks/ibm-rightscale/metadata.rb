name             'ibm-rightscale'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures ibm-rightscale'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
recipe "ibm-rightscale::helloworld", "My first recipe, prints Hello World to the RightScale dashboard"