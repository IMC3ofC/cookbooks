name             'ibm-rightscale'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures ibm-rightscale'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "rightscale"

# My recipes
recipe "ibm-rightscale::install_db2_express_c", "Install DB2 Express-C 10.5"
recipe "ibm-rightscale::start_db2",                       "Start DB2"
recipe "ibm-rightscale::stop_db2",                        "Stop DB2"
recipe "ibm-rightscale::start_db2_administration_server", "Start DB2 Administration Server"
recipe "ibm-rightscale::stop_db2_administration_server",  "Stop DB2 Administration Server"
recipe "ibm-rightscale::create_database",                 "Create DB2 Database"
recipe "ibm-rightscale::backup_database",                 "Backup DB2 Database"
#recipe "ibm-rightscale::restore_database",                 "Restore DB2 Database"

#
# My Attributes
#

### INPUTS FOR INSTANCE OWNER

attribute "db2/instance/username",
   :display_name => "DB2 Instance owner username",
   :description => "Username for the DB2 instance owner.",
   :required => "recommended",
   :default => "db2inst1",
   :recipes => ["ibm-rightscale::install_db2_express_c", "ibm-rightscale::start_db2", "ibm-rightscale::stop_db2", "ibm-rightscale::start_db2_administration_server", "ibm-rightscale::stop_db2_administration_server", "ibm-rightscale::create_database", "ibm-rightscale::backup_database"]

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

   
### INPUTS FOR DB2
 
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

attribute "db2/force",
   :display_name => "Force",
   :description => "Would you like to force the DB2 Command?",
   :required => "recommended",
   :choice => ["yes", "no"],
   :default => "no",
   :recipes => ["ibm-rightscale::stop_db2"]

attribute "db2/database/name",
   :display_name => "Database name",
   :description => "The name of the DB2 Database.",
   :required => "required",
   :type => "string",
   :recipes => ["ibm-rightscale::create_database", "ibm-rightscale::backup_database"]

attribute "db2/database/options",
   :display_name => "DB2 Database Options",
   :description => "The options for the DB2 Database.",
   :required => "optional",
   :recipes => ["ibm-rightscale::create_database", "ibm-rightscale::backup_database"]

   
## INPUTS FOR DOWNLOAD API

attribute "api/key",
   :display_name => "API Key for Download API",
   :description => "The API Key to use for the Download API.",
   :required => "optional",
   :default => "643a4018ad2c16314ad4ddf6aecfbd4bd34be3bd95ccfe146d1b9be214e406aa",
   :recipes => ["ibm-rightscale::install_db2_express_c"]

attribute "api/url",
   :display_name => "API End-point URL for Download API",
   :description => "The End-point URL to use for the Download API.",
   :required => "optional",
   :default => "https://my.imdemocloud.com:443/api",
   :recipes => ["ibm-rightscale::install_db2_express_c"]


### INPUTS FOR BACKUP

attribute "backup/save_to_cloud",
   :display_name => "Save to Cloud",
   :description => "Would you like to save the backup to the Cloud?",
   :required => "recommended",
   :choice => ["yes", "no"],
   :default => "no",
   :recipes => ["ibm-rightscale::backup_database"]

attribute "backup/bucket",
   :display_name => "Backup Bucket",
   :description => "What bucket would you like to use for the Backup?",
   :required => "recommended",
   :type => "string",
   :recipes => ["ibm-rightscale::backup_database"]

attribute "backup/path",
   :display_name => "Backup Path",
   :description => "What path would you like to use for the Backup?",
   :required => "recommended",
   :type => "string",
   :recipes => ["ibm-rightscale::backup_database"]
   
attribute "backup/cloud/name",
   :display_name => "Cloud Name",
   :description => "Which cloud do you want to backup to?",
   :required => "recommended",
   :choice => ["s3", "softlayer"],
   :default => "s3",
   :recipes => ["ibm-rightscale::backup_database"]

attribute "backup/cloud/key",
   :display_name => "Cloud Key",
   :description => "What is your cloud key?",
   :required => "recommended",
   :default => "CRED:AWS_ACCESS_KEY_ID",
   :recipes => ["ibm-rightscale::backup_database"]
   
attribute "backup/cloud/secret",
   :display_name => "Cloud Secret",
   :description => "What is your cloud secret?",
   :required => "recommended",
   :default => "CRED:AWS_SECRET_ACCESS_KEY",
   :recipes => ["ibm-rightscale::backup_database"]
