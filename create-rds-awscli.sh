#!/bin/bash
#USE INTRUCTIONS
#./create-rds.sh -dbtype db.r5.4xlarge -amount_instances 5 -cluster main-perf-cluster
#./create-rds.sh -dbtype db.r5.4xlarge -amount_instances 5 -cluster perf-payment-cluster
if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Example: ./create-rds.sh -dbtype db.r5.4xlarge -amount_instances 5 -cluster main-perf-cluster"
else
    

while [[ $# > 0 ]]  # Itero sobre la cantidad de parametros que se ingresaron.
do
    case "$1" in
        -dbtype  )
            shift  # Una vez que se encuentra el patron "-dbtype" "
                   # Se recorre el indice del array de argumentos.
            declare dbtype="$1"  # Entonces el siguiente valor de entrada se almacena en la variable "dbtype"
            shift  # Y se vuelve a recorrer para proceder con este método.
        ;;
        -amount_instances )
            shift
            declare amount_instances="$1"
            shift
        ;;
        -cluster )
            shift
            declare PERF_CLUSTER_IDENTIFIER="$1"
            shift 
       
        ;;
        * ) 
            # En caso de no coincidir, de igual forma se recorre el indice para
            # continuar con el bucle.
            shift
        ;;
    esac        
done 


#Data:
#PERF_CLUSTER_IDENTIFIER=
#PERF_CLUSTER_IDENTIFIER="main-perf-cluster"
#PERF_CLUSTER_PAYMENT_IDENTIFIER="perf-payment-cluster"
ENGINE="aurora-mysql"
ENGINE_VERSION="5.7.12"
PERF_DB_CLASS=$dbtype
DB_INSTANCE_NAME="db-$RANDOM"
#DB_INSTANCE_PAYMENT_NAME="perf-payment-"
SNAPSHOT_IDENTIFIER="db-dump-perf-request-$(date +%s)"
DB_SUBNET_GROUP_NAME="cluster-frantest"
VPC_SECURITY_GROUP_IDS="sg-0922db0e530bbda3f"
MASTER_USERNAME_MYSQL="scalefast"
MASTER_PASSWORD_MYSQL="scalefast"
DB_USER=
DB_PASS=
# See https://sipb.mit.edu/doc/safe-shell/
set -euf -o pipefail


#CREATE CLUSTER
aws rds create-db-cluster --db-cluster-identifier $PERF_CLUSTER_IDENTIFIER --engine $ENGINE \
--engine-version  $ENGINE_VERSION  --master-username $MASTER_USERNAME_MYSQL --master-user-password $MASTER_PASSWORD_MYSQL \
--db-subnet-group-name $DB_SUBNET_GROUP_NAME --vpc-security-group-ids $VPC_SECURITY_GROUP_IDS

##CREATE INSTANCES
for (( contador=1; contador<=$amount_instances; contador++ ))
    do
    aws rds create-db-instance --db-instance-identifier $DB_INSTANCE_NAME-$contador      --db-cluster-identifier $PERF_CLUSTER_IDENTIFIER --engine $ENGINE --db-instance-class $PERF_DB_CLASS
    done



#MYSQL SECTION

#DB_HOST=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_NAME-1|jq '.DBInstances[0] .Endpoint.Address')


# USER
#echo "Updating User"
## Set Password and Salt
#mysql -u $DB_USER -h $DB_HOST -p$DB_PASS pepita -e "UPDATE user SET pass='ef6857cfa873957671c854a1bc5a253847d14481a7d1e41446afae0ad8c2a241', salt='NXh+406wRCILJjfP2tbBpfAPnjS9JuIk';"

## Set Email like: {user_id}@scalefast.com
#mysql -u $DB_USER -h $DB_HOST -p$DB_PASS pepita -e "UPDATE personal_info pi, user u SET pi.email = CONCAT(u.user_id,'@scalefast.com') WHERE u.info_id=pi.info_id;"

#mysql -u $DB_USER -h $DB_HOST -p$DB_PASS pepita -e "UPDATE profesional_info pi, user u SET pi.email = CONCAT(u.user_id,'@scalefast.com') WHERE u.info_id=pi.info_id;"

fi
