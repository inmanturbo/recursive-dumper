#!/bin/sh

unset HOST
unset USER
unset OUTPUT_DIR
unset COMMIT_MESSAGE
unset REMOTE
unset BRANCH
unset table
unset db
unset PASSWORD

helpmenu () {

  echo 'Options:                                                                             '
  echo '  -h, --help            # print help menu and exit                                   '
  echo '  -r, --repo            # git repo (requires existing --initialized-- git repo)      '
  echo '  -gz, --tar            # compress indevidual sql files. Does not work with git      '
  echo '  -m, --message [$NOW]  # commit message [OPTIONAL]                                  '
  echo '  -R, --remote [origin] # commit remote [OPTIONAL]                                   '
  echo '  -b, --branch          # Do not ask any interactive question                        '
  echo '  -o, --out-dir [$(pwd)/mysqldump_${NOW}] # output directory (where to dump the data)'
  echo '  -h, --host [localhost] # mysql host                                                '
  echo '      --port [3306]      # mysql port                                                '
  echo '  -u, --user [root]     # mysql user                                                 '
  echo '  -p, --password required # mysql password (leave empty                              '
  echo '                            to enter interactively and avoid passing in clear text   '
  echo '                            through shell)                                           '
  echo '  -v, --verbose         # show output                                                '
  echo ''

  exit 1
}

command -v mysql >/dev/null 2>&1 || { echo >&2 "I require mysql-client but it's not installed. Aborting."; helpmenu; exit 1; }

read_password () {
  stty -echo
  printf "Password: "
  read PASSWORD
  if [ ! ${#PASSWORD} -ge 5 ]; then
      echo "password too short!"
      read_password
  fi
  stty echo
  printf "\n"
}

dumpdatabase() {
 local host="$1"
 local user="$2"
 local password="$3"
 local database="$4"
 local dir="$5"
 local port="$6"



 mysqldump \
  -h ${host} \
  -P ${port} \
  -u ${user} \
  -p${password} \
  --flush-logs --single-transaction \
  ${database} \
  |tee ${dir}/mariadb/${database}.sql > /dev/null

}

dumpdatabasegz() {
 local host="$1"
 local user="$2"
 local password="$3"
 local database="$4"
 local dir="$5"
 local port="$6"

 mysqldump \
  -h ${host} \
  -P ${port} \
  -u ${user} \
  -p${password} \
  --flush-logs --single-transaction \
  ${database} \
  | gzip -c > ${dir}/mariadb/${database}.sql.tar.gz

}

dumptable() {

 local host="$1"
 local user="$2"
 local password="$3"
 local database="$4"
 local dir="$5"
 local table_name="$6"
 local port="$7"

 mysqldump \
  -h ${host} \
  -P ${port} \
  -u ${user} \
  -p${password} \
  --flush-logs --single-transaction \
  ${database} ${table_name} \
  |tee ${dir}/${database}/mariadb/${table_name}.sql > /dev/null

}

dumptablegz() {

 local host="$1"
 local user="$2"
 local password="$3"
 local database="$4"
 local dir="$5"
 local table_name="$6"
 local port="$7"

 mysqldump \
  -h ${host} \
  -P ${port} \
  -u ${user} \
  -p${password} \
  --flush-logs --single-transaction \
  ${database} ${table_name} \
  | gzip -c > ${dir}/${database}/mariadb/${table_name}.sql.tar.gz

}

NOW=$(date "+%Y-%m-%d_%H-%M-%S")

while [ ! $# -eq 0 ]
do
	case "$1" in

    # mysql password
		--password | -p)

      case "$2" in
        *-*|'' ) read_password ;;
      esac
      
      PASSWORD=${PASSWORD:-$2}
			;;

    # print help menu and exit
		--help )
			helpmenu
			exit
			;;
    
    # git repo (requires existing --initialized-- git repo)
    --repo | -r)
			REPO=$2
			;;

    # tarball
    --tar | -gz)
			TARBALL=1
			;;

    # commit message [OPTIONAL]
    --message | -m)
			COMMIT_MESSAGE=${2:-"auto_committed on ${NOW}"} 
			;;

    # commit remote [OPTIONAL]
    --remote | -R)
			REMOTE=${$2:-origin}
			;;

    # commit branch [OPTIONAL]
    --branch | -b)
			BRANCH=${2:-master}
			;;

    # output directory (where to dump the data)
    --out-dir | -O)    
      OUTPUT_DIR=${2}
      ;;
    
    #mysql user
    --host | -h)
			 HOST=${2:-localhost}
			;;

    #mysql port
    --port)
			 PORT=${2:-3306}
			;;

    #mysql user
    --user | -u)
			 USER=${2:-root}
			;;
    #verbose
    --verbose | -v)
			 VERBOSE=1
			;;

	esac
	shift
done

HOST=${HOST:-localhost}
USER=${USER:-root}
OUTPUT_DIR=${OUTPUT_DIR:-$(pwd)/mysqldump_${NOW}}
COMMIT_MESSAGE=${COMMIT_MESSAGE:-auto_committed on $NOW} 
REMOTE=${REMOTE:-origin}
BRANCH=${BRANCH:-master}
PORT=${PORT:-3306}


if [ ! -z "$TARBALL" ] && [ ! -z "$REPO" ] ; then
  echo '  -gz, --tar            # compress indevidual sql files. Does not work with git      '
  helpmenu
  exit 1
fi

if [ ! -z "$REPO" ]; then
  git clone ${REPO} ${OUTPUT_DIR}
fi

#prepare directories

mkdir -p ${OUTPUT_DIR}/mariadb
mkdir -p ${OUTPUT_DIR}/json
mkdir -p ${OUTPUT_DIR}/csv

# loop through all databases
for db in $(mysql -NBA -h ${HOST} -P ${PORT} -u ${USER} -p${PASSWORD} --execute "SHOW DATABASES";) 
   
  do 
    if [ ! -z "$VERBOSE" ]; then
    echo "working on database ${db}"
    fi
    
    # Prepare directories
    mkdir -p ${OUTPUT_DIR}/${db}/mariadb
    mkdir -p ${OUTPUT_DIR}/${db}/json 
    mkdir -p ${OUTPUT_DIR}/${db}/csv 

    if [ ! -z "$TARBALL" ]; then

      dumpdatabasegz ${HOST} ${USER} ${PASSWORD} ${db} ${OUTPUT_DIR} ${PORT}
    else

      # dump database
      dumpdatabase ${HOST} ${USER} ${PASSWORD} ${db} ${OUTPUT_DIR} ${PORT}
    fi   
    
      #loop through tables
      for table in $(mysql -NBA -h ${HOST} -P ${PORT} -u ${USER} -p${PASSWORD} ${db} --execute "SHOW TABLES";) 

      do 
        
        if [ ! -z "$VERBOSE" ]; then
          echo "working on table ${table} in database ${db}"
        fi
        
        if [ ! -z "$TARBALL" ]; then

          dumptablegz ${HOST} ${USER} ${PASSWORD} ${db} ${OUTPUT_DIR} ${table} ${PORT}
        else

          # dump table
          dumptable ${HOST} ${USER} ${PASSWORD} ${db} ${OUTPUT_DIR} ${table} ${PORT}
        fi    
      done 
done

if [ ! -z "$REPO" ]; then
  
  cd ${OUTPUT_DIR} 
  git add --all 
  git commit -m "${COMMIT_MESSAGE}" 
  git push -u $REMOTE $BRANCH;

  rm -rf ${OUTPUT_DIR}

fi
