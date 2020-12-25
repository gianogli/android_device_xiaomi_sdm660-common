#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
sleep 10
chmod 777 /sys/class/power_supply/*/*
chmod 777 /sys/module/qpnp_smbcharger/*/*
chmod 777 /sys/module/dwc3_msm/*/*
chmod 777 /sys/module/phy_msm_usb/*/*
while true; do
echo '1' > /sys/kernel/fast_charge/force_fast_charge
echo '1' > /sys/class/power_supply/battery/system_temp_level
echo '1' > /sys/kernel/fast_charge/failsafe
echo '1' > /sys/class/power_supply/battery/allow_hvdcp3
echo '1' > /sys/class/power_supply/usb/pd_allowed
echo '1' > /sys/class/power_supply/battery/subsystem/usb/pd_allowed
echo '0' > /sys/class/power_supply/battery/input_current_limited
echo '1' > /sys/class/power_supply/battery/input_current_settled
echo '0' > /sys/class/qcom-battery/restricted_charging
echo '150' > /sys/class/power_supply/bms/temp_cool
echo '460' > /sys/class/power_supply/bms/temp_hot
echo '460' > /sys/class/power_supply/bms/temp_warm
echo '4000000' > /sys/class/power_supply/usb/current_max
echo '4000000' > /sys/class/power_supply/usb/hw_current_max
echo '4000000' > /sys/class/power_supply/usb/pd_current_max
echo '4000000' > /sys/class/power_supply/usb/ctm_current_max
echo '4000000' > /sys/class/power_supply/usb/sdp_current_max
echo '4000000' > /sys/class/power_supply/main/current_max
echo '4000000' > /sys/class/power_supply/main/constant_charge_current_max
echo '4000000' > /sys/class/power_supply/battery/current_max
echo '4000000' > /sys/class/power_supply/battery/constant_charge_current_max
echo '5000000' > /sys/class/qcom-battery/restricted_current
echo '4000000' > /sys/class/power_supply/pc_port/current_max
sleep 1
done