name             'ibm-rightscale'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures ibm-rightscale'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "rightscale"

# My recipes
recipe "ibm-rightscale::helloworld", "My first recipe, prints Hello World to the RightScale dashboard"

recipe "ibm-rightscale::install_db2_express_c", "Install DB2 Express-C 10.5"

# My Attributes

### INPUTS FOR INSTANCE OWNER

attribute "db2/instance/username",
   :display_name => "DB2 Instance owner username",
   :description => "Username for the DB2 instance owner.",
   :required => "recommended",
   :default => "db2inst1",
   :recipes => ["ibm-rightscale::install_db2_express_c"]

attribute "db2/instance/password",
   :display_name => "DB2 Instance owner password",
   :description => "Password for the DB2 instance owner.",
   :required => "recommended",
   :default => "passw0rd",
   :recipes => ["ibm-rightscale::install_db2_express_c"]
   
attribute "db2/instance/group",
   :display_name => "DB2 Instance owner group",
   :description => "Primary Group for the DB2 instance owner.",
   :required => "recommended",
   :default => "db2iadm1",
   :recipes => ["ibm-rightscale::install_db2_express_c"]

   
### INPUTS FOR DAS USER
   
attribute "db2/das/username",
   :display_name => "DB2 das owner username",
   :description => "Username for the DB2 das owner.",
   :required => "recommended",
   :default => "dasusr1",
   :recipes => ["ibm-rightscale::install_db2_express_c"]

attribute "db2/das/password",
   :display_name => "DB2 das owner password",
   :description => "Password for the DB2 das owner.",
   :required => "recommended",
   :default => "passw0rd",
   :recipes => ["ibm-rightscale::install_db2_express_c"]
   
attribute "db2/das/group",
   :display_name => "DB2 das owner group",
   :description => "Primary Group for the DB2 das owner.",
   :required => "recommended",
   :default => "dasadm1",
   :recipes => ["ibm-rightscale::install_db2_express_c"]


### INPUTS FOR FENCED USER
   
attribute "db2/fenced/username",
   :display_name => "DB2 Fenced owner username",
   :description => "Username for the DB2 fenced owner.",
   :required => "recommended",
   :default => "db2fenc1",
   :recipes => ["ibm-rightscale::install_db2_express_c"]

attribute "db2/fenced/password",
   :display_name => "DB2 Fenced owner password",
   :description => "Password for the DB2 fenced owner.",
   :required => "recommended",
   :default => "passw0rd",
   :recipes => ["ibm-rightscale::install_db2_express_c"]
   
attribute "db2/fenced/group",
   :display_name => "DB2 Fenced owner group",
   :description => "Primary Group for the DB2 fenced owner.",
   :required => "recommended",
   :default => "db2fadm1",
   :recipes => ["ibm-rightscale::install_db2_express_c"]

   
 ## INPUTS FOR DB2 SYSTEM
 
 attribute "db2/data_path",
   :display_name => "DB2 Data Directory",
   :description => "The location on disk where the DB2 Data Directory will be installed.",
   :required => "recommended",
   :default => "/mnt/database",
   :recipes => ["ibm-rightscale::install_db2_express_c"]
   
attribute "db2/system",
   :display_name => "DB2 System name",
   :description => "The name of the DB2 system.",
   :required => "recommended",
   :default => "DB2onRS",
   :recipes => ["ibm-rightscale::install_db2_express_c"]
