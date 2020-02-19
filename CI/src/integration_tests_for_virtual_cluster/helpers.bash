#! /bin/echo This file is meant to be sourced

generate_slurm_conf() {
    slurm_conf_file=$1; shift
    controller=$1; shift
    servers=( "$@" )

    cat << EOF > $slurm_conf_file
#
# Example slurm.conf file. Please run configurator.html
# (in doc/html) to build a configuration file customized
# for your environment.
#
#
# slurm.conf file generated by configurator.html.
#
# See the slurm.conf man page for more information.
#
ClusterName=virtual-cluster
ControlMachine=$controller
SlurmUser=slurm
SlurmctldPort=6817
SlurmdPort=6818
StateSaveLocation=/var/lib/slurm-llnl
SlurmdSpoolDir=/tmp/slurmd
SwitchType=switch/none
MpiDefault=none
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
ProctrackType=proctrack/pgid
CacheGroups=0
ReturnToService=0
SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0
SchedulerType=sched/backfill
SelectType=select/linear
FastSchedule=1
# LOGGING
SlurmctldDebug=3
SlurmdDebug=3
JobCompType=jobcomp/none
EOF

    echo "# COMPUTE NODES" >> $slurm_conf_file
    for server in "${servers[@]}"; do
    echo "Nodename=$server" >> $slurm_conf_file
    done

    partition_nodes=
    for server in "${servers[@]}"; do
        if [ ! -z "$partition_nodes" ]; then
            partition_nodes=$partition_nodes,
        fi
        partition_nodes=$partition_nodes$server
    done
    echo "PartitionName=debug Nodes=$partition_nodes Default=YES MaxTime=INFINITE State=UP" >> $slurm_conf_file

    cat << EOF >> $slurm_conf_file
GresTypes=gpu
# settings required by SLURM plugin
PrologFlags=Alloc,Contain
EOF
}