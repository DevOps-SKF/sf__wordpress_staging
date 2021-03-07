#!/bin/sh

helpFunction()
{
   echo ""
   echo "Usage: $0 -k ssh_key -u user -i IP -h hostname -p playbook"
   echo -e "\t-k ssh-key (aws-common.pem)"
   echo -e "\t-u user (ubuntu, azureuser...)"
   echo -e "\t-i FQDN or IP"
   echo -e "\t-h hostname form DDNS"
   echo -e "\t-p playbook (stdprep.yml)"
   exit 1 # Exit script after printing help
}

while getopts "k:u:i:h:p:" opt
do
   case "$opt" in
      k ) KEY="$OPTARG" ;;
      u ) USER="$OPTARG" ;;
      i ) IP="$OPTARG" ;;
      h ) HOST="$OPTARG" ;;
      p ) PLAY="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$KEY" ] || [ -z "$USER" ] || [ -z "$IP" ] || [ -z "$HOST" ] || [ -z "$PLAY" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

#echo $KEY $USER $IP $PLAY
ansible-playbook --become -e "ansible_python_interpreter=/usr/bin/python3" --private-key="~/.ssh/$KEY" \
    -u $USER -i $IP, --extra-vars "hostname=$HOST" $PLAY
# ./aplay.sh -k aws-common.pem -u ubuntu -i 35.157.131.12 -h Micro -p stdprep.yml