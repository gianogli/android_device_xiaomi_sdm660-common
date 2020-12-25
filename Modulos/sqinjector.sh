#========================================
# SUPER乛Quantum Injector
# Developer : @AkiraSuper
#========================================
#!/system/bin/sh
# Disable sysctl.conf to prevent ROM interference #1
if [ -e /system/etc/sysctl.conf ]; then
  mount -o remount,rw /system;
  mv /system/etc/sysctl.conf /system/etc/sysctl.conf.bak;
  mount -o remount,ro /system;
fi;

# Filesystem tweaks for better system performance;
busybox mount -o remount,nosuid,nodev,noatime,nodiratime -t auto /;
busybox mount -o remount,nosuid,nodev,noatime,nodiratime -t auto /proc;
busybox mount -o remount,nosuid,nodev,noatime,nodiratime -t auto /sys;
busybox mount -o remount,nodev,noatime,nodiratime,barrier=0,noauto_da_alloc,discard -t auto /system;

# Disable / stop system logging (logd) daemon;
stop logd

# Doze setup services (experimental)
pm disable com.google.android.gms/.update.SystemUpdateActivity 
pm disable com.google.android.gms/.update.SystemUpdateService 
pm disable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver 
pm disable com.google.android.gms/.update.SystemUpdateService$Receiver 
pm disable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver 
pm disable com.google.android.gsf/.update.SystemUpdateActivity 
pm disable com.google.android.gsf/.update.SystemUpdatePanoActivity 
pm disable com.google.android.gsf/.update.SystemUpdateService 
pm disable com.google.android.gsf/.update.SystemUpdateService$Receiver 
pm disable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver
pm disable --user 0 com.google.android.gms/.phenotype.service.sync.PhenotypeConfigurator;
settings put secure location_providers_allowed ' ';
dumpsys deviceidle enable all;
dumpsys deviceidle enabled all;

#GMS Doze Test
# Stop certain services and restart it on boot (experimental)
if [ "$(busybox pidof com.qualcomm.qcrilmsgtunnel.QcrilMsgTunnelService | wc -l)" -eq "1" ]; then
	busybox kill $(busybox com.qualcomm.qcrilmsgtunnel.QcrilMsgTunnelService);
fi;
if [ "$(busybox pidof com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver | wc -l)" -eq "1" ]; then
	busybox kill $(busybox pidof com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver);
fi;
if [ "$(busybox pidof com.google.android.gms | wc -l)" -eq "1" ]; then
	busybox kill $(busybox pidof com.google.android.gms);
fi;
if [ "$(busybox pidof com.google.android.gms.unstable | wc -l)" -eq "1" ]; then
	busybox kill $(busybox pidof com.google.android.gms.unstable);
fi;
if [ "$(busybox pidof com.google.android.gms.persistent | wc -l)" -eq "1" ]; then
	busybox kill $(busybox pidof com.google.android.gms.persistent);
fi;
if [ "$(busybox pidof com.google.android.gms.wearable | wc -l)" -eq "1" ]; then
	busybox kill $(busybox pidof com.google.android.gms.wearable);
fi;
if [ "$(busybox pidof com.google.android.gms.backup.backupTransportService | wc -l)" -eq "1" ]; then
	busybox kill $(busybox pidof com.google.android.gms.backup.backupTransportService);
fi;
if [ "$(busybox pidof com.google.android.gms.lockbox.LockboxService | wc -l)" -eq "1" ]; then
	busybox kill $(busybox pidof com.google.android.gms.lockbox.LockboxService);
fi;
if [ "$(busybox pidof com.google.android.gms.auth.setup.devicesignals.LockScreenService | wc -l)" -eq "1" ]; then
	busybox kill $(busybox pidof com.google.android.gms.auth.setup.devicesignals.LockScreenService);
fi;

settings put global dropbox_max_files 1;
settings put global hide_carrier_network_settings 0;
settings put system anr_debugging_mechanism 0;
settings put global tether_dun_required 0;

# Disable Services 
for apk in $(pm list packages -3 | sed 's/package://g' | sort); do
 # analytics
 pm disable $apk/com.google.android.gms.analytics.AnalyticsService
 pm disable $apk/com.google.android.gms.analytics.CampaignTrackingService
 pm disable $apk/com.google.android.gms.measurement.AppMeasurementService
 pm disable $apk/com.google.android.gms.analytics.AnalyticsReceiver
 pm disable $apk/com.google.android.gms.analytics.CampaignTrackingReceiver
 pm disable $apk/com.google.android.gms.measurement.AppMeasurementInstallReferrerReceiver
 pm disable $apk/com.google.android.gms.measurement.AppMeasurementReceiver
 pm disable $apk/com.google.android.gms.measurement.AppMeasurementContentProvider
# ADS
 pm disable $apk/com.google.android.gms.ads.AdActivity
done 2>/dev/null

# Doze battery life profile;
settings delete global device_idle_constants;
settings put global device_idle_constants inactive_to=60000,sensing_to=0,locating_to=0,location_accuracy=2000,motion_inactive_to=0,idle_after_inactive_to=0,idle_pending_to=60000,max_idle_pending_to=120000,idle_pending_factor=2.0,idle_to=900000,max_idle_to=21600000,idle_factor=2.0,max_temp_app_whitelist_duration=60000,mms_temp_app_whitelist_duration=30000,sms_temp_app_whitelist_duration=20000,light_after_inactive_to=10000,light_pre_idle_to=60000,light_idle_to=180000,light_idle_factor=2.0,light_max_idle_to=900000,light_idle_maintenance_min_budget=30000,light_idle_maintenance_max_budget=60000;

echo "Doze Excecuted on $(date +"%d-%m-%Y %r" )" >> /storage/emulated/0/injector.log
echo "" >> /storage/emulated/0/injector.log

# CPU
stop perfd
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]; then
 cpu_governors=/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
fi
if [ -e /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies ]; then
 cpu_freq=/sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies
fi
if [ -e /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq ]; then
 cpu_max=/sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq
fi
if [ -e /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_min_freq ]; then
 cpu_min=/sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_min_freq
fi
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq ]; then
 setmin0=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq`
fi
if [ -e /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_min_freq ]; then
 setmin4=`cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_min_freq`
fi
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]; then
 setmax0=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
fi
if [ -e /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq ]; then
 setmax4=`cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq`
fi

for perm in /sys/devices/system/cpu/cpu*/cpufreq; do
  chmod 644 $perm/scaling_max_freq;
  chmod 644 $perm/scaling_min_freq;
  chmod 644 $perm/scaling_governor;
done;

for pol in /sys/devices/system/cpu/cpufreq/policy*; do
  chmod 644 $pol/scaling_max_freq;
  chmod 644 $pol/scaling_min_freq;
  chmod 644 $pol/scaling_governor;
done;

if grep 'interactive' $cpu_governors; then
    echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    chmod 0644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/*
    echo "198000 1401000:18000 1536000:78000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
    echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/fast_ramp_down
    echo "72" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
    echo "1536000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
    echo "78000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
    echo "18000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
    echo "20000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
    echo "-1" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
    echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    chmod 0644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/*
    echo "198000 1401000:18000 1536000:78000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
    echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/fast_ramp_down
    echo "72" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
    echo "1958400" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
    echo "78000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
    echo "18000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
    echo "20000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
    echo "-1" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
elif grep 'schedutil' $cpu_governors; then
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    chmod 0644 /sys/devices/system/cpu/cpu0/cpufreq/schedutil/*
    echo "38000" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    echo "1" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/iowait_boost_enable
    echo "10000" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    chmod 0644 /sys/devices/system/cpu/cpu4/cpufreq/schedutil/*
    echo "36000" > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us
    echo "1" > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/iowait_boost_enable
    echo "10000" > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us
fi
echo Y > /sys/module/msm_performance/parameters/cpu_oc

for otak in /sys/devices/system/cpu; do
  echo "$setmax0" > $otak/cpu0/cpufreq/scaling_max_freq;
  echo "$setmin0" > $otak/cpu0/cpufreq//scaling_min_freq;
  echo "$setmax0" > $otak/cpu4/cpufreq/scaling_max_freq;
  echo "$setmin0" > $otak/cpu4/cpufreq//scaling_min_freq;
done;

for polisi in /sys/devices/system/cpu/cpufreq; do
  echo "$setmax0" > $polisi/policy0/scaling_max_freq;
  echo "$setmin0" > $polisi/policy0/scaling_min_freq;
  echo "$setmax4" > $polisi/policy4/scaling_max_freq;
  echo "$setmin4" > $polisi/policy4/scaling_min_freq;
done;

echo "0:$setmax0 1:$setmax0 2:$setmax0 3:$setmax0 4:$setmax4 5:$setmax4 6:$setmax4 7:$setmax4" > /sys/module/msm_performance/parameters/cpu_max_freq
echo "0:setmin0 1:setmin0 2:setmin0 3:setmin0 4:setmin4 5:setmin4 6:setmin4 7:setmin4" > /sys/module/msm_performance/parameters/cpu_min_freq

echo "1804800" > /sys/module/cpu_input_boost/parameters/input_boost_freq_hp
echo "1536000" > /sys/module/cpu_input_boost/parameters/input_boost_freq_lp
for ext4block in $ext4blocks; do
  if [ -e "$ext4block/inode_readahead_blks" ]; then
    chmod 0644 $ext4block/inode_readahead_blks
    echo "64" > $ext4block/inode_readahead_blks
  fi
done
echo "deadline" > /sys/block/mmcblk0/queue/scheduler
echo "512" > /sys/block/mmcblk0/queue/read_ahead_kb
echo "0" > /sys/block/mmcblk0/queue/iostats
echo "0" > /sys/block/mmcblk0/queue/add_random
echo "2" > /sys/block/mmcblk0/queue/rq_affinity
echo "deadline" > /sys/block/mmcblk1/queue/scheduler
echo "512" > /sys/block/mmcblk1/queue/read_ahead_kb
echo "0" > /sys/block/mmcblk1/queue/iostats
echo "0" > /sys/block/mmcblk1/queue/add_random
echo "2" > /sys/block/mmcblk1/queue/rq_affinity
echo "5" > /sys/class/kgsl/kgsl-3d0/devfreq/polling_interval
echo "3" > /sys/class/kgsl/kgsl-3d0/devfreq/adrenoboost
echo "0" > /sys/class/kgsl/kgsl-3d0/throttling
echo "1" > /sys/class/kgsl/kgsl-3d0/force_clk_on
echo "1" > /sys/class/kgsl/kgsl-3d0/force_bus_on
echo "1" > /sys/class/kgsl/kgsl-3d0/force_rail_on
echo "1" > /sys/class/kgsl/kgsl-3d0/force_no_nap
echo "Y" > /sys/module/adreno_idler/parameters/adreno_idler_active
echo "15" > /sys/module/adreno_idler/parameters/adreno_idler_downdifferential
echo "25" > /sys/module/adreno_idler/parameters/adreno_idler_idlewait
echo "6000" > /sys/module/adreno_idler/parameters/adreno_idler_idleworkload
echo "256" > /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "256" > /sys/module/dsboost/parameters/input_boost_duration
echo "50" > /sys/module/dsboost/parameters/input_stune_boost
echo "50" > /sys/module/dsboost/parameters/sched_stune_boost
echo "256" > /sys/module/dsboost/parameters/cooldown_boost_duration
echo "10" > /sys/module/dsboost/parameters/cooldown_stune_boost
echo "256" > /sys/module/cpu_boost/parameters/input_boost_ms
echo "256" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "50" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "50" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "256" > /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "50" > /sys/module/cpu_input_boost/parameters/general_stune_boost
echo "1" > /sys/module/msm_performance/parameters/touchboost
echo "1" > /sys/power/pnpmgr/touch_boost
echo "45" > /dev/stune/schedtune.boost
echo "45" > /dev/stune/top-app/schedtune.boost
echo "50" > /dev/stune/top-app/schedtune.sched_boost
echo "1" > /dev/stune/top-app/schedtune.colocate
echo "1" > /dev/stune/top-app/schedtune.sched_boost_enabled
echo "1" > /dev/stune/top-app/schedtune.sched_boost_no_override
echo "1" > /dev/stune/foreground/schedtune.sched_boost_enabled
echo "1" > /dev/stune/background/schedtune.sched_boost_enabled
echo "1" > /dev/stune/schedtune.sched_boost_enabled
echo "0" > /dev/stune/top-app/schedtune.prefer_idle
echo "1024" > /proc/sys/kernel/random/read_wakeup_threshold
echo "2048" > /proc/sys/kernel/random/write_wakeup_threshold
echo "0" > /sys/module/msm_thermal/core_control/enabled
echo "Y" > /sys/module/sync/parameters/fsync_enabled
echo "5" > /proc/sys/fs/lease-break-time
echo "0" > /sys/kernel/dyn_fsync/Dyn_fsync_active
echo '0' > /sys/module/mmc_core/parameters/use_spi_crc
echo "1" > /proc/sys/kernel/sched_boost
echo "0" > /proc/sys/kernel/sched_child_runs_first
echo "0" > /proc/sys/kernel/timer_migration
echo "0" > /sys/module/workqueue/parameters/power_efficient
echo "0" > /sys/devices/system/cpu/sched_mc_power_savings
#echo "1" > /proc/sys/vm/drop_caches
setprop debug.hwui.renderer skiagl
echo "0,258,417,676,824,1000" > /sys/module/lowmemorykiller/parameters/adj
echo "6999,13998,20997,27996,34955,41994" > /sys/module/lowmemorykiller/parameters/minfree
echo "0" > /sys/module/lowmemorykiller/parameters/lmk_fast_run
echo "75" > /proc/sys/vm/swappiness
echo "6732" > /proc/sys/vm/min_free_kbytes
echo "21542" > /proc/sys/vm/extra_free_kbytes
echo "100" > /proc/sys/vm/vfs_cache_pressure
echo "250" > /proc/sys/vm/dirty_expire_centisecs
echo "800" > /proc/sys/vm/dirty_writeback_centisecs
echo "5" > /proc/sys/vm/dirty_background_ratio
echo "10" > /proc/sys/vm/dirty_ratio
#setprop ro.sys.fw.bg_apps_limit 34
#setprop ro.vendor.qti.sys.fw.bg_apps_limit 34
#setprop debug.egl.force_msaa 1
echo "performance" > /sys/class/devfreq/cc00000.qcom,vidc:venus_bus_ddr/governor
echo "performance" > /sys/class/devfreq/mmc0/governor
echo "performance" > /sys/class/devfreq/mmc1/governor
echo "performance" > /sys/class/devfreq/soc:devfreq_spdm_cpu/governor
echo "performance" > /sys/class/devfreq/soc:qcom,cpubw/governor
echo "performance" > /sys/class/devfreq/soc:qcom,gpubw/governor
echo "performance" > /sys/class/devfreq/soc:qcom,kgsl-busmon/governor
echo "performance" > /sys/class/devfreq/soc:qcom,memlat-cpu0/governor
echo "performance" > /sys/class/devfreq/soc:qcom,memlat-cpu4/governor
echo "performance" > /sys/class/devfreq/soc:qcom,mincpubw/governor

for perm in /sys/devices/system/cpu/cpu*/cpufreq; do
  chmod 444 $perm/scaling_max_freq;
  chmod 444 $perm/scaling_min_freq;
  chmod 444 $perm/scaling_governor;
done;

for pol in /sys/devices/system/cpu/cpufreq/policy*; do
  chmod 444 $pol/scaling_max_freq;
  chmod 444 $pol/scaling_min_freq;
  chmod 444 $pol/scaling_governor;
done;

# Tweak the kernel task scheduler for improved overall system performance and user interface responsivness during all kind of possible workload based scenarios;
if [ -e /sys/kernel/debug/sched_features ]; then
   echo "NO_GENTLE_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
   echo "NO_HRTICK" > /sys/kernel/debug/sched_features
   echo "NO_DOUBLE_TICK" > /sys/kernel/debug/sched_features
   echo "RT_RUNTIME_SHARE" > /sys/kernel/debug/sched_features
   echo "NEXT_BUDDY" > /sys/kernel/debug/sched_features
   echo "LAST_BUDDY" > /sys/kernel/debug/sched_features
   echo "TTWU_QUEUE" > /sys/kernel/debug/sched_features
   echo "UTIL_EST" > /sys/kernel/debug/sched_features
   echo "ARCH_CAPACITY" > /sys/kernel/debug/sched_features
   echo "ARCH_POWER" > /sys/kernel/debug/sched_features
fi;

if [ -e /sys/kernel/sched/gentle_fair_sleepers ]; then
   echo "0" > /sys/kernel/sched/gentle_fair_sleepers
fi;

if [ -e /sys/kernel/sched/arch_power ]; then
  echo "1" > /sys/kernel/sched/arch_power
fi

# Fix DeepSleep
scsi_disk=$(ls -d /sys/class/scsi_disk/*) 2>/dev/null
for i in $scsi_disk; do
 	Write "temporary none" $i/cache_type
 done

# A customized CPUSet profile
echo "3" > /dev/cpuset/background/cpus
echo "1,3" > /dev/cpuset/camera-daemon/cpus
echo "0-1" > /dev/cpuset/foreground/cpus
echo "2" > /dev/cpuset/kernel/cpus
echo "2-3" > /dev/cpuset/restricted/cpus
echo "2-3" > /dev/cpuset/system-background/cpus
echo "0-3" > /dev/cpuset/top-app/cpus

# A couple of minor kernel entropy tweaks & enhancements for a slight UI responsivness boost;
echo "192" > /proc/sys/kernel/random/read_wakeup_threshold
echo "90" > /proc/sys/kernel/random/urandom_min_reseed_secs
echo "1792" > /proc/sys/kernel/random/write_wakeup_threshold
echo "0" > /sys/module/lpm_levels/parameters/sleep_disabled

# Kernel based tweaks that reduces the amount of wasted CPU cycles to maximum and gives back a huge amount of needed performance to both the system and the user;
echo "0" > /proc/sys/kernel/compat-log
echo "0" > /proc/sys/kernel/panic
echo "0" > /proc/sys/kernel/panic_on_oops
echo "0" > /proc/sys/kernel/softlockup_panic
echo "0" > /proc/sys/kernel/perf_cpu_time_max_percent
echo "0" > /proc/sys/kernel/nmi_watchdog
echo "5" > /proc/sys/kernel/sched_walt_init_task_load_pct
echo "0" > /proc/sys/kernel/sched_tunable_scaling

# Fully disable kernel printk console log spamming directly for less amount of useless wakeups (reduces overhead);
echo "0 0 0 0" > /proc/sys/kernel/printk

# Increase how much CPU bandwidth (CPU time) realtime scheduling processes are given for slightly improved system stability and minimized chance of system freezes & lockups;
echo "955000" > /proc/sys/kernel/sched_rt_runtime_us

# Enable CFQ group idle mode for improved scheduling effectivness by merging the IO queues in a "unified group" instead of treating them as individual IO based queues;
for i in /sys/devices/virtual/block/*/queue/iosched; do
  echo "1" > $i/group_idle;
done;

# Disable CFQ low latency mode for overall increased IO based scheduling throughput and for better overall needed responsivness & performance from the system;
for i in /sys/devices/virtual/block/*/queue/iosched; do
  echo "0" > $i/low_latency;
done;

# Wide block based tuning for reduced lag and less possible amount of general IO scheduling based overhead
#for i in /sys/devices/virtual/block/*/queue; do
#  echo "0" > $i/add_random;
#  echo "0" > $i/discard_max_bytes;
#  echo "0" > $i/io_poll;
#  echo "0" > $i/iostats;
#  echo "0" > $i/nomerges;
#  echo "32" > $i/nr_requests;
#  echo "0" > $i/rotational;
#  echo "1" > $i/rq_affinity;
#done;
for g in /sys/block/*/queue;do
echo "0" > "${g}"/add_random;
echo "0" > "${g}"/iostats;
echo "2" > "${g}"/nomerges;
echo "0" > "${g}"/rotational;
echo "1" > "${g}"/rq_affinity;
echo "0" > "${g}"/iosched/slice_idle;
echo "0" > "${g}"/iosched/low_latency;
done;

if [ -d /dev/stune ];then
echo "-12" > /dev/stune/background/schedtune.boost;
STN=$($B cat /dev/stune/top-app/schedtune.boost);
echo "$((STN+1))" > /dev/stune/top-app/schedtune.boost
fi;

#1028 readahead KB for sde and sdf io scheds
echo "1028" > /sys/block/sde/queue/read_ahead_kb
echo "1028" > /sys/block/sdf/queue/read_ahead_kb

echo "Kernel Settings Excecuted on $(date +"%d-%m-%Y %r" )" >> /storage/emulated/0/injector.log
echo "" >> /storage/emulated/0/injector.log

# Turn off a few additional kernel debuggers and what not for gaining a slight boost in both performance and battery life;
echo "Y" > /sys/module/bluetooth/parameters/disable_ertm
echo "Y" > /sys/module/bluetooth/parameters/disable_esco
echo "0" > /sys/module/dwc3/parameters/ep_addr_rxdbg_mask
echo "0" > /sys/module/dwc3/parameters/ep_addr_txdbg_mask
echo "0" > /sys/module/dwc3_msm/parameters/disable_host_mode
echo "0" > /sys/module/hid_apple/parameters/fnmode
echo "0" > /sys/module/hid/parameters/ignore_special_drivers
echo "N" > /sys/module/hid_magicmouse/parameters/emulate_3button
echo "N" > /sys/module/hid_magicmouse/parameters/emulate_scroll_wheel
echo "0" > /sys/module/hid_magicmouse/parameters/scroll_speed
#echo "N" > /sys/module/otg_wakelock/parameters/enabled
echo "Y" > /sys/module/workqueue/parameters/power_efficient
echo "N" > /sys/module/sync/parameters/fsync_enabled
#echo "0" > /sys/module/wakelock/parameters/debug_mask
#echo "0" > /sys/module/userwakelock/parameters/debug_mask
echo "0" > /sys/module/binder/parameters/debug_mask
echo "0" > /sys/module/debug/parameters/enable_event_log
echo "0" > /sys/module/glink/parameters/debug_mask
echo "N" > /sys/module/ip6_tunnel/parameters/log_ecn_error
echo "0" /sys/module/subsystem_restart/parameters/enable_ramdumps
echo "0" > /sys/module/lowmemorykiller/parameters/debug_level
echo "0" > /sys/module/msm_show_resume_irq/parameters/debug_mask
echo "0" > /sys/module/msm_smd_pkt/parameters/debug_mask
echo "N" > /sys/module/sit/parameters/log_ecn_error
echo "0" > /sys/module/smp2p/parameters/debug_mask
echo "0" > /sys/module/usb_bam/parameters/enable_event_log
echo "Y" > /sys/module/printk/parameters/console_suspend
echo "N" > /sys/module/printk/parameters/cpu
echo "Y" > /sys/module/printk/parameters/ignore_loglevel
echo "N" > /sys/module/printk/parameters/pid
echo "N" > /sys/module/printk/parameters/time
echo "0" > /sys/module/service_locator/parameters/enable
echo "1" > /sys/module/subsystem_restart/parameters/disable_restart_work

for i in $(find /sys/ -name debug_mask); do
echo "0" > $i;
done
for i in $(find /sys/ -name debug_level); do
echo "0" > $i;
done
for i in $(find /sys/ -name edac_mc_log_ce); do
echo "0" > $i;
done
for i in $(find /sys/ -name edac_mc_log_ue); do
echo "0" > $i;
done
for i in $(find /sys/ -name enable_event_log); do
echo "0" > $i;
done
for i in $(find /sys/ -name log_ecn_error); do
echo "0" > $i;
done
for i in $(find /sys/ -name snapshot_crashdumper); do
echo "0" > $i;
done

# BusyBox Debugging
busybox=/sbin/.magisk/busybox/busybox

mount -o rw,remount / 2>/dev/null
mount -o rw,remount / / 2>/dev/null
mount -o rw,remount rootfs 2>/dev/null
mount -o rw,remount /system 2>/dev/null
mount -o rw,remount /system /system 2>/dev/null
$busybox mount -o rw,remount / 2>/dev/null
$busybox mount -o rw,remount / / 2>/dev/null
$busybox mount -o rw,remount rootfs 2>/dev/null
$busybox mount -o rw,remount /system 2>/dev/null
$busybox mount -o rw,remount /system /system 2>/dev/null

for i in $($busybox find /sys -name debug_mask); do
  $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name debug); do
  $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name debug_enable); do
  $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name debug_level); do
 $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name edac_mc_log_ce); do
 $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name edac_mc_log_ue); do
 $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name pwrnap); do
 $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name enable_event_log); do
 $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name log_ecn_error); do
 $busybox echo "0" > "$i"
done

for i in $($busybox find /sys -name snapshot_crashdumper); do
 $busybox echo "0" > "$i"
done

resetprop ro.config.nocheckin 1
resetprop profiler.force_disable_err_rpt 1

console_suspend=/sys/module/printk/parameters/console_suspend
if [ -e $console_suspend ]; then
 $busybox echo "Y" > $console_suspend
fi;

log_mode=/sys/module/logger/parameters/log_mode
if [ -e $log_mode ]; then
 $busybox echo "2" > $log_mode
fi;

debug_enabled=/sys/kernel/debug/debug_enabled
if [ -e $debug_enabled ]; then
 $busybox echo "N" > $debug_enabled
fi;

exception_trace=/proc/sys/debug/exception-trace
if [ -e "$exception_trace" ]; then
 $busybox echo "0" > "$exception_trace"
fi;

mali_debug_level=/sys/module/mali/parameters/mali_debug_level
if [ -e $mali_debug_level ]; then
 $busybox echo "0" > $mali_debug_level
fi;

block_dump=/proc/sys/vm/block_dump
if [ -e $block_dump ]; then
 $busybox echo "0" > $block_dump
fi;

mballoc_debug=/sys/module/ext4/parameters/mballoc_debug
if [ -e $mballoc_debug ]; then
 $busybox echo "0" > $mballoc_debug
fi;

logger_mode=/sys/kernel/logger_mode/logger_mode
if [ -e $logger_mode ]; then
 $busybox echo "0" > $logger_mode
fi;

log_enabled=/sys/module/logger/parameters/log_enabled
if [ -e $log_enabled ]; then
 $busybox echo "0" > $log_enabled
fi;

logger_enabled=/sys/module/logger/parameters/enabled
if [ -e $logger_enabled ]; then
 $busybox echo "0" > $logger_enabled
fi;

compat_log=/proc/sys/kernel/compat-log
if [ -e $compat_log ]; then
 $busybox echo "0" > $compat_log
fi;

disable_ertm=/sys/module/bluetooth/parameters/disable_ertm
if [ -e $disable_ertm ]; then
 $busybox echo "0" > $disable_ertm
fi;

disable_esco=/sys/module/bluetooth/parameters/disable_esco
if [ -e $disable_esco ]; then
 $busybox echo "0" > $disable_esco
fi;

if [ -e proc/sys/debug/exception-trace ]; then
 echo "0" > /proc/sys/debug/exception-trace
fi;
if [ -e /proc/sys/kernel/compat-log ]; then
 echo "0" > /proc/sys/kernel/compat-log
fi;
if [ -e /sys/module/logger/parameters/log_mode ]; then
 echo "2" > /sys/module/logger/parameters/log_mode
fi;
if [ -e /sys/class/lcd/panel/power_reduce ]; then
 echo "1" > /sys/class/lcd/panel/power_reduce
fi;

echo "Disable Debugging Excecuted on $(date +"%d-%m-%Y %r" )" >> /storage/emulated/0/injector.log
echo "" >> /storage/emulated/0/injector.log

# Virtual Memory tweaks & enhancements for a massively improved balance between performance and battery life;
echo "1" > /proc/sys/vm/drop_caches
echo "10" > /proc/sys/vm/dirty_background_ratio
echo "400" > /proc/sys/vm/dirty_expire_centisecs
echo "0" > /proc/sys/vm/page-cluster
echo "40" > /proc/sys/vm/dirty_ratio
echo "0" > /proc/sys/vm/laptop_mode
echo "0" > /proc/sys/vm/block_dump
echo "1" > /proc/sys/vm/compact_memory
echo "3000" > /proc/sys/vm/dirty_writeback_centisecs
echo "0" > /proc/sys/vm/oom_dump_tasks
echo "0" > /proc/sys/vm/oom_kill_allocating_task
echo "1103" > /proc/sys/vm/stat_interval
echo "0" > /proc/sys/vm/panic_on_oom
echo "75" > /proc/sys/vm/swappiness
echo "94" > /proc/sys/vm/vfs_cache_pressure
echo '50' > /proc/sys/vm/overcommit_ratio
echo '24300' > /proc/sys/vm/extra_free_kbytes
echo '64' > /proc/sys/kernel/random/read_wakeup_threshold
#echo '128' > /proc/sys/kernel/random/read_wakeup_threshold
echo '896' > /proc/sys/kernel/random/write_wakeup_threshold
#echo '0' > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo '21816,29088,36360,43632,50904,65448' > /sys/module/lowmemorykiller/parameters/minfree

if [ -e "/sys/module/lowmemorykiller/parameters/oom_reaper" ]; then
echo "1" > /sys/module/lowmemorykiller/parameters/oom_reaper
fi;

echo "0" > /d/tracing/tracing_on;
echo "0" > /sys/module/rmnet_data/parameters/rmnet_data_log_level;
if [ -e /sys/kernel/debug/kgsl/kgsl-3d0/log_level_cmd ];then
echo "0" > /sys/kernel/debug/kgsl/kgsl-3d0/log_level_cmd;
echo "0" > /sys/kernel/debug/kgsl/kgsl-3d0/log_level_ctxt;
echo "0" > /sys/kernel/debug/kgsl/kgsl-3d0/log_level_drv;
echo "0" > /sys/kernel/debug/kgsl/kgsl-3d0/log_level_mem;
echo "0" > /sys/kernel/debug/kgsl/kgsl-3d0/log_level_pwr;
fi;

# VRAM
sysctl -w vm.compact_unevictable_allowed=0
sysctl -w vm.dirty_background_ratio=10
sysctl -w vm.dirty_ratio=30
sysctl -w vm.dirty_expire_centisecs=1000
sysctl -w vm.dirty_writeback_centisecs=0
sysctl -w vm.extfrag_threshold=750
sysctl -w vm.oom_dump_tasks=0
sysctl -w vm.page-cluster=0
sysctl -w vm.reap_mem_on_sigkill=1
sysctl -w vm.stat_interval=10
sysctl -w vm.swappiness=80
sysctl -w vm.vfs_cache_pressure=200
sysctl -w vm.watermark_scale_factor=100

echo "Virtual Ram Memory Excecuted on $(date +"%d-%m-%Y %r" )" >> /storage/emulated/0/injector.log
echo "" >> /storage/emulated/0/injector.log

# Network tweaks for slightly reduced battery consumption when being "actively" connected to a network connection;
echo "1" > /proc/sys/net/ipv4/route/flush
echo "1" > /proc/sys/net/ipv4/tcp_mtu_probing;
echo "0" > /proc/sys/net/ipv4/conf/all/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/default/rp_filter
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
echo "1" > /proc/sys/net/ipv4/conf/all/log_martians
echo "1" > /proc/sys/kernel/kptr_restrict 
echo "6" > /proc/sys/net/ipv4/tcp_retries2
echo "1" > /proc/sys/net/ipv4/tcp_low_latency
echo "0" > /proc/sys/net/ipv4/tcp_slow_start_after_idle
echo "0" > /proc/sys/net/ipv4/conf/default/secure_redirects
echo "0" > /proc/sys/net/ipv4/conf/default/accept_redirects
echo "0" > /proc/sys/net/ipv4/conf/default/accept_source_route
echo "0" > /proc/sys/net/ipv4/conf/all/secure_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
echo "0" > /proc/sys/net/ipv4/ip_forward
echo "0" > /proc/sys/net/ipv4/ip_dynaddr
echo "0" > /proc/sys/net/ipv4/ip_no_pmtu_disc
echo "1" > /proc/sys/net/ipv4/tcp_ecn
echo "3" > /proc/sys/net/ipv4/tcp_fastopen
echo "0" > /proc/sys/net/ipv4/tcp_delayed_ack
echo "1" > /proc/sys/net/ipv4/tcp_timestamps
echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
echo "1" > /proc/sys/net/ipv4/tcp_fack
echo "1" > /proc/sys/net/ipv4/tcp_sack
echo "1" > /proc/sys/net/ipv4/tcp_dsack
echo "1" > /proc/sys/net/ipv4/tcp_rfc1337
echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle
echo "1" > /proc/sys/net/ipv4/tcp_window_scaling
echo "1" > /proc/sys/net/ipv4/tcp_moderate_rcvbuf
echo "1" > /proc/sys/net/ipv4/tcp_no_metrics_save
echo "2" > /proc/sys/net/ipv4/tcp_synack_retries
echo "2" > /proc/sys/net/ipv4/tcp_syn_retries
echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes
echo "320" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "10" > /proc/sys/net/ipv4/tcp_fin_timeout
echo "21600" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "2097152" > /proc/sys/net/core/rmem_max
echo "2097152" > /proc/sys/net/core/wmem_max
echo "1048576" > /proc/sys/net/core/rmem_default
echo "1048576" > /proc/sys/net/core/wmem_default
echo "300000" > /proc/sys/net/core/netdev_max_backlog
echo "0" > /proc/sys/net/core/netdev_tstamp_prequeue
echo "0" > /proc/sys/net/ipv4/cipso_cache_bucket_size
echo "0" > /proc/sys/net/ipv4/cipso_cache_enable
echo "0" > /proc/sys/net/ipv4/cipso_rbm_strictvalid
echo "0" > /proc/sys/net/ipv4/igmp_link_local_mcast_reports
echo "30" > /proc/sys/net/ipv4/ipfrag_time
echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control
echo "0" > /proc/sys/net/ipv4/tcp_fwmark_accept
echo "600" > /proc/sys/net/ipv4/tcp_probe_interval
echo "60" > /proc/sys/net/ipv6/ip6frag_time

# MTU Tweak
for i in $(ls /sys/class/net); do
echo "128" > /sys/class/net/"$i"/tx_queue_len
done
echo "2" > /sys/module/tcp_cubic/parameters/hystart_detect;

for i in $(ls /sys/class/net); do
echo "1500" > /sys/class/net/"$i"/mtu
done

#data connections and network buffer optimizations
setprop net.tcp.buffersize.hsdpa 4096,32768,65536,4096,32768,65536;
setprop net.tcp.buffersize.hspa 4096,32768,65536,4096,32768,65536;
setprop net.tcp.buffersize.hspap 4096,32768,65536,4096,32768,65536;
setprop net.tcp.buffersize.hsupa 4096,32768,65536,4096,32768,65536;
setprop net.tcp.buffersize.umts 4095,87380,110208,4096,32768,110208;
setprop net.tcp.buffersize.default 4094,87380,1220608,4096,32768,1220608;
setprop net.tcp.buffersize.edge 4093,26280,35040,4096,16384,35040;
setprop net.tcp.buffersize.evdo 4093,26280,35040,4096,16384,35040;
setprop net.tcp.buffersize.gprs 4092,8760,11680,4096,8760,11680;
setprop net.tcp.buffersize.wifi 4094,87380,1220608,4096,32768,1220608;

echo "TCP Excecuted on $(date +"%d-%m-%Y %r" )" >> /storage/emulated/0/injector.log
echo "" >> /storage/emulated/0/injector.log

# Enable a tuned Boeffla wakelock blocker at boot for both better active & idle battery life;
#echo "enable_wlan_ws;enable_wlan_wow_wl_ws;enable_wlan_extscan_wl_ws;enable_timerfd_ws;enable_qcom_rx_wakelock_ws;enable_netmgr_wl_ws;enable_netlink_ws;enable_ipa_ws;tftp_server_wakelock;" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;SensorService_wakelock;tftp_server_wakelock;wlan_wow_wl;wlan_extscan_wl;" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker

# Disable Wakelock
if [ -e /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
   echo "qcom_rx_wakelock;wcnss_filter_lock;wlan;wlan_ipa;IPA_WS;wlan_pno_wl;wlan_wow_wl;wlan_extscan_wl;net;IPCRTR_lpass_rx;eventpoll;event2;KeyEvents;eventpoll;NETLINK;NETLINK;NETLINK;mpss_IPCRTR;NETLINK;eventpoll;NETLINK;IPCRTR_mpss_rx;NETLINK;eventpoll;[timerfd];hal_bluetooth_lock;sensor_ind;netmgr_wl;qcom_rx_wakelock;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12" > /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker
fi;

if [ -e /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
   echo "qcom_rx_wakelock;wcnss_filter_lock;wlan;wlan_ipa;IPA_WS;wlan_pno_wl;wlan_wow_wl;wlan_extscan_wl;net;IPCRTR_lpass_rx;eventpoll;event2;KeyEvents;eventpoll;NETLINK;NETLINK;NETLINK;mpss_IPCRTR;NETLINK;eventpoll;NETLINK;IPCRTR_mpss_rx;NETLINK;eventpoll;[timerfd];hal_bluetooth_lock;sensor_ind;netmgr_wl;qcom_rx_wakelock;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
fi;

echo "Wakelock Excecuted on $(date +"%d-%m-%Y %r" )" >> /storage/emulated/0/injector.log
echo "" >> /storage/emulated/0/injector.log

# Memory Tuning
echo '1024' > /sys/block/ram0/queue/read_ahead_kb
echo '1024' > /sys/block/ram1/queue/read_ahead_kb
echo '1024' > /sys/block/ram2/queue/read_ahead_kb
echo '1024' > /sys/block/ram3/queue/read_ahead_kb
echo '1024' > /sys/block/ram4/queue/read_ahead_kb
echo '1024' > /sys/block/ram5/queue/read_ahead_kb
echo '1024' > /sys/block/ram6/queue/read_ahead_kb
echo '1024' > /sys/block/ram7/queue/read_ahead_kb
echo '1024' > /sys/block/ram8/queue/read_ahead_kb
echo '1024' > /sys/block/ram9/queue/read_ahead_kb
echo '1024' > /sys/block/ram10/queue/read_ahead_kb
echo '1024' > /sys/block/ram11/queue/read_ahead_kb
echo '1024' > /sys/block/ram12/queue/read_ahead_kb
echo '1024' > /sys/block/ram13/queue/read_ahead_kb
echo '1024' > /sys/block/ram14/queue/read_ahead_kb
echo '1024' > /sys/block/ram15/queue/read_ahead_kb
echo '1024' > /sys/block/vnswap0/queue/read_ahead_kb
# ZRAM
echo '1024' > /sys/block/zram0/queue/read_ahead_kb

echo "Ram Tuning Excecuted on $(date +"%d-%m-%Y %r" )" >> /storage/emulated/0/injector.log
echo "" >> /storage/emulated/0/injector.log

# Miscellaneous
echo "0" > /sys/kernel/printk_mode/printk_mode
echo "7 7" > /sys/kernel/sound_control/headphone_gain
echo "3" > /sys/kernel/sound_control/mic_gain "3"
echo "7" > /sys/kernel/sound_control/earpiece_gain
echo "0" > /sys/module/msm_thermal/parameters/enabled
echo "0" > /sys/module/msm_thermal/core_control/enabled
echo "0" > /sys/module/msm_thermal/vdd_restriction/enabled
echo "Y" > /sys/module/mmc_core/parameters/use_spi_crc
echo "mem" > /sys/power/autosleep

# Disabling ksm
setprop ro.config.ksm.support false
if [ -e /sys/kernel/mm/ksm/run ]; then
  echo "0" > /sys/kernel/mm/ksm/run
fi

# Disabling uksm
setprop ro.config.uksm.support false
if [ -e /sys/kernel/mm/uksm/run ]; then
  echo "0" > /sys/kernel/mm/uksm/run
fi
 
# Enable Fast Charge for slightly faster battery charging when being connected to a USB 3.1 port
if [ -e /sys/kernel/fast_charge/force_fast_charge ]; then
  echo "1" > /sys/kernel/fast_charge/force_fast_charge
fi

# lpm Levels
lpm=/sys/module/lpm_levels
if [ -d $lpm/parameters ]; then
  echo "Y" > $lpm/parameters/lpm_prediction
  echo "0" > $lpm/parameters/sleep_disabled
fi

if [ -e /sys/class/lcd/panel/power_reduce ]; then
  echo "1" > /sys/class/lcd/panel/power_reduce
fi

if [ -e /sys/module/pm2/parameters/idle_sleep_mode ]; then
  echo "Y" > /sys/module/pm2/parameters/idle_sleep_mode
fi

# A miscellaneous pm_async tweak that increases the amount of time (in milliseconds) before user processes & kernel threads are being frozen & "put to sleep";
if [ -e /sys/power/pm_freeze_timeout ]; then
  echo "25000" > /sys/power/pm_freeze_timeout
fi

resetprop debug.egl.buffcount 4
echo "0" > /proc/sys/vm/oom_kill_allocating_task

# DT2W Enable
if [ -e /sys/touchpanel/double_tap ]; then
  echo "1" > /sys/touchpanel/double_tap
fi

#Enable msm_thermal and core_control
echo "1" > /sys/module/msm_thermal/core_control/enabled
echo "0" > /sys/module/msm_performance/parameters/touchboost
echo "Y" > /sys/module/msm_thermal/parameters/enabled

# Disable exception-trace and reduce some overhead that is caused by a certain amount and percent of kernel logging, in case your kernel of choice have it enabled;
echo "0" > /proc/sys/debug/exception-trace

# Disable a few minor and overall pretty useless modules for slightly better battery life & system wide performance;
echo "Y" > /sys/module/bluetooth/parameters/disable_ertm
echo "Y" > /sys/module/bluetooth/parameters/disable_esco

# FileSystem (FS) optimized tweaks & enhancements for a improved userspace experience;
echo "0" > /proc/sys/fs/dir-notify-enable
echo "20" > /proc/sys/fs/lease-break-time
echo "0" > /proc/sys/kernel/hung_task_timeout_secs

# Disable GPU frequency based throttling;
echo "0" > /sys/class/kgsl/kgsl-3d0/throttling

echo "Miscellaneous Tweaks Excecuted on $(date +"%d-%m-%Y %r" )" >> /storage/emulated/0/injector.log
echo "" >> /storage/emulated/0/injector.log

#Execute Gaming Mode(by @HafizZiq)
while true; do
 sleep 5
  if [ $(top -n 1 -d 1 | head -n 12 | grep -o -e 'mobile' -e 'skynet' -e 'cputhrottlingtest' -e 'codm' -e 'legends' -e 'nexon' -e 'ea.game' -e 'konami' -e 'bandainamco' -e 'netmarble' -e 'GoogleCam' -e 'edengames' -e 'camera' -e 'snapcam' -e 'tencent' -e 'moonton' -e 'gameloft' -e 'netease' -e 'garena' | head -n 1) ]; then
  echo "0" > /sys/module/msm_thermal/core_control/enabled
  chmod 0644 > /sys/module/workqueue/parameters/power_efficient
  echo "N" > /sys/module/workqueue/parameters/power_efficient
  echo "1" > /sys/module/msm_thermal/core_control/enabled
 else
  sleep 5
  echo "0" > /sys/module/msm_thermal/core_control/enabled
  chmod 0644 > /sys/module/workqueue/parameters/power_efficient
  echo "Y" > /sys/module/workqueue/parameters/power_efficient
  echo "1" > /sys/module/msm_thermal/core_control/enabled
 fi;
done
