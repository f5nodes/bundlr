#!/bin/bash

if [ "$language" = "uk" ]; then
	step_1='\n\e[94mВстановлення софта...\e[0m\n'
	step_2='\n\e[94mСофт встановлено...\e[0m\n'
	step_3='\n\e[94mСтворюємо docker-compose файл...\e[0m\n'
	step_4='\n\e[94mDocker контейнер запущено...\e[0m\n'
else
	step_1='\n\e[94mInstalling software...\e[0m\n'
	step_2='\n\e[94mSoftware installed...\e[0m\n'
	step_3='\n\e[94mCreating a docker-compose file...\e[0m\n'
	step_4='\n\e[94mDocker container started...\e[0m\n'
fi
echo -e $step_1
sudo apt update && sudo apt install curl -y &>/dev/null
sudo apt-get install curl wget jq libpq-dev libssl-dev build-essential pkg-config openssl ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y &>/dev/null
curl -s https://raw.githubusercontent.com/f5nodes/root/main/install/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/f5nodes/root/main/install/rust.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/f5nodes/root/main/install/node.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/f5nodes/root/main/install/docker.sh | bash &>/dev/null
echo -e $step_2
source $HOME/.profile
source "$HOME/.cargo/env"
mkdir $HOME/bundlr
cd $HOME/bundlr
git clone --recurse-submodules https://github.com/Bundlr-Network/validator-rust.git
cd $HOME/bundlr/validator-rust && cargo run --bin wallet-tool create > wallet.json
echo -e $step_3
sudo tee <<EOF >/dev/null $HOME/bundlr/validator-rust/.env
PORT=2109
VALIDATOR_KEY=./wallet.json
BUNDLER_URL=https://testnet1.bundlr.network
GW_WALLET=./wallet.json
GW_CONTRACT=RkinCLBlY4L5GZFv8gCFcrygTyd5Xm91CzKlR6qxhKA
GW_ARWEAVE=https://arweave.testnet1.bundlr.network
EOF
cd $HOME/bundlr/validator-rust && docker-compose up -d
echo -e $step_4
echo -e "\n\e[93mBundlr Network Validator\e[0m"
if [ "$language" = "uk" ]; then
	echo -e "Ваша Bundlr нода \e[92mвстановлена та працює\e[0m!"
    echo -e "Подивитись логи ноди можна командою \e[92mdocker-compose -f $HOME/bundlr/validator-rust/docker-compose.yml logs -f --tail=100\e[0m"
    echo -e "Зробити рестарт ноди \e[92mdocker-compose -f $HOME/bundlr/validator-rust/docker-compose.yml restart\e[0m"
    echo -e "Бекап файл: $HOME/bundlr/validator-rust/wallet.json"
else
	echo -e "Your Bundlr node \e[92msuccessfully installed and running\e[0m!"
    echo -e "To check node logs use command \e[92mdocker-compose -f $HOME/bundlr/validator-rust/docker-compose.yml logs -f --tail=100\e[0m"
    echo -e "To restart the node \e[92mdocker-compose -f $HOME/bundlr/validator-rust/docker-compose.yml restart\e[0m"
    echo -e "Бекап файл: $HOME/bundlr/validator-rust/wallet.json"
fi