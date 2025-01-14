#!/usr/bin/env bash

##########################################
# Created by Afiniel for Yiimpool use... #
##########################################

source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf
source $HOME/Yiimpoolv1/yiimp_single/.wireguard.install.cnf

set -eu -o pipefail

function print_error {
  read line file <<<$(caller)
  echo "An error occurred in line $line of file $file:" >&2
  sed "${line}q;d" "$file" >&2
}
trap print_error ERR
term_art
echo -e "$MAGENTA    <----------------------------------------------------->${NC}"
echo -e "$MAGENTA     <--$YELLOW Installing Berkeley , openssl , bls-signatures$MAGENTA -->${NC}"
echo -e "$MAGENTA    <----------------------------------------------------->${NC}"
echo

echo -e "$YELLOW => Installing BitCoin PPA <= ${NC}"
if [ ! -f /etc/apt/sources.list.d/bitcoin.list ]; then
  hide_output sudo add-apt-repository -y ppa:bitcoin/bitcoin
fi
echo
echo -e "$YELLOW => Installing additional system files required for daemons <= ${NC}"
hide_output sudo apt-get update
apt_install build-essential libtool autotools-dev \
  automake pkg-config libssl-dev libevent-dev bsdmainutils git libboost-all-dev libminiupnpc-dev \
  libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev \
  protobuf-compiler libqrencode-dev libzmq3-dev libgmp-dev

sudo mkdir -p $STORAGE_ROOT/yiimp/yiimp_setup/tmp
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
echo
echo -e "$GREEN => Additional System Files Completed  <= ${NC}"

echo
echo -e "$MAGENTA => Building Berkeley 4.8, this may take several minutes <= ${NC}"
sudo mkdir -p $STORAGE_ROOT/berkeley/db4/
hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
hide_output sudo tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db4/
hide_output sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-4.8.30.NC.tar.gz db-4.8.30.NC
echo
echo -e "$GREEN => Berkeley 4.8 Completed <= ${NC}"
echo

echo -e "$MAGENTA => Building Berkeley 5.1, this may take several minutes <= ${NC}"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db5/
hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-5.1.29.tar.gz'
hide_output sudo tar -xzvf db-5.1.29.tar.gz
cd db-5.1.29/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db5/
hide_output sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-5.1.29.tar.gz db-5.1.29
echo -e "$GREEN => Berkeley 5.1 Completed <= ${NC}"
echo
echo -e "$MAGENTA => Building Berkeley 5.3, this may take several minutes <= ${NC}"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db5.3/
hide_output sudo wget 'http://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz'
hide_output sudo tar -xzvf db-5.3.28.tar.gz
cd db-5.3.28/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db5.3/
hide_output sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-5.3.28.tar.gz db-5.3.28
echo -e "$GREEN => Berkeley 5.3 Completed <= ${NC}"
echo
echo -e "$YELLOW Building Berkeley 6.2, this may take several minutes...${NC}"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db6.2/
hide_output sudo wget 'https://download.oracle.com/berkeley-db/db-6.2.23.tar.gz'
hide_output sudo tar -xzvf db-6.2.23.tar.gz
cd db-6.2.23/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db6.2/
hide_output sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-6.2.23.tar.gz db-6.2.23
echo -e "$GREEN => Berkeley 6.2 Completed <= ${NC}"
echo
echo -e "$YELLOW Building Berkeley 18, this may take several minutes...${NC}"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db18/
hide_output sudo wget 'https://download.oracle.com/berkeley-db/db-18.1.40.tar.gz'
hide_output sudo tar -xzvf db-18.1.40.tar.gz
cd db-18.1.40/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db18/
hide_output sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-18.1.40.tar.gz db-18.1.40
echo -e "$GREEN => Berkeley 18 Completed <= ${NC}"
echo

echo -e "$YELLOW => Building OpenSSL 1.0.2g, this may take several minutes <= ${NC}"
echo
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
hide_output sudo wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2g.tar.gz --no-check-certificate
hide_output sudo tar -xf openssl-1.0.2g.tar.gz
cd openssl-1.0.2g
hide_output sudo ./config --prefix=$STORAGE_ROOT/openssl --openssldir=$STORAGE_ROOT/openssl shared zlib
hide_output sudo make -j$((`nproc`+1))
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r openssl-1.0.2g.tar.gz openssl-1.0.2g
echo -e "$GREEN =>OpenSSL 1.0.2g Completed <= ${NC}"
echo

echo -e "$YELLOW => Building bls-signatures, this may take several minutes <= ${NC}"
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
hide_output sudo wget 'https://github.com/codablock/bls-signatures/archive/v20181101.zip'
hide_output sudo unzip v20181101.zip
cd bls-signatures-20181101
hide_output sudo cmake .
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r v20181101.zip bls-signatures-20181101
echo
echo -e "$GREEN => bls-signatures Completed${NC}"

echo
echo -e "$YELLOW => Building blocknotify.sh <= ${NC}"
if [[ ("$wireguard" == "true") ]]; then
  source $STORAGE_ROOT/yiimp/.wireguard.conf
  echo '#####################################
  # Created by Afiniel for Yiimpool use...  #
  ###########################################
  #!/bin/bash
  blocknotify '""''"${DBInternalIP}"''""':$1 $2 $3' | sudo -E tee /usr/bin/blocknotify.sh >/dev/null 2>&1
  sudo chmod +x /usr/bin/blocknotify.sh
else
  echo '#####################################
  # Created by Afiniel for Yiimpool use...  #
  ###########################################
  #!/bin/bash
  blocknotify 127.0.0.1:$1 $2 $3' | sudo -E tee /usr/bin/blocknotify.sh >/dev/null 2>&1
  sudo chmod +x /usr/bin/blocknotify.sh
fi

echo
echo -e "$GREEN Daemon setup completed ${NC}"

set +eu +o pipefail
cd $HOME/Yiimpoolv1/yiimp_single
