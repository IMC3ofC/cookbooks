# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions

# The following three lines have been added by UDB DB2.
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi


export CLASSPATH=$CLASSPATH:/home/db2inst1/sqllib/json/lib/
export PATH=$PATH:/home/db2inst1/sqllib/json/bin/
