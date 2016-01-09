#!/bin/bash

liccmd='/nopt/nrel/admin/bin/lmutil lmstat -c 1999@wind-lic.nrel.gov'

licenses_available()
{
    licStr=`$liccmd -f $1 | grep "Users of $1"`
    echo $licStr | awk '{print $6 - $11}'
}
