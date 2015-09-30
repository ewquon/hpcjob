jecho()
{
    #echo "Job manager: $*" | tee -a job.log
    if [ -n "$1" ]; then echo "Job manager: $*"; fi
    echo "$*" >> jerb.log
}

jexec()
{
    if [ "$dryrun" = true ]; then
        echo "Job manager: DRYRUN $1"
    else
        $*
    fi
}

job_init()
{
    jecho ''
    jecho '-----------------------------------------------'
    if [ -f "current_stage" ]; then
        export currstage=`cat current_stage`
        jecho "Continuing from stage $currstage"
    else
        jecho "Starting new job"
        export currstage=1
        echo 1 > current_stage
    fi

    if [ -n "$PBS_NODEFILE" ]; then
        export nprocs=`cat $PBS_NODEFILE | wc -l`
    else
        export nprocs=1
    fi
}

job_setup()
{
    jecho "Copying default settings files"
    cp -v config/default/* system/

    solver=${stage[$currstage]}
    jecho "Copying $solver settings files"
    if [ -d "config/$solver" ]; then
        cp -v config/$solver/* system/
        export app=`getApp`
        if [ "$app" != "$solver" ]; then
            jecho "WARNING mismatched solver $app in config/$solver?"
        fi
    else
        jecho "WARNING config/$solver directory not found! Attempting to proceed anyway..."
        export app=$solver
    fi

    if [ "$currstage" -eq 1 ]; then
        cp -rv CLEAN_START/0 .
        if [ "$nprocs" -gt 1 ]; then #parallel
            jecho "Decomposing mesh and transferring fields"
            jexec decomposePar -ifRequired &> decomposePar.out
        fi

    else # restart
        prevstage=$((currstage-1))
        prevdir="stage$prevstage"
        if [ ! -d "$prevdir" ]; then
            jecho "Previous stage $prevstage not found!"
        else
            jecho "Restarting from $prevdir"
            echo "startFrom0 = $startFrom0"

            if [ "$nprocs" -gt 1 ]; then #parallel restart
                latest=`foamLatestTime.py $prevdir/processor0`
                if [ "$startFrom0" = true ]; then
                    jecho "Starting stage $currstage in parallel from time t=0"
                    for i in `seq 0 $((nprocs-1))`; do
                        mkdir -p processor$i
                        if [ -d "processor$i/0" ]; then
                            jecho "WARNING processor$i/0 already exists!?"
                            rm -rv processor$i/0
                        fi
                        cp -rv $prevdir/processor$i/$latest processor$i/0
                        rm -fv processor$i/0/uniform/time
                    done
                else # false (undefined by default)
                    for i in `seq 0 $((nprocs-1))`; do
                        mkdir -p processor$i
                        cp -rv $prevdir/processor$i/$latest processor$i/
                    done
                fi 
                jecho "Latest time from processor0 is $latest"

            else #serial restart
                latest=`foamLatestTime.py $prevdir`
                if [ "$startFrom0" = true ]; then
                    jecho "Starting stage $currstage from time t=0"
                    if [ -d "0" ]; then
                        jecho "WARNING processor$i/0 already exists!?"
                        rm -rv 0
                    fi
                    cp -rv $prevdir/$latest 0
                    rm -fv 0/uniform/time
                else # false (undefined by default)
                    cp -rv $prevdir/$latest .
                fi 
                jecho "Latest time is $latest"
            fi
        fi
    fi
}

job_runstage()
{
    if [ -n "$1" ]; then export currstage=$1; fi
    if [ -d "stage$currstage" ]; then
        jecho "Stage $currstage directory already exists! Remove to continue..."
        return
    fi

    jecho ''
    jecho "STAGE $currstage STARTED at `date`"
    jecho "Setting up ${stage[$currstage]}"
    job_setup #sets $app


    if [ -f "$app.out" ]; then 
        lastTimestep=`grep "Time =" $app.out | grep -v "Exec" | tail -n 1 | awk '{print $3}'`
        if [ -n "$lastTimestep" ]; then
            cp -v $app.out ${app}_${lastTimestep}.out
        else
            cp -v $app.out $app.out_last
        fi
    fi

    if [ "$nprocs" -gt 1 ]; then
        jecho "Running $app in parallel mode"
        jexec mpirun -np $nprocs $app -parallel 2>&1 | tee $app.out
        if [ "$dryrun" == true ]; then echo "Finalising parallel run" >> $app.out; fi
    else
        jecho "Running $app in serial mode"
        jexec $app 2>&1 | tee $app.out
        if [ "$dryrun" == true ]; then echo "End" >> $app.out; fi
    fi

    job_post #saves files, update currstage
}

job_post()
{
    if [ "$nprocs" -gt 1 ]; then #parallel
        jecho "Reconstructing latest time `foamLatestTime.py processor0`"
        jexec reconstructPar -latestTime &> reconstructPar.out
    fi

    jecho "Saving files for stage $currstage"
    lastline=`tail -n 1 $app.out`
    if [[ "$lastline" == "End" || "$lastline" == "Finalising parallel run" ]]; then
        savedir="stage$currstage"
        mkdir -p $savedir
        (cd $savedir && ln -sf ../constant)

        cp -rv system $savedir/
        for f in $app*.out*; do mv -v $f $savedir/; done
        for f in "`foamOutputDirs.py`"; do mv -v $f $savedir/; done
        if [ -d "postProcessing" ]; then mv -v postProcessing $savedir/; fi
        for f in ${savefiles[currstage]}; do
            if [ -f "$f" ]; then cp -frv $f $savedir/; fi
        done

        if [ "$nprocs" -gt 1 ]; then #parallel
            jecho "Saving processor directories for stage $currstage"
            for i in `seq 0 $((nprocs-1))`; do
                mkdir -p $savedir/processor$i
                mv -v processor$i/*[0-9]* $savedir/processor$i/
                for f in ${savefiles[currstage]}; do
                    if [ -f "processor$i/$f" ]; then cp -rv processor$i/$f $savedir/processor$i/; fi
                done
            done
        fi

        currstage=$((currstage+1))
        
    else
        jecho "WARNING Job crashed???"
        exit
    fi
}

