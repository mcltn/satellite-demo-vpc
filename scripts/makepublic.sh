##########################################################
#source .env

ibmcloud login --apikey $APIKEY -r $REGION -g $RESOURCEGROUP
#ibmcloud target -r $REGION -g $RESOURCEGROUP

### CONTROLPLANE
printf "\nSET CONTROL PLANE DNS IPS\n\n"
echo ibmcloud sat location dns register --location $LOCATION $(ibmcloud is instances | grep controlplane-$PROJECT | awk '{print "--ip " $5}')
ibmcloud sat location dns register --location $LOCATION $(ibmcloud is instances | grep controlplane-$PROJECT | awk '{print "--ip " $5}')

printf "\nGET NLB DNS HOSTNAME\n\n"
NLBHOSTNAME=$(ibmcloud ks nlb-dns ls --cluster $CLUSTER | awk 'NR == 3 {print $1}')
printf "$NLBHOSTNAME\n\n"

printf "\nGET NLB DNS INTERNAL IPS\n\n"
INTERNALIPS=$(ibmcloud ks nlb-dns ls --cluster $CLUSTER | awk 'NR == 3 {print $2}')
printf "$INTERNALIPS\n\n"

printf "\nREMOVE NLB DNS INTERNAL IPS\n"
for ip in $(echo $INTERNALIPS | tr "," "\n")
do
  printf "\nREMOVING IP : $ip\n"
  echo ibmcloud ks nlb-dns rm classic --cluster $CLUSTER --ip $ip --nlb-host $NLBHOSTNAME
  ibmcloud ks nlb-dns rm classic --cluster $CLUSTER --ip $ip --nlb-host $NLBHOSTNAME
  sleep 3
done

ibmcloud ks nlb-dns ls --cluster $CLUSTER

printf "\nADD NLB DNS PUBLIC IPS\n"
ibmcloud ks nlb-dns add --cluster $CLUSTER --nlb-host $NLBHOSTNAME $(ibmcloud is instances | grep worker-$PROJECT | awk '{print "--ip " $5}')

sleep 10

ibmcloud ks nlb-dns ls --cluster $CLUSTER

