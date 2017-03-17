#!/bin/bash
#find $* | xargs touch
find $* -exec touch {} \;
