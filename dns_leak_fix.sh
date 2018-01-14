#
# dns_leak_fix
#
# This will force OpenVPN to use default dns from your .ovpn file.
# Check https://www.dnsleaktest.com/ to see if your dns is leaking.
# 
# source for fix
#
# https://askubuntu.com/a/949272
# https://wiki.archlinux.org/index.php/OpenVPN#Update_resolv-conf_script
# 
# how to run the script
#
# 1.  Place script in a folder with your .ovpn files.
# 2.  chmod 755 dns_leak_fix.sh
# 3.  ./dns_leak_fix.sh

prompt_patch() {
  echo "$file_counter .ovpn configs found."
  echo "Do you want to run fix for all $file_counter .ovpn files?\n"
  read -p "Continue (y/n)?" choice

  case "$choice" in 
    y|Y ) patch_files;;
    n|N ) echo "no";;
    * ) echo "invalid";;
  esac
}
patch_files() {
  echo "\nChecking files..."
  echo "\nChecking script-security 2"
  script_security_2=0
  script_security_2_patched=0
  for filename in *.ovpn; do
    if grep -q "script-security 2" "$filename";
    then
      script_security_2=$((script_security_2 + 1))
    else
      script_security_2_patched=$((script_security_2_patched + 1))
      echo "script-security 2" >> $filename
    fi
  done
  echo "\t->Patched files: $script_security_2_patched"
  echo "\t->Ignored files: $script_security_2"

  echo "\nChecking up /etc/openvpn/update-resolv-conf"
  up_res=0
  up_res_patched=0
  for filename in *.ovpn; do
    if grep -q "up /etc/openvpn/update-resolv-conf" "$filename";
    then
      up_res=$((up_res + 1))
    else
      up_res_patched=$((up_res_patched + 1))
      echo "up /etc/openvpn/update-resolv-conf" >> $filename
    fi
  done
  echo "\t->Patched files: $up_res_patched"
  echo "\t->Ignored files: $up_res"

  echo "\nChecking down /etc/openvpn/update-resolv-conf"
  down_res=0
  down_res_patched=0
  for filename in *.ovpn; do
    if grep -q "down /etc/openvpn/update-resolv-conf" "$filename";
    then
      down_res=$((down_res + 1))
    else
      down_res_patched=$((down_res_patched + 1))
      echo "down /etc/openvpn/update-resolv-conf" >> $filename
    fi
  done
  echo "\t->Patched files: $down_res_patched"
  echo "\t->Ignored files: $down_res"

  echo "\nDone. Test for leaks at https://www.dnsleaktest.com/"
  
}

file_counter=0
for filename in *.ovpn; do
  [ -f "$filename" ] || break
  file_counter=$((file_counter + 1))
done

if [ $file_counter -lt 1 ]
then
  echo "No .ovpn files found in this directory."
else
  prompt_patch
fi

