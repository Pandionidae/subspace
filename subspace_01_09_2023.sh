function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git ocl-icd-opencl-dev libopencl-clang-dev libgomp1 expect -y
}

function wget_pulsar {
  wget -O pulsar https://github.com/subspace/pulsar/releases/download/v0.6.4-alpha/pulsar-ubuntu-x86_64-skylake-v0.6.4-alpha 
  sudo chmod +x pulsar
  sudo mv pulsar /usr/local/bin/
  sleep 1
}

function read_nodename {
  if [ ! $SUBSPACE_NODENAME ]; then
  echo -e "Введіть назву ноди"
  line
  read SUBSPACE_NODENAME
  export SUBSPACE_NODENAME
  sleep 1
  fi
}

function read_wallet {
  if [ ! $WALLET_ADDRESS ]; then
  echo -e "Введіть polkadot.js address"
  line
  read WALLET_ADDRESS
  export WALLET_ADDRESS
  sleep 1
  fi
}

function init_expect {
    sudo rm -rf $HOME/.config/pulsar
    expect <(curl -s https://raw.githubusercontent.com/Pandionidae/subspace/main/expect)
}          

function systemd {
  sudo tee <<EOF >/dev/null /etc/systemd/system/subspace.service
[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/pulsar farm --verbose
Restart=on-failure
LimitNOFILE=548576:1048576

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable subspace
sudo systemctl restart subspace
}

function output_after_install {
    echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 5
    if [[ `systemctl status subspace | grep active` =~ "running" ]]; then
        echo -e "Your Subspace node \e[32minstalled and works\e[39m!"
        echo -e "You can check node status by the command \e[7msystemctl status subspace\e[0m"
        echo -e "Press \e[7mQ\e[0m for exit from status menu"
    else
        echo -e "Your Subspace node \e[31mwas not installed correctly\e[39m, please reinstall."
    fi
}


read_nodename
read_wallet
install_tools
wget_pulsar
init_expect
systemd
output_after_install

