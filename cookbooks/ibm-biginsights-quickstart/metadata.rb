name             'ibm-biginsights-quickstart'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures IBM BigInsights Quickstart'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

depends "rightscale"

# My recipes
recipe "ibm-biginsights-quickstart::default",  "Install BigInsights Quickstart"


#
# My Attributes
#


### INPUTS FOR BIG INSIGHTS

attribute "biginsights/console/use_ssl",
   :display_name => "Use SSL?",
   :description => "Should https be configured for the web console?.",
   :required => "recommended",
   :default => "YES",
   :choice => ["YES","NO"],
   :recipes => ["ibm-biginsights-quickstart::default"]
    
attribute "biginsights/biadmin/password",
   :display_name => "Big Insights password",
   :description => "Password for the Big Insights admin.",
   :required => "recommended",
   :default => "passw0rd",
   :recipes => ["ibm-biginsights-quickstart::default"]
     
attribute "biginsights/master_hostname",
   :display_name => "Big Insights master hostname",
   :description => "Hostname for the Big Insights master node.",
   :required => "recommended",
   :default => "localhost",
   :recipes => ["ibm-biginsights-quickstart::default"]     
     
attribute "biginsights/bi_directory_prefix",
   :display_name => "Big Insights directory prefix",
   :description => "Directory prefix for Big Insights installation location.",
   :required => "recommended",
   :default => "/",
   :recipes => ["ibm-biginsights-quickstart::default"]    
     
attribute "biginsights/hadoop_distribution",
   :display_name => "Big Insights Hadoop distribution",
   :description => "Hadoop distribution name for Big Insights.",
   :required => "recommended",
   :default => "Apache",
   :recipes => ["ibm-biginsights-quickstart::default"]    
     
attribute "biginsights/data_node_unique_hostnames",
   :display_name => "Big Insights data node hostnames",
   :description => "Hostnames for the Big Insights data nodes.",
   :required => "recommended",
   :type => "array",
   :default => ["localhost"],
   :recipes => ["ibm-biginsights-quickstart::default"]                
   

## INPUTS FOR DOWNLOAD API

attribute "api/key",
   :display_name => "API Key for Download API",
   :description => "The API Key to use for the Download API.",
   :required => "optional",
   :default => "643a4018ad2c16314ad4ddf6aecfbd4bd34be3bd95ccfe146d1b9be214e406aa",
   :recipes => ["ibm-biginsights-quickstart::default"]

attribute "api/url",
   :display_name => "API End-point URL for Download API",
   :description => "The End-point URL to use for the Download API.",
   :required => "optional",
   :default => "https://my.imdemocloud.com:443/api",
   :recipes => ["ibm-biginsights-quickstart::default"]
